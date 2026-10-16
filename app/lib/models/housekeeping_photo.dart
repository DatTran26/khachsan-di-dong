/// Nhóm ảnh nghiệm thu (BR-housekeeping-006) — khớp enum `HousekeepingPhotoCategory` phía BE.
enum PhotoCategory { overview, bed, bathroom, closeup }

/// Mã API và nhãn nhóm ảnh.
extension PhotoCategoryX on PhotoCategory {
  /// `OVERVIEW`, `BED`, `BATHROOM`, `CLOSEUP`.
  String get value => switch (this) {
        PhotoCategory.overview => 'OVERVIEW',
        PhotoCategory.bed => 'BED',
        PhotoCategory.bathroom => 'BATHROOM',
        PhotoCategory.closeup => 'CLOSEUP',
      };

  /// Nhãn trên ô ảnh nghiệm thu.
  String get label => switch (this) {
        PhotoCategory.overview => 'Tổng quan phòng',
        PhotoCategory.bed => 'Khu ngủ / giường',
        PhotoCategory.bathroom => 'Nhà vệ sinh',
        PhotoCategory.closeup => 'Cận cảnh',
      };

  /// Parse mã API. Chuỗi lạ thành [PhotoCategory.closeup], không ném.
  static PhotoCategory parse(String v) => PhotoCategory.values
      .firstWhere((c) => c.value == v, orElse: () => PhotoCategory.closeup);
}

/// 3 nhóm bắt buộc mỗi lượt (mỗi nhóm 1 ảnh, tải lại = thay); cận cảnh tối đa [maxCloseups].
const requiredPhotoCategories = [
  PhotoCategory.overview,
  PhotoCategory.bed,
  PhotoCategory.bathroom,
];
const maxCloseups = 5;

/// Một ảnh đã lưu. [round] là lượt dọn; lượt cũ giữ khi việc bị trả lại.
class HousekeepingPhoto {
  final String id;
  final PhotoCategory category;
  final int round;
  final int sizeBytes;
  final DateTime createdAt;

  const HousekeepingPhoto({
    required this.id,
    required this.category,
    required this.round,
    required this.sizeBytes,
    required this.createdAt,
  });

  /// Dựng từ một phần tử `photos`. [sizeBytes] và [round] nhận `num`.
  factory HousekeepingPhoto.fromJson(Map<String, dynamic> json) =>
      HousekeepingPhoto(
        id: json['id'] as String,
        category: PhotoCategoryX.parse(json['category'] as String),
        round: (json['round'] as num).toInt(),
        sizeBytes: (json['sizeBytes'] as num).toInt(),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

/// Ảnh của một việc dọn: lượt hiện tại + ảnh các lượt trước (bị trả lại) để truy vết.
class TaskPhotos {
  final int currentRound;
  final List<HousekeepingPhoto> photos;

  const TaskPhotos({required this.currentRound, this.photos = const []});

  /// Ảnh đúng [currentRound]. Không gồm lượt trước.
  List<HousekeepingPhoto> get current =>
      photos.where((p) => p.round == currentRound).toList();

  /// Ảnh nhóm [c] của lượt hiện tại, hoặc null nếu chưa có. Không xét lượt cũ.
  HousekeepingPhoto? of(PhotoCategory c) {
    for (final p in current) {
      if (p.category == c) return p;
    }
    return null;
  }

  /// Ảnh cận cảnh của lượt hiện tại.
  List<HousekeepingPhoto> get closeups =>
      current.where((p) => p.category == PhotoCategory.closeup).toList();

  /// Số nhóm bắt buộc đã có ảnh ở lượt hiện tại, từ 0 đến 3.
  int get requiredDone =>
      requiredPhotoCategories.where((c) => of(c) != null).length;

  /// Đủ ba nhóm bắt buộc. Không tính cận cảnh.
  bool get hasAllRequired => requiredDone == requiredPhotoCategories.length;

  /// Dựng từ `GET .../photos`. Thiếu `photos` thì danh sách rỗng.
  factory TaskPhotos.fromJson(Map<String, dynamic> json) => TaskPhotos(
        currentRound: (json['currentRound'] as num).toInt(),
        photos: [
          for (final p in (json['photos'] as List?) ?? const [])
            HousekeepingPhoto.fromJson(p as Map<String, dynamic>),
        ],
      );
}
