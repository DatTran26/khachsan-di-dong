import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../rooms/providers/rooms_provider.dart';
import '../widgets/stats_row.dart';
import '../../../models/room.dart';

final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  final rooms = ref.watch(roomsProvider).rooms;
  return DashboardStats.fromRooms(rooms);
});

final dashboardRoomsProvider = Provider<List<Room>>((ref) {
  return ref.watch(roomsProvider).rooms;
});
