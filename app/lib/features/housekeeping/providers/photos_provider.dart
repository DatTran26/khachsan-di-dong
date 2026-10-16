import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../models/housekeeping_photo.dart';

/// Ảnh của một việc, cờ tải, lỗi và tập nhóm đang upload.
class TaskPhotosState {
  final TaskPhotos? data;
  final bool isLoading;
  final String? error;

  /// Nhóm đang tải ảnh lên — ô của nhóm đó hiện "Đang tải…", các nút ghi khác vẫn dùng được.
  final Set<PhotoCategory> uploading;

  const TaskPhotosState({
    this.data,
    this.isLoading = false,
    this.error,
    this.uploading = const {},
  });

  /// Bản sao. [clearError] true thì xóa lỗi. [uploading] thay cả set khi được truyền.
  TaskPhotosState copyWith({
    TaskPhotos? data,
    bool? isLoading,
    String? error,
    bool clearError = false,
    Set<PhotoCategory>? uploading,
  }) =>
      TaskPhotosState(
        data: data ?? this.data,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        uploading: uploading ?? this.uploading,
      );
}

/// Ảnh nghiệm thu của một việc dọn (FR-housekeeping-005/007).
/// Nhân viên phụ trách tải/xóa khi việc đang làm; quản lý chỉ xem.
class TaskPhotosNotifier extends StateNotifier<TaskPhotosState> {
  final String taskId;

  /// Side effect: gọi [load] khi tạo.
  TaskPhotosNotifier(this.taskId) : super(const TaskPhotosState()) {
    load();
  }

  /// GET `/housekeeping/tasks/{id}/photos`. Bỏ qua nếu notifier đã dispose.
  /// [ApiException] ghi lỗi, không ném tiếp.
  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await apiClient.get('/housekeeping/tasks/$taskId/photos');
      if (!mounted) return;
      state = state.copyWith(
          data: TaskPhotos.fromJson(res['data'] as Map<String, dynamic>),
          isLoading: false);
    } on ApiException catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  /// Tải 1 ảnh vào nhóm. Nhóm bắt buộc: server thay ảnh cũ cùng nhóm của lượt hiện tại.
  Future<void> upload(PhotoCategory category, Uint8List bytes) async {
    state = state.copyWith(uploading: {...state.uploading, category});
    try {
      await apiClient.postBytes('/housekeeping/tasks/$taskId/photos', bytes,
          query: {'category': category.value});
      if (mounted) await load();
    } finally {
      if (mounted) {
        state =
            state.copyWith(uploading: {...state.uploading}..remove(category));
      }
    }
  }

  /// DELETE `/housekeeping/photos/{id}` rồi [load] nếu còn mounted. Ném [ApiException] nếu ảnh đã khóa.
  Future<void> delete(HousekeepingPhoto photo) async {
    await apiClient.delete('/housekeeping/photos/${photo.id}');
    if (mounted) await load();
  }
}

/// Ảnh theo [taskId]. Auto-dispose khi không còn widget xem.
final taskPhotosProvider = StateNotifierProvider.autoDispose
    .family<TaskPhotosNotifier, TaskPhotosState, String>(
        (ref, taskId) => TaskPhotosNotifier(taskId));

/// Byte của một ảnh (tải kèm token). Ảnh không đổi theo id → giữ trong bộ nhớ khi còn được xem.
final photoBytesProvider = FutureProvider.autoDispose.family<Uint8List, String>(
    (ref, photoId) => apiClient.getBytes('/housekeeping/photos/$photoId/file'));
