import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../models/room.dart';

class RoomTypesState {
  final List<RoomType> types;
  final bool isLoading;
  final String? error;

  const RoomTypesState({
    this.types = const [],
    this.isLoading = false,
    this.error,
  });

  List<RoomType> get activeTypes => types.where((t) => t.isActive).toList();

  RoomTypesState copyWith({List<RoomType>? types, bool? isLoading, String? error, bool clearError = false}) =>
      RoomTypesState(
        types: types ?? this.types,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );
}

class RoomTypesNotifier extends StateNotifier<RoomTypesState> {
  RoomTypesNotifier() : super(const RoomTypesState()) {
    load();
  }

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

final roomTypesProvider = StateNotifierProvider<RoomTypesNotifier, RoomTypesState>((ref) {
  return RoomTypesNotifier();
});
