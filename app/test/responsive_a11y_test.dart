import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khachsan_di_dong/core/theme/app_theme.dart';
import 'package:khachsan_di_dong/features/ai_summary/providers/ai_summary_provider.dart';
import 'package:khachsan_di_dong/features/ai_summary/screens/ai_summary_screen.dart';
import 'package:khachsan_di_dong/features/dashboard/providers/dashboard_provider.dart';
import 'package:khachsan_di_dong/features/dashboard/screens/dashboard_screen.dart';
import 'package:khachsan_di_dong/features/housekeeping/providers/housekeeping_provider.dart';
import 'package:khachsan_di_dong/features/housekeeping/providers/photos_provider.dart';
import 'package:khachsan_di_dong/features/housekeeping/screens/acceptance_photos_screen.dart';
import 'package:khachsan_di_dong/features/rooms/providers/rooms_provider.dart';
import 'package:khachsan_di_dong/models/ai_summary.dart';

import 'support/fakes.dart';

/// Kiểm responsive + khả năng tiếp cận (S3-HOANG-04/007) cho màn Sprint 3, dùng theme thật của app:
/// - Không tràn bố cục (RenderFlex overflow) ở điện thoại / máy tính bảng / web.
/// - Vùng bấm ≥24×24 (WCAG 2.2 AA, 2.5.8), nút có nhãn, chữ đạt tương phản WCAG AA (4.5:1).
///   Chuẩn 48×48 của Android chưa đạt với nút lọc dạng viên — ghi ở docs/qa/sprint-3-ui-checklist.md.
///
/// Font trong test (FlutterTest) rộng hơn font thật → kiểm tràn ở đây khắt khe như khi phóng to chữ.

const _sizes = {
  'điện thoại 360×740': Size(360, 740),
  'máy tính bảng 768×1024': Size(768, 1024),
  'web 1280×800': Size(1280, 800),
};

/// 50 phòng, 5 tầng — đủ mọi trạng thái để lưới và nhãn hiện như thật.
final _rooms = [
  for (var f = 1; f <= 5; f++)
    for (var i = 1; i <= 10; i++)
      fakeRoom('$f${i.toString().padLeft(2, '0')}',
          occupancy: i <= 3 ? 'OCCUPIED' : 'VACANT',
          cleaning: i == 4
              ? 'DIRTY'
              : i == 5
                  ? 'CLEANING'
                  : i == 6
                      ? 'PENDING_INSPECTION'
                      : 'CLEAN',
          service: i == 7 ? 'OUT_OF_SERVICE' : 'IN_SERVICE'),
];

final _summary = DashboardSummary.fromJson({
  'asOf': '2026-10-13T00:00:00.000Z',
  'totalRooms': 50,
  'occupied': 15,
  'ready': 15,
  'outOfService': 5,
  'cleaning': {'DIRTY': 5, 'CLEANING': 5, 'PENDING_INSPECTION': 5, 'CLEAN': 35},
  'overdue': {
    'housekeeping': 1,
    'maintenance': 1,
    'total': 2,
    'tasks': [
      {
        'type': 'HOUSEKEEPING',
        'taskId': 't1',
        'roomId': 'r104',
        'roomNumber': '104'
      },
      {
        'type': 'MAINTENANCE',
        'taskId': 't2',
        'roomId': 'r207',
        'roomNumber': '207'
      },
    ],
  },
  'occupancy': {'occupied': 15, 'serviceable': 45, 'rate': 33.3},
});

