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
 * - OQ-1 ngưỡng quá hạn: chốt 10/10/2026 = 4 giờ (mặc định 240 phút). Đổi bằng MAINTENANCE_DUE_MINUTES; 0 = tắt.
 *
 * Chưa chốt (ghi rõ để nhóm quyết):
 * - OQ-2 giao việc: nhân viên TỰ NHẬN (giả định trong URD); quản lý/lễ tân chỉ định được (FR-009, P1).
 * - OQ-3 sửa khi phòng có khách: không chặn.
 */
type Enqueue = (event: PendingEvent) => void;

const OPEN_STATUSES: MaintenanceTaskStatus[] = ['OPEN', 'IN_PROGRESS'];
const invalidState = () => new AppError(409, 'INVALID_STATE', MSG.invalidState);

export const DEFAULT_MAINTENANCE_DUE_MINUTES = 240;

/**
 * Ngưỡng quá hạn việc sửa, tính bằng phút.
 *
 * Đọc `process.env.MAINTENANCE_DUE_MINUTES` trực tiếp, không đọc object `env` đã parse.
 * Không khai báo hoặc chuỗi trắng → 240. Số ≤ 0 hoặc không phải số hữu hạn → `null` (không đặt `dueAt`).
 * @returns Số phút dương, hoặc `null` khi tắt cờ quá hạn.
 */
function dueMinutes(): number | null {
  const raw = process.env.MAINTENANCE_DUE_MINUTES;
  if (raw === undefined || raw.trim() === '') return DEFAULT_MAINTENANCE_DUE_MINUTES;
  const minutes = Number(raw);
  return Number.isFinite(minutes) && minutes > 0 ? minutes : null;
}

/**
 * Tính lại trục bảo trì của phòng sau mỗi thay đổi việc sửa hoặc hold tay.
 *
 * Còn việc `OPEN`/`IN_PROGRESS` hoặc hold chưa `liftedAt` → `OUT_OF_SERVICE`, ngược lại `IN_SERVICE`.
 * Nhờ `applyRoomChange`, không đổi thì không tăng version phòng và không phát sự kiện.
 * @returns Kết quả `applyRoomChange` (phòng trước khi đổi và các trục đã khác).
 */
export async function syncServiceAxis(tx: Prisma.TransactionClient, roomId: string, enqueue: Enqueue) {
  const [openTasks, activeHold] = await Promise.all([
    tx.maintenanceTask.count({ where: { roomId, status: { in: OPEN_STATUSES } } }),
    tx.outOfServiceHold.count({ where: { roomId, liftedAt: null } }),
  ]);
  const service = openTasks > 0 || activeHold > 0 ? 'OUT_OF_SERVICE' : 'IN_SERVICE';
  return applyRoomChange(tx, roomId, { service }, enqueue);
}

/**
 * Khóa dòng việc sửa và đối chiếu version. Lệch → 409 kèm DTO.
 * @returns Việc include phòng, người báo, người xử lý.
 */
async function lockTask(tx: Prisma.TransactionClient, taskId: string, version: number) {
  await tx.$queryRaw`SELECT 1 FROM maintenance_tasks WHERE id = ${taskId}::uuid FOR UPDATE`;
  const task = await tx.maintenanceTask.findUnique({ where: { id: taskId }, include: maintenanceInclude });
  if (!task) throw new NotFoundError('Việc bảo trì không tồn tại.');
  if (task.version !== version) throw new VersionConflictError('Việc bảo trì', taskId, version, toMaintenanceTaskDto(task));
  return task;
}

type LockedTask = Awaited<ReturnType<typeof lockTask>>;

/**
 * Ghi việc, tính lại trục bảo trì, nhật ký, rồi phát `maintenance:task_updated`.
 * Luôn gọi `syncServiceAxis` kể cả khi status mới không đổi (đổi assignee).
 * @returns DTO trong transaction, trước commit.
 */
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

