import type { HousekeepingTask, HousekeepingTaskStatus, Prisma, User } from '@prisma/client';
import { writeAudit, type AuditChange } from '../../lib/audit.js';
import { AppError, ForbiddenError, NotFoundError, VersionConflictError } from '../../lib/errors.js';
import { MSG } from '../../lib/messages.js';
import { updateWithVersion } from '../../lib/optimistic-lock.js';
import { prisma } from '../../lib/prisma.js';
import { withTransaction } from '../../lib/transaction.js';
import { CHANNELS, type PendingEvent } from '../../realtime/events.js';
import { notification } from '../../realtime/notify.js';
import { applyRoomChange, roomLabel } from '../rooms/rooms.service.js';
import { autoAssign, serializeAssignment } from './housekeeping.assignment.js';
import { OVERDUE_STATUSES, housekeepingInclude, toHousekeepingTaskDto } from './housekeeping.dto.js';
import { REQUIRED_CATEGORIES, countRoundPhotos } from './housekeeping.photos.js';

/**
 * Chu trình việc dọn (housekeeping-states.md):
 *   chờ giao → đã giao → đang làm → chờ xác nhận → hoàn tất
 *   (từ chối: giao người khác / về chờ giao · trả lại: chờ xác nhận → đang làm)
 * Trục vệ sinh của phòng đi theo: cần dọn → đang dọn → chờ kiểm tra → sạch.
 * Quyền (NFR-004): nhân viên chỉ thao tác việc của mình; chỉ quản lý xác nhận / trả lại / phân công lại.
 */
type Enqueue = (event: PendingEvent) => void;

const invalidState = () => new AppError(409, 'INVALID_STATE', MSG.invalidState);

/** Khóa dòng việc + kiểm version (chống ghi đè — FR-012). */
async function lockTask(tx: Prisma.TransactionClient, taskId: string, version: number) {
  await tx.$queryRaw`SELECT 1 FROM housekeeping_tasks WHERE id = ${taskId}::uuid FOR UPDATE`;
  const task = await tx.housekeepingTask.findUnique({ where: { id: taskId }, include: housekeepingInclude });
  if (!task) throw new NotFoundError('Công việc không tồn tại.');
  if (task.version !== version) {
    throw new VersionConflictError('Việc dọn phòng', taskId, version, toHousekeepingTaskDto(task));
  }
  return task;
}

function assertOwnTask(actor: User, task: HousekeepingTask) {
  if (actor.role !== 'STAFF' || task.assigneeId !== actor.id) throw new ForbiddenError();
}

async function audit(
  tx: Prisma.TransactionClient,
  actor: User,
  action: string,
  task: HousekeepingTask & { room: { id: string; number: string } },
  changes: AuditChange[],
) {
  await writeAudit(tx, {
    actorId: actor.id,
    actorRole: actor.role,
    action,
    entityType: 'HOUSEKEEPING_TASK',
    entityId: task.id,
    entityLabel: `Dọn ${roomLabel(task.room)}`,
    roomId: task.room.id,
    changes,
  });
}

/** Đổi trạng thái việc (+ trục vệ sinh phòng) trong một transaction, ghi nhật ký, phát realtime. */
async function transition(
  tx: Prisma.TransactionClient,
  enqueue: Enqueue,
  actor: User,
  task: Awaited<ReturnType<typeof lockTask>>,
  action: string,
  data: Prisma.HousekeepingTaskUncheckedUpdateManyInput & { status: HousekeepingTaskStatus },
  roomCleaning?: 'CLEANING' | 'PENDING_INSPECTION' | 'CLEAN',
  extraChanges: AuditChange[] = [],
) {
  await updateWithVersion(tx, 'housekeepingTask', task.id, task.version, data);
  const { changes: roomChanges } = roomCleaning
    ? await applyRoomChange(tx, task.roomId, { cleaning: roomCleaning }, enqueue)
    : { changes: [] };
  await audit(tx, actor, action, task, [
    ...(task.status === data.status ? [] : [{ field: 'status', before: task.status, after: data.status }]),
    ...extraChanges,
    ...roomChanges.map((c) => ({ ...c, entityType: 'ROOM' as const, entityId: task.roomId, entityLabel: roomLabel(task.room) })),
  ]);
  const dto = toHousekeepingTaskDto(
    await tx.housekeepingTask.findUniqueOrThrow({ where: { id: task.id }, include: housekeepingInclude }),
  );
  enqueue({ channel: CHANNELS.hotel, event: 'housekeeping:task_updated', payload: { task: dto } });
  return dto;
}

