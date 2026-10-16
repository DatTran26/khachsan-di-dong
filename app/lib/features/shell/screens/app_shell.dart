import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/realtime/socket_service.dart';
import '../../../core/router/nav.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/housekeeping_task.dart';
import '../../../models/maintenance_task.dart';
import '../../../models/user.dart';
import '../../../shared/utils/error_handler.dart';
import '../../../shared/widgets/ui.dart';
import '../../auth/providers/auth_provider.dart';
import '../../dashboard/widgets/offline_banner.dart';
import '../../housekeeping/providers/housekeeping_provider.dart';
import '../../maintenance/providers/maintenance_provider.dart';
import '../../rooms/providers/rooms_provider.dart';

/// Khung chung sau đăng nhập.
/// - Màn rộng (≥900px, web tại quầy): thanh bên espresso + thanh đầu trang trắng.
/// - Tablet (600–899px): thanh đầu trang espresso + thanh điều hướng dọc bên trái.
/// - Màn hẹp (Android): thanh đầu trang espresso viền vàng + thanh điều hướng dưới (≤5 mục) hoặc ngăn kéo.
class AppShell extends ConsumerStatefulWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  /// Tạo state khung. [child] là màn con của router.
  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

/// Thanh bên hoặc thanh dưới theo bề ngang, snack thông báo realtime, badge quá hạn.
class _AppShellState extends ConsumerState<AppShell> {
  /// Gắn [socketService.onNotification]. Ghi đè callback thông báo toàn cục.
  @override
  void initState() {
    super.initState();
    socketService.onNotification = _handleNotification;
  }

  /// Hiện snack. Quá hạn hoặc việc dọn bị trả thì cảnh báo, còn lại thông tin.
  /// Có đích thì thêm nút Xem gọi [GoRouter.go]. Bỏ qua nếu widget đã dispose.
  void _handleNotification(
      String kind, String message, String? taskId, String? roomId) {
    if (!mounted) return;
    final tone = kind.endsWith('OVERDUE') || kind == 'HOUSEKEEPING_RETURNED'
        ? SnackTone.warn
        : SnackTone.info;
    final target = _notificationTarget(kind, taskId, roomId);
    showAppSnack(
      context,
      message,
      tone: tone,
      action: target == null
          ? null
          : SnackBarAction(
              label: 'Xem',
              textColor: AppColors.goldLight,
              onPressed: () => context.go(target)),
    );
  }

  /// Nơi mở khi bấm "Xem" trên thông báo: quản lý/lễ tân → ô phòng trên dashboard;
  /// nhân viên (không có dashboard) → mở thẳng việc đó trong danh sách việc của mình.
  String? _notificationTarget(String kind, String? taskId, String? roomId) {
    final role = ref.read(authProvider).user?.role;
    if (role == UserRole.staff) {
      final query = taskId == null ? '' : '?viec=$taskId';
      if (kind.startsWith('HOUSEKEEPING')) return '/don-phong$query';
      if (kind.startsWith('MAINTENANCE')) return '/bao-tri$query';
      return null;
    }
    return roomId == null ? null : '/dashboard?phong=$roomId';
  }

