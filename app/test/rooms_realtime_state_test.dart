import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:khachsan_di_dong/core/api/api_client.dart';
import 'package:khachsan_di_dong/core/realtime/socket_service.dart';
import 'package:khachsan_di_dong/features/rooms/providers/rooms_provider.dart';

class _QueuedApiClient extends ApiClient {
  final requests = <Completer<Map<String, dynamic>>>[];

  @override
  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? query}) {
    final request = Completer<Map<String, dynamic>>();
    requests.add(request);
    return request.future;
  }
}

class _FakeRealtime extends SocketService {
  bool connected = false;

  @override
  bool get isConnected => connected;

  void emitConnection(bool value) {
    connected = value;
    onConnectionChanged?.call(value);
  }
}

Map<String, dynamic> _roomJson(String id, String number) => {
      'id': id,
      'number': number,
      'floor': 1,
      'roomType': {'id': 'type-1', 'name': 'Đôi'},
      'occupancy': 'VACANT',
      'cleaning': 'CLEAN',
      'service': 'IN_SERVICE',
      'isReady': true,
      'version': 1,
      'updatedAt': '2026-11-02T00:00:00.000Z',
    };

void main() {
  test('reconnect chỉ mở khóa sau khi tải lại phòng thành công', () async {
    final client = _QueuedApiClient();
    final realtime = _FakeRealtime();
    final notifier = RoomsNotifier(client: client, realtime: realtime);
    addTearDown(notifier.dispose);

    expect(notifier.state.isConnected, isFalse);
    expect(client.requests, hasLength(1));

    realtime.emitConnection(true);

    expect(notifier.state.isConnected, isFalse);
    expect(client.requests, hasLength(2));

    client.requests[1].complete({
      'data': [_roomJson('fresh', '102')],
    });
    await Future<void>.delayed(Duration.zero);

    expect(notifier.state.isConnected, isTrue);
    expect(notifier.state.rooms.single.id, 'fresh');

    client.requests[0].complete({
      'data': [_roomJson('stale', '101')],
    });
    await Future<void>.delayed(Duration.zero);

    expect(notifier.state.rooms.single.id, 'fresh');

    realtime.emitConnection(false);
    expect(notifier.state.isConnected, isFalse);
  });

  test('ngắt socket trong lúc refresh không mở khóa ghi trở lại', () async {
    final client = _QueuedApiClient();
    final realtime = _FakeRealtime();
    final notifier = RoomsNotifier(client: client, realtime: realtime);
    addTearDown(notifier.dispose);

    realtime.emitConnection(true);
    realtime.emitConnection(false);
    client.requests[1].complete({'data': <Map<String, dynamic>>[]});
    await Future<void>.delayed(Duration.zero);

    expect(notifier.state.isConnected, isFalse);

    client.requests[0].complete({'data': <Map<String, dynamic>>[]});
    await Future<void>.delayed(Duration.zero);
  });
}
