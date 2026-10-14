import type { HousekeepingTask, Prisma } from '@prisma/client';
import { writeAudit } from '../../lib/audit.js';
import { MSG } from '../../lib/messages.js';
import { CHANNELS, type PendingEvent } from '../../realtime/events.js';
import { notification } from '../../realtime/notify.js';
import { roomLabel } from '../rooms/rooms.service.js';
import { housekeepingInclude, toHousekeepingTaskDto } from './housekeeping.dto.js';

type Enqueue = (event: PendingEvent) => void;

/** Trạng thái tính là "việc đang mở" khi chia việc (BR-housekeeping-004). */
export const OPEN_TASK_STATUSES = ['ASSIGNED', 'IN_PROGRESS', 'PENDING_CONFIRM'] as const;

// Mọi lần chia việc chạy tuần tự → 2 lượt trả phòng cùng lúc không dồn việc cho cùng một người.
const ASSIGNMENT_LOCK = 724002;

/**
 * Khóa tư vấn Postgres `724002` đến hết transaction, để hai lần trả phòng
 * không cùng chọn một nhân viên trước khi đếm việc của nhau cập nhật.
 * @param tx Transaction sẽ giữ khóa đến commit hoặc rollback.
 * @returns Promise khi khóa đã lấy. Không trả dữ liệu.
 */
export async function serializeAssignment(tx: Prisma.TransactionClient) {
  await tx.$queryRaw`SELECT 1 FROM pg_advisory_xact_lock(${ASSIGNMENT_LOCK}::bigint)`;
}

/**
 * Chọn nhân viên buồng phòng–bảo trì đang trực (và đang hoạt động) có ÍT việc đang mở nhất;
 * hòa → người lâu nhất chưa được giao việc (BR-housekeeping-004 / FR-002).
 * Nguồn "đang trực" tạm là cờ `onDuty` do quản lý/lễ tân bật (housekeeping OQ-1 chưa chốt).
 *
 * Không ghi dữ liệu. Hòa mọi tiêu chí thì xếp theo `id` để kết quả ổn định.
 * @param tx Transaction đang giữ khóa chia việc (người gọi phải `serializeAssignment` nếu sắp ghi).
 * @param excludeUserIds Nhân viên vừa từ chối hoặc không được chọn lại. Mặc định không loại ai.
 * @returns `{ id, fullName }` hoặc `null` khi không còn ai trực.
 */
export async function pickAssignee(tx: Prisma.TransactionClient, excludeUserIds: string[] = []) {
  const candidates = await tx.user.findMany({
    where: { role: 'STAFF', status: 'ACTIVE', onDuty: true, id: { notIn: excludeUserIds } },
    select: { id: true, fullName: true },
  });
  if (candidates.length === 0) return null;

  const ids = candidates.map((c) => c.id);
  const [openCounts, lastAssigned] = await Promise.all([
    tx.housekeepingTask.groupBy({
      by: ['assigneeId'],
      where: { assigneeId: { in: ids }, status: { in: [...OPEN_TASK_STATUSES] } },
      _count: { _all: true },
    }),
    tx.housekeepingTask.groupBy({ by: ['assigneeId'], where: { assigneeId: { in: ids } }, _max: { assignedAt: true } }),
  ]);
  const open = new Map(openCounts.map((row) => [row.assigneeId, row._count._all]));
  const last = new Map(lastAssigned.map((row) => [row.assigneeId, row._max.assignedAt?.getTime() ?? 0]));

  return [...candidates].sort(
    (a, b) =>
      (open.get(a.id) ?? 0) - (open.get(b.id) ?? 0) ||
      (last.get(a.id) ?? 0) - (last.get(b.id) ?? 0) ||
      a.id.localeCompare(b.id), // cố định thứ tự khi mọi thứ bằng nhau
  )[0];
}

