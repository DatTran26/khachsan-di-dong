import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/room.dart';
import '../../../models/stay.dart';
import '../../../models/user.dart';
import '../../../shared/widgets/ui.dart';
import '../../auth/providers/auth_provider.dart';
import '../../maintenance/widgets/report_issue_dialog.dart';
import '../../rooms/providers/rooms_provider.dart';
import '../../rooms/widgets/room_detail_panel.dart';
import 'quick_check_in_dialog.dart';

/// Menu thao tác nhanh dạng Popover/Sheet ngữ cảnh khi bấm vào một ô phòng trên Dashboard.
/// Giúp lễ tân/quản lý thực hiện các tác vụ phổ biến nhất (Nhận phòng, Trả phòng, Báo hỏng)
/// ngay lập tức trong 1-2 chạm.
Future<void> showRoomQuickActionMenu(
  BuildContext context, {
  required WidgetRef ref,
  required Room room,
  Stay? stay,
  required VoidCallback onOpenFullDetail,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    constraints: const BoxConstraints(maxWidth: 480),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _RoomQuickActionSheet(
      room: room,
      stay: stay,
      onOpenFullDetail: onOpenFullDetail,
    ),
  );
}

class _RoomQuickActionSheet extends ConsumerWidget {
  final Room room;
  final Stay? stay;
  final VoidCallback onOpenFullDetail;

  const _RoomQuickActionSheet({
    required this.room,
    this.stay,
    required this.onOpenFullDetail,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authProvider.select((s) => s.user?.role));
    final online = ref.watch(isOnlineProvider);
    final isReceptionist = role == UserRole.receptionist;
    final isOccupied = room.occupancy == OccupancyStatus.occupied;
    final isReady = room.isReady;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tiêu đề phòng
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.espresso,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    room.number,
                    style: AppText.titleLg.copyWith(
                      color: AppColors.goldLight,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phòng ${room.number} · ${room.roomType.name}',
                        style:
                            AppText.bodyLg.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'Tầng ${room.floor} · ${_statusSummary(room, stay)}',
                        style: AppText.caption.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 8),

            // Nhóm tác vụ nhanh theo trạng thái phòng
            if (isReady && isReceptionist) ...[
              _ActionTile(
                icon: Icons.flash_on_rounded,
                iconColor: AppColors.solidReady,
                bgColor: AppColors.solidReady.withValues(alpha: 0.1),
                title: 'Nhận phòng nhanh',
                subtitle: 'Nhập tên khách & chọn thời gian trong 3 giây',
                enabled: online,
                onTap: () {
                  Navigator.pop(context);
                  showQuickCheckInDialog(context, room: room);
                },
              ),
            ],

            if (isOccupied && isReceptionist) ...[
              _ActionTile(
                icon: Icons.logout_rounded,
                iconColor: AppColors.solidOccupied,
                bgColor: AppColors.solidOccupied.withValues(alpha: 0.1),
                title: 'Trả phòng ngay',
                subtitle:
                    'Khách: ${stay?.guestName ?? 'Khách'} · Hoàn tất lượt lưu trú',
                enabled: online,
                onTap: () {
                  Navigator.pop(context);
                  confirmCheckOut(context, ref, room,
                      guestName: stay?.guestName);
                },
              ),
            ],

            // Báo hỏng thiết bị (mọi vai trò)
            _ActionTile(
              icon: Icons.build_circle_outlined,
              iconColor: AppColors.dirty,
              bgColor: AppColors.dirty.withValues(alpha: 0.1),
              title: 'Báo hỏng phòng này',
              subtitle: 'Gửi yêu cầu sửa chữa thiết bị buồng phòng',
              enabled: online,
              onTap: () {
                Navigator.pop(context);
                showReportIssueDialog(context, roomId: room.id);
              },
            ),

            // Xem toàn bộ chi tiết phòng
            _ActionTile(
              icon: Icons.info_outline_rounded,
              iconColor: AppColors.muted,
              bgColor: AppColors.surfaceSunken,
              title: 'Xem toàn bộ chi tiết phòng',
              subtitle:
                  'Tiện nghi, lịch sử dọn dẹp, bảo trì và thao tác quản lý',
              onTap: () {
                Navigator.pop(context);
                onOpenFullDetail();
              },
            ),

            if (!online) ...[
              const SizedBox(height: 8),
              const OfflineActionNote(),
            ],
          ],
        ),
      ),
    );
  }

  static String _statusSummary(Room r, Stay? s) {
    if (r.service == ServiceStatus.outOfService) return 'Ngừng phục vụ';
    if (r.occupancy == OccupancyStatus.occupied) {
      return s != null ? 'Đang ở (${s.guestName})' : 'Đang ở';
    }
    if (r.cleaning == CleaningStatus.dirty) return 'Cần dọn';
    if (r.cleaning == CleaningStatus.cleaning) return 'Đang dọn';
    if (r.cleaning == CleaningStatus.pendingInspection) return 'Chờ nghiệm thu';
    return 'Sẵn sàng đón khách';
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: enabled ? bgColor : AppColors.surfaceSunken,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: enabled ? iconColor : AppColors.iconMuted,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppText.body.copyWith(
                          fontWeight: FontWeight.w700,
                          color: enabled ? AppColors.text : AppColors.iconMuted,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: AppText.micro.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.muted.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
