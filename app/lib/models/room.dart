/// Trục lưu trú. Khớp `VACANT` / `OCCUPIED`.
enum OccupancyStatus { vacant, occupied }

/// Trục vệ sinh. Khớp bốn giá trị `CleaningStatus` của server.
enum CleaningStatus { dirty, cleaning, pendingInspection, clean }

/// Trục bảo trì. `outOfService` là ngừng phục vụ (việc sửa mở hoặc hold tay).
enum ServiceStatus { inService, outOfService }

/// Nhãn và mã API của trục lưu trú.
extension OccupancyStatusX on OccupancyStatus {
  /// "Trống" hoặc "Đang ở".
  String get label {
    switch (this) {
      case OccupancyStatus.vacant:
        return 'Trống';
      case OccupancyStatus.occupied:
        return 'Đang ở';
    }
  }

  /// `VACANT` hoặc `OCCUPIED`.
  String get value {
    switch (this) {
      case OccupancyStatus.vacant:
        return 'VACANT';
      case OccupancyStatus.occupied:
        return 'OCCUPIED';
    }
  }

  /// Parse mã API. Mọi chuỗi khác `OCCUPIED` thành trống.
  static OccupancyStatus fromString(String v) =>
      v == 'OCCUPIED' ? OccupancyStatus.occupied : OccupancyStatus.vacant;
}

/// Nhãn và mã API của trục vệ sinh.
extension CleaningStatusX on CleaningStatus {
  /// Nhãn ô phòng: Cần dọn, Đang dọn, Chờ kiểm tra, Sạch.
  String get label {
    switch (this) {
      case CleaningStatus.dirty:
        return 'Cần dọn';
      case CleaningStatus.cleaning:
        return 'Đang dọn';
      case CleaningStatus.pendingInspection:
        return 'Chờ kiểm tra';
      case CleaningStatus.clean:
        return 'Sạch';
    }
  }

  /// Mã API `DIRTY`, `CLEANING`, `PENDING_INSPECTION`, `CLEAN`.
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

  /// Parse mã API. Giá trị lạ thành [CleaningStatus.clean], không ném.
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

/// Nhãn và mã API của trục bảo trì.
extension ServiceStatusX on ServiceStatus {
  /// "Đang phục vụ" hoặc "Ngừng phục vụ".
  String get label {
    switch (this) {
      case ServiceStatus.inService:
        return 'Đang phục vụ';
      case ServiceStatus.outOfService:
        return 'Ngừng phục vụ';
    }
  }

  /// `IN_SERVICE` hoặc `OUT_OF_SERVICE`.
  String get value {
    switch (this) {
      case ServiceStatus.inService:
        return 'IN_SERVICE';
      case ServiceStatus.outOfService:
        return 'OUT_OF_SERVICE';
    }
  }

  /// Parse mã API. Chỉ `OUT_OF_SERVICE` là ngừng; chuỗi khác thành đang phục vụ.
  static ServiceStatus fromString(String v) => v == 'OUT_OF_SERVICE'
      ? ServiceStatus.outOfService
      : ServiceStatus.inService;
}

/// Loại phòng gắn trên DTO phòng. [isActive] mặc định true nếu JSON thiếu khóa
/// (một số payload cũ không gửi cờ).
class RoomType {
  final String id;
  final String name;
  final bool isActive;

  const RoomType({required this.id, required this.name, this.isActive = true});

  /// Dựng từ object lồng `roomType` của phòng hoặc từ API loại phòng.
  factory RoomType.fromJson(Map<String, dynamic> json) => RoomType(
        id: json['id'] as String,
        name: json['name'] as String,
        isActive: (json['isActive'] as bool?) ?? true,
      );
}

/// Phòng trên client. [isReady] do server tính (trống + sạch + đang phục vụ), không tự suy lại.
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

  /// Dựng từ DTO phòng. `updatedAt` phải là chuỗi ISO. Thiếu `roomType` thì ném.
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

  /// Bản sao các trục và version. Không đổi id, số, tầng, loại.
  /// Dùng khi socket hoặc optimistic UI cập nhật một phần.
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
