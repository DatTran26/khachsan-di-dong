import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khachsan_di_dong/shared/widgets/task_link.dart';

/// Thẻ việc giả: gọi [openIfLinked] như thẻ thật, đếm số lần mở chi tiết.
class _Card extends ConsumerWidget {
  final String taskId;
  final List<String> opened;
  const _Card(this.taskId, this.opened);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    openIfLinked(context, ref, taskId, () => opened.add(taskId));
    return Text(taskId);
  }
}

void main() {
  testWidgets('chỉ thẻ khớp id mở chi tiết, đúng một lần', (tester) async {
    final opened = <String>[];
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Column(children: [_Card('t1', opened), _Card('t2', opened)]),
      ),
    ));

    container.read(taskLinkProvider.notifier).state = 't2';
    await tester.pump(); // thẻ dựng lại, hẹn mở
    await tester.pump(); // khung hình sau: mở + xóa liên kết
    expect(opened, ['t2']);
    expect(container.read(taskLinkProvider), isNull);

    await tester.pump();
    expect(opened, ['t2']); // dựng lại không mở lần nữa
  });

  testWidgets('việc không có trong danh sách → không mở gì', (tester) async {
    final opened = <String>[];
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: _Card('t1', opened)),
    ));

    container.read(taskLinkProvider.notifier).state = 'khac';
    await tester.pump();
    await tester.pump();
    expect(opened, isEmpty);
  });
}
