import { Router } from 'express';
import { z } from 'zod';
import { authOf, requireAuth, requireRole } from '../auth/auth.middleware.js';
import { createRoomType, listRoomTypes, updateRoomType } from './room-types.service.js';

/** Router `/api/room-types`. Xem: mọi vai trò đã đăng nhập. Ghi: chỉ quản lý. */
export const roomTypesRouter = Router();
roomTypesRouter.use(requireAuth());

const nameSchema = z.string().trim().min(1, 'Vui lòng nhập tên loại phòng.').max(50);
const idParams = z.object({ id: z.string().uuid() });

/** GET `/` — mọi loại, kể cả đã tắt. Dùng cho bộ lọc danh mục phòng. */
roomTypesRouter.get('/', async (_req, res) => {
  res.json({ data: await listRoomTypes() });
});

/** POST `/` — thêm loại. Chỉ quản lý. 201. */
roomTypesRouter.post('/', requireRole('MANAGER'), async (req, res) => {
  const { name } = z.object({ name: nameSchema }).parse(req.body);
  res.status(201).json({ data: await createRoomType(authOf(res).user, name) });
});

/** PATCH `/:id` — đổi tên và/hoặc `isActive`. Chỉ quản lý. Không nhận version. */
roomTypesRouter.patch('/:id', requireRole('MANAGER'), async (req, res) => {
  const { id } = idParams.parse(req.params);
  const patch = z.object({ name: nameSchema.optional(), isActive: z.boolean().optional() }).parse(req.body);
  res.json({ data: await updateRoomType(authOf(res).user, id, patch) });
});
