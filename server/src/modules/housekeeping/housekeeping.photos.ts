import type { HousekeepingPhoto, HousekeepingPhotoCategory, HousekeepingTask, Prisma, User } from '@prisma/client';
import { env } from '../../config/env.js';
import { AppError, ForbiddenError, NotFoundError } from '../../lib/errors.js';
import { MSG } from '../../lib/messages.js';
import { PHOTO_MAX_BYTES, deletePhotoFile, detectImageType, readPhoto, savePhoto } from '../../lib/photo-storage.js';
import { prisma } from '../../lib/prisma.js';

/**
 * Ảnh nghiệm thu dọn phòng (FR-housekeeping-005/007, BR-006, NFR-006).
 * - Ảnh thuộc MỘT lần dọn, theo "lượt" (`task.photoRound`). Quản lý trả lại → sang lượt mới, ảnh lượt cũ giữ để truy vết.
 * - 3 nhóm bắt buộc mỗi lượt giữ 1 ảnh (tải lại = thay ảnh cũ); cận cảnh tối đa MAX_CLOSEUPS ảnh.
 * - Chỉ nhân viên phụ trách thêm/xóa, và chỉ khi việc "đang làm". Xem: nhân viên phụ trách + quản lý.
 * Tải ảnh là bản nháp — nhật ký ghi ở lần NỘP (báo hoàn tất), xem completeTask.
 */

/** Thứ tự nhóm khi hiển thị gallery (FR-007). */
export const PHOTO_ORDER: HousekeepingPhotoCategory[] = ['OVERVIEW', 'BED', 'BATHROOM', 'CLOSEUP'];
export const REQUIRED_CATEGORIES: HousekeepingPhotoCategory[] = ['OVERVIEW', 'BED', 'BATHROOM'];
export const MAX_CLOSEUPS = 5;

type PhotoWithUploader = HousekeepingPhoto & { uploadedBy: Pick<User, 'id' | 'fullName'> };

const uploaderInclude = { uploadedBy: { select: { id: true, fullName: true } } } as const;

/**
 * Metadata ảnh cho client. Không gồm `storageKey`.
 * @param photo Ảnh kèm người tải (id, họ tên).
 * @returns DTO với `url` tương đối `/api/housekeeping/photos/:id/file`.
 */
export function toPhotoDto(photo: PhotoWithUploader) {
  return {
    id: photo.id,
    category: photo.category,
    round: photo.round,
    mimeType: photo.mimeType,
    sizeBytes: photo.sizeBytes,
    uploadedBy: photo.uploadedBy,
    createdAt: photo.createdAt,
    // Tải bằng token như mọi API khác (Authorization header) — không có link công khai.
    url: `/api/housekeeping/photos/${photo.id}/file`,
  };
}

/**
 * Quản lý xem mọi ảnh. Nhân viên chỉ xem ảnh của việc mình được giao. Lễ tân không xem.
 * @returns `true` khi được đọc metadata và byte.
 */
function canView(actor: User, task: Pick<HousekeepingTask, 'assigneeId'>) {
  return actor.role === 'MANAGER' || (actor.role === 'STAFF' && task.assigneeId === actor.id);
}

/**
 * Sắp bản sao: lượt mới nhất trước, rồi thứ tự `PHOTO_ORDER`, rồi `createdAt` tăng dần.
 * Không sửa mảng đầu vào.
 */
function sortPhotos<T extends Pick<HousekeepingPhoto, 'round' | 'category' | 'createdAt'>>(photos: T[]) {
  return [...photos].sort(
    (a, b) =>
      b.round - a.round ||
      PHOTO_ORDER.indexOf(a.category) - PHOTO_ORDER.indexOf(b.category) ||
      a.createdAt.getTime() - b.createdAt.getTime(),
  );
}

/**
 * Đếm ảnh của lượt hiện tại theo nhóm — dùng khi báo hoàn tất.
 * @returns Map category → số ảnh. Nhóm không có thì `get` ra `undefined`.
 */
export async function countRoundPhotos(tx: Prisma.TransactionClient, task: Pick<HousekeepingTask, 'id' | 'photoRound'>) {
  const groups = await tx.housekeepingPhoto.groupBy({
    by: ['category'],
    where: { taskId: task.id, round: task.photoRound },
    _count: true,
  });
  return new Map(groups.map((g) => [g.category, g._count]));
}

/**
 * Khóa việc và yêu cầu đúng nhân viên phụ trách, status `IN_PROGRESS`.
 * Sai người → 403. Sai trạng thái → 409 `PHOTO_LOCKED`. Không kiểm version ảnh.
 */
async function lockOwnInProgressTask(tx: Prisma.TransactionClient, actor: User, taskId: string) {
  await tx.$queryRaw`SELECT 1 FROM housekeeping_tasks WHERE id = ${taskId}::uuid FOR UPDATE`;
  const task = await tx.housekeepingTask.findUnique({ where: { id: taskId } });
  if (!task) throw new NotFoundError('Công việc không tồn tại.');
  if (actor.role !== 'STAFF' || task.assigneeId !== actor.id) throw new ForbiddenError();
  if (task.status !== 'IN_PROGRESS') throw new AppError(409, 'PHOTO_LOCKED', MSG.photoLocked);
  return task;
}

