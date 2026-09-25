import type { User } from '@prisma/client';
import { writeAudit } from '../../lib/audit.js';
import { AppError, UnauthorizedError } from '../../lib/errors.js';
import { MSG } from '../../lib/messages.js';
import { prisma } from '../../lib/prisma.js';
import { withTransaction } from '../../lib/transaction.js';
import { toUserDto } from '../users/users.dto.js';
import { hashPassword, verifyAgainstDummy, verifyPassword } from './credentials.js';
import { openSession, revokeUserSession, sessionRevokedEvent, type AuthContext } from './sessions.js';

/** Sai MK 5 lần liên tiếp → khóa (BR-auth-roles-004). */
export const MAX_FAILED_LOGINS = 5;

const invalidCredentials = () => new UnauthorizedError('INVALID_CREDENTIALS', MSG.invalidCredentials);
const accountLocked = () => new AppError(403, 'ACCOUNT_LOCKED', MSG.accountLocked);

/** Sai MK: +1 đếm sai; đủ 5 → hệ thống khóa TK, hủy phiên, ghi nhật ký (FR-auth-roles-011, E-auth-roles-001). */
async function recordFailedLogin(user: User): Promise<'LOCKED' | 'COUNTED'> {
  return withTransaction(async (tx, enqueue) => {
    const updated = await tx.user.update({
      where: { id: user.id },
      data: { failedLoginCount: { increment: 1 } },
    });
    if (updated.failedLoginCount < MAX_FAILED_LOGINS) return 'COUNTED';

    await tx.user.update({ where: { id: user.id }, data: { status: 'LOCKED' } });
    await revokeUserSession(tx, user.id, 'LOCKED', enqueue);
    await writeAudit(tx, {
      actorId: null,
      actorRole: 'SYSTEM',
      action: 'auth.auto_locked',
      entityType: 'USER',
      entityId: user.id,
      entityLabel: user.fullName,
      changes: [{ field: 'status', before: user.status, after: 'LOCKED' }],
    });
    return 'LOCKED';
  });
}

/**
 * Đăng nhập bằng SĐT + MK (FR-auth-roles-001).
 * - Sai SĐT hoặc MK → cùng một câu báo lỗi (không lộ SĐT nào có tài khoản).
 * - TK bị khóa → chỉ báo "bị khóa" khi MK đúng (E-auth-roles-002).
 * - TK "Chờ kích hoạt" (MK tạm) → vẫn vào được nhưng `mustChangePassword` = true (FR-auth-roles-006).
 */
export async function login(phone: string, password: string, deviceInfo?: string) {
  const user = await prisma.user.findUnique({ where: { phone } });
  if (!user) {
    await verifyAgainstDummy(password);
    throw invalidCredentials();
  }

  const passwordOk = await verifyPassword(password, user.passwordHash);
  if (user.status === 'LOCKED') throw passwordOk ? accountLocked() : invalidCredentials();
  if (!passwordOk) {
    const result = await recordFailedLogin(user);
    throw result === 'LOCKED' ? accountLocked() : invalidCredentials();
  }

  const { token, session } = await withTransaction(async (tx, enqueue) => {
    if (user.failedLoginCount > 0) {
      await tx.user.update({ where: { id: user.id }, data: { failedLoginCount: 0 } });
    }
    const opened = await openSession(tx, user, deviceInfo, enqueue);
    await writeAudit(tx, {
      actorId: user.id,
      actorRole: user.role,
      action: 'auth.login',
      entityType: 'USER',
      entityId: user.id,
      entityLabel: user.fullName,
    });
    return opened;
  });

  return {
    token,
    expiresAt: session.expiresAt,
    user: toUserDto({ ...user, failedLoginCount: 0 }),
    message: user.mustChangePassword ? MSG.mustChangePassword : undefined,
  };
}

/** Đăng xuất: hủy phiên hiện tại (FR-auth-roles-002). */
export async function logout({ user, session }: AuthContext) {
  await withTransaction(async (tx, enqueue) => {
    const { count } = await tx.session.deleteMany({ where: { id: session.id } });
    if (count === 0) return;
    await writeAudit(tx, {
      actorId: user.id,
      actorRole: user.role,
      action: 'auth.logout',
      entityType: 'USER',
      entityId: user.id,
      entityLabel: user.fullName,
    });
    // Thiết bị này tự về màn đăng nhập; báo qua socket để đóng kết nối realtime của phiên.
    enqueue(sessionRevokedEvent(session.id, 'LOGGED_OUT'));
  });
}

/**
 * Đổi MK: đúng MK hiện tại + MK mới đạt quy tắc (FR-auth-roles-007) → giữ phiên hiện tại.
 * Đang dùng MK tạm → xong thì TK chuyển "Hoạt động" (FR-auth-roles-006).
 */
export async function changePassword({ user }: AuthContext, currentPassword: string, newPassword: string) {
  if (!(await verifyPassword(currentPassword, user.passwordHash))) {
    throw new AppError(400, 'WRONG_CURRENT_PASSWORD', MSG.wrongCurrentPassword);
  }
  const passwordHash = await hashPassword(newPassword);

  return withTransaction(async (tx) => {
    const updated = await tx.user.update({
      where: { id: user.id },
      data: {
        passwordHash,
        mustChangePassword: false,
        status: user.status === 'PENDING_ACTIVATION' ? 'ACTIVE' : user.status,
      },
    });
    await writeAudit(tx, {
      actorId: user.id,
      actorRole: user.role,
      action: 'auth.password_changed',
      entityType: 'USER',
      entityId: user.id,
      entityLabel: user.fullName,
      // Chỉ ghi trạng thái — KHÔNG bao giờ ghi giá trị mật khẩu (FR-audit-log-004).
      changes: user.status === updated.status ? [] : [{ field: 'status', before: user.status, after: updated.status }],
    });
    return { user: toUserDto(updated), message: MSG.passwordChanged };
  });
}
