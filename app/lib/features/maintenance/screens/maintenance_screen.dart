import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/maintenance_provider.dart';
import '../../../models/maintenance_task.dart';
import '../../../models/user.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/users/providers/users_provider.dart';
import '../../../features/rooms/providers/rooms_provider.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/task_status_timeline.dart';
import '../../../shared/utils/error_handler.dart';

class MaintenanceScreen extends ConsumerWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(maintenanceProvider);
    final user = ref.watch(authProvider).user;

    final active = state.tasks.where((t) => t.status == MaintenanceStatus.open || t.status == MaintenanceStatus.inProgress).toList();
    final closed = state.tasks.where((t) => t.status == MaintenanceStatus.done || t.status == MaintenanceStatus.cancelled).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảo trì'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Tải lại',
            onPressed: () => ref.read(maintenanceProvider.notifier).load(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showReportDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Báo hỏng'),
      ),
      body: _buildBody(context, ref, state, active, closed, user),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    MaintenanceState state,
    List<MaintenanceTask> active,
    List<MaintenanceTask> closed,
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
              onPressed: () => ref.read(maintenanceProvider.notifier).load(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }
    if (state.tasks.isEmpty) {
      return const Center(child: Text('Không có việc bảo trì nào.'));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
      children: [
        if (active.isNotEmpty) ...[
          Text('Đang xử lý (${active.length})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          ...active.map((t) => _MaintenanceCard(
              task: t,
              currentUser: user,
              onAction: (action) => _handleAction(context, ref, t, action))),
        ],
        if (closed.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Đã xử lý (${closed.length})',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 8),
          ...closed.map((t) => _MaintenanceCard(task: t, currentUser: user, onAction: null)),
        ],
      ],
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, MaintenanceTask task, String action) async {
    final notifier = ref.read(maintenanceProvider.notifier);
    try {
      switch (action) {
        case 'claim':
          await notifier.claim(task.id, task.version);
        case 'complete':
          await notifier.complete(task.id, task.version);
        case 'cancel':
          await _showCancelDialog(context, ref, task);
          return;
        case 'assign':
          await _showAssignDialog(context, ref, task);
          return;
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thao tác thành công')));
      }
    } on ApiException catch (e) {
      if (context.mounted) {
        handleApiError(context, e, onReload: () => ref.read(maintenanceProvider.notifier).load());
      }
    }
  }

  Future<void> _showReportDialog(BuildContext context, WidgetRef ref) async {
    final rooms = ref.read(roomsProvider).rooms;
    if (rooms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chưa có danh sách phòng.')));
      return;
    }
    String? selectedRoomId;
    final descCtrl = TextEditingController();
    final locationCtrl = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Báo hỏng'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Phòng'),
                  items: rooms
                      .map((r) => DropdownMenuItem(value: r.id, child: Text('Phòng ${r.number} (T${r.floor})')))
                      .toList(),
                  onChanged: (v) => setState(() => selectedRoomId = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Mô tả sự cố', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationCtrl,
                  decoration: const InputDecoration(labelText: 'Vị trí (tuỳ chọn)', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: (selectedRoomId != null && descCtrl.text.trim().isNotEmpty) ? () => Navigator.pop(ctx, true) : null,
              child: const Text('Báo hỏng'),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true || selectedRoomId == null || !context.mounted) return;
    try {
      final warning = await ref.read(maintenanceProvider.notifier).report(
            roomId: selectedRoomId!,
            description: descCtrl.text.trim(),
            location: locationCtrl.text.trim(),
          );
      if (context.mounted) {
        final msg = warning != null ? 'Đã báo hỏng. Lưu ý: $warning' : 'Đã báo hỏng thành công';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _showCancelDialog(BuildContext context, WidgetRef ref, MaintenanceTask task) async {
    final reasonCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hủy việc bảo trì'),
        content: TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(labelText: 'Lý do (tuỳ chọn)', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Đóng')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hủy việc'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(maintenanceProvider.notifier).cancel(task.id, task.version, reason: reasonCtrl.text.trim());
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã hủy việc bảo trì')));
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _showAssignDialog(BuildContext context, WidgetRef ref, MaintenanceTask task) async {
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
          title: const Text('Chỉ định nhân viên'),
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
      await ref.read(maintenanceProvider.notifier).assign(task.id, task.version, selectedId!);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã chỉ định nhân viên')));
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: Colors.red));
      }
    }
  }
}

class _MaintenanceCard extends StatelessWidget {
  final MaintenanceTask task;
  final AppUser? currentUser;
  final void Function(String action)? onAction;

  const _MaintenanceCard({required this.task, required this.currentUser, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('HH:mm dd/MM');
    final isManager = currentUser?.role == UserRole.manager;
    final isReceptionist = currentUser?.role == UserRole.receptionist;
    final isStaff = currentUser?.role == UserRole.staff;
    final isMyTask = task.assignee?.id == currentUser?.id;
    final isReporter = task.reporter.id == currentUser?.id;
    final isActive = task.status == MaintenanceStatus.open || task.status == MaintenanceStatus.inProgress;

    Color statusColor;
    switch (task.status) {
      case MaintenanceStatus.open:
        statusColor = Colors.orange;
      case MaintenanceStatus.inProgress:
        statusColor = AppTheme.primary;
      case MaintenanceStatus.done:
        statusColor = AppTheme.statusReady;
      case MaintenanceStatus.cancelled:
        statusColor = Colors.grey;
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
            Text(task.description, style: const TextStyle(fontSize: 14)),
            if (task.location != null && task.location!.isNotEmpty)
              Text('Vị trí: ${task.location}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            Text('Báo bởi: ${task.reporter.fullName} · ${fmt.format(task.createdAt.toLocal())}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            if (task.assignee != null)
              Text('Phụ trách: ${task.assignee!.fullName}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            if (task.cancelReason != null)
              Text('Lý do hủy: ${task.cancelReason}', style: const TextStyle(fontSize: 12, color: Colors.red)),
            const SizedBox(height: 8),
            TaskStatusTimeline.maintenance(task.status),
            if (isActive && onAction != null) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: [
                  if (isStaff && task.status == MaintenanceStatus.open)
                    _ActionButton(label: 'Nhận việc', color: AppTheme.primary, onPressed: () => onAction!('claim')),
                  if (isStaff && isMyTask && task.status == MaintenanceStatus.inProgress)
                    _ActionButton(label: 'Hoàn tất', color: AppTheme.statusReady, onPressed: () => onAction!('complete')),
                  if ((isManager || isReceptionist) && task.status == MaintenanceStatus.open)
                    _ActionButton(label: 'Chỉ định', color: Colors.blueGrey, onPressed: () => onAction!('assign')),
                  if (isManager || (isReporter && task.status == MaintenanceStatus.open))
                    _ActionButton(label: 'Hủy', color: Colors.red, onPressed: () => onAction!('cancel')),
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
