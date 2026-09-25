import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/user.dart';
import '../providers/users_provider.dart';
import '../widgets/user_form_dialog.dart';
import '../widgets/temp_password_dialog.dart';
import '../../auth/providers/auth_provider.dart';

class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(usersProvider);
    final currentUser = ref.watch(authProvider).user;
    final isManager = currentUser?.role == UserRole.manager;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý tài khoản'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Tải lại',
            onPressed: () => ref.read(usersProvider.notifier).load(),
          ),
          if (isManager)
            IconButton(
              icon: const Icon(Icons.person_add),
              tooltip: 'Tạo tài khoản',
              onPressed: () => showDialog(
                context: context,
                builder: (_) => const UserFormDialog(),
              ),
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[400], size: 40),
                      const SizedBox(height: 8),
                      Text(state.error!),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => ref.read(usersProvider.notifier).load(),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : state.users.isEmpty
                  ? const Center(child: Text('Chưa có tài khoản nào.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: state.users.length,
                      itemBuilder: (context, i) => _UserTile(
                        user: state.users[i],
                        currentUser: currentUser,
                        isManager: isManager,
                      ),
                    ),
    );
  }
}

class _UserTile extends ConsumerWidget {
  final AppUser user;
  final AppUser? currentUser;
  final bool isManager;

  const _UserTile({
    required this.user,
    required this.currentUser,
    required this.isManager,
  });

  Color _statusColor() {
    switch (user.status) {
      case AccountStatus.active:
        return Colors.green;
      case AccountStatus.locked:
        return Colors.red;
      case AccountStatus.pendingActivation:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelf = user.id == currentUser?.id;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1565C0).withValues(alpha: 0.1),
          child: Text(
            user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
            style: const TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.bold),
          ),
        ),
        title: Row(
          children: [
            Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
            if (isSelf) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('Bạn', style: TextStyle(fontSize: 11, color: Color(0xFF1565C0))),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.phone),
            Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 2, right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(user.role.label, style: const TextStyle(fontSize: 11)),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _statusColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    user.status.label,
                    style: TextStyle(fontSize: 11, color: _statusColor()),
                  ),
                ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        trailing: isManager && !isSelf
            ? PopupMenuButton<String>(
                onSelected: (action) => _handleAction(context, ref, action),
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
                  if (user.status == AccountStatus.active)
                    const PopupMenuItem(value: 'lock', child: Text('Khoá')),
                  if (user.status == AccountStatus.locked)
                    const PopupMenuItem(value: 'unlock', child: Text('Mở khoá')),
                  const PopupMenuItem(value: 'reset', child: Text('Đặt lại mật khẩu')),
                ],
              )
            : null,
      ),
    );
  }

  Future<void> _handleAction(BuildContext context, WidgetRef ref, String action) async {
    switch (action) {
      case 'edit':
        await showDialog(
          context: context,
          builder: (_) => UserFormDialog(user: user),
        );
      case 'lock':
        await _confirmAndDo(
          context,
          ref,
          title: 'Khoá tài khoản',
          message: 'Khoá tài khoản của ${user.fullName}?',
          action: () => ref.read(usersProvider.notifier).lockUser(user.id, user.version),
        );
      case 'unlock':
        await _confirmAndDo(
          context,
          ref,
          title: 'Mở khoá',
          message: 'Mở khoá tài khoản của ${user.fullName}?',
          action: () => ref.read(usersProvider.notifier).unlockUser(user.id, user.version),
        );
      case 'reset':
        await _confirmAndDo(
          context,
          ref,
          title: 'Đặt lại mật khẩu',
          message: 'Đặt lại mật khẩu cho ${user.fullName}? Một mật khẩu tạm thời sẽ được tạo.',
          action: () async {
            final data = await ref.read(usersProvider.notifier).resetPassword(user.id, user.version);
            final tempPw = data?['tempPassword'] as String?;
            if (tempPw != null && context.mounted) {
              await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => TempPasswordDialog(
                  tempPassword: tempPw,
                  fullName: user.fullName,
                ),
              );
            }
          },
        );
    }
  }

  Future<void> _confirmAndDo(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String message,
    required Future<void> Function() action,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;
    try {
      await action();
    } on Exception catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }
}
