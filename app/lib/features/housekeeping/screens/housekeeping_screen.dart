import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/housekeeping_task.dart';
import '../../../models/user.dart';
import '../../../shared/utils/error_handler.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/task_status_timeline.dart';
import '../../../shared/widgets/task_link.dart';
import '../../../shared/widgets/ui.dart';
import '../../auth/providers/auth_provider.dart';
import '../../maintenance/widgets/report_issue_dialog.dart';
import '../../rooms/providers/rooms_provider.dart';
import '../../users/providers/users_provider.dart';
import '../providers/housekeeping_provider.dart';
import '../widgets/photo_gallery.dart';
import 'acceptance_photos_screen.dart';

/// Dọn phòng.
/// - Quản lý: bảng điều phối 4 cột (Chờ giao · Đã giao · Đang dọn · Chờ xác nhận).
/// - Nhân viên: danh sách việc của mình, nút lớn dễ bấm trên điện thoại.
class HousekeepingScreen extends ConsumerWidget {
  const HousekeepingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(housekeepingProvider);
    final role = ref.watch(authProvider.select((s) => s.user?.role));

    if (state.isLoading && state.tasks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null && state.tasks.isEmpty) {
      return ErrorState(
          message: state.error!,
          onRetry: () => ref.read(housekeepingProvider.notifier).load());
    }
    return role == UserRole.manager
        ? _ManagerBoard(tasks: state.tasks)
        : _StaffList(tasks: state.tasks);
  }
}

// ---------------------------------------------------------------------------
// Dùng chung

bool _isToday(DateTime? t) {
  if (t == null) return false;
  final l = t.toLocal(), n = DateTime.now();
  return l.year == n.year && l.month == n.month && l.day == n.day;
}

/// "Hạn 14:50" hoặc "Hạn 14:30 — trễ 12 phút".
Widget dueText(DateTime due, bool overdue) {
  final hm = DateFormat('HH:mm').format(due.toLocal());
  if (!overdue) return MetaText('Hạn $hm');
  final late = DateTime.now().difference(due).inMinutes;
  return MetaText(
    late > 0 ? 'Hạn $hm — trễ $late phút' : 'Hạn $hm',
    color: AppColors.danger,
    weight: FontWeight.w600,
  );
}

StatusTone _tone(HousekeepingTask t) {
  if (t.returnNote != null && t.status == HousekeepingStatus.inProgress) {
    return StatusTone.danger;
  }
  switch (t.status) {
    case HousekeepingStatus.unassigned:
      return StatusTone.neutral;
    case HousekeepingStatus.assigned:
      return StatusTone.gold;
    case HousekeepingStatus.inProgress:
      return StatusTone.cleaning;
    case HousekeepingStatus.pendingConfirm:
      return StatusTone.inspect;
    case HousekeepingStatus.done:
      return StatusTone.ready;
  }
}

String _label(HousekeepingTask t) =>
    t.returnNote != null && t.status == HousekeepingStatus.inProgress
        ? 'Bị trả lại'
        : t.status.label;

Future<void> _run(BuildContext context, WidgetRef ref,
    Future<void> Function() action, String success) async {
  try {
    await action();
    if (context.mounted) showAppSnack(context, success);
  } on ApiException catch (e) {
    if (context.mounted) {
      handleApiError(context, e,
          onReload: () => ref.read(housekeepingProvider.notifier).load());
    }
  }
}

Future<void> _returnTask(
    BuildContext context, WidgetRef ref, HousekeepingTask task) async {
  final note = TextEditingController();
  String? error;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => GoldDialog(
        title: 'Trả lại việc dọn phòng ${task.room.number}?',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${task.assignee?.fullName ?? 'Nhân viên'} sẽ nhận lại việc và thấy ghi chú của bạn. Phòng vẫn ở trạng thái Đang dọn.',
              style: const TextStyle(color: AppColors.muted, height: 1.5),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: note,
              autofocus: true,
              maxLines: 3,
              maxLength: 500,
              decoration: InputDecoration(
                labelText: 'Cần làm lại gì? *',
                hintText: 'Ví dụ: gương phòng tắm còn vết, thay khăn tắm',
                errorText: error,
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Để sau')),
          ElevatedButton(
            onPressed: () {
              if (note.text.trim().isEmpty) {
                setState(() =>
                    error = 'Vui lòng nhập ghi chú khi trả lại công việc.');
                return;
              }
              Navigator.pop(ctx, true);
            },
            child: const Text('Trả lại việc'),
          ),
        ],
      ),
    ),
  );
  if (ok != true || !context.mounted) return;
  await _run(
      context,
      ref,
      () => ref
          .read(housekeepingProvider.notifier)
          .returnTask(task.id, task.version, note.text.trim()),
      'Đã trả lại việc dọn phòng ${task.room.number}.');
}

