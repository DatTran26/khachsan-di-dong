import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/room.dart';
import '../../../models/user.dart';
import '../../../shared/widgets/room_tile.dart';
import '../../../shared/widgets/ui.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/rooms_provider.dart';
import '../widgets/room_detail_panel.dart';
import 'room_form_screen.dart';
import 'room_types_screen.dart';

/// Phòng (room-catalog + check-in-out).
/// Web: bảng phòng + khung chi tiết bên phải. Mobile: lưới ô phòng, bấm để mở chi tiết.
class RoomsScreen extends ConsumerStatefulWidget {
  const RoomsScreen({super.key});

  /// Tạo state chọn phòng và ô tìm. Danh sách do [roomsProvider] tự tải.
  @override
  ConsumerState<RoomsScreen> createState() => _RoomsScreenState();
}

/// Chọn phòng trên bảng rộng và mở sheet trên màn hẹp.
class _RoomsScreenState extends ConsumerState<RoomsScreen> {
  String? _selectedId;
  final _search = TextEditingController();

  /// Giải phóng controller ô tìm. Không đổi bộ lọc trên provider.
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// Ghi bộ lọc mới vào [roomsProvider]. Không gọi API.
  void _setFilter(RoomsFilter f) =>
      ref.read(roomsProvider.notifier).setFilter(f);

  /// Bảng hoặc lưới phòng theo bề ngang. Màn rộng gắn [RoomDetailPanel] bên phải.
  /// Lỗi khi danh sách rỗng thì [ErrorState], không vẽ bảng trống.
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(roomsProvider);
    final role = ref.watch(authProvider.select((s) => s.user?.role));
    final wide = Breakpoints.isWide(context);
    final rooms = state.filtered;
    final selected = _selectedId != null ? state.byId(_selectedId!) : null;

    if (state.isLoading && state.rooms.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null && state.rooms.isEmpty) {
      return ErrorState(
          message: state.error!,
          onRetry: () => ref.read(roomsProvider.notifier).load());
    }

    final toolbar = _Toolbar(
      filter: state.filter,
      floors: state.availableFloors,
      search: _search,
      canCreate: role == UserRole.manager,
      readyCount: state.rooms.where((r) => r.isReady).length,
      onChanged: _setFilter,
    );

    final Widget list;
    if (state.rooms.isEmpty) {
      list = EmptyState(
        icon: Icons.bed_outlined,
        title: 'Chưa có phòng nào trong danh mục.',
        message: role == UserRole.manager
            ? 'Thêm phòng lẻ hoặc tạo theo dải số (ví dụ 101–110) để bắt đầu.'
            : 'Quản lý sẽ nhập danh mục phòng. Phòng mới sẽ tự hiện ở đây.',
      );
    } else if (rooms.isEmpty) {
      list = EmptyState(
        icon: Icons.filter_alt_off_outlined,
        title: 'Không có phòng nào khớp bộ lọc.',
        action: TextButton(
          onPressed: () {
            _search.clear();
            ref.read(roomsProvider.notifier).clearFilter();
          },
          child: const Text('Xóa bộ lọc'),
        ),
      );
    } else if (wide) {
      list = _RoomTable(
        rooms: rooms,
        total: state.rooms.length,
        selectedId: _selectedId,
        onSelect: (r) => setState(() => _selectedId = r.id),
      );
    } else {
      list = GridView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 128,
          mainAxisExtent: RoomTile.extent(context),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        children: [
          for (final r in rooms)
            RoomTile(room: r, onTap: () => showRoomDetailSheet(context, r.id)),
        ],
      );
    }

    if (!wide) {
      return Column(
        children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: toolbar),
          Expanded(child: list),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                toolbar,
                const SizedBox(height: 16),
                Expanded(child: list)
              ],
            ),
          ),
        ),
        Container(
          width: 400,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(left: BorderSide(color: AppColors.border)),
          ),
          child: selected == null
              ? const EmptyState(
                  icon: Icons.touch_app_outlined,
                  title: 'Chọn một phòng',
                  message:
                      'Chi tiết và thao tác nhận phòng, trả phòng, báo hỏng sẽ hiện ở đây.',
                )
              : RoomDetailPanel(
                  key: ValueKey(selected.id),
                  roomId: selected.id,
                  onClose: () => setState(() => _selectedId = null),
                ),
        ),
      ],
    );
  }
}

/// Ô tìm, lọc tầng / sẵn sàng / ngừng phục vụ. Nút loại phòng và thêm phòng chỉ khi [canCreate].
class _Toolbar extends StatelessWidget {
  final RoomsFilter filter;
  final List<int> floors;
  final TextEditingController search;
  final bool canCreate;
  final int readyCount;
  final ValueChanged<RoomsFilter> onChanged;

