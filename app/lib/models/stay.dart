/// Phòng rút gọn trên một lượt lưu trú: id, số, tầng. Không có trạng thái.
class StayRoomRef {
  final String id;
  final String number;
  final int floor;

  const StayRoomRef({required this.id, required this.number, required this.floor});

  /// Dựng từ object `room` lồng trong DTO lượt. Thiếu khóa thì ném khi ép kiểu.
  factory StayRoomRef.fromJson(Map<String, dynamic> json) => StayRoomRef(
        id: json['id'] as String,
        number: json['number'] as String,
        floor: json['floor'] as int,
      );
}

/// Một lượt nhận/trả phòng. [status] giữ chuỗi API (`OPEN`, `CLOSED`, …), không có enum riêng.
/// [version] là version của lượt, không phải version phòng.
class Stay {
  final String id;
  final StayRoomRef room;
  final String guestName;
  final int guestCount;
  final String status;
  final DateTime checkedInAt;
  final DateTime? checkedOutAt;
  final DateTime? expectedCheckout;
  final String? note;
  final int version;

  const Stay({
    required this.id,
    required this.room,
    required this.guestName,
    required this.guestCount,
    required this.status,
    required this.checkedInAt,
    this.checkedOutAt,
    this.expectedCheckout,
    this.note,
    required this.version,
  });

  /// Dựng từ DTO stay. `checkedOutAt`, `expectedCheckout`, `note` được phép null.
  /// Các mốc thời gian phải là chuỗi ISO nếu có mặt.
  factory Stay.fromJson(Map<String, dynamic> json) => Stay(
        id: json['id'] as String,
        room: StayRoomRef.fromJson(json['room'] as Map<String, dynamic>),
        guestName: json['guestName'] as String,
        guestCount: json['guestCount'] as int,
        status: json['status'] as String,
        checkedInAt: DateTime.parse(json['checkedInAt'] as String),
        checkedOutAt: json['checkedOutAt'] != null ? DateTime.parse(json['checkedOutAt'] as String) : null,
        expectedCheckout:
            json['expectedCheckout'] != null ? DateTime.parse(json['expectedCheckout'] as String) : null,
        note: json['note'] as String?,
        version: json['version'] as int,
      );
}
