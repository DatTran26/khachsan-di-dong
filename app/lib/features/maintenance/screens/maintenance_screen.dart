import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/maintenance_task.dart';
import '../../../models/user.dart';
import '../../../shared/utils/error_handler.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/task_status_timeline.dart';
import '../../../shared/widgets/task_link.dart';
import '../../../shared/widgets/ui.dart';
import '../../auth/providers/auth_provider.dart';
import '../../rooms/providers/rooms_provider.dart';
import '../../users/providers/users_provider.dart';
import '../providers/maintenance_provider.dart';
import '../widgets/report_issue_dialog.dart';

/// Bảo trì (maintenance).
/// - Nhân viên: việc sửa chờ nhận + việc mình đang sửa.
/// - Quản lý, lễ tân: bảng Chờ nhận · Đang sửa · Đã xử lý, chỉ định người sửa.
class MaintenanceScreen extends ConsumerWidget {
  const MaintenanceScreen({super.key});

  /// Nhân viên thấy [_StaffView], quản lý và lễ tân thấy [_DeskView].
  /// Nút báo hỏng tắt khi mất mạng. Lỗi khi danh sách rỗng thì [ErrorState].
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(maintenanceProvider);
    final user = ref.watch(authProvider).user;
    final online = ref.watch(isOnlineProvider);
    final gate = initialLoadGate(
      loading: state.isLoading,
      error: state.error,
      isEmpty: state.tasks.isEmpty,
      onRetry: ref.read(maintenanceProvider.notifier).load,
      skeleton: const SkeletonList(itemHeight: 120),
    );
    if (gate != null) return gate;
    final isStaff = user?.role == UserRole.staff;
    final pad = Breakpoints.hasSidebar(context) ? 32.0 : 16.0;

    final reportButton = ElevatedButton.icon(
      onPressed: online ? () => showReportIssueDialog(context) : null,
      icon: const Icon(Icons.report_problem_outlined, size: 18),
      label: const Text('Báo hỏng'),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
          pad, Breakpoints.hasSidebar(context) ? 24 : 16, pad, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Wrap: màn hẹp hoặc chữ to thì nút xuống dòng, mô tả không bị ép thành cột hẹp.
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              MetaText(isStaff
                  ? 'Nhận việc sửa, sửa xong thì báo để phòng mở lại phục vụ.'
                  : 'Phòng có việc sửa đang mở sẽ ở trạng thái Ngừng phục vụ.'),
              reportButton,
            ],
          ),
          if (!online) ...[
            const SizedBox(height: 10),
            const OfflineActionNote(),
          ],
          const SizedBox(height: 16),
          Expanded(
            child: isStaff
                ? _StaffView(tasks: state.tasks, me: user!, online: online)
                : _DeskView(tasks: state.tasks, me: user, online: online),
          ),
        ],
      ),
    );
  }
}

/// Cùng ngày lịch local với lúc gọi.
bool _isToday(DateTime t) {
  final l = t.toLocal(), n = DateTime.now();
  return l.year == n.year && l.month == n.month && l.day == n.day;
}

/// Chạy [action], snack [success] nếu còn mounted. [ApiException] qua [handleApiError] và tải lại việc sửa.
Future<void> _run(BuildContext context, WidgetRef ref,
    Future<void> Function() action, String success) async {
  try {
    await action();
    if (context.mounted) showAppSnack(context, success);
  } on ApiException catch (e) {
    if (context.mounted) {
      handleApiError(context, e,
          onReload: () => ref.read(maintenanceProvider.notifier).load());
    }
  }
}

/// Màu chip theo trạng thái việc sửa. Hủy là trung tính.
StatusTone _tone(MaintenanceStatus s) => switch (s) {
      MaintenanceStatus.open => StatusTone.gold,
      MaintenanceStatus.inProgress => StatusTone.cleaning,
      MaintenanceStatus.done => StatusTone.ready,
      MaintenanceStatus.cancelled => StatusTone.neutral,
    };

