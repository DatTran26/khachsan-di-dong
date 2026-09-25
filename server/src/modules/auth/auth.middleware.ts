import type { Role } from '@prisma/client';
import type { RequestHandler, Response } from 'express';
import { ForbiddenError } from '../../lib/errors.js';
import { MSG } from '../../lib/messages.js';
import { authenticate, type AuthContext } from './sessions.js';

export function bearerToken(header: string | undefined): string | undefined {
  const match = header?.match(/^Bearer (.+)$/i);
  return match?.[1];
}

/**
 * Bắt buộc đăng nhập. Kiểm phiên ở CSDL mỗi request → khóa TK / đăng nhập nơi khác có hiệu lực ngay.
 * Đang dùng MK tạm → chặn mọi chức năng trừ đổi MK / đăng xuất / xem bản thân (FR-auth-roles-006),
 * trừ khi route cho phép bằng `allowTempPassword`.
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

/** Chỉ cho các vai trò liệt kê — kiểm ở máy chủ (NFR-auth-roles-003). Dùng SAU requireAuth. */
export function requireRole(...roles: Role[]): RequestHandler {
  return (_req, res, next) => {
    if (!roles.includes(authOf(res).user.role)) throw new ForbiddenError();
    next();
  };
}

/** Lấy tài khoản + phiên đã xác thực của request hiện tại. */
export function authOf(res: Response): AuthContext {
  return res.locals.auth as AuthContext;
}
