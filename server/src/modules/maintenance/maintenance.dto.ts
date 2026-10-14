import type { MaintenanceTask, Room, User } from '@prisma/client';

type TaskWithRefs = MaintenanceTask & {
  room: Pick<Room, 'id' | 'number' | 'floor'>;
  reporter: Pick<User, 'id' | 'fullName' | 'role'>;
  assignee: Pick<User, 'id' | 'fullName'> | null;
};

/**
 * Include khi đọc việc sửa ra DTO. Người báo có thêm `role` để UI biết ai đã báo;
 * người xử lý chỉ id và họ tên.
 */
export const maintenanceInclude = {
  room: { select: { id: true, number: true, floor: true } },
  reporter: { select: { id: true, fullName: true, role: true } },
  assignee: { select: { id: true, fullName: true } },
} as const;

/**
 * Việc bảo trì trả cho client.
 *
 * `isOverdue` đúng khi đã có `overdueFlaggedAt` và status còn `OPEN` hoặc `IN_PROGRESS`.
 * `DONE` và `CANCELLED` không hiện quá hạn dù cột cờ còn. `dueAt` null khi ngưỡng quá hạn tắt lúc báo.
 * @param task Bản ghi đã include theo `maintenanceInclude`.
 * @returns DTO có `version` cho nhận, xong, hủy, chỉ định.
 */
export function toMaintenanceTaskDto(task: TaskWithRefs) {
  return {
    id: task.id,
    room: task.room,
    description: task.description,
    location: task.location,
    status: task.status,
    reporter: task.reporter,
    assignee: task.assignee,
    cancelReason: task.cancelReason,
    isOverdue: task.overdueFlaggedAt !== null && (task.status === 'OPEN' || task.status === 'IN_PROGRESS'),
    dueAt: task.dueAt,
    createdAt: task.createdAt,
    updatedAt: task.updatedAt,
    version: task.version,
  };
}
