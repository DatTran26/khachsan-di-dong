import type { Prisma, Session, User } from '@prisma/client';
import { writeAudit } from '../../lib/audit.js';
import { UnauthorizedError } from '../../lib/errors.js';
import { MSG } from '../../lib/messages.js';
import { prisma } from '../../lib/prisma.js';
import { withTransaction } from '../../lib/transaction.js';
import { CHANNELS, type PendingEvent, type SessionRevokedReason } from '../../realtime/events.js';
import { generateSessionToken, hashSessionToken } from './credentials.js';

/** Phiên đăng nhập 12 giờ (BR-auth-roles-007). */
export const SESSION_TTL_MS = 12 * 60 * 60 * 1000;

export interface AuthContext {
  user: User;
  session: Session;
}

type Enqueue = (event: PendingEvent) => void;

const REVOKED_MESSAGES: Record<SessionRevokedReason, string> = {
  LOGGED_IN_ELSEWHERE: MSG.sessionRevoked,
  LOCKED: MSG.sessionRevoked,
  EXPIRED: MSG.sessionExpired,
  LOGGED_OUT: MSG.sessionExpired,
  PASSWORD_RESET: MSG.passwordResetByAdmin,
};

/** Sự kiện báo thiết bị đang giữ phiên này rằng phiên đã kết thúc (server ngắt kết nối ngay sau đó). */
export function sessionRevokedEvent(sessionId: string, reason: SessionRevokedReason): PendingEvent {
  return {
    channel: CHANNELS.session(sessionId),
    event: 'session:revoked',
    payload: { reason, message: REVOKED_MESSAGES[reason] },
  };
}

/**
 * Hủy phiên đang mở của một tài khoản (nếu có) và báo cho thiết bị đang giữ phiên đó.
 * Trả về phiên đã hủy (null nếu không có).
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
 * Mở phiên mới cho tài khoản. Tài khoản đang có phiên ở thiết bị khác → hủy phiên cũ
 * (1 TK 1 thiết bị — FR-auth-roles-012) và ghi nhật ký hành động của hệ thống.
 * Trả về token gốc — chỉ đưa cho client MỘT lần, CSDL chỉ giữ SHA-256.
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
 * Hết 12 giờ → hủy phiên, ghi nhật ký "hết phiên" (FR-auth-roles-003, hành động của hệ thống).
 * An toàn khi gọi nhiều lần (request và bộ hẹn giờ của socket cùng phát hiện): chỉ lần xóa được mới ghi.
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

/** Xác thực token → tài khoản + phiên. Dùng chung cho REST và Socket.IO. */
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
