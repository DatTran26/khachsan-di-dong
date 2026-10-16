import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../models/housekeeping_task.dart';
import '../../models/maintenance_task.dart';

/// Trạng thái một nút trên timeline: chưa tới, đang ở, đã qua, đã hủy.
enum _StepState { pending, current, done, cancelled }

/// Một bước: [label], [state], [note] tùy chọn (giờ hoặc tên người).
class _Step {
  final String label;
  final String? note;
  final _StepState state;
  const _Step(this.label, this.state, [this.note]);
}

/// Bước trước [currentIdx] là xong, đúng chỉ số là hiện tại, sau là chờ.
_StepState _stateOf(int stepIdx, int currentIdx) {
  if (stepIdx < currentIdx) return _StepState.done;
  if (stepIdx == currentIdx) return _StepState.current;
  return _StepState.pending;
}

/// `HH:mm dd/MM` local, hoặc null nếu [t] null.
String? _time(DateTime? t) =>
    t == null ? null : DateFormat('HH:mm dd/MM').format(t.toLocal());

/// Tiến độ công việc dạng dọc — nút vàng cho bước đã qua / đang ở.
class TaskStatusTimeline extends StatelessWidget {
  final List<_Step> _steps;

  const TaskStatusTimeline._({required List<_Step> steps}) : _steps = steps;

  /// Năm bước dọn, bước hiện tại theo [HousekeepingTask.status]. Không có nhánh hủy.
  factory TaskStatusTimeline.housekeeping(HousekeepingTask task) {
    const order = [
      HousekeepingStatus.unassigned,
      HousekeepingStatus.assigned,
      HousekeepingStatus.inProgress,
      HousekeepingStatus.pendingConfirm,
      HousekeepingStatus.done,
    ];
    final idx = order.indexOf(task.status);
    return TaskStatusTimeline._(steps: [
      _Step('Tạo việc dọn', _stateOf(0, idx), _time(task.createdAt)),
      _Step(
        'Đã giao',
        _stateOf(1, idx),
        task.assignee != null
            ? '${_time(task.assignedAt) ?? ''} · ${task.assignee!.fullName}'
            : null,
      ),
      _Step('Đang dọn', _stateOf(2, idx), _time(task.startedAt)),
      _Step('Chờ quản lý xác nhận', _stateOf(3, idx),
          _time(task.completedAt) ?? 'sau khi báo xong'),
      _Step('Phòng sạch', _stateOf(4, idx),
          _time(task.confirmedAt) ?? 'phòng về Sẵn sàng'),
    ]);
  }

  /// Việc hủy thì hai bước (báo hỏng, đã hủy). Còn lại ba bước tới sửa xong.
  factory TaskStatusTimeline.maintenance(MaintenanceTask task) {
    if (task.status == MaintenanceStatus.cancelled) {
      return TaskStatusTimeline._(steps: [
        _Step('Báo hỏng', _StepState.done, _time(task.createdAt)),
        _Step('Đã hủy', _StepState.cancelled, task.cancelReason),
      ]);
    }
    const order = [
      MaintenanceStatus.open,
      MaintenanceStatus.inProgress,
      MaintenanceStatus.done
    ];
    final idx = order.indexOf(task.status);
    return TaskStatusTimeline._(steps: [
      _Step('Báo hỏng', _stateOf(0, idx),
          '${_time(task.createdAt)} · ${task.reporter.fullName}'),
      _Step('Đang sửa', _stateOf(1, idx), task.assignee?.fullName),
      _Step('Sửa xong', _stateOf(2, idx), 'phòng mở lại phục vụ'),
    ]);
  }

  /// Cột nút và nhãn. Đường nối vàng nếu bước trên đã xong.
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < _steps.length; i++)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 20,
                child: Column(
                  children: [
                    _Node(state: _steps[i].state),
                    if (i < _steps.length - 1)
                      Container(
                        width: 2,
                        height: 30,
                        color: _steps[i].state == _StepState.done
                            ? AppColors.gold
                            : AppColors.timelineLine,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: i < _steps.length - 1 ? 50 : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _steps[i].label,
                        style: AppText.body.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _steps[i].state == _StepState.pending
                                ? AppColors.muted
                                : AppColors.text),
                      ),
                      if (_steps[i].note != null && _steps[i].note!.isNotEmpty)
                        Text(_steps[i].note!,
                            style: AppText.caption
                                .copyWith(color: AppColors.muted)),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

/// Nút tròn 20px theo [_StepState].
class _Node extends StatelessWidget {
  final _StepState state;
  const _Node({required this.state});

  /// Không animation. Hủy là nền oos và dấu đóng.
  @override
  Widget build(BuildContext context) {
    switch (state) {
      case _StepState.done:
        return Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
              color: AppColors.gold, shape: BoxShape.circle),
          child: const Icon(Icons.check, size: 13, color: AppColors.espresso),
        );
      case _StepState.current:
        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.gold, width: 2),
            boxShadow: const [
              BoxShadow(color: AppColors.goldTint, spreadRadius: 4)
            ],
          ),
          child: Center(
            child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: AppColors.gold, shape: BoxShape.circle)),
          ),
        );
      case _StepState.cancelled:
        return Container(
          width: 20,
          height: 20,
          decoration:
              const BoxDecoration(color: AppColors.oos, shape: BoxShape.circle),
          child: const Icon(Icons.close, size: 13, color: Colors.white),
        );
      case _StepState.pending:
        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.timelineRing, width: 2),
          ),
        );
    }
  }
}
