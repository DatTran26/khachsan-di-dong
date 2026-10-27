import type { Role } from '@prisma/client';
import type { RequestHandler, Response } from 'express';
import { ForbiddenError } from '../../lib/errors.js';
import { MSG } from '../../lib/messages.js';
import { authenticate, type AuthContext } from './sessions.js';

/**
 * Lấy token khỏi header `Authorization`.
 *
 * Chấp nhận tiền tố `Bearer` không phân biệt hoa thường. Không có header,
 * sai định dạng, hoặc không có phần token → `undefined` (chỗ gọi sẽ ném 401).
 * Không kiểm tra token còn hạn; việc đó thuộc `authenticate`.
 * @param header Giá trị thô của `Authorization`, có thể không gửi.
 * @returns Token gốc (chưa băm) hoặc `undefined`.
 */
export function bearerToken(header: string | undefined): string | undefined {
  const match = header?.match(/^Bearer (.+)$/i);
  return match?.[1];
}

/**
 * Middleware bắt buộc đăng nhập.
 *
 * Mỗi request đọc lại phiên trong CSDL, nên khóa tài khoản hoặc đăng nhập nơi khác
 * có hiệu lực ngay, không chờ hết cache. Đang giữ mật khẩu tạm thì chặn mọi chức năng
 * trừ các route đặt `allowTempPassword` (đổi MK, xem bản thân — FR-auth-roles-006).
 * Đăng xuất không đi qua middleware này (luôn 204, kể cả phiên đã chết).
 * Gán `res.locals.auth` khi thành công.
 * @param options `allowTempPassword: true` để tài khoản `mustChangePassword` đi tiếp.
 * @returns Express handler. Ném `UnauthorizedError` hoặc `ForbiddenError` cho error handler.
 */
export function requireAuth(options: { allowTempPassword?: boolean } = {}): RequestHandler {
  return async (req, res, next) => {
    const auth = await authenticate(bearerToken(req.headers.authorization));
    if (auth.user.mustChangePassword && !options.allowTempPassword) {
      throw new ForbiddenError('PASSWORD_CHANGE_REQUIRED', MSG.mustChangePassword);
    }
    res.locals.auth = auth;
    next();
  };
}

/**
 * Chỉ cho các vai trò liệt kê. Kiểm tra trên máy chủ (NFR-auth-roles-003).
 *
 * Phải gắn sau `requireAuth` — hàm đọc `res.locals.auth`. Vai trò không nằm trong
 * danh sách → 403 `FORBIDDEN`, không tiết lộ thêm dữ liệu.
 * @param roles Các `Role` được đi tiếp. Không truyền role nào thì mọi request đã đăng nhập đều bị 403.
 * @returns Express handler đồng bộ.
 */
export function requireRole(...roles: Role[]): RequestHandler {
  return (_req, res, next) => {
    if (!roles.includes(authOf(res).user.role)) throw new ForbiddenError();
    next();
  };
}

/**
 * Lấy tài khoản và phiên đã xác thực của request hiện tại.
 *
 * Chỉ gọi sau `requireAuth`. Không kiểm tra lại token. Ép kiểu `res.locals.auth`
 * — nếu middleware chưa chạy thì giá trị là `undefined` và chỗ dùng sẽ vỡ khi đọc `user`.
 * @param res Response Express của request đang xử lý.
 * @returns `AuthContext` middleware đã gán.
 */
export function authOf(res: Response): AuthContext {
  return res.locals.auth as AuthContext;
}
