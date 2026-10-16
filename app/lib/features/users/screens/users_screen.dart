import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/user.dart';
import '../../../shared/utils/error_handler.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/ui.dart';
import '../../auth/providers/auth_provider.dart';
import '../../rooms/providers/rooms_provider.dart';
import '../providers/users_provider.dart';
import '../widgets/temp_password_dialog.dart';
import '../widgets/user_form_dialog.dart';

/// Tài khoản (auth-roles). Quản lý: mọi tài khoản. Lễ tân: tài khoản không phải quản lý.
class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  /// Tạo state lọc vai trò. Danh sách do [usersProvider] tự tải.
  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

/// Lọc theo vai trò và mở dialog tạo tài khoản. Bảng trên màn rộng, thẻ trên màn hẹp.
class _UsersScreenState extends ConsumerState<UsersScreen> {
  UserRole? _roleFilter;

  /// Sắp theo vai trò rồi tên. Nút tạo tắt khi mất mạng.
  /// Danh sách rỗng kèm lỗi thì [ErrorState].
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(usersProvider);
    final me = ref.watch(authProvider).user;
    final online = ref.watch(isOnlineProvider);
    final wide = Breakpoints.isWide(context);
    final pad = Breakpoints.hasSidebar(context) ? 32.0 : 16.0;

    final reload = ref.read(usersProvider.notifier).load;
    final gate = initialLoadGate(
      loading: state.isLoading,
      error: state.error,
      isEmpty: state.users.isEmpty,
      onRetry: reload,
      skeleton: const SkeletonList(),
    );
    if (gate != null) return gate;

    final users = state.users
        .where((u) => _roleFilter == null || u.role == _roleFilter)
        .toList()
      ..sort((a, b) {
        final r = a.role.index.compareTo(b.role.index);
        return r != 0 ? r : a.fullName.compareTo(b.fullName);
      });

    /// Số tài khoản của vai trò [r]. Null là mọi vai trò đang có trong state.
    int count(UserRole? r) => r == null
        ? state.users.length
        : state.users.where((u) => u.role == r).length;

    final rows = [
      for (final u in users)
        _UserRow(user: u, me: me, online: online, wide: wide),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(pad, wide ? 24 : 16, pad, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final r in <UserRole?>[null, ...UserRole.values])
                FilterPill(
                  label: '${r == null ? 'Tất cả' : r.shortLabel} · ${count(r)}',
                  selected: _roleFilter == r,
                  onTap: () => setState(() => _roleFilter = r),
                ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: online
                    ? () => showDialog(
                        context: context,
                        builder: (_) => const UserFormDialog())
                    : null,
                icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
                label: const Text('Tạo tài khoản'),
              ),
            ],
          ),
          if (!online) ...[
            const SizedBox(height: 12),
            const OfflineActionNote(),
          ],
          const SizedBox(height: 16),
          Expanded(
            child: users.isEmpty
                ? const EmptyState(
                    icon: Icons.manage_accounts_outlined,
                    title: 'Chưa có tài khoản nào ở nhóm này.',
                    message:
                        'Bấm "Tạo tài khoản" để thêm nhân viên và cấp mật khẩu tạm.',
                  )
                : wide
                    ? AppCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            const _HeaderRow(),
                            const Divider(height: 1, color: AppColors.border),
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: reload,
                                child: ListView.separated(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  itemCount: rows.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 1),
                                  itemBuilder: (_, i) => rows[i],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: reload,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: rows.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) => rows[i],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

const _flex = [22, 14, 12, 14, 10, 28];

/// Hàng tiêu đề bảng tài khoản trên màn rộng.
class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  /// Sáu cột khớp [_flex]. Không có dữ liệu.
  @override
  Widget build(BuildContext context) {
    const s = TextStyle(
        fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.muted);
    /// Ô tiêu đề cột [i]. [end] true thì căn phải.
    Widget c(int i, String t, {bool end = false}) => Expanded(
        flex: _flex[i],
        child: Align(
            alignment: end ? Alignment.centerRight : Alignment.centerLeft,
            child: Text(t, style: s)));
    return Container(
      color: const Color(0xFFFAF8F3),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        c(0, 'Họ tên'),
        c(1, 'Số điện thoại'),
        c(2, 'Vai trò'),
        c(3, 'Trạng thái'),
        c(4, 'Trực ca'),
        c(5, 'Thao tác', end: true),
      ]),
    );
  }
}

