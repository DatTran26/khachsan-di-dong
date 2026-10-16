import { HousekeepingPhotoCategory, HousekeepingTaskStatus } from '@prisma/client';
import express, { Router, type Request, type RequestHandler, type Response } from 'express';
import { z } from 'zod';
import { env } from '../../config/env.js';
import { AppError } from '../../lib/errors.js';
import { MSG } from '../../lib/messages.js';
import { PHOTO_MAX_BYTES } from '../../lib/photo-storage.js';
import { authOf, requireAuth, requireRole } from '../auth/auth.middleware.js';
import {
  acceptTask,
  completeTask,
  confirmTask,
  listTasks,
  reassignTask,
  rejectTask,
  returnTask,
} from './housekeeping.service.js';
import { deletePhoto, getPhotoFile, listPhotos, uploadPhoto } from './housekeeping.photos.js';

/**
 * Việc dọn phòng. Xem: quản lý + nhân viên (FR-010). Nhận / từ chối / báo xong: nhân viên được giao.
 * Xác nhận / trả lại / phân công lại: CHỈ quản lý (BR-housekeeping-001, NFR-004). Ghi luôn kèm `version` của việc.
 * Việc được tạo bởi hệ thống khi trả phòng — không có API tạo tay (spec housekeeping không có FR tạo tay).
 */
export const housekeepingRouter = Router();
housekeepingRouter.use(requireAuth());

const idParams = z.object({ id: z.string().uuid() });
const versionBody = z.object({ version: z.number().int().positive() });

/**
 * GET `/tasks` — quản lý và nhân viên. `mine=true` ép `assigneeId` thành người gọi,
 * ghi đè assigneeId trên query. Lễ tân bị 403. Không có `mine` thì nhân viên cũng thấy việc của người khác.
 */
housekeepingRouter.get('/tasks', requireRole('MANAGER', 'STAFF'), async (req, res) => {
  const query = z
    .object({
      status: z.nativeEnum(HousekeepingTaskStatus).optional(),
      assigneeId: z.string().uuid().optional(),
      roomId: z.string().uuid().optional(),
      mine: z.enum(['true', 'false']).transform((v) => v === 'true').optional(),
      overdue: z.enum(['true', 'false']).transform((v) => v === 'true').optional(),
    })
    .parse(req.query);
  const { mine, ...filter } = query;
  res.json({ data: await listTasks(mine ? { ...filter, assigneeId: authOf(res).user.id } : filter) });
});

/**
 * Bọc các POST chỉ cần `{ version }` trong body.
 * @param action Hàm service `(actor, taskId, version)`.
 * @returns Handler parse UUID và version rồi trả `{ data }`.
 */
const versionOnly = (action: typeof acceptTask) => async (req: Request, res: Response) => {
  const { id } = idParams.parse(req.params);
  res.json({ data: await action(authOf(res).user, id, versionBody.parse(req.body).version) });
};

housekeepingRouter.post('/tasks/:id/accept', requireRole('STAFF'), versionOnly(acceptTask));
housekeepingRouter.post('/tasks/:id/reject', requireRole('STAFF'), versionOnly(rejectTask));
/** POST `.../complete` — nhân viên phụ trách. `hasIssue` tùy chọn. */
housekeepingRouter.post('/tasks/:id/complete', requireRole('STAFF'), async (req, res) => {
  const { id } = idParams.parse(req.params);
  // hasIssue = nhân viên đánh dấu bất thường → bắt buộc có ảnh cận cảnh (BR-housekeeping-006).
  const { version, hasIssue } = versionBody.extend({ hasIssue: z.boolean().optional() }).parse(req.body);
  res.json({ data: await completeTask(authOf(res).user, id, version, hasIssue) });
});
housekeepingRouter.post('/tasks/:id/confirm', requireRole('MANAGER'), versionOnly(confirmTask));

/** POST `.../return` — chỉ quản lý. `note` trim, 1–500 ký tự. */
housekeepingRouter.post('/tasks/:id/return', requireRole('MANAGER'), async (req, res) => {
  const { id } = idParams.parse(req.params);
  const { version, note } = versionBody
    .extend({ note: z.string({ required_error: MSG.returnNoteRequired }).trim().min(1, MSG.returnNoteRequired).max(500) })
    .parse(req.body);
  res.json({ data: await returnTask(authOf(res).user, id, version, note) });
});

/** POST `.../reassign` — chỉ quản lý. Body gồm `version` và `assigneeId`. */
housekeepingRouter.post('/tasks/:id/reassign', requireRole('MANAGER'), async (req, res) => {
  const { id } = idParams.parse(req.params);
  const { version, assigneeId } = versionBody.extend({ assigneeId: z.string().uuid() }).parse(req.body);
  res.json({ data: await reassignTask(authOf(res).user, id, version, assigneeId) });
});

// ---- Ảnh nghiệm thu (FR-005, FR-007, NFR-006) ---------------------------------------

/**
 * Parser body byte ảnh. Vượt `PHOTO_MAX_BYTES` → `AppError` 413 câu tiếng Việt, không phải lỗi HTML của Express.
 * Content-Type chấp nhận `image/*` hoặc `application/octet-stream`.
 */
const rawImage: RequestHandler = (req, res, next) =>
  express.raw({ type: ['image/*', 'application/octet-stream'], limit: PHOTO_MAX_BYTES })(req, res, (err?: unknown) => {
    if ((err as { type?: string } | undefined)?.type === 'entity.too.large') {
      return next(new AppError(413, 'PHOTO_TOO_LARGE', MSG.photoTooLarge(env.PHOTO_MAX_MB)));
    }
    next(err);
  });

/** GET ảnh của một việc. Quyền xem chi tiết nằm trong `listPhotos` (quản lý hoặc đúng assignee). */
housekeepingRouter.get('/tasks/:id/photos', requireRole('MANAGER', 'STAFF'), async (req, res) => {
  const { id } = idParams.parse(req.params);
  res.json({ data: await listPhotos(authOf(res).user, id) });
});

/**
 * POST ảnh. Query `category` bắt buộc. Body không phải Buffer thì thành buffer rỗng
 * và service từ chối vì không nhận ra loại ảnh. 201 kèm DTO metadata, không trả byte.
 */
housekeepingRouter.post('/tasks/:id/photos', requireRole('STAFF'), rawImage, async (req, res) => {
  const { id } = idParams.parse(req.params);
  const { category } = z.object({ category: z.nativeEnum(HousekeepingPhotoCategory) }).parse(req.query);
  const data = Buffer.isBuffer(req.body) ? req.body : Buffer.alloc(0);
  res.status(201).json({ data: await uploadPhoto(authOf(res).user, id, category, data) });
});

/** DELETE một ảnh của lượt hiện tại. 204 khi xóa được cả dòng và tệp. */
housekeepingRouter.delete('/photos/:id', requireRole('STAFF'), async (req, res) => {
  const { id } = idParams.parse(req.params);
  await deletePhoto(authOf(res).user, id);
  res.status(204).end();
});

/**
 * GET byte ảnh. Cache private 1 giờ, `nosniff`. Không có link công khai — vẫn cần Bearer.
 * Sai quyền → 403, không lộ mime.
 */
housekeepingRouter.get('/photos/:id/file', requireRole('MANAGER', 'STAFF'), async (req, res) => {
  const { id } = idParams.parse(req.params);
  const { data, mimeType } = await getPhotoFile(authOf(res).user, id);
  res.set({ 'Content-Type': mimeType, 'Cache-Control': 'private, max-age=3600', 'X-Content-Type-Options': 'nosniff' });
  res.send(data);
});
