import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khachsan_di_dong/features/maintenance/widgets/report_issue_dialog.dart';
import 'package:khachsan_di_dong/features/rooms/providers/rooms_provider.dart';
import 'package:khachsan_di_dong/features/rooms/widgets/room_detail_panel.dart';
import 'package:khachsan_di_dong/features/stays/providers/stays_provider.dart';
import 'package:khachsan_di_dong/features/stays/screens/stays_screen.dart';
import 'package:khachsan_di_dong/models/room.dart';
import 'package:khachsan_di_dong/models/stay.dart';
import 'package:khachsan_di_dong/models/user.dart';
import 'package:khachsan_di_dong/shared/widgets/ui.dart';

import '../helpers/fakes.dart';

final _stay = Stay(
  id: 's1',
  room: const StayRoomRef(id: 'room-103', number: '103', floor: 1),
  guestName: 'Trần Thị Bình',
  guestCount: 2,
  status: 'ACTIVE',
  checkedInAt: DateTime(2026, 10, 16, 14),
  version: 1,
);

void main() {
  testWidgets('Lưu trú: lần tải đầu hiện khung xương', (tester) async {
    setScreen(tester, const Size(400, 900));
    await pumpScreen(tester, const StaysScreen(),
        overrides: fakeOverrides(
            role: UserRole.receptionist,
            stays: const StaysState(isLoading: true)));
    expect(find.byType(SkeletonList), findsOneWidget);
  });

  testWidgets('Lưu trú: mất kết nối → nút trả phòng khóa và có giải thích',
      (tester) async {
    setScreen(tester, const Size(400, 900));
    await pumpScreen(tester, const StaysScreen(),
        overrides: fakeOverrides(
            role: UserRole.receptionist,
            online: false,
            stays: StaysState(stays: [_stay])));
    final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Trả phòng 103'));
    expect(button.onPressed, isNull);
    expect(find.byType(OfflineActionNote), findsOneWidget);
  });

  testWidgets('Chi tiết phòng: chọn nhanh "2 đêm" thay cho lịch',
      (tester) async {
    setScreen(tester, const Size(400, 1000));
    await pumpScreen(tester, const RoomDetailPanel(roomId: 'room-101'),
        overrides: fakeOverrides(
            role: UserRole.receptionist,
            rooms: RoomsState(rooms: [fakeRoom('101')])));
    expect(find.text('Chưa chọn'), findsOneWidget);
    await tester.tap(find.text('2 đêm'));
    await tester.pump();
    expect(find.text('Chưa chọn'), findsNothing);
    expect(find.textContaining('12:00 · '), findsOneWidget);
  });

  testWidgets('Báo hỏng: để trống mô tả thì báo lỗi, không gửi',
      (tester) async {
    setScreen(tester, const Size(500, 1000));
    await pumpScreen(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => showReportIssueDialog(context, roomId: 'room-101'),
          child: const Text('mở'),
        ),
      ),
      overrides: fakeOverrides(
          rooms: RoomsState(rooms: [
        fakeRoom('101', cleaning: CleaningStatus.dirty),
      ])),
    );
    await tester.tap(find.text('mở'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gửi báo hỏng'));
    await tester.pump();
    expect(find.text('Vui lòng mô tả sự cố.'), findsOneWidget);
    expect(find.text('Báo hỏng'), findsOneWidget); // dialog vẫn mở
  });
}
