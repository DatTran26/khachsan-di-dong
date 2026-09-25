import 'package:socket_io_client/socket_io_client.dart' as io;

typedef RoomUpdatedCallback = void Function(Map<String, dynamic> roomJson);
typedef SessionRevokedCallback = void Function(String reason, String message);
typedef ConnectionCallback = void Function(bool connected);

class SocketService {
  io.Socket? _socket;

  RoomUpdatedCallback? onRoomUpdated;
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
          final authCodes = ['UNAUTHENTICATED', 'SESSION_EXPIRED', 'SESSION_INVALID'];
          if (authCodes.contains(code)) {
            onSessionRevoked?.call(code, 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
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