/// Màu chip trạng thái tài khoản. Hoạt động xanh, chờ kích hoạt vàng, khóa đỏ.
StatusTone _statusTone(AccountStatus s) => switch (s) {
      AccountStatus.active => StatusTone.ready,
      AccountStatus.pendingActivation => StatusTone.dirty,
      AccountStatus.locked => StatusTone.danger,
    };

/// Một tài khoản: tên, SĐT, vai trò, trạng thái, trực ca và nút sửa/khóa/đặt lại mật khẩu.
class _UserRow extends ConsumerWidget {
  final AppUser user;
  final AppUser? me;
  final bool online;
  final bool wide;

  const _UserRow(
      {required this.user,
      required this.me,
      required this.online,
      required this.wide});

  /// Đúng tài khoản đang đăng nhập. Ẩn khóa và đặt lại mật khẩu của chính mình.
  bool get _isSelf => user.id == me?.id;

  /// Lễ tân không thao tác trên tài khoản quản lý (BE chặn).
  bool get _canManage =>
      me?.role == UserRole.manager ||
      (me?.role == UserRole.receptionist && user.role != UserRole.manager);

  /// Mở [TempPasswordDialog] nếu [data] có `tempPassword`. Không có thì không hiện gì.
  /// [heading] là câu trước tên, do chỗ gọi chọn.
  Future<void> _showTemp(
      BuildContext context, Map<String, dynamic>? data, String heading) async {
    final pw = data?['tempPassword'] as String?;
    if (pw == null || !context.mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => TempPasswordDialog(
          tempPassword: pw, fullName: user.fullName, heading: heading),
    );
  }

  /// Hỏi rồi [UsersNotifier.lockUser]. Snack khi dialog thành công.
  /// Lỗi server hiện trong dialog, không nuốt ở đây.
  Future<void> _lock(BuildContext context, WidgetRef ref) => showConfirmDialog(
        context,
        title: 'Khóa tài khoản ${user.fullName}?',
        message:
            'Người này bị đăng xuất ngay trên mọi thiết bị và không đăng nhập được cho tới khi mở khóa.',
        confirmLabel: 'Khóa tài khoản',
        destructive: true,
        onConfirm: () async {
          await ref
              .read(usersProvider.notifier)
              .lockUser(user.id, user.version);
          if (context.mounted) {
            showAppSnack(context, 'Đã khóa tài khoản ${user.fullName}.');
          }
        },
      );

  /// Hỏi rồi [UsersNotifier.unlockUser]. Thành công thì hiện mật khẩu tạm mới.
  /// Hủy dialog thì không hiện mật khẩu dù request có thể đã chạy trong onConfirm.
  Future<void> _unlock(BuildContext context, WidgetRef ref) async {
    Map<String, dynamic>? data;
    final ok = await showConfirmDialog(
      context,
      title: 'Mở khóa tài khoản ${user.fullName}?',
      message:
          'Hệ thống cấp mật khẩu tạm mới. Nhân viên phải đặt mật khẩu mới ở lần đăng nhập đầu.',
      confirmLabel: 'Mở khóa',
      onConfirm: () async => data = await ref
          .read(usersProvider.notifier)
          .unlockUser(user.id, user.version),
    );
    if (ok && context.mounted) {
      await _showTemp(context, data, 'Đã mở khóa tài khoản');
    }
  }

  /// Hỏi rồi [UsersNotifier.resetPassword]. Thành công thì hiện mật khẩu tạm.
  /// Người bị đặt lại bị đăng xuất phía server.
  Future<void> _reset(BuildContext context, WidgetRef ref) async {
    Map<String, dynamic>? data;
    final ok = await showConfirmDialog(
      context,
      title: 'Đặt lại mật khẩu cho ${user.fullName}?',
      message:
          'Mật khẩu hiện tại hết hiệu lực và người này bị đăng xuất. Hệ thống cấp mật khẩu tạm mới.',
      confirmLabel: 'Đặt lại mật khẩu',
      onConfirm: () async => data = await ref
          .read(usersProvider.notifier)
          .resetPassword(user.id, user.version),
    );
    if (ok && context.mounted) {
      await _showTemp(context, data, 'Đã đặt lại mật khẩu cho');
    }
  }

