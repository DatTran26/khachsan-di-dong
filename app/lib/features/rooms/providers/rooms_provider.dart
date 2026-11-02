import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/realtime/socket_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../models/room.dart';

/// Bộ lọc danh sách phòng trên client. Không gửi lên API.
class RoomsFilter {
  final int? floor;
  final OccupancyStatus? occupancy;
  final CleaningStatus? cleaning;
  final ServiceStatus? service;
  final bool readyOnly;
  final String query;

  const RoomsFilter({
    this.floor,
    this.occupancy,
    this.cleaning,
    this.service,
    this.readyOnly = false,
    this.query = '',
  });

  /// Có ít nhất một tiêu chí khác mặc định. Ô tìm chỉ khoảng trắng vẫn tính là đang lọc.
  bool get isActive =>
      floor != null ||
      occupancy != null ||
      cleaning != null ||
      service != null ||
      readyOnly ||
      query.isNotEmpty;

  /// Bản sao. Truyền `null` cho tầng hoặc trục trạng thái để xóa tiêu chí đó
  /// (dùng sentinel nội bộ, không giữ giá trị cũ khi gọi `copyWith(floor: null)`).
  RoomsFilter copyWith({
    Object? floor = _sentinel,
    Object? occupancy = _sentinel,
    Object? cleaning = _sentinel,
    Object? service = _sentinel,
    bool? readyOnly,
    String? query,
  }) =>
      RoomsFilter(
        floor: floor == _sentinel ? this.floor : floor as int?,
        occupancy: occupancy == _sentinel
            ? this.occupancy
            : occupancy as OccupancyStatus?,
        cleaning:
            cleaning == _sentinel ? this.cleaning : cleaning as CleaningStatus?,
        service:
            service == _sentinel ? this.service : service as ServiceStatus?,
        readyOnly: readyOnly ?? this.readyOnly,
        query: query ?? this.query,
      );

  static const _sentinel = Object();
}

/// Danh sách phòng, bộ lọc, cờ tải, lỗi và trạng thái socket.
class RoomsState {
  final List<Room> rooms;
  final bool isLoading;
  final String? error;
  final RoomsFilter filter;
  final bool isConnected;
  final DateTime? lastUpdated;

  const RoomsState({
    this.rooms = const [],
    this.isLoading = false,
    this.error,
    this.filter = const RoomsFilter(),
    this.isConnected = false,
    this.lastUpdated,
  });

  /// Phòng khớp [filter], đã sắp bằng [compareRooms]. Không sửa [rooms].
  List<Room> get filtered {
    final q = filter.query.trim();
    final list = rooms.where((r) {
      if (filter.floor != null && r.floor != filter.floor) return false;
      if (filter.occupancy != null && r.occupancy != filter.occupancy) {
        return false;
      }
      if (filter.cleaning != null && r.cleaning != filter.cleaning) {
        return false;
      }
      if (filter.service != null && r.service != filter.service) return false;
      if (filter.readyOnly && !r.isReady) return false;
      if (q.isNotEmpty && !r.number.contains(q)) return false;
      return true;
    }).toList();
    list.sort(compareRooms);
    return list;
  }

  /// Mọi phòng, không lọc, sắp theo tầng rồi số phòng.
  List<Room> get sorted => [...rooms]..sort(compareRooms);

  /// Tầng tăng dần, rồi số phòng nếu cả hai là số, không thì so chuỗi.
  /// Giá trị âm nếu [a] đứng trước [b].
  static int compareRooms(Room a, Room b) {
    final byFloor = a.floor.compareTo(b.floor);
    if (byFloor != 0) return byFloor;
    final an = int.tryParse(a.number), bn = int.tryParse(b.number);
    if (an != null && bn != null) return an.compareTo(bn);
    return a.number.compareTo(b.number);
  }

  /// Phòng có [id], hoặc null nếu không còn trong danh sách đã tải.
  Room? byId(String id) {
    for (final r in rooms) {
      if (r.id == id) return r;
    }
    return null;
  }

  /// Các tầng đang có phòng, tăng dần, không trùng.
  List<int> get availableFloors {
    final floors = rooms.map((r) => r.floor).toSet().toList()..sort();
    return floors;
  }

  /// Bản sao. [clearError] true thì xóa lỗi dù [error] được truyền.
  RoomsState copyWith({
    List<Room>? rooms,
    bool? isLoading,
    String? error,
    RoomsFilter? filter,
    bool? isConnected,
    DateTime? lastUpdated,
    bool clearError = false,
  }) =>
      RoomsState(
        rooms: rooms ?? this.rooms,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        filter: filter ?? this.filter,
        isConnected: isConnected ?? this.isConnected,
        lastUpdated: lastUpdated ?? this.lastUpdated,
      );
}

