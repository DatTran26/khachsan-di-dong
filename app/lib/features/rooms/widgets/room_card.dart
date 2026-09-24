import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/room.dart';

class RoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback? onEdit;

  const RoomCard({super.key, required this.room, this.onEdit});

  Color _occupancyColor() {
    if (room.isReady) return AppTheme.statusReady;
    if (room.occupancy == OccupancyStatus.occupied) return AppTheme.statusOccupied;
    return Colors.grey[600]!;
  }

  Color _cleaningColor() {
    switch (room.cleaning) {
      case CleaningStatus.clean:
        return AppTheme.statusReady;
      case CleaningStatus.dirty:
      case CleaningStatus.cleaning:
      case CleaningStatus.pendingInspection:
        return AppTheme.statusDirty;
    }
  }

  Color _serviceColor() {
    return room.service == ServiceStatus.outOfService
        ? AppTheme.statusOutOfService
        : AppTheme.statusReady;
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = room.isReady
        ? AppTheme.statusReady
        : room.service == ServiceStatus.outOfService
            ? AppTheme.statusOutOfService
            : room.occupancy == OccupancyStatus.occupied
                ? AppTheme.statusOccupied
                : Colors.grey[300]!;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: borderColor, width: room.isReady ? 2 : 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Phòng ${room.number}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const Spacer(),
                if (room.isReady)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.statusReady,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('Sẵn sàng',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                  ),
                if (onEdit != null) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 16),
                    onPressed: onEdit,
                    tooltip: 'Sửa',
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text('Tầng ${room.floor} · ${room.roomType.name}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const Divider(height: 12),
            _StatusRow(label: 'Lưu trú', value: room.occupancy.label, color: _occupancyColor()),
            const SizedBox(height: 4),
            _StatusRow(label: 'Vệ sinh', value: room.cleaning.label, color: _cleaningColor()),
            const SizedBox(height: 4),
            _StatusRow(label: 'Bảo trì', value: room.service.label, color: _serviceColor()),
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatusRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          SizedBox(
            width: 52,
            child: Text(label,
                style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Text(value,
                style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
          ),
        ],
      );
}
