import type { AuditEntityType } from '@prisma/client';

/**
 * Nhãn nghiệp vụ tiếng Việt cho nhật ký (NFR-audit-log-004) — quản lý đọc hiểu không cần giải thích kỹ thuật.
 * Mẫu dòng (audit-log brainstorm 7.3):
 *   "{giờ:phút ngày/tháng} · {họ tên} ({vai trò}) · {hành động} · {đối tượng} · {trục/trường}: {trước} → {sau}"
 */

export const ROLE_LABELS: Record<string, string> = {
  MANAGER: 'quản lý',
  RECEPTIONIST: 'lễ tân',
  STAFF: 'nv buồng phòng–bảo trì',
  SYSTEM: 'hệ thống',
};

export const ACTION_LABELS: Record<string, string> = {
  'auth.login': 'Đăng nhập',
  'auth.logout': 'Đăng xuất',
  'auth.session_expired': 'Hết phiên',
  'auth.session_replaced': 'Hủy phiên (đăng nhập nơi khác)',
  'auth.auto_locked': 'Khóa tài khoản (sai mật khẩu 5 lần)',
  'auth.password_changed': 'Đổi mật khẩu',
  'user.created': 'Tạo tài khoản',
  'user.updated': 'Sửa tài khoản',
  'user.locked': 'Khóa tài khoản',
  'user.unlocked': 'Mở khóa tài khoản',
  'user.password_reset': 'Đặt lại mật khẩu',
  'room_type.created': 'Thêm loại phòng',
  'room_type.updated': 'Sửa loại phòng',
  'room.created': 'Thêm phòng',
  'room.updated': 'Sửa phòng',
  'room.deleted': 'Xóa phòng',
  'room.status_change': 'Đổi trạng thái phòng',
  'room.out_of_service': 'Đặt ngừng phục vụ',
  'room.back_in_service': 'Gỡ ngừng phục vụ',
  'stay.check_in': 'Nhận phòng',
  'stay.check_out': 'Trả phòng',
  'housekeeping.task_created': 'Tạo việc dọn',
  'housekeeping.task_assigned': 'Giao việc dọn',
  'housekeeping.task_accepted': 'Nhận việc dọn',
  'housekeeping.task_rejected': 'Từ chối việc dọn',
  'housekeeping.task_completed': 'Báo dọn xong',
  'housekeeping.task_confirmed': 'Xác nhận phòng sạch',
  'housekeeping.task_returned': 'Trả lại việc dọn',
  'housekeeping.task_reassigned': 'Phân công lại việc dọn',
  'housekeeping.task_overdue': 'Việc dọn quá hạn',
  'maintenance.reported': 'Báo hỏng',
  'maintenance.claimed': 'Nhận việc sửa',
  'maintenance.completed': 'Sửa xong',
  'maintenance.cancelled': 'Hủy việc sửa',
  'maintenance.assigned': 'Chỉ định người sửa',
  'maintenance.task_overdue': 'Việc sửa quá hạn',
};

/** Nhãn trục / trường. Trường `status` đặt theo loại đối tượng (vd "việc dọn", "lượt lưu trú"). */
const FIELD_LABELS: Record<string, string> = {
  occupancy: 'lưu trú',
  cleaning: 'vệ sinh',
  service: 'bảo trì',
  number: 'số phòng',
  floor: 'tầng',
  roomType: 'loại phòng',
  reason: 'lý do ngừng phục vụ',
  assignee: 'người phụ trách',
  returnNote: 'ghi chú trả lại',
  cancelReason: 'lý do hủy',
  description: 'mô tả',
  overdue: 'quá hạn',
  fullName: 'họ tên',
  phone: 'số điện thoại',
  role: 'vai trò',
  onDuty: 'đang trực',
  name: 'tên',
  isActive: 'đang dùng',
};

const STATUS_FIELD_BY_ENTITY: Record<AuditEntityType, string> = {
  ROOM: 'trạng thái phòng',
  ROOM_TYPE: 'trạng thái loại phòng',
  STAY: 'lượt lưu trú',
  HOUSEKEEPING_TASK: 'việc dọn',
  MAINTENANCE_TASK: 'việc sửa',
  OUT_OF_SERVICE_HOLD: 'ngừng phục vụ',
  USER: 'trạng thái tài khoản',
  AI_SUMMARY: 'bản tóm tắt',
};

/** Giá trị enum → chữ. Cùng một mã có nghĩa khác nhau theo đối tượng (IN_PROGRESS: đang làm / đang sửa). */
const VALUE_LABELS: Record<string, string> = {
  VACANT: 'trống',
  OCCUPIED: 'đang ở',
  DIRTY: 'cần dọn',
  CLEANING: 'đang dọn',
  PENDING_INSPECTION: 'chờ kiểm tra',
  CLEAN: 'sạch',
  IN_SERVICE: 'bình thường',
  OUT_OF_SERVICE: 'ngừng phục vụ',
  PENDING_ACTIVATION: 'chờ kích hoạt',
  ACTIVE: 'hoạt động',
  LOCKED: 'bị khóa',
  MANAGER: 'quản lý',
  RECEPTIONIST: 'lễ tân',
  STAFF: 'nv buồng phòng–bảo trì',
  true: 'có',
  false: 'không',
};

const STATUS_BY_ENTITY: Partial<Record<AuditEntityType, Record<string, string>>> = {
  STAY: { OPEN: 'mở', CLOSED: 'đóng', CANCELLED: 'đã hủy' },
  HOUSEKEEPING_TASK: {
    UNASSIGNED: 'chờ giao',
    ASSIGNED: 'đã giao',
    IN_PROGRESS: 'đang làm',
    PENDING_CONFIRM: 'chờ xác nhận',
    DONE: 'hoàn tất',
  },
  MAINTENANCE_TASK: { OPEN: 'chờ nhận', IN_PROGRESS: 'đang sửa', DONE: 'hoàn tất', CANCELLED: 'đã hủy' },
};

export function fieldLabel(entityType: AuditEntityType, field: string): string {
  if (field === 'status') return STATUS_FIELD_BY_ENTITY[entityType];
  return FIELD_LABELS[field] ?? field;
}

export function valueLabel(entityType: AuditEntityType, field: string, value: string | null): string {
  if (value === null || value === '') return '—';
  if (field === 'status') return STATUS_BY_ENTITY[entityType]?.[value] ?? VALUE_LABELS[value] ?? value;
  return VALUE_LABELS[value] ?? value;
}

const TIME_FORMAT = new Intl.DateTimeFormat('vi-VN', {
  timeZone: 'Asia/Ho_Chi_Minh',
  hour: '2-digit',
  minute: '2-digit',
  day: '2-digit',
  month: '2-digit',
  hour12: false,
});

/** "14:32 05/10" theo giờ Việt Nam. */
export function formatTime(date: Date): string {
  const parts = Object.fromEntries(TIME_FORMAT.formatToParts(date).map((p) => [p.type, p.value]));
  return `${parts.hour}:${parts.minute} ${parts.day}/${parts.month}`;
}
