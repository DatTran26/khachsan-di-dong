/**
 * Câu chữ hiển thị cho người dùng — lấy nguyên văn từ docs (không tự đặt lời mới khi docs đã có):
 * - auth-roles brainstorm mục 7.2 (wording đã chốt, FR-auth-roles-018)
 * - realtime-sync / audit-log error matrix
 * Câu nào docs chưa có được đánh dấu "(bổ sung)" để nhóm duyệt.
 */
export const MSG = {
  // auth-roles 7.2
  invalidCredentials: 'Số điện thoại hoặc mật khẩu chưa đúng. Vui lòng thử lại.',
  accountLocked: 'Tài khoản của bạn đang bị khóa. Vui lòng liên hệ quản lý để được mở lại.',
  sessionExpired: 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
  weakPassword: 'Mật khẩu mới cần ít nhất 8 ký tự, gồm cả chữ và số.',
  phoneTaken: 'Số điện thoại này đã có tài khoản. Vui lòng kiểm tra lại.',
  forbidden: 'Bạn không có quyền thực hiện thao tác này.',
  lastManagerLock: 'Không thể khóa — đây là tài khoản quản lý cuối cùng.',
  mustChangePassword: 'Bạn đang dùng mật khẩu tạm — vui lòng đặt mật khẩu mới để tiếp tục.',
  sessionRevoked: 'Tài khoản vừa đăng nhập trên thiết bị khác (hoặc đã bị khóa) — phiên này đã kết thúc.',
  passwordChanged: 'Đổi mật khẩu thành công.',
  accountCreated: (fullName: string, tempPassword: string) =>
    `Đã tạo tài khoản cho ${fullName}. Mật khẩu tạm: ${tempPassword} — hãy chuyển cho nhân viên.`,
  accountLockedDone: (fullName: string) => `Đã khóa tài khoản ${fullName}.`,
  accountUnlocked: (tempPassword: string) => `Đã mở khóa tài khoản. Mật khẩu tạm mới: ${tempPassword}`,

  // room-catalog error matrix (mục 6)
  roomNumberTaken: (number: string) => `Số phòng ${number} đã tồn tại trong danh mục.`,
  roomDeleteBusy: 'Không thể xóa — phòng đang có khách / có việc đang mở.',
  roomDeleteHasHistory: "Phòng đã có lịch sử hoạt động — không xóa được. Hãy đặt 'Ngừng phục vụ' để rút phòng khỏi vận hành.",
  outOfServiceReasonRequired: 'Vui lòng nhập lý do ngừng phục vụ.',
  // room-catalog E-006 = check-in-out E-005
  invalidState: 'Thao tác không hợp lệ ở trạng thái hiện tại. Tải lại để xem trạng thái mới nhất.',

  // check-in-out error matrix (mục 6)
  checkInOccupied: 'Phòng đang có khách — không thể nhận.',
  checkInNotClean: (cleaningLabel: string) => `Phòng chưa dọn xong (${cleaningLabel}) — không thể nhận.`,
  checkInOutOfService: 'Phòng đang ngừng phục vụ — không thể nhận.',
  guestNameRequired: 'Vui lòng nhập tên khách.',

  // housekeeping error matrix (mục 6)
  taskAlreadyTaken: 'Công việc này đã có người khác nhận.',
  noStaffOnDuty: 'Chưa có nhân viên buồng phòng đang trực — công việc đang chờ giao.',
  returnNoteRequired: 'Vui lòng nhập ghi chú khi trả lại công việc.',

  // realtime-sync E-002, audit-log E-005
  versionConflict: 'Dữ liệu vừa được người khác cập nhật — đã tải lại bản mới nhất.',
  notCompleted: 'Thao tác chưa hoàn tất — vui lòng thử lại.',

  // (bổ sung) — docs chưa có câu cho các tình huống này
  invalidPhone: 'Số điện thoại cần gồm 10 chữ số và bắt đầu bằng 0.',
  wrongCurrentPassword: 'Mật khẩu hiện tại chưa đúng.',
  lastManagerRole: 'Không thể đổi vai trò — đây là tài khoản quản lý cuối cùng.',
  cannotLockSelf: 'Bạn không thể tự khóa tài khoản của mình.',
  notLocked: 'Tài khoản này không ở trạng thái bị khóa.',
  passwordReset: (tempPassword: string) => `Đã đặt lại mật khẩu. Mật khẩu tạm mới: ${tempPassword}`,
  accountUpdated: 'Đã cập nhật tài khoản.',
  loginRequired: 'Vui lòng đăng nhập để tiếp tục.',
  resetLockedAccount: 'Tài khoản đang bị khóa — hãy dùng "Mở khóa" (hệ thống sẽ cấp mật khẩu tạm mới).',
  passwordResetByAdmin: 'Mật khẩu của bạn vừa được đặt lại — vui lòng đăng nhập bằng mật khẩu tạm.',
  occupiedConfirmRequired: 'Phòng đang có khách — khách vẫn ở hết kỳ. Xác nhận lại để đặt ngừng phục vụ.',
  roomHasOpenMaintenance: 'Phòng còn việc bảo trì đang mở — chưa thể mở lại phục vụ.',
  roomTypeInactive: 'Loại phòng này đang ngừng dùng — vui lòng chọn loại khác.',
  roomTypeTaken: (name: string) => `Loại phòng ${name} đã tồn tại.`,
  guestCountInvalid: 'Số người phải từ 1 trở lên.',
  // housekeeping / maintenance — thông báo đẩy (bổ sung)
  taskAssignedToYou: (room: string) => `Bạn có việc dọn mới: ${room}.`,
  taskPendingConfirm: (room: string) => `${room} đã dọn xong — chờ quản lý xác nhận.`,
  taskReturned: (room: string, note: string) => `Việc dọn ${room} bị trả lại: ${note}`,
  taskOverdue: (room: string) => `Việc dọn ${room} đã quá hạn.`,
  maintenanceOverdue: (room: string) => `Việc sửa ${room} đã quá hạn.`,
  maintenanceReported: (room: string) => `Có báo hỏng mới ở ${room}.`,
  maintenanceAlreadyOpen: 'Phòng này đang có việc bảo trì mở — vẫn đã ghi nhận báo hỏng mới.',
  assigneeNotOnDuty: 'Người được chọn không phải nhân viên buồng phòng–bảo trì đang trực.',
  maintenanceAssignedToOther: 'Việc này đã được giao cho người khác.',
  bulkRangeInvalid: 'Khoảng số phòng không hợp lệ — số đầu phải nhỏ hơn hoặc bằng số cuối, tối đa 100 phòng mỗi lần.',
  bulkCreated: (created: number, skipped: string[]) =>
    skipped.length
      ? `Đã tạo ${created} phòng. Bỏ qua ${skipped.length} số đã tồn tại: ${skipped.join(', ')}.`
      : `Đã tạo ${created} phòng.`,
} as const;
