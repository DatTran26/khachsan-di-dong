import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khachsan_di_dong/features/dashboard/providers/dashboard_provider.dart';
import 'package:khachsan_di_dong/features/dashboard/screens/dashboard_screen.dart';
import 'package:khachsan_di_dong/features/rooms/providers/rooms_provider.dart';

import 'support/fakes.dart';

/// 101 đang ở, 102 cần dọn + quá hạn, 103 ngừng phục vụ, 104 và 201 sẵn sàng.
final _rooms = [
  fakeRoom('101', occupancy: 'OCCUPIED'),
  fakeRoom('102', cleaning: 'DIRTY'),
  fakeRoom('103', service: 'OUT_OF_SERVICE'),
  fakeRoom('104'),
  fakeRoom('201'),
];

DashboardSummary _summary({int occupied = 1, int serviceable = 3}) =>
    DashboardSummary.fromJson({
      'asOf': '2026-10-13T00:00:00.000Z',
      'totalRooms': 4,
      'occupied': occupied,
      'ready': 1,
      'outOfService': 1,
      'cleaning': {
        'DIRTY': 1,
        'CLEANING': 0,
        'PENDING_INSPECTION': 0,
        'CLEAN': 3
      },
      'overdue': {
        'housekeeping': 1,
        'maintenance': 0,
        'total': 1,
        'tasks': [
          {
            'type': 'HOUSEKEEPING',
            'taskId': 't1',
            'roomId': 'r102',
            'roomNumber': '102'
          },
        ],
      },
      'occupancy': {
        'occupied': occupied,
        'serviceable': serviceable,
        'rate': serviceable == 0 ? null : 33.3,
      },
    });

Future<void> _pump(WidgetTester tester, DashboardSummary summary) async {
  tester.view.physicalSize = const Size(1400, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      roomsProvider.overrideWith((ref) => FakeRooms(_rooms)),
      dashboardSummaryProvider
          .overrideWith((ref) => FakeDashboardSummary(summary)),
    ],
    child: const MaterialApp(home: Scaffold(body: DashboardScreen())),
  ));
  await tester.pump();
}

Finder _tile(String number) => find.text(number);

void main() {
  test('DashboardSummary giữ từng việc quá hạn theo phòng', () {
    final s = _summary();
    expect(s.overdueRoomIds, {'r102'});
    expect(s.overdueTasksOf('r102').single.isHousekeeping, isTrue);
    expect(s.overdueTasksOf('r101'), isEmpty);
  });

  test('tỷ lệ lấp đầy: mẫu số 0 → "Không áp dụng", thập phân kiểu Việt', () {
    expect(_summary(serviceable: 0).occupancyRateLabel, 'Không áp dụng');
    expect(_summary().occupancyRateLabel, '33,3%');
  });

  testWidgets('đếm theo nhóm khớp dữ liệu phòng', (tester) async {
    await _pump(tester, _summary());
    expect(find.text('Tất cả · 5'), findsOneWidget);
    expect(find.text('Sẵn sàng · 2'), findsOneWidget);
    expect(find.text('Đang ở · 1'), findsOneWidget);
    expect(find.text('Cần dọn · 1'), findsOneWidget);
    expect(find.text('Ngừng phục vụ · 1'), findsOneWidget);
    expect(find.text('Quá hạn · 1'), findsOneWidget);
    expect(find.text('33,3%'), findsOneWidget);
  });

  testWidgets('lọc "Quá hạn" chỉ còn phòng có việc quá hạn', (tester) async {
    await _pump(tester, _summary());
    for (final n in ['101', '102', '103', '104', '201']) {
      expect(_tile(n), findsOneWidget);
    }
    await tester.tap(find.text('Quá hạn · 1'));
    await tester.pump();
    expect(_tile('102'), findsOneWidget);
    for (final n in ['101', '103', '104', '201']) {
      expect(_tile(n), findsNothing);
    }
  });

  testWidgets('lọc "Cần dọn" chỉ đếm phòng cần dọn', (tester) async {
    await _pump(tester, _summary());
    await tester.tap(find.text('Cần dọn · 1'));
    await tester.pump();
    expect(_tile('102'), findsOneWidget);
    expect(_tile('104'), findsNothing);
  });

  testWidgets('lọc không khớp phòng nào → trạng thái trống + xóa lọc',
      (tester) async {
    await _pump(tester, _summary());
    // Tầng 2 không có phòng ngừng phục vụ.
    await tester.tap(find.text('2'));
    await tester.tap(find.text('Ngừng phục vụ · 1'));
    await tester.pump();
    expect(find.text('Không có phòng nào khớp bộ lọc.'), findsOneWidget);
    await tester.tap(find.text('Xóa bộ lọc'));
    await tester.pump();
    expect(_tile('101'), findsOneWidget);
  });
}
