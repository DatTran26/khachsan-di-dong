import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khachsan_di_dong/core/realtime/socket_service.dart';
import 'package:khachsan_di_dong/features/auth/providers/auth_provider.dart';
import 'package:khachsan_di_dong/features/dashboard/providers/dashboard_provider.dart';
import 'package:khachsan_di_dong/features/rooms/providers/rooms_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fakes.dart';

/// Chỉ số Tổng quan chỉ dành cho quản lý + lễ tân — nhân viên / chưa biết vai trò không gọi API (BE trả 403).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final (name, user) in [
    ('nhân viên', fakeUser('STAFF')),
    ('chưa biết vai trò', null),
  ]) {
    test('$name: không tải chỉ số, không nghe realtime', () {
      final container = ProviderContainer(overrides: [
        authProvider.overrideWith((ref) => FakeAuth(user)),
        roomsProvider.overrideWith((ref) => FakeRooms(const [])),
      ]);
      addTearDown(container.dispose);

      final notifier = container.read(dashboardSummaryProvider.notifier);
      expect(notifier.enabled, isFalse);
      // load() chạy thật sẽ bật isLoading ngay, trước khi gọi API.
      expect(container.read(dashboardSummaryProvider).isLoading, isFalse);
      expect(socketService.onTaskChanged, isNull);
    });
  }

  Map<String, dynamic> body(int occupied) => {
        'data': {'totalRooms': 50, 'occupied': occupied}
      };

  test('lượt tải cũ về sau lượt mới → bị bỏ, không ghi đè số mới', () async {
    final calls = <Completer<Map<String, dynamic>>>[];
    final notifier = DashboardSummaryNotifier(fetch: () {
      final c = Completer<Map<String, dynamic>>();
      calls.add(c);
      return c.future;
    });
    addTearDown(notifier.dispose);

    final second = notifier.load(silent: true); // lượt 1 do constructor gọi đang chờ
    calls[1].complete(body(20));
    await second;
    calls[0].complete(body(7));
    await Future<void>.delayed(Duration.zero);

    expect(notifier.state.summary.occupied, 20);
    expect(notifier.state.isLoading, isFalse);
  });

  test('dữ liệu sai dạng → báo lỗi có nút thử lại, không kẹt ở đang tải', () async {
    final notifier =
        DashboardSummaryNotifier(fetch: () async => {'data': 'sai dạng'});
    addTearDown(notifier.dispose);
    await Future<void>.delayed(Duration.zero);

    expect(notifier.state.isLoading, isFalse);
    expect(notifier.state.error, 'Không tải được dữ liệu dashboard. Thử lại.');
  });
}