Future<void> _assign(
    BuildContext context, WidgetRef ref, HousekeepingTask task) async {
  final users = ref.read(usersProvider).users;
  final staff = users
      .where((u) =>
          u.role == UserRole.staff &&
          u.onDuty &&
          u.status == AccountStatus.active)
      .toList();
  if (staff.isEmpty) {
    showAppSnack(context,
        'Chưa có nhân viên buồng phòng đang trực — công việc đang chờ giao.',
        tone: SnackTone.warn);
    return;
  }
  String? selected = task.assignee?.id;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => GoldDialog(
        title: task.assignee == null
            ? 'Giao việc dọn phòng ${task.room.number}'
            : 'Phân công lại phòng ${task.room.number}',
        content: RadioGroup<String>(
          groupValue: selected,
          onChanged: (v) => setState(() => selected = v),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final u in staff)
                RadioListTile<String>(
                  value: u.id,
                  title: Text(u.fullName),
                  subtitle: Text(u.phone),
                  activeColor: AppColors.goldDark,
                  contentPadding: EdgeInsets.zero,
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Để sau')),
          ElevatedButton(
            onPressed: selected == null || selected == task.assignee?.id
                ? null
                : () => Navigator.pop(ctx, true),
            child: const Text('Giao việc'),
          ),
        ],
      ),
    ),
  );
  if (ok != true || selected == null || !context.mounted) return;
  final name = staff.firstWhere((u) => u.id == selected).fullName;
  await _run(
      context,
      ref,
      () => ref
          .read(housekeepingProvider.notifier)
          .reassign(task.id, task.version, selected!),
      'Đã giao việc dọn phòng ${task.room.number} cho $name.');
}

/// Dựng nút thao tác cho [task] theo trạng thái hiện tại (thẻ và sheet chi tiết dùng chung).
typedef _TaskActions = List<Widget> Function(
    BuildContext context, WidgetRef ref, HousekeepingTask task, bool online);

/// Sheet chi tiết luôn đọc việc mới nhất theo `task.id` từ [housekeepingProvider] — thao tác trong sheet
/// hoặc realtime đổi trạng thái thì nội dung và nút tự cập nhật theo.
void _showDetail(
    BuildContext context, HousekeepingTask task, _TaskActions actionsFor) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    constraints: const BoxConstraints(maxWidth: 520),
    builder: (_) => _TaskDetailSheet(initial: task, actionsFor: actionsFor),
  );
}

class _TaskDetailSheet extends ConsumerStatefulWidget {
  final HousekeepingTask initial;
  final _TaskActions actionsFor;
  const _TaskDetailSheet({required this.initial, required this.actionsFor});

