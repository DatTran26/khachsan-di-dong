import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Việc cần mở chi tiết khi đi từ liên kết `?viec=<id>` (cảnh báo quá hạn, chi tiết phòng).
/// Thẻ việc khớp id tự mở chi tiết — đủ nút thao tác như khi bấm tay — rồi xóa giá trị này.
final taskLinkProvider = StateProvider<String?>((ref) => null);

/// Bọc màn danh sách việc: nhận `?viec=<id>` từ đường dẫn, ghi vào [taskLinkProvider] rồi bỏ tham số khỏi
/// đường dẫn — lần sau đi tới cùng việc vẫn mở lại được.
class TaskLinkScope extends ConsumerStatefulWidget {
  final String path;
  final String? taskId;
  final Widget child;

  const TaskLinkScope(
      {super.key, required this.path, this.taskId, required this.child});

  @override
  ConsumerState<TaskLinkScope> createState() => _TaskLinkScopeState();
}

class _TaskLinkScopeState extends ConsumerState<TaskLinkScope> {
  @override
  void initState() {
    super.initState();
    _apply();
  }

  @override
  void didUpdateWidget(TaskLinkScope old) {
    super.didUpdateWidget(old);
    if (widget.taskId != old.taskId) _apply();
  }

  void _apply() {
    final taskId = widget.taskId;
    if (taskId == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(taskLinkProvider.notifier).state = taskId;
      context.go(widget.path);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Gọi trong `build` của thẻ việc: thẻ là việc đang được liên kết tới → mở chi tiết sau khung hình hiện tại.
/// Việc không có trong danh sách (vd không thuộc người đang xem) → không mở gì.
void openIfLinked(
    BuildContext context, WidgetRef ref, String taskId, VoidCallback open) {
  if (ref.watch(taskLinkProvider) != taskId) return;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted || ref.read(taskLinkProvider) != taskId) return;
    ref.read(taskLinkProvider.notifier).state = null;
    open();
  });
}
