import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/realtime/socket_service.dart';
import '../../../models/user.dart';
import '../../auth/providers/auth_provider.dart';
import '../../rooms/providers/rooms_provider.dart';

/// Một việc quá hạn đang mở (`overdue.tasks`) — để chi tiết phòng mở đúng màn việc.
class OverdueTask {
  final String type; // HOUSEKEEPING | MAINTENANCE
  final String taskId;
  final String roomId;

  const OverdueTask(
      {required this.type, required this.taskId, required this.roomId});

  /// `true` khi [type] là `HOUSEKEEPING`. Mọi mã khác coi là việc sửa.
  bool get isHousekeeping => type == 'HOUSEKEEPING';
}

/// Chỉ số tổng quan một thời điểm, khớp `GET /dashboard/summary`.
class DashboardSummary {
  final int totalRooms;
  final int occupied;
  final int ready;
  final int outOfService;
  final Map<String, int> cleaning;
  final int overdueHousekeeping;
  final int overdueMaintenance;
  final int overdueTotal;

  /// Phòng đang có việc quá hạn (từ `overdue.tasks`) — tô cờ ô phòng cho mọi vai trò xem dashboard (FR-006).
  final Set<String> overdueRoomIds;
  final List<OverdueTask> overdueTasks;
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
    this.overdueRoomIds = const {},
    this.overdueTasks = const [],
    required this.occupancyServiceable,
    this.occupancyRate,
    this.asOf,
  });

  /// Bản rỗng trước lần tải thành công. [asOf] null để UI không hiện số 0 như dữ liệu thật.
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

  /// Việc quá hạn của phòng [roomId]. Rỗng nếu phòng không có việc trong `overdue.tasks`.
  List<OverdueTask> overdueTasksOf(String roomId) =>
      overdueTasks.where((t) => t.roomId == roomId).toList();

  /// Số phòng `DIRTY`. Thiếu khóa trong [cleaning] thì 0.
  int get needsCleaning => cleaning['DIRTY'] ?? 0;

  /// Số phòng `CLEANING`. Thiếu khóa thì 0.
  int get cleaningNow => cleaning['CLEANING'] ?? 0;

  /// Số phòng `PENDING_INSPECTION`. Thiếu khóa thì 0.
  int get pendingInspection => cleaning['PENDING_INSPECTION'] ?? 0;

  /// Dựng từ JSON summary. Khối lồng nhau thiếu thì coi là rỗng, không ném.
  /// [overdueRoomIds] lấy từ danh sách task, không đọc một mảng id riêng.
  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final cleaningMap = (json['cleaning'] as Map<String, dynamic>?)
            ?.map((k, v) => MapEntry(k, (v as num).toInt())) ??
        {};
    final overdue = json['overdue'] as Map<String, dynamic>? ?? {};
    final occupancy = json['occupancy'] as Map<String, dynamic>? ?? {};
    final tasks = [
      for (final t in (overdue['tasks'] as List?) ?? const [])
        OverdueTask(
          type: (t as Map<String, dynamic>)['type'] as String,
          taskId: t['taskId'] as String,
          roomId: t['roomId'] as String,
        ),
    ];
    return DashboardSummary(
      totalRooms: (json['totalRooms'] as num?)?.toInt() ?? 0,
      occupied: (json['occupied'] as num?)?.toInt() ?? 0,
      ready: (json['ready'] as num?)?.toInt() ?? 0,
      outOfService: (json['outOfService'] as num?)?.toInt() ?? 0,
      cleaning: cleaningMap,
      overdueHousekeeping: (overdue['housekeeping'] as num?)?.toInt() ?? 0,
      overdueMaintenance: (overdue['maintenance'] as num?)?.toInt() ?? 0,
      overdueTotal: (overdue['total'] as num?)?.toInt() ?? 0,
      overdueRoomIds: {for (final t in tasks) t.roomId},
      overdueTasks: tasks,
      occupancyServiceable: (occupancy['serviceable'] as num?)?.toInt() ?? 0,
      occupancyRate: occupancy['rate'] != null
          ? (occupancy['rate'] as num).toDouble()
          : null,
      asOf:
          json['asOf'] != null ? DateTime.parse(json['asOf'] as String) : null,
    );
  }
}

/// Trạng thái tải chỉ số: dữ liệu hiện có, cờ đang tải, thông báo lỗi gần nhất.
class DashboardSummaryState {
  final DashboardSummary summary;
  final bool isLoading;
  final String? error;

  const DashboardSummaryState({
    this.summary = DashboardSummary.empty,
    this.isLoading = false,
    this.error,
  });

  /// Bản sao. [clearError] true thì xóa lỗi kể cả khi [error] được truyền.
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

/// Giữ [DashboardSummary] và tải lại từ API. Tự gọi [load] trong constructor.
class DashboardSummaryNotifier extends StateNotifier<DashboardSummaryState> {
  /// `false` → vai trò không được xem chỉ số (nhân viên / chưa đăng nhập): không gọi API.
  final bool enabled;

  /// [enabled] false vẫn tạo state rỗng nhưng [load] không gọi API.
  /// Side effect: gọi [load] ngay khi khởi tạo.
  DashboardSummaryNotifier({this.enabled = true})
      : super(const DashboardSummaryState()) {
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

  /// Hủy timer gom sự kiện rồi hủy notifier. Không gọi API.
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  /// GET `/dashboard/summary` rồi ghi state.
  /// [silent] true không bật cờ tải (reload realtime). [enabled] false thì thoát ngay, không gọi mạng.
  /// [ApiException] ghi [DashboardSummaryState.error], không ném tiếp.
  Future<void> load({bool silent = false}) async {
    if (!enabled) return;
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

/// Chỉ số dashboard theo vai trò đang đăng nhập.
/// Nhân viên hoặc chưa có user: notifier tắt, không gọi API và không nghe socket.
/// Quản lý và lễ tân: [DashboardSummaryNotifier.scheduleReload] khi phòng đổi hoặc việc dọn/sửa đổi.
final dashboardSummaryProvider =
    StateNotifierProvider<DashboardSummaryNotifier, DashboardSummaryState>(
        (ref) {
  // Chỉ số chỉ dành cho quản lý + lễ tân (BE trả 403 cho nhân viên). App mở `/dashboard` trước khi biết
  // vai trò, provider lại không tự hủy → phải theo vai trò, không thì nhân viên vẫn gọi API mỗi lần phòng đổi.
  final role = ref.watch(authProvider.select((s) => s.user?.role));
  final canView = role == UserRole.manager || role == UserRole.receptionist;
  final notifier = DashboardSummaryNotifier(enabled: canView);
  if (!canView) return notifier;
  ref.listen(roomsProvider.select((s) => s.lastUpdated),
      (_, __) => notifier.scheduleReload());
  // Việc dọn/sửa đổi trạng thái hoặc bị cờ quá hạn không phát room:updated → nghe riêng (FR-005, ≤3s).
  socketService.onTaskChanged = notifier.scheduleReload;
  ref.onDispose(() => socketService.onTaskChanged = null);
  return notifier;
});