  @override
  ConsumerState<_TaskDetailSheet> createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends ConsumerState<_TaskDetailSheet> {
  /// Lúc mở có nút thao tác không — để biết khi nào việc "hết việc cần làm" thì tự đóng.
  /// (Sheet mở từ mục "Xong hôm nay" vốn không có nút → không tự đóng.)
  late final bool _hadActions = widget
      .actionsFor(context, ref, widget.initial, ref.read(isOnlineProvider))
      .isNotEmpty;
  bool _closing = false;

  /// Đóng đúng sheet này kể cả khi đang có hộp thoại khác đè lên.
  void _close() {
    if (_closing) return;
    _closing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final route = ModalRoute.of(context);
      if (route == null) return;
      if (route.isCurrent) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).removeRoute(route);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final online = ref.watch(isOnlineProvider);
    final id = widget.initial.id;
    final latest = ref.watch(housekeepingProvider
        .select((s) => s.tasks.where((t) => t.id == id).firstOrNull));
    final task = latest ?? widget.initial;
    final actions = latest == null
        ? const <Widget>[]
        : widget.actionsFor(context, ref, task, online);
    // Việc không còn trong danh sách, hoặc đã hết nút cần làm (vd đã xác nhận sạch) → đóng sheet.
    if (latest == null || (_hadActions && actions.isEmpty)) _close();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Phòng ${task.room.number}',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w700)),
                ),
                StatusChip(_label(task), tone: _tone(task)),
              ],
            ),
            MetaText('Tầng ${task.room.floor} · việc dọn'),
            const SizedBox(height: 6),
            dueText(task.dueAt, task.isOverdue),
            if (task.returnNote != null) ...[
              const SizedBox(height: 12),
              AppBanner(
                  tone: BannerTone.error,
                  title: 'Quản lý ghi chú:',
                  message: task.returnNote!),
            ],
            const SizedBox(height: 20),
            const SectionLabel('Tiến độ'),
            const SizedBox(height: 12),
            TaskStatusTimeline.housekeeping(task),
            // Đã báo xong → quản lý đối chiếu ảnh trước khi xác nhận / trả lại (FR-housekeeping-007).
            if (task.status == HousekeepingStatus.pendingConfirm ||
                task.status == HousekeepingStatus.done) ...[
              const SizedBox(height: 20),
              PhotoReviewSection(taskId: task.id),
            ],
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 20),
              for (final a in actions)
                Padding(padding: const EdgeInsets.only(bottom: 10), child: a),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quản lý

class _ManagerBoard extends ConsumerWidget {
  final List<HousekeepingTask> tasks;
  const _ManagerBoard({required this.tasks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(usersProvider); // nạp sẵn danh sách nhân viên để giao việc
    final online = ref.watch(isOnlineProvider);
    final wide = Breakpoints.isWide(context);
    final pad = Breakpoints.hasSidebar(context) ? 32.0 : 16.0;

    List<HousekeepingTask> by(HousekeepingStatus s) =>
        tasks.where((t) => t.status == s).toList()
          ..sort((a, b) => a.dueAt.compareTo(b.dueAt));
    final columns = [
      ('Chờ giao', by(HousekeepingStatus.unassigned)),
      ('Đã giao', by(HousekeepingStatus.assigned)),
      ('Đang dọn', by(HousekeepingStatus.inProgress)),
      ('Chờ xác nhận', by(HousekeepingStatus.pendingConfirm)),
    ];
    final doneToday = tasks
        .where((t) =>
            t.status == HousekeepingStatus.done && _isToday(t.confirmedAt))
        .length;
    final waiting = columns[3].$2.length;

    Widget card(HousekeepingTask t) =>
        _ManagerTaskCard(task: t, online: online);

    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (waiting > 0)
          AppBanner(
            tone: BannerTone.info,
            title: '$waiting phòng chờ bạn xác nhận.',
            message: 'Phòng chỉ về Sẵn sàng sau khi quản lý xác nhận sạch.',
          ),
        if (waiting > 0) const SizedBox(height: 16),
      ],
    );

    if (tasks.isEmpty) {
      return const EmptyState(
        icon: Icons.cleaning_services_outlined,
        title: 'Chưa có việc dọn nào.',
        message: 'Khi khách trả phòng, việc dọn sẽ tự xuất hiện ở đây.',
      );
    }

