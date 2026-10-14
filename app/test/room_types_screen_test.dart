import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khachsan_di_dong/features/rooms/providers/room_types_provider.dart';
import 'package:khachsan_di_dong/features/rooms/providers/rooms_provider.dart';
import 'package:khachsan_di_dong/features/rooms/screens/room_types_screen.dart';
import 'package:khachsan_di_dong/models/room.dart';

import 'support/fakes.dart';

Future<FakeRoomTypes> _pump(WidgetTester tester, {bool online = true}) async {
  final types = FakeRoomTypes(const [
    RoomType(id: 'std', name: 'Standard'),
    RoomType(id: 'suite', name: 'Suite', isActive: false),
  ]);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      roomTypesProvider.overrideWith((ref) => types),
      // fakeRoom gán loại 'std' → Standard có 2 phòng, Suite chưa có phòng.
      roomsProvider
          .overrideWith((ref) => FakeRooms([fakeRoom('101'), fakeRoom('102')])),
      isOnlineProvider.overrideWithValue(online),
    ],
    child: const MaterialApp(home: RoomTypesScreen()),
  ));
  await tester.pump();
  return types;
}

void main() {
  testWidgets('danh sách: trạng thái dùng/ngừng, số phòng, nút Tắt/Bật',
      (tester) async {
    await _pump(tester);
    expect(find.text('Đang dùng'), findsOneWidget);
    expect(find.text('Đã ngừng'), findsOneWidget);
    expect(find.text('2 phòng'), findsOneWidget);
    expect(find.text('Chưa có phòng'), findsOneWidget);
    expect(find.text('Tắt'), findsOneWidget);
    expect(find.text('Bật'), findsOneWidget);
  });

  testWidgets('thêm loại: tên trống báo lỗi tại chỗ, có tên thì lưu',
      (tester) async {
    final types = await _pump(tester);
    await tester.tap(find.text('Thêm loại'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lưu'));
    await tester.pump();
    expect(find.text('Vui lòng nhập tên loại phòng.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '  Deluxe  ');
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();
    expect(types.calls, ['create:Deluxe']);
    expect(find.text('Deluxe'), findsOneWidget);
  });

  testWidgets('tắt loại cần xác nhận; bật lại thì làm ngay', (tester) async {
    final types = await _pump(tester);
    await tester.tap(find.text('Tắt'));
    await tester.pumpAndSettle();
    expect(find.text('Tắt loại phòng Standard?'), findsOneWidget);
    await tester.tap(find.text('Tắt loại'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bật'));
    await tester.pumpAndSettle();
    expect(types.calls, ['active:std:false', 'active:suite:true']);
  });

  testWidgets('mất kết nối → khóa thêm, sửa, tắt/bật', (tester) async {
    await _pump(tester, online: false);
    for (final label in ['Thêm loại', 'Sửa', 'Tắt', 'Bật']) {
      final button = tester.widget<ButtonStyleButton>(find
          .ancestor(
              of: find.text(label).first,
              matching: find.bySubtype<ButtonStyleButton>())
          .first);
      expect(button.onPressed, isNull, reason: label);
    }
  });
}
