import type { NotificationKind, PendingEvent } from './events.js';

/** Thông báo đẩy tới một kênh (người, vai trò). Client hiện `message` dạng snackbar/thông báo. */
export function notification(
  channel: string,
  kind: NotificationKind,
  message: string,
  refs: { taskId?: string; roomId?: string } = {},
): PendingEvent {
  return { channel, event: 'notification', payload: { kind, message, ...refs } };
}
