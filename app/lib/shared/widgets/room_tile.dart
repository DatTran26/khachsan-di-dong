import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../models/room.dart';
import '../../models/stay.dart';
import 'ui.dart';

/// Ô phòng trên lưới dạng Khối màu trực quan theo 5 trường hợp thực tế (Chuẩn PMS):
/// 1. Sẵn sàng: Nền xanh lá, icon check, Trống • Sẵn sàng
/// 2. Cần dọn: Nền cam đất, icon chổi, Trống • Cần dọn
/// 3. Thuê qua đêm: Nền xanh dương, icon khách, Đang ở • Tên khách / Giờ trả
/// 4. Thuê theo tiếng: Nền xanh ngọc (cyan), icon đồng hồ, Đang ở • Đếm ngược phút còn lại
/// 5. Quá giờ (Overdue): Nền đỏ báo động, viền nổi bật, Đang ở • Quá giờ lố phút
/// 6. Ngừng phục vụ: Nền xám slate, icon cờ lê, chỉ hiện Ngừng phục vụ
class RoomTile extends StatelessWidget {
  final Room room;
  final Stay? stay;
  final bool overdue;
  final bool selected;
  final VoidCallback? onTap;

  const RoomTile({
    super.key,
    required this.room,
    this.stay,
    this.overdue = false,
    this.selected = false,
    this.onTap,
  });

  /// Phòng đang ngừng phục vụ trên trục bảo trì.
  bool get _oos => room.service == ServiceStatus.outOfService;

  /// Phòng đang có khách ở.
  bool get _isOccupied => room.occupancy == OccupancyStatus.occupied;

  /// Chiều cao ô trên lưới theo chuẩn PMS (96px).
  static double extent(BuildContext context) =>
      MediaQuery.textScalerOf(context).scale(96);

  /// Rút gọn tên loại phòng thành mã 3-4 ký tự (ĐƠN, ĐÔI, VIP, DLX).
  static String _categoryTag(String typeName) {
    final upper = typeName.trim().toUpperCase();
    if (upper.contains('VIP')) return 'VIP';
    if (upper.contains('DELUXE') || upper.contains('DLX')) return 'DLX';
    if (upper.contains('ĐƠN') || upper.contains('SINGLE') || upper.contains('SGL')) return 'ĐƠN';
    if (upper.contains('ĐÔI') || upper.contains('DOUBLE') || upper.contains('DBL')) return 'ĐÔI';
    if (upper.contains('SUITE')) return 'SUI';
    if (upper.contains('FAMILY')) return 'FAM';
    final words = upper.split(' ');
    return words.first.length > 4 ? words.first.substring(0, 4) : words.first;
  }

