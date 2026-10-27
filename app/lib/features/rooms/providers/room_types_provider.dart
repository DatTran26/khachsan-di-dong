import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../models/room.dart';

/// Danh sách loại phòng, cờ tải và lỗi của `GET /room-types`.
class RoomTypesState {
  final List<RoomType> types;
  final bool isLoading;
  final String? error;

  const RoomTypesState({
    this.types = const [],
    this.isLoading = false,
    this.error,
  });

  /// Loại còn bật, đúng thứ tự server trả. Dùng cho dropdown thêm/sửa phòng.
  List<RoomType> get activeTypes => types.where((t) => t.isActive).toList();

  /// Bản sao. [clearError] true thì xóa lỗi dù [error] được truyền.
  RoomTypesState copyWith({List<RoomType>? types, bool? isLoading, String? error, bool clearError = false}) =>
      RoomTypesState(
        types: types ?? this.types,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );
}

/// Tải và sửa loại phòng. Constructor gọi [load]. Quyền quản lý do server kiểm.
class RoomTypesNotifier extends StateNotifier<RoomTypesState> {
  /// Side effect: gọi [load] khi tạo.
  RoomTypesNotifier() : super(const RoomTypesState()) {
    load();
  }

  /// GET `/room-types`. [ApiException] ghi lỗi vào state, không ném tiếp.
  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await apiClient.get('/room-types');
      final list = (res['data'] as List)
          .cast<Map<String, dynamic>>()
          .map(RoomType.fromJson)
          .toList();
      state = state.copyWith(types: list, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  /// Quản lý loại phòng (FR-room-catalog-010) — chỉ quản lý, server kiểm quyền và ghi nhật ký.
  Future<void> create(String name) async {
    await apiClient.post('/room-types', body: {'name': name});
    await load();
  }

  /// PATCH `/room-types/{id}` đổi [name], rồi [load] lại. Ném [ApiException] nếu trùng tên.
  Future<void> rename(String id, String name) async {
    await apiClient.patch('/room-types/$id', body: {'name': name});
    await load();
  }

  /// Tắt: phòng đang thuộc loại này giữ nguyên, chỉ không chọn được khi thêm/sửa phòng.
  Future<void> setActive(String id, bool isActive) async {
    await apiClient.patch('/room-types/$id', body: {'isActive': isActive});
    await load();
  }
}

/// Loại phòng dùng chung. Một [RoomTypesNotifier] cho đến khi không còn listener.
final roomTypesProvider = StateNotifierProvider<RoomTypesNotifier, RoomTypesState>((ref) {
  return RoomTypesNotifier();
});
