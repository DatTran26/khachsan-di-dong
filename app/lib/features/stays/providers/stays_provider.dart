import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../models/stay.dart';

class StaysState {
  final List<Stay> stays;
  final bool isLoading;
  final String? error;

  const StaysState({
    this.stays = const [],
    this.isLoading = false,
    this.error,
  });

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

class StaysNotifier extends StateNotifier<StaysState> {
  StaysNotifier() : super(const StaysState()) {
    load();
  }

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

final staysProvider = StateNotifierProvider<StaysNotifier, StaysState>((ref) {
  return StaysNotifier();
});
