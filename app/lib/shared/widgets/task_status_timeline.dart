import 'package:flutter/material.dart';
import '../../models/housekeeping_task.dart';
import '../../models/maintenance_task.dart';

enum _StepState { pending, current, done, cancelled }

class _Step {
  final String label;
  final _StepState state;
  const _Step(this.label, this.state);
}

_StepState _stateOf(int stepIdx, int currentIdx) {
  if (stepIdx < currentIdx) return _StepState.done;
  if (stepIdx == currentIdx) return _StepState.current;
  return _StepState.pending;
}

class TaskStatusTimeline extends StatelessWidget {
  final List<_Step> _steps;

  const TaskStatusTimeline._({required List<_Step> steps}) : _steps = steps;

  factory TaskStatusTimeline.housekeeping(HousekeepingStatus status) {
    final idx = HousekeepingStatus.values.indexOf(status);
    return TaskStatusTimeline._(steps: [
      _Step('Chờ giao', _stateOf(0, idx)),
      _Step('Đã nhận', _stateOf(1, idx)),
      _Step('Đang dọn', _stateOf(2, idx)),
      _Step('Chờ xác nhận', _stateOf(3, idx)),
      _Step('Hoàn tất', _stateOf(4, idx)),
    ]);
  }

  factory TaskStatusTimeline.maintenance(MaintenanceStatus status) {
    if (status == MaintenanceStatus.cancelled) {
      return const TaskStatusTimeline._(steps: [
        _Step('Chờ nhận', _StepState.done),
        _Step('Đã hủy', _StepState.cancelled),
      ]);
    }
    final statuses = [MaintenanceStatus.open, MaintenanceStatus.inProgress, MaintenanceStatus.done];
    final idx = statuses.indexOf(status);
    return TaskStatusTimeline._(steps: [
      _Step('Chờ nhận', _stateOf(0, idx)),
      _Step('Đang sửa', _stateOf(1, idx)),
      _Step('Hoàn tất', _stateOf(2, idx)),
    ]);
  }

  Color _connectorColor(_StepState state) {
    switch (state) {
      case _StepState.done:
        return Colors.green;
      case _StepState.current:
        return Colors.blue.withValues(alpha: 0.4);
      case _StepState.cancelled:
        return Colors.grey[400]!;
      case _StepState.pending:
        return Colors.grey[300]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < _steps.length; i++)
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 2,
                        color: i > 0 ? _connectorColor(_steps[i - 1].state) : Colors.transparent,
                      ),
                    ),
                    _StepCircle(state: _steps[i].state),
                    Expanded(
                      child: Container(
                        height: 2,
                        color: i < _steps.length - 1 ? _connectorColor(_steps[i].state) : Colors.transparent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _steps[i].label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 10,
                    color: _steps[i].state == _StepState.current
                        ? Colors.blue[700]
                        : _steps[i].state == _StepState.cancelled
                            ? Colors.grey
                            : _steps[i].state == _StepState.done
                                ? Colors.green[700]
                                : Colors.grey[500],
                    fontWeight: _steps[i].state == _StepState.current ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _StepCircle extends StatelessWidget {
  final _StepState state;
  const _StepCircle({required this.state});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Widget icon;
    switch (state) {
      case _StepState.done:
        bgColor = Colors.green;
        icon = const Icon(Icons.check, size: 12, color: Colors.white);
      case _StepState.current:
        bgColor = Colors.blue;
        icon = Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        );
      case _StepState.cancelled:
        bgColor = Colors.grey[400]!;
        icon = const Icon(Icons.close, size: 12, color: Colors.white);
      case _StepState.pending:
        bgColor = Colors.grey[200]!;
        icon = const SizedBox();
    }
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: state == _StepState.pending
            ? Border.all(color: Colors.grey[400]!, width: 1.5)
            : null,
      ),
      child: Center(child: icon),
    );
  }
}
