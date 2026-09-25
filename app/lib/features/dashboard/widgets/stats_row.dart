import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/room.dart';

class DashboardStats {
  final int occupied;
  final int ready;
  final int needsCleaning;
  final int outOfService;
  final int overdue;
  final int totalInService;

  const DashboardStats({
    required this.occupied,
    required this.ready,
    required this.needsCleaning,
    required this.outOfService,
    required this.overdue,
    required this.totalInService,
  });

  factory DashboardStats.fromRooms(List<Room> rooms) {
    int occupied = 0, ready = 0, needsCleaning = 0, outOfService = 0, inService = 0;
    for (final r in rooms) {
      if (r.occupancy == OccupancyStatus.occupied) occupied++;
      if (r.isReady) ready++;
      if (r.cleaning == CleaningStatus.dirty) needsCleaning++;
      if (r.service == ServiceStatus.outOfService) outOfService++;
      if (r.service == ServiceStatus.inService) inService++;
    }
    return DashboardStats(
      occupied: occupied,
      ready: ready,
      needsCleaning: needsCleaning,
      outOfService: outOfService,
      overdue: 0,
      totalInService: inService,
    );
  }

  String get occupancyRate {
    if (totalInService == 0) return 'N/A';
    return '${(occupied / totalInService * 100).round()}%';
  }
}

class StatsRow extends StatelessWidget {
  final DashboardStats stats;

  const StatsRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            _StatCard(label: 'Đang ở', value: '${stats.occupied}', color: AppTheme.statusOccupied, icon: Icons.person),
            _StatCard(label: 'Sẵn sàng', value: '${stats.ready}', color: AppTheme.statusReady, icon: Icons.check_circle),
            _StatCard(label: 'Cần dọn', value: '${stats.needsCleaning}', color: AppTheme.statusDirty, icon: Icons.cleaning_services),
            _StatCard(label: 'Ngừng phục vụ', value: '${stats.outOfService}', color: AppTheme.statusOutOfService, icon: Icons.block),
            _StatCard(label: 'Quá hạn', value: '${stats.overdue}', color: Colors.deepOrange, icon: Icons.warning),
            _StatCard(label: 'Lấp đầy', value: stats.occupancyRate, color: AppTheme.primary, icon: Icons.hotel),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(right: 8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(value,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
            ],
          ),
        ),
      );
}
