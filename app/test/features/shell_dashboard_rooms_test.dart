import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khachsan_di_dong/features/dashboard/screens/dashboard_screen.dart';
import 'package:khachsan_di_dong/features/rooms/providers/rooms_provider.dart';
import 'package:khachsan_di_dong/features/rooms/screens/rooms_screen.dart';
import 'package:khachsan_di_dong/features/shell/screens/app_shell.dart';
import 'package:khachsan_di_dong/models/room.dart';
import 'package:khachsan_di_dong/models/user.dart';
import 'package:khachsan_di_dong/shared/widgets/loading_skeleton.dart';
import 'package:khachsan_di_dong/shared/widgets/room_tile.dart';

import '../helpers/fakes.dart';

final _rooms = RoomsState(rooms: [
  fakeRoom('101'),
  fakeRoom('102', cleaning: CleaningStatus.dirty),
  fakeRoom('103', occupancy: OccupancyStatus.occupied),
  fakeRoom('201', floor: 2, cleaning: CleaningStatus.dirty),
]);

Future<void> _pumpShell(WidgetTester tester, Size size,
    {UserRole role = UserRole.manager}) {
  setScreen(tester, size);
  return pumpScreen(
    tester,
    const SizedBox.expand(),
    path: '/phong',
    overrides: fakeOverrides(role: role, rooms: _rooms),
    shell: (c) => AppShell(child: c),
  );
}

void main() {
  group('AppShell chọn bố cục theo bề rộng', () {
    testWidgets('điện thoại 360px: thanh điều hướng dưới', (tester) async {
      await _pumpShell(tester, const Size(360, 800),
          role: UserRole.receptionist);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('tablet 768px: thanh điều hướng dọc, đủ 7 mục quản lý',
        (tester) async {
      await _pumpShell(tester, const Size(768, 1024));
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      for (final label in ['Tổng quan', 'Phòng', 'Nhật ký']) {
        expect(find.text(label), findsWidgets);
      }
    });

    testWidgets('tablet ngang thấp vẫn không tràn khi có 7 mục',
        (tester) async {
      await _pumpShell(tester, const Size(800, 420));
      expect(tester.takeException(), isNull);
    });

    testWidgets('web 1280px: thanh bên', (tester) async {
      await _pumpShell(tester, const Size(1280, 800));
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.text('Khách Sạn Di Động'), findsOneWidget);
    });
  });

  group('Tổng quan', () {
    testWidgets('lần tải đầu hiện khung xương thay vòng xoay', (tester) async {
      setScreen(tester, const Size(400, 900));
      await pumpScreen(tester, const DashboardScreen(),
          overrides:
              fakeOverrides(rooms: const RoomsState(isLoading: true)));
      expect(find.byType(SkeletonGrid), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('bấm thẻ "Cần dọn" lọc lưới, bấm lại bỏ lọc', (tester) async {
      final handle = tester.ensureSemantics();
      setScreen(tester, const Size(1280, 1400));
      await pumpScreen(tester, const DashboardScreen(),
          overrides: fakeOverrides(rooms: _rooms));
      expect(find.byType(RoomTile), findsNWidgets(4));

      final card = find.bySemanticsLabel(RegExp(r'^Cần dọn:'));
      await tester.tap(card);
      await tester.pump();
      expect(find.byType(RoomTile), findsNWidgets(2));

      await tester.tap(card);
      await tester.pump();
      expect(find.byType(RoomTile), findsNWidgets(4));
      handle.dispose();
    });
  });

  group('Danh sách phòng', () {
    testWidgets('ô tìm kiếm hiện lại từ khóa đang lọc khi quay lại màn',
        (tester) async {
      setScreen(tester, const Size(400, 900));
      await pumpScreen(tester, const RoomsScreen(),
          overrides: fakeOverrides(
              rooms: RoomsState(
                  rooms: _rooms.rooms,
                  filter: const RoomsFilter(query: '10'))));
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, '10');
      expect(find.text('Đang hiện 3 / 4 phòng'), findsOneWidget);
    });

    testWidgets('kéo xuống để tải lại danh sách', (tester) async {
      setScreen(tester, const Size(400, 900));
      final notifier = FakeRooms(_rooms);
      await pumpScreen(tester, const RoomsScreen(),
          overrides: fakeOverrides(roomsNotifier: notifier));
      await tester.fling(find.byType(GridView), const Offset(0, 400), 1000);
      await tester.pumpAndSettle();
      expect(notifier.loads, 1);
    });
  });
}
