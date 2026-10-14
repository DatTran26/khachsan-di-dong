import type { Server as HttpServer } from 'node:http';
import { Server } from 'socket.io';
import { corsOptions } from '../config/cors.js';
import { AppError } from '../lib/errors.js';
import { MSG } from '../lib/messages.js';
import { authenticate, expireSession, type AuthContext } from '../modules/auth/sessions.js';
import { CHANNELS, type ClientToServerEvents, type PendingEvent, type ServerToClientEvents } from './events.js';

/** Dữ liệu gắn trên mỗi socket sau handshake: người dùng và phiên đã xác thực. */
interface SocketData {
  auth: AuthContext;
}

/**
 * Server Socket.IO của tiến trình. Generic: không có sự kiện client→server,
 * payload server→client theo `ServerToClientEvents`, `socket.data` là `SocketData`.
 */
export type RealtimeServer = Server<ClientToServerEvents, ServerToClientEvents, Record<string, never>, SocketData>;

let io: RealtimeServer | null = null;

/**
 * Gắn Socket.IO vào cùng HTTP server với REST API.
 * - Bắt tay phải kèm token phiên: `io(url, { auth: { token } })`. Sai/hết hạn → từ chối kết nối,
 *   client nhận `connect_error` với `err.data.code` (vd SESSION_EXPIRED → về màn đăng nhập, FR-realtime-sync-010).
 * - Nhịp ping 5s + chờ 5s → phát hiện mất kết nối trong khoảng ≤10s (ngưỡng chính thức: realtime-sync OQ-1).
 *
 * Ghi đè biến module `io` để `publish` dùng. Gọi lần hai sẽ thay server cũ mà không đóng server trước.
 * @param httpServer Server HTTP đã tạo từ `createApp`, chưa cần listen.
 * @returns Instance Socket.IO vừa gắn. Middleware từ chối token sai bằng `connect_error`.
 */
export function attachRealtime(httpServer: HttpServer): RealtimeServer {
  io = new Server<ClientToServerEvents, ServerToClientEvents, Record<string, never>, SocketData>(httpServer, {
    cors: corsOptions(process.env.CORS_ORIGINS),
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

/**
 * Phát các sự kiện đã gom. Chỉ gọi sau khi transaction đã COMMIT (`withTransaction`).
 *
 * Gắn `emittedAt` tại thời điểm phát. `session:revoked` còn ngắt mọi socket trong kênh đó.
 * Nếu `attachRealtime` chưa chạy (seed, script) thì bỏ qua, không ném lỗi.
 * @param events Danh sách đã enqueue. Payload chưa có `emittedAt`.
 * @returns Không trả gì. Socket lỗi được thư viện tự xử lý, không bubble về request REST.
 */
export function publish(events: readonly PendingEvent[]): void {
  if (!io) return; // chưa gắn realtime (vd khi chạy seed/script) → bỏ qua
  const emittedAt = new Date().toISOString(); // mốc SAU khi lưu thành công
  for (const { channel, event, payload } of events) {
    io.to(channel).emit(event, { ...payload, emittedAt } as never);
    // Phiên đã kết thúc → ngắt mọi kết nối của phiên đó ngay sau khi báo (SC-auth-roles-05: ≤3 giây).
    if (event === 'session:revoked') io.in(channel).disconnectSockets();
  }
}

/**
 * Đóng Socket.IO và xóa singleton `io`.
 *
 * `shutdown` gọi trước khi đóng HTTP server. Không có instance thì không làm gì.
 * @returns Promise hoàn tất khi `io.close()` xong.
 */
export async function closeRealtime(): Promise<void> {
  if (io) await io.close();
  io = null;
}
