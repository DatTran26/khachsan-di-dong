import type { MaintenanceTaskStatus, Prisma, User } from '@prisma/client';
import { writeAudit, type AuditChange } from '../../lib/audit.js';
import { AppError, ForbiddenError, NotFoundError, VersionConflictError } from '../../lib/errors.js';
import { MSG } from '../../lib/messages.js';
import { updateWithVersion } from '../../lib/optimistic-lock.js';
import { prisma } from '../../lib/prisma.js';
import { withTransaction } from '../../lib/transaction.js';
import { CHANNELS, type PendingEvent } from '../../realtime/events.js';
import { notification } from '../../realtime/notify.js';
import { applyRoomChange, roomLabel } from '../rooms/rooms.service.js';
import { maintenanceInclude, toMaintenanceTaskDto } from './maintenance.dto.js';

/**
 * Báo hỏng & bảo trì (maintenance spec):
 *   chờ nhận → đang sửa → hoàn tất   ·   chờ nhận / đang sửa → đã hủy
 * Trục bảo trì của phòng TỰ TÍNH: "ngừng phục vụ" khi còn ≥1 việc mở HOẶC đang có ngừng phục vụ tay;
 * ngược lại "bình thường" (FR-002/003).
 *
 * Chưa chốt (ghi rõ để nhóm quyết):
 * - OQ-1 ngưỡng quá hạn: đọc MAINTENANCE_DUE_MINUTES trong .env; bỏ trống = không tính quá hạn.
 * - OQ-2 giao việc: nhân viên TỰ NHẬN (giả định trong URD); quản lý/lễ tân chỉ định được (FR-009, P1).
 * - OQ-3 sửa khi phòng có khách: không chặn.
 */
type Enqueue = (event: PendingEvent) => void;

const OPEN_STATUSES: MaintenanceTaskStatus[] = ['OPEN', 'IN_PROGRESS'];
const invalidState = () => new AppError(409, 'INVALID_STATE', MSG.invalidState);

function dueMinutes(): number | null {
  const minutes = Number(process.env.MAINTENANCE_DUE_MINUTES);
  return Number.isFinite(minutes) && minutes > 0 ? minutes : null;
}

/** Tính lại trục bảo trì của phòng sau mỗi thay đổi việc sửa / ngừng phục vụ tay. */
export async function syncServiceAxis(tx: Prisma.TransactionClient, roomId: string, enqueue: Enqueue) {
  const [openTasks, activeHold] = await Promise.all([
    tx.maintenanceTask.count({ where: { roomId, status: { in: OPEN_STATUSES } } }),
    tx.outOfServiceHold.count({ where: { roomId, liftedAt: null } }),
  ]);
  const service = openTasks > 0 || activeHold > 0 ? 'OUT_OF_SERVICE' : 'IN_SERVICE';
  return applyRoomChange(tx, roomId, { service }, enqueue);
}

async function lockTask(tx: Prisma.TransactionClient, taskId: string, version: number) {
  await tx.$queryRaw`SELECT 1 FROM maintenance_tasks WHERE id = ${taskId}::uuid FOR UPDATE`;
  const task = await tx.maintenanceTask.findUnique({ where: { id: taskId }, include: maintenanceInclude });
  if (!task) throw new NotFoundError('Việc bảo trì không tồn tại.');
  if (task.version !== version) throw new VersionConflictError('Việc bảo trì', taskId, version, toMaintenanceTaskDto(task));
  return task;
}

type LockedTask = Awaited<ReturnType<typeof lockTask>>;

/** Ghi việc + tính lại trục bảo trì + nhật ký + realtime, một transaction. */
async function transition(
  tx: Prisma.TransactionClient,
  enqueue: Enqueue,
  actor: User,
  task: LockedTask,
  action: string,
  data: Prisma.MaintenanceTaskUncheckedUpdateManyInput & { status: MaintenanceTaskStatus },
  extraChanges: AuditChange[] = [],
) {
  await updateWithVersion(tx, 'maintenanceTask', task.id, task.version, data);
  const { changes: roomChanges } = await syncServiceAxis(tx, task.roomId, enqueue);
  await writeAudit(tx, {
    actorId: actor.id,
    actorRole: actor.role,
    action,
    entityType: 'MAINTENANCE_TASK',
    entityId: task.id,
    entityLabel: `Sửa ${roomLabel(task.room)}`,
    roomId: task.roomId,
    changes: [
      ...(task.status === data.status ? [] : [{ field: 'status', before: task.status, after: data.status }]),
      ...extraChanges,
      ...roomChanges.map((c) => ({ ...c, entityType: 'ROOM' as const, entityId: task.roomId, entityLabel: roomLabel(task.room) })),
    ],
  });
  const dto = toMaintenanceTaskDto(await tx.maintenanceTask.findUniqueOrThrow({ where: { id: task.id }, include: maintenanceInclude }));
  enqueue({ channel: CHANNELS.hotel, event: 'maintenance:task_updated', payload: { task: dto } });
  return dto;
}

// ---- Đọc -----------------------------------------------------------------------

export interface MaintenanceFilter {
  status?: MaintenanceTaskStatus;
  roomId?: string;
  assigneeId?: string;
}

/** Danh sách việc kèm phòng, mô tả, vị trí, trạng thái, người xử lý (FR-004, lọc FR-012). */
export async function listTasks(filter: MaintenanceFilter) {
  const tasks = await prisma.maintenanceTask.findMany({
    where: filter,
    include: maintenanceInclude,
    orderBy: { createdAt: 'desc' },
    take: 200,
  });
  return tasks.map(toMaintenanceTaskDto);
}

