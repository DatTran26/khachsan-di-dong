import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../rooms/providers/rooms_provider.dart';

class DashboardSummary {
  final int totalRooms;
  final int occupied;
  final int ready;
  final int outOfService;
  final Map<String, int> cleaning;
  final int overdueHousekeeping;
  final int overdueMaintenance;
  final int overdueTotal;
  final int occupancyServiceable;
  final double? occupancyRate;
  final DateTime? asOf;

  const DashboardSummary({
    required this.totalRooms,
    required this.occupied,
    required this.ready,
    required this.outOfService,
    required this.cleaning,
    required this.overdueHousekeeping,
    required this.overdueMaintenance,
    required this.overdueTotal,
    required this.occupancyServiceable,
    this.occupancyRate,
    this.asOf,
  });

  static const empty = DashboardSummary(
    totalRooms: 0,
    occupied: 0,
    ready: 0,
    outOfService: 0,
    cleaning: {},
    overdueHousekeeping: 0,
    overdueMaintenance: 0,
    overdueTotal: 0,
    occupancyServiceable: 0,
  );

  /// Mẫu = 0 → "Không áp dụng" (FR-room-dashboard-004). Dấu thập phân kiểu Việt: 37,5%.
  String get occupancyRateLabel {
    if (occupancyRate == null) return 'Không áp dụng';
    final r = occupancyRate!;
    final s = r == r.roundToDouble()
        ? r.toStringAsFixed(0)
        : r.toStringAsFixed(1).replaceAll('.', ',');
    return '$s%';
  }

  int get needsCleaning => cleaning['DIRTY'] ?? 0;
  int get cleaningNow => cleaning['CLEANING'] ?? 0;
  int get pendingInspection => cleaning['PENDING_INSPECTION'] ?? 0;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final cleaningMap = (json['cleaning'] as Map<String, dynamic>?)
            ?.map((k, v) => MapEntry(k, (v as num).toInt())) ??
        {};
    final overdue = json['overdue'] as Map<String, dynamic>? ?? {};
    final occupancy = json['occupancy'] as Map<String, dynamic>? ?? {};
    return DashboardSummary(
      totalRooms: (json['totalRooms'] as num?)?.toInt() ?? 0,
      occupied: (json['occupied'] as num?)?.toInt() ?? 0,
      ready: (json['ready'] as num?)?.toInt() ?? 0,
      outOfService: (json['outOfService'] as num?)?.toInt() ?? 0,
      cleaning: cleaningMap,
      overdueHousekeeping: (overdue['housekeeping'] as num?)?.toInt() ?? 0,
      overdueMaintenance: (overdue['maintenance'] as num?)?.toInt() ?? 0,
      overdueTotal: (overdue['total'] as num?)?.toInt() ?? 0,
      occupancyServiceable: (occupancy['serviceable'] as num?)?.toInt() ?? 0,
      occupancyRate: occupancy['rate'] != null
          ? (occupancy['rate'] as num).toDouble()
          : null,
      asOf:
          json['asOf'] != null ? DateTime.parse(json['asOf'] as String) : null,
    );
  }
}

class DashboardSummaryState {
  final DashboardSummary summary;
  final bool isLoading;
  final String? error;

  const DashboardSummaryState({
    this.summary = DashboardSummary.empty,
    this.isLoading = false,
    this.error,
  });

  DashboardSummaryState copyWith({
    DashboardSummary? summary,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      DashboardSummaryState(
        summary: summary ?? this.summary,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );
}

class DashboardSummaryNotifier extends StateNotifier<DashboardSummaryState> {
  DashboardSummaryNotifier() : super(const DashboardSummaryState()) {
    load();
  }

  Timer? _debounce;

  /// Có thay đổi realtime → tải lại chỉ số (gom nhiều sự kiện liền nhau thành một lần gọi).
  void scheduleReload() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      if (mounted) load(silent: true);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> load({bool silent = false}) async {
    if (!silent) state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await apiClient.get('/dashboard/summary');
      final summary =
          DashboardSummary.fromJson(res['data'] as Map<String, dynamic>);
      state = state.copyWith(summary: summary, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }
}

final dashboardSummaryProvider =
    StateNotifierProvider<DashboardSummaryNotifier, DashboardSummaryState>(
        (ref) {
  final notifier = DashboardSummaryNotifier();
  ref.listen(roomsProvider.select((s) => s.lastUpdated),
      (_, __) => notifier.scheduleReload());
  return notifier;
});
