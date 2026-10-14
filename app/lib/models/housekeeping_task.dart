/// Khớp enum `HousekeepingTaskStatus` phía BE:
/// UNASSIGNED → (quản lý giao) ASSIGNED → (nhân viên nhận) IN_PROGRESS → (báo xong) PENDING_CONFIRM
/// → (quản lý xác nhận) DONE; quản lý trả lại → IN_PROGRESS kèm `returnNote`; nhân viên từ chối → UNASSIGNED.
enum HousekeepingStatus {
  unassigned,
  assigned,
  inProgress,
  pendingConfirm,
  done
}

/// Nhãn tiếng Việt và mã API của [HousekeepingStatus].
extension HousekeepingStatusX on HousekeepingStatus {
  /// Nhãn trên thẻ việc. `assigned` là "Chờ nhận" (đã giao, nhân viên chưa nhận).
  String get label {
    switch (this) {
      case HousekeepingStatus.unassigned:
        return 'Chờ giao';
      case HousekeepingStatus.assigned:
        return 'Chờ nhận';
      case HousekeepingStatus.inProgress:
        return 'Đang dọn';
      case HousekeepingStatus.pendingConfirm:
        return 'Chờ kiểm tra';
      case HousekeepingStatus.done:
        return 'Hoàn tất';
    }
  }

  /// Mã gửi/nhận API: `UNASSIGNED`, `ASSIGNED`, `IN_PROGRESS`, `PENDING_CONFIRM`, `DONE`.
  String get value {
    switch (this) {
      case HousekeepingStatus.unassigned:
        return 'UNASSIGNED';
      case HousekeepingStatus.assigned:
        return 'ASSIGNED';
      case HousekeepingStatus.inProgress:
        return 'IN_PROGRESS';
      case HousekeepingStatus.pendingConfirm:
        return 'PENDING_CONFIRM';
      case HousekeepingStatus.done:
        return 'DONE';
    }
  }

  /// Parse mã API. Giá trị lạ thành [HousekeepingStatus.unassigned], không ném.
  static HousekeepingStatus fromString(String v) {
    switch (v) {
      case 'ASSIGNED':
        return HousekeepingStatus.assigned;
      case 'IN_PROGRESS':
        return HousekeepingStatus.inProgress;
      case 'PENDING_CONFIRM':
        return HousekeepingStatus.pendingConfirm;
      case 'DONE':
        return HousekeepingStatus.done;
      default:
        return HousekeepingStatus.unassigned;
    }
  }
}

/// Phòng rút gọn trên việc dọn: id, số, tầng.
class HousekeepingRoomRef {
  final String id;
  final String number;
  final int floor;

  const HousekeepingRoomRef(
      {required this.id, required this.number, required this.floor});

  /// Dựng từ object `room` của DTO việc. Thiếu khóa thì ném khi ép kiểu.
  factory HousekeepingRoomRef.fromJson(Map<String, dynamic> json) =>
      HousekeepingRoomRef(
        id: json['id'] as String,
        number: json['number'] as String,
        floor: json['floor'] as int,
      );
}

/// Người được giao: id và họ tên. Null trên việc chưa giao.
class HousekeepingAssigneeRef {
  final String id;
  final String fullName;

  const HousekeepingAssigneeRef({required this.id, required this.fullName});

  /// Dựng từ object `assignee`. Thiếu khóa thì ném khi ép kiểu.
  factory HousekeepingAssigneeRef.fromJson(Map<String, dynamic> json) =>
      HousekeepingAssigneeRef(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
      );
}

/// Một việc dọn. [isOverdue] và [version] do server tính/giữ, client không tự suy.
class HousekeepingTask {
  final String id;
  final HousekeepingRoomRef room;
  final HousekeepingAssigneeRef? assignee;
  final HousekeepingStatus status;
  final bool isOverdue;
  final DateTime dueAt;
  final String? returnNote;
  final DateTime createdAt;
  final DateTime? assignedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? confirmedAt;
  final int version;

  const HousekeepingTask({
    required this.id,
    required this.room,
    this.assignee,
    required this.status,
    required this.isOverdue,
    required this.dueAt,
    this.returnNote,
    required this.createdAt,
    this.assignedAt,
    this.startedAt,
    this.completedAt,
    this.confirmedAt,
    required this.version,
  });

  /// Dựng từ DTO `/housekeeping/tasks`. Mốc thời gian null nếu server không gửi.
  factory HousekeepingTask.fromJson(Map<String, dynamic> json) =>
      HousekeepingTask(
        id: json['id'] as String,
        room:
            HousekeepingRoomRef.fromJson(json['room'] as Map<String, dynamic>),
        assignee: json['assignee'] != null
            ? HousekeepingAssigneeRef.fromJson(
                json['assignee'] as Map<String, dynamic>)
            : null,
        status: HousekeepingStatusX.fromString(json['status'] as String),
        isOverdue: json['isOverdue'] as bool,
        dueAt: DateTime.parse(json['dueAt'] as String),
        returnNote: json['returnNote'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        assignedAt: json['assignedAt'] != null
            ? DateTime.parse(json['assignedAt'] as String)
            : null,
        startedAt: json['startedAt'] != null
            ? DateTime.parse(json['startedAt'] as String)
            : null,
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'] as String)
            : null,
        confirmedAt: json['confirmedAt'] != null
            ? DateTime.parse(json['confirmedAt'] as String)
            : null,
        version: json['version'] as int,
      );

  /// Bản sao chỉ đổi [status], [isOverdue], [version]. Trường null giữ giá trị cũ.
  /// Không đổi phòng, người giao hay ghi chú.
  HousekeepingTask copyWith(
          {HousekeepingStatus? status, bool? isOverdue, int? version}) =>
      HousekeepingTask(
        id: id,
        room: room,
        assignee: assignee,
        status: status ?? this.status,
        isOverdue: isOverdue ?? this.isOverdue,
        dueAt: dueAt,
        returnNote: returnNote,
        createdAt: createdAt,
        assignedAt: assignedAt,
        startedAt: startedAt,
        completedAt: completedAt,
        confirmedAt: confirmedAt,
        version: version ?? this.version,
      );
}