  /// Phân loại 5 trường hợp trực quan cho lễ tân
  _TileVisual _resolveVisual(bool isOverdue) {
    final now = DateTime.now();

    // TRƯỜNG HỢP PHÒNG NGỪNG PHỤC VỤ (BẢO TRÌ)
    // Spec & Test: phòng ngừng phục vụ chỉ hiện dòng "Ngừng phục vụ"
    if (_oos) {
      return const _TileVisual(
        bgColor: AppColors.solidOos,
        textColor: Colors.white,
        subTextColor: Color(0xFFF1F5F9),
        icon: Icons.build_circle_rounded,
        title: 'Ngừng phục vụ',
        subtitle: 'Đang bảo trì phòng',
      );
    }

    // TRƯỜNG HỢP 5: KHÁCH Ở QUÁ GIỜ / VIỆC QUÁ HẠN (OVERTIME / BÁO ĐỘNG)
    if (isOverdue) {
      String subtitle = 'Quá hạn';
      if (stay?.expectedCheckout != null) {
        final lateMin = now.difference(stay!.expectedCheckout!).inMinutes;
        final checkoutStr = DateFormat('HH:mm').format(stay!.expectedCheckout!.toLocal());
        subtitle = lateMin > 0 ? 'Lố +${lateMin}p (từ $checkoutStr)' : 'Quá hạn từ $checkoutStr';
      }
      return _TileVisual(
        bgColor: AppColors.solidOverdue,
        textColor: Colors.white,
        subTextColor: const Color(0xFFFFD2D2),
        icon: Icons.warning_amber_rounded,
        title: room.occupancy.label,
        subtitle: subtitle,
        isOverdue: true,
      );
    }

    // TRƯỜNG HỢP 4: THUÊ THEO TIẾNG (ĐẾM NGƯỢC THỜI GIAN)
    if (_isOccupied && stay?.expectedCheckout != null) {
      final diff = stay!.expectedCheckout!.difference(now);
      // Nếu giờ trả trong vòng 8 tiếng tới -> coi là thuê theo tiếng
      if (diff.inMinutes > 0 && diff.inHours < 8) {
        final checkoutStr = DateFormat('HH:mm').format(stay!.expectedCheckout!.toLocal());
        final String timeRemains = diff.inMinutes < 60
            ? 'Còn ${diff.inMinutes}p ($checkoutStr)'
            : 'Còn ${diff.inHours}h${diff.inMinutes % 60}p ($checkoutStr)';

        return _TileVisual(
          bgColor: AppColors.solidHourly,
          textColor: Colors.white,
          subTextColor: const Color(0xFFE0F2FE),
          icon: Icons.access_time_filled_rounded,
          title: 'Đang ở',
          subtitle: timeRemains,
        );
      }
    }

    // TRƯỜNG HỢP 3: THUÊ QUA ĐÊM (BÌNH THƯỜNG)
    if (_isOccupied) {
      String subtitle = 'Trả 12:00';
      if (stay != null) {
        final guest = stay!.guestName.trim().isNotEmpty ? stay!.guestName : 'Khách';
        if (stay!.expectedCheckout != null) {
          final checkoutStr = DateFormat('HH:mm').format(stay!.expectedCheckout!.toLocal());
          subtitle = '$guest • $checkoutStr';
        } else {
          subtitle = guest;
        }
      }
      return _TileVisual(
        bgColor: AppColors.solidOccupied,
        textColor: Colors.white,
        subTextColor: const Color(0xFFDBEAFE),
        icon: Icons.person_rounded,
        title: 'Đang ở',
        subtitle: subtitle,
      );
    }

    // TRƯỜNG HỢP 1: PHÒNG TRỐNG SẴN SÀNG
    if (room.isReady) {
      return const _TileVisual(
        bgColor: AppColors.solidReady,
        textColor: Colors.white,
        subTextColor: Color(0xFFDCFCE7),
        icon: Icons.check_circle_rounded,
        title: 'Trống',
        subtitle: 'Sẵn sàng',
      );
    }

    // TRƯỜNG HỢP 2: PHÒNG TRỐNG CẦN DỌN
    if (room.cleaning == CleaningStatus.dirty) {
      return const _TileVisual(
        bgColor: AppColors.solidDirty,
        textColor: Colors.white,
        subTextColor: Color(0xFFFEF3C7),
        icon: Icons.cleaning_services_rounded,
        title: 'Trống',
        subtitle: 'Cần dọn',
      );
    }

    // Đang dọn
    if (room.cleaning == CleaningStatus.cleaning) {
      return const _TileVisual(
        bgColor: AppColors.solidCleaning,
        textColor: Colors.white,
        subTextColor: Color(0xFFF3E8FF),
        icon: Icons.hourglass_top_rounded,
        title: 'Trống',
        subtitle: 'Đang dọn',
      );
    }

    // Chờ duyệt
    if (room.cleaning == CleaningStatus.pendingInspection) {
      return const _TileVisual(
        bgColor: AppColors.solidInspect,
        textColor: Colors.white,
        subTextColor: Color(0xFFFCE7F3),
        icon: Icons.fact_check_rounded,
        title: 'Trống',
        subtitle: 'Chờ duyệt',
      );
    }

    return _TileVisual(
      bgColor: room.summaryTone.solidBg,
      textColor: Colors.white,
      subTextColor: Colors.white70,
      icon: room.summaryTone.icon,
      title: room.occupancy.label,
      subtitle: room.cleaning.label,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isStayLate = stay?.expectedCheckout != null &&
        stay!.expectedCheckout!.isBefore(DateTime.now());
    final isOverdue = overdue || isStayLate;

    final visual = _resolveVisual(isOverdue);
    final radius = BorderRadius.circular(AppTheme.radiusMd);

    final cardContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: visual.bgColor,
        borderRadius: radius,
        border: Border.all(
          color: visual.isOverdue
              ? Colors.white
              : (selected ? AppColors.goldLight : Colors.white.withValues(alpha: 0.15)),
          width: visual.isOverdue ? 2.5 : (selected ? 2.0 : 1.0),
        ),
        boxShadow: [
          if (visual.isOverdue)
            BoxShadow(
              color: AppColors.solidOverdue.withValues(alpha: 0.5),
              blurRadius: 8,
              spreadRadius: 1,
            )
          else if (selected)
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.4),
              blurRadius: 6,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Dòng 1: Số phòng + Tag loại phòng + Icon trạng thái
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    room.number,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.3,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  _categoryTag(room.roomType.name),
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                visual.icon,
                size: 15,
                color: Colors.white,
              ),
            ],
          ),

          // Đường gạch mảnh phân cách
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.22),
          ),

          // Dòng 2 & 3: Trạng thái chính + Chi tiết ngữ cảnh thực tế
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                visual.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.1,
                  height: 1.15,
                ),
              ),
              if (!_oos) ...[
                const SizedBox(height: 2),
                Text(
                  visual.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: visual.subTextColor,
                    letterSpacing: -0.1,
                    height: 1.1,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );

    // Chuỗi mô tả đầy đủ phục vụ trợ năng (Semantics) và Tooltip khi rê chuột
    final fullLabel =
        'Phòng ${room.number}: ${room.occupancy.label} · ${room.cleaning.label} · ${room.service.label}'
        '${isOverdue ? ' · quá hạn' : ''}';

    final tooltipDetail = StringBuffer()
      ..writeln('Phòng ${room.number} • ${room.roomType.name} (Tầng ${room.floor})');

    if (stay != null) {
      tooltipDetail.writeln('Khách: ${stay!.guestName} (${stay!.guestCount} người)');
      tooltipDetail.writeln('Nhận: ${DateFormat('dd/MM HH:mm').format(stay!.checkedInAt.toLocal())}');
      if (stay!.expectedCheckout != null) {
        tooltipDetail.writeln('Dự kiến trả: ${DateFormat('dd/MM HH:mm').format(stay!.expectedCheckout!.toLocal())}');
      }
      if (stay!.note?.isNotEmpty == true) {
        tooltipDetail.writeln('Ghi chú: ${stay!.note}');
      }
    } else {
      tooltipDetail.writeln('Trạng thái: ${room.summaryLabel}');
      tooltipDetail.writeln('Vệ sinh: ${room.cleaning.label}');
      tooltipDetail.writeln('Bảo trì: ${room.service.label}');
    }

    if (isOverdue) {
      tooltipDetail.writeln('⚠️ Đang có công việc hoặc lưu trú quá hạn!');
    }

    return Tooltip(
      message: tooltipDetail.toString().trim(),
      waitDuration: const Duration(milliseconds: 350),
      excludeFromSemantics: true,
      child: Semantics(
        button: onTap != null,
        label: fullLabel,
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: cardContent,
          ),
        ),
      ),
    );
  }
}

class _TileVisual {
  final Color bgColor;
  final Color textColor;
  final Color subTextColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isOverdue;

  const _TileVisual({
    required this.bgColor,
    required this.textColor,
    required this.subTextColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isOverdue = false,
  });
}
