with open('app/lib/features/dashboard/screens/dashboard_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

# Add import stays_provider
import_marker = "import '../../rooms/widgets/room_detail_panel.dart';"
if "stays_provider.dart" not in c:
    c = c.replace(import_marker, import_marker + "\nimport '../../stays/providers/stays_provider.dart';")

# Update reload
old_reload = '''  Future<void> _reload() async {
    await Future.wait([
      ref.read(roomsProvider.notifier).load(),
      ref.read(dashboardSummaryProvider.notifier).load(),
    ]);
  }'''

new_reload = '''  Future<void> _reload() async {
    await Future.wait([
      ref.read(roomsProvider.notifier).load(),
      ref.read(dashboardSummaryProvider.notifier).load(),
      ref.read(staysProvider.notifier).load(),
    ]);
  }'''
c = c.replace(old_reload, new_reload)

# In build: add stayMap
build_marker = '''    final overdue = summary.overdueRoomIds;
    final rooms = roomsState.sorted;'''

build_replacement = '''    final overdue = summary.overdueRoomIds;
    final rooms = roomsState.sorted;
    final stays = ref.watch(staysProvider).stays;
    final stayMap = {for (final s in stays) s.room.id: s};'''
c = c.replace(build_marker, build_replacement)

# Update RoomTile in Grid
old_tile = '''                    for (final r in entry.value)
                      RoomTile(
                        room: r,
                        overdue: overdue.contains(r.id),
                        onTap: () => showRoomDetailSheet(context, r.id),
                      ),'''

new_tile = '''                    for (final r in entry.value)
                      RoomTile(
                        room: r,
                        stay: stayMap[r.id],
                        overdue: overdue.contains(r.id),
                        onTap: () => showRoomDetailSheet(context, r.id),
                      ),'''
c = c.replace(old_tile, new_tile)

with open('app/lib/features/dashboard/screens/dashboard_screen.dart', 'w', encoding='utf-8', newline='') as f:
    f.write(c)

print('Updated dashboard_screen.dart successfully!')
