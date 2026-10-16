import { MSG } from './messages.js';

/**
 * Lỗi nghiệp vụ mang sẵn mã HTTP.
 *
 * `errorHandler` bắt đúng lớp này và trả `{ error: { code, message, details } }`
 * với status lấy từ `status`. Lỗi không phải `AppError` bị nuốt thành 500, nên
 * mọi từ chối có chủ đích (quyền, trạng thái, xung đột version) phải ném lớp con.
 * Ném lỗi không tự ghi nhật ký; nếu ném từ trong `withTransaction` thì transaction
 * rollback và sự kiện realtime của lần đó không được phát.
 */
export class AppError extends Error {
  /**
   * @param status Mã HTTP trả cho client (400, 401, 403, 404, 409, 413, …).
   * @param code Mã ổn định cho client phân nhánh (vd `ROOM_OCCUPIED`), không phải câu hiển thị.
   * @param message Câu tiếng Việt cho người dùng.
   * @param details Payload kèm theo. Có thể bỏ qua. Xung đột version nhét bản ghi hiện tại vào đây.
   */
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

/**
 * 404 — không tìm thấy bản ghi.
 *
 * `code` luôn là `NOT_FOUND`. Không dùng lớp này để giấu bản ghi mà người gọi
 * không được xem; trường hợp đó ném `ForbiddenError`.
 */
export class NotFoundError extends AppError {
  /**
   * @param message Câu mô tả đối tượng, vd "Phòng không tồn tại."
   */
  constructor(message: string) {
    super(404, 'NOT_FOUND', message);
  }
}

/**
 * 401 — chưa đăng nhập, phiên hết hạn, hoặc phiên đã bị hủy.
 *
 * Client (interceptor Dio và socket) coi các mã 401 này là phải về màn đăng nhập.
 */
export class UnauthorizedError extends AppError {
  /**
   * @param code Mặc định `SESSION_EXPIRED`. Đăng nhập sai dùng `INVALID_CREDENTIALS`;
   *   không có token dùng `UNAUTHENTICATED`; phiên không còn trong CSDL dùng `SESSION_INVALID`.
   * @param message Câu hiển thị. Mặc định là `MSG.sessionExpired`.
   */
  constructor(code = 'SESSION_EXPIRED', message: string = MSG.sessionExpired) {
    super(401, code, message);
  }
}

/**
 * 403 — đã đăng nhập nhưng không được làm thao tác này (E-auth-roles-007).
 *
 * Khác 401: client không xóa phiên, chỉ báo không có quyền (hoặc bắt đổi mật khẩu tạm).
 */
export class ForbiddenError extends AppError {
  /**
   * @param code Mặc định `FORBIDDEN`. Đổi mật khẩu bắt buộc dùng `PASSWORD_CHANGE_REQUIRED`.
   * @param message Câu hiển thị. Mặc định là `MSG.forbidden`.
   */
  constructor(code = 'FORBIDDEN', message: string = MSG.forbidden) {
    super(403, code, message);
  }
}

/**
 * 409 — chống ghi đè.
 *
 * Client gửi `version` đã đọc, nhưng bản ghi đã bị người khác sửa trước đó.
 * `details.current` là bản mới nhất để client vẽ lại, không ghi đè (E-realtime-sync-002).
 */
export class VersionConflictError extends AppError {
  /**
   * @param label Tên đối tượng tiếng Việt ("Phòng", "Việc dọn phòng", …).
   * @param id Khóa chính của bản ghi bị xung đột.
   * @param expectedVersion Version client gửi lên và đã không còn khớp.
   * @param current Bản ghi (thường là DTO) đang nằm trong CSDL sau lần ghi thắng.
   */
  constructor(label: string, id: string, expectedVersion: number, current: unknown) {
    super(409, 'VERSION_CONFLICT', MSG.versionConflict, { entity: label, id, expectedVersion, current });
  }
}
