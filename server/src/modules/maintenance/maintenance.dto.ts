import type { MaintenanceTask, Room, User } from '@prisma/client';

type TaskWithRefs = MaintenanceTask & {
  room: Pick<Room, 'id' | 'number' | 'floor'>;
  reporter: Pick<User, 'id' | 'fullName' | 'role'>;
  assignee: Pick<User, 'id' | 'fullName'> | null;
};

export const maintenanceInclude = {
  room: { select: { id: true, number: true, floor: true } },
  reporter: { select: { id: true, fullName: true, role: true } },
  assignee: { select: { id: true, fullName: true } },
} as const;

/** Việc bảo trì trả cho client. `isOverdue` = đã bị cờ quá hạn và còn mở. */
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
