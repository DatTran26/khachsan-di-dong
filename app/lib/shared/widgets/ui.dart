import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/room.dart';

/// Tông màu trạng thái — dùng chung cho chip, chấm, ô phòng.
enum StatusTone {
  ready,
  occupied,
  dirty,
  cleaning,
  inspect,
  oos,
  danger,
  neutral,
  gold
}

extension StatusToneX on StatusTone {
  Color get fg {
    switch (this) {
      case StatusTone.ready:
        return AppColors.ready;
      case StatusTone.occupied:
        return AppColors.occupied;
      case StatusTone.dirty:
        return AppColors.dirty;
      case StatusTone.cleaning:
        return AppColors.cleaning;
      case StatusTone.inspect:
        return AppColors.inspect;
      case StatusTone.oos:
        return AppColors.oos;
      case StatusTone.danger:
        return AppColors.danger;
      case StatusTone.neutral:
        return AppColors.neutral;
      case StatusTone.gold:
        return AppColors.goldText;
    }
  }

  Color get bg {
    switch (this) {
      case StatusTone.ready:
        return AppColors.readyBg;
      case StatusTone.occupied:
        return AppColors.occupiedBg;
      case StatusTone.dirty:
        return AppColors.dirtyBg;
      case StatusTone.cleaning:
        return AppColors.cleaningBg;
      case StatusTone.inspect:
        return AppColors.inspectBg;
      case StatusTone.oos:
        return AppColors.oosBg;
      case StatusTone.danger:
        return AppColors.dangerBg;
      case StatusTone.neutral:
        return AppColors.neutralBg;
      case StatusTone.gold:
        return AppColors.goldTint;
    }
  }

  /// Màu chấm trên ô phòng — trạng thái "bình thường" dùng xám nhạt để không gây chú ý.
  Color get dot => this == StatusTone.neutral ? AppColors.dotMuted : fg;
}

extension OccupancyTone on OccupancyStatus {
  StatusTone get tone => this == OccupancyStatus.occupied
      ? StatusTone.occupied
      : StatusTone.neutral;
}

extension CleaningTone on CleaningStatus {
  StatusTone get tone {
    switch (this) {
      case CleaningStatus.dirty:
        return StatusTone.dirty;
      case CleaningStatus.cleaning:
        return StatusTone.cleaning;
      case CleaningStatus.pendingInspection:
        return StatusTone.inspect;
      case CleaningStatus.clean:
        return StatusTone.ready;
    }
  }
}

extension ServiceTone on ServiceStatus {
  StatusTone get tone =>
      this == ServiceStatus.outOfService ? StatusTone.oos : StatusTone.neutral;
}

/// Trạng thái tổng hợp của phòng — quyết định màu đầu ô phòng.
extension RoomSummaryTone on Room {
  StatusTone get summaryTone {
    if (service == ServiceStatus.outOfService) return StatusTone.oos;
    if (occupancy == OccupancyStatus.occupied) return StatusTone.occupied;
    if (isReady) return StatusTone.ready;
    return cleaning.tone;
  }

  String get summaryLabel {
    if (service == ServiceStatus.outOfService) return 'Ngừng phục vụ';
    if (occupancy == OccupancyStatus.occupied) return 'Đang ở';
    if (isReady) return 'Sẵn sàng';
    return cleaning.label;
  }
}

/// Chip trạng thái: chữ luôn đi kèm màu (không phân biệt chỉ bằng màu).
class StatusChip extends StatelessWidget {
  final String label;
  final StatusTone tone;
  final bool dot;
  final bool dense;

  const StatusChip(this.label,
      {super.key, required this.tone, this.dot = true, this.dense = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: dense ? 22 : 24,
      padding: EdgeInsets.symmetric(horizontal: dense ? 8 : 10),
      decoration: BoxDecoration(
          color: tone.bg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
                width: 6,
                height: 6,
                decoration:
                    BoxDecoration(color: tone.fg, shape: BoxShape.circle)),
            const SizedBox(width: 6),
          ],
          Text(label,
              style: TextStyle(
                  color: tone.fg,
                  fontSize: dense ? 11.5 : 12,
                  fontWeight: FontWeight.w600,
                  height: 1.1)),
        ],
      ),
    );
  }
}

/// Nhãn đỏ "Quá hạn" / "QH".
class OverdueBadge extends StatelessWidget {
  final bool short;
  const OverdueBadge({super.key, this.short = false});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Quá hạn',
      child: Container(
        height: 20,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: AppColors.danger, borderRadius: BorderRadius.circular(10)),
        child: Text(short ? 'QH' : 'Quá hạn',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700)),
      ),
    );
  }
}

enum BannerTone { info, warn, error, success }

class AppBanner extends StatelessWidget {
  final BannerTone tone;
  final String message;
  final String? title;
  final IconData? icon;
  final Widget? action;
  final BorderRadius? radius;

