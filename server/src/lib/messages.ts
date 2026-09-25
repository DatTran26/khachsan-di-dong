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
} as const;
