import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khachsan_di_dong/models/room.dart';
import 'package:khachsan_di_dong/shared/widgets/room_tile.dart';
import 'package:khachsan_di_dong/shared/widgets/ui.dart';

Room _room({
  OccupancyStatus occupancy = OccupancyStatus.occupied,
  CleaningStatus cleaning = CleaningStatus.dirty,
}) =>
    Room(
      id: 'r1',
      number: '204',
      floor: 2,
      roomType: const RoomType(id: 't1', name: 'Đôi'),
      occupancy: occupancy,
      cleaning: cleaning,
      service: ServiceStatus.inService,
      isReady: false,
      version: 1,
      updatedAt: DateTime(2026, 10, 17),
    );

Widget _host(Widget child, {double width = 400, double textScale = 1}) =>
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
            size: Size(width, 800), textScaler: TextScaler.linear(textScale)),
        child: Scaffold(body: child),
      ),
    );

void main() {
  group('initialLoadGate', () {
    Widget? gate({bool loading = false, String? error, bool isEmpty = true}) =>
        initialLoadGate(
          loading: loading,
          error: error,
          isEmpty: isEmpty,
          onRetry: () {},
          skeleton: const SkeletonList(),
        );

    test('trả khung xương khi đang tải lần đầu', () {
      expect(gate(loading: true), isA<SkeletonList>());
    });

    test('trả ErrorState khi lỗi và chưa có dữ liệu', () {
      expect(gate(error: 'Mất kết nối'), isA<ErrorState>());
    });

    test('để màn tự dựng khi đã có dữ liệu, kể cả đang tải lại', () {
      expect(gate(loading: true, isEmpty: false), isNull);
      expect(gate(error: 'x', isEmpty: false), isNull);
    });

    test('để màn tự hiện trạng thái rỗng khi tải xong không có dữ liệu', () {
      expect(gate(), isNull);
    });
  });

  testWidgets('khung xương chỉ đọc "Đang tải" cho trình đọc màn hình',
      (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host(const SkeletonGrid(header: true)));
    expect(find.bySemanticsLabel('Đang tải'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('khung xương đứng yên khi bật giảm chuyển động', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: Scaffold(body: SkeletonList()),
      ),
    ));
    // Không có animation chạy vô hạn → pumpAndSettle kết thúc được.
    await tester.pumpAndSettle();
    final fade = tester.widget<FadeTransition>(find.descendant(
        of: find.byType(Skeleton), matching: find.byType(FadeTransition)));
    expect(fade.opacity.value, 1);
  });

  testWidgets('ô phòng có nhãn đủ số phòng và ba trục trạng thái',
      (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host(SizedBox(
        width: 120,
        height: 106,
        child: RoomTile(room: _room(), overdue: true, onTap: () {}))));
    expect(
      find.bySemanticsLabel(
          RegExp(r'Phòng 204: Đang ở · Cần dọn · Đang phục vụ · quá hạn')),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('StatusChip không tràn ở cỡ chữ 200% trong khung 160px',
      (tester) async {
    await tester.pumpWidget(_host(
      const Center(
        child: SizedBox(
          width: 160,
          child: Wrap(children: [
            StatusChip('Chờ kiểm tra', tone: StatusTone.inspect),
          ]),
        ),
      ),
      textScale: 2,
    ));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Breakpoints chia đúng ba mức', (tester) async {
    final seen = <WindowSize>[];
    for (final w in [360.0, 768.0, 1280.0]) {
      await tester.pumpWidget(_host(Builder(builder: (c) {
        seen.add(Breakpoints.of(c));
        return const SizedBox();
      }), width: w));
    }
    expect(seen, [WindowSize.compact, WindowSize.medium, WindowSize.expanded]);
  });
}
