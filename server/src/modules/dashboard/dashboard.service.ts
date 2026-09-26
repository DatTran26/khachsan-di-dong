import type { CleaningStatus } from '@prisma/client';
import { prisma } from '../../lib/prisma.js';

/**
 * Chỉ số tại thời điểm xem (room-dashboard): đang ở / sẵn sàng / cần dọn / ngừng phục vụ / việc quá hạn / lấp đầy.
 * Tính trực tiếp từ bảng — không lưu số liệu riêng nên luôn khớp dữ liệu đối soát.
 *
 * - "Cần dọn" chưa chốt đếm chỉ DIRTY hay mọi phòng chưa sạch (room-dashboard OQ-2) → trả đủ theo từng trạng thái
 *   vệ sinh để giao diện chọn, không tự quyết thay nhóm.
 * - Lấp đầy = phòng đang ở ÷ phòng có thể phục vụ × 100%; mẫu = 0 → `rate: null` ("không áp dụng").
 */
export async function getSummary() {
  const [rooms, housekeepingOverdue, maintenanceOverdue] = await Promise.all([
    prisma.room.findMany({ select: { occupancy: true, cleaning: true, service: true } }),
    prisma.housekeepingTask.count({ where: { overdueFlaggedAt: { not: null }, status: { not: 'DONE' } } }),
    prisma.maintenanceTask.count({ where: { overdueFlaggedAt: { not: null }, status: { in: ['OPEN', 'IN_PROGRESS'] } } }),
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
      total: housekeepingOverdue + maintenanceOverdue,
    },
    occupancy: {
      occupied,
      serviceable,
      rate: serviceable === 0 ? null : Math.round((occupied / serviceable) * 1000) / 10,
    },
  };
}
