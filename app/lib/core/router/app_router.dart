import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/change_password_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/rooms/screens/rooms_screen.dart';
import '../../features/users/screens/users_screen.dart';
import '../../features/stays/screens/stays_screen.dart';
import '../../features/housekeeping/screens/housekeeping_screen.dart';
import '../../features/maintenance/screens/maintenance_screen.dart';
import '../../features/shell/screens/app_shell.dart';
import '../../models/user.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ValueNotifier<AuthState>(ref.read(authProvider));
  ref.listen(authProvider, (_, next) => notifier.value = next);

  return GoRouter(
    refreshListenable: notifier,
    redirect: (context, state) {
      final auth = notifier.value;
      final path = state.uri.path;

      if (!auth.initialized) return null;

      if (!auth.isAuthenticated) {
        if (path != '/dang-nhap') return '/dang-nhap';
        return null;
      }

      if (auth.user?.mustChangePassword == true && path != '/doi-mat-khau') {
        return '/doi-mat-khau';
      }

      if (path == '/dang-nhap') return '/dashboard';

      final role = auth.user?.role;
      final isManagerOrReceptionist =
          role == UserRole.manager || role == UserRole.receptionist;

      if (path.startsWith('/tai-khoan') && !isManagerOrReceptionist) {
        return '/dashboard';
      }
      if (path.startsWith('/luot-o') && !isManagerOrReceptionist) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/dang-nhap',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/doi-mat-khau',
        builder: (context, state) {
          final ref = ProviderScope.containerOf(context);
          final user = ref.read(authProvider).user;
          final forced = user?.mustChangePassword ?? false;
          return ChangePasswordScreen(forced: forced);
        },
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (_, __) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/phong',
            builder: (_, __) => const RoomsScreen(),
          ),
          GoRoute(
            path: '/luot-o',
            builder: (_, __) => const StaysScreen(),
          ),
          GoRoute(
            path: '/don-phong',
            builder: (_, __) => const HousekeepingScreen(),
          ),
          GoRoute(
            path: '/bao-tri',
            builder: (_, __) => const MaintenanceScreen(),
          ),
          GoRoute(
            path: '/tai-khoan',
            builder: (_, __) => const UsersScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/',
        redirect: (_, __) => '/dashboard',
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Trang không tồn tại: ${state.error}')),
    ),
  );
});