    if (!wide) {
      return ListView(
        padding: EdgeInsets.fromLTRB(pad, 16, pad, 24),
        children: [
          header,
          for (final (title, list) in columns) ...[
            SectionLabel('$title · ${list.length}'),
            const SizedBox(height: 8),
            if (list.isEmpty)
              const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: MetaText('Không có việc.')),
            for (final t in list)
              Padding(
                  padding: const EdgeInsets.only(bottom: 10), child: card(t)),
            const SizedBox(height: 8),
          ],
          MetaText('Hoàn tất hôm nay: $doneToday phòng'),
        ],
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 24, pad, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < columns.length; i++) ...[
                  if (i > 0) const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0ECE3),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 2, 4, 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(columns[i].$1,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Text('${columns[i].$2.length}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.muted)),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: columns[i].$2.isEmpty
                                ? const Center(
                                    child: MetaText('Không có việc.'))
                                : ListView.separated(
                                    itemCount: columns[i].$2.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 10),
                                    itemBuilder: (_, j) =>
                                        card(columns[i].$2[j]),
                                  ),
                          ),
                          if (i == columns.length - 1)
                            Padding(
                              padding: const EdgeInsets.only(top: 8, left: 4),
                              child: MetaText(
                                  'Hoàn tất hôm nay: $doneToday phòng'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

List<Widget> _managerActions(
    BuildContext context, WidgetRef ref, HousekeepingTask task, bool online,
    {bool large = false}) {
  final n = ref.read(housekeepingProvider.notifier);
  final size = large ? const Size.fromHeight(48) : const Size(0, 36);
  switch (task.status) {
    case HousekeepingStatus.unassigned:
      return [
        ElevatedButton(
          style: ElevatedButton.styleFrom(minimumSize: size),
          onPressed: online ? () => _assign(context, ref, task) : null,
          child: const Text('Giao cho…'),
        ),
      ];
    case HousekeepingStatus.assigned:
    case HousekeepingStatus.inProgress:
      return [
        OutlinedButton(
          style: OutlinedButton.styleFrom(minimumSize: size),
          onPressed: online ? () => _assign(context, ref, task) : null,
          child: const Text('Phân công lại'),
        ),
      ];
    case HousekeepingStatus.pendingConfirm:
      return [
        ElevatedButton(
          style: ElevatedButton.styleFrom(minimumSize: size),
          onPressed: online
              ? () => _run(context, ref, () => n.confirm(task.id, task.version),
                  'Đã xác nhận phòng ${task.room.number} sạch. Phòng về Sẵn sàng.')
              : null,
          child: const Text('Xác nhận sạch'),
        ),
        OutlinedButton(
          style: OutlinedButton.styleFrom(minimumSize: size),
          onPressed: online ? () => _returnTask(context, ref, task) : null,
          child: const Text('Trả lại'),
        ),
      ];
    case HousekeepingStatus.done:
      return const [];
  }
}

class _ManagerTaskCard extends ConsumerWidget {
  final HousekeepingTask task;
  final bool online;
  const _ManagerTaskCard({required this.task, required this.online});

  void _open(BuildContext context) => _showDetail(
      context, task, (c, r, t, o) => _managerActions(c, r, t, o, large: true));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hm = DateFormat('HH:mm');
    final actions = _managerActions(context, ref, task, online);
    openIfLinked(context, ref, task.id, () => _open(context));
    return AppCard(
      padding: const EdgeInsets.all(12),
      borderColor: task.isOverdue
          ? AppColors.danger
          : task.status == HousekeepingStatus.pendingConfirm
              ? const Color(0xFFE7B7D1)
              : null,
      onTap: () => _open(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Phòng ${task.room.number}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
              ),
              if (task.isOverdue)
                const OverdueBadge()
              else
                StatusChip(_label(task), tone: _tone(task), dense: true),
            ],
          ),
          const SizedBox(height: 6),
          if (task.assignee != null)
            MetaText('Phụ trách: ${task.assignee!.fullName}'),
          if (task.status == HousekeepingStatus.pendingConfirm &&
              task.completedAt != null)
            MetaText('Báo xong lúc ${hm.format(task.completedAt!.toLocal())}')
          else
            dueText(task.dueAt, task.isOverdue),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 10),
            // Cột bảng điều phối hẹp → xếp nút dọc để chữ không bị xuống dòng.
            for (var i = 0; i < actions.length; i++) ...[
              if (i > 0) const SizedBox(height: 6),
              actions[i],
            ],
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Nhân viên

class _StaffList extends ConsumerWidget {
  final List<HousekeepingTask> tasks;
  const _StaffList({required this.tasks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final online = ref.watch(isOnlineProvider);
    final active = tasks
        .where((t) =>
            t.status == HousekeepingStatus.assigned ||
            t.status == HousekeepingStatus.inProgress)
        .toList()
      ..sort((a, b) {
        if (a.isOverdue != b.isOverdue) return a.isOverdue ? -1 : 1;
        return a.dueAt.compareTo(b.dueAt);
      });
    final finished = tasks
        .where((t) =>
            t.status == HousekeepingStatus.pendingConfirm ||
            (t.status == HousekeepingStatus.done &&
                _isToday(t.confirmedAt ?? t.completedAt)))
        .toList();

    return RefreshIndicator(
      onRefresh: () => ref.read(housekeepingProvider.notifier).load(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MetaText(
                  'Chào ${user.fullName} · ${active.length} việc đang chờ bạn'),
            ),
          if (active.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: EmptyState(
                icon: Icons.check_circle_outline,
                title: 'Bạn chưa có việc dọn nào.',
                message:
                    'Khi quản lý giao việc, bạn sẽ nhận thông báo và việc sẽ hiện ở đây.',
              ),
            ),
          for (final t in active)
            Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _StaffTaskCard(task: t, online: online)),
          if (finished.isNotEmpty) ...[
            const SizedBox(height: 8),
            SectionLabel('Xong hôm nay · ${finished.length}'),
            const SizedBox(height: 8),
            for (final t in finished)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  onTap: () =>
                      _showDetail(context, t, (_, __, ___, ____) => const []),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('Phòng ${t.room.number}',
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      StatusChip(t.status.label, tone: _tone(t)),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

List<Widget> _staffActions(
    BuildContext context, WidgetRef ref, HousekeepingTask task, bool online,
    {bool vertical = false}) {
  final n = ref.read(housekeepingProvider.notifier);
  const size = Size.fromHeight(48);
  if (task.status == HousekeepingStatus.assigned) {
    return [
      OutlinedButton(
        style: OutlinedButton.styleFrom(minimumSize: size),
        onPressed: online
            ? () => showConfirmDialog(
                  context,
                  title: 'Từ chối việc dọn phòng ${task.room.number}?',
                  message:
                      'Việc sẽ quay về Chờ giao để quản lý giao cho người khác.',
                  confirmLabel: 'Từ chối',
                  onConfirm: () => n.reject(task.id, task.version),
                )
            : null,
        child: const Text('Từ chối'),
      ),
      ElevatedButton(
        style: ElevatedButton.styleFrom(minimumSize: size),
        onPressed: online
            ? () => _run(context, ref, () => n.accept(task.id, task.version),
                'Đã nhận việc phòng ${task.room.number}. Phòng chuyển sang Đang dọn.')
            : null,
        child: const Text('Nhận việc'),
      ),
    ];
  }
  // Đã báo xong / đã xác nhận / chưa giao → nhân viên không còn gì để làm.
  if (task.status != HousekeepingStatus.inProgress) return const [];
  return [
    // Báo xong cần đủ ảnh nghiệm thu → nộp ảnh và báo ở màn riêng (FR-housekeeping-005).
    ElevatedButton.icon(
      style: ElevatedButton.styleFrom(minimumSize: size),
      // Màn riêng toàn màn hình (navigator gốc) — không lồng trong khung app.
      onPressed: () => Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
              builder: (_) => AcceptancePhotosScreen(taskId: task.id))),
      icon: const Icon(Icons.photo_camera_outlined, size: 18),
      label: const Text('Ảnh & báo xong'),
    ),
    if (vertical)
      OutlinedButton(
        style: OutlinedButton.styleFrom(minimumSize: size),
        onPressed: online
            ? () => showReportIssueDialog(context, roomId: task.room.id)
            : null,
        child: const Text('Báo hỏng phòng này'),
      ),
  ];
}

class _StaffTaskCard extends ConsumerWidget {
  final HousekeepingTask task;
  final bool online;
  const _StaffTaskCard({required this.task, required this.online});

  void _open(BuildContext context) => _showDetail(
      context, task, (c, r, t, o) => _staffActions(c, r, t, o, vertical: true));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = _staffActions(context, ref, task, online);
    final started = task.startedAt != null
        ? ' · bắt đầu ${DateFormat('HH:mm').format(task.startedAt!.toLocal())}'
        : '';
    openIfLinked(context, ref, task.id, () => _open(context));
    return AppCard(
      padding: const EdgeInsets.all(14),
      borderColor: task.isOverdue ? AppColors.danger : null,
      onTap: () => _open(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Phòng ${task.room.number}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
              ),
              if (task.isOverdue)
                const OverdueBadge()
              else
                StatusChip(_label(task), tone: _tone(task)),
            ],
          ),
          const SizedBox(height: 6),
          MetaText('Tầng ${task.room.floor}$started'),
          if (task.returnNote != null)
            MetaText('Quản lý ghi chú: “${task.returnNote}”',
                color: AppColors.text),
          dueText(task.dueAt, task.isOverdue),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < actions.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(child: actions[i]),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
