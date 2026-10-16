import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/housekeeping_task.dart';
import '../../../models/maintenance_task.dart';
import '../../../models/room.dart';
import '../../../models/user.dart';
import '../../../shared/widgets/room_tile.dart';
import '../../../shared/widgets/ui.dart';
import '../../auth/providers/auth_provider.dart';
import '../../housekeeping/providers/housekeeping_provider.dart';
import '../../maintenance/providers/maintenance_provider.dart';
import '../../rooms/providers/rooms_provider.dart';
import '../../rooms/widgets/room_detail_panel.dart';
import '../providers/dashboard_provider.dart';

enum _Group { all, ready, occupied, needsCleaning, outOfService, overdue }

/// Tổng quan (room-dashboard): 6 chỉ số tại thời điểm xem + lưới phòng realtime theo tầng.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int? _floor;
  _Group _group = _Group.all;

  /// Phòng có việc quá hạn — chỉ đọc nguồn mà vai trò được phép gọi API.
  Set<String> _overdueRoomIds(UserRole? role) {
    final ids = <String>{};
    if (role == UserRole.manager) {
      for (final t in ref.watch(housekeepingProvider).tasks) {
        if (t.isOverdue && t.status != HousekeepingStatus.done) {
          ids.add(t.room.id);
        }
      }
    }
    for (final t in ref.watch(maintenanceProvider).tasks) {
      if (t.isOverdue &&
          (t.status == MaintenanceStatus.open ||
              t.status == MaintenanceStatus.inProgress)) {
        ids.add(t.room.id);
      }
    }
    return ids;
  }

  bool _matches(Room r, Set<String> overdue) {
    if (_floor != null && r.floor != _floor) return false;
    switch (_group) {
      case _Group.all:
        return true;
      case _Group.ready:
        return r.isReady;
      case _Group.occupied:
        return r.occupancy == OccupancyStatus.occupied;
      case _Group.needsCleaning:
        return r.cleaning != CleaningStatus.clean;
      case _Group.outOfService:
        return r.service == ServiceStatus.outOfService;
      case _Group.overdue:
        return overdue.contains(r.id);
    }
  }

  Future<void> _reload() async {
    await Future.wait([
      ref.read(roomsProvider.notifier).load(),
      ref.read(dashboardSummaryProvider.notifier).load(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final roomsState = ref.watch(roomsProvider);
    final summary = ref.watch(dashboardSummaryProvider).summary;
    final role = ref.watch(authProvider.select((s) => s.user?.role));
    final overdue = _overdueRoomIds(role);
    final rooms = roomsState.sorted;
    final wide = Breakpoints.hasSidebar(context);
    final pad = wide
        ? const EdgeInsets.fromLTRB(32, 24, 32, 32)
        : const EdgeInsets.fromLTRB(16, 16, 16, 24);

    final gate = initialLoadGate(
      loading: roomsState.isLoading,
      error: roomsState.error,
      isEmpty: rooms.isEmpty,
      onRetry: _reload,
      skeleton: const SkeletonGrid(header: true),
    );
    if (gate != null) return gate;

    final visible = rooms.where((r) => _matches(r, overdue)).toList();
    final floors = roomsState.availableFloors;
    final byFloor = <int, List<Room>>{};
    for (final r in visible) {
      byFloor.putIfAbsent(r.floor, () => []).add(r);
    }
    final counts = {
      _Group.all: rooms.length,
      _Group.ready: rooms.where((r) => r.isReady).length,
      _Group.occupied:
          rooms.where((r) => r.occupancy == OccupancyStatus.occupied).length,
      _Group.needsCleaning:
          rooms.where((r) => r.cleaning != CleaningStatus.clean).length,
      _Group.outOfService:
          rooms.where((r) => r.service == ServiceStatus.outOfService).length,
      _Group.overdue: overdue.length,
    };

    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView(
        padding: pad,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _StatsGrid(
            summary: summary,
            selected: _group,
            // Bấm thẻ số liệu để lọc lưới theo nhóm đó; bấm lại để bỏ lọc.
            onSelect: (g) =>
                setState(() => _group = _group == g ? _Group.all : g),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Tầng',
                  style: AppText.meta.copyWith(
                      color: AppColors.muted, fontWeight: FontWeight.w500)),
              SegmentedPills<int?>(
                options: [(null, 'Tất cả'), for (final f in floors) (f, '$f')],
                value: _floor,
                onChanged: (v) => setState(() => _floor = v),
              ),
              const SizedBox(width: 8),
              for (final g in _Group.values)
                FilterPill(
                  label: '${_groupLabel(g)} · ${counts[g]}',
                  selected: _group == g,
                  color: g == _Group.overdue ? AppColors.danger : null,
                  onTap: () => setState(() => _group = g),
                ),
            ],
          ),
          const SizedBox(height: 20),
          if (rooms.isEmpty)
            const EmptyState(
              icon: Icons.bed_outlined,
              title: 'Chưa có phòng nào trong danh mục.',
              message:
                  'Quản lý thêm phòng ở mục Phòng, lưới phòng sẽ hiện ở đây.',
            )
          else if (visible.isEmpty)
            EmptyState(
              icon: Icons.filter_alt_off_outlined,
              title: 'Không có phòng nào khớp bộ lọc.',
              action: TextButton(
                onPressed: () => setState(() {
                  _floor = null;
                  _group = _Group.all;
                }),
                child: const Text('Xóa bộ lọc'),
              ),
            )
          else
            for (final entry in byFloor.entries) ...[
              _FloorHeader(
                floor: entry.key,
                total: rooms.where((r) => r.floor == entry.key).length,
                ready: rooms
                    .where((r) => r.floor == entry.key && r.isReady)
                    .length,
              ),
              const SizedBox(height: 8),
              LayoutBuilder(
                // Tối đa 10 ô/hàng (1 tầng = 10 phòng), ô không hẹp hơn ~88px.
                builder: (context, c) => GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        ((c.maxWidth + 8) / 96).floor().clamp(3, 10),
                    mainAxisExtent: RoomTile.extent(context),
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  children: [
                    for (final r in entry.value)
                      RoomTile(
                        room: r,
                        overdue: overdue.contains(r.id),
                        onTap: () => showRoomDetailSheet(context, r.id),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
            ],
        ],
      ),
    );
  }

  String _groupLabel(_Group g) => switch (g) {
        _Group.all => 'Tất cả',
        _Group.ready => 'Sẵn sàng',
        _Group.occupied => 'Đang ở',
        _Group.needsCleaning => 'Cần dọn',
        _Group.outOfService => 'Ngừng phục vụ',
        _Group.overdue => 'Quá hạn',
      };
}

class _FloorHeader extends StatelessWidget {
  final int floor;
  final int total;
  final int ready;
  const _FloorHeader(
      {required this.floor, required this.total, required this.ready});

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text('Tầng $floor',
              style: AppText.body.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(width: 10),
          MetaText('$total phòng · $ready sẵn sàng'),
        ],
      );
}