  /// Khung rộng: sidebar + top bar. Khung hẹp: app bar, drawer nếu hơn 5 mục, không thì bottom nav.
  /// Mất mạng thì chèn [OfflineBanner]. Không tự đăng xuất.
  @override
  Widget build(BuildContext context) {
    ref.listen(isOnlineProvider, (prev, next) {
      if (prev == false && next) {
        showAppSnack(context, 'Đã kết nối lại.', tone: SnackTone.info);
      }
    });
    final user = ref.watch(authProvider).user;
    final role = user?.role;
    final isOnline = ref.watch(isOnlineProvider);
    final lastUpdated = ref.watch(roomsProvider.select((s) => s.lastUpdated));
    final location = GoRouterState.of(context).uri.path;
    final items = navItemsFor(role);
    final badges = _badges(role);

    final size = Breakpoints.of(context);
    final title = titleFor(role, location);

    if (size == WindowSize.expanded) {
      return Scaffold(
        body: Row(
          children: [
            _Sidebar(
                items: items, location: location, role: role, badges: badges),
            Expanded(
              child: Column(
                children: [
                  _TopBar(
                      title: title,
                      user: user,
                      isOnline: isOnline,
                      lastUpdated: lastUpdated),
                  if (!isOnline) const OfflineBanner(),
                  Expanded(child: widget.child),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final rail = size == WindowSize.medium && items.isNotEmpty;
    final useBottomNav = !rail && items.length <= 5;
    final currentIndex = items.indexWhere((d) => location.startsWith(d.path));
    final content = Column(
      children: [
        if (!isOnline) const OfflineBanner(),
        Expanded(child: widget.child),
      ],
    );
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        shape:
            const Border(bottom: BorderSide(color: AppColors.gold, width: 3)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isOnline && lastUpdated != null
                  ? 'Cập nhật lúc ${DateFormat('HH:mm').format(lastUpdated)}'
                  : (user?.fullName ?? ''),
              style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.onDarkMuted,
                  fontWeight: FontWeight.w400),
            ),
            Text(title),
          ],
        ),
        actions: [
          _UserMenu(user: user, dark: true),
          const SizedBox(width: 8),
        ],
      ),
      drawer: useBottomNav || rail
          ? null
          : _MobileDrawer(
              items: items, location: location, user: user, badges: badges),
      body: rail
          ? Row(
              children: [
                _Rail(
                    items: items,
                    selectedIndex: currentIndex < 0 ? 0 : currentIndex,
                    badges: badges),
                const VerticalDivider(width: 1),
                Expanded(child: content),
              ],
            )
          : content,
      bottomNavigationBar: useBottomNav && items.isNotEmpty
          ? NavigationBar(
              selectedIndex: currentIndex < 0 ? 0 : currentIndex,
              onDestinationSelected: (i) => context.go(items[i].path),
              destinations: [
                for (final d in items)
                  NavigationDestination(
                    icon: _BadgeIcon(icon: d.icon, count: badges[d.path] ?? 0),
                    selectedIcon: _BadgeIcon(
                        icon: d.selectedIcon, count: badges[d.path] ?? 0),
                    label: d.label,
                  ),
              ],
            )
          : null,
    );
  }

  /// Số việc quá hạn hiện cạnh mục điều hướng — chỉ đọc provider mà vai trò có quyền gọi API.
  Map<String, int> _badges(UserRole? role) {
    final result = <String, int>{};
    if (role == UserRole.manager || role == UserRole.staff) {
      result['/don-phong'] = ref
          .watch(housekeepingProvider)
          .tasks
          .where((t) => t.isOverdue && t.status != HousekeepingStatus.done)
          .length;
    }
    if (role != null) {
      result['/bao-tri'] = ref
          .watch(maintenanceProvider)
          .tasks
          .where((t) =>
              t.isOverdue &&
              (t.status == MaintenanceStatus.open ||
                  t.status == MaintenanceStatus.inProgress))
          .length;
    }
    return result;
  }
}

/// Thanh điều hướng dọc cho tablet — cuộn được khi màn ngang thấp (quản lý có 7 mục).
class _Rail extends StatelessWidget {
  final List<NavItem> items;
  final int selectedIndex;
  final Map<String, int> badges;

  const _Rail(
      {required this.items, required this.selectedIndex, required this.badges});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: (i) => context.go(items[i].path),
              destinations: [
                for (final d in items)
                  NavigationRailDestination(
                    icon: _BadgeIcon(icon: d.icon, count: badges[d.path] ?? 0),
                    selectedIcon: _BadgeIcon(
                        icon: d.selectedIcon, count: badges[d.path] ?? 0),
                    label: Text(d.label),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Thanh bên espresso. [badges] là số việc quá hạn theo path menu.
class _Sidebar extends StatelessWidget {
  final List<NavItem> items;
  final String location;
  final UserRole? role;
  final Map<String, int> badges;

  const _Sidebar(
      {required this.items,
      required this.location,
      required this.role,
      required this.badges});

  /// Logo, vai trò và các [_SideNavTile]. Không gọi API.
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 248,
      color: AppColors.espresso,
      padding: const EdgeInsets.fromLTRB(14, 20, 14, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 20),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0x40C9A24D)))),
            child: Row(
              children: [
                const BrandMark(),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Khách Sạn Di Động',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15)),
                      Text(role?.shortLabel ?? '',
                          style: const TextStyle(
                              color: AppColors.goldLight,
                              fontSize: 12,
                              letterSpacing: .3)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          for (final item in items)
            _SideNavTile(
              item: item,
              active: location.startsWith(item.path),
              count: badges[item.path] ?? 0,
            ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0x40C9A24D)))),
            child: const Text('Khách sạn giả định · dữ liệu giả lập',
                style: TextStyle(color: Color(0xFFA89C87), fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

/// Một mục menu. [onTap] null thì [GoRouter.go] tới [NavItem.path]. [count] > 0 hiện badge.
class _SideNavTile extends StatelessWidget {
  final NavItem item;
  final bool active;
  final int count;

  final VoidCallback? onTap;

  const _SideNavTile(
      {required this.item,
      required this.active,
      required this.count,
      this.onTap});

  /// Hàng cao 44. Mục đang chọn có nền và viền vàng trái.
  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.goldLight : AppColors.onDark;
    return Semantics(
      selected: active,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Material(
          color: active ? AppColors.goldSelected : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap ?? () => context.go(item.path),
            child: Container(
              height: AppTheme.minTouch,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: active
                  ? const BoxDecoration(
                      border: Border(
                          left: BorderSide(color: AppColors.gold, width: 3)))
                  : null,
              child: Row(
                children: [
                  Icon(active ? item.selectedIcon : item.icon,
                      color: color, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(item.label,
                        style: AppText.body.copyWith(
                            color: color,
                            fontWeight:
                                active ? FontWeight.w600 : FontWeight.w500)),
                  ),
                  if (count > 0) _CountBadge(count),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Chip số việc quá hạn trên menu rộng. Nhãn semantics cho trình đọc màn hình.
class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge(this.count);

  /// Số [count] trên nền đỏ. Không ẩn khi count = 0 — cha chỉ dựng khi count > 0.
  @override
  Widget build(BuildContext context) => Semantics(
        label: '$count việc quá hạn',
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
          decoration: BoxDecoration(
              color: AppColors.danger, borderRadius: BorderRadius.circular(10)),
          child: Text('$count',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
        ),
      );
}

/// Icon bottom nav. [count] > 0 thì bọc [Badge], không thì icon trần.
class _BadgeIcon extends StatelessWidget {
  final IconData icon;
  final int count;
  const _BadgeIcon({required this.icon, required this.count});

  /// Badge Material mặc định. Không tự điều hướng.
  @override
  Widget build(BuildContext context) => count > 0
      ? Semantics(
          label: '$count việc quá hạn',
          child: Badge(
            label: ExcludeSemantics(child: Text('$count')),
            backgroundColor: AppColors.danger,
            child: Icon(icon),
          ),
        )
      : Icon(icon);
}

/// Thanh tiêu đề màn rộng: tên màn, chấm đồng bộ hoặc "Mất kết nối", menu user.
class _TopBar extends StatelessWidget {
  final String title;
  final AppUser? user;
  final bool isOnline;
  final DateTime? lastUpdated;

  const _TopBar(
      {required this.title,
      required this.user,
      required this.isOnline,
      required this.lastUpdated});

  /// Giờ cập nhật lấy [lastUpdated] local. [isOnline] false thì không hiện chấm xanh.
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(width: 16),
          if (isOnline) ...[
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.ready,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: AppColors.readyBg, spreadRadius: 3)
                ],
              ),
            ),
            const SizedBox(width: 8),
            MetaText(lastUpdated != null
                ? 'Đang đồng bộ · Cập nhật lúc ${DateFormat('HH:mm').format(lastUpdated!)}'
                : 'Đang đồng bộ'),
          ] else
            const MetaText('Mất kết nối',
                color: AppColors.dirty, weight: FontWeight.w600),
          const Spacer(),
          _UserMenu(user: user, dark: false),
        ],
      ),
    );
  }
}

/// Menu tài khoản: đổi mật khẩu và đăng xuất. [dark] true dùng avatar đơn trên app bar hẹp.
class _UserMenu extends ConsumerWidget {
  final AppUser? user;
  final bool dark;
  const _UserMenu({required this.user, required this.dark});

