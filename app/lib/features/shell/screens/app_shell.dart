import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../rooms/providers/rooms_provider.dart';
import '../../../models/user.dart';

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final isConnected = ref.watch(roomsProvider).isConnected;
    final location = GoRouterState.of(context).uri.path;

    final isManager = user?.role == UserRole.manager;
    final isReceptionist = user?.role == UserRole.receptionist;

    final destinations = <(String, NavigationDestination)>[
      ('/dashboard', const NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard')),
      ('/phong', const NavigationDestination(icon: Icon(Icons.hotel_outlined), selectedIcon: Icon(Icons.hotel), label: 'Danh mục phòng')),
      if (isManager || isReceptionist)
        ('/tai-khoan', const NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Tài khoản')),
    ];

    final currentIndex = destinations.indexWhere((d) => location.startsWith(d.$1));
    final selectedIndex = currentIndex < 0 ? 0 : currentIndex;

    return Scaffold(
      appBar: _buildAppBar(context, ref, user, isConnected, location),
      body: child,
      bottomNavigationBar: MediaQuery.of(context).size.width < 600
          ? NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: (i) => context.go(destinations[i].$1),
              destinations: destinations.map((d) => d.$2).toList(),
            )
          : null,
      drawer: MediaQuery.of(context).size.width >= 600
          ? null
          : _buildDrawer(context, ref, user, destinations, location),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    AppUser? user,
    bool isConnected,
    String location,
  ) {
    final title = _titleFor(location);
    return AppBar(
      title: Text(title),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      actions: [
        if (!isConnected)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.wifi_off, color: Colors.orange),
          ),
        PopupMenuButton<String>(
          icon: CircleAvatar(
            backgroundColor: Colors.white24,
            radius: 14,
            child: Text(
              user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          onSelected: (action) {
            if (action == 'logout') {
              ref.read(authProvider.notifier).logout();
            } else if (action == 'change-password') {
              context.go('/doi-mat-khau');
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              enabled: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(user?.fullName ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                  Text(user?.role.label ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(value: 'change-password', child: Text('Đổi mật khẩu')),
            const PopupMenuItem(value: 'logout', child: Text('Đăng xuất')),
          ],
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildDrawer(
    BuildContext context,
    WidgetRef ref,
    AppUser? user,
    List<(String, NavigationDestination)> destinations,
    String location,
  ) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF1565C0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('KhachSanDiDong',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(user?.fullName ?? '', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                Text(user?.role.label ?? '', style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          ...destinations.map((d) => ListTile(
                leading: d.$2.icon,
                title: Text(d.$2.label),
                selected: location.startsWith(d.$1),
                onTap: () {
                  Navigator.pop(context);
                  context.go(d.$1);
                },
              )),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Đổi mật khẩu'),
            onTap: () {
              Navigator.pop(context);
              context.go('/doi-mat-khau');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Đăng xuất'),
            onTap: () => ref.read(authProvider.notifier).logout(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _titleFor(String location) {
    if (location.startsWith('/phong')) return 'Danh mục phòng';
    if (location.startsWith('/tai-khoan')) return 'Quản lý tài khoản';
    if (location.startsWith('/doi-mat-khau')) return 'Đổi mật khẩu';
    return 'Dashboard';
  }
}
