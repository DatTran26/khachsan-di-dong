import { Prisma, type Role, type User } from '@prisma/client';
import { diffFields, writeAudit, type AuditChange } from '../../lib/audit.js';
import { AppError, ForbiddenError, NotFoundError } from '../../lib/errors.js';
import { MSG } from '../../lib/messages.js';
import { updateWithVersion } from '../../lib/optimistic-lock.js';
import { prisma } from '../../lib/prisma.js';
import { withTransaction } from '../../lib/transaction.js';
import { generateTempPassword, hashPassword } from '../auth/credentials.js';
import { revokeUserSession } from '../auth/sessions.js';
import { toUserDto } from './users.dto.js';

/**
 * Quản lý tài khoản (auth-roles, BR-auth-roles-001 — chốt nhóm 23/09/2026):
 * - Quản lý: toàn quyền trên mọi tài khoản.
 * - Lễ tân: chỉ trên tài khoản KHÔNG phải quản lý, và không được gán vai trò quản lý.
 * - Không ai được tự khóa mình; không khóa / đổi vai trò tài khoản quản lý cuối cùng (BR-auth-roles-006).
 * - Không có xóa tài khoản (BR-auth-roles-005).
 */
type Actor = User;

const phoneTaken = () => new AppError(409, 'PHONE_TAKEN', MSG.phoneTaken);

function assertCanManage(actor: Actor, target: Pick<User, 'role'> | null, newRole?: Role) {
  if (actor.role === 'MANAGER') return;
  if (actor.role !== 'RECEPTIONIST') throw new ForbiddenError();
  if (target?.role === 'MANAGER' || newRole === 'MANAGER') throw new ForbiddenError();
}

// Mọi thao tác quản lý tài khoản chạy tuần tự (khóa tư vấn trong transaction) → hai người cùng khóa
// hai quản lý cuối cùng một lúc cũng không làm hệ thống mất hết quản lý.
const ACCOUNT_ADMIN_LOCK = 724001;
async function serializeAccountAdmin(tx: Prisma.TransactionClient) {
  await tx.$queryRaw`SELECT 1 FROM pg_advisory_xact_lock(${ACCOUNT_ADMIN_LOCK}::bigint)`;
}

async function assertNotLastActiveManager(tx: Prisma.TransactionClient, target: User, message: string) {
  if (target.role !== 'MANAGER' || target.status !== 'ACTIVE') return;
  const others = await tx.user.count({ where: { role: 'MANAGER', status: 'ACTIVE', id: { not: target.id } } });
  if (others === 0) throw new AppError(409, 'LAST_MANAGER', message);
}

async function loadTarget(tx: Prisma.TransactionClient, id: string) {
  const target = await tx.user.findUnique({ where: { id } });
  if (!target) throw new NotFoundError('Tài khoản không tồn tại.');
  return target;
}

function isUniqueViolation(error: unknown) {
  return error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2002';
}

function audit(tx: Prisma.TransactionClient, actor: Actor, action: string, target: User, changes: AuditChange[] = []) {
  return writeAudit(tx, {
    actorId: actor.id,
    actorRole: actor.role,
    action,
    entityType: 'USER',
    entityId: target.id,
    entityLabel: target.fullName,
    changes,
  });
}

export async function listUsers() {
  const users = await prisma.user.findMany({ orderBy: [{ role: 'asc' }, { fullName: 'asc' }] });
  return users.map(toUserDto);
}

/** Tạo TK: sinh MK tạm, trạng thái "Chờ kích hoạt", trả MK tạm MỘT lần (FR-auth-roles-005). */
export async function createUser(actor: Actor, input: { fullName: string; phone: string; role: Role }) {
  assertCanManage(actor, null, input.role);
  const tempPassword = generateTempPassword();
  const passwordHash = await hashPassword(tempPassword);

  try {
    return await withTransaction(async (tx) => {
      await serializeAccountAdmin(tx);
      if (await tx.user.findUnique({ where: { phone: input.phone } })) throw phoneTaken();

      const user = await tx.user.create({
        data: { ...input, passwordHash, status: 'PENDING_ACTIVATION', mustChangePassword: true },
      });
      await audit(tx, actor, 'user.created', user, [
        { field: 'fullName', after: user.fullName },
        { field: 'phone', after: user.phone },
        { field: 'role', after: user.role },
        { field: 'status', after: user.status },
      ]);
      return { user: toUserDto(user), tempPassword, message: MSG.accountCreated(user.fullName, tempPassword) };
    });
  } catch (error) {
    if (isUniqueViolation(error)) throw phoneTaken(); // hai người tạo trùng SĐT cùng lúc (edge case 6.4)
    throw error;
  }
}

