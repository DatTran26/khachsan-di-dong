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
import '../../features/audit/screens/audit_screen.dart';
import '../../features/ai_summary/screens/ai_summary_screen.dart';
import '../../features/shell/screens/app_shell.dart';
import 'nav.dart';

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

      final role = auth.user?.role;
      if (path == '/dang-nhap' || path == '/') return homeFor(role);
      if (path == '/doi-mat-khau') return null;

      // Chặn mở màn ngoài quyền (BE vẫn kiểm quyền — đây chỉ để không hiện màn lỗi 403).
      if (!canOpen(role, path)) return homeFor(role);

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
            // `?phong=<id>`: mở sẵn chi tiết phòng (đi từ việc cần chú ý / cảnh báo quá hạn).
            builder: (_, state) => DashboardScreen(
                openRoomId: state.uri.queryParameters['phong']),
          ),
          GoRoute(
            path: '/tom-tat',
            builder: (_, __) => const AiSummaryScreen(),
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
          GoRoute(
            path: '/nhat-ky',
            builder: (_, __) => const AuditScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/',
        redirect: (_, __) => '/dashboard',
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Không tìm thấy trang này.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Về trang chính')),
          ],
        ),
      ),
    ),
  );
});
