import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/realtime/socket_service.dart';
import '../../../models/housekeeping_task.dart';

class HousekeepingState {
  final List<HousekeepingTask> tasks;
  final bool isLoading;
  final String? error;
  final bool isConnected;

  const HousekeepingState({
    this.tasks = const [],
    this.isLoading = false,
    this.error,
    this.isConnected = true,
  });

  HousekeepingState copyWith({
    List<HousekeepingTask>? tasks,
    bool? isLoading,
    String? error,
    bool? isConnected,
    bool clearError = false,
  }) =>
      HousekeepingState(
        tasks: tasks ?? this.tasks,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        isConnected: isConnected ?? this.isConnected,
      );
}

class HousekeepingNotifier extends StateNotifier<HousekeepingState> {
  HousekeepingNotifier() : super(const HousekeepingState()) {
    socketService.onHousekeepingTaskUpdated = _handleTaskUpdated;
    load();
  }

  void _handleTaskUpdated(Map<String, dynamic> taskJson) {
    final updated = HousekeepingTask.fromJson(taskJson);
    final idx = state.tasks.indexWhere((t) => t.id == updated.id);
    if (idx == -1) {
      state = state.copyWith(tasks: [...state.tasks, updated]);
    } else {
      final current = state.tasks[idx];
      if (updated.version <= current.version) return;
      final newTasks = [...state.tasks];
      newTasks[idx] = updated;
      state = state.copyWith(tasks: newTasks);
    }
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await apiClient.get('/housekeeping/tasks');
      final list = (res['data'] as List)
          .cast<Map<String, dynamic>>()
          .map(HousekeepingTask.fromJson)
          .toList();
      state = state.copyWith(tasks: list, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> accept(String id, int version) async {
    await apiClient.post('/housekeeping/tasks/$id/accept', body: {'version': version});
    await load();
  }

  Future<void> reject(String id, int version) async {
    await apiClient.post('/housekeeping/tasks/$id/reject', body: {'version': version});
    await load();
  }

  Future<void> complete(String id, int version) async {
    await apiClient.post('/housekeeping/tasks/$id/complete', body: {'version': version});
    await load();
  }

  Future<void> confirm(String id, int version) async {
    await apiClient.post('/housekeeping/tasks/$id/confirm', body: {'version': version});
    await load();
  }

  Future<void> returnTask(String id, int version, String note) async {
    await apiClient.post('/housekeeping/tasks/$id/return', body: {'version': version, 'note': note});
    await load();
  }

  Future<void> reassign(String id, int version, String assigneeId) async {
    await apiClient.post('/housekeeping/tasks/$id/reassign', body: {'version': version, 'assigneeId': assigneeId});
    await load();
  }
}

final housekeepingProvider =
    StateNotifierProvider<HousekeepingNotifier, HousekeepingState>((ref) {
  return HousekeepingNotifier();
});
