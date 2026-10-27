import type { NotificationKind, PendingEvent } from './events.js';

/**
 * Dựng sự kiện `notification` chờ phát sau commit.
 *
 * Không gửi socket tại đây. Client hiện `message` dạng snackbar. `taskId` / `roomId`
 * để app mở đúng việc hoặc phòng; bỏ qua thì payload không có hai khóa đó
 * (spread object rỗng không thêm field).
 * @param channel Tên room Socket.IO, thường từ `CHANNELS.role` hoặc `CHANNELS.user`.
 * @param kind Mã ổn định để client phân loại, không phải câu hiển thị.
 * @param message Câu tiếng Việt đã dựng từ `MSG`.
 * @param refs Id việc và/hoặc phòng. Mặc định không gắn id.
 * @returns `PendingEvent` chưa có `emittedAt` (`publish` gắn lúc phát).
 */
export function notification(
  channel: string,
  kind: NotificationKind,
  message: string,
  refs: { taskId?: string; roomId?: string } = {},
): PendingEvent {
  return { channel, event: 'notification', payload: { kind, message, ...refs } };
}
