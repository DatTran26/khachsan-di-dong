import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/housekeeping_photo.dart';
import '../../../shared/widgets/ui.dart';
import '../providers/photos_provider.dart';

/// Ảnh thu nhỏ — tải byte kèm token. Bấm → mở trình xem toàn màn hình.
class PhotoThumb extends ConsumerWidget {
  final HousekeepingPhoto photo;
  final double width;
  final double height;
  final VoidCallback? onTap;

  const PhotoThumb(
      {super.key,
      required this.photo,
      this.width = 96,
      this.height = 72,
      this.onTap});

  /// Ảnh từ [photoBytesProvider]. Lỗi hiện icon vỡ, không ném. [onTap] null thì không phải nút.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bytes = ref.watch(photoBytesProvider(photo.id));
    return Semantics(
      button: onTap != null,
      label: 'Ảnh ${photo.category.label}',
      child: Material(
        color: AppColors.neutralBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: width,
            height: height,
            child: bytes.when(
              data: (b) =>
                  Image.memory(b, fit: BoxFit.cover, gaplessPlayback: true),
              loading: () => const Center(
                  child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))),
              error: (_, __) => const Center(
                child: Icon(Icons.broken_image_outlined,
                    color: AppColors.muted, size: 22),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Trình xem toàn màn hình: vuốt qua lại giữa các ảnh, chụm hai ngón / chạm đúp để phóng to (FR-housekeeping-007).
/// Chỉ để kiểm tra — không đổi thứ tự, không xóa bằng chứng.
Future<void> showPhotoViewer(
    BuildContext context, List<HousekeepingPhoto> photos, int initialIndex) {
  return showDialog<void>(
    context: context,
    useSafeArea: false,
    barrierColor: AppColors.espressoDeep,
    builder: (_) => _PhotoViewer(photos: photos, initialIndex: initialIndex),
  );
}

/// Dialog full màn, [PageView] bắt đầu tại [initialIndex].
class _PhotoViewer extends StatefulWidget {
  final List<HousekeepingPhoto> photos;
  final int initialIndex;
  const _PhotoViewer({required this.photos, required this.initialIndex});

  /// Tạo state chỉ số trang.
  @override
  State<_PhotoViewer> createState() => _PhotoViewerState();
}

/// Giữ [PageController] và chỉ số ảnh đang xem.
class _PhotoViewerState extends State<_PhotoViewer> {
  late final PageController _pages =
      PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;

  /// Giải phóng [PageController].
  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  /// Tiêu đề nhóm và vị trí, vuốt đổi ảnh. Không sửa dữ liệu.
  @override
  Widget build(BuildContext context) {
    final photo = widget.photos[_index];
    return Dialog.fullscreen(
      backgroundColor: AppColors.espressoDeep,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${photo.category.label} · ${_index + 1}/${widget.photos.length}',
                      style: AppText.bodyLg.copyWith(
                          color: AppColors.onDark, fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Đóng',
                    color: AppColors.onDark,
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pages,
                itemCount: widget.photos.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => _ZoomablePhoto(photo: widget.photos[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text('Chụm hai ngón hoặc chạm đúp để phóng to',
                  style: AppText.meta.copyWith(color: AppColors.onDarkMuted)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Một ảnh phóng được trong viewer. Tải byte theo id.
class _ZoomablePhoto extends ConsumerStatefulWidget {
  final HousekeepingPhoto photo;
  const _ZoomablePhoto({required this.photo});

  /// Tạo state zoom.
  @override
  ConsumerState<_ZoomablePhoto> createState() => _ZoomablePhotoState();
}

/// [TransformationController] cho chụm và chạm đúp.
class _ZoomablePhotoState extends ConsumerState<_ZoomablePhoto> {
  final _zoom = TransformationController();
  TapDownDetails? _tap;

  /// Giải phóng controller phóng.
  @override
  void dispose() {
    _zoom.dispose();
    super.dispose();
  }

  /// Chạm đúp: phóng 2.5× quanh điểm chạm; đang phóng thì về lại.
  void _toggleZoom() {
    if (_zoom.value != Matrix4.identity()) {
      _zoom.value = Matrix4.identity();
      return;
    }
    final p = _tap?.localPosition ?? Offset.zero;
    const s = 2.5;
    _zoom.value = Matrix4.identity()
      ..translateByDouble(-p.dx * (s - 1), -p.dy * (s - 1), 0, 1)
      ..scaleByDouble(s, s, 1, 1);
  }

  /// Ảnh contain, tối đa phóng 5 lần. Lỗi hiện câu kiểm tra kết nối, không retry tự động.
  @override
  Widget build(BuildContext context) {
    final bytes = ref.watch(photoBytesProvider(widget.photo.id));
    return bytes.when(
      data: (b) => GestureDetector(
        onDoubleTapDown: (d) => _tap = d,
        onDoubleTap: _toggleZoom,
        child: InteractiveViewer(
          transformationController: _zoom,
          maxScale: 5,
          child: Center(child: Image.memory(b, fit: BoxFit.contain)),
        ),
      ),
      loading: () => const Center(
          child: CircularProgressIndicator(semanticsLabel: 'Đang tải ảnh')),
      error: (e, _) => const Center(
        child: Text('Không tải được ảnh — kiểm tra kết nối rồi mở lại.',
            style: TextStyle(color: AppColors.onDark)),
      ),
    );
  }
}

/// Mục "Ảnh nghiệm thu" trong chi tiết việc — quản lý đối chiếu trước khi xác nhận / trả lại.
/// Ảnh theo thứ tự nhóm; ảnh lần dọn trước (đã bị trả lại) giữ để truy vết.
class PhotoReviewSection extends ConsumerWidget {
  final String taskId;
  const PhotoReviewSection({super.key, required this.taskId});

  /// Ảnh vòng hiện tại và nút xem ảnh vòng trước. Thiếu nhóm bắt buộc thì tô đỏ.
  /// Lỗi tải thì banner thử lại, gọi [TaskPhotosNotifier.load].
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(taskPhotosProvider(taskId));
    final data = state.data;

    Widget body;
    if (data == null && state.isLoading) {
      body = const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
            child: CircularProgressIndicator(
                semanticsLabel: 'Đang tải ảnh nghiệm thu')),
      );
    } else if (data == null) {
      body = AppBanner(
        tone: BannerTone.error,
        message: state.error ?? 'Chưa tải được ảnh nghiệm thu.',
        action: TextButton(
          onPressed: () => ref.read(taskPhotosProvider(taskId).notifier).load(),
          child: const Text('Thử lại'),
        ),
      );
    } else {
      final current = data.current;
      final previous =
          data.photos.where((p) => p.round != data.currentRound).toList();
      final missing = requiredPhotoCategories
          .where((c) => data.of(c) == null)
          .map((c) => c.label)
          .toList();
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          missing.isEmpty
              ? MetaText(
                  '${data.requiredDone}/${requiredPhotoCategories.length} ảnh bắt buộc đã tải')
              : MetaText('Thiếu ảnh: ${missing.join(', ')}',
                  color: AppColors.danger, weight: FontWeight.w600),
          const SizedBox(height: 10),
          if (current.isEmpty)
            const MetaText('Lần dọn này chưa có ảnh.')
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (var i = 0; i < current.length; i++)
                  _Captioned(
                    caption: current[i].category.label,
                    child: PhotoThumb(
                      photo: current[i],
                      width: 120,
                      height: 90,
                      onTap: () => showPhotoViewer(context, current, i),
                    ),
                  ),
              ],
            ),
          if (previous.isNotEmpty) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              onPressed: () => showPhotoViewer(context, previous, 0),
              icon: const Icon(Icons.history_rounded, size: 18),
              label: Text('Xem ${previous.length} ảnh của lần dọn trước'),
            ),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Ảnh nghiệm thu'),
        const SizedBox(height: 8),
        body,
      ],
    );
  }
}

/// Ảnh kèm chú thích một dòng, rộng 120.
class _Captioned extends StatelessWidget {
  final String caption;
  final Widget child;
  const _Captioned({required this.caption, required this.child});

  /// [child] rồi [caption] cắt một dòng. Không tải ảnh.
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          child,
          const SizedBox(height: 4),
          SizedBox(
            width: 120,
            child: Text(caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.overline.copyWith(color: AppColors.muted)),
          ),
        ],
      );
}
