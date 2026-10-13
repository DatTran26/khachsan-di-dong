import { Prisma, type User } from '@prisma/client';
import { diffFields, writeAudit } from '../../lib/audit.js';
import { AppError, NotFoundError } from '../../lib/errors.js';
import { MSG } from '../../lib/messages.js';
import { prisma } from '../../lib/prisma.js';
import { withTransaction } from '../../lib/transaction.js';

/**
 * Loại phòng (room-catalog FR-010, P1): quản lý thêm, đổi tên, tắt.
 * Không có API xóa — phòng cũ vẫn tham chiếu. Không có cột `version`: hai người sửa cùng lúc, lần ghi sau thắng.
 */
/** 409 khi tên loại đụng unique. @param name Tên vừa bị từ chối. */
const nameTaken = (name: string) => new AppError(409, 'ROOM_TYPE_TAKEN', MSG.roomTypeTaken(name));

/** @returns `true` khi lỗi Prisma là P2002. */
function isUniqueViolation(error: unknown) {
  return error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2002';
}

/**
 * Mọi loại phòng, kể cả đã tắt, sắp theo tên tăng dần.
 * Không lọc `isActive` — client tự ẩn loại tắt khi tạo phòng mới.
 * @returns Promise mảng bản ghi Prisma (không có DTO riêng).
 */
export function listRoomTypes() {
  return prisma.roomType.findMany({ orderBy: { name: 'asc' } });
}

/**
 * Thêm loại phòng đang dùng (`isActive` mặc định của schema).
 * Trùng tên → 409. Ghi nhật ký `room_type.created`. Không phát socket.
 * @param actor Quản lý. Hàm không kiểm role.
 * @param name Tên đã trim, 1–50 ký tự, do route validate.
 * @returns Bản ghi vừa tạo.
 */
export async function createRoomType(actor: User, name: string) {
  try {
    return await withTransaction(async (tx) => {
      const type = await tx.roomType.create({ data: { name } });
      await writeAudit(tx, {
        actorId: actor.id,
        actorRole: actor.role,
        action: 'room_type.created',
        entityType: 'ROOM_TYPE',
        entityId: type.id,
        entityLabel: type.name,
        changes: [{ field: 'name', after: type.name }],
      });
      return type;
    });
  } catch (error) {
    if (isUniqueViolation(error)) throw nameTaken(name);
    throw error;
  }
}

/**
 * Đổi tên hoặc bật/tắt loại phòng.
 *
 * Không có thì 404. Tắt loại không sửa các phòng đang dùng nó; tạo/sửa phòng
 * sau đó sẽ bị `ROOM_TYPE_INACTIVE` nếu chọn loại đã tắt. Bảng không có `updatedAt`
 * hay `version`. Patch rỗng vẫn gọi `update` nhưng `diffFields` ra mảng rỗng. Không 409 khi hai người ghi cùng lúc.
 * @param patch `name` và/hoặc `isActive`. Nhật ký chỉ gồm trường thực sự đổi.
 * @returns Bản ghi sau ghi. Nhãn nhật ký là tên cũ.
 */
export async function updateRoomType(actor: User, id: string, patch: { name?: string; isActive?: boolean }) {
  try {
    return await withTransaction(async (tx) => {
      const before = await tx.roomType.findUnique({ where: { id } });
      if (!before) throw new NotFoundError('Loại phòng không tồn tại.');
      const after = await tx.roomType.update({ where: { id }, data: patch });
      await writeAudit(tx, {
        actorId: actor.id,
        actorRole: actor.role,
        action: 'room_type.updated',
        entityType: 'ROOM_TYPE',
        entityId: id,
        entityLabel: before.name,
        changes: diffFields(before, after, ['name', 'isActive']),
      });
      return after;
    });
  } catch (error) {
    if (isUniqueViolation(error) && patch.name) throw nameTaken(patch.name);
    throw error;
  }
}