/// Danh sách phòng và các lệnh ghi (nhận/trả, phục vụ, danh mục).
/// Constructor gắn socket rồi gọi [load].
class RoomsNotifier extends StateNotifier<RoomsState> {
  final ApiClient _apiClient;
  final SocketService _socketService;
  int _connectionGeneration = 0;
  int _loadGeneration = 0;

  /// Side effect: [_setupSocket] và [load] ngay khi tạo.
  RoomsNotifier({ApiClient? client, SocketService? realtime})
      : _apiClient = client ?? apiClient,
        _socketService = realtime ?? socketService,
        super(const RoomsState()) {
    _setupSocket();
    if (_socketService.isConnected) {
      _synchronizeAfterConnect();
    } else {
      load();
    }
  }

  /// Gắn callback phòng tạo/sửa/xóa và đổi kết nối. Ghi đè callback toàn cục của [socketService].
  void _setupSocket() {
    _socketService.onRoomUpdated = _handleRoomUpdated;
    _socketService.onRoomCreated = _handleRoomCreated;
    _socketService.onRoomDeleted = _handleRoomDeleted;
    _socketService.onConnectionChanged = _handleConnectionChanged;
  }

  /// Thay phòng trong state nếu payload mới hơn [Room.version]. Bỏ qua id lạ hoặc version cũ.
  /// Đặt [RoomsState.lastUpdated] để màn khác tải lại.
  void _handleRoomUpdated(Map<String, dynamic> roomJson) {
    final updated = Room.fromJson(roomJson);
    final idx = state.rooms.indexWhere((r) => r.id == updated.id);
    if (idx == -1) return;
    final current = state.rooms[idx];
    if (updated.version <= current.version) return;
    final newRooms = [...state.rooms];
    newRooms[idx] = updated;
    state = state.copyWith(rooms: newRooms, lastUpdated: DateTime.now());
  }

  /// Thêm phòng nếu chưa có cùng id. Cập nhật [RoomsState.lastUpdated].
  void _handleRoomCreated(Map<String, dynamic> roomJson) {
    final room = Room.fromJson(roomJson);
    if (state.rooms.any((r) => r.id == room.id)) return;
    state = state
        .copyWith(rooms: [...state.rooms, room], lastUpdated: DateTime.now());
  }

  /// Bỏ phòng [roomId] khỏi state. Không gọi API.
  void _handleRoomDeleted(String roomId) {
    final newRooms = state.rooms.where((r) => r.id != roomId).toList();
    state = state.copyWith(rooms: newRooms, lastUpdated: DateTime.now());
  }

  /// Mất kết nối thì khóa ghi ngay. Khi nối lại, chỉ mở khóa sau khi tải bản đầy đủ
  /// thành công và socket vẫn còn kết nối.
  void _handleConnectionChanged(bool connected) {
    if (!connected) {
      _connectionGeneration++;
      state = state.copyWith(isConnected: false);
      return;
    }
    _synchronizeAfterConnect();
  }

  Future<void> _synchronizeAfterConnect() async {
    final generation = ++_connectionGeneration;
    state = state.copyWith(isConnected: false);
    final refreshed = await _loadRooms();
    if (generation != _connectionGeneration || !_socketService.isConnected) {
      return;
    }
    if (refreshed) state = state.copyWith(isConnected: true);
  }

  /// GET `/rooms`. [ApiException] ghi lỗi vào state, không ném tiếp.
  Future<void> load() async {
    final connectionGeneration = _connectionGeneration;
    final refreshed = await _loadRooms();
    if (refreshed &&
        connectionGeneration == _connectionGeneration &&
        _socketService.isConnected &&
        !state.isConnected) {
      state = state.copyWith(isConnected: true);
    }
  }

  Future<bool> _loadRooms() async {
    final generation = ++_loadGeneration;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await _apiClient.get('/rooms');
      final list = (res['data'] as List)
          .cast<Map<String, dynamic>>()
          .map(Room.fromJson)
          .toList();
      if (generation != _loadGeneration) return false;
      state = state.copyWith(
        rooms: list,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
      return true;
    } on ApiException catch (e) {
      if (generation != _loadGeneration) return false;
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    }
  }

  /// Đổi bộ lọc local. Không gọi mạng.
  void setFilter(RoomsFilter filter) {
    state = state.copyWith(filter: filter);
  }

  /// Xóa mọi tiêu chí lọc, kể cả ô tìm.
  void clearFilter() {
    state = state.copyWith(filter: const RoomsFilter());
  }