/// Thẻ một việc sửa. [actions] do view cha dựng. [large] tăng cỡ chữ phòng.
class _TaskCard extends ConsumerWidget {
  final MaintenanceTask task;
  final List<Widget> actions;
  final bool large;

  const _TaskCard(
      {required this.task, required this.actions, this.large = false});

  /// [openIfLinked] mở sheet nếu route có `?viec=` trùng id. Viền đỏ khi quá hạn và việc còn mở.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = DateFormat('HH:mm dd/MM');
    final active = task.status == MaintenanceStatus.open ||
        task.status == MaintenanceStatus.inProgress;
    openIfLinked(
        context, ref, task.id, () => _showDetail(context, task, actions));
    return AppCard(
      padding: EdgeInsets.all(large ? 14 : 12),
      borderColor: task.isOverdue && active ? AppColors.danger : null,
      onTap: () => _showDetail(context, task, actions),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Phòng ${task.room.number}',
                    style: (large ? AppText.titleLg : AppText.bodyLg)
                        .copyWith(fontWeight: FontWeight.w700)),
              ),
              if (task.isOverdue && active)
                const OverdueBadge()
              else
                StatusChip(task.status.label, tone: _tone(task.status)),
            ],
          ),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(children: [
              TextSpan(
                  text: task.description,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              if (task.location?.isNotEmpty == true)
                TextSpan(text: ' · ${task.location}'),
            ]),
            style: AppText.body.copyWith(height: 1.4),
          ),
          const SizedBox(height: 4),
          MetaText(
              'Báo bởi: ${task.reporter.fullName} · ${fmt.format(task.createdAt.toLocal())}'),
          if (task.assignee != null)
            MetaText('Phụ trách: ${task.assignee!.fullName}'),
          if (task.cancelReason?.isNotEmpty == true)
            MetaText('Lý do hủy: ${task.cancelReason}'),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                for (var i = 0; i < actions.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(child: actions[i]),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Sheet tiến độ và nút [actions] bản chụp lúc mở. Không tự cập nhật khi socket đổi việc.
void _showDetail(
    BuildContext context, MaintenanceTask task, List<Widget> actions) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    constraints: const BoxConstraints(maxWidth: 520),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Phòng ${task.room.number}',
                      style: AppText.headlineLg
                          .copyWith(fontWeight: FontWeight.w700)),
                ),
                StatusChip(task.status.label, tone: _tone(task.status)),
              ],
            ),
            MetaText('Tầng ${task.room.floor} · việc sửa'),
            const SizedBox(height: 8),
            Text(task.description,
                style: AppText.bodyLg.copyWith(fontWeight: FontWeight.w600)),
            if (task.location?.isNotEmpty == true)
              MetaText('Vị trí: ${task.location}'),
            const SizedBox(height: 20),
            const SectionLabel('Tiến độ'),
            const SizedBox(height: 12),
            TaskStatusTimeline.maintenance(task),
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  for (var i = 0; i < actions.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(child: actions[i]),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Nhân viên

/// Việc mình đang sửa, việc chờ nhận (chưa giao hoặc giao cho mình), và việc mình xong hôm nay.
class _StaffView extends ConsumerWidget {
  final List<MaintenanceTask> tasks;
  final AppUser me;
  final bool online;
  const _StaffView(
      {required this.tasks, required this.me, required this.online});

  /// Kéo để [MaintenanceNotifier.load]. Nút nhận/báo xong tắt khi [online] false.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.read(maintenanceProvider.notifier);
    const size = Size.fromHeight(48);
    final mine = tasks
        .where((t) =>
            t.status == MaintenanceStatus.inProgress && t.assignee?.id == me.id)
        .toList();
    final open = tasks
        .where((t) =>
            t.status == MaintenanceStatus.open &&
            (t.assignee == null || t.assignee!.id == me.id))
        .toList()
      ..sort((a, b) => a.isOverdue == b.isOverdue
          ? a.createdAt.compareTo(b.createdAt)
          : (a.isOverdue ? -1 : 1));
    final doneToday = tasks
        .where((t) =>
            t.status == MaintenanceStatus.done &&
            t.assignee?.id == me.id &&
            _isToday(t.updatedAt))
        .toList();

    if (mine.isEmpty && open.isEmpty && doneToday.isEmpty) {
      return const EmptyState(
        icon: Icons.handyman_outlined,
        title: 'Chưa có việc sửa nào.',
        message: 'Khi có báo hỏng, việc sẽ hiện ở đây để bạn nhận.',
      );
    }

    return RefreshIndicator(
      onRefresh: n.load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          if (mine.isNotEmpty) ...[
            SectionLabel('Đang sửa · ${mine.length}'),
            const SizedBox(height: 8),
            for (final t in mine)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TaskCard(task: t, large: true, actions: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(minimumSize: size),
                    onPressed: online
                        ? () => _run(
                            context,
                            ref,
                            () => n.complete(t.id, t.version),
                            'Đã báo sửa xong phòng ${t.room.number}. Phòng mở lại phục vụ khi không còn việc sửa nào.')
                        : null,
                    child: const Text('Báo đã sửa xong'),
                  ),
                ]),
              ),
          ],
          if (open.isNotEmpty) ...[
            SectionLabel('Chờ nhận · ${open.length}'),
            const SizedBox(height: 8),
            for (final t in open)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TaskCard(task: t, large: true, actions: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(minimumSize: size),
                    onPressed: online
                        ? () => _run(
                            context,
                            ref,
                            () => n.claim(t.id, t.version),
                            'Đã nhận việc sửa phòng ${t.room.number}.')
                        : null,
                    child: const Text('Nhận việc sửa'),
                  ),
                ]),
              ),
          ],
          if (doneToday.isNotEmpty) ...[
            SectionLabel('Đã xong hôm nay · ${doneToday.length}'),
            const SizedBox(height: 8),
            for (final t in doneToday)
              Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _TaskCard(task: t, actions: const [])),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quản lý, lễ tân

