import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/realtime/socket_service.dart';
import '../../../models/housekeeping_task.dart';
import '../../../models/user.dart';
import '../../auth/providers/auth_provider.dart';

/// Danh sách việc dọn, cờ tải, lỗi và cờ kết nối (notifier không ghi cờ kết nối).
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

  /// Bản sao. [clearError] true thì xóa lỗi dù [error] được truyền.
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
  /// Nhân viên chỉ xem việc của mình (`mine=true`); quản lý xem tất cả.
  final bool mine;
  final String? userId;

  /// [mine] true thì GET chỉ việc của mình. [userId] lọc sự kiện socket.
  /// Side effect: gắn callback socket (ghi đè callback toàn cục) rồi [load].
  HousekeepingNotifier({this.mine = false, this.userId})
      : super(const HousekeepingState()) {
    socketService.onHousekeepingTaskUpdated = _handleTaskUpdated;
    load();
  }

  /// Thêm hoặc thay việc nếu version mới hơn. Khi [mine], bỏ việc của người khác.
  /// Không gọi API.
  void _handleTaskUpdated(Map<String, dynamic> taskJson) {
    final updated = HousekeepingTask.fromJson(taskJson);
    final idx = state.tasks.indexWhere((t) => t.id == updated.id);
    if (idx == -1) {
      if (mine && updated.assignee?.id != userId) return;
      state = state.copyWith(tasks: [...state.tasks, updated]);
    } else {
      final current = state.tasks[idx];
      if (updated.version <= current.version) return;
      final newTasks = [...state.tasks];
      newTasks[idx] = updated;
      state = state.copyWith(tasks: newTasks);
    }
  }

  /// GET `/housekeeping/tasks`, thêm `mine=true` khi [mine]. Lỗi ghi state, không ném tiếp.
  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await apiClient.get('/housekeeping/tasks',
          query: mine ? {'mine': 'true'} : null);
      final list = (res['data'] as List)
          .cast<Map<String, dynamic>>()
          .map(HousekeepingTask.fromJson)
          .toList();
      state = state.copyWith(tasks: list, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  /// POST nhận việc rồi [load]. Ném [ApiException] nếu version lệch hoặc sai trạng thái.
  Future<void> accept(String id, int version) async {
    await apiClient
        .post('/housekeeping/tasks/$id/accept', body: {'version': version});
    await load();
  }

  /// POST từ chối việc (về chờ giao) rồi [load]. Ném [ApiException] khi server từ chối.
  Future<void> reject(String id, int version) async {
    await apiClient
        .post('/housekeeping/tasks/$id/reject', body: {'version': version});
    await load();
  }

  /// [hasIssue]: nhân viên đánh dấu bất thường → server bắt buộc có ảnh cận cảnh (BR-housekeeping-006).
  Future<void> complete(String id, int version, {bool hasIssue = false}) async {
    await apiClient.post('/housekeeping/tasks/$id/complete',
        body: {'version': version, if (hasIssue) 'hasIssue': true});
    await load();
  }

  /// POST xác nhận sạch rồi [load]. Ném [ApiException] nếu việc chưa chờ xác nhận.
  Future<void> confirm(String id, int version) async {
    await apiClient
        .post('/housekeeping/tasks/$id/confirm', body: {'version': version});
    await load();
  }

  /// POST trả lại việc kèm [note] rồi [load]. Ném [ApiException] nếu server từ chối ghi chú.
  Future<void> returnTask(String id, int version, String note) async {
    await apiClient.post('/housekeeping/tasks/$id/return',
        body: {'version': version, 'note': note});
    await load();
  }

  /// POST giao hoặc giao lại cho [assigneeId] rồi [load]. Ném [ApiException] nếu người nhận không hợp lệ.
  Future<void> reassign(String id, int version, String assigneeId) async {
    await apiClient.post('/housekeeping/tasks/$id/reassign',
        body: {'version': version, 'assigneeId': assigneeId});
    await load();
  }
}

/// Việc dọn theo vai trò đăng nhập. Nhân viên thì [HousekeepingNotifier.mine] true.
final housekeepingProvider =
    StateNotifierProvider<HousekeepingNotifier, HousekeepingState>((ref) {
  final user = ref.watch(authProvider.select((s) => s.user));
  return HousekeepingNotifier(
      mine: user?.role == UserRole.staff, userId: user?.id);
});
