import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/offline_banner.dart';
import '../widgets/stats_row.dart';
import '../widgets/room_grid.dart';
import '../../rooms/providers/rooms_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsState = ref.watch(roomsProvider);
    final summaryState = ref.watch(dashboardSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Tải lại',
            onPressed: () {
              ref.read(roomsProvider.notifier).load();
              ref.read(dashboardSummaryProvider.notifier).load();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (!roomsState.isConnected) const OfflineBanner(),
          StatsRow(summary: summaryState.summary),
          const Divider(height: 1),
          if (roomsState.isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (roomsState.error != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[400], size: 40),
                    const SizedBox(height: 8),
                    Text(roomsState.error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ref.read(roomsProvider.notifier).load(),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            )
          else if (roomsState.rooms.isEmpty)
            const Expanded(
              child: Center(child: Text('Chưa có phòng nào.')),
            )
          else
            Expanded(child: DashboardRoomGrid(rooms: roomsState.rooms)),
        ],
      ),
    );
  }
}
