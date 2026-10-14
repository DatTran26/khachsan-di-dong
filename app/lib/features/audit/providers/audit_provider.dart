import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../models/audit_entry.dart';

/// Bộ lọc `GET /audit-logs`. [actorRole] là mã API (`MANAGER`, `RECEPTIONIST`, `STAFF`, `SYSTEM`) hoặc null.
class AuditFilter {
  final DateTime? from;
  final DateTime? to;
  final String? roomId;
  final String? actorRole; // MANAGER | RECEPTIONIST | STAFF | SYSTEM

  const AuditFilter({this.from, this.to, this.roomId, this.actorRole});

  /// Có ít nhất một tiêu chí. Dùng để hiện nút xóa lọc và câu gợi ý danh sách rỗng.
  bool get isActive =>
      from != null || to != null || roomId != null || actorRole != null;

  /// Bản sao. Truyền null cho một trường để xóa tiêu chí đó (sentinel nội bộ).
  AuditFilter copyWith({
    Object? from = _s,
    Object? to = _s,
    Object? roomId = _s,
    Object? actorRole = _s,
  }) =>
      AuditFilter(
        from: from == _s ? this.from : from as DateTime?,
        to: to == _s ? this.to : to as DateTime?,
        roomId: roomId == _s ? this.roomId : roomId as String?,
        actorRole: actorRole == _s ? this.actorRole : actorRole as String?,
      );

  /// Query string. Thời điểm đưa về UTC ISO. Trường null không có trong map.
  Map<String, dynamic> toQuery() => {
        if (from != null) 'from': from!.toUtc().toIso8601String(),
        if (to != null) 'to': to!.toUtc().toIso8601String(),
        if (roomId != null) 'roomId': roomId,
        if (actorRole != null) 'actorRole': actorRole,
      };

  static const _s = Object();
}

/// Trang nhật ký hiện có, con trỏ trang sau, cờ tải và thông báo rỗng từ server.
class AuditState {
  final List<AuditEntry> entries;
  final AuditFilter filter;
  final String? nextCursor;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final String? emptyMessage;

  const AuditState({
    this.entries = const [],
    this.filter = const AuditFilter(),
    this.nextCursor,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.emptyMessage,
  });

  /// Bản sao. [nextCursor], [error], [emptyMessage] nhận null để xóa (sentinel), khác [entries].
  AuditState copyWith({
    List<AuditEntry>? entries,
    AuditFilter? filter,
    Object? nextCursor = _s,
    bool? isLoading,
    bool? isLoadingMore,
    Object? error = _s,
    Object? emptyMessage = _s,
  }) =>
      AuditState(
        entries: entries ?? this.entries,
        filter: filter ?? this.filter,
        nextCursor: nextCursor == _s ? this.nextCursor : nextCursor as String?,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        error: error == _s ? this.error : error as String?,
        emptyMessage:
            emptyMessage == _s ? this.emptyMessage : emptyMessage as String?,
      );

  static const _s = Object();
}

/// Nhật ký thay đổi — chỉ quản lý (BE kiểm quyền). Phân trang theo con trỏ `nextCursor`.
class AuditNotifier extends StateNotifier<AuditState> {
  /// Side effect: gọi [load] khi tạo.
  AuditNotifier() : super(const AuditState()) {
    load();
  }

  static const _pageSize = 50;

  /// Ghi [f] rồi [load] từ đầu, bỏ trang đang có.
  Future<void> setFilter(AuditFilter f) async {
    state = state.copyWith(filter: f);
    await load();
  }

  /// Lượt tải mới nhất — đổi lọc liên tiếp thì phản hồi của lượt cũ về sau bị bỏ, không ghi đè kết quả lọc mới.
  int _loadSeq = 0;

  Future<void> load() async {
    final seq = ++_loadSeq;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await apiClient.get('/audit-logs',
          query: {...state.filter.toQuery(), 'limit': _pageSize});
      if (seq != _loadSeq) return;
      state = state.copyWith(
        entries: _parse(res),
        nextCursor: res['nextCursor'] as String?,
        emptyMessage: res['message'] as String?,
        isLoading: false,
      );
    } on ApiException catch (e) {
      if (seq != _loadSeq) return;
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  /// GET trang sau bằng [AuditState.nextCursor]. Không làm gì nếu hết trang hoặc đang tải thêm.
  /// Nối vào [entries]. Lỗi ghi state, không xóa trang đã có.
  Future<void> loadMore() async {
    final cursor = state.nextCursor;
    if (cursor == null || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final res = await apiClient.get('/audit-logs', query: {
        ...state.filter.toQuery(),
        'limit': _pageSize,
        'cursor': cursor,
      });
      state = state.copyWith(
        entries: [...state.entries, ..._parse(res)],
        nextCursor: res['nextCursor'] as String?,
        isLoadingMore: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.message);
    }
  }

  /// Map `data` thành [AuditEntry]. Thiếu `data` thì danh sách rỗng, không ném.
  List<AuditEntry> _parse(Map<String, dynamic> res) =>
      ((res['data'] as List?) ?? const [])
          .cast<Map<String, dynamic>>()
          .map(AuditEntry.fromJson)
          .toList();
}

/// Nhật ký dùng chung. Một [AuditNotifier]. Chỉ quản lý gọi được API, server trả 403 với vai trò khác.
final auditProvider =
    StateNotifierProvider<AuditNotifier, AuditState>((ref) => AuditNotifier());
