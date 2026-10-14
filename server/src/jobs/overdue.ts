import { writeAudit } from '../lib/audit.js';
import { MSG } from '../lib/messages.js';
import { withTransaction } from '../lib/transaction.js';
import { roomLabel } from '../modules/rooms/rooms.service.js';
import { OVERDUE_STATUSES, housekeepingInclude, toHousekeepingTaskDto } from '../modules/housekeeping/housekeeping.dto.js';
import { maintenanceInclude, toMaintenanceTaskDto } from '../modules/maintenance/maintenance.dto.js';
import { CHANNELS } from '../realtime/events.js';
import { notification } from '../realtime/notify.js';

/**
 * Đánh cờ "quá hạn" theo QUY TẮC (không phụ thuộc AI — tôn chỉ):
 * - Việc dọn: quá 60 phút từ lúc tạo mà nhân viên chưa báo hoàn tất (BR-housekeeping-002 — thời gian chờ quản lý
 *   xác nhận không tính). Cờ tự gỡ khi việc hoàn tất (FR-008) — DTO tính `isOverdue` theo trạng thái.
 * - Việc sửa: quá `dueAt` = lúc báo + 4 giờ (maintenance OQ-1, đổi bằng MAINTENANCE_DUE_MINUTES; 0 = tắt).
 * Mỗi việc chỉ cảnh báo MỘT lần (housekeeping OQ-2 chưa chốt → chọn cách tối thiểu), cho quản lý + người phụ trách.
 * Hệ thống là người thực hiện trong nhật ký (FR-audit-log-003).
 */
export async function flagOverdueTasks(now: Date = new Date()) {
  return withTransaction(async (tx, enqueue) => {
    const housekeeping = await tx.housekeepingTask.findMany({
      where: {
        status: { in: OVERDUE_STATUSES },
        completedAt: null,
        overdueFlaggedAt: null,
        dueAt: { lte: now },
      },
      include: housekeepingInclude,
    });
    for (const task of housekeeping) {
      const label = roomLabel(task.room);
      const flagged = await tx.housekeepingTask.update({
        where: { id: task.id },
        data: { overdueFlaggedAt: now },
        include: housekeepingInclude,
      });
      await writeAudit(tx, {
        actorId: null,
        actorRole: 'SYSTEM',
        action: 'housekeeping.task_overdue',
        entityType: 'HOUSEKEEPING_TASK',
        entityId: task.id,
        entityLabel: `Dọn ${label}`,
        roomId: task.room.id,
        changes: [{ field: 'overdue', before: 'false', after: 'true' }],
      });
      const refs = { taskId: task.id, roomId: task.room.id };
      enqueue({ channel: CHANNELS.hotel, event: 'housekeeping:task_updated', payload: { task: toHousekeepingTaskDto(flagged) } });
      enqueue(notification(CHANNELS.role('MANAGER'), 'HOUSEKEEPING_OVERDUE', MSG.taskOverdue(label), refs));
      if (task.assigneeId) enqueue(notification(CHANNELS.user(task.assigneeId), 'HOUSEKEEPING_OVERDUE', MSG.taskOverdue(label), refs));
    }

    const maintenance = await tx.maintenanceTask.findMany({
      where: { status: { in: ['OPEN', 'IN_PROGRESS'] }, overdueFlaggedAt: null, dueAt: { not: null, lte: now } },
      include: maintenanceInclude,
    });
    for (const task of maintenance) {
      const label = roomLabel(task.room);
      const flagged = await tx.maintenanceTask.update({
        where: { id: task.id },
        data: { overdueFlaggedAt: now },
        include: maintenanceInclude,
      });
      await writeAudit(tx, {
        actorId: null,
        actorRole: 'SYSTEM',
        action: 'maintenance.task_overdue',
        entityType: 'MAINTENANCE_TASK',
        entityId: task.id,
        entityLabel: `Sửa ${label}`,
        roomId: task.room.id,
        changes: [{ field: 'overdue', before: 'false', after: 'true' }],
      });
      const refs = { taskId: task.id, roomId: task.room.id };
      enqueue({ channel: CHANNELS.hotel, event: 'maintenance:task_updated', payload: { task: toMaintenanceTaskDto(flagged) } });
      enqueue(notification(CHANNELS.role('MANAGER'), 'MAINTENANCE_OVERDUE', MSG.maintenanceOverdue(label), refs));
      if (task.assigneeId) enqueue(notification(CHANNELS.user(task.assigneeId), 'MAINTENANCE_OVERDUE', MSG.maintenanceOverdue(label), refs));
    }

    return { housekeeping: housekeeping.length, maintenance: maintenance.length };
  });
}

/** Quét định kỳ. 30 giây/lần → cờ bật ≤1 phút sau khi vượt ngưỡng (SC-housekeeping-04). */
export function startOverdueJob(intervalMs = 30_000) {
  let running = false;
  const timer = setInterval(() => {
    if (running) return; // lần quét trước chưa xong thì bỏ qua lượt này
    running = true;
    flagOverdueTasks()
      .catch((error) => console.error('Quét quá hạn lỗi:', error))
      .finally(() => {
        running = false;
      });
  }, intervalMs);
  return () => clearInterval(timer);
}
