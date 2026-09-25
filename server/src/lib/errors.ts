import { MSG } from './messages.js';

/** Lỗi nghiệp vụ có mã HTTP — error handler trả về dạng { error: { code, message, details } }. */
export class AppError extends Error {
  constructor(
    readonly status: number,
    readonly code: string,
    message: string,
    readonly details?: unknown,
  ) {
    super(message);
    this.name = new.target.name;
  }
}

export class NotFoundError extends AppError {
  constructor(message: string) {
    super(404, 'NOT_FOUND', message);
  }
}

/** 401 — chưa đăng nhập / phiên hết hạn / phiên đã bị hủy → client về màn đăng nhập. */
export class UnauthorizedError extends AppError {
  constructor(code = 'SESSION_EXPIRED', message: string = MSG.sessionExpired) {
    super(401, code, message);
  }
}

/** 403 — đã đăng nhập nhưng vai trò không được làm thao tác này (E-auth-roles-007). */
export class ForbiddenError extends AppError {
  constructor(code = 'FORBIDDEN', message: string = MSG.forbidden) {
    super(403, code, message);
  }
}

/**
 * Chống ghi đè: client gửi `version` đã đọc, nhưng bản ghi đã bị người khác sửa trước.
 * `details.current` là bản mới nhất — client hiển thị ngay thay vì ghi đè (E-realtime-sync-002).
 */
export class VersionConflictError extends AppError {
  constructor(label: string, id: string, expectedVersion: number, current: unknown) {
    super(409, 'VERSION_CONFLICT', MSG.versionConflict, { entity: label, id, expectedVersion, current });
  }
}