/**
 * Danh sách việc kèm phòng, mô tả, vị trí, trạng thái, người xử lý (FR-004, lọc FR-012).
 *
 * Mọi vai trò đã đăng nhập đều xem được — không lọc theo người gọi. Tối đa 200 dòng mới nhất.
 * @param filter `status`, `roomId`, `assigneeId` đều tùy chọn. Prisma bỏ trường undefined.
 * @returns DTO. Không kèm byte ảnh (bảo trì không có ảnh).
 */
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
 *
 * `dueAt` = now + `dueMinutes()`, hoặc null khi ngưỡng tắt. Không khóa version phòng:
 * `syncServiceAxis` tự đọc version hiện tại. Báo kênh `role:STAFF`.
 * @param input `description` đã được route giới hạn 500 ký tự.
 * @returns `{ task, warning }`. `warning` có câu tiếng Việt khi phòng đã có việc mở.
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

/**
 * Nhân viên nhận việc "chờ nhận" → "đang sửa", gán mình là người xử lý (FR-004).
 *
 * Role khác STAFF → 403 (route cũng đã chặn). Đã giao người khác → 409 `ASSIGNED_TO_OTHER`.
 * Không đòi `onDuty`. Không đổi status nếu không còn `OPEN`.
 * @returns DTO `IN_PROGRESS`.
 */
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

/**
 * Báo hoàn tất việc do chính mình đang sửa → `DONE` (FR-005).
 *
 * Phòng về "đang phục vụ" chỉ khi hết việc mở và không còn hold tay (`syncServiceAxis`).
 * Không phải assignee → 403. Không còn `IN_PROGRESS` → 409.
 * @returns DTO sau commit.
 */
export async function completeTask(actor: User, taskId: string, version: number) {
  return withTransaction(async (tx, enqueue) => {
    const task = await lockTask(tx, taskId, version);
    if (actor.role !== 'STAFF' || task.assigneeId !== actor.id) throw new ForbiddenError();
    if (task.status !== 'IN_PROGRESS') throw invalidState();
    return transition(tx, enqueue, actor, task, 'maintenance.completed', { status: 'DONE' });
  });
}

/**
 * Hủy việc (FR-006).
 *
 * `OPEN`: quản lý, hoặc đúng người đã báo. `IN_PROGRESS`: chỉ quản lý.
 * Lễ tân không phải người báo bị 403. `DONE`/`CANCELLED` → 409. Lý do tùy chọn, route cắt 200 ký tự.
 * Hủy xong, `syncServiceAxis` có thể mở lại phòng nếu không còn việc và không còn hold.
 * @param reason Bỏ qua thì `cancelReason` lưu null và nhật ký không có field đó.
 * @returns DTO `CANCELLED`.
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

/**
 * Quản lý hoặc lễ tân chỉ định người xử lý cho việc đang mở (FR-009, P1).
 *
 * Không đổi status. Người nhận phải STAFF và ACTIVE. Không kiểm `onDuty` — nhân viên
 * đang tắt trực vẫn được gán; nếu sai role/trạng thái thì lỗi vẫn mang mã `ASSIGNEE_NOT_ON_DUTY`.
 * @param assigneeId UUID nhân viên. Không bắt phải khác người đang giữ việc.
 * @returns DTO cùng status, assignee mới.
 */
export async function assignTask(actor: User, taskId: string, version: number, assigneeId: string) {
  return withTransaction(async (tx, enqueue) => {
    const task = await lockTask(tx, taskId, version);
    if (!OPEN_STATUSES.includes(task.status)) throw invalidState();
    const assignee = await tx.user.findUnique({ where: { id: assigneeId } });
    if (assignee?.role !== 'STAFF' || assignee.status !== 'ACTIVE') {
      throw new AppError(400, 'ASSIGNEE_NOT_ON_DUTY', MSG.assigneeNotOnDuty);
    }
    return transition(tx, enqueue, actor, task, 'maintenance.assigned', { status: task.status, assigneeId }, [
      { field: 'assignee', before: task.assignee?.fullName ?? null, after: assignee.fullName },
    ]);
  });
}
