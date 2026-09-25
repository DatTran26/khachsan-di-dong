import { Router } from 'express';
import { z } from 'zod';
import { authOf, requireAuth, requireRole } from '../auth/auth.middleware.js';
import { createRoomType, listRoomTypes, updateRoomType } from './room-types.service.js';

export const roomTypesRouter = Router();
roomTypesRouter.use(requireAuth());

const nameSchema = z.string().trim().min(1, 'Vui lòng nhập tên loại phòng.').max(50);
const idParams = z.object({ id: z.string().uuid() });

// Mọi vai trò xem được (dùng cho bộ lọc theo loại phòng).
roomTypesRouter.get('/', async (_req, res) => {
  res.json({ data: await listRoomTypes() });
});

roomTypesRouter.post('/', requireRole('MANAGER'), async (req, res) => {
  const { name } = z.object({ name: nameSchema }).parse(req.body);
  res.status(201).json({ data: await createRoomType(authOf(res).user, name) });
});

roomTypesRouter.patch('/:id', requireRole('MANAGER'), async (req, res) => {
  const { id } = idParams.parse(req.params);
  const patch = z.object({ name: nameSchema.optional(), isActive: z.boolean().optional() }).parse(req.body);
  res.json({ data: await updateRoomType(authOf(res).user, id, patch) });
});