/** Sửa họ tên / SĐT / vai trò / đang trực — kèm version (chống ghi đè). */
export async function updateUser(
  actor: Actor,
  id: string,
  version: number,
  patch: { fullName?: string; phone?: string; role?: Role; onDuty?: boolean },
) {
  try {
    return await withTransaction(async (tx) => {
      await serializeAccountAdmin(tx);
      const target = await loadTarget(tx, id);
      assertCanManage(actor, target, patch.role);
      if (patch.role && patch.role !== target.role) {
        await assertNotLastActiveManager(tx, target, MSG.lastManagerRole);
      }
      if (patch.phone && patch.phone !== target.phone && (await tx.user.findUnique({ where: { phone: patch.phone } }))) {
        throw phoneTaken();
      }

      const updated = await updateWithVersion(tx, 'user', id, version, patch);
      await audit(tx, actor, 'user.updated', target, diffFields(target, updated, ['fullName', 'phone', 'role', 'onDuty']));
      return { user: toUserDto(updated), message: MSG.accountUpdated };
    });
  } catch (error) {
    if (isUniqueViolation(error)) throw phoneTaken();
    throw error;
  }
}

/** Khóa TK → hủy ngay phiên đang mở (FR-auth-roles-009, SC-auth-roles-05). */
export async function lockUser(actor: Actor, id: string, version: number) {
  return withTransaction(async (tx, enqueue) => {
    await serializeAccountAdmin(tx);
    const target = await loadTarget(tx, id);
    assertCanManage(actor, target);
    if (target.id === actor.id) throw new AppError(409, 'CANNOT_LOCK_SELF', MSG.cannotLockSelf);
    await assertNotLastActiveManager(tx, target, MSG.lastManagerLock);

    const updated = await updateWithVersion(tx, 'user', id, version, { status: 'LOCKED' });
    await revokeUserSession(tx, id, 'LOCKED', enqueue);
    await audit(tx, actor, 'user.locked', target, diffFields(target, updated, ['status']));
    return { user: toUserDto(updated), message: MSG.accountLockedDone(updated.fullName) };
  });
}

/** Mở khóa → MK tạm mới, "Chờ kích hoạt", đếm sai về 0 (FR-auth-roles-010). */
export async function unlockUser(actor: Actor, id: string, version: number) {
  const tempPassword = generateTempPassword();
  const passwordHash = await hashPassword(tempPassword);

  return withTransaction(async (tx) => {
    await serializeAccountAdmin(tx);
    const target = await loadTarget(tx, id);
    assertCanManage(actor, target);
    if (target.status !== 'LOCKED') throw new AppError(409, 'NOT_LOCKED', MSG.notLocked);

    const updated = await updateWithVersion(tx, 'user', id, version, {
      status: 'PENDING_ACTIVATION',
      mustChangePassword: true,
      failedLoginCount: 0,
      passwordHash,
    });
    await audit(tx, actor, 'user.unlocked', target, diffFields(target, updated, ['status']));
    return { user: toUserDto(updated), tempPassword, message: MSG.accountUnlocked(tempPassword) };
  });
}

/**
 * Đặt lại MK → MK tạm mới, "Chờ kích hoạt" (FR-auth-roles-008).
 * Hủy phiên đang mở: người dùng không biết MK tạm nên phải đăng nhập lại bằng MK tạm rồi đổi MK.
 */
export async function resetPassword(actor: Actor, id: string, version: number) {
  const tempPassword = generateTempPassword();
  const passwordHash = await hashPassword(tempPassword);

  return withTransaction(async (tx, enqueue) => {
    await serializeAccountAdmin(tx);
    const target = await loadTarget(tx, id);
    assertCanManage(actor, target);
    if (target.status === 'LOCKED') throw new AppError(409, 'ACCOUNT_LOCKED', MSG.resetLockedAccount);

    const updated = await updateWithVersion(tx, 'user', id, version, {
      status: 'PENDING_ACTIVATION',
      mustChangePassword: true,
      failedLoginCount: 0,
      passwordHash,
    });
    if (target.id !== actor.id) await revokeUserSession(tx, id, 'PASSWORD_RESET', enqueue);
    await audit(tx, actor, 'user.password_reset', target, diffFields(target, updated, ['status']));
    return { user: toUserDto(updated), tempPassword, message: MSG.passwordReset(tempPassword) };
  });
}
