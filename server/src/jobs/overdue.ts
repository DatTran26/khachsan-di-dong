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
/**
 * Gắn cờ quá hạn cho việc dọn và việc sửa đến hạn mà chưa được gắn.
 *
 * Một transaction: với mỗi việc, set `overdueFlaggedAt`, ghi nhật ký hệ thống,
 * phát `*:task_updated` và notification cho quản lý cùng người được giao (nếu có).
 * Việc đã có cờ không bị chọn lại. Trigger `bump_version` vẫn tăng `version` của dòng
 * vì đây là UPDATE — client đang giữ version cũ sẽ bị 409 ở lần ghi kế tiếp và phải tải lại.
 * Việc dọn `PENDING_CONFIRM` không nằm trong lọc (chờ xác nhận không tính quá hạn).
 * @param now Mốc so với `dueAt`. Mặc định thời điểm gọi. Test truyền giờ cố định.
 * @returns Số việc dọn và việc sửa vừa gắn cờ trong lượt này (không phải tổng đang quá hạn).
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

/**
 * Quét định kỳ. Mặc định 30 giây/lần nên cờ bật không quá khoảng một phút sau ngưỡng
 * (SC-housekeeping-04), cộng thêm thời gian một lượt quét.
 *
 * Nếu lượt trước chưa xong thì bỏ qua lượt mới (`running`), không xếp hàng.
 * Lỗi được `console.error`, không làm chết process. Timer không `unref` — giữ process sống
 * cùng HTTP server cho đến khi `shutdown` gọi hàm trả về.
 * @param intervalMs Khoảng cách giữa hai lần gọi. Test có thể truyền số nhỏ.
 * @returns Hàm hủy timer. Gọi một lần khi tắt server.
 */
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
