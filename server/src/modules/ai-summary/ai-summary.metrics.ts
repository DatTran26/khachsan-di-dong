import { prisma } from '../../lib/prisma.js';
import { getSummary, listOverdueTasks } from '../dashboard/dashboard.service.js';
import type { PeriodRange } from './ai-summary.period.js';

/**
 * Số liệu tổng hợp của kỳ tại thời điểm T (FR-ai-ops-summary-002).
 * CHỈ đếm / tỷ lệ + số phòng — không đọc bảng lượt lưu trú, không có tên khách, không gửi nhật ký thô (NFR-002, BR-002).
 * - Trạng thái phòng / việc đang mở / quá hạn: ảnh chụp tại T (cùng nguồn với dashboard để đối soát).
 * - Hoạt động trong kỳ: đếm theo loại thao tác trong nhật ký [đầu kỳ, cuối kỳ].
 */

/** Thao tác vận hành tính là "hoạt động" của kỳ (đăng nhập, quản lý tài khoản, tạo tóm tắt… không tính). */
export const ACTIVITY_LABELS = {
  'stay.check_in': 'Nhận phòng',
  'stay.check_out': 'Trả phòng',
  'housekeeping.task_created': 'Việc dọn được tạo',
  'housekeeping.task_completed': 'Lượt báo dọn xong',
  'housekeeping.task_confirmed': 'Phòng được xác nhận sạch',
  'housekeeping.task_returned': 'Việc dọn bị trả lại',
  'housekeeping.task_overdue': 'Việc dọn bị quá hạn',
  'maintenance.reported': 'Báo hỏng',
  'maintenance.completed': 'Sửa xong',
  'maintenance.task_overdue': 'Việc sửa bị quá hạn',
  'room.out_of_service': 'Đặt ngừng phục vụ',
  'room.back_in_service': 'Mở lại phục vụ',
} as const;

export type ActivityAction = keyof typeof ACTIVITY_LABELS;

export interface AttentionItem {
  type: 'HOUSEKEEPING_OVERDUE' | 'MAINTENANCE_OVERDUE' | 'OUT_OF_SERVICE';
  roomId: string;
  roomNumber: string;
  taskId?: string;
  text: string; // câu hiển thị, dựng theo quy tắc
}

export interface PeriodMetrics {
  rooms: {
    total: number;
    occupied: number;
    vacant: number;
    ready: number;
    dirty: number;
    cleaning: number;
    pendingInspection: number;
    clean: number;
    outOfService: number;
    occupancyRate: number | null; // null = không áp dụng (mẫu số 0)
  };
  openTasks: {
    housekeeping: { unassigned: number; assigned: number; inProgress: number; pendingConfirm: number };
    maintenance: { open: number; inProgress: number };
    overdueHousekeeping: number;
    overdueMaintenance: number;
  };
  activity: Record<ActivityAction, number>;
}

export async function buildPeriodMetrics(range: PeriodRange) {
  const [summary, overdue, outOfServiceRooms, housekeepingGroups, maintenanceGroups, activityGroups] = await Promise.all([
    getSummary(),
    listOverdueTasks(),
    prisma.room.findMany({
      where: { service: 'OUT_OF_SERVICE' },
      select: { id: true, number: true },
      orderBy: [{ floor: 'asc' }, { number: 'asc' }],
    }),
    prisma.housekeepingTask.groupBy({ by: ['status'], where: { status: { not: 'DONE' } }, _count: true }),
    prisma.maintenanceTask.groupBy({ by: ['status'], where: { status: { in: ['OPEN', 'IN_PROGRESS'] } }, _count: true }),
    prisma.auditLog.groupBy({
      by: ['action'],
      where: {
        action: { in: Object.keys(ACTIVITY_LABELS) },
        occurredAt: { gte: range.start, lte: range.end },
      },
      _count: true,
    }),
  ]);

  const hk = Object.fromEntries(housekeepingGroups.map((g) => [g.status, g._count]));
  const mt = Object.fromEntries(maintenanceGroups.map((g) => [g.status, g._count]));
  const activity = Object.fromEntries(Object.keys(ACTIVITY_LABELS).map((a) => [a, 0])) as Record<ActivityAction, number>;
  for (const g of activityGroups) activity[g.action as ActivityAction] = g._count;

  const metrics: PeriodMetrics = {
    rooms: {
      total: summary.totalRooms,
      occupied: summary.occupied,
      vacant: summary.totalRooms - summary.occupied,
      ready: summary.ready,
      dirty: summary.cleaning.DIRTY,
      cleaning: summary.cleaning.CLEANING,
      pendingInspection: summary.cleaning.PENDING_INSPECTION,
      clean: summary.cleaning.CLEAN,
      outOfService: summary.outOfService,
      occupancyRate: summary.occupancy.rate,
    },
    openTasks: {
      housekeeping: {
        unassigned: hk.UNASSIGNED ?? 0,
        assigned: hk.ASSIGNED ?? 0,
        inProgress: hk.IN_PROGRESS ?? 0,
        pendingConfirm: hk.PENDING_CONFIRM ?? 0,
      },
      maintenance: { open: mt.OPEN ?? 0, inProgress: mt.IN_PROGRESS ?? 0 },
      overdueHousekeeping: summary.overdue.housekeeping,
      overdueMaintenance: summary.overdue.maintenance,
    },
    activity,
  };

  // Việc cần chú ý theo QUY TẮC (FR-007, FR-012, BR-008) — không phụ thuộc AI.
  const attention: AttentionItem[] = [
    ...overdue.map((t) => ({
      type: t.type === 'HOUSEKEEPING' ? ('HOUSEKEEPING_OVERDUE' as const) : ('MAINTENANCE_OVERDUE' as const),
      roomId: t.roomId,
      roomNumber: t.roomNumber,
      taskId: t.taskId,
      text: `${t.type === 'HOUSEKEEPING' ? 'Việc dọn' : 'Việc sửa'} phòng ${t.roomNumber} quá hạn`,
    })),
    ...outOfServiceRooms.map((r) => ({
      type: 'OUT_OF_SERVICE' as const,
      roomId: r.id,
      roomNumber: r.number,
      text: `Phòng ${r.number} đang ngừng phục vụ`,
    })),
  ];

  const hasActivity = Object.values(activity).some((n) => n > 0);
  return { metrics, attention, hasActivity };
}
