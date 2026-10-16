import { Router } from 'express';
import { z } from 'zod';
import { toUserDto } from '../users/users.dto.js';
import { UnauthorizedError } from '../../lib/errors.js';
import { authOf, bearerToken, requireAuth } from './auth.middleware.js';
import { changePassword, login, logout } from './auth.service.js';
import { newPasswordSchema, phoneSchema } from './credentials.js';
import { authenticate } from './sessions.js';

/**
 * Router `/api/auth`. Login và logout không dùng `requireAuth`.
 * `/me` và `/change-password` cho phép mật khẩu tạm.
 */
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

/**
 * POST `/login`. Body: SĐT, mật khẩu, `deviceInfo` tùy chọn tối đa 200 ký tự.
 * Thiếu `deviceInfo` thì lấy header `user-agent` (service cắt 200 khi lưu).
 * Thành công `{ data: { token, expiresAt, user, message? } }`.
 */
authRouter.post('/login', async (req, res) => {
  const { phone, password, deviceInfo } = loginSchema.parse(req.body);
  res.json({ data: await login(phone, password, deviceInfo ?? req.headers['user-agent']) });
});

// Đăng xuất luôn trả 204 — kể cả khi phiên đã hết / đã bị hủy (đăng xuất lần 2 không có gì để làm).
// Không trả 401 ở đây: client hay gọi đăng xuất NGAY KHI nhận 401, trả 401 nữa sẽ thành vòng lặp.
/**
 * POST `/logout`. Luôn 204. Token hết hạn hoặc đã hủy thì nuốt `UnauthorizedError`
 * và không gọi `logout`. Lỗi khác vẫn ném. Không trả 401 để client khỏi lặp khi đang xử lý 401.
 */
authRouter.post('/logout', async (req, res) => {
  const auth = await authenticate(bearerToken(req.headers.authorization)).catch((error: unknown) => {
    if (error instanceof UnauthorizedError) return null;
    throw error;
  });
  if (auth) await logout(auth);
  res.status(204).end();
});

// 2 route dưới vẫn dùng được khi đang giữ MK tạm (để đổi MK).

/**
 * GET `/me`. Kể cả khi còn mật khẩu tạm. Trả user DTO và `expiresAt` của phiên,
 * không trả token mới.
 */
authRouter.get('/me', requireAuth({ allowTempPassword: true }), (_req, res) => {
  const { user, session } = authOf(res);
  res.json({ data: { user: toUserDto(user), expiresAt: session.expiresAt } });
});

/**
 * POST `/change-password`. Mật khẩu mới phải qua `newPasswordSchema` (8 ký tự, có chữ và số).
 * Phiên hiện tại được giữ. Sai mật khẩu hiện tại → 400 từ service.
 */
authRouter.post('/change-password', requireAuth({ allowTempPassword: true }), async (req, res) => {
  const { currentPassword, newPassword } = changePasswordSchema.parse(req.body);
  res.json({ data: await changePassword(authOf(res), currentPassword, newPassword) });
});
