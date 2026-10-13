import 'package:khachsan_di_dong/core/api/api_client.dart';
import 'package:khachsan_di_dong/features/ai_summary/providers/ai_summary_provider.dart';
import 'package:khachsan_di_dong/features/dashboard/providers/dashboard_provider.dart';
import 'package:khachsan_di_dong/features/rooms/providers/rooms_provider.dart';
import 'package:khachsan_di_dong/models/room.dart';

/// Notifier giả dùng chung cho widget test — không gọi API.

class FakeRooms extends RoomsNotifier {
  FakeRooms(List<Room> rooms) {
    state = RoomsState(rooms: rooms);
  }

  @override
  Future<void> load() async {}
}

class FakeDashboardSummary extends DashboardSummaryNotifier {
  FakeDashboardSummary(DashboardSummary summary) {
    state = DashboardSummaryState(summary: summary);
  }

  @override
  Future<void> load({bool silent = false}) async {}
}

/// Đếm số lần bấm tạo tóm tắt.
class FakeAiSummary extends AiSummaryNotifier {
  FakeAiSummary(AiSummaryState initial) {
    state = initial;
  }

  int generateCalls = 0;

  @override
  Future<void> load() async {}

  @override
  Future<ApiException?> generate() async {
    generateCalls++;
    return null;
  }
}

Room fakeRoom(String number,
        {String occupancy = 'VACANT',
        String cleaning = 'CLEAN',
        String service = 'IN_SERVICE'}) =>
    Room.fromJson({
      'id': 'r$number',
      'number': number,
      'floor': int.parse(number[0]),
      'roomType': {'id': 'std', 'name': 'Standard'},
      'occupancy': occupancy,
      'cleaning': cleaning,
      'service': service,
      'isReady': occupancy == 'VACANT' &&
          cleaning == 'CLEAN' &&
          service == 'IN_SERVICE',
      'version': 1,
      'updatedAt': '2026-10-13T00:00:00.000Z',
    });
