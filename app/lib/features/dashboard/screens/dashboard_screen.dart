import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/room.dart';
import '../../../shared/widgets/room_tile.dart';
import '../../../shared/widgets/ui.dart';
import '../../rooms/providers/rooms_provider.dart';
import '../../rooms/widgets/room_detail_panel.dart';
import '../../stays/providers/stays_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/room_quick_action_menu.dart';

/// Nhóm lọc lưới phòng. Thẻ lấp đầy dùng lại [occupied], không có nhóm riêng.
enum _Group { all, ready, occupied, needsCleaning, outOfService, overdue }

/// Tổng quan (room-dashboard): 6 chỉ số tại thời điểm xem + lưới phòng realtime theo tầng.
class DashboardScreen extends ConsumerStatefulWidget {
  /// Phòng cần mở chi tiết ngay khi vào màn (`/dashboard?phong=<id>`).
  final String? openRoomId;

  const DashboardScreen({super.key, this.openRoomId});

  /// Tạo state lọc. Dữ liệu phòng và chỉ số do provider tự tải, không gọi API ở đây.
  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

/// Lọc tầng/nhóm và vẽ lưới. Mở sheet phòng khi route còn `phong`.
class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int? _floor;
  _Group _group = _Group.all;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Sau frame đầu, mở phòng nếu [DashboardScreen.openRoomId] có giá trị.
  @override
  void initState() {
    super.initState();
    _openRequestedRoom();
  }

  /// [DashboardScreen.openRoomId] đổi thì mở lại sheet. Cùng id không gọi lại.
  @override
  void didUpdateWidget(DashboardScreen old) {
    super.didUpdateWidget(old);
    if (widget.openRoomId != old.openRoomId) _openRequestedRoom();
  }

