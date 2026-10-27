import { Prisma, type Role, type User } from '@prisma/client';
import { diffFields, writeAudit, type AuditChange } from '../../lib/audit.js';
import { AppError, ForbiddenError, NotFoundError } from '../../lib/errors.js';
import { MSG } from '../../lib/messages.js';
import { updateWithVersion } from '../../lib/optimistic-lock.js';
import { prisma } from '../../lib/prisma.js';
import { withTransaction } from '../../lib/transaction.js';
import { generateTempPassword, hashPassword } from '../auth/credentials.js';
import { revokeUserSession } from '../auth/sessions.js';
import { assignPendingTasks } from '../housekeeping/housekeeping.assignment.js';
import { toUserDto } from './users.dto.js';

/**
 * Quản lý tài khoản (auth-roles, BR-auth-roles-001 — chốt nhóm 23/09/2026):
 * - Quản lý: toàn quyền trên mọi tài khoản.
 * - Lễ tân: chỉ trên tài khoản KHÔNG phải quản lý, và không được gán vai trò quản lý.
 * - Không ai được tự khóa mình; không khóa / đổi vai trò tài khoản quản lý cuối cùng (BR-auth-roles-006).
 * - Không có xóa tài khoản (BR-auth-roles-005).
 */
type Actor = User;

/** 409 khi SĐT đụng unique, kể cả hai request tạo cùng lúc. */
const phoneTaken = () => new AppError(409, 'PHONE_TAKEN', MSG.phoneTaken);

/**
 * Quản lý đi tiếp. Lễ tân bị 403 nếu đích hoặc vai trò mới là MANAGER, hoặc người gọi không phải lễ tân.
 * `target` null khi tạo mới — chỉ xét `newRole`.
 */
function assertCanManage(actor: Actor, target: Pick<User, 'role'> | null, newRole?: Role) {
  if (actor.role === 'MANAGER') return;
  if (actor.role !== 'RECEPTIONIST') throw new ForbiddenError();
  if (target?.role === 'MANAGER' || newRole === 'MANAGER') throw new ForbiddenError();
}

// Mọi thao tác quản lý tài khoản chạy tuần tự (khóa tư vấn trong transaction) → hai người cùng khóa
// hai quản lý cuối cùng một lúc cũng không làm hệ thống mất hết quản lý.
const ACCOUNT_ADMIN_LOCK = 724001;

/**
 * Khóa tư vấn `724001` đến hết transaction để hai người không cùng hạ nốt quản lý cuối cùng.
 * @param tx Transaction thao tác tài khoản.
 */
async function serializeAccountAdmin(tx: Prisma.TransactionClient) {
  await tx.$queryRaw`SELECT 1 FROM pg_advisory_xact_lock(${ACCOUNT_ADMIN_LOCK}::bigint)`;
}

/**
 * Chặn khóa hoặc đổi vai trò nếu `target` là quản lý ACTIVE duy nhất.
 * Tài khoản quản lý đang khóa hoặc chờ kích hoạt không tính là "cuối cùng".
 * @param message Câu 409 `LAST_MANAGER` (khóa khác với đổi vai trò).
 */
async function assertNotLastActiveManager(tx: Prisma.TransactionClient, target: User, message: string) {
  if (target.role !== 'MANAGER' || target.status !== 'ACTIVE') return;
  const others = await tx.user.count({ where: { role: 'MANAGER', status: 'ACTIVE', id: { not: target.id } } });
  if (others === 0) throw new AppError(409, 'LAST_MANAGER', message);
}

/**
 * Đọc tài khoản trong transaction. Không có thì 404 "Tài khoản không tồn tại."
 * @param id UUID. Không lọc theo quyền — `assertCanManage` chạy sau.
 */
async function loadTarget(tx: Prisma.TransactionClient, id: string) {
  const target = await tx.user.findUnique({ where: { id } });
  if (!target) throw new NotFoundError('Tài khoản không tồn tại.');
  return target;
}

/** @returns `true` khi Prisma báo P2002. Lỗi khác trả `false`. */
function isUniqueViolation(error: unknown) {
  return error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2002';
}

/**
 * Ghi nhật ký thao tác tài khoản. Không đưa hash mật khẩu vào `changes`.
 * @returns Promise của `writeAudit`.
 */
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

/**
 * Mọi tài khoản, sắp theo role rồi họ tên.
 *
 * Không lọc theo người gọi: lễ tân cũng nhận tài khoản quản lý (DTO không có hash).
 * Route đã chặn nhân viên. Không phân trang.
 * @returns Mảng DTO.
 */
export async function listUsers() {
  const users = await prisma.user.findMany({ orderBy: [{ role: 'asc' }, { fullName: 'asc' }] });
  return users.map(toUserDto);
}

/**
 * Tạo tài khoản: sinh mật khẩu tạm, trạng thái "Chờ kích hoạt", trả mật khẩu một lần (FR-auth-roles-005).
 *
 * `onDuty` mặc định false theo schema. Trùng SĐT → 409. Nhật ký không chứa mật khẩu tạm;
 * mật khẩu chỉ nằm trong object trả về cho người tạo.
 * @param input Họ tên, SĐT, vai trò đã qua zod ở route.
 * @returns `{ user, tempPassword, message }`.
 */
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

/**
 * Sửa họ tên, SĐT, vai trò, hoặc đang trực — kèm version (chống ghi đè).
 *
 * Đổi vai trò của quản lý ACTIVE cuối cùng → 409. Bật `onDuty` của STAFF
 * (từ false sang true) gọi `assignPendingTasks` trong cùng transaction.
 * Patch rỗng vẫn đi qua `updateWithVersion` nên vẫn tăng version.
 * @returns `{ user, message }` không kèm mật khẩu.
 */
export async function updateUser(
  actor: Actor,
  id: string,
  version: number,
  patch: { fullName?: string; phone?: string; role?: Role; onDuty?: boolean },
) {
  try {
    return await withTransaction(async (tx, enqueue) => {
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
      // Có nhân viên vào trực → hệ thống giao ngay các việc dọn đang "chờ giao" (FR-housekeeping-003).
      if (updated.role === 'STAFF' && updated.onDuty && !target.onDuty) await assignPendingTasks(tx, enqueue);
      return { user: toUserDto(updated), message: MSG.accountUpdated };
    });
  } catch (error) {
    if (isUniqueViolation(error)) throw phoneTaken();
    throw error;
  }
}

/**
 * Khóa tài khoản và hủy phiên đang mở (FR-auth-roles-009, SC-auth-roles-05).
 *
 * Không được tự khóa mình. Không khóa quản lý ACTIVE cuối cùng.
 * Không kiểm tài khoản đã LOCKED sẵn — gọi lại vẫn UPDATE status và tăng version.
 * @returns DTO và câu xác nhận. Không trả mật khẩu.
 */
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

/**
 * Mở khóa: mật khẩu tạm mới, "Chờ kích hoạt", đếm sai về 0 (FR-auth-roles-010).
 *
 * Chỉ khi status hiện là `LOCKED`, nếu không 409 `NOT_LOCKED`. Không mở phiên.
 * Mật khẩu tạm trả một lần trong response, không ghi vào nhật ký (nhật ký chỉ có đổi status).
 * @returns `{ user, tempPassword, message }`.
 */
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
 *
 * Tài khoản đang LOCKED → 409, phải dùng mở khóa. Tự đặt lại mật khẩu của chính mình
 * thì không hủy phiên (`target.id === actor.id`); người khác bị `PASSWORD_RESET`.
 * @returns `{ user, tempPassword, message }`. Hash mới đã lưu, plaintext chỉ ở response.
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
