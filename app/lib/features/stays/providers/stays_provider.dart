import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../models/stay.dart';

/// Danh sách lượt đang ở, cờ tải và lỗi gần nhất của `GET /stays`.
class StaysState {
  final List<Stay> stays;
  final bool isLoading;
  final String? error;

  const StaysState({
    this.stays = const [],
    this.isLoading = false,
    this.error,
  });

  /// Bản sao. [clearError] true thì xóa lỗi dù [error] được truyền.
  StaysState copyWith({
    List<Stay>? stays,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      StaysState(
        stays: stays ?? this.stays,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );
}

/// Tải các lượt lưu trú đang mở. Constructor gọi [load] ngay.
class StaysNotifier extends StateNotifier<StaysState> {
  /// Side effect: gọi [load] khi tạo.
  StaysNotifier() : super(const StaysState()) {
    load();
  }

  /// GET `/stays`, map từng phần tử bằng [Stay.fromJson].
  /// [ApiException] ghi vào state, không ném tiếp. Không lọc theo vai trò ở client.
  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await apiClient.get('/stays');
      final list = (res['data'] as List)
          .cast<Map<String, dynamic>>()
          .map(Stay.fromJson)
          .toList();
      state = state.copyWith(stays: list, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }
}

/// Lượt lưu trú đang mở. Riverpod giữ một [StaysNotifier] cho đến khi không còn listener.
final staysProvider = StateNotifierProvider<StaysNotifier, StaysState>((ref) {
  return StaysNotifier();
});
