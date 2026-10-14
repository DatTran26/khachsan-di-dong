import type { Prisma, Session, User } from '@prisma/client';
import { writeAudit } from '../../lib/audit.js';
import { UnauthorizedError } from '../../lib/errors.js';
import { MSG } from '../../lib/messages.js';
import { prisma } from '../../lib/prisma.js';
import { withTransaction } from '../../lib/transaction.js';
import { CHANNELS, type PendingEvent, type SessionRevokedReason } from '../../realtime/events.js';
import { generateSessionToken, hashSessionToken } from './credentials.js';

/** Thời sống của một phiên: 12 giờ kể từ lúc mở (BR-auth-roles-007). Không gia hạn khi có request. */
export const SESSION_TTL_MS = 12 * 60 * 60 * 1000;

/**
 * Người gọi đã xác thực: bản ghi `User` đầy đủ và phiên tương ứng (không kèm quan hệ `user`).
 * Route lấy qua `authOf` sau `requireAuth`. Không chứa token gốc.
 */
export interface AuthContext {
  user: User;
  session: Session;
}

/** Hàng đợi sự kiện realtime trong một transaction — chỉ phát sau khi commit (`withTransaction`). */
type Enqueue = (event: PendingEvent) => void;

const REVOKED_MESSAGES: Record<SessionRevokedReason, string> = {
  LOGGED_IN_ELSEWHERE: MSG.sessionRevoked,
  LOCKED: MSG.sessionRevoked,
  EXPIRED: MSG.sessionExpired,
  LOGGED_OUT: MSG.sessionExpired,
  PASSWORD_RESET: MSG.passwordResetByAdmin,
};

/**
 * Dựng sự kiện `session:revoked` cho đúng kênh của một phiên.
 *
 * `publish` ngắt socket của kênh đó ngay sau khi phát. Câu `message` lấy từ
 * `REVOKED_MESSAGES` theo lý do, để client hiện đúng lời (đăng nhập nơi khác, hết hạn, đặt lại MK).
 * @param sessionId Id phiên bị kết thúc — trở thành kênh `session:<id>`.
 * @param reason Lý do hủy. Không ghi vào nhật ký ở hàm này.
 * @returns Sự kiện chờ `enqueue`. Chưa phát ra socket.
 */
export function sessionRevokedEvent(sessionId: string, reason: SessionRevokedReason): PendingEvent {
  return {
    channel: CHANNELS.session(sessionId),
    event: 'session:revoked',
    payload: { reason, message: REVOKED_MESSAGES[reason] },
  };
}

/**
 * Hủy phiên đang mở của một tài khoản (nếu có) và báo cho thiết bị đang giữ phiên đó.
 *
 * Xóa dòng `Session` trong transaction của người gọi. Một tài khoản tối đa một phiên
 * (`userId` unique). Không ghi nhật ký — chỗ gọi tự ghi khi cần (đăng nhập nơi khác, khóa, đặt lại MK).
 * @param tx Client transaction. Không được gọi bằng `prisma` thường nếu còn việc khác phải cùng commit.
 * @param userId Tài khoản cần rút phiên.
 * @param reason Đưa vào payload `session:revoked`.
 * @param enqueue Hàng đợi của `withTransaction`. Sự kiện chỉ đi ra sau commit.
 * @returns Phiên vừa xóa, hoặc `null` nếu tài khoản không có phiên.
 */
export async function revokeUserSession(
  tx: Prisma.TransactionClient,
  userId: string,
  reason: SessionRevokedReason,
  enqueue: Enqueue,
): Promise<Session | null> {
  const existing = await tx.session.findUnique({ where: { userId } });
  if (!existing) return null;
  await tx.session.delete({ where: { id: existing.id } });
  enqueue(sessionRevokedEvent(existing.id, reason));
  return existing;
}

/**
 * Mở phiên mới cho tài khoản.
 *
 * Nếu đang có phiên ở thiết bị khác thì hủy phiên đó (1 tài khoản 1 thiết bị —
 * FR-auth-roles-012) và ghi nhật ký `auth.session_replaced` với người thực hiện là hệ thống.
 * Token gốc chỉ trả cho client một lần; CSDL giữ SHA-256. `deviceInfo` cắt còn 200 ký tự.
 * @param tx Transaction của lần đăng nhập (cùng lúc reset đếm sai MK và ghi `auth.login`).
 * @param user Tài khoản vừa xác thực mật khẩu. Không kiểm tra khóa/trạng thái ở đây.
 * @param deviceInfo Chuỗi thiết bị client gửi hoặc User-Agent. Có thể bỏ qua.
 * @param enqueue Để báo thiết bị cũ rằng phiên đã bị thay.
 * @returns `token` gốc và dòng `session` vừa tạo (kèm `expiresAt` = now + 12 giờ).
 */
