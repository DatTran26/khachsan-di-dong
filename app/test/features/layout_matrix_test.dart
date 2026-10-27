import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khachsan_di_dong/features/audit/screens/audit_screen.dart';
import 'package:khachsan_di_dong/features/dashboard/screens/dashboard_screen.dart';
import 'package:khachsan_di_dong/features/housekeeping/providers/housekeeping_provider.dart';
import 'package:khachsan_di_dong/features/housekeeping/screens/housekeeping_screen.dart';
import 'package:khachsan_di_dong/features/maintenance/screens/maintenance_screen.dart';
import 'package:khachsan_di_dong/features/rooms/providers/rooms_provider.dart';
import 'package:khachsan_di_dong/features/rooms/screens/rooms_screen.dart';
import 'package:khachsan_di_dong/features/shell/screens/app_shell.dart';
import 'package:khachsan_di_dong/features/stays/providers/stays_provider.dart';
import 'package:khachsan_di_dong/features/stays/screens/stays_screen.dart';
import 'package:khachsan_di_dong/features/users/providers/users_provider.dart';
import 'package:khachsan_di_dong/features/users/screens/users_screen.dart';
import 'package:khachsan_di_dong/models/housekeeping_task.dart';
import 'package:khachsan_di_dong/models/room.dart';
import 'package:khachsan_di_dong/models/stay.dart';
import 'package:khachsan_di_dong/models/user.dart';

import '../helpers/fakes.dart';

// Ma trận bố cục: mỗi màn (có dữ liệu) × điện thoại / tablet / web × cỡ chữ 100% / 200%
// phải dựng được mà không tràn. Thay cho phần kiểm thủ công kích thước màn hình.

final _rooms = RoomsState(rooms: [
  for (var f = 1; f <= 3; f++)
    for (var n = 1; n <= 4; n++)
      fakeRoom('${f}0$n',
          floor: f,
          occupancy:
              n == 1 ? OccupancyStatus.occupied : OccupancyStatus.vacant,
          cleaning: n == 2 ? CleaningStatus.pendingInspection : CleaningStatus.clean,
          service: n == 4 ? ServiceStatus.outOfService : ServiceStatus.inService),
]);

final _stays = StaysState(stays: [
  Stay(
    id: 's1',
    room: const StayRoomRef(id: 'room-101', number: '101', floor: 1),
    guestName: 'Trần Thị Bình Phương',
    guestCount: 2,
    status: 'ACTIVE',
    checkedInAt: DateTime(2026, 10, 16, 14),
    expectedCheckout: DateTime(2026, 10, 16, 12),
    note: 'Khách cần thêm gối và nước suối',
    version: 1,
  ),
]);

final _tasks = HousekeepingState(tasks: [
  for (final st in HousekeepingStatus.values)
    HousekeepingTask(
      id: 'h-${st.name}',
      room: const HousekeepingRoomRef(id: 'room-102', number: '102', floor: 1),
      assignee:
          const HousekeepingAssigneeRef(id: 'u1', fullName: 'Nguyễn Văn An'),
      status: st,
      isOverdue: st == HousekeepingStatus.inProgress,
      dueAt: DateTime.now().add(const Duration(minutes: 30)),
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      version: 1,
    ),
]);

final _users = UsersState(users: [
  for (final r in UserRole.values) fakeUser(r),
]);

const _sizes = {
  'điện thoại': Size(360, 800),
  'tablet': Size(768, 1024),
  'web': Size(1280, 800),
};

final _screens = <String, (Widget, UserRole)>{
  'Tổng quan': (const DashboardScreen(), UserRole.manager),
  'Phòng': (const RoomsScreen(), UserRole.manager),
  'Lưu trú': (const StaysScreen(), UserRole.receptionist),
  'Dọn phòng (quản lý)': (const HousekeepingScreen(), UserRole.manager),
  'Dọn phòng (nhân viên)': (const HousekeepingScreen(), UserRole.staff),
  'Bảo trì': (const MaintenanceScreen(), UserRole.receptionist),
  'Tài khoản': (const UsersScreen(), UserRole.manager),
  'Nhật ký': (const AuditScreen(), UserRole.manager),
};

void main() {
  for (final MapEntry(key: name, value: (screen, role)) in _screens.entries) {
    for (final MapEntry(key: label, value: size) in _sizes.entries) {
      for (final scale in [1.0, 2.0]) {
        testWidgets('$name · $label · chữ ${(scale * 100).round()}%',
            (tester) async {
          setScreen(tester, size, textScale: scale);
          await pumpScreen(
            tester,
            screen,
            path: '/phong',
            overrides: fakeOverrides(
              role: role,
              rooms: _rooms,
              stays: _stays,
              housekeeping: _tasks,
              users: _users,
            ),
            shell: (c) => AppShell(child: c),
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