// ---- Đọc -----------------------------------------------------------------------

export interface TaskFilter {
  status?: HousekeepingTaskStatus;
  assigneeId?: string;
  roomId?: string;
  overdue?: boolean;
}

/** Danh sách việc, lọc theo nhân viên / trạng thái / phòng (FR-010). */
export async function listTasks(filter: TaskFilter) {
  const tasks = await prisma.housekeepingTask.findMany({
    where: {
      status: filter.status,
      assigneeId: filter.assigneeId,
      roomId: filter.roomId,
      ...(filter.overdue ? { overdueFlaggedAt: { not: null }, status: { in: OVERDUE_STATUSES } } : {}),
    },
    include: housekeepingInclude,
    orderBy: { createdAt: 'desc' },
    take: 200,
  });
  return tasks.map(toHousekeepingTaskDto);
}

// ---- Nhân viên -----------------------------------------------------------------

/** Nhận việc → "đang làm", phòng → "đang dọn" (FR-004). Việc đã có người nhận → E-001. */
export async function acceptTask(actor: User, taskId: string, version: number) {
  return withTransaction(async (tx, enqueue) => {
    const task = await lockTask(tx, taskId, version);
    assertOwnTask(actor, task);
    if (task.status === 'IN_PROGRESS') throw new AppError(409, 'TASK_ALREADY_TAKEN', MSG.taskAlreadyTaken);
    if (task.status !== 'ASSIGNED') throw invalidState();
    return transition(tx, enqueue, actor, task, 'housekeeping.task_accepted', { status: 'IN_PROGRESS', startedAt: new Date() }, 'CLEANING');
  });
}

/** Từ chối → giao người trực ít việc kế tiếp; hết người → "chờ giao" + cảnh báo quản lý (FR-004). */
export async function rejectTask(actor: User, taskId: string, version: number) {
  return withTransaction(async (tx, enqueue) => {
    await serializeAssignment(tx);
    const task = await lockTask(tx, taskId, version);
    assertOwnTask(actor, task);
    if (task.status !== 'ASSIGNED') throw invalidState();

    await audit(tx, actor, 'housekeeping.task_rejected', task, [{ field: 'assignee', before: actor.fullName, after: null }]);
    const fresh = await tx.housekeepingTask.findUniqueOrThrow({ where: { id: taskId } });
    return autoAssign(tx, fresh, enqueue, [actor.id]);
  });
}

/**
 * Báo hoàn tất → "chờ xác nhận", phòng → "chờ kiểm tra", báo quản lý (FR-005, FR-006).
 * Chỉ khi lượt ảnh hiện tại đủ 3 nhóm bắt buộc; đánh dấu bất thường thì cần thêm ảnh cận cảnh (BR-006, E-007).
 */
export async function completeTask(actor: User, taskId: string, version: number, hasIssue = false) {
  return withTransaction(async (tx, enqueue) => {
    const task = await lockTask(tx, taskId, version);
    assertOwnTask(actor, task);
    if (task.status !== 'IN_PROGRESS') throw invalidState();
    const counts = await countRoundPhotos(tx, task);
    if (REQUIRED_CATEGORIES.some((category) => !counts.get(category))) {
      throw new AppError(400, 'PHOTOS_REQUIRED', MSG.photosRequired);
    }
    if (hasIssue && !counts.get('CLOSEUP')) throw new AppError(400, 'CLOSEUP_REQUIRED', MSG.closeupRequired);
    const photoCount = [...counts.values()].reduce((sum, n) => sum + n, 0);

    const dto = await transition(
      tx,
      enqueue,
      actor,
      task,
      'housekeeping.task_completed',
      { status: 'PENDING_CONFIRM', completedAt: new Date(), hasIssue },
      'PENDING_INSPECTION',
      // Lần nộp ảnh được ghi vào nhật ký (FR-housekeeping-015).
      [
        { field: 'photos', after: `${photoCount} ảnh (lượt ${task.photoRound})` },
        ...(hasIssue ? [{ field: 'hasIssue', before: 'false', after: 'true' }] : []),
      ],
    );
    enqueue(notification(CHANNELS.role('MANAGER'), 'HOUSEKEEPING_PENDING_CONFIRM', MSG.taskPendingConfirm(roomLabel(task.room)), { taskId, roomId: task.roomId }));
    return dto;
  });
}

