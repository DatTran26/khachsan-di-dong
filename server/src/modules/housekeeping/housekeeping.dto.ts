import type { HousekeepingTask, Room, User } from '@prisma/client';

type TaskWithRefs = HousekeepingTask & {
  room: Pick<Room, 'id' | 'number' | 'floor'>;
  assignee: Pick<User, 'id' | 'fullName'> | null;
};

export const housekeepingInclude = {
  room: { select: { id: true, number: true, floor: true } },
  assignee: { select: { id: true, fullName: true } },
} as const;

/** Việc dọn trả cho client. `isOverdue` = đã bị cờ quá hạn và chưa hoàn tất (cờ tự gỡ khi hoàn tất — FR-008). */
export function toHousekeepingTaskDto(task: TaskWithRefs) {
  return {
    id: task.id,
    room: task.room,
    assignee: task.assignee,
    status: task.status,
    isOverdue: task.overdueFlaggedAt !== null && task.status !== 'DONE',
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
