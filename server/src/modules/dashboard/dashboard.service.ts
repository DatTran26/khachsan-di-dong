import type { CleaningStatus } from '@prisma/client';
import { prisma } from '../../lib/prisma.js';
import { OVERDUE_STATUSES } from '../housekeeping/housekeeping.dto.js';

const roomRef = { select: { id: true, number: true } } as const;

/** Việc quá hạn đang mở, kèm phòng — để tô cờ đúng ô phòng (FR-room-dashboard-006) và làm "việc cần chú ý" (AI FR-012). */
export async function listOverdueTasks() {
  const [housekeeping, maintenance] = await Promise.all([
    prisma.housekeepingTask.findMany({
      where: { overdueFlaggedAt: { not: null }, status: { in: OVERDUE_STATUSES } },
      select: { id: true, room: roomRef },
      orderBy: { dueAt: 'asc' },
    }),
    prisma.maintenanceTask.findMany({
      where: { overdueFlaggedAt: { not: null }, status: { in: ['OPEN', 'IN_PROGRESS'] } },
      select: { id: true, room: roomRef },
      orderBy: { dueAt: 'asc' },
    }),
  ]);
  return [
    ...housekeeping.map((t) => ({ type: 'HOUSEKEEPING' as const, taskId: t.id, roomId: t.room.id, roomNumber: t.room.number })),
    ...maintenance.map((t) => ({ type: 'MAINTENANCE' as const, taskId: t.id, roomId: t.room.id, roomNumber: t.room.number })),
  ];
}

/**
 * Chỉ số tại thời điểm xem (room-dashboard): đang ở / sẵn sàng / cần dọn / ngừng phục vụ / việc quá hạn / lấp đầy.
 * Tính trực tiếp từ bảng — không lưu số liệu riêng nên luôn khớp dữ liệu đối soát.
 *
 * - "Cần dọn" CHỈ đếm `DIRTY` (đã chốt — room-dashboard PRD/URD); đang dọn / chờ kiểm tra trả riêng trong `cleaning`.
 * - Lấp đầy = phòng đang ở ÷ phòng có thể phục vụ × 100%; mẫu = 0 → `rate: null` ("không áp dụng").
 * - `overdue.tasks`: từng việc quá hạn + phòng → client tô cờ ô phòng; cập nhật tiếp qua sự kiện `*:task_updated`.
 */
export async function getSummary() {
  const [rooms, overdueTasks] = await Promise.all([
    prisma.room.findMany({ select: { occupancy: true, cleaning: true, service: true } }),
    listOverdueTasks(),
  ]);

  const cleaning: Record<CleaningStatus, number> = { DIRTY: 0, CLEANING: 0, PENDING_INSPECTION: 0, CLEAN: 0 };
  let occupied = 0;
  let ready = 0;
  let outOfService = 0;
  for (const room of rooms) {
    cleaning[room.cleaning] += 1;
    if (room.occupancy === 'OCCUPIED') occupied += 1;
    if (room.service === 'OUT_OF_SERVICE') outOfService += 1;
    if (room.occupancy === 'VACANT' && room.cleaning === 'CLEAN' && room.service === 'IN_SERVICE') ready += 1;
  }
  const serviceable = rooms.length - outOfService;
  const housekeepingOverdue = overdueTasks.filter((t) => t.type === 'HOUSEKEEPING').length;
  const maintenanceOverdue = overdueTasks.length - housekeepingOverdue;

  return {
    asOf: new Date(),
    totalRooms: rooms.length,
    occupied,
    ready,
    outOfService,
    cleaning,
    overdue: {
      housekeeping: housekeepingOverdue,
      maintenance: maintenanceOverdue,
      total: overdueTasks.length,
      tasks: overdueTasks,
    },
    occupancy: {
      occupied,
      serviceable,
      rate: serviceable === 0 ? null : Math.round((occupied / serviceable) * 1000) / 10,
    },
  };
}
