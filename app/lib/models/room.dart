enum OccupancyStatus { vacant, occupied }

enum CleaningStatus { dirty, cleaning, pendingInspection, clean }

enum ServiceStatus { inService, outOfService }

extension OccupancyStatusX on OccupancyStatus {
  String get label {
    switch (this) {
      case OccupancyStatus.vacant:
        return 'Trống';
      case OccupancyStatus.occupied:
        return 'Đang ở';
    }
  }

  String get value {
    switch (this) {
      case OccupancyStatus.vacant:
        return 'VACANT';
      case OccupancyStatus.occupied:
        return 'OCCUPIED';
    }
  }

  static OccupancyStatus fromString(String v) =>
      v == 'OCCUPIED' ? OccupancyStatus.occupied : OccupancyStatus.vacant;
}

extension CleaningStatusX on CleaningStatus {
  String get label {
    switch (this) {
      case CleaningStatus.dirty:
        return 'Cần dọn';
      case CleaningStatus.cleaning:
        return 'Đang dọn';
      case CleaningStatus.pendingInspection:
        return 'Chờ xác nhận';
      case CleaningStatus.clean:
        return 'Sạch';
    }
  }

  String get value {
    switch (this) {
      case CleaningStatus.dirty:
        return 'DIRTY';
      case CleaningStatus.cleaning:
        return 'CLEANING';
      case CleaningStatus.pendingInspection:
        return 'PENDING_INSPECTION';
      case CleaningStatus.clean:
        return 'CLEAN';
    }
  }

  static CleaningStatus fromString(String v) {
    switch (v) {
      case 'DIRTY':
        return CleaningStatus.dirty;
      case 'CLEANING':
        return CleaningStatus.cleaning;
      case 'PENDING_INSPECTION':
        return CleaningStatus.pendingInspection;
      default:
        return CleaningStatus.clean;
    }
  }
}

extension ServiceStatusX on ServiceStatus {
  String get label {
    switch (this) {
      case ServiceStatus.inService:
        return 'Bình thường';
      case ServiceStatus.outOfService:
        return 'Ngừng phục vụ';
    }
  }

  String get value {
    switch (this) {
      case ServiceStatus.inService:
        return 'IN_SERVICE';
      case ServiceStatus.outOfService:
        return 'OUT_OF_SERVICE';
    }
  }

  static ServiceStatus fromString(String v) =>
      v == 'OUT_OF_SERVICE' ? ServiceStatus.outOfService : ServiceStatus.inService;
}

class RoomType {
  final String id;
  final String name;

  const RoomType({required this.id, required this.name});

  factory RoomType.fromJson(Map<String, dynamic> json) =>
      RoomType(id: json['id'] as String, name: json['name'] as String);
}

class Room {
  final String id;
  final String number;
  final int floor;
  final RoomType roomType;
  final OccupancyStatus occupancy;
  final CleaningStatus cleaning;
  final ServiceStatus service;
  final bool isReady;
  final int version;
  final DateTime updatedAt;

  const Room({
    required this.id,
    required this.number,
    required this.floor,
    required this.roomType,
    required this.occupancy,
    required this.cleaning,
    required this.service,
    required this.isReady,
    required this.version,
    required this.updatedAt,
  });

  factory Room.fromJson(Map<String, dynamic> json) => Room(
        id: json['id'] as String,
        number: json['number'] as String,
        floor: json['floor'] as int,
        roomType: RoomType.fromJson(json['roomType'] as Map<String, dynamic>),
        occupancy: OccupancyStatusX.fromString(json['occupancy'] as String),
        cleaning: CleaningStatusX.fromString(json['cleaning'] as String),
        service: ServiceStatusX.fromString(json['service'] as String),
        isReady: json['isReady'] as bool,
        version: json['version'] as int,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Room copyWith({
    OccupancyStatus? occupancy,
    CleaningStatus? cleaning,
    ServiceStatus? service,
    bool? isReady,
    int? version,
    DateTime? updatedAt,
  }) =>
      Room(
        id: id,
        number: number,
        floor: floor,
        roomType: roomType,
        occupancy: occupancy ?? this.occupancy,
        cleaning: cleaning ?? this.cleaning,
        service: service ?? this.service,
        isReady: isReady ?? this.isReady,
        version: version ?? this.version,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