class _StatsGrid extends StatelessWidget {
  final DashboardSummary summary;
  final _Group selected;
  final ValueChanged<_Group> onSelect;
  const _StatsGrid(
      {required this.summary, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatCard(
          label: 'Đang ở',
          group: _Group.occupied,
          value: '${summary.occupied}',
          sub: 'phòng có khách',
          color: AppColors.occupied),
      _StatCard(
          label: 'Sẵn sàng',
          group: _Group.ready,
          value: '${summary.ready}',
          sub: 'nhận khách được ngay',
          color: AppColors.ready),
      _StatCard(
        label: 'Cần dọn',
        group: _Group.needsCleaning,
        value: '${summary.needsCleaning}',
        sub:
            '+${summary.cleaningNow} đang dọn · ${summary.pendingInspection} chờ kiểm tra',
        color: AppColors.dirty,
      ),
      _StatCard(
          label: 'Ngừng phục vụ',
          group: _Group.outOfService,
          value: '${summary.outOfService}',
          sub: 'đang chờ sửa',
          color: AppColors.oos),
      _StatCard(
        label: 'Quá hạn',
        group: _Group.overdue,
        value: '${summary.overdueTotal}',
        sub:
            '${summary.overdueHousekeeping} việc dọn · ${summary.overdueMaintenance} việc sửa',
        color: AppColors.danger,
        alert: summary.overdueTotal > 0,
      ),
      _StatCard(
        label: 'Lấp đầy',
        value: summary.occupancyRateLabel,
        sub:
            '${summary.occupied} / ${summary.occupancyServiceable} phòng phục vụ được',
        color: AppColors.gold,
        hero: true,
      ),
    ];
    return LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth >= 1000
          ? 6
          : c.maxWidth >= 560
              ? 3
              : 2;
      const gap = 16.0;
      final w = (c.maxWidth - gap * (cols - 1)) / cols;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final card in cards)
            SizedBox(
              width: w,
              child: card.group == null
                  ? card
                  : card.copyWithSelection(
                      selected: card.group == selected,
                      onTap: () => onSelect(card.group!)),
            ),
        ],
      );
    });
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color color;
  final bool alert;
  final bool hero;

  /// Nhóm lọc tương ứng; `null` = thẻ chỉ để xem (Lấp đầy).
  final _Group? group;
  final bool selected;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
    this.alert = false,
    this.hero = false,
    this.group,
    this.selected = false,
    this.onTap,
  });

  _StatCard copyWithSelection(
          {required bool selected, required VoidCallback onTap}) =>
      _StatCard(
        label: label,
        value: value,
        sub: sub,
        color: color,
        alert: alert,
        hero: hero,
        group: group,
        selected: selected,
        onTap: onTap,
      );

  @override
  Widget build(BuildContext context) {
    final bg = hero
        ? AppColors.espresso
        : (alert ? AppColors.dangerSurface : AppColors.surface);
    final border = selected
        ? AppColors.goldDark
        : hero
            ? AppColors.espresso
            : (alert ? AppColors.dangerBorder : AppColors.border);
    final labelColor = hero
        ? AppColors.onDarkMuted
        : (alert ? AppColors.danger : AppColors.muted);
    final valueColor = hero
        ? AppColors.goldLight
        : (alert ? AppColors.danger : AppColors.text);
    final radius = BorderRadius.circular(AppTheme.radiusMd);
    final card = Container(
      // Cao đủ cho nhãn + số + 2 dòng mô tả; co giãn theo cỡ chữ hệ thống để không tràn.
      height: MediaQuery.textScalerOf(context).scale(134),
      padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: radius,
        border: Border.all(color: border, width: selected ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(3)),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(label,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.meta.copyWith(
                        color: labelColor, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                style: AppText.display.copyWith(
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                    color: valueColor)),
          ),
          const SizedBox(height: 2),
          Text(sub,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppText.caption.copyWith(
                  height: 1.3,
                  color: hero ? AppColors.onDarkMuted : AppColors.muted)),
        ],
      ),
    );
    if (onTap == null) {
      return Semantics(
          label: '$label: $value, $sub', child: ExcludeSemantics(child: card));
    }
    return Semantics(
      button: true,
      selected: selected,
      label: '$label: $value, $sub',
      hint: selected ? 'Bấm để bỏ lọc' : 'Bấm để lọc lưới phòng',
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(borderRadius: radius, onTap: onTap, child: card),
      ),
    );
  }
}
