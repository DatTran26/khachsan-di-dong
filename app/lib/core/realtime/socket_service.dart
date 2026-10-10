import 'package:socket_io_client/socket_io_client.dart' as io;

typedef RoomJsonCallback = void Function(Map<String, dynamic> json);
typedef RoomIdCallback = void Function(String roomId);
typedef TaskJsonCallback = void Function(Map<String, dynamic> json);
typedef NotificationCallback = void Function(String kind, String message, String? taskId, String? roomId);
typedef SessionRevokedCallback = void Function(String reason, String message);
typedef ConnectionCallback = void Function(bool connected);

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

  bool _connected = false;
  bool get isConnected => _connected;

  void connect(String token, {String url = 'http://localhost:3000'}) {
    _socket?.dispose();
    _socket = io.io(
      url,
      io.OptionBuilder()
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

    _socket!.onConnectError((data) {
      _connected = false;
      onConnectionChanged?.call(false);
      if (data is Map && data['data'] is Map) {
        final code = data['data']['code'] as String?;
        if (code != null) {
          const authCodes = ['UNAUTHENTICATED', 'SESSION_EXPIRED', 'SESSION_INVALID'];
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
    });

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
      }
    });

    _socket!.on('maintenance:task_updated', (data) {
      if (data is Map<String, dynamic>) {
        final task = data['task'] as Map<String, dynamic>?;
        if (task != null) onMaintenanceTaskUpdated?.call(task);
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

  void disconnect() {
    _socket?.dispose();
    _socket = null;
    _connected = false;
  }

  @override
  String toString() => 'SocketService(connected: $_connected)';
}

final socketService = SocketService();
