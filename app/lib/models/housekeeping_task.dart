enum HousekeepingStatus { pending, accepted, cleaning, pendingInspection, done }

extension HousekeepingStatusX on HousekeepingStatus {
  String get label {
    switch (this) {
      case HousekeepingStatus.pending:
        return 'Chờ giao';
      case HousekeepingStatus.accepted:
        return 'Đã nhận';
      case HousekeepingStatus.cleaning:
        return 'Đang dọn';
      case HousekeepingStatus.pendingInspection:
        return 'Chờ xác nhận';
      case HousekeepingStatus.done:
        return 'Hoàn tất';
    }
  }

  String get value {
    switch (this) {
      case HousekeepingStatus.pending:
        return 'PENDING';
      case HousekeepingStatus.accepted:
        return 'ACCEPTED';
      case HousekeepingStatus.cleaning:
        return 'CLEANING';
      case HousekeepingStatus.pendingInspection:
        return 'PENDING_INSPECTION';
      case HousekeepingStatus.done:
        return 'DONE';
    }
  }

  static HousekeepingStatus fromString(String v) {
    switch (v) {
      case 'ACCEPTED':
        return HousekeepingStatus.accepted;
      case 'CLEANING':
        return HousekeepingStatus.cleaning;
      case 'PENDING_INSPECTION':
        return HousekeepingStatus.pendingInspection;
      case 'DONE':
        return HousekeepingStatus.done;
      default:
        return HousekeepingStatus.pending;
    }
  }
}

class HousekeepingRoomRef {
  final String id;
  final String number;
  final int floor;

  const HousekeepingRoomRef({required this.id, required this.number, required this.floor});

  factory HousekeepingRoomRef.fromJson(Map<String, dynamic> json) => HousekeepingRoomRef(
        id: json['id'] as String,
        number: json['number'] as String,
        floor: json['floor'] as int,
      );
}

class HousekeepingAssigneeRef {
  final String id;
  final String fullName;

  const HousekeepingAssigneeRef({required this.id, required this.fullName});

  factory HousekeepingAssigneeRef.fromJson(Map<String, dynamic> json) => HousekeepingAssigneeRef(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
      );
}

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

  factory HousekeepingTask.fromJson(Map<String, dynamic> json) => HousekeepingTask(
        id: json['id'] as String,
        room: HousekeepingRoomRef.fromJson(json['room'] as Map<String, dynamic>),
        assignee: json['assignee'] != null
            ? HousekeepingAssigneeRef.fromJson(json['assignee'] as Map<String, dynamic>)
            : null,
        status: HousekeepingStatusX.fromString(json['status'] as String),
        isOverdue: json['isOverdue'] as bool,
        dueAt: DateTime.parse(json['dueAt'] as String),
        returnNote: json['returnNote'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        assignedAt: json['assignedAt'] != null ? DateTime.parse(json['assignedAt'] as String) : null,
        startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt'] as String) : null,
        completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
        confirmedAt: json['confirmedAt'] != null ? DateTime.parse(json['confirmedAt'] as String) : null,
        version: json['version'] as int,
      );

  HousekeepingTask copyWith({HousekeepingStatus? status, bool? isOverdue, int? version}) => HousekeepingTask(
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