// ---- Thao tác ------------------------------------------------------------------

/**
 * Báo hỏng — mọi vai trò (FR-001). Phòng lập tức "ngừng phục vụ" → check-in-out chặn nhận khách (FR-002).
 * Phòng đã có việc mở vẫn ghi nhận, kèm cảnh báo nhẹ (FR-008).
 */
export async function reportIssue(actor: User, input: { roomId: string; description: string; location?: string }) {
  return withTransaction(async (tx, enqueue) => {
    const room = await tx.room.findUnique({ where: { id: input.roomId } });
    if (!room) throw new NotFoundError('Phòng không tồn tại.');
    const alreadyOpen = await tx.maintenanceTask.count({ where: { roomId: room.id, status: { in: OPEN_STATUSES } } });

    const minutes = dueMinutes();
    const created = await tx.maintenanceTask.create({
      data: {
        ...input,
        reporterId: actor.id,
        dueAt: minutes ? new Date(Date.now() + minutes * 60_000) : null,
      },
    });
    const { changes: roomChanges } = await syncServiceAxis(tx, room.id, enqueue);
    await writeAudit(tx, {
      actorId: actor.id,
      actorRole: actor.role,
      action: 'maintenance.reported',
      entityType: 'MAINTENANCE_TASK',
      entityId: created.id,
      entityLabel: `Sửa ${roomLabel(room)}`,
      roomId: room.id,
      changes: [
        { field: 'status', after: created.status },
        { field: 'description', after: created.description },
        ...roomChanges.map((c) => ({ ...c, entityType: 'ROOM' as const, entityId: room.id, entityLabel: roomLabel(room) })),
      ],
    });

    const task = toMaintenanceTaskDto(await tx.maintenanceTask.findUniqueOrThrow({ where: { id: created.id }, include: maintenanceInclude }));
    enqueue({ channel: CHANNELS.hotel, event: 'maintenance:task_updated', payload: { task } });
    enqueue(notification(CHANNELS.role('STAFF'), 'MAINTENANCE_REPORTED', MSG.maintenanceReported(roomLabel(room)), { taskId: task.id, roomId: room.id }));
    return { task, warning: alreadyOpen > 0 ? MSG.maintenanceAlreadyOpen : undefined };
  });
}

/** Nhân viên nhận việc "chờ nhận" → "đang sửa", gán mình là người xử lý (FR-004). */
export async function claimTask(actor: User, taskId: string, version: number) {
  return withTransaction(async (tx, enqueue) => {
    const task = await lockTask(tx, taskId, version);
    if (actor.role !== 'STAFF') throw new ForbiddenError();
    if (task.status !== 'OPEN') throw invalidState();
    if (task.assigneeId && task.assigneeId !== actor.id) throw new AppError(409, 'ASSIGNED_TO_OTHER', MSG.maintenanceAssignedToOther);
    return transition(tx, enqueue, actor, task, 'maintenance.claimed', { status: 'IN_PROGRESS', assigneeId: actor.id }, [
      { field: 'assignee', before: task.assignee?.fullName ?? null, after: actor.fullName },
    ]);
  });
}

/** Báo hoàn tất việc do chính mình đang sửa → "hoàn tất"; phòng mở lại nếu hết việc + không ngừng tay (FR-005/003). */
export async function completeTask(actor: User, taskId: string, version: number) {
  return withTransaction(async (tx, enqueue) => {
    const task = await lockTask(tx, taskId, version);
    if (actor.role !== 'STAFF' || task.assigneeId !== actor.id) throw new ForbiddenError();
    if (task.status !== 'IN_PROGRESS') throw invalidState();
    return transition(tx, enqueue, actor, task, 'maintenance.completed', { status: 'DONE' });
  });
}

/**
 * Hủy (FR-006): việc "chờ nhận" → người báo hoặc quản lý; việc "đang sửa" → chỉ quản lý. Lý do tùy chọn ≤200.
 */
export async function cancelTask(actor: User, taskId: string, version: number, reason?: string) {
  return withTransaction(async (tx, enqueue) => {
    const task = await lockTask(tx, taskId, version);
    if (!OPEN_STATUSES.includes(task.status)) throw invalidState();
    const allowed = actor.role === 'MANAGER' || (task.status === 'OPEN' && task.reporterId === actor.id);
    if (!allowed) throw new ForbiddenError();
    return transition(tx, enqueue, actor, task, 'maintenance.cancelled', { status: 'CANCELLED', cancelReason: reason ?? null }, [
      ...(reason ? [{ field: 'cancelReason', after: reason }] : []),
    ]);
  });
}

/** Quản lý / lễ tân chỉ định hoặc đổi người xử lý cho việc đang mở (FR-009, P1). */
export async function assignTask(actor: User, taskId: string, version: number, assigneeId: string) {
  return withTransaction(async (tx, enqueue) => {
    const task = await lockTask(tx, taskId, version);
    if (!OPEN_STATUSES.includes(task.status)) throw invalidState();
    const assignee = await tx.user.findUnique({ where: { id: assigneeId } });
    if (!assignee || assignee.role !== 'STAFF' || assignee.status !== 'ACTIVE') {
      throw new AppError(400, 'ASSIGNEE_NOT_ON_DUTY', MSG.assigneeNotOnDuty);
    }
    return transition(tx, enqueue, actor, task, 'maintenance.assigned', { status: task.status, assigneeId }, [
      { field: 'assignee', before: task.assignee?.fullName ?? null, after: assignee.fullName },
    ]);
  });
}