  const AppBanner({
    super.key,
    required this.tone,
    required this.message,
    this.title,
    this.icon,
    this.action,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, Color border, IconData defIcon) = switch (tone) {
      BannerTone.info => (
          AppColors.goldTint,
          const Color(0xFF5A420E),
          const Color(0xFFE8D6A8),
          Icons.info_outline
        ),
      BannerTone.warn => (
          AppColors.dirtyBg,
          const Color(0xFF7A2E10),
          const Color(0xFFF0C3AE),
          Icons.wifi_off_rounded
        ),
      BannerTone.error => (
          AppColors.dangerBg,
          const Color(0xFF8A1C21),
          const Color(0xFFF2C4C6),
          Icons.error_outline
        ),
      BannerTone.success => (
          AppColors.readyBg,
          const Color(0xFF1F5A22),
          const Color(0xFFBFDDC1),
          Icons.check_circle_outline
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: radius ?? BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? defIcon, color: fg, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(children: [
                if (title != null)
                  TextSpan(
                      text: '$title ',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                TextSpan(text: message),
              ]),
              style: TextStyle(color: fg, fontSize: 14, height: 1.4),
            ),
          ),
          if (action != null) ...[const SizedBox(width: 8), action!],
        ],
      ),
    );
  }
}

/// Màn trống: nói rõ đây là gì, vì sao trống, bước tiếp theo.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  const EmptyState(
      {super.key,
      required this.icon,
      required this.title,
      this.message,
      this.action});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                    color: AppColors.goldTint, shape: BoxShape.circle),
                child: Icon(icon, color: AppColors.goldText, size: 30),
              ),
              const SizedBox(height: 16),
              Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
              if (message != null) ...[
                const SizedBox(height: 6),
                Text(message!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.muted, height: 1.5)),
              ],
              if (action != null) ...[const SizedBox(height: 16), action!],
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorState({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.cloud_off_rounded,
      title: 'Chưa tải được dữ liệu',
      message: message,
      action: ElevatedButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh, size: 18),
        label: const Text('Thử lại'),
      ),
    );
  }
}

/// Đầu mục nhỏ in hoa — "XONG HÔM NAY · 4".
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: AppColors.muted,
            letterSpacing: .5),
      );
}

/// Nút lọc dạng viên thuốc; đang chọn → nền espresso, chữ vàng.
class FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  const FilterPill(
      {super.key,
      required this.label,
      required this.selected,
      required this.onTap,
      this.color});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.espresso : AppColors.surface,
      shape: StadiumBorder(
          side: BorderSide(
              color: selected ? AppColors.espresso : AppColors.border)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color:
                    selected ? AppColors.goldLight : (color ?? AppColors.text),
              )),
        ),
      ),
    );
  }
}

/// Nhóm nút chọn một (vd lọc tầng). Không đủ chỗ (màn hẹp, chữ phóng to) → cuộn ngang thay vì tràn.
class SegmentedPills<T> extends StatelessWidget {
  final List<(T, String)> options;
  final T value;
  final ValueChanged<T> onChanged;

  const SegmentedPills(
      {super.key,
      required this.options,
      required this.value,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
          color: const Color(0xFFECE7DC),
          borderRadius: BorderRadius.circular(10)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (v, label) in options)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Material(
                  color: v == value ? AppColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  elevation: v == value ? 1 : 0,
                  shadowColor: Colors.black26,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => onChanged(v),
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(minWidth: 40, minHeight: 32),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Center(
                          child: Text(label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: v == value
                                    ? AppColors.goldText
                                    : AppColors.muted,
                              )),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Ảnh đại diện chữ cái đầu — nền espresso, viền vàng.
class InitialAvatar extends StatelessWidget {
  final String name;
  final double size;
  const InitialAvatar(this.name, {super.key, this.size = 36});

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty
        ? '?'
        : name.trim().split(' ').last[0].toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.espresso,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.gold, width: 1.5),
      ),
      child: Text(initial,
          style: TextStyle(
              color: AppColors.goldLight,
              fontWeight: FontWeight.w700,
              fontSize: size * .4)),
    );
  }
}

/// Logo "KS" nền vàng chuyển sắc.
class BrandMark extends StatelessWidget {
  final double size;
  const BrandMark({super.key, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * .28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.goldLight, AppColors.goldDark],
        ),
      ),
      child: Text('KS',
          style: TextStyle(
              color: AppColors.espresso,
              fontWeight: FontWeight.w800,
              fontSize: size * .38)),
    );
  }
}

/// Khung thẻ trắng viền mảnh.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final Color? color;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderColor,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      side: BorderSide(
          color: borderColor ?? AppColors.border,
          width: borderColor == AppColors.danger ? 1.5 : 1),
    );
    return Material(
      color: color ?? AppColors.surface,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Hàng thông tin nhỏ — "Hạn 14:50".
class MetaText extends StatelessWidget {
  final String text;
  final Color? color;
  final FontWeight? weight;
  const MetaText(this.text, {super.key, this.color, this.weight});

  @override
  Widget build(BuildContext context) => Text(text,
      style: TextStyle(
          fontSize: 13,
          color: color ?? AppColors.muted,
          fontWeight: weight,
          height: 1.4));
}

/// Kích thước màn hình dùng chung.
class Breakpoints {
  static const double wide = 1100; // web: bảng + khung chi tiết
  static const double sidebar = 900; // hiện thanh bên
  static bool isWide(BuildContext c) => MediaQuery.sizeOf(c).width >= wide;
  static bool hasSidebar(BuildContext c) =>
      MediaQuery.sizeOf(c).width >= sidebar;
}