// ---- Quản lý -------------------------------------------------------------------

/** Xác nhận → "hoàn tất", phòng → "sạch". CHỈ quản lý (BR-housekeeping-001, FR-006). */
export async function confirmTask(actor: User, taskId: string, version: number) {
  return withTransaction(async (tx, enqueue) => {
    const task = await lockTask(tx, taskId, version);
    if (task.status !== 'PENDING_CONFIRM') throw invalidState();
    return transition(tx, enqueue, actor, task, 'housekeeping.task_confirmed', { status: 'DONE', confirmedAt: new Date(), confirmedById: actor.id }, 'CLEAN');
  });
}

/**
 * Trả lại kèm ghi chú (≤500) → "đang làm", phòng → "đang dọn", báo nhân viên (FR-008, BR-005).
 * Sang lượt ảnh mới — ảnh lượt cũ giữ nguyên để truy vết, nhân viên phải nộp lại bộ ảnh.
 */
export async function returnTask(actor: User, taskId: string, version: number, note: string) {
  return withTransaction(async (tx, enqueue) => {
    const task = await lockTask(tx, taskId, version);
    if (task.status !== 'PENDING_CONFIRM') throw invalidState();
    const dto = await transition(
      tx,
      enqueue,
      actor,
      task,
      'housekeeping.task_returned',
      { status: 'IN_PROGRESS', returnNote: note, completedAt: null, hasIssue: false, photoRound: { increment: 1 } },
      'CLEANING',
      [
        { field: 'returnNote', after: note },
        { field: 'photoRound', before: String(task.photoRound), after: String(task.photoRound + 1) },
      ],
    );
    if (task.assigneeId) {
      enqueue(notification(CHANNELS.user(task.assigneeId), 'HOUSEKEEPING_RETURNED', MSG.taskReturned(roomLabel(task.room), note), { taskId, roomId: task.roomId }));
    }
    return dto;
  });
}

/** Phân công lại việc đang mở cho nhân viên đang trực khác; ghi nhật ký mỗi lần đổi người (FR-009, P1). */
export async function reassignTask(actor: User, taskId: string, version: number, assigneeId: string) {
  return withTransaction(async (tx, enqueue) => {
    await serializeAssignment(tx);
    const task = await lockTask(tx, taskId, version);
    if (!['UNASSIGNED', 'ASSIGNED', 'IN_PROGRESS'].includes(task.status)) throw invalidState();
    const assignee = await tx.user.findUnique({ where: { id: assigneeId } });
    if (assignee?.role !== 'STAFF' || assignee.status !== 'ACTIVE' || !assignee.onDuty) {
      throw new AppError(400, 'ASSIGNEE_NOT_ON_DUTY', MSG.assigneeNotOnDuty);
    }

    const status = task.status === 'UNASSIGNED' ? 'ASSIGNED' : task.status;
    const dto = await transition(
      tx,
      enqueue,
      actor,
      task,
      'housekeeping.task_reassigned',
      { status, assigneeId, assignedAt: new Date() },
      undefined,
      [{ field: 'assignee', before: task.assignee?.fullName ?? null, after: assignee.fullName }],
    );
    enqueue(notification(CHANNELS.user(assigneeId), 'HOUSEKEEPING_ASSIGNED', MSG.taskAssignedToYou(roomLabel(task.room)), { taskId, roomId: task.roomId }));
    return dto;
  });
}
