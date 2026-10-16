import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// Điểm vào. Bọc app bằng [ProviderScope] để Riverpod có gốc.
/// Không khởi tạo binding hay đọc token ở đây — [AuthNotifier] làm khi được tạo.
void main() {
  runApp(const ProviderScope(child: KhachSanApp()));
}

/// Widget gốc: theme sáng và [appRouterProvider]. Tắt banner debug.
class KhachSanApp extends ConsumerWidget {
  const KhachSanApp({super.key});

  /// Dựng [MaterialApp.router] từ [appRouterProvider].
  /// Instance router giữ nguyên khi auth đổi; redirect chạy nhờ notifier bên trong provider.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Khách Sạn Di Động',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