  /// PATCH trực ca qua [UsersNotifier.updateUser]. [v] true là đang trực.
  /// [ApiException] (thường xung đột version) qua [handleApiError] và tải lại danh sách.
  Future<void> _toggleDuty(BuildContext context, WidgetRef ref, bool v) async {
    try {
      await ref
          .read(usersProvider.notifier)
          .updateUser(id: user.id, version: user.version, onDuty: v);
      if (context.mounted) {
        showAppSnack(
            context,
            v
                ? '${user.fullName} đang trực — sẽ được giao việc.'
                : '${user.fullName} đã hết ca.');
      }
    } on ApiException catch (e) {
      if (context.mounted) {
        handleApiError(context, e,
            onReload: () => ref.read(usersProvider.notifier).load());
      }
    }
  }

  /// Nút Sửa / Đặt lại / Khóa / Mở khóa. Rỗng nếu [_canManage] false.
  /// Mọi nút tắt khi [online] false. Không khóa chính mình.
  List<Widget> _actions(BuildContext context, WidgetRef ref) {
    if (!_canManage) return const [];
    final small = OutlinedButton.styleFrom(
        minimumSize: const Size(0, 34),
        padding: const EdgeInsets.symmetric(horizontal: 12));
    final ghost = TextButton.styleFrom(
        minimumSize: const Size(0, 34),
        padding: const EdgeInsets.symmetric(horizontal: 10));
    return [
      TextButton(
        style: ghost,
        onPressed: online
            ? () => showDialog(
                context: context, builder: (_) => UserFormDialog(user: user))
            : null,
        child: const Text('Sửa'),
      ),
      if (!_isSelf && user.status != AccountStatus.locked)
        TextButton(
            style: ghost,
            onPressed: online ? () => _reset(context, ref) : null,
            child: const Text('Đặt lại mật khẩu')),
      if (!_isSelf && user.status != AccountStatus.locked)
        OutlinedButton(
          style: small.copyWith(
            foregroundColor: const WidgetStatePropertyAll(AppColors.danger),
            side: const WidgetStatePropertyAll(
                BorderSide(color: Color(0xFFF2C4C6))),
          ),
          onPressed: online ? () => _lock(context, ref) : null,
          child: const Text('Khóa'),
        ),
      if (user.status == AccountStatus.locked)
        OutlinedButton(
            style: small,
            onPressed: online ? () => _unlock(context, ref) : null,
            child: const Text('Mở khóa')),
    ];
  }

  /// Hàng bảng hoặc thẻ. Switch trực ca chỉ với nhân viên và chỉ khi được quản lý.
  /// Không gọi API trong build.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duty = user.role == UserRole.staff
        ? Switch(
            value: user.onDuty,
            activeThumbColor: AppColors.gold,
            onChanged: online && _canManage
                ? (v) => _toggleDuty(context, ref, v)
                : null,
          )
        : const MetaText('—');

    final name = Row(
      children: [
        InitialAvatar(user.fullName, size: 32),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.fullName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              if (_isSelf)
                const Text('Bạn',
                    style: TextStyle(fontSize: 12, color: AppColors.goldText)),
            ],
          ),
        ),
      ],
    );

    if (wide) {
      /// Ô một cột bảng theo [_flex].
      Widget c(int i, Widget w, {bool end = false}) => Expanded(
          flex: _flex[i],
          child: Align(
              alignment: end ? Alignment.centerRight : Alignment.centerLeft,
              child: w));
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(children: [
          c(0, name),
          c(1, Text(user.phone)),
          c(2, Text(user.role.shortLabel)),
          c(3, StatusChip(user.status.label, tone: _statusTone(user.status))),
          c(4, duty),
          c(
              5,
              Wrap(
                  spacing: 4,
                  alignment: WrapAlignment.end,
                  children: _actions(context, ref)),
              end: true),
        ]),
      );
    }

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Expanded(child: name),
            StatusChip(user.status.label, tone: _statusTone(user.status))
          ]),
          const SizedBox(height: 6),
          MetaText('${user.role.shortLabel} · ${user.phone}'),
          if (user.role == UserRole.staff)
            Row(children: [const MetaText('Đang trực'), const Spacer(), duty]),
          if (_canManage) Wrap(spacing: 4, children: _actions(context, ref)),
        ],
      ),
    );
  }
}