  /// `logout` gọi [AuthNotifier.logout] (xóa token, ngắt socket).
  /// `change-password` chuyển `/doi-mat-khau`. Không gọi API ở đây.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      tooltip: 'Tài khoản của bạn',
      offset: const Offset(0, 48),
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
              Text(user?.fullName ?? '',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, color: AppColors.text)),
              Text(user?.role.label ?? '',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'change-password',
          child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.lock_outline),
              title: Text('Đổi mật khẩu')),
        ),
        const PopupMenuItem(
          value: 'logout',
          child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.logout),
              title: Text('Đăng xuất')),
        ),
      ],
      child: dark
          ? Padding(
              padding: const EdgeInsets.all(8),
              child: InitialAvatar(user?.fullName ?? '?', size: 34))
          : Row(
              children: [
                InitialAvatar(user?.fullName ?? '?'),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.fullName ?? '',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    Text(user?.role.shortLabel ?? '',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.muted)),
                  ],
                ),
                const Icon(Icons.expand_more, color: AppColors.muted),
              ],
            ),
    );
  }
}

/// Ngăn kéo khi menu hẹp có hơn 5 mục. Cùng [_SideNavTile], đóng drawer trước khi chuyển trang.
class _MobileDrawer extends ConsumerWidget {
  final List<NavItem> items;
  final String location;
  final AppUser? user;
  final Map<String, int> badges;

  const _MobileDrawer(
      {required this.items,
      required this.location,
      required this.user,
      required this.badges});

  /// Tên user và danh sách mục. [ref] không dùng để gọi API.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: AppColors.espresso,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                child: Row(
                  children: [
                    const BrandMark(),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user?.fullName ?? '',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                          Text(user?.role.shortLabel ?? '',
                              style: const TextStyle(
                                  color: AppColors.goldLight, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              for (final item in items)
                _SideNavTile(
                  item: item,
                  active: location.startsWith(item.path),
                  count: badges[item.path] ?? 0,
                  onTap: () {
                    Navigator.pop(context);
                    context.go(item.path);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
