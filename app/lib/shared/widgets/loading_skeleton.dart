import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Khung xương khi tải lần đầu — giữ đúng hình dạng nội dung sắp hiện để màn không "nhảy".
/// Nhấp nháy nhẹ; tắt hẳn khi người dùng bật giảm chuyển động. Trình đọc màn hình chỉ nghe "Đang tải".
class Skeleton extends StatefulWidget {
  final Widget child;
  final String label;

  const Skeleton({super.key, required this.child, this.label = 'Đang tải'});

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
      _c.value = 1;
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label,
      liveRegion: true,
      child: ExcludeSemantics(
        child: FadeTransition(
          opacity: Tween(begin: .45, end: 1.0).animate(_c),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Một khối xám bo góc.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const SkeletonBox(
      {super.key,
      this.width,
      this.height = 14,
      this.radius = AppTheme.radiusSm});

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceSunken,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}

/// Lưới ô phòng (Tổng quan, Phòng). [header] = hàng thẻ số liệu phía trên.
class SkeletonGrid extends StatelessWidget {
  final bool header;
  final int count;

  const SkeletonGrid({super.key, this.header = false, this.count = 18});

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          if (header) ...[
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (var i = 0; i < 4; i++)
                  const SkeletonBox(
                      width: 150, height: 76, radius: AppTheme.radiusMd),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          const SkeletonBox(width: 220, height: 32),
          const SizedBox(height: AppSpacing.md),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 120,
              mainAxisExtent: 96,
              crossAxisSpacing: AppSpacing.xs,
              mainAxisSpacing: AppSpacing.xs,
            ),
            itemCount: count,
            itemBuilder: (_, __) => const SkeletonBox(height: 96, radius: 10),
          ),
        ],
      ),
    );
  }
}

/// Danh sách thẻ/bảng (Lưu trú, Dọn phòng, Bảo trì, Tài khoản, Nhật ký).
class SkeletonList extends StatelessWidget {
  final int count;
  final double itemHeight;

  const SkeletonList({super.key, this.count = 6, this.itemHeight = 72});

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const SkeletonBox(width: 180, height: 22),
          const SizedBox(height: AppSpacing.md),
          for (var i = 0; i < count; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Container(
                height: itemHeight,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    SkeletonBox(width: 40, height: 40, radius: 20),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FractionallySizedBox(
                              widthFactor: .5, child: SkeletonBox(height: 12)),
                          SizedBox(height: AppSpacing.xs),
                          FractionallySizedBox(
                              widthFactor: .8, child: SkeletonBox(height: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