/**
 * Liệt kê mọi lượt ảnh của một việc, lượt mới đứng trước.
 * @returns `currentRound` là lượt đang nộp, không phải lượt cao nhất nếu dữ liệu lệch (bình thường chúng trùng).
 */
export async function listPhotos(actor: User, taskId: string) {
  const task = await prisma.housekeepingTask.findUnique({ where: { id: taskId } });
  if (!task) throw new NotFoundError('Công việc không tồn tại.');
  if (!canView(actor, task)) throw new ForbiddenError();
  const photos = await prisma.housekeepingPhoto.findMany({ where: { taskId }, include: uploaderInclude });
  return { currentRound: task.photoRound, photos: sortPhotos(photos).map(toPhotoDto) };
}

/**
 * Tải một ảnh (body = byte). Nhóm bắt buộc: thay ảnh cũ cùng nhóm của lượt hiện tại.
 *
 * Ghi đĩa trước khi mở transaction. Transaction lỗi thì xóa tệp mới. Ảnh bị thay chỉ
 * xóa đĩa sau khi commit. Cận cảnh đủ `MAX_CLOSEUPS` → 400, không ghi đè. Không ghi nhật ký
 * (nhật ký nằm ở lần báo hoàn tất).
 * @param data Buffer đã giới hạn size ở route; hàm kiểm tra lại lần nữa.
 * @returns DTO metadata, status route là 201.
 */
export async function uploadPhoto(actor: User, taskId: string, category: HousekeepingPhotoCategory, data: Buffer) {
  if (data.length > PHOTO_MAX_BYTES) throw new AppError(413, 'PHOTO_TOO_LARGE', MSG.photoTooLarge(env.PHOTO_MAX_MB));
  const mimeType = detectImageType(data);
  if (!mimeType) throw new AppError(400, 'PHOTO_INVALID_TYPE', MSG.photoInvalidType);

  // Ghi tệp trước, transaction lỗi thì xóa tệp — không để CSDL trỏ tới tệp không tồn tại.
  const storageKey = await savePhoto(data, mimeType);
  let replaced: string[] = [];
  let photo: PhotoWithUploader;
  try {
    photo = await prisma.$transaction(async (tx) => {
      const task = await lockOwnInProgressTask(tx, actor, taskId);
      const sameGroup = await tx.housekeepingPhoto.findMany({
        where: { taskId, round: task.photoRound, category },
        select: { id: true, storageKey: true },
      });
      if (category === 'CLOSEUP') {
        if (sameGroup.length >= MAX_CLOSEUPS) throw new AppError(400, 'TOO_MANY_PHOTOS', MSG.tooManyCloseups(MAX_CLOSEUPS));
      } else if (sameGroup.length) {
        await tx.housekeepingPhoto.deleteMany({ where: { id: { in: sameGroup.map((p) => p.id) } } });
        replaced = sameGroup.map((p) => p.storageKey);
      }
      return tx.housekeepingPhoto.create({
        data: { taskId, round: task.photoRound, category, storageKey, mimeType, sizeBytes: data.length, uploadedById: actor.id },
        include: uploaderInclude,
      });
    });
  } catch (error) {
    await deletePhotoFile(storageKey);
    throw error;
  }
  // Chỉ xóa tệp ảnh bị thay SAU khi đã commit.
  await Promise.all(replaced.map(deletePhotoFile));
  return toPhotoDto(photo);
}

/**
 * Xóa ảnh để chụp lại — chỉ ảnh của lượt hiện tại, khi việc đang làm.
 *
 * Ảnh lượt cũ → 409 `PHOTO_LOCKED`. Xóa dòng rồi mới xóa tệp; nếu xóa tệp lỗi sau commit
 * thì CSDL đã mất metadata và tệp có thể còn sót.
 * @param photoId UUID ảnh, không phải id việc.
 */
export async function deletePhoto(actor: User, photoId: string) {
  const storageKey = await prisma.$transaction(async (tx) => {
    const photo = await tx.housekeepingPhoto.findUnique({ where: { id: photoId } });
    if (!photo) throw new NotFoundError('Ảnh không tồn tại.');
    const task = await lockOwnInProgressTask(tx, actor, photo.taskId);
    if (photo.round !== task.photoRound) throw new AppError(409, 'PHOTO_LOCKED', MSG.photoLocked);
    await tx.housekeepingPhoto.delete({ where: { id: photoId } });
    return photo.storageKey;
  });
  await deletePhotoFile(storageKey);
}

/**
 * Byte ảnh để hiển thị. Kiểm quyền theo việc chứa ảnh (NFR-006).
 * @returns `{ data, mimeType }` để route set Content-Type. Tệp mất trên đĩa thì ném lỗi đọc file (500).
 */
export async function getPhotoFile(actor: User, photoId: string) {
  const photo = await prisma.housekeepingPhoto.findUnique({
    where: { id: photoId },
    include: { task: { select: { assigneeId: true } } },
  });
  if (!photo) throw new NotFoundError('Ảnh không tồn tại.');
  if (!canView(actor, photo.task)) throw new ForbiddenError();
  return { data: await readPhoto(photo.storageKey), mimeType: photo.mimeType };
}
