import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khachsan_di_dong/core/api/api_client.dart';
import 'package:khachsan_di_dong/features/ai_summary/providers/ai_summary_provider.dart';
import 'package:khachsan_di_dong/features/ai_summary/screens/ai_summary_screen.dart';
import 'package:khachsan_di_dong/features/rooms/providers/rooms_provider.dart';
import 'package:khachsan_di_dong/models/ai_summary.dart';

/// Notifier giả: không gọi API, đếm số lần bấm tạo.
class _FakeAiSummary extends AiSummaryNotifier {
  _FakeAiSummary(AiSummaryState initial) {
    state = initial;
  }

  int generateCalls = 0;

  @override
  Future<void> load() async {}

  @override
  Future<ApiException?> generate() async {
    generateCalls++;
    return null;
  }
}

Map<String, dynamic> _summaryJson({
  required String source,
  String? label,
  String overview = 'Ca 06:00–14:00: 2/50 phòng đang ở.',
  List<String> highlights = const [],
  List<Map<String, dynamic>> items = const [],
}) =>
    {
      'id': 's1',
      'period': 'CURRENT_SHIFT',
      'periodLabel': 'Ca 06:00–14:00 ngày 13/10',
      'dataAsOfText': 'Dữ liệu tính đến 07:46 13/10',
      'source': source,
      'label': label,
      'overview': overview,
      'highlights': highlights,
      'attention': {'items': items, 'notes': <String>[]},
      'createdBy': {'id': 'u1', 'fullName': 'Nguyễn Văn Quản Lý'},
      'createdAt': '2026-10-13T00:46:00.000Z',
    };

Future<_FakeAiSummary> _pump(WidgetTester tester, AiSummaryState state,
    {bool online = true}) async {
  final fake = _FakeAiSummary(state);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      aiSummaryProvider.overrideWith((ref) => fake),
      isOnlineProvider.overrideWithValue(online),
    ],
    child: const MaterialApp(home: Scaffold(body: AiSummaryScreen())),
  ));
  await tester.pump();
  return fake;
}

Finder _generateButton() => find.ancestor(
    of: find.byIcon(Icons.auto_awesome), matching: find.byType(ElevatedButton));

void main() {
  group('AiSummary.fromJson', () {
    test('đọc nguồn, nhãn, việc cần chú ý có phòng/việc', () {
      final s = AiSummary.fromJson(_summaryJson(
        source: 'FALLBACK',
        label: 'Báo cáo mẫu — dữ liệu gốc, chưa qua AI',
        items: [
          {
            'type': 'HOUSEKEEPING_OVERDUE',
            'roomId': 'r101',
            'roomNumber': '101',
            'taskId': 't1',
            'text': 'Việc dọn phòng 101 quá hạn',
          },
        ],
      ));
      expect(s.source, SummarySource.fallback);
      expect(s.period, SummaryPeriod.currentShift);
      expect(s.attention.single.roomId, 'r101');
      expect(s.attention.single.taskId, 't1');
      expect(s.createdByName, 'Nguyễn Văn Quản Lý');
    });

    test('kỳ rỗng không có nhãn', () {
      final s = AiSummary.fromJson(_summaryJson(source: 'EMPTY'));
      expect(s.source, SummarySource.empty);
      expect(s.label, isNull);
    });
  });

  group('Màn tóm tắt vận hành', () {
    testWidgets('chưa có bản nào → trạng thái trống, nút tạo bật',
        (tester) async {
      final fake = await _pump(tester, const AiSummaryState());
      expect(find.text('Chưa có bản tóm tắt nào cho ca hiện tại.'),
          findsOneWidget);
      await tester.tap(_generateButton());
      expect(fake.generateCalls, 1);
    });

    testWidgets('bản AI: nhãn tham khảo + thời điểm T + nổi bật',
        (tester) async {
      final s = AiSummary.fromJson(_summaryJson(
        source: 'AI',
        label: 'Tham khảo — tóm tắt do AI tạo, không thay quyết định vận hành',
        highlights: ['Nhận phòng: 3'],
      ));
      await _pump(
          tester, AiSummaryState(latest: {SummaryPeriod.currentShift: s}));
      expect(
          find.textContaining('Tham khảo — tóm tắt do AI tạo'), findsOneWidget);
      expect(
          find.textContaining('Dữ liệu tính đến 07:46 13/10'), findsOneWidget);
      expect(find.text('Nhận phòng: 3'), findsOneWidget);
      expect(find.text('Việc cần chú ý · 0'.toUpperCase()), findsOneWidget);
    });

    testWidgets('báo cáo mẫu: nhãn + thông báo lý do + nút tới dashboard',
        (tester) async {
      final s = AiSummary.fromJson(_summaryJson(
        source: 'FALLBACK',
        label: 'Báo cáo mẫu — dữ liệu gốc, chưa qua AI',
        items: [
          {
            'type': 'OUT_OF_SERVICE',
            'roomId': 'r201',
            'roomNumber': '201',
            'text': 'Phòng 201 đang ngừng phục vụ',
          },
        ],
      ));
      await _pump(
        tester,
        AiSummaryState(
          latest: {SummaryPeriod.currentShift: s},
          notice: 'Đã hết hạn mức AI — hiển thị báo cáo mẫu từ dữ liệu gốc.',
        ),
      );
      expect(
          find.text('Báo cáo mẫu — dữ liệu gốc, chưa qua AI'), findsOneWidget);
      expect(find.textContaining('Đã hết hạn mức AI'), findsOneWidget);
      expect(find.text('Phòng 201 đang ngừng phục vụ'), findsOneWidget);
      expect(find.text('Tới dashboard'), findsOneWidget);
    });

    testWidgets('đang tạo → nút khóa, hiện "Đang tạo…", không đổi kỳ',
        (tester) async {
      final fake =
          await _pump(tester, const AiSummaryState(isGenerating: true));
      expect(find.text('Đang tạo…'), findsOneWidget);
      final button = tester.widget<ElevatedButton>(find.ancestor(
          of: find.text('Đang tạo…'), matching: find.byType(ElevatedButton)));
      expect(button.onPressed, isNull);

      await tester.tap(find.text('Hôm nay'));
      expect(fake.state.period, SummaryPeriod.currentShift);
      expect(fake.generateCalls, 0);
    });

    testWidgets('mất kết nối → khóa nút tạo', (tester) async {
      await _pump(tester, const AiSummaryState(), online: false);
      expect(
          tester.widget<ElevatedButton>(_generateButton()).onPressed, isNull);
    });

    testWidgets('chọn kỳ khác → hiện bản của kỳ đó', (tester) async {
      final today = AiSummary.fromJson({
        ..._summaryJson(source: 'EMPTY', overview: 'Chưa có dữ liệu.'),
        'period': 'TODAY',
        'periodLabel': 'Hôm nay 13/10',
      });
      await _pump(tester, AiSummaryState(latest: {SummaryPeriod.today: today}));
      expect(find.text('Hôm nay 13/10'), findsNothing);
      await tester.tap(find.text('Hôm nay'));
      await tester.pump();
      expect(find.text('Hôm nay 13/10'), findsOneWidget);
    });
  });
}
