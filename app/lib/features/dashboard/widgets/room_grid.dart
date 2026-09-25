import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/room.dart';

class DashboardRoomGrid extends StatelessWidget {
  final List<Room> rooms;

  const DashboardRoomGrid({super.key, required this.rooms});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth > 1000
            ? 10
            : constraints.maxWidth > 700
                ? 7
                : constraints.maxWidth > 400
                    ? 5
                    : 3;

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            childAspectRatio: 0.9,
          ),
          itemCount: rooms.length,
          itemBuilder: (context, i) => _RoomTile(room: rooms[i]),
        );
      },
    );
  }
}

class _RoomTile extends StatelessWidget {
  final Room room;

  const _RoomTile({required this.room});

  Color _borderColor() {
    if (room.isReady) return AppTheme.statusReady;
    if (room.service == ServiceStatus.outOfService) return AppTheme.statusOutOfService;
    if (room.occupancy == OccupancyStatus.occupied) return AppTheme.statusOccupied;
    if (room.cleaning != CleaningStatus.clean) return AppTheme.statusDirty;
    return Colors.grey[300]!;
  }

  String _occupancyLabel() {
    if (room.occupancy == OccupancyStatus.occupied) return 'O';
    return 'T';
  }

  String _cleaningLabel() {
    switch (room.cleaning) {
      case CleaningStatus.clean:
        return 'S';
      case CleaningStatus.dirty:
        return 'D';
      case CleaningStatus.cleaning:
        return 'DD';
      case CleaningStatus.pendingInspection:
        return 'CX';
    }
  }

  String _serviceLabel() {
    return room.service == ServiceStatus.outOfService ? 'NP' : 'BT';
  }

  @override
  Widget build(BuildContext context) {
    final border = _borderColor();
    return Tooltip(
      message:
          'Phòng ${room.number}\n${room.occupancy.label} · ${room.cleaning.label} · ${room.service.label}',
      child: Container(
        decoration: BoxDecoration(
          color: border.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: border, width: room.isReady ? 2 : 1),
        ),
        padding: const EdgeInsets.all(4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(room.number,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                textAlign: TextAlign.center),
            const SizedBox(height: 2),
            Text('${_occupancyLabel()}/${_cleaningLabel()}',
                style: TextStyle(fontSize: 9, color: Colors.grey[700])),
            Text(_serviceLabel(),
                style: TextStyle(fontSize: 9, color: Colors.grey[700])),
            if (room.isReady)
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                decoration: BoxDecoration(
                  color: AppTheme.statusReady,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Text('SS',
                    style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}
