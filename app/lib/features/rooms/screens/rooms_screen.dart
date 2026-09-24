import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/rooms_provider.dart';
import '../widgets/room_card.dart';
import '../widgets/room_filter_bar.dart';
import '../../dashboard/widgets/offline_banner.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../models/user.dart';

class RoomsScreen extends ConsumerWidget {
  const RoomsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(roomsProvider);
    final user = ref.watch(authProvider).user;
    final isManager = user?.role == UserRole.manager;

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
                      childAspectRatio: 1.1,
                    ),
                    itemCount: state.filtered.length,
                    itemBuilder: (context, i) {
                      final room = state.filtered[i];
                      return RoomCard(
                        room: room,
                        onEdit: isManager
                            ? () => ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Tính năng đang phát triển.')),
                                )
                            : null,
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
}
