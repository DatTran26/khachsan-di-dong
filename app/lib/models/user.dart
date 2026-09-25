enum UserRole { manager, receptionist, staff }

enum AccountStatus { pendingActivation, active, locked }

extension UserRoleX on UserRole {
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

extension AccountStatusX on AccountStatus {
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