final _aiSummary = AiSummary.fromJson({
  'id': 's1',
  'period': 'CURRENT_SHIFT',
  'periodLabel': 'Ca 06:00–14:00 ngày 13/10',
  'dataAsOfText': 'Dữ liệu tính đến 07:46 13/10',
  'source': 'FALLBACK',
  'label': 'Báo cáo mẫu — dữ liệu gốc, chưa qua AI',
  'overview':
      'Ca 06:00–14:00 ngày 13/10: 15/50 phòng đang ở (lấp đầy 33,3%), 15 phòng sẵn sàng, 5 phòng cần dọn, 5 phòng ngừng phục vụ; 2 việc quá hạn.',
  'highlights': ['Nhận phòng: 3', 'Trả phòng: 2'],
  'attention': {
    'items': [
      {
        'type': 'HOUSEKEEPING_OVERDUE',
        'roomId': 'r104',
        'roomNumber': '104',
        'taskId': 't1',
        'text': 'Việc dọn phòng 104 quá hạn',
      },
      {
        'type': 'OUT_OF_SERVICE',
        'roomId': 'r207',
        'roomNumber': '207',
        'text': 'Phòng 207 đang ngừng phục vụ',
      },
    ],
    'notes': <String>[],
  },
  'createdBy': {'id': 'u1', 'fullName': 'Nguyễn Văn Quản Lý'},
  'createdAt': '2026-10-13T00:46:00.000Z',
});

Future<void> _pump(WidgetTester tester, Size size, Widget screen) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      roomsProvider.overrideWith((ref) => FakeRooms(_rooms)),
      dashboardSummaryProvider
          .overrideWith((ref) => FakeDashboardSummary(_summary)),
      housekeepingProvider.overrideWith((ref) => FakeHousekeeping([
            fakeHousekeepingTask(
                returnNote: 'Nhà vệ sinh còn tóc trên sàn, chụp lại giúp.'),
          ])),
      taskPhotosProvider.overrideWith((ref, id) =>
          FakeTaskPhotos(id, fakeTaskPhotos(['OVERVIEW', 'BED', 'CLOSEUP']))),
      photoBytesProvider.overrideWith((ref, id) async => base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==')),
      aiSummaryProvider.overrideWith((ref) => FakeAiSummary(AiSummaryState(
            latest: {SummaryPeriod.currentShift: _aiSummary},
            notice: 'Đã hết hạn mức AI — hiển thị báo cáo mẫu từ dữ liệu gốc.',
          ))),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: screen),
    ),
  ));
  await tester.pump();
}

const _wcagTargetSize = MinimumTapTargetGuideline(
  size: Size(24, 24),
  link: 'https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum',
);

Future<void> _expectAccessible(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(_wcagTargetSize));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('Tổng quan web — Tab đi theo thứ tự đọc, tới được ô phòng',
      (tester) async {
    await _pump(tester, const Size(1280, 800), const DashboardScreen());
    final rects = <Rect>[];
    for (var i = 0; i < 20; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final box = FocusManager.instance.primaryFocus!.context!
          .findRenderObject()! as RenderBox;
      rects.add(box.localToGlobal(Offset.zero) & box.size);
    }
    // Thứ tự đọc: cùng hàng thì sang phải, sang hàng mới thì xuống dưới.
    for (var i = 1; i < rects.length; i++) {
      final prev = rects[i - 1], cur = rects[i];
      final sameRow = (cur.center.dy - prev.center.dy).abs() < prev.height / 2;
      expect(sameRow ? cur.left > prev.left : cur.top > prev.top, isTrue,
          reason: 'Tab lần ${i + 1} nhảy ngược: $prev → $cur');
    }
    // 6 nút tầng + 6 nút nhóm → các lần Tab sau phải vào lưới phòng (ô 101 ở hàng dưới bộ lọc).
    expect(rects.last.top, greaterThan(rects[11].bottom));
  });

  for (final MapEntry(key: name, value: size) in _sizes.entries) {
    testWidgets('Tổng quan — $name: không tràn, đạt a11y', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, size, const DashboardScreen());
      expect(tester.takeException(), isNull);
      await _expectAccessible(tester);
      handle.dispose();
    });

    testWidgets('Ảnh nghiệm thu — $name: không tràn, đạt a11y', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, size, const AcceptancePhotosScreen(taskId: 't1'));
      await tester.pump();
      expect(tester.takeException(), isNull);
      await _expectAccessible(tester);
      handle.dispose();
    });

    testWidgets('Tóm tắt vận hành — $name: không tràn, đạt a11y',
        (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, size, const AiSummaryScreen());
      expect(tester.takeException(), isNull);
      await _expectAccessible(tester);
      handle.dispose();
    });
  }
}