/// Ba cột chờ nhận, đang sửa, đã xử lý (tối đa 20 việc đóng). Quản lý và lễ tân.
class _DeskView extends ConsumerWidget {
  final List<MaintenanceTask> tasks;
  final AppUser? me;
  final bool online;
  const _DeskView(
      {required this.tasks, required this.me, required this.online});

  /// Chỉ định khi việc còn chờ nhận. Hủy nếu là quản lý, hoặc lễ tân chính là người báo và việc chưa nhận.
  /// Việc đóng không còn nút. Mất [online] thì tắt nút.
  List<Widget> _actions(
      BuildContext context, WidgetRef ref, MaintenanceTask t) {
    if (t.status != MaintenanceStatus.open &&
        t.status != MaintenanceStatus.inProgress) {
      return const [];
    }
    final isManager = me?.role == UserRole.manager;
    final canCancel = isManager ||
        (t.reporter.id == me?.id && t.status == MaintenanceStatus.open);
    return [
      if (t.status == MaintenanceStatus.open)
        ElevatedButton(
          onPressed: online ? () => _assign(context, ref, t) : null,
          child: Text(t.assignee == null ? 'Chỉ định' : 'Đổi người'),
        ),
      if (canCancel)
        OutlinedButton(
          onPressed: online ? () => _cancel(context, ref, t) : null,
          child: const Text('Hủy việc'),
        ),
    ];
  }

  /// Chọn nhân viên đang trực rồi [MaintenanceNotifier.assign]. Không ai trực thì snack, không gọi API.
  Future<void> _assign(
      BuildContext context, WidgetRef ref, MaintenanceTask t) async {
    final staff = ref
        .read(usersProvider)
        .users
        .where((u) =>
            u.role == UserRole.staff &&
            u.onDuty &&
            u.status == AccountStatus.active)
        .toList();
    if (staff.isEmpty) {
      showAppSnack(context, 'Chưa có nhân viên buồng phòng–bảo trì đang trực.',
          tone: SnackTone.warn);
      return;
    }
    String? selected = t.assignee?.id;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => GoldDialog(
          title: 'Chỉ định người sửa phòng ${t.room.number}',
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
              onPressed:
                  selected == null ? null : () => Navigator.pop(ctx, true),
              child: const Text('Chỉ định'),
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
            .read(maintenanceProvider.notifier)
            .assign(t.id, t.version, selected!),
        'Đã chỉ định $name sửa phòng ${t.room.number}.');
  }

