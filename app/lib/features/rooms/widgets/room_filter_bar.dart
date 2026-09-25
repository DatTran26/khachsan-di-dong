import 'package:flutter/material.dart';
import '../../../models/room.dart';
import '../providers/rooms_provider.dart';

class RoomFilterBar extends StatelessWidget {
  final RoomsFilter filter;
  final List<int> floors;
  final void Function(RoomsFilter) onChanged;

  const RoomFilterBar({
    super.key,
    required this.filter,
    required this.floors,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _FilterChipDropdown<int?>(
          label: 'Tầng',
          value: filter.floor,
          items: [
            const DropdownMenuItem(value: null, child: Text('Tất cả tầng')),
            ...floors.map((f) => DropdownMenuItem(value: f, child: Text('Tầng $f'))),
          ],
          onChanged: (v) => onChanged(filter.copyWith(floor: v)),
        ),
        _FilterChipDropdown<OccupancyStatus?>(
          label: 'Lưu trú',
          value: filter.occupancy,
          items: [
            const DropdownMenuItem(value: null, child: Text('Tất cả')),
            ...OccupancyStatus.values.map((s) =>
                DropdownMenuItem(value: s, child: Text(s.label))),
          ],
          onChanged: (v) => onChanged(filter.copyWith(occupancy: v)),
        ),
        _FilterChipDropdown<CleaningStatus?>(
          label: 'Vệ sinh',
          value: filter.cleaning,
          items: [
            const DropdownMenuItem(value: null, child: Text('Tất cả')),
            ...CleaningStatus.values.map((s) =>
                DropdownMenuItem(value: s, child: Text(s.label))),
          ],
          onChanged: (v) => onChanged(filter.copyWith(cleaning: v)),
        ),
        _FilterChipDropdown<ServiceStatus?>(
          label: 'Bảo trì',
          value: filter.service,
          items: [
            const DropdownMenuItem(value: null, child: Text('Tất cả')),
            ...ServiceStatus.values.map((s) =>
                DropdownMenuItem(value: s, child: Text(s.label))),
          ],
          onChanged: (v) => onChanged(filter.copyWith(service: v)),
        ),
      ],
    );
  }
}

class _FilterChipDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;

  const _FilterChipDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = value != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: isActive ? const Color(0xFF1565C0) : Colors.grey[400]!),
        borderRadius: BorderRadius.circular(20),
        color: isActive ? const Color(0xFF1565C0).withValues(alpha: 0.08) : Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isDense: true,
          hint: Text(label, style: const TextStyle(fontSize: 13)),
          items: items,
          onChanged: onChanged,
          style: TextStyle(
            fontSize: 13,
            color: isActive ? const Color(0xFF1565C0) : Colors.black87,
          ),
          icon: Icon(Icons.arrow_drop_down,
              size: 18, color: isActive ? const Color(0xFF1565C0) : Colors.grey),
        ),
      ),
    );
  }
}
