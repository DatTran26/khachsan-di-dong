import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khachsan_di_dong/features/auth/providers/auth_provider.dart';
import 'package:khachsan_di_dong/features/housekeeping/providers/housekeeping_provider.dart';
import 'package:khachsan_di_dong/features/housekeeping/providers/photos_provider.dart';
import 'package:khachsan_di_dong/features/housekeeping/screens/housekeeping_screen.dart';
import 'package:khachsan_di_dong/features/rooms/providers/rooms_provider.dart';
import 'package:khachsan_di_dong/features/users/providers/users_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fakes.dart';

/// Sheet chi tiết việc dọn đọc việc mới nhất theo id — thao tác / realtime đổi trạng thái thì nút đổi theo.

Future<FakeHousekeeping> _pump(
    WidgetTester tester, String role, String status) async {
  tester.view.physicalSize = const Size(1280, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final hk = FakeHousekeeping([fakeHousekeepingTask(status: status)]);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      authProvider.overrideWith((ref) => FakeAuth(fakeUser(role))),
      usersProvider.overrideWith((ref) => FakeUsers(const [])),
      housekeepingProvider.overrideWith((ref) => hk),
      isOnlineProvider.overrideWithValue(true),
      taskPhotosProvider.overrideWith((ref, id) =>
          FakeTaskPhotos(id, fakeTaskPhotos(['OVERVIEW', 'BED', 'CLOSEUP']))),
      photoBytesProvider.overrideWith((ref, id) async => base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==')),
    ],
    child: const MaterialApp(home: Scaffold(body: HousekeepingScreen())),
  ));
  await tester.pump();
  await tester.tap(find.text('Phòng 104').first);
  await tester.pumpAndSettle();
  return hk;
}

Finder _inSheet(String text) =>
    find.descendant(of: find.byType(BottomSheet), matching: find.text(text));

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets(
      'quản lý: trả lại → sheet hiện "Bị trả lại" + nút mới; xác nhận sạch → đóng sheet',
      (tester) async {
    final hk = await _pump(tester, 'MANAGER', 'PENDING_CONFIRM');
    expect(_inSheet('Xác nhận sạch'), findsOneWidget);
    expect(_inSheet('Trả lại'), findsOneWidget);

    hk.setTasks([
      fakeHousekeepingTask(
          status: 'IN_PROGRESS', returnNote: 'Gương phòng tắm còn vết.'),
    ]);
    await tester.pumpAndSettle();
    expect(_inSheet('Bị trả lại'), findsOneWidget);
    expect(
        find.descendant(
            of: find.byType(BottomSheet),
            matching: find.textContaining('Gương phòng tắm còn vết.',
                findRichText: true)),
        findsOneWidget);
    expect(_inSheet('Phân công lại'), findsOneWidget);
    expect(_inSheet('Xác nhận sạch'), findsNothing);

    hk.setTasks([fakeHousekeepingTask(status: 'DONE')]);
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'nhân viên: nhận việc → sheet đổi nút; việc không còn trong danh sách → đóng sheet',
      (tester) async {
    final hk = await _pump(tester, 'STAFF', 'ASSIGNED');
    expect(_inSheet('Nhận việc'), findsOneWidget);

    hk.setTasks([fakeHousekeepingTask(status: 'IN_PROGRESS')]);
    await tester.pumpAndSettle();
    expect(_inSheet('Nhận việc'), findsNothing);
    expect(_inSheet('Ảnh & báo xong'), findsOneWidget);
    expect(_inSheet('Báo hỏng phòng này'), findsOneWidget);

    hk.setTasks(const []);
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('nhân viên: đang dọn → báo xong (chờ xác nhận) → sheet tự đóng',
      (tester) async {
    final hk = await _pump(tester, 'STAFF', 'IN_PROGRESS');
    expect(_inSheet('Ảnh & báo xong'), findsOneWidget);

    hk.setTasks([fakeHousekeepingTask(status: 'PENDING_CONFIRM')]);
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.text('Ảnh & báo xong'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
