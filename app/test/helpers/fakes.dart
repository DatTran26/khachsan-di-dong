import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:khachsan_di_dong/features/audit/providers/audit_provider.dart';
import 'package:khachsan_di_dong/features/auth/providers/auth_provider.dart';
import 'package:khachsan_di_dong/features/dashboard/providers/dashboard_provider.dart';
import 'package:khachsan_di_dong/features/housekeeping/providers/housekeeping_provider.dart';
import 'package:khachsan_di_dong/features/maintenance/providers/maintenance_provider.dart';
import 'package:khachsan_di_dong/features/rooms/providers/rooms_provider.dart';
import 'package:khachsan_di_dong/features/stays/providers/stays_provider.dart';
import 'package:khachsan_di_dong/features/users/providers/users_provider.dart';
import 'package:khachsan_di_dong/models/room.dart';
import 'package:khachsan_di_dong/models/user.dart';

// Notifier giả: giữ nguyên state được đưa vào, không gọi API hay socket.
// `implements` + noSuchMethod để không chạy constructor thật (constructor thật tự gọi load()).

class FakeAuth extends StateNotifier<AuthState> implements AuthNotifier {
  FakeAuth(super.state);
  int logins = 0;
  @override
  Future<void> login(String phone, String password) async {
    logins++;
    state = AuthState(user: fakeUser(UserRole.manager), initialized: true);
  }
  @override
  String? get revokedMessage => null;
  @override
  dynamic noSuchMethod(Invocation i) => Future.value(false);
}

class FakeRooms extends StateNotifier<RoomsState> implements RoomsNotifier {
  FakeRooms(super.state);
  int loads = 0;
  @override
  Future<void> load() async => loads++;
  @override
  void setFilter(RoomsFilter f) => state = state.copyWith(filter: f);
  @override
  dynamic noSuchMethod(Invocation i) => Future.value();
}

class FakeSummary extends StateNotifier<DashboardSummaryState>
    implements DashboardSummaryNotifier {
  FakeSummary() : super(const DashboardSummaryState());
  @override
  dynamic noSuchMethod(Invocation i) => Future.value();
}

class FakeHousekeeping extends StateNotifier<HousekeepingState>
    implements HousekeepingNotifier {
  FakeHousekeeping(super.state);
  @override
  dynamic noSuchMethod(Invocation i) => Future.value();
}

class FakeMaintenance extends StateNotifier<MaintenanceState>
    implements MaintenanceNotifier {
  FakeMaintenance(super.state);
  @override
  dynamic noSuchMethod(Invocation i) => Future.value();
}

class FakeStays extends StateNotifier<StaysState> implements StaysNotifier {
  FakeStays(super.state);
  @override
  dynamic noSuchMethod(Invocation i) => Future.value();
}

class FakeUsers extends StateNotifier<UsersState> implements UsersNotifier {
  FakeUsers(super.state);
  @override
  dynamic noSuchMethod(Invocation i) => Future.value();
}

class FakeAudit extends StateNotifier<AuditState> implements AuditNotifier {
  FakeAudit(super.state);
  @override
  dynamic noSuchMethod(Invocation i) => Future.value();
}

AppUser fakeUser(UserRole role) => AppUser(
      id: 'u1',
      phone: '0900000000',
      fullName: 'Nguyễn Văn An',
      role: role,
      status: AccountStatus.active,
      mustChangePassword: false,
      onDuty: true,
      version: 1,
      createdAt: DateTime(2026, 10, 1),
    );

Room fakeRoom(
  String number, {
  int floor = 1,
  OccupancyStatus occupancy = OccupancyStatus.vacant,
  CleaningStatus cleaning = CleaningStatus.clean,
  ServiceStatus service = ServiceStatus.inService,
}) =>
    Room(
      id: 'room-$number',
      number: number,
      floor: floor,
      roomType: const RoomType(id: 't1', name: 'Đôi'),
      occupancy: occupancy,
      cleaning: cleaning,
      service: service,
      isReady: occupancy == OccupancyStatus.vacant &&
          cleaning == CleaningStatus.clean &&
          service == ServiceStatus.inService,
      version: 1,
      updatedAt: DateTime(2026, 10, 17, 9),
    );

/// Ghi đè mọi provider có gọi API bằng state cho trước.
List<Override> fakeOverrides({
  UserRole role = UserRole.manager,
  RoomsState rooms = const RoomsState(),
  HousekeepingState housekeeping = const HousekeepingState(),
  MaintenanceState maintenance = const MaintenanceState(),
  StaysState stays = const StaysState(),
  UsersState users = const UsersState(),
  AuditState audit = const AuditState(),
  bool online = true,
  FakeRooms? roomsNotifier,
}) =>
    [
      authProvider.overrideWith((ref) =>
          FakeAuth(AuthState(user: fakeUser(role), initialized: true))),
      roomsProvider.overrideWith((ref) => roomsNotifier ?? FakeRooms(rooms)),
      isOnlineProvider.overrideWithValue(online),
      dashboardSummaryProvider.overrideWith((ref) => FakeSummary()),
      housekeepingProvider.overrideWith((ref) => FakeHousekeeping(housekeeping)),
      maintenanceProvider.overrideWith((ref) => FakeMaintenance(maintenance)),
      staysProvider.overrideWith((ref) => FakeStays(stays)),
      usersProvider.overrideWith((ref) => FakeUsers(users)),
      auditProvider.overrideWith((ref) => FakeAudit(audit)),
    ];

/// Đặt kích thước "màn hình" cho test và trả về sau khi xong.
void setScreen(WidgetTester tester, Size size, {double textScale = 1}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
}

/// Dựng [child] trong MaterialApp + ProviderScope (+ GoRouter ở [path] khi cần router).
Future<void> pumpScreen(
  WidgetTester tester,
  Widget child, {
  List<Override> overrides = const [],
  String path = '/',
  Widget Function(Widget child)? shell,
}) async {
  final router = GoRouter(
    initialLocation: path,
    routes: [
      ShellRoute(
        builder: (_, __, c) => shell?.call(c) ?? Scaffold(body: c),
        routes: [
          for (final p in {
            path,
            '/dashboard',
            '/phong',
            '/luot-o',
            '/don-phong',
            '/bao-tri',
            '/tai-khoan',
            '/nhat-ky',
          })
            GoRoute(path: p, builder: (_, __) => child),
        ],
      ),
    ],
  );
  await tester.pumpWidget(ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(routerConfig: router),
  ));
  await tester.pump();
}
