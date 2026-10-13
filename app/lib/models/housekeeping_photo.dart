/// Nhóm ảnh nghiệm thu (BR-housekeeping-006) — khớp enum `HousekeepingPhotoCategory` phía BE.
enum PhotoCategory { overview, bed, bathroom, closeup }

extension PhotoCategoryX on PhotoCategory {
  String get value => switch (this) {
        PhotoCategory.overview => 'OVERVIEW',
        PhotoCategory.bed => 'BED',
        PhotoCategory.bathroom => 'BATHROOM',
        PhotoCategory.closeup => 'CLOSEUP',
      };

  String get label => switch (this) {
        PhotoCategory.overview => 'Tổng quan phòng',
        PhotoCategory.bed => 'Khu ngủ / giường',
        PhotoCategory.bathroom => 'Nhà vệ sinh',
        PhotoCategory.closeup => 'Cận cảnh',
      };

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

  List<HousekeepingPhoto> get current =>
      photos.where((p) => p.round == currentRound).toList();

  HousekeepingPhoto? of(PhotoCategory c) {
    for (final p in current) {
      if (p.category == c) return p;
    }
    return null;
  }

  List<HousekeepingPhoto> get closeups =>
      current.where((p) => p.category == PhotoCategory.closeup).toList();

  int get requiredDone =>
      requiredPhotoCategories.where((c) => of(c) != null).length;

  bool get hasAllRequired => requiredDone == requiredPhotoCategories.length;

  factory TaskPhotos.fromJson(Map<String, dynamic> json) => TaskPhotos(
        currentRound: (json['currentRound'] as num).toInt(),
        photos: [
          for (final p in (json['photos'] as List?) ?? const [])
            HousekeepingPhoto.fromJson(p as Map<String, dynamic>),
        ],
      );
}
