import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/realtime/socket_service.dart';
import '../../../models/room.dart';

class RoomsFilter {
  final int? floor;
  final OccupancyStatus? occupancy;
  final CleaningStatus? cleaning;
  final ServiceStatus? service;

  const RoomsFilter({this.floor, this.occupancy, this.cleaning, this.service});

  RoomsFilter copyWith({
    Object? floor = _sentinel,
    Object? occupancy = _sentinel,
    Object? cleaning = _sentinel,
    Object? service = _sentinel,
  }) =>
      RoomsFilter(
        floor: floor == _sentinel ? this.floor : floor as int?,
        occupancy: occupancy == _sentinel ? this.occupancy : occupancy as OccupancyStatus?,
        cleaning: cleaning == _sentinel ? this.cleaning : cleaning as CleaningStatus?,
        service: service == _sentinel ? this.service : service as ServiceStatus?,
      );

  static const _sentinel = Object();
}

class RoomsState {
  final List<Room> rooms;
  final bool isLoading;
  final String? error;
  final RoomsFilter filter;
  final bool isConnected;
  final DateTime? lastUpdated;

  const RoomsState({
    this.rooms = const [],
    this.isLoading = false,
    this.error,
    this.filter = const RoomsFilter(),
    this.isConnected = true,
    this.lastUpdated,
  });

  List<Room> get filtered {
    return rooms.where((r) {
      if (filter.floor != null && r.floor != filter.floor) return false;
      if (filter.occupancy != null && r.occupancy != filter.occupancy) return false;
      if (filter.cleaning != null && r.cleaning != filter.cleaning) return false;
      if (filter.service != null && r.service != filter.service) return false;
      return true;
    }).toList();
  }

  List<int> get availableFloors {
    final floors = rooms.map((r) => r.floor).toSet().toList()..sort();
    return floors;
  }

  RoomsState copyWith({
    List<Room>? rooms,
    bool? isLoading,
    String? error,
    RoomsFilter? filter,
    bool? isConnected,
    DateTime? lastUpdated,
    bool clearError = false,
  }) =>
      RoomsState(
        rooms: rooms ?? this.rooms,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        filter: filter ?? this.filter,
        isConnected: isConnected ?? this.isConnected,
        lastUpdated: lastUpdated ?? this.lastUpdated,
      );
}

class RoomsNotifier extends StateNotifier<RoomsState> {
  RoomsNotifier() : super(const RoomsState()) {
    _setupSocket();
    load();
  }

  void _setupSocket() {
    socketService.onRoomUpdated = _handleRoomUpdated;
    socketService.onConnectionChanged = _handleConnectionChanged;
  }

  void _handleRoomUpdated(Map<String, dynamic> roomJson) {
    final updated = Room.fromJson(roomJson);
    final idx = state.rooms.indexWhere((r) => r.id == updated.id);
    if (idx == -1) return;
    final current = state.rooms[idx];
    if (updated.version <= current.version) return;
    final newRooms = [...state.rooms];
    newRooms[idx] = updated;
    state = state.copyWith(rooms: newRooms, lastUpdated: DateTime.now());
  }

  void _handleConnectionChanged(bool connected) {
    state = state.copyWith(isConnected: connected);
    if (connected) load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await apiClient.get('/rooms');
      final list = (res['data'] as List)
          .cast<Map<String, dynamic>>()
          .map(Room.fromJson)
          .toList();
      state = state.copyWith(
        rooms: list,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  void setFilter(RoomsFilter filter) {
    state = state.copyWith(filter: filter);
  }

  void clearFilter() {
    state = state.copyWith(filter: const RoomsFilter());
  }
}

final roomsProvider = StateNotifierProvider<RoomsNotifier, RoomsState>((ref) {
  return RoomsNotifier();
});