export async function openSession(
  tx: Prisma.TransactionClient,
  user: User,
  deviceInfo: string | undefined,
  enqueue: Enqueue,
) {
  const replaced = await revokeUserSession(tx, user.id, 'LOGGED_IN_ELSEWHERE', enqueue);
  if (replaced) {
    await writeAudit(tx, {
      actorId: null,
      actorRole: 'SYSTEM',
      action: 'auth.session_replaced',
      entityType: 'USER',
      entityId: user.id,
      entityLabel: user.fullName,
    });
  }

  const token = generateSessionToken();
  const session = await tx.session.create({
    data: {
      userId: user.id,
      tokenHash: hashSessionToken(token),
      deviceInfo: deviceInfo?.slice(0, 200),
      expiresAt: new Date(Date.now() + SESSION_TTL_MS),
    },
  });
  return { token, session };
}

/**
 * Hết 12 giờ → hủy phiên và ghi nhật ký "hết phiên" (FR-auth-roles-003, người thực hiện là hệ thống).
 *
 * An toàn khi gọi nhiều lần (request REST và timer của socket cùng phát hiện):
 * `deleteMany` đếm 0 thì không ghi nhật ký và không phát sự kiện lần nữa.
 * @param session Phiên đã hết hạn, phải kèm `user` để ghi `entityLabel`.
 * @returns Promise hoàn tất sau commit. Không trả token hay DTO.
 */
export async function expireSession(session: Session & { user: User }) {
  await withTransaction(async (tx, enqueue) => {
    const { count } = await tx.session.deleteMany({ where: { id: session.id } });
    if (count === 0) return;
    enqueue(sessionRevokedEvent(session.id, 'EXPIRED'));
    await writeAudit(tx, {
      actorId: null,
      actorRole: 'SYSTEM',
      action: 'auth.session_expired',
      entityType: 'USER',
      entityId: session.userId,
      entityLabel: session.user.fullName,
    });
  });
}

/**
 * Xác thực token thành tài khoản + phiên. Dùng chung cho REST và Socket.IO.
 *
 * Không thấy phiên → `SESSION_INVALID` (đã đăng xuất, bị hủy, hoặc đăng nhập nơi khác).
 * Quá `expiresAt` → gọi `expireSession` rồi ném `SESSION_EXPIRED`.
 * Tài khoản `LOCKED` mà phiên còn sót → `ACCOUNT_LOCKED` (khóa bình thường đã xóa phiên).
 * Không kiểm `mustChangePassword` — middleware REST và handshake socket tự chặn.
 * @param token Token gốc. `undefined` hoặc chuỗi rỗng được coi là chưa đăng nhập.
 * @returns `AuthContext`. Ném `UnauthorizedError` khi từ chối; không trả `null`.
 */
export async function authenticate(token: string | undefined): Promise<AuthContext> {
  if (!token) throw new UnauthorizedError('UNAUTHENTICATED', MSG.loginRequired);

  const session = await prisma.session.findUnique({
    where: { tokenHash: hashSessionToken(token) },
    include: { user: true },
  });
  // Không thấy phiên: đã đăng xuất / bị hủy / đăng nhập nơi khác → đăng nhập lại.
  if (!session) throw new UnauthorizedError('SESSION_INVALID', MSG.sessionExpired);

  if (session.expiresAt.getTime() <= Date.now()) {
    await expireSession(session);
    throw new UnauthorizedError('SESSION_EXPIRED', MSG.sessionExpired);
  }
  // Phòng hờ: khóa TK luôn xóa phiên, nhưng nếu còn sót thì vẫn không cho dùng.
  if (session.user.status === 'LOCKED') throw new UnauthorizedError('ACCOUNT_LOCKED', MSG.accountLocked);

  const { user, ...sessionOnly } = session;
  return { user, session: sessionOnly };
}
