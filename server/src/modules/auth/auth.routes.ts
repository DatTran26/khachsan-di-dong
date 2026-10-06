import { Router } from 'express';
import { z } from 'zod';
import { toUserDto } from '../users/users.dto.js';
import { UnauthorizedError } from '../../lib/errors.js';
import { authOf, bearerToken, requireAuth } from './auth.middleware.js';
import { changePassword, login, logout } from './auth.service.js';
import { newPasswordSchema, phoneSchema } from './credentials.js';
import { authenticate } from './sessions.js';

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

// Đăng xuất luôn trả 204 — kể cả khi phiên đã hết / đã bị hủy (đăng xuất lần 2 không có gì để làm).
// Không trả 401 ở đây: client hay gọi đăng xuất NGAY KHI nhận 401, trả 401 nữa sẽ thành vòng lặp.
authRouter.post('/logout', async (req, res) => {
  const auth = await authenticate(bearerToken(req.headers.authorization)).catch((error: unknown) => {
    if (error instanceof UnauthorizedError) return null;
    throw error;
  });
  if (auth) await logout(auth);
  res.status(204).end();
});

// 2 route dưới vẫn dùng được khi đang giữ MK tạm (để đổi MK).

authRouter.get('/me', requireAuth({ allowTempPassword: true }), (_req, res) => {
  const { user, session } = authOf(res);
  res.json({ data: { user: toUserDto(user), expiresAt: session.expiresAt } });
});

authRouter.post('/change-password', requireAuth({ allowTempPassword: true }), async (req, res) => {
  const { currentPassword, newPassword } = changePasswordSchema.parse(req.body);
  res.json({ data: await changePassword(authOf(res), currentPassword, newPassword) });
});
