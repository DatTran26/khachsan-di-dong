import type { HousekeepingTask, Room, User } from '@prisma/client';

type TaskWithRefs = HousekeepingTask & {
  room: Pick<Room, 'id' | 'number' | 'floor'>;
  assignee: Pick<User, 'id' | 'fullName'> | null;
};

/**
 * `include` Prisma dùng chung khi đọc việc dọn ra DTO.
 * Phòng chỉ lấy id, số, tầng. Người được giao chỉ id và họ tên — không có SĐT hay hash.
 */
export const housekeepingInclude = {
  room: { select: { id: true, number: true, floor: true } },
  assignee: { select: { id: true, fullName: true } },
} as const;

/**
 * Việc dọn trả cho client.
 *
 * `isOverdue` đúng khi đã có `overdueFlaggedAt` và status khác `DONE`. Chuyển `DONE`
 * không xóa cột cờ; DTO tự coi là không quá hạn (FR-008). `returnNote` của lần trả gần nhất vẫn nằm trong DTO.
 * @param task Bản ghi đã include phòng và assignee theo `housekeepingInclude`.
 * @returns DTO có `version` để client gửi lại khi nhận/báo xong/xác nhận.
 */
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