/**
 * Hệ thống tự giao một việc (mới tạo, bị từ chối, hoặc đang chờ giao).
 * Không có ai trực → để "chờ giao" và cảnh báo quản lý (FR-003, E-housekeeping-002).
 * Gọi bên trong transaction đã `serializeAssignment`.
 *
 * Có người: status `ASSIGNED`, ghi `assignedAt`, nhật ký hệ thống `housekeeping.task_assigned`,
 * báo riêng người được giao. Không có người: nếu việc chưa phải `UNASSIGNED` thì chuyển về
 * chờ giao và xóa assignee; luôn báo quản lý `HOUSEKEEPING_UNASSIGNED`.
 * UPDATE này làm trigger tăng `version`. Cuối hàm luôn phát `housekeeping:task_updated`.
 * @param task Việc cần giao. Dùng `roomId`, `status`, `assigneeId` hiện tại.
 * @param excludeUserIds Truyền người vừa từ chối để không giao lại đúng họ trong lượt này.
 * @returns DTO việc sau khi giao hoặc sau khi để chờ.
 */
export async function autoAssign(
  tx: Prisma.TransactionClient,
  task: HousekeepingTask,
  enqueue: Enqueue,
  excludeUserIds: string[] = [],
) {
  const room = await tx.room.findUniqueOrThrow({ where: { id: task.roomId }, select: { id: true, number: true } });
  const label = roomLabel(room);
  const refs = { taskId: task.id, roomId: room.id };
  const assignee = await pickAssignee(tx, excludeUserIds);

  if (!assignee) {
    if (task.status !== 'UNASSIGNED') {
      await tx.housekeepingTask.update({ where: { id: task.id }, data: { status: 'UNASSIGNED', assigneeId: null } });
    }
    enqueue(notification(CHANNELS.role('MANAGER'), 'HOUSEKEEPING_UNASSIGNED', MSG.noStaffOnDuty, refs));
  } else {
    const previous = task.assigneeId
      ? (await tx.user.findUnique({ where: { id: task.assigneeId }, select: { fullName: true } }))?.fullName
      : null;
    await tx.housekeepingTask.update({
      where: { id: task.id },
      data: { status: 'ASSIGNED', assigneeId: assignee.id, assignedAt: new Date() },
    });
    await writeAudit(tx, {
      actorId: null,
      actorRole: 'SYSTEM',
      action: 'housekeeping.task_assigned',
      entityType: 'HOUSEKEEPING_TASK',
      entityId: task.id,
      entityLabel: `Dọn ${label}`,
      roomId: room.id,
      changes: [
        ...(task.status === 'ASSIGNED' ? [] : [{ field: 'status', before: task.status, after: 'ASSIGNED' }]),
        { field: 'assignee', before: previous ?? null, after: assignee.fullName },
      ],
    });
    enqueue(notification(CHANNELS.user(assignee.id), 'HOUSEKEEPING_ASSIGNED', MSG.taskAssignedToYou(label), refs));
  }

  const updated = await tx.housekeepingTask.findUniqueOrThrow({ where: { id: task.id }, include: housekeepingInclude });
  const dto = toHousekeepingTaskDto(updated);
  enqueue({ channel: CHANNELS.hotel, event: 'housekeeping:task_updated', payload: { task: dto } });
  return dto;
}

/**
 * Có người vào trực → giao lần lượt các việc "chờ giao" (FR-003).
 *
 * Tự lấy khóa chia việc. Sắp theo `createdAt` tăng dần (gần với thứ tự trả phòng vì việc
 * được tạo lúc checkout). Hết người trực thì dừng, không gọi `autoAssign` nên không
 * bắn thêm cảnh báo "chưa có nhân viên" cho từng việc còn lại.
 * @param tx Transaction của lần bật `onDuty` (hoặc chỗ gọi khác).
 * @param enqueue Sự kiện giao việc và `task_updated` đi cùng commit đó.
 * @returns Promise rỗng. Số việc giao được không trả ra.
 */
export async function assignPendingTasks(tx: Prisma.TransactionClient, enqueue: Enqueue) {
  await serializeAssignment(tx);
  const pending = await tx.housekeepingTask.findMany({ where: { status: 'UNASSIGNED' }, orderBy: { createdAt: 'asc' } });
  for (const task of pending) {
    if (!(await pickAssignee(tx))) break; // hết người trực — không cảnh báo lặp lại cho từng việc
    await autoAssign(tx, task, enqueue);
  }
}
