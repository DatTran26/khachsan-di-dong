import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/room.dart';
import 'ui.dart';

/// Ô phòng trên lưới: số phòng + lưu trú + vệ sinh; phòng ngừng phục vụ chỉ hiện "Ngừng phục vụ".
/// Đủ 3 trục vẫn có trong tooltip / nhãn đọc màn hình.
/// - Đầu ô tô màu theo trạng thái tổng hợp.
/// - Ngừng phục vụ: gạch chéo toàn ô, viền nét đứt, chữ xám trầm.
/// - Quá hạn: viền đỏ + nhãn "QH".
class RoomTile extends StatelessWidget {
  final Room room;
  final bool overdue;
  final bool selected;
  final VoidCallback? onTap;

  const RoomTile({
    super.key,
    required this.room,
    this.overdue = false,
    this.selected = false,
    this.onTap,
  });

  /// Phòng đang ngừng phục vụ. Quyết định gạch chéo và một dòng trạng thái.
  bool get _oos => room.service == ServiceStatus.outOfService;

  /// Chiều cao ô trên lưới, co giãn theo cỡ chữ hệ thống (đầu ô ~31px + 3 dòng trạng thái ~16px + lề).
  static double extent(BuildContext context) =>
      MediaQuery.textScalerOf(context).scale(106);

  /// Ô bấm [onTap]. Tooltip và semantics luôn đủ ba trục, kể cả khi thân ô chỉ một dòng.
  @override
  Widget build(BuildContext context) {
    final tone = room.summaryTone;
    final borderColor = overdue
        ? AppColors.danger
        : selected
            ? AppColors.gold
            : _oos
                ? AppColors.borderStrong
                : AppColors.border;
    final borderWidth = (overdue || selected) ? 2.0 : 1.0;
    final radius = BorderRadius.circular(10);

    final header = Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 8, 6),
      color: _oos ? AppColors.oos.withValues(alpha: .10) : tone.bg,
      child: Row(
        children: [
          Expanded(
            child: Text(room.number,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 16,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    color: tone.fg)),
          ),
          if (overdue) const OverdueBadge(short: true),
        ],
      ),
    );

    // Ngừng phục vụ: chỉ một dòng đó — lưu trú / vệ sinh không còn ý nghĩa khi phòng không nhận khách.
    final axes = <(String, StatusTone)>[
      if (_oos)
        (room.service.label, room.service.tone)
      else ...[
        (room.occupancy.label, room.occupancy.tone),
        (room.cleaning.label, room.cleaning.tone),
      ],
    ];

    final body = Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 4, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (label, t) in axes)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                children: [
                  Container(
                      width: 6,
                      height: 6,
                      decoration:
                          BoxDecoration(color: t.dot, shape: BoxShape.circle)),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(label,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.3,
                          letterSpacing: -.1,
                          color: _oos ? AppColors.oos : AppColors.text,
                        )),
                  ),
                ],
              ),
            ),
        ],
      ),
    );

    // Thân ô tự cắt nếu chữ hệ thống to hơn dự kiến — không bao giờ hiện vạch tràn.
    Widget tile = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        Expanded(child: ClipRect(child: body)),
      ],
    );

    if (_oos) {
      tile = CustomPaint(painter: _HatchPainter(), child: tile);
    }

    final fullLabel =
        'Phòng ${room.number}: ${room.occupancy.label} · ${room.cleaning.label} · ${room.service.label}'
        '${overdue ? ' · quá hạn' : ''}';
    return Tooltip(
      message: fullLabel,
      waitDuration: const Duration(milliseconds: 500),
      excludeFromSemantics: true,
      child: Semantics(
        button: onTap != null,
        label: fullLabel,
        child: CustomPaint(
          foregroundPainter: _oos && !overdue && !selected
              ? _DashedBorderPainter(radius: 10)
              : null,
          child: Material(
            color: _oos ? const Color(0xFFF3F0EA) : AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: radius,
              side: _oos && !overdue && !selected
                  ? BorderSide.none
                  : BorderSide(color: borderColor, width: borderWidth),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(onTap: onTap, child: tile),
          ),
        ),
      ),
    );
  }
}

/// Gạch chéo 135° phủ toàn ô phòng ngừng phục vụ.
class _HatchPainter extends CustomPainter {
  /// Khoảng cách nét 9px. Không đọc theme.
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFDDD7CB)
      ..strokeWidth = 2;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    const gap = 9.0;
    final span = size.width + size.height;
    for (double d = -size.height; d < span; d += gap) {
      canvas.drawLine(
          Offset(d, size.height), Offset(d + size.height, 0), paint);
    }
    canvas.restore();
  }

  /// Không có tham số, không cần vẽ lại.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Viền nét đứt bo [radius] cho ô ngừng phục vụ khi không quá hạn và không đang chọn.
class _DashedBorderPainter extends CustomPainter {
  final double radius;
  _DashedBorderPainter({required this.radius});

  /// Nét 5px, hở 4px, dọc theo bo góc.
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.borderStrong
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final rrect =
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius))
            .deflate(.6);
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        final len = math.min(5.0, metric.length - dist);
        canvas.drawPath(metric.extractPath(dist, dist + len), paint);
        dist += 9;
      }
    }
  }

  /// Vẽ lại khi [radius] đổi.
  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.radius != radius;
}
