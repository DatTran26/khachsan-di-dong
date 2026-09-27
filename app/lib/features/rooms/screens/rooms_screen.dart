import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/rooms_provider.dart';
import '../screens/room_form_screen.dart';
import '../widgets/room_card.dart';
import '../widgets/room_filter_bar.dart';
import '../../dashboard/widgets/offline_banner.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../models/user.dart';
import '../../../models/room.dart';
import '../../../core/api/api_client.dart';
import '../../../shared/utils/error_handler.dart';

class RoomsScreen extends ConsumerWidget {
  const RoomsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(roomsProvider);
    final user = ref.watch(authProvider).user;
    final isManager = user?.role == UserRole.manager;
    final isReceptionist = user?.role == UserRole.receptionist;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh mục phòng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(roomsProvider.notifier).load(),
            tooltip: 'Tải lại',
          ),
        ],
      ),
      floatingActionButton: isManager
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RoomFormScreen()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Thêm phòng'),
            )
          : null,
      body: Column(
        children: [
          if (!state.isConnected) const OfflineBanner(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: RoomFilterBar(
              filter: state.filter,
              floors: state.availableFloors,
              onChanged: (f) => ref.read(roomsProvider.notifier).setFilter(f),
            ),
          ),
          if (state.isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (state.error != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[400], size: 40),
                    const SizedBox(height: 8),
                    Text(state.error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ref.read(roomsProvider.notifier).load(),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            )
          else if (state.filtered.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_off, color: Colors.grey[400], size: 40),
                    const SizedBox(height: 8),
                    const Text('Không có phòng nào khớp bộ lọc.'),
                    if (state.filter.floor != null ||
                        state.filter.occupancy != null ||
                        state.filter.cleaning != null ||
                        state.filter.service != null) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => ref.read(roomsProvider.notifier).clearFilter(),
                        child: const Text('Xoá bộ lọc'),
                      ),
                    ],
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final crossCount = constraints.maxWidth > 900
                      ? 4
                      : constraints.maxWidth > 600
                          ? 3
                          : 2;
                  return GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossCount,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: state.filtered.length,
                    itemBuilder: (context, i) {
                      final room = state.filtered[i];
                      return GestureDetector(
                        onTap: (isReceptionist || isManager)
                            ? () => _showRoomActions(context, ref, room, user!)
                            : null,
                        child: RoomCard(
                          room: room,
                          onEdit: isManager
                              ? () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => RoomFormScreen(room: room)),
                                  )
                              : null,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showRoomActions(BuildContext context, WidgetRef ref, Room room, AppUser user) {
    final isReady = room.isReady;
    final isOccupied = room.occupancy == OccupancyStatus.occupied;
    final isOos = room.service == ServiceStatus.outOfService;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Phòng ${room.number} · Tầng ${room.floor}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${room.roomType.name} · ${room.occupancy.label} · ${room.cleaning.label}'),
            ),
            const Divider(),
            if (isReady)
              ListTile(
                leading: const Icon(Icons.login, color: Colors.green),
                title: const Text('Nhận phòng'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showCheckInDialog(context, ref, room);
                },
              ),
            if (isOccupied)
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Trả phòng'),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmCheckOut(context, ref, room);
                },
              ),
            if (!isOos && user.role == UserRole.manager)
              ListTile(
                leading: const Icon(Icons.block, color: Colors.orange),
                title: const Text('Đặt ngừng phục vụ'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showOutOfServiceDialog(context, ref, room);
                },
              ),
            if (isOos && user.role == UserRole.manager)
              ListTile(
                leading: const Icon(Icons.check_circle_outline, color: Colors.green),
                title: const Text('Đưa vào phục vụ'),
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    await ref.read(roomsProvider.notifier).backInService(roomId: room.id, version: room.version);
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã đưa phòng vào phục vụ')));
                  } on ApiException catch (e) {
                    if (context.mounted) handleApiError(context, e, onReload: () => ref.read(roomsProvider.notifier).load());
                  }
                },
              ),
            if (user.role == UserRole.manager)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Xóa phòng', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDeleteRoom(context, ref, room);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _showCheckInDialog(BuildContext context, WidgetRef ref, Room room) async {
    final guestNameCtrl = TextEditingController();
    final guestCountCtrl = TextEditingController(text: '1');
    final noteCtrl = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Nhận phòng ${room.number}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: guestNameCtrl,
                decoration: const InputDecoration(labelText: 'Tên khách *', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: guestCountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Số khách *', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Ghi chú', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Nhận phòng'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    final guestName = guestNameCtrl.text.trim();
    if (guestName.isEmpty) return;
    final guestCount = int.tryParse(guestCountCtrl.text.trim()) ?? 1;

    try {
      await ref.read(roomsProvider.notifier).checkIn(
            roomId: room.id,
            version: room.version,
            guestName: guestName,
            guestCount: guestCount,
            note: noteCtrl.text.trim(),
          );
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã nhận phòng ${room.number} cho $guestName')));
    } on ApiException catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: Colors.red));
    }
  }

  Future<void> _confirmCheckOut(BuildContext context, WidgetRef ref, Room room) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Trả phòng ${room.number}'),
        content: const Text('Xác nhận trả phòng? Hệ thống sẽ tự tạo việc dọn phòng.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Trả phòng')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(roomsProvider.notifier).checkOut(roomId: room.id, version: room.version);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã trả phòng ${room.number}')));
    } on ApiException catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: Colors.red));
    }
  }

  Future<void> _confirmDeleteRoom(BuildContext context, WidgetRef ref, Room room) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Xóa phòng ${room.number}?'),
        content: const Text('Chỉ xóa được phòng chưa có lịch sử hoạt động (chưa từng có khách, dọn phòng, bảo trì).'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(roomsProvider.notifier).deleteRoom(roomId: room.id, version: room.version);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã xóa phòng ${room.number}')));
    } on ApiException catch (e) {
      if (context.mounted) handleApiError(context, e, onReload: () => ref.read(roomsProvider.notifier).load());
    }
  }

  Future<void> _showOutOfServiceDialog(BuildContext context, WidgetRef ref, Room room) async {
    final reasonCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Đặt ngừng phục vụ phòng ${room.number}'),
        content: TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(labelText: 'Lý do *', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              if (reasonCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx, true);
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(roomsProvider.notifier).setOutOfService(
            roomId: room.id,
            version: room.version,
            reason: reasonCtrl.text.trim(),
            confirmOccupied: room.occupancy == OccupancyStatus.occupied,
          );
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã đặt ngừng phục vụ')));
    } on ApiException catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: Colors.red));
    }
  }
}
