import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/room.dart';
import '../../../shared/widgets/room_tile.dart';
import '../../../shared/widgets/ui.dart';
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
        // "Cần dọn" chỉ là trạng thái `cần dọn` — khớp ô chỉ số (room-dashboard PRD đã chốt).
        return r.cleaning == CleaningStatus.dirty;
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
    final summaryState = ref.watch(dashboardSummaryProvider);
    final summary = summaryState.summary;
    // Cờ quá hạn lấy từ API chỉ số → lễ tân cũng thấy việc dọn quá hạn (FR-006).
    final overdue = summary.overdueRoomIds;
    final rooms = roomsState.sorted;
    final wide = Breakpoints.hasSidebar(context);
    final pad = wide
        ? const EdgeInsets.fromLTRB(32, 24, 32, 32)
        : const EdgeInsets.fromLTRB(16, 16, 16, 24);

    if (roomsState.isLoading && rooms.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (roomsState.error != null && rooms.isEmpty) {
      return ErrorState(message: roomsState.error!, onRetry: _reload);
    }

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
          rooms.where((r) => r.cleaning == CleaningStatus.dirty).length,
      _Group.outOfService:
          rooms.where((r) => r.service == ServiceStatus.outOfService).length,
      _Group.overdue: overdue.length,
    };

    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView(
        padding: pad,
        children: [
          // Chưa tải được chỉ số lần nào → báo lỗi + thử lại, không hiện số 0 như thật (FR-010).
          if (summaryState.error != null && summary.asOf == null)
            ErrorState(
              message: summaryState.error!,
              onRetry: () =>
                  ref.read(dashboardSummaryProvider.notifier).load(),
            )
          else
            _StatsGrid(summary: summary),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Tầng',
                  style: TextStyle(
                      fontSize: 13,
                      color: AppColors.muted,
                      fontWeight: FontWeight.w500)),
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
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(width: 10),
          MetaText('$total phòng · $ready sẵn sàng'),
        ],
      );
}

class _StatsGrid extends StatelessWidget {
  final DashboardSummary summary;
  const _StatsGrid({required this.summary});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatCard(
          label: 'Đang ở',
          value: '${summary.occupied}',
          sub: 'phòng có khách',
          color: AppColors.occupied),
      _StatCard(
          label: 'Sẵn sàng',
          value: '${summary.ready}',
          sub: 'nhận khách được ngay',
          color: AppColors.ready),
      _StatCard(
        label: 'Cần dọn',
        value: '${summary.needsCleaning}',
        sub:
            '+${summary.cleaningNow} đang dọn · ${summary.pendingInspection} chờ kiểm tra',
        color: AppColors.dirty,
      ),
      _StatCard(
          label: 'Ngừng phục vụ',
          value: '${summary.outOfService}',
          sub: 'đang chờ sửa',
          color: AppColors.oos),
      _StatCard(
        label: 'Quá hạn',
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
        children: [for (final card in cards) SizedBox(width: w, child: card)],
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

  const _StatCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
    this.alert = false,
    this.hero = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = hero
        ? AppColors.espresso
        : (alert ? const Color(0xFFFFF8F8) : AppColors.surface);
    final border = hero
        ? AppColors.espresso
        : (alert ? const Color(0xFFF2C4C6) : AppColors.border);
    final labelColor = hero
        ? AppColors.onDarkMuted
        : (alert ? AppColors.danger : AppColors.muted);
    final valueColor = hero
        ? AppColors.goldLight
        : (alert ? AppColors.danger : AppColors.text);
    return Container(
      // Cao đủ cho nhãn + số + 2 dòng mô tả; co giãn theo cỡ chữ hệ thống để không tràn.
      height: MediaQuery.textScalerOf(context).scale(134),
      padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: border),
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
                    style: TextStyle(
                        fontSize: 13,
                        color: labelColor,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                style: TextStyle(
                    fontSize: 28,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                    color: valueColor)),
          ),
          const SizedBox(height: 2),
          Text(sub,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 12,
                  height: 1.3,
                  color: hero ? AppColors.onDarkMuted : AppColors.muted)),
        ],
      ),
    );
  }
}
