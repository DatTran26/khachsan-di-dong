import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/realtime/socket_service.dart';
import '../../../models/maintenance_task.dart';

/// Danh sách việc sửa, cờ tải và lỗi của `GET /maintenance/tasks`.
class MaintenanceState {
  final List<MaintenanceTask> tasks;
  final bool isLoading;
  final String? error;

  const MaintenanceState({
    this.tasks = const [],
    this.isLoading = false,
    this.error,
  });

  /// Bản sao. [clearError] true thì xóa lỗi dù [error] được truyền.
  MaintenanceState copyWith({
    List<MaintenanceTask>? tasks,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      MaintenanceState(
        tasks: tasks ?? this.tasks,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );
}

/// Tải và đổi việc sửa. Constructor gắn socket rồi [load].
class MaintenanceNotifier extends StateNotifier<MaintenanceState> {
  /// Side effect: ghi đè [socketService.onMaintenanceTaskUpdated] rồi gọi [load].
  MaintenanceNotifier() : super(const MaintenanceState()) {
    socketService.onMaintenanceTaskUpdated = _handleTaskUpdated;
    load();
  }

  /// Thêm việc mới hoặc thay nếu version cao hơn. Bỏ payload cũ hơn. Không gọi API.
  void _handleTaskUpdated(Map<String, dynamic> taskJson) {
    final updated = MaintenanceTask.fromJson(taskJson);
    final idx = state.tasks.indexWhere((t) => t.id == updated.id);
    if (idx == -1) {
      state = state.copyWith(tasks: [...state.tasks, updated]);
    } else {
      if (updated.version <= state.tasks[idx].version) return;
      final newTasks = [...state.tasks];
      newTasks[idx] = updated;
      state = state.copyWith(tasks: newTasks);
    }
  }

  /// GET `/maintenance/tasks`. [ApiException] ghi state, không ném tiếp.
  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await apiClient.get('/maintenance/tasks');
      final list = (res['data'] as List)
          .cast<Map<String, dynamic>>()
          .map(MaintenanceTask.fromJson)
          .toList();
      state = state.copyWith(tasks: list, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  /// POST tạo việc. [location] rỗng không gửi. Trả `warning` nếu server có, không thì null.
  /// Luôn [load] lại. Ném [ApiException] khi từ chối.
  Future<String?> report({
    required String roomId,
    required String description,
    String? location,
  }) async {
    final body = <String, dynamic>{'roomId': roomId, 'description': description};
    if (location != null && location.isNotEmpty) body['location'] = location;
    final res = await apiClient.post('/maintenance/tasks', body: body);
    final data = res['data'] as Map<String, dynamic>;
    await load();
    return data['warning'] as String?;
  }

  /// POST nhận việc rồi [load]. Ném [ApiException] nếu version lệch hoặc việc đã có người.
  Future<void> claim(String id, int version) async {
    await apiClient.post('/maintenance/tasks/$id/claim', body: {'version': version});
    await load();
  }

  /// POST báo sửa xong rồi [load]. Ném [ApiException] nếu không phải người đang sửa.
  Future<void> complete(String id, int version) async {
    await apiClient.post('/maintenance/tasks/$id/complete', body: {'version': version});
    await load();
  }

  /// POST hủy. [reason] rỗng không gửi. Rồi [load]. Ném [ApiException] nếu không đủ quyền.
  Future<void> cancel(String id, int version, {String? reason}) async {
    final body = <String, dynamic>{'version': version};
    if (reason != null && reason.isNotEmpty) body['reason'] = reason;
    await apiClient.post('/maintenance/tasks/$id/cancel', body: body);
    await load();
  }

  /// POST chỉ định [assigneeId] rồi [load]. Ném [ApiException] nếu người nhận không hợp lệ.
  Future<void> assign(String id, int version, String assigneeId) async {
    await apiClient.post('/maintenance/tasks/$id/assign', body: {'version': version, 'assigneeId': assigneeId});
    await load();
  }
}

/// Việc sửa dùng chung. Một [MaintenanceNotifier], socket gắn trong constructor.
final maintenanceProvider =
    StateNotifierProvider<MaintenanceNotifier, MaintenanceState>((ref) {
  return MaintenanceNotifier();
});