  const _Toolbar({
    required this.filter,
    required this.floors,
    required this.search,
    required this.canCreate,
    required this.readyCount,
    required this.onChanged,
  });

  /// Gọi [onChanged] khi đổi ô tìm hoặc pill. Mở màn loại phòng hoặc form thêm, không tự ghi phòng.
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 220,
          child: TextField(
            controller: search,
            onChanged: (v) => onChanged(filter.copyWith(query: v)),
            decoration: const InputDecoration(
              hintText: 'Tìm số phòng…',
              prefixIcon: Icon(Icons.search, size: 20),
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        SegmentedPills<int?>(
          options: [(null, 'Tất cả tầng'), for (final f in floors) (f, '$f')],
          value: filter.floor,
          onChanged: (v) => onChanged(filter.copyWith(floor: v)),
        ),
        FilterPill(
          label: 'Chỉ phòng sẵn sàng · $readyCount',
          selected: filter.readyOnly,
          onTap: () => onChanged(filter.copyWith(readyOnly: !filter.readyOnly)),
        ),
        FilterPill(
          label: 'Ngừng phục vụ',
          selected: filter.service == ServiceStatus.outOfService,
          onTap: () => onChanged(filter.copyWith(
            service: filter.service == ServiceStatus.outOfService
                ? null
                : ServiceStatus.outOfService,
          )),
        ),
        if (canCreate)
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RoomTypesScreen())),
            icon: const Icon(Icons.category_outlined, size: 18),
            label: const Text('Loại phòng'),
          ),
        if (canCreate)
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RoomFormScreen())),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Thêm phòng'),
          ),
      ],
    );
  }
}

/// Bảng phòng trên màn rộng. Bấm hàng gọi [onSelect], không mở sheet.
class _RoomTable extends StatelessWidget {
  final List<Room> rooms;
  final int total;
  final String? selectedId;
  final ValueChanged<Room> onSelect;

  const _RoomTable(
      {required this.rooms,
      required this.total,
      required this.selectedId,
      required this.onSelect});

  static const _flex = [12, 12, 12, 14, 16, 10];

  /// "14:05" nếu hôm nay, "14:05 28/09" nếu ngày khác.
  static String _when(DateTime t) {
    final l = t.toLocal(), n = DateTime.now();
    final today = l.year == n.year && l.month == n.month && l.day == n.day;
    return DateFormat(today ? 'HH:mm' : 'HH:mm dd/MM').format(l);
  }

  /// Hàng tiêu đề, từng phòng và dòng đếm. Không gọi API.
  @override
  Widget build(BuildContext context) {
    /// Ô một cột theo flex [_flex], căn trái.
    Widget cell(int i, Widget child) => Expanded(
        flex: _flex[i],
        child: Align(alignment: Alignment.centerLeft, child: child));
    const head = TextStyle(
        fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.muted);

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            color: const Color(0xFFFAF8F3),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              cell(0, const Text('Phòng', style: head)),
              cell(1, const Text('Loại', style: head)),
              cell(2, const Text('Lưu trú', style: head)),
              cell(3, const Text('Vệ sinh', style: head)),
              cell(4, const Text('Bảo trì', style: head)),
              cell(5, const Text('Cập nhật', style: head)),
            ]),
          ),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: ListView.separated(
              itemCount: rooms.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final r = rooms[i];
                return Material(
                  color: r.id == selectedId
                      ? AppColors.goldTint
                      : Colors.transparent,
                  child: InkWell(
                    onTap: () => onSelect(r),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(children: [
                        cell(
                          0,
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r.number,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14)),
                                Text('Tầng ${r.floor}',
                                    style: const TextStyle(
                                        fontSize: 12, color: AppColors.muted)),
                              ]),
                        ),
                        cell(
                            1,
                            Text(r.roomType.name,
                                style: const TextStyle(fontSize: 14))),
                        cell(
                            2,
                            StatusChip(r.occupancy.label,
                                tone: r.occupancy.tone)),
                        cell(
                            3,
                            StatusChip(r.cleaning.label,
                                tone: r.cleaning.tone)),
                        cell(4,
                            StatusChip(r.service.label, tone: r.service.tone)),
                        cell(5, MetaText(_when(r.updatedAt))),
                      ]),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Align(
                alignment: Alignment.centerLeft,
                child: MetaText('Đang hiện ${rooms.length} / $total phòng')),
          ),
        ],
      ),
    );
  }
}
