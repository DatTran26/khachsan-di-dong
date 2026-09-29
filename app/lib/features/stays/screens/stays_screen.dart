import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/stays_provider.dart';
import '../../../models/stay.dart';
import '../../rooms/providers/rooms_provider.dart';

class StaysScreen extends ConsumerWidget {
  const StaysScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(staysProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lượt lưu trú'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Tải lại',
            onPressed: () => ref.read(staysProvider.notifier).load(),
          ),
        ],
      ),
      body: _buildBody(context, ref, state),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, StaysState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red[400], size: 40),
            const SizedBox(height: 8),
            Text(state.error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref.read(staysProvider.notifier).load(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }
    if (state.stays.isEmpty) {
      return const Center(child: Text('Không có phòng nào đang có khách.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: state.stays.length,
      itemBuilder: (context, i) => _StayCard(stay: state.stays[i], onCheckOut: () => _confirmCheckOut(context, ref, state.stays[i])),
    );
  }

  Future<void> _confirmCheckOut(BuildContext context, WidgetRef ref, Stay stay) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận trả phòng'),
        content: Text('Trả phòng ${stay.room.number} cho khách ${stay.guestName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Trả phòng')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      final roomsNotifier = ref.read(roomsProvider.notifier);
      final rooms = ref.read(roomsProvider).rooms;
      final room = rooms.firstWhere((r) => r.id == stay.room.id, orElse: () => throw Exception('Không tìm thấy phòng'));
      await roomsNotifier.checkOut(roomId: stay.room.id, version: room.version);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã trả phòng ${stay.room.number}')),
        );
        ref.read(staysProvider.notifier).load();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }
}

class _StayCard extends StatelessWidget {
  final Stay stay;
  final VoidCallback onCheckOut;

  const _StayCard({required this.stay, required this.onCheckOut});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    final duration = DateTime.now().difference(stay.checkedInAt);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'T${stay.room.floor}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  Text(
                    stay.room.number,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1565C0)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stay.guestName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text('${stay.guestCount} khách · Nhận: ${fmt.format(stay.checkedInAt.toLocal())}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  Text('Đã ở: ${hours}h ${minutes}m',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  if (stay.expectedCheckout != null)
                    Text('Dự kiến trả: ${fmt.format(stay.expectedCheckout!.toLocal())}',
                        style: TextStyle(fontSize: 12, color: Colors.orange[700])),
                  if (stay.note != null && stay.note!.isNotEmpty)
                    Text('Ghi chú: ${stay.note}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: onCheckOut,
              icon: const Icon(Icons.logout, size: 16),
              label: const Text('Trả phòng'),
              style: TextButton.styleFrom(foregroundColor: Colors.red[700]),
            ),
          ],
        ),
      ),
    );
  }
}