  /// POST `/rooms/{id}/check-in`. [note] rỗng và [expectedCheckout] null thì không gửi.
  /// Trả `data` của response. Lỗi API ném [ApiException], không nuốt.
  Future<Map<String, dynamic>> checkIn({
    required String roomId,
    required int version,
    required String guestName,
    required int guestCount,
    String? note,
    DateTime? expectedCheckout,
  }) async {
    final body = <String, dynamic>{
      'version': version,
      'guestName': guestName,
      'guestCount': guestCount,
    };
    if (note != null && note.isNotEmpty) body['note'] = note;
    if (expectedCheckout != null) {
      body['expectedCheckout'] = expectedCheckout.toIso8601String();
    }
    final res = await _apiClient.post('/rooms/$roomId/check-in', body: body);
    return res['data'] as Map<String, dynamic>;
  }

  /// POST `/rooms/{id}/check-out` với [version] phòng. Trả `data`. Ném [ApiException] khi lỗi.
  Future<Map<String, dynamic>> checkOut({
    required String roomId,
    required int version,
  }) async {
    final res = await _apiClient
        .post('/rooms/$roomId/check-out', body: {'version': version});
    return res['data'] as Map<String, dynamic>;
  }

  /// POST `/rooms/{id}/out-of-service`. [confirmOccupied] true mới gửi cờ xác nhận phòng đang có khách.
  /// Không trả body. Ném [ApiException] khi server từ chối.
  Future<void> setOutOfService({
    required String roomId,
    required int version,
    required String reason,
    bool confirmOccupied = false,
  }) async {
    final body = <String, dynamic>{'version': version, 'reason': reason};
    if (confirmOccupied) body['confirmOccupied'] = true;
    await _apiClient.post('/rooms/$roomId/out-of-service', body: body);
  }

  /// POST `/rooms/{id}/back-in-service` với [version]. Ném [ApiException] nếu còn việc sửa mở.
  Future<void> backInService(
      {required String roomId, required int version}) async {
    await _apiClient
        .post('/rooms/$roomId/back-in-service', body: {'version': version});
  }

  /// POST `/rooms`. Trả `data` phòng vừa tạo. Ném khi trùng số hoặc thiếu quyền.
  Future<Map<String, dynamic>> createRoom({
    required String number,
    required int floor,
    required String roomTypeId,
  }) async {
    final res = await _apiClient.post('/rooms', body: {
      'number': number,
      'floor': floor,
      'roomTypeId': roomTypeId,
    });
    return res['data'] as Map<String, dynamic>;
  }

  /// POST `/rooms/bulk` cho dải số [from]–[to] trên [floor]. Trả `data` (created/skipped do server).
  Future<Map<String, dynamic>> createRoomRange({
    required int floor,
    required int from,
    required int to,
    required String roomTypeId,
  }) async {
    final res = await _apiClient.post('/rooms/bulk', body: {
      'floor': floor,
      'from': from,
      'to': to,
      'roomTypeId': roomTypeId,
    });
    return res['data'] as Map<String, dynamic>;
  }

  /// PATCH `/rooms/{id}`. Chỉ gửi [number], [floor], [roomTypeId] khi khác null, luôn gửi [version].
  /// Trả `data`. Ném [ApiException] khi xung đột version hoặc trùng số.
  Future<Map<String, dynamic>> updateRoom({
    required String roomId,
    required int version,
    String? number,
    int? floor,
    String? roomTypeId,
  }) async {
    final body = <String, dynamic>{'version': version};
    if (number != null) body['number'] = number;
    if (floor != null) body['floor'] = floor;
    if (roomTypeId != null) body['roomTypeId'] = roomTypeId;
    final res = await _apiClient.patch('/rooms/$roomId', body: body);
    return res['data'] as Map<String, dynamic>;
  }

  /// DELETE `/rooms/{id}` kèm [version] trong body. Ném [ApiException] nếu phòng đã có lịch sử.
  Future<void> deleteRoom(
      {required String roomId, required int version}) async {
    await _apiClient.delete('/rooms/$roomId', body: {'version': version});
  }
}

/// Danh sách phòng dùng chung. Một [RoomsNotifier], socket gắn trong constructor.
final roomsProvider = StateNotifierProvider<RoomsNotifier, RoomsState>((ref) {
  // Đổi tài khoản (đăng xuất → đăng nhập) thì dựng notifier mới: không giữ dữ liệu và cờ
  // mất kết nối của phiên trước (socket cũ bị ngắt lúc đăng xuất làm isConnected kẹt false).
  ref.watch(authProvider.select((s) => s.user?.id));
  return RoomsNotifier();
});

/// Đang kết nối realtime? Mất kết nối → khóa mọi nút ghi (realtime-sync FR: báo trạng thái + khóa ghi).
final isOnlineProvider = Provider<bool>(
    (ref) => ref.watch(roomsProvider.select((s) => s.isConnected)));
