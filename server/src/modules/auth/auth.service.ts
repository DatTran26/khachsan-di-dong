import type { User } from '@prisma/client';
import { writeAudit } from '../../lib/audit.js';
import { AppError, UnauthorizedError } from '../../lib/errors.js';
import { MSG } from '../../lib/messages.js';
import { prisma } from '../../lib/prisma.js';
import { withTransaction } from '../../lib/transaction.js';
import { toUserDto } from '../users/users.dto.js';
import { hashPassword, verifyAgainstDummy, verifyPassword } from './credentials.js';
import { openSession, revokeUserSession, sessionRevokedEvent, type AuthContext } from './sessions.js';

/**
 * Ngưỡng khóa tài khoản: 5 lần sai mật khẩu liên tiếp (BR-auth-roles-004).
 * Đăng nhập đúng hoặc mở khóa / đặt lại MK đưa bộ đếm về 0. Sai MK khi tài khoản
 * đã `LOCKED` không tăng đếm (tránh phân biệt thêm sau khi đã khóa).
 */
export const MAX_FAILED_LOGINS = 5;

/** 401 dùng chung cho SĐT không tồn tại và mật khẩu sai — cùng câu chữ, không lộ tài khoản. */
const invalidCredentials = () => new UnauthorizedError('INVALID_CREDENTIALS', MSG.invalidCredentials);

/**
 * 403 khi mật khẩu đúng nhưng tài khoản đã `LOCKED`.
 * Khác 401: client biết tài khoản tồn tại và đang bị khóa (E-auth-roles-002).
 */
const accountLocked = () => new AppError(403, 'ACCOUNT_LOCKED', MSG.accountLocked);

/**
 * Ghi một lần sai mật khẩu trên tài khoản đang tồn tại và chưa khóa.
 *
 * Tăng `failedLoginCount` trong transaction. Khi bộ đếm chạm `MAX_FAILED_LOGINS`:
 * chuyển `status` sang `LOCKED`, hủy phiên đang mở, ghi nhật ký `auth.auto_locked`
 * với người thực hiện là hệ thống. Không ghi mật khẩu đã thử.
 * @param user Bản ghi đọc trước khi tăng đếm. `status` trước khi khóa được đưa vào `changes`.
 * @returns `COUNTED` nếu chỉ tăng đếm; `LOCKED` nếu lần này vừa khóa tài khoản.
 */
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
 * Đăng nhập bằng SĐT + mật khẩu (FR-auth-roles-001).
 *
 * - Sai SĐT hoặc sai mật khẩu → cùng một câu lỗi (không lộ SĐT nào có tài khoản).
 *   SĐT không tồn tại vẫn chạy bcrypt trên hash giả để cân thời gian.
 * - Tài khoản `LOCKED` chỉ báo "bị khóa" khi mật khẩu đúng (E-auth-roles-002);
 *   mật khẩu sai thì báo như đăng nhập thường và không tăng đếm.
 * - "Chờ kích hoạt" (mật khẩu tạm) vẫn vào được, `mustChangePassword` giữ nguyên (FR-auth-roles-006).
 * - Đúng mật khẩu: xóa đếm sai nếu đang > 0, mở phiên mới (đá phiên thiết bị khác), ghi `auth.login`.
 * @param phone SĐT đã qua `phoneSchema`.
 * @param password Mật khẩu thô. Không ghi vào nhật ký.
 * @param deviceInfo Mô tả thiết bị, có thể bỏ qua. Cắt 200 ký tự khi lưu phiên.
 * @returns Token gốc (một lần), `expiresAt`, DTO người dùng (đếm sai đã về 0 trên DTO),
 *   và `message` nhắc đổi mật khẩu tạm khi còn cờ.
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

/**
 * Đăng xuất: xóa phiên hiện tại và ghi `auth.logout` (FR-auth-roles-002).
 *
 * Nếu phiên đã không còn (đếm xóa = 0) thì không ghi nhật ký và không phát sự kiện.
 * Khi xóa được, enqueue `session:revoked` lý do `LOGGED_OUT` để socket của chính
 * thiết bị này đóng. Route bọc hàm này và vẫn trả 204 khi không xác thực được.
 * @param auth Ngữ cảnh đã xác thực. Chỉ hủy đúng `session.id`, không hủy phiên khác.
 * @returns Promise rỗng sau commit.
 */
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
 * Đổi mật khẩu khi mật khẩu hiện tại đúng và mật khẩu mới đã qua `newPasswordSchema` (FR-auth-roles-007).
 *
 * Giữ nguyên phiên hiện tại — không phát `session:revoked`. Nếu tài khoản đang
 * `PENDING_ACTIVATION` thì chuyển `ACTIVE` và hạ `mustChangePassword` (FR-auth-roles-006).
 * Nhật ký `auth.password_changed` chỉ ghi đổi `status`, không ghi giá trị mật khẩu (FR-audit-log-004).
 * Sai mật khẩu hiện tại → 400 `WRONG_CURRENT_PASSWORD`, không tăng đếm khóa đăng nhập.
 * @param auth Chỉ dùng `user`. Phiên không bị đụng.
 * @param currentPassword Mật khẩu đang dùng (với tài khoản vừa được đặt lại, đây là mật khẩu tạm).
 * @param newPassword Mật khẩu mới chưa băm. Route đã kiểm độ mạnh trước khi gọi.
 * @returns DTO người dùng sau cập nhật và câu `MSG.passwordChanged`.
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
