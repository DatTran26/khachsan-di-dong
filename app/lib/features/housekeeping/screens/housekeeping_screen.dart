import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/housekeeping_provider.dart';
import '../../../models/housekeeping_task.dart';
import '../../../models/user.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/users/providers/users_provider.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';

class HousekeepingScreen extends ConsumerWidget {
  const HousekeepingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(housekeepingProvider);
    final user = ref.watch(authProvider).user;

    final activeTasks = state.tasks.where((t) => t.status != HousekeepingStatus.done).toList();
    final doneTasks = state.tasks.where((t) => t.status == HousekeepingStatus.done).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dọn phòng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Tải lại',
            onPressed: () => ref.read(housekeepingProvider.notifier).load(),
          ),
        ],
      ),
      body: _buildBody(context, ref, state, activeTasks, doneTasks, user),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    HousekeepingState state,
    List<HousekeepingTask> active,
    List<HousekeepingTask> done,
    AppUser? user,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red[400], size: 40),
            const SizedBox(height: 8),
            Text(state.error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref.read(housekeepingProvider.notifier).load(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }
    if (state.tasks.isEmpty) {
      return const Center(child: Text('Không có việc dọn phòng nào.'));
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        if (active.isNotEmpty) ...[
          Text('Đang xử lý (${active.length})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          ...active.map((t) => _TaskCard(task: t, currentUser: user, onAction: (action) => _handleAction(context, ref, t, action, user))),
        ],
        if (done.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Hoàn tất hôm nay (${done.length})',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 8),
          ...done.map((t) => _TaskCard(task: t, currentUser: user, onAction: null)),
        ],
      ],
    );
  }

  void _handleAction(
    BuildContext context,
    WidgetRef ref,
    HousekeepingTask task,
    String action,
    AppUser? user,
  ) async {
    final notifier = ref.read(housekeepingProvider.notifier);
    try {
      switch (action) {
        case 'accept':
          await notifier.accept(task.id, task.version);
        case 'reject':
          await notifier.reject(task.id, task.version);
        case 'complete':
          await notifier.complete(task.id, task.version);
        case 'confirm':
          await notifier.confirm(task.id, task.version);
        case 'return':
          await _showReturnDialog(context, ref, task);
          return;
        case 'reassign':
          await _showReassignDialog(context, ref, task);
          return;
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thao tác thành công')));
      }
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _showReturnDialog(BuildContext context, WidgetRef ref, HousekeepingTask task) async {
    final noteCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Trả lại việc dọn'),
        content: TextField(
          controller: noteCtrl,
          maxLength: 500,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Ghi chú (bắt buộc)', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              if (noteCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx, true);
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(housekeepingProvider.notifier).returnTask(task.id, task.version, noteCtrl.text.trim());
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã trả lại việc')));
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _showReassignDialog(BuildContext context, WidgetRef ref, HousekeepingTask task) async {
    final usersState = ref.read(usersProvider);
    final staffOnDuty = usersState.users
        .where((u) => u.role == UserRole.staff && u.onDuty && u.status == AccountStatus.active)
        .toList();
    if (!context.mounted) return;
    if (staffOnDuty.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không có nhân viên đang trực.')));
      return;
    }
    String? selectedId;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Phân công lại'),
          content: DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Chọn nhân viên'),
            items: staffOnDuty
                .map((u) => DropdownMenuItem(value: u.id, child: Text(u.fullName)))
                .toList(),
            onChanged: (v) => setState(() => selectedId = v),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: selectedId == null ? null : () => Navigator.pop(ctx, true),
              child: const Text('Xác nhận'),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true || selectedId == null || !context.mounted) return;
    try {
      await ref.read(housekeepingProvider.notifier).reassign(task.id, task.version, selectedId!);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã phân công lại')));
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: Colors.red));
      }
    }
  }
}

class _TaskCard extends StatelessWidget {
  final HousekeepingTask task;
  final AppUser? currentUser;
  final void Function(String action)? onAction;

  const _TaskCard({required this.task, required this.currentUser, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('HH:mm dd/MM');
    final isManager = currentUser?.role == UserRole.manager;
    final isStaff = currentUser?.role == UserRole.staff;
    final isMyTask = task.assignee?.id == currentUser?.id;
    final isDone = task.status == HousekeepingStatus.done;

    Color statusColor;
    switch (task.status) {
      case HousekeepingStatus.pending:
        statusColor = Colors.grey;
      case HousekeepingStatus.accepted:
        statusColor = Colors.blue;
      case HousekeepingStatus.cleaning:
        statusColor = AppTheme.statusDirty;
      case HousekeepingStatus.pendingInspection:
        statusColor = AppTheme.statusPending;
      case HousekeepingStatus.done:
        statusColor = AppTheme.statusReady;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                  child: Text(task.status.label, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
                if (task.isOverdue) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: Colors.deepOrange.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                    child: const Text('Quá hạn', style: TextStyle(color: Colors.deepOrange, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
                const Spacer(),
                Text('Phòng ${task.room.number} (T${task.room.floor})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
            const SizedBox(height: 6),
            Text('Hạn: ${fmt.format(task.dueAt.toLocal())}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            if (task.assignee != null)
              Text('Phụ trách: ${task.assignee!.fullName}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            if (task.returnNote != null) ...[
              const SizedBox(height: 4),
              Text('Ghi chú trả lại: ${task.returnNote}',
                  style: const TextStyle(fontSize: 12, color: Colors.orange)),
            ],
            if (!isDone && onAction != null) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: [
                  if (isStaff && isMyTask && task.status == HousekeepingStatus.accepted)
                    _ActionButton(label: 'Bắt đầu dọn', color: AppTheme.primary, onPressed: () => onAction!('complete')),
                  if (isStaff && isMyTask && task.status == HousekeepingStatus.cleaning)
                    _ActionButton(label: 'Báo xong', color: AppTheme.secondary, onPressed: () => onAction!('complete')),
                  if (isStaff && task.status == HousekeepingStatus.pending)
                    _ActionButton(label: 'Nhận việc', color: AppTheme.primary, onPressed: () => onAction!('accept')),
                  if (isStaff && isMyTask && task.status == HousekeepingStatus.accepted)
                    _ActionButton(label: 'Từ chối', color: Colors.red, onPressed: () => onAction!('reject')),
                  if (isManager && task.status == HousekeepingStatus.pendingInspection) ...[
                    _ActionButton(label: 'Xác nhận sạch', color: AppTheme.statusReady, onPressed: () => onAction!('confirm')),
                    _ActionButton(label: 'Trả lại', color: Colors.orange, onPressed: () => onAction!('return')),
                  ],
                  if (isManager)
                    _ActionButton(label: 'Phân công lại', color: Colors.blueGrey, onPressed: () => onAction!('reassign')),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({required this.label, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) => OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          minimumSize: const Size(0, 32),
        ),
        child: Text(label, style: const TextStyle(fontSize: 12)),
      );
}
