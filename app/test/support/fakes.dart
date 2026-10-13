import 'package:khachsan_di_dong/core/api/api_client.dart';
import 'package:khachsan_di_dong/features/ai_summary/providers/ai_summary_provider.dart';
import 'package:khachsan_di_dong/features/auth/providers/auth_provider.dart';
import 'package:khachsan_di_dong/features/dashboard/providers/dashboard_provider.dart';
import 'package:khachsan_di_dong/features/housekeeping/providers/housekeeping_provider.dart';
import 'package:khachsan_di_dong/features/housekeeping/providers/photos_provider.dart';
import 'package:khachsan_di_dong/features/rooms/providers/room_types_provider.dart';
import 'package:khachsan_di_dong/features/rooms/providers/rooms_provider.dart';
import 'package:khachsan_di_dong/models/housekeeping_photo.dart';
import 'package:khachsan_di_dong/models/housekeeping_task.dart';
import 'package:khachsan_di_dong/models/room.dart';
import 'package:khachsan_di_dong/models/user.dart';

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
  Future<void> loadBudget() async {}

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

/// Danh sách việc dọn giả; ghi lại các lần báo xong.
class FakeHousekeeping extends HousekeepingNotifier {
  FakeHousekeeping(List<HousekeepingTask> tasks) : super(mine: true) {
    state = HousekeepingState(tasks: tasks);
  }

  final completed = <(String, bool)>[];

  @override
  Future<void> load() async {}

  @override
  Future<void> complete(String id, int version, {bool hasIssue = false}) async {
    completed.add((id, hasIssue));
    state = HousekeepingState(tasks: [
      for (final t in state.tasks)
        t.id == id ? t.copyWith(status: HousekeepingStatus.pendingConfirm) : t,
    ]);
  }
}

/// Ảnh nghiệm thu giả — không gọi API.
class FakeTaskPhotos extends TaskPhotosNotifier {
  FakeTaskPhotos(super.taskId, TaskPhotos data) {
    state = TaskPhotosState(data: data);
  }

  @override
  Future<void> load() async {}
}

HousekeepingTask fakeHousekeepingTask(
        {String id = 't1',
        String status = 'IN_PROGRESS',
        String? returnNote}) =>
    HousekeepingTask.fromJson({
      'id': id,
      'room': {'id': 'r104', 'number': '104', 'floor': 1},
      'assignee': {'id': 'u4', 'fullName': 'Phạm Thị Buồng Phòng'},
      'status': status,
      'isOverdue': false,
      'dueAt': '2026-10-13T05:00:00.000Z',
      'returnNote': returnNote,
      'createdAt': '2026-10-13T04:00:00.000Z',
      'version': 3,
    });

TaskPhotos fakeTaskPhotos(List<String> categories) => TaskPhotos.fromJson({
      'currentRound': 1,
      'photos': [
        for (var i = 0; i < categories.length; i++)
          {
            'id': 'p$i',
            'category': categories[i],
            'round': 1,
            'sizeBytes': 1000,
            'createdAt': '2026-10-13T04:30:00.000Z',
          },
      ],
    });

/// Loại phòng giả; ghi lại thao tác thêm / đổi tên / tắt–bật.
class FakeRoomTypes extends RoomTypesNotifier {
  FakeRoomTypes(List<RoomType> types) {
    state = RoomTypesState(types: types);
  }

  final calls = <String>[];

  @override
  Future<void> load() async {}

  @override
  Future<void> create(String name) async {
    calls.add('create:$name');
    state = RoomTypesState(
        types: [...state.types, RoomType(id: 'new', name: name)]);
  }

  @override
  Future<void> rename(String id, String name) async =>
      calls.add('rename:$id:$name');

  @override
  Future<void> setActive(String id, bool isActive) async =>
      calls.add('active:$id:$isActive');
}

/// Người đang đăng nhập giả. Cần `SharedPreferences.setMockInitialValues({})` trước khi dùng
/// (AuthNotifier gốc vẫn đọc token lúc khởi tạo — không có token thì giữ nguyên user giả).
class FakeAuth extends AuthNotifier {
  FakeAuth(AppUser? user) {
    state = AuthState(user: user, initialized: true);
  }
}

AppUser fakeUser(String role) => AppUser.fromJson({
      'id': 'u-$role',
      'phone': '0900000000',
      'fullName': 'Người dùng $role',
      'role': role,
      'status': 'ACTIVE',
      'mustChangePassword': false,
      'onDuty': true,
      'version': 1,
      'createdAt': '2026-10-01T00:00:00.000Z',
    });

