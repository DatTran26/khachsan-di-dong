import 'package:flutter/material.dart';
import '../../models/user.dart';

/// Một mục điều hướng. Quyền xem bám đúng phân quyền API phía BE:
/// - Tổng quan (`/dashboard/summary`), Lưu trú (`/stays`): quản lý + lễ tân.
/// - Dọn phòng (`/housekeeping/tasks`): quản lý + nhân viên.
/// - Nhật ký (`/audit-logs`): chỉ quản lý.
/// - Tài khoản (`/users`): quản lý + lễ tân.
class NavItem {
  final String path;
  final String label;
  final String title; // tiêu đề trên thanh đầu trang
  final IconData icon;
  final IconData selectedIcon;

  const NavItem(
      this.path, this.label, this.title, this.icon, this.selectedIcon);
}

const _dashboard = NavItem('/dashboard', 'Tổng quan', 'Tổng quan',
    Icons.grid_view_outlined, Icons.grid_view_rounded);
const _rooms =
    NavItem('/phong', 'Phòng', 'Phòng', Icons.bed_outlined, Icons.bed_rounded);
const _stays = NavItem(
    '/luot-o', 'Lưu trú', 'Lưu trú', Icons.key_outlined, Icons.key_rounded);
const _housekeeping = NavItem('/don-phong', 'Dọn phòng', 'Dọn phòng',
    Icons.cleaning_services_outlined, Icons.cleaning_services_rounded);
const _maintenance = NavItem('/bao-tri', 'Bảo trì', 'Bảo trì',
    Icons.build_outlined, Icons.build_rounded);
const _users = NavItem('/tai-khoan', 'Tài khoản', 'Tài khoản',
    Icons.manage_accounts_outlined, Icons.manage_accounts_rounded);
const _audit = NavItem('/nhat-ky', 'Nhật ký', 'Nhật ký thay đổi',
    Icons.history_rounded, Icons.history_rounded);

// Nhân viên dùng mobile: nhãn theo công việc của họ.
const _staffHousekeeping = NavItem('/don-phong', 'Việc dọn', 'Việc dọn của tôi',
    Icons.cleaning_services_outlined, Icons.cleaning_services_rounded);
const _staffMaintenance = NavItem('/bao-tri', 'Việc sửa', 'Việc sửa',
    Icons.build_outlined, Icons.build_rounded);

List<NavItem> navItemsFor(UserRole? role) {
  switch (role) {
    case UserRole.manager:
      return const [
        _dashboard,
        _rooms,
        _stays,
        _housekeeping,
        _maintenance,
        _users,
        _audit
      ];
    case UserRole.receptionist:
      return const [_dashboard, _rooms, _stays, _maintenance, _users];
    case UserRole.staff:
      return const [_staffHousekeeping, _staffMaintenance, _rooms];
    case null:
      return const [];
  }
}

String homeFor(UserRole? role) =>
    role == UserRole.staff ? '/don-phong' : '/dashboard';

bool canOpen(UserRole? role, String path) =>
    navItemsFor(role).any((n) => path.startsWith(n.path));

String titleFor(UserRole? role, String path) {
  for (final n in navItemsFor(role)) {
    if (path.startsWith(n.path)) return n.title;
  }
  return 'Khách Sạn Di Động';
}
