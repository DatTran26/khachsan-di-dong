/// Vai trò app, khớp enum `Role` của server.
enum UserRole { manager, receptionist, staff }

/// Trạng thái tài khoản, khớp `AccountStatus` của server.
enum AccountStatus { pendingActivation, active, locked }

/// Nhãn và mã API của [UserRole].
extension UserRoleX on UserRole {
  /// Câu đầy đủ: Quản lý, Lễ tân, hoặc Nhân viên buồng phòng–bảo trì.
  String get label {
    switch (this) {
      case UserRole.manager:
        return 'Quản lý';
      case UserRole.receptionist:
        return 'Lễ tân';
      case UserRole.staff:
        return 'Nhân viên buồng phòng–bảo trì';
    }
  }

  /// Nhãn ngắn cho bảng, chip, thanh điều hướng.
  String get shortLabel => this == UserRole.staff ? 'Nhân viên' : label;

  /// Mã gửi/nhận API: `MANAGER`, `RECEPTIONIST`, `STAFF`.
  String get value {
    switch (this) {
      case UserRole.manager:
        return 'MANAGER';
      case UserRole.receptionist:
        return 'RECEPTIONIST';
      case UserRole.staff:
        return 'STAFF';
    }
  }

  /// Parse mã API. Giá trị lạ thành [UserRole.staff] — không ném.
  static UserRole fromString(String v) {
    switch (v) {
      case 'MANAGER':
        return UserRole.manager;
      case 'RECEPTIONIST':
        return UserRole.receptionist;
      default:
        return UserRole.staff;
    }
  }
}

/// Nhãn tiếng Việt và parse mã trạng thái tài khoản.
extension AccountStatusX on AccountStatus {
  /// Nhãn trên danh sách tài khoản.
  String get label {
    switch (this) {
      case AccountStatus.pendingActivation:
        return 'Chờ kích hoạt';
      case AccountStatus.active:
        return 'Hoạt động';
      case AccountStatus.locked:
        return 'Bị khóa';
    }
  }

  /// Parse mã API. Giá trị lạ thành chờ kích hoạt, không ném.
  static AccountStatus fromString(String v) {
    switch (v) {
      case 'ACTIVE':
        return AccountStatus.active;
      case 'LOCKED':
        return AccountStatus.locked;
      default:
        return AccountStatus.pendingActivation;
    }
  }
}

/// Tài khoản nhân viên trên client. Không có hash mật khẩu hay số lần đăng nhập sai.
class AppUser {
  final String id;
  final String phone;
  final String fullName;
  final UserRole role;
  final AccountStatus status;
  final bool mustChangePassword;
  final bool onDuty;
  final int version;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.phone,
    required this.fullName,
    required this.role,
    required this.status,
    required this.mustChangePassword,
    required this.onDuty,
    required this.version,
    required this.createdAt,
  });

  /// Dựng từ DTO `/auth/me` hoặc `/users`. Thiếu khóa bắt buộc thì ném khi ép kiểu.
  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        phone: json['phone'] as String,
        fullName: json['fullName'] as String,
        role: UserRoleX.fromString(json['role'] as String),
        status: AccountStatusX.fromString(json['status'] as String),
        mustChangePassword: json['mustChangePassword'] as bool,
        onDuty: json['onDuty'] as bool,
        version: json['version'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  /// Bản sao. Không đổi [id], [phone], [createdAt]. Trường null giữ giá trị cũ.
  AppUser copyWith({
    String? fullName,
    UserRole? role,
    AccountStatus? status,
    bool? mustChangePassword,
    bool? onDuty,
    int? version,
  }) =>
      AppUser(
        id: id,
        phone: phone,
        fullName: fullName ?? this.fullName,
        role: role ?? this.role,
        status: status ?? this.status,
        mustChangePassword: mustChangePassword ?? this.mustChangePassword,
        onDuty: onDuty ?? this.onDuty,
        version: version ?? this.version,
        createdAt: createdAt,
      );
}