  /// Hỏi lý do (có thể trống) rồi [MaintenanceNotifier.cancel]. Lý do rỗng không gửi field reason.
  Future<void> _cancel(
      BuildContext context, WidgetRef ref, MaintenanceTask t) async {
    final reason = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => GoldDialog(
        title: 'Hủy việc sửa phòng ${t.room.number}?',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
                'Dùng khi báo nhầm hoặc sự cố không còn. Phòng mở lại phục vụ nếu không còn việc sửa nào khác.',
                style: TextStyle(color: AppColors.muted, height: 1.5)),
            const SizedBox(height: 14),
            TextField(
                controller: reason,
                maxLength: 200,
                decoration: const InputDecoration(labelText: 'Lý do')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Giữ việc')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hủy việc sửa'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await _run(
        context,
        ref,
        () => ref
            .read(maintenanceProvider.notifier)
            .cancel(t.id, t.version, reason: reason.text.trim()),
        'Đã hủy việc sửa phòng ${t.room.number}.');
  }

  /// Side effect: watch [usersProvider] để chỉ định có danh sách. Màn hẹp xếp mục dọc.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(usersProvider); // nạp sẵn danh sách nhân viên để chỉ định
    final wide = Breakpoints.isWide(context);
    /// Quá hạn trước, rồi việc tạo sớm hơn. Âm nếu [a] đứng trước.
    int byOverdue(MaintenanceTask a, MaintenanceTask b) =>
        a.isOverdue == b.isOverdue
            ? a.createdAt.compareTo(b.createdAt)
            : (a.isOverdue ? -1 : 1);
    final open = tasks.where((t) => t.status == MaintenanceStatus.open).toList()
      ..sort(byOverdue);
    final progress = tasks
        .where((t) => t.status == MaintenanceStatus.inProgress)
        .toList()
      ..sort(byOverdue);
    final closed = tasks
        .where((t) =>
            t.status == MaintenanceStatus.done ||
            t.status == MaintenanceStatus.cancelled)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final columns = [
      ('Chờ nhận', open),
      ('Đang sửa', progress),
      ('Đã xử lý', closed.take(20).toList())
    ];

    if (tasks.isEmpty) {
      return const EmptyState(
        icon: Icons.handyman_outlined,
        title: 'Chưa có báo hỏng nào.',
        message:
            'Bấm "Báo hỏng" khi phát hiện sự cố — phòng sẽ tạm ngừng phục vụ cho tới khi sửa xong.',
      );
    }

    final reload = ref.read(maintenanceProvider.notifier).load;
    if (!wide) {
      return RefreshIndicator(
        onRefresh: reload,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            for (final (title, list) in columns) ...[
              SectionLabel('$title · ${list.length}'),
              const SizedBox(height: 8),
              if (list.isEmpty)
                const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: MetaText('Không có việc.')),
              for (final t in list)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _TaskCard(task: t, actions: _actions(context, ref, t)),
                ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < columns.length; i++) ...[
            if (i > 0) const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSunken,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 2, 4, 10),
                      child: Text('${columns[i].$1} · ${columns[i].$2.length}',
                          style: AppText.body
                              .copyWith(fontWeight: FontWeight.w700)),
                    ),
                    Expanded(
                      child: columns[i].$2.isEmpty
                          ? const Center(child: MetaText('Không có việc.'))
                          : RefreshIndicator(
                              onRefresh: reload,
                              child: ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: columns[i].$2.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (_, j) {
                                  final t = columns[i].$2[j];
                                  return _TaskCard(
                                      task: t,
                                      actions: _actions(context, ref, t));
                                },
                              ),
                            ),
                    ),
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
