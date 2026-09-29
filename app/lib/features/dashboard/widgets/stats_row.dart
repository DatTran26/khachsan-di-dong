import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/dashboard_provider.dart';

class StatsRow extends StatelessWidget {
  final DashboardSummary summary;

  const StatsRow({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            _StatCard(label: 'Đang ở', value: '${summary.occupied}', color: AppTheme.statusOccupied, icon: Icons.person),
            _StatCard(label: 'Sẵn sàng', value: '${summary.ready}', color: AppTheme.statusReady, icon: Icons.check_circle),
            _StatCard(label: 'Cần dọn', value: '${summary.needsCleaning}', color: AppTheme.statusDirty, icon: Icons.cleaning_services),
            _StatCard(label: 'Ngừng phục vụ', value: '${summary.outOfService}', color: AppTheme.statusOutOfService, icon: Icons.block),
            _StatCard(label: 'Quá hạn', value: '${summary.overdueTotal}', color: Colors.deepOrange, icon: Icons.warning),
            _StatCard(label: 'Lấp đầy', value: summary.occupancyRateLabel, color: AppTheme.primary, icon: Icons.hotel),
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
