import type { toRoomDto } from '../modules/rooms/rooms.service.js';

/**
 * Kênh (Socket.IO room) mà mỗi kết nối tham gia sau khi xác thực:
 * - hotel: mọi người — thay đổi trạng thái phòng
 * - role:<ROLE>: theo vai trò — vd cảnh báo quá hạn cho quản lý
 * - user:<id>: riêng từng người — việc vừa được giao
 * - session:<id>: riêng một phiên đăng nhập — để hủy phiên đó ngay (khóa TK, đăng nhập nơi khác...)
 */
export const CHANNELS = {
  hotel: 'hotel',
  role: (role: string) => `role:${role}`,
  user: (userId: string) => `user:${userId}`,
  session: (sessionId: string) => `session:${sessionId}`,
} as const;

type RoomDto = ReturnType<typeof toRoomDto>;

/** Lý do phiên bị hủy — client hiện thông báo tương ứng rồi về màn đăng nhập. */
export type SessionRevokedReason = 'LOGGED_IN_ELSEWHERE' | 'LOCKED' | 'EXPIRED' | 'LOGGED_OUT' | 'PASSWORD_RESET';

/**
 * Sự kiện server → client. Mỗi sự kiện mang `emittedAt` = lúc phát (ngay sau khi lưu thành công)
 * để đo độ trễ ≤3s (FR-realtime-sync-002/008). Sự kiện dữ liệu mang `version` để client bỏ qua bản cũ đến muộn.
 */
export interface ServerToClientEvents {
  'room:updated': (payload: { room: RoomDto; emittedAt: string }) => void;
  /** Phiên này đã kết thúc — server ngắt kết nối ngay sau sự kiện này (E-auth-roles-009/011, SC-auth-roles-05). */
  'session:revoked': (payload: { reason: SessionRevokedReason; message: string; emittedAt: string }) => void;
}

// Client hiện chưa gửi gì lên qua socket — mọi thao tác ghi đi qua REST API (có kiểm quyền + version).
export type ClientToServerEvents = Record<string, never>;

/** Một sự kiện chờ phát, kèm kênh nhận. Được gom lại trong transaction, chỉ phát sau khi COMMIT. */
export type PendingEvent = {
  [E in keyof ServerToClientEvents]: {
    channel: string;
    event: E;
    payload: Omit<Parameters<ServerToClientEvents[E]>[0], 'emittedAt'>; // emittedAt do publish() gắn
  };
}[keyof ServerToClientEvents];