  /// Bỏ `?phong=` khỏi đường dẫn rồi mở chi tiết phòng — lần sau đi tới cùng phòng vẫn mở lại được.
  void _openRequestedRoom() {
    final roomId = widget.openRoomId;
    if (roomId == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.go('/dashboard');
      showRoomDetailSheet(context, roomId);
    });
  }

  /// Phòng có khớp tầng đang chọn, từ khóa tìm kiếm và nhóm [_group] không.
  /// [overdue] là tập id phòng có việc quá hạn từ chỉ số, không tự tính từ phòng.
  bool _matches(Room r, Set<String> overdue) {
    if (_searchQuery.isNotEmpty && !r.number.contains(_searchQuery)) {
      return false;
    }
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

  /// Tải lại danh sách phòng và chỉ số cùng lúc. Dùng cho kéo để làm mới và nút thử lại.
  Future<void> _reload() async {
    await Future.wait([
      ref.read(roomsProvider.notifier).load(),
      ref.read(dashboardSummaryProvider.notifier).load(),
      ref.read(staysProvider.notifier).load(),
    ]);
  }

  /// Chỉ số, bộ lọc, lưới theo tầng. Danh sách phòng rỗng kèm lỗi thì hiện [ErrorState], không vẽ số 0.
  @override
  Widget build(BuildContext context) {
    final roomsState = ref.watch(roomsProvider);
    final summaryState = ref.watch(dashboardSummaryProvider);
    final summary = summaryState.summary;
    // Cờ quá hạn lấy từ API chỉ số → lễ tân cũng thấy việc dọn quá hạn (FR-006).
    final overdue = summary.overdueRoomIds;
    final rooms = roomsState.sorted;
    final stays = ref.watch(staysProvider).stays;
    final stayMap = {for (final s in stays) s.room.id: s};
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
          rooms.where((r) => r.cleaning == CleaningStatus.dirty).length,
      _Group.outOfService:
          rooms.where((r) => r.service == ServiceStatus.outOfService).length,
      _Group.overdue: overdue.length,
    };

    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: pad,
        children: [
          // Chưa tải được chỉ số lần nào → báo lỗi + thử lại, không hiện số 0 như thật (FR-010).
          if (summaryState.error != null && summary.asOf == null)
            ErrorState(
              message: summaryState.error!,
              onRetry: () => ref.read(dashboardSummaryProvider.notifier).load(),
            )
          else
            _StatsGrid(
              summary: summary,
              group: _group,
              // Bấm thẻ chỉ số = lọc lưới theo nhóm đó; bấm lại thẻ đang chọn = bỏ lọc.
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
              // Ô tìm kiếm nhanh phòng gọn nhẹ trong Wrap (bỏ qua phím Tab để bảo toàn a11y)
              FocusTraversalGroup(
                descendantsAreTraversable: false,
                child: SizedBox(
                  width: 140,
                  height: 32,
                  child: TextField(
                    controller: _searchCtrl,
                    style: AppText.micro,
                    decoration: InputDecoration(
                      hintText: 'Tìm số phòng...',
                      hintStyle:
                          AppText.micro.copyWith(color: AppColors.muted),
                      prefixIcon: const Icon(Icons.search, size: 14),
                      prefixIconConstraints:
                          const BoxConstraints(minWidth: 26),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 6),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.clear, size: 12),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                    ),
                    onChanged: (val) =>
                        setState(() => _searchQuery = val.trim()),
                  ),
                ),
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
                  _searchCtrl.clear();
                  _searchQuery = '';
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
                        stay: stayMap[r.id],
                        overdue: overdue.contains(r.id),
                        onTap: () => showRoomQuickActionMenu(
                          context,
                          ref: ref,
                          room: r,
                          stay: stayMap[r.id],
                          onOpenFullDetail: () =>
                              showRoomDetailSheet(context, r.id),
                        ),
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

  /// Nhãn tiếng Việt của nhóm lọc trên pill.
  String _groupLabel(_Group g) => switch (g) {
        _Group.all => 'Tất cả',
        _Group.ready => 'Sẵn sàng',
        _Group.occupied => 'Đang ở',
        _Group.needsCleaning => 'Cần dọn',
        _Group.outOfService => 'Ngừng phục vụ',
        _Group.overdue => 'Quá hạn',
      };
}

/// Tiêu đề một tầng: số phòng trên tầng và số phòng sẵn sàng.
class _FloorHeader extends StatelessWidget {
  final int floor;
  final int total;
  final int ready;
  const _FloorHeader(
      {required this.floor, required this.total, required this.ready});

  /// Một dòng "Tầng n" và meta đếm. Không tự lọc phòng.
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

/// Sáu thẻ chỉ số. Bấm thẻ gọi [onSelect]; bố cục 2, 3 hoặc 6 cột theo bề ngang.
class _StatsGrid extends StatelessWidget {
  final DashboardSummary summary;
  final _Group group;
  final ValueChanged<_Group> onSelect;
  const _StatsGrid(
      {required this.summary, required this.group, required this.onSelect});

  /// Dựng [_StatCard] đã gắn nhóm [g] và [onSelect]. [selected] khi [group] trùng [g].
  _StatCard _card(_Group g,
          {required String label,
          required String value,
          required String sub,
          required Color color,
          bool alert = false,
          bool hero = false}) =>
      _StatCard(
        label: label,
        value: value,
        sub: sub,
        color: color,
        alert: alert,
        hero: hero,
        selected: group == g,
        onTap: () => onSelect(g),
      );

  /// Xếp thẻ theo bề ngang. Thẻ lấp đầy lọc nhóm đang ở, không có nhóm riêng.
  @override
  Widget build(BuildContext context) {
    final cards = [
      _card(_Group.occupied,
          label: 'Đang ở',
          value: '${summary.occupied}',
          sub: 'phòng có khách',
          color: AppColors.occupied),
      _card(_Group.ready,
          label: 'Sẵn sàng',
          value: '${summary.ready}',
          sub: 'nhận khách được ngay',
          color: AppColors.ready),
      _card(
        _Group.needsCleaning,
        label: 'Cần dọn',
        value: '${summary.needsCleaning}',
        sub:
            '+${summary.cleaningNow} đang dọn · ${summary.pendingInspection} chờ kiểm tra',
        color: AppColors.dirty,
      ),
      _card(_Group.outOfService,
          label: 'Ngừng phục vụ',
          value: '${summary.outOfService}',
          sub: 'đang chờ sửa',
          color: AppColors.oos),
      _card(
        _Group.overdue,
        label: 'Quá hạn',
        value: '${summary.overdueTotal}',
        sub:
            '${summary.overdueHousekeeping} việc dọn · ${summary.overdueMaintenance} việc sửa',
        color: AppColors.danger,
        alert: summary.overdueTotal > 0,
      ),
      // Lấp đầy = phòng đang ở ÷ phòng phục vụ được → lọc các phòng đang ở.
      _card(
        _Group.occupied,
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

/// Một thẻ chỉ số bấm được. [hero] là nền tối (lấp đầy). [alert] tô đỏ khi có việc quá hạn.
/// [selected] vẽ viền đậm. [onTap] do lưới gắn, thẻ không đổi state lọc.
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color color;
  final bool alert;
  final bool hero;
  final bool selected;
  final VoidCallback onTap;

  const _StatCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
    required this.onTap,
    this.alert = false,
    this.hero = false,
    this.selected = false,
  });

  /// Vẽ nhãn, số và dòng phụ. Không gọi API.
  @override
  Widget build(BuildContext context) {
    final bg = hero
        ? AppColors.espresso
        : (alert ? AppColors.dangerSurface : AppColors.surface);
    // Đang lọc theo thẻ này → viền vàng dày, như ô phòng đang chọn.
    final border = selected
        ? (hero ? AppColors.goldLight : AppColors.gold)
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
    return Semantics(
      button: true,
      selected: selected,
      hint: selected ? 'Bấm để bỏ lọc' : 'Bấm để lọc lưới phòng',
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: border, width: selected ? 2 : 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            // Cao đủ cho nhãn + số + 2 dòng mô tả; co giãn theo cỡ chữ hệ thống để không tràn.
            height: MediaQuery.textScalerOf(context).scale(134),
            padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
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
          ),
        ),
      ),
    );
  }
}
