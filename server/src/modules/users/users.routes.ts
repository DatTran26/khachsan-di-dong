import { Role } from '@prisma/client';
import { Router } from 'express';
import { z } from 'zod';
import { authOf, requireAuth, requireRole } from '../auth/auth.middleware.js';
import { phoneSchema } from '../auth/credentials.js';
import { createUser, listUsers, lockUser, resetPassword, unlockUser, updateUser } from './users.service.js';

/** Quản lý tài khoản — quản lý + lễ tân (lễ tân bị giới hạn trong users.service.ts). */
export const usersRouter = Router();
usersRouter.use(requireAuth(), requireRole('MANAGER', 'RECEPTIONIST'));

const fullNameSchema = z.string().trim().min(1, 'Vui lòng nhập họ tên.').max(100);
const idParams = z.object({ id: z.string().uuid() });
// Mọi thao tác ghi gửi kèm version đã đọc (FR-realtime-sync-003).
const versionBody = z.object({ version: z.number().int().positive() });

const createSchema = z.object({ fullName: fullNameSchema, phone: phoneSchema, role: z.nativeEnum(Role) });
const updateSchema = versionBody.extend({
  fullName: fullNameSchema.optional(),
  phone: phoneSchema.optional(),
  role: z.nativeEnum(Role).optional(),
  onDuty: z.boolean().optional(),
});

/** GET `/` — danh sách mọi tài khoản. Quản lý và lễ tân. */
usersRouter.get('/', async (_req, res) => {
  res.json({ data: await listUsers() });
});

/** POST `/` — tạo tài khoản. 201. Response có mật khẩu tạm một lần. */
usersRouter.post('/', async (req, res) => {
  const result = await createUser(authOf(res).user, createSchema.parse(req.body));
  res.status(201).json({ data: result });
});

/** PATCH `/:id` — sửa hồ sơ. Body có `version` và các trường tùy chọn. */
usersRouter.patch('/:id', async (req, res) => {
  const { id } = idParams.parse(req.params);
  const { version, ...patch } = updateSchema.parse(req.body);
  res.json({ data: await updateUser(authOf(res).user, id, version, patch) });
});

/** POST `/:id/lock` — khóa. Body `{ version }`. */
usersRouter.post('/:id/lock', async (req, res) => {
  const { id } = idParams.parse(req.params);
  res.json({ data: await lockUser(authOf(res).user, id, versionBody.parse(req.body).version) });
});

/** POST `/:id/unlock` — mở khóa, response có mật khẩu tạm mới. */
usersRouter.post('/:id/unlock', async (req, res) => {
  const { id } = idParams.parse(req.params);
  res.json({ data: await unlockUser(authOf(res).user, id, versionBody.parse(req.body).version) });
});

/** POST `/:id/reset-password` — cấp mật khẩu tạm. Body `{ version }`. */
usersRouter.post('/:id/reset-password', async (req, res) => {
  const { id } = idParams.parse(req.params);
  res.json({ data: await resetPassword(authOf(res).user, id, versionBody.parse(req.body).version) });
});
