import 'package:socket_io_client/socket_io_client.dart' as io;

import '../api/api_config.dart';

/// Callback nhận JSON phòng từ `room:updated` hoặc `room:created`.
typedef RoomJsonCallback = void Function(Map<String, dynamic> json);
/// Callback khi `room:deleted`. [roomId] là UUID, không phải số phòng.
typedef RoomIdCallback = void Function(String roomId);
/// Callback nhận DTO việc dọn hoặc việc sửa.
typedef TaskJsonCallback = void Function(Map<String, dynamic> json);
/// Callback snackbar. [kind] là mã server. [taskId] và [roomId] có thể null.
typedef NotificationCallback = void Function(String kind, String message, String? taskId, String? roomId);
/// Callback khi phiên chết. [reason] là mã (`LOGGED_OUT`, `EXPIRED`, …) hoặc mã lỗi kết nối.
typedef SessionRevokedCallback = void Function(String reason, String message);
/// Callback đổi trạng thái socket. `true` sau `onConnect`, `false` khi đứt hoặc lỗi.
typedef ConnectionCallback = void Function(bool connected);

/// Một kết nối Socket.IO tới backend.
///
/// Mọi thao tác ghi vẫn đi REST. Socket chỉ nhận sự kiện.
/// [connect] hủy socket cũ trước khi mở socket mới. URL mặc định [apiUrl].
class SocketService {
  io.Socket? _socket;

  RoomJsonCallback? onRoomUpdated;
  RoomJsonCallback? onRoomCreated;
  RoomIdCallback? onRoomDeleted;
  TaskJsonCallback? onHousekeepingTaskUpdated;
  TaskJsonCallback? onMaintenanceTaskUpdated;
  NotificationCallback? onNotification;
  SessionRevokedCallback? onSessionRevoked;
  ConnectionCallback? onConnectionChanged;

  /// Có việc dọn / việc sửa đổi trạng thái (kể cả bị cờ quá hạn) — dashboard dùng để tải lại chỉ số.
  /// Tách riêng khỏi callback của từng provider vì vai trò không xem danh sách việc vẫn cần biết.
  void Function()? onTaskChanged;

  bool _connected = false;

  /// `true` chỉ sau sự kiện connect, không phải sau khi gọi [connect].
  bool get isConnected => _connected;

  /// Mở socket với [token] phiên. Handshake `auth.token`.
  ///
  /// Bật reconnect của thư viện. Lỗi kết nối/handshake xử lý ở [_handleConnectError].
  /// [url] mặc định [apiUrl] — cùng host với REST (`--dart-define=API_URL`).
  void connect(String token, {String url = apiUrl}) {
    _socket?.dispose();
    _socket = io.io(
      url,
      io.OptionBuilder()
          // Bắt buộc: thư viện cache Manager theo URL và trả lại socket cũ (đã dispose, còn
          // token cũ) → đăng xuất rồi đăng nhập lại sẽ bắt tay bằng token đã bị thu hồi.
          .enableForceNew()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .setTimeout(5000)
          .enableReconnection()
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .build(),
    );

    _socket!.onConnect((_) {
      _connected = true;
      onConnectionChanged?.call(true);
    });

    _socket!.onDisconnect((_) {
      _connected = false;
      onConnectionChanged?.call(false);
    });

    // Lỗi tầng mạng (không tới được server) → `connect_error`, thư viện tự reconnect.
    _socket!.onConnectError(_handleConnectError);
    // Server từ chối handshake (middleware `io.use`) → socket_io_client 2.x phát `error`,
    // KHÔNG phát `connect_error`. Thiếu listener này thì phiên hết hạn/bị hủy không bao giờ
    // được báo về auth → app kẹt banner "Mất kết nối" dù mạng vẫn bình thường.
    _socket!.on('error', _handleConnectError);

    _socket!.on('room:updated', (data) {
      if (data is Map<String, dynamic>) {
        final room = data['room'] as Map<String, dynamic>?;
        if (room != null) onRoomUpdated?.call(room);
      }
    });

    _socket!.on('room:created', (data) {
      if (data is Map<String, dynamic>) {
        final room = data['room'] as Map<String, dynamic>?;
        if (room != null) onRoomCreated?.call(room);
      }
    });

    _socket!.on('room:deleted', (data) {
      if (data is Map<String, dynamic>) {
        final roomId = data['roomId'] as String?;
        if (roomId != null) onRoomDeleted?.call(roomId);
      }
    });

    _socket!.on('housekeeping:task_updated', (data) {
      if (data is Map<String, dynamic>) {
        final task = data['task'] as Map<String, dynamic>?;
        if (task != null) onHousekeepingTaskUpdated?.call(task);
        onTaskChanged?.call();
      }
    });

    _socket!.on('maintenance:task_updated', (data) {
      if (data is Map<String, dynamic>) {
        final task = data['task'] as Map<String, dynamic>?;
        if (task != null) onMaintenanceTaskUpdated?.call(task);
        onTaskChanged?.call();
      }
    });

    _socket!.on('notification', (data) {
      if (data is Map<String, dynamic>) {
        final kind = data['kind'] as String? ?? '';
        final message = data['message'] as String? ?? '';
        final taskId = data['taskId'] as String?;
        final roomId = data['roomId'] as String?;
        onNotification?.call(kind, message, taskId, roomId);
      }
    });

    _socket!.on('session:revoked', (data) {
      if (data is Map<String, dynamic>) {
        final reason = data['reason'] as String? ?? '';
        final message = data['message'] as String? ?? 'Phiên đăng nhập đã kết thúc.';
        onSessionRevoked?.call(reason, message);
      }
    });

    _socket!.connect();
  }

  /// Xử lý lỗi kết nối/handshake. [data] từ server có dạng `{message, data: {code}}`.
  ///
  /// Mã phiên chết → [onSessionRevoked]. Mã khác (kể cả `PASSWORD_CHANGE_REQUIRED`)
  /// thì tự [connect] lại sau 3 giây nếu vẫn là cùng socket và chưa nối.
  /// Lỗi mạng không có mã → để reconnect của thư viện lo.
  void _handleConnectError(dynamic data) {
    _connected = false;
    onConnectionChanged?.call(false);
    if (data is Map && data['data'] is Map) {
      final code = data['data']['code'] as String?;
      if (code != null) {
        const authCodes = ['UNAUTHENTICATED', 'SESSION_EXPIRED', 'SESSION_INVALID', 'ACCOUNT_LOCKED'];
        if (authCodes.contains(code)) {
          onSessionRevoked?.call(code, 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
        } else {
          // Lỗi từ middleware server (vd INTERNAL_ERROR) → socket.io không tự thử lại; tự thử sau 3s.
          final socket = _socket;
          Future.delayed(const Duration(seconds: 3), () {
            if (identical(socket, _socket) && !_connected) socket?.connect();
          });
        }
      }
    }
  }

  /// Đóng socket và đánh dấu ngắt. Không gọi [onConnectionChanged].
  /// Không xóa các callback đã gán.
  void disconnect() {
    _socket?.dispose();
    _socket = null;
    _connected = false;
  }

  /// Chuỗi debug, không gồm token.
  @override
  String toString() => 'SocketService(connected: $_connected)';
}

/// Singleton. Auth và các provider gán callback trên instance này.
final socketService = SocketService();
