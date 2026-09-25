import type { Server as HttpServer } from 'node:http';
import { Server } from 'socket.io';
import { AppError } from '../lib/errors.js';
import { MSG } from '../lib/messages.js';
import { authenticate, expireSession, type AuthContext } from '../modules/auth/sessions.js';
import { CHANNELS, type ClientToServerEvents, type PendingEvent, type ServerToClientEvents } from './events.js';

interface SocketData {
  auth: AuthContext;
}

export type RealtimeServer = Server<ClientToServerEvents, ServerToClientEvents, Record<string, never>, SocketData>;

let io: RealtimeServer | null = null;

/**
 * Gắn Socket.IO vào cùng HTTP server với REST API.
 * - Bắt tay phải kèm token phiên: `io(url, { auth: { token } })`. Sai/hết hạn → từ chối kết nối,
 *   client nhận `connect_error` với `err.data.code` (vd SESSION_EXPIRED → về màn đăng nhập, FR-realtime-sync-010).
 * - Nhịp ping 5s + chờ 5s → phát hiện mất kết nối trong khoảng ≤10s (ngưỡng chính thức: realtime-sync OQ-1).
 */
export function attachRealtime(httpServer: HttpServer): RealtimeServer {
  io = new Server<ClientToServerEvents, ServerToClientEvents, Record<string, never>, SocketData>(httpServer, {
    cors: { origin: true },
    pingInterval: 5_000,
    pingTimeout: 5_000,
  });

  io.use(async (socket, next) => {
    try {
      const auth = await authenticate(socket.handshake.auth?.token as string | undefined);
      if (auth.user.mustChangePassword) {
        throw new AppError(403, 'PASSWORD_CHANGE_REQUIRED', MSG.mustChangePassword);
      }
      socket.data.auth = auth;
      next();
    } catch (error) {
      const appError = error instanceof AppError ? error : new AppError(500, 'INTERNAL_ERROR', MSG.notCompleted);
      next(Object.assign(new Error(appError.message), { data: { code: appError.code } }));
    }
  });

  io.on('connection', (socket) => {
    const { user, session } = socket.data.auth;
    socket.join([CHANNELS.hotel, CHANNELS.role(user.role), CHANNELS.user(user.id), CHANNELS.session(session.id)]);

    // Hết 12 giờ trong lúc đang mở app → hủy phiên + báo thiết bị ngay, không đợi tới thao tác kế tiếp.
    const expiryTimer = setTimeout(
      () => void expireSession({ ...session, user }).catch((error) => console.error(error)),
      Math.max(0, session.expiresAt.getTime() - Date.now()),
    );
    socket.on('disconnect', () => clearTimeout(expiryTimer));
  });

  return io;
}

/** Phát các sự kiện đã gom. Chỉ gọi SAU khi transaction đã COMMIT (xem lib/transaction.ts). */
export function publish(events: readonly PendingEvent[]): void {
  if (!io) return; // chưa gắn realtime (vd khi chạy seed/script) → bỏ qua
  const emittedAt = new Date().toISOString(); // mốc SAU khi lưu thành công
  for (const { channel, event, payload } of events) {
    io.to(channel).emit(event, { ...payload, emittedAt } as never);
    // Phiên đã kết thúc → ngắt mọi kết nối của phiên đó ngay sau khi báo (SC-auth-roles-05: ≤3 giây).
    if (event === 'session:revoked') io.in(channel).disconnectSockets();
  }
}

export async function closeRealtime(): Promise<void> {
  if (io) await io.close();
  io = null;
}
