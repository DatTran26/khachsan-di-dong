import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khachsan_di_dong/features/housekeeping/providers/housekeeping_provider.dart';
import 'package:khachsan_di_dong/features/housekeeping/providers/photos_provider.dart';
import 'package:khachsan_di_dong/features/housekeeping/screens/acceptance_photos_screen.dart';
import 'package:khachsan_di_dong/features/rooms/providers/rooms_provider.dart';
import 'package:khachsan_di_dong/models/housekeeping_photo.dart';
import 'package:khachsan_di_dong/models/housekeeping_task.dart';

import 'support/fakes.dart';

/// Ảnh PNG 1×1 — thay cho byte ảnh tải từ server.
final _png = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==');

const _all = ['OVERVIEW', 'BED', 'BATHROOM'];

/// Mở màn ảnh nghiệm thu từ một nút, như thẻ việc thật (navigator gốc).
Future<FakeHousekeeping> _pump(
  WidgetTester tester, {
  required List<String> photos,
  HousekeepingTask? task,
  bool online = true,
}) async {
  tester.view.physicalSize = const Size(420, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final housekeeping = FakeHousekeeping([task ?? fakeHousekeepingTask()]);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      housekeepingProvider.overrideWith((ref) => housekeeping),
      taskPhotosProvider.overrideWith(
          (ref, id) => FakeTaskPhotos(id, fakeTaskPhotos(photos))),
      photoBytesProvider.overrideWith((ref, id) async => _png),
      isOnlineProvider.overrideWithValue(online),
    ],
    child: MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                    builder: (_) =>
                        const AcceptancePhotosScreen(taskId: 't1'))),
            child: const Text('Mở'),
          ),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('Mở'));
  await tester.pumpAndSettle();
  return housekeeping;
}

ElevatedButton _submitButton(WidgetTester tester) =>
    tester.widget(find.ancestor(
        of: find.text('Báo hoàn tất'), matching: find.byType(ElevatedButton)));

void main() {
  testWidgets('thiếu ảnh bắt buộc → khóa báo hoàn tất, nói rõ thiếu nhóm nào',
      (tester) async {
    await _pump(tester, photos: ['OVERVIEW', 'BED']);
    expect(find.text('Đã tải'), findsNWidgets(2));
    expect(find.text('Cần ảnh'), findsOneWidget);
    expect(find.text('Còn thiếu ảnh: Nhà vệ sinh.'), findsOneWidget);
    expect(_submitButton(tester).onPressed, isNull);
  });

  testWidgets('đủ 3 ảnh → báo hoàn tất, đóng màn', (tester) async {
    final housekeeping = await _pump(tester, photos: _all);
    expect(_submitButton(tester).onPressed, isNotNull);
    await tester.tap(find.text('Báo hoàn tất'));
    await tester.pumpAndSettle();
    expect(housekeeping.completed, [('t1', false)]);
    expect(find.byType(AcceptancePhotosScreen), findsNothing);
    expect(find.textContaining('Đã báo xong phòng 104'), findsOneWidget);
  });

  testWidgets('có bất thường → cần ảnh cận cảnh mới báo được', (tester) async {
    await _pump(tester, photos: _all);
    await tester.tap(find.text('Có bất thường'));
    await tester.pump();
    expect(find.text('Có bất thường — cần ít nhất 1 ảnh cận cảnh.'),
        findsOneWidget);
    expect(find.text('Thêm ảnh cận cảnh'), findsOneWidget);
    expect(_submitButton(tester).onPressed, isNull);
  });

  testWidgets('có bất thường + ảnh cận cảnh → gửi kèm cờ bất thường',
      (tester) async {
    final housekeeping =
        await _pump(tester, photos: [..._all, 'CLOSEUP', 'CLOSEUP']);
    expect(find.byTooltip('Xóa ảnh cận cảnh 2'), findsOneWidget);
    await tester.tap(find.text('Có bất thường'));
    await tester.pump();
    await tester.tap(find.text('Báo hoàn tất'));
    await tester.pumpAndSettle();
    expect(housekeeping.completed, [('t1', true)]);
  });

  testWidgets('mất kết nối → khóa chụp ảnh và báo hoàn tất', (tester) async {
    await _pump(tester, photos: ['OVERVIEW'], online: false);
    expect(_submitButton(tester).onPressed, isNull);
    final chup = tester.widget<ButtonStyleButton>(find.ancestor(
        of: find.text('Chụp ảnh').first,
        matching: find.bySubtype<ButtonStyleButton>()));
    expect(chup.onPressed, isNull);
  });

  testWidgets('bị trả lại → hiện ghi chú của quản lý', (tester) async {
    await _pump(tester,
        photos: const [],
        task:
            fakeHousekeepingTask(returnNote: 'Nhà vệ sinh còn tóc trên sàn.'));
    expect(
        find.textContaining('Nhà vệ sinh còn tóc trên sàn.'), findsOneWidget);
    expect(find.text('Chụp ảnh'), findsNWidgets(3));
  });

  test('TaskPhotos: chỉ tính ảnh lượt hiện tại', () {
    final p = TaskPhotos.fromJson({
      'currentRound': 2,
      'photos': [
        {
          'id': 'a',
          'category': 'OVERVIEW',
          'round': 1,
          'sizeBytes': 1,
          'createdAt': '2026-10-13T00:00:00Z'
        },
        {
          'id': 'b',
          'category': 'BED',
          'round': 2,
          'sizeBytes': 1,
          'createdAt': '2026-10-13T00:00:00Z'
        },
      ],
    });
    expect(p.requiredDone, 1);
    expect(p.of(PhotoCategory.overview), isNull);
    expect(p.hasAllRequired, isFalse);
  });
}
