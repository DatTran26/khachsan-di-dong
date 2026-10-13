import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../models/ai_summary.dart';

class AiSummaryState {
  final SummaryPeriod period;

  /// Bản gần nhất của mỗi kỳ (FR-013) — xem lại không gọi AI.
  final Map<SummaryPeriod, AiSummary?> latest;

  /// Hạn mức AI; null khi chưa tải được (không chặn việc tạo — server vẫn tự kiểm).
  final AiBudget? budget;

  /// Thông báo kèm lượt tạo vừa xong (chưa cấu hình / hết hạn mức / AI lỗi / kỳ rỗng).
  final String? notice;
  final bool isLoading;
  final bool isGenerating;
  final String? error;

  const AiSummaryState({
    this.period = SummaryPeriod.currentShift,
    this.latest = const {},
    this.budget,
    this.notice,
    this.isLoading = false,
    this.isGenerating = false,
    this.error,
  });

  AiSummary? get current => latest[period];

  AiSummaryState copyWith({
    SummaryPeriod? period,
    Map<SummaryPeriod, AiSummary?>? latest,
    AiBudget? budget,
    String? notice,
    bool clearNotice = false,
    bool? isLoading,
    bool? isGenerating,
    String? error,
    bool clearError = false,
  }) =>
      AiSummaryState(
        period: period ?? this.period,
        latest: latest ?? this.latest,
        budget: budget ?? this.budget,
        notice: clearNotice ? null : (notice ?? this.notice),
        isLoading: isLoading ?? this.isLoading,
        isGenerating: isGenerating ?? this.isGenerating,
        error: clearError ? null : (error ?? this.error),
      );
}

class AiSummaryNotifier extends StateNotifier<AiSummaryState> {
  AiSummaryNotifier() : super(const AiSummaryState()) {
    load();
    loadBudget();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await apiClient.get('/ai-summaries/latest');
      if (!mounted) return;
      final data = res['data'] as Map<String, dynamic>;
      state = state.copyWith(
        isLoading: false,
        latest: {
          for (final p in SummaryPeriod.values)
            p: data[p.value] == null
                ? null
                : AiSummary.fromJson(data[p.value] as Map<String, dynamic>),
        },
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  /// Hạn mức tải riêng, lỗi thì bỏ qua — chỉ là dòng thông tin phụ.
  Future<void> loadBudget() async {
    try {
      final res = await apiClient.get('/ai-summaries/budget');
      if (!mounted) return;
      state = state.copyWith(
          budget: AiBudget.fromJson(res['data'] as Map<String, dynamic>));
    } on ApiException {
      // Giữ hạn mức cũ (nếu có).
    }
  }

  void selectPeriod(SummaryPeriod period) =>
      state = state.copyWith(period: period, clearNotice: true);

  /// Tạo bản tóm tắt cho kỳ đang chọn. Đang tạo → bỏ qua lượt bấm thêm (FR-008, chống bấm 2 lần).
  /// Lỗi trả về để màn hình báo (vd 409 đang có lượt khác chạy).
  Future<ApiException?> generate() async {
    if (state.isGenerating) return null;
    final period = state.period;
    state = state.copyWith(isGenerating: true, clearNotice: true);
    try {
      final res = await apiClient.post('/ai-summaries',
          body: {'period': period.value},
          receiveTimeout: const Duration(seconds: 30));
      // Rời màn khi đang tạo → bản vẫn được lưu ở server, mở lại sẽ thấy trong "bản gần nhất".
      if (!mounted) return null;
      final summary = AiSummary.fromJson(res['data'] as Map<String, dynamic>);
      state = state.copyWith(
        isGenerating: false,
        latest: {...state.latest, period: summary},
        // Kỳ rỗng: câu thông báo trùng phần tổng quan → không lặp lại ở banner.
        notice: summary.source == SummarySource.empty
            ? null
            : res['notice'] as String?,
      );
      loadBudget(); // lượt vừa rồi có thể đã tốn chi phí
      return null;
    } on ApiException catch (e) {
      if (mounted) state = state.copyWith(isGenerating: false);
      return e;
    }
  }
}

final aiSummaryProvider =
    StateNotifierProvider.autoDispose<AiSummaryNotifier, AiSummaryState>(
        (ref) => AiSummaryNotifier());
