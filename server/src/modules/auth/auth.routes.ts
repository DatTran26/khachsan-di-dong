import { Router } from 'express';
import { z } from 'zod';
import { toUserDto } from '../users/users.dto.js';
import { authOf, requireAuth } from './auth.middleware.js';
import { changePassword, login, logout } from './auth.service.js';
import { newPasswordSchema, phoneSchema } from './credentials.js';

export const authRouter = Router();

const loginSchema = z.object({
  phone: phoneSchema,
  password: z.string().min(1),
  deviceInfo: z.string().max(200).optional(), // vd "web" / "android" — hiển thị ở nhật ký phiên
});

const changePasswordSchema = z.object({
  currentPassword: z.string().min(1),
  newPassword: newPasswordSchema,
});

authRouter.post('/login', async (req, res) => {
  const { phone, password, deviceInfo } = loginSchema.parse(req.body);
  res.json({ data: await login(phone, password, deviceInfo ?? req.headers['user-agent']) });
});

// 3 route dưới vẫn dùng được khi đang giữ MK tạm (để đổi MK hoặc thoát).
authRouter.post('/logout', requireAuth({ allowTempPassword: true }), async (_req, res) => {
  await logout(authOf(res));
  res.status(204).end();
});

authRouter.get('/me', requireAuth({ allowTempPassword: true }), (_req, res) => {
  const { user, session } = authOf(res);
  res.json({ data: { user: toUserDto(user), expiresAt: session.expiresAt } });
});

authRouter.post('/change-password', requireAuth({ allowTempPassword: true }), async (req, res) => {
  const { currentPassword, newPassword } = changePasswordSchema.parse(req.body);
  res.json({ data: await changePassword(authOf(res), currentPassword, newPassword) });
});
