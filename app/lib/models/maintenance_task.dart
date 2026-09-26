enum MaintenanceStatus { open, inProgress, done, cancelled }

extension MaintenanceStatusX on MaintenanceStatus {
  String get label {
    switch (this) {
      case MaintenanceStatus.open:
        return 'Chờ nhận';
      case MaintenanceStatus.inProgress:
        return 'Đang sửa';
      case MaintenanceStatus.done:
        return 'Hoàn tất';
      case MaintenanceStatus.cancelled:
        return 'Đã hủy';
    }
  }

  String get value {
    switch (this) {
      case MaintenanceStatus.open:
        return 'OPEN';
      case MaintenanceStatus.inProgress:
        return 'IN_PROGRESS';
      case MaintenanceStatus.done:
        return 'DONE';
      case MaintenanceStatus.cancelled:
        return 'CANCELLED';
    }
  }

  static MaintenanceStatus fromString(String v) {
    switch (v) {
      case 'IN_PROGRESS':
        return MaintenanceStatus.inProgress;
      case 'DONE':
        return MaintenanceStatus.done;
      case 'CANCELLED':
        return MaintenanceStatus.cancelled;
      default:
        return MaintenanceStatus.open;
    }
  }
}

class MaintenanceRoomRef {
  final String id;
  final String number;
  final int floor;

  const MaintenanceRoomRef({required this.id, required this.number, required this.floor});

  factory MaintenanceRoomRef.fromJson(Map<String, dynamic> json) => MaintenanceRoomRef(
        id: json['id'] as String,
        number: json['number'] as String,
        floor: json['floor'] as int,
      );
}

class MaintenanceUserRef {
  final String id;
  final String fullName;
  final String? role;

  const MaintenanceUserRef({required this.id, required this.fullName, this.role});

  factory MaintenanceUserRef.fromJson(Map<String, dynamic> json) => MaintenanceUserRef(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        role: json['role'] as String?,
      );
}

class MaintenanceTask {
  final String id;
  final MaintenanceRoomRef room;
  final String description;
  final String? location;
  final MaintenanceStatus status;
  final MaintenanceUserRef reporter;
  final MaintenanceUserRef? assignee;
  final String? cancelReason;
  final bool isOverdue;
  final DateTime? dueAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  const MaintenanceTask({
    required this.id,
    required this.room,
    required this.description,
    this.location,
    required this.status,
    required this.reporter,
    this.assignee,
    this.cancelReason,
    required this.isOverdue,
    this.dueAt,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory MaintenanceTask.fromJson(Map<String, dynamic> json) => MaintenanceTask(
        id: json['id'] as String,
        room: MaintenanceRoomRef.fromJson(json['room'] as Map<String, dynamic>),
        description: json['description'] as String,
        location: json['location'] as String?,
        status: MaintenanceStatusX.fromString(json['status'] as String),
        reporter: MaintenanceUserRef.fromJson(json['reporter'] as Map<String, dynamic>),
        assignee: json['assignee'] != null
            ? MaintenanceUserRef.fromJson(json['assignee'] as Map<String, dynamic>)
            : null,
        cancelReason: json['cancelReason'] as String?,
        isOverdue: json['isOverdue'] as bool,
        dueAt: json['dueAt'] != null ? DateTime.parse(json['dueAt'] as String) : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        version: json['version'] as int,
      );
}
