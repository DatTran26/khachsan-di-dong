import type { HousekeepingTask, HousekeepingTaskStatus, Room, User } from '@prisma/client';

type TaskWithRefs = HousekeepingTask & {
  room: Pick<Room, 'id' | 'number' | 'floor'>;
  assignee: Pick<User, 'id' | 'fullName'> | null;
};

export const housekeepingInclude = {
  room: { select: { id: true, number: true, floor: true } },
  assignee: { select: { id: true, fullName: true } },
} as const;

/**
 * Trạng thái còn tính quá hạn: nhân viên chưa báo xong. Chờ xác nhận / hoàn tất thì không — BR-002 chỉ đo tới mốc
 * nhân viên báo hoàn tất, thời gian chờ quản lý xác nhận không tính. Bị trả lại (về đang làm) thì cờ hiện lại.
 */
export const OVERDUE_STATUSES: HousekeepingTaskStatus[] = ['UNASSIGNED', 'ASSIGNED', 'IN_PROGRESS'];

/** Việc dọn trả cho client. `isOverdue` = đã bị cờ quá hạn và nhân viên chưa báo xong (cờ tự gỡ — FR-010, BR-002). */
export function toHousekeepingTaskDto(task: TaskWithRefs) {
  return {
    id: task.id,
    room: task.room,
    assignee: task.assignee,
    status: task.status,
    isOverdue: task.overdueFlaggedAt !== null && OVERDUE_STATUSES.includes(task.status),
    dueAt: task.dueAt,
    returnNote: task.returnNote,
    photoRound: task.photoRound, // lượt ảnh nghiệm thu hiện tại (tăng khi bị trả lại)
    hasIssue: task.hasIssue, // nhân viên đánh dấu bất thường lúc báo xong
    createdAt: task.createdAt,
    assignedAt: task.assignedAt,
    startedAt: task.startedAt,
    completedAt: task.completedAt,
    confirmedAt: task.confirmedAt,
    version: task.version,
  };
}
