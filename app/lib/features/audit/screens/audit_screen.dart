import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/audit_entry.dart';
import '../../../shared/widgets/ui.dart';
import '../../rooms/providers/rooms_provider.dart';
import '../providers/audit_provider.dart';

/// Nhật ký thay đổi (audit-log) — chỉ quản lý. Lọc theo thời gian, phòng, vai trò người thao tác.
/// `/nhat-ky?phong=<id>` (từ chi tiết phòng): lọc sẵn theo phòng đó.
class AuditScreen extends ConsumerStatefulWidget {
  final String? roomId;
  const AuditScreen({super.key, this.roomId});

  /// Tạo state. Lọc phòng từ query làm trong [initState].
  @override
  ConsumerState<AuditScreen> createState() => _AuditScreenState();
}

/// Áp `phong` từ route vào bộ lọc rồi bỏ query khỏi URL.
class _AuditScreenState extends ConsumerState<AuditScreen> {
  /// Sau frame đầu, lọc theo [AuditScreen.roomId] nếu có.
  @override
  void initState() {
    super.initState();
    _applyRoom();
  }

  /// [AuditScreen.roomId] đổi thì áp lại. Cùng id không gọi.
  @override
  void didUpdateWidget(AuditScreen old) {
    super.didUpdateWidget(old);
    if (widget.roomId != old.roomId) _applyRoom();
  }

  /// Bỏ `?phong=` khỏi đường dẫn sau khi lọc — người dùng vẫn đổi/bỏ lọc phòng như thường.
  void _applyRoom() {
    final roomId = widget.roomId;
    if (roomId == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final n = ref.read(auditProvider.notifier);
      n.setFilter(ref.read(auditProvider).filter.copyWith(roomId: roomId));
      context.go('/nhat-ky');
    });
  }

  /// Ủy quyền cho [_AuditBody] để body watch provider sau khi lọc đã được xếp post-frame.
  @override
  Widget build(BuildContext context) => const _AuditBody();
}

/// Danh sách nhật ký nhóm theo ngày và thanh lọc.
class _AuditBody extends ConsumerWidget {
  const _AuditBody();

  /// Rỗng dùng [AuditState.emptyMessage] nếu server gửi. Lỗi khi đã có dòng thì banner, không thay cả danh sách.
  /// `nextCursor` còn thì nút xem thêm.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(auditProvider);
    final wide = Breakpoints.isWide(context);
    final pad = Breakpoints.hasSidebar(context) ? 32.0 : 16.0;

    final groups = <String, List<AuditEntry>>{};
    for (final e in state.entries) {
      groups.putIfAbsent(_dayLabel(e.occurredAt), () => []).add(e);
    }

    final reload = ref.read(auditProvider.notifier).load;
    final gate = initialLoadGate(
      loading: state.isLoading,
      error: state.error,
      isEmpty: state.entries.isEmpty,
      onRetry: reload,
      skeleton: const SkeletonList(count: 8, itemHeight: 64),
    );
    Widget body;
    if (gate != null) {
      body = gate;
    } else if (state.entries.isEmpty) {
      body = EmptyState(
        icon: Icons.history_rounded,
        title:
            state.emptyMessage ?? 'Chưa có thay đổi nào trong phạm vi đã chọn.',
        message: state.filter.isActive
            ? 'Thử nới khoảng thời gian hoặc bỏ bớt điều kiện lọc.'
            : null,
      );
    } else {
      body = AppCard(
        padding: EdgeInsets.zero,
        child: RefreshIndicator(
          onRefresh: reload,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              for (final g in groups.entries) ...[
                Container(
                  color: AppColors.surfaceMuted,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text(g.key,
                      style:
                          AppText.meta.copyWith(fontWeight: FontWeight.w700)),
                ),
                for (final e in g.value) ...[
                  _EntryRow(entry: e, wide: wide),
                  const Divider(height: 1),
                ],
              ],
              if (state.nextCursor != null)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Center(
                    child: state.isLoadingMore
                        ? const CircularProgressIndicator(
                            semanticsLabel: 'Đang tải thêm nhật ký')
                        : TextButton(
                            onPressed: () =>
                                ref.read(auditProvider.notifier).loadMore(),
                            child: const Text('Xem thêm',
                                semanticsLabel: 'Xem thêm nhật ký cũ hơn'),
                          ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(pad, wide ? 24 : 16, pad, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FilterBar(filter: state.filter),
          if (state.error != null && state.entries.isNotEmpty) ...[
            const SizedBox(height: 12),
            AppBanner(tone: BannerTone.error, message: state.error!),
          ],
          const SizedBox(height: 16),
          Expanded(child: body),
        ],
      ),
    );
  }

  /// "Hôm nay", "Hôm qua" hoặc `dd/MM/yyyy` theo lịch local.
  static String _dayLabel(DateTime t) {
    final l = t.toLocal();
    final now = DateTime.now();
    final d = DateTime(l.year, l.month, l.day);
    final today = DateTime(now.year, now.month, now.day);
    final dm = DateFormat('dd/MM/yyyy').format(l);
    if (d == today) return 'Hôm nay · $dm';
    if (d == today.subtract(const Duration(days: 1))) return 'Hôm qua · $dm';
    return dm;
  }
}

/// Lọc từ/đến, phòng, vai trò. Đổi lọc gọi [AuditNotifier.setFilter] (tải lại từ đầu).
class _FilterBar extends ConsumerWidget {
  final AuditFilter filter;
  const _FilterBar({required this.filter});

  /// Chọn một ngày. [endOfDay] true thì 23:59:59, không thì 00:00. Hủy picker trả null.
  Future<DateTime?> _pick(BuildContext context, DateTime? initial,
      {required bool endOfDay}) async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
    );
    if (d == null) return null;
    return endOfDay
        ? DateTime(d.year, d.month, d.day, 23, 59, 59)
        : DateTime(d.year, d.month, d.day);
  }

  /// Không tự gọi API ngoài [setFilter]. Nút xóa lọc chỉ hiện khi [AuditFilter.isActive].
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.read(auditProvider.notifier);
    final rooms = ref.watch(roomsProvider).sorted;
    final fmt = DateFormat('dd/MM/yyyy');

    /// Ô ngày bấm được. Chỉ gọi [onChanged] khi người dùng chọn ngày, không gọi khi hủy.
    Widget dateField(
            String label, DateTime? value, ValueChanged<DateTime?> onChanged,
            {required bool end}) =>
        SizedBox(
          width: 170,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            onTap: () async {
              final v = await _pick(context, value, endOfDay: end);
              if (v != null) onChanged(v);
            },
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: label,
                suffixIcon: value == null
                    ? const Icon(Icons.event_outlined, size: 20)
                    : IconButton(
                        tooltip: 'Bỏ ngày',
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => onChanged(null),
                      ),
              ),
              child: Text(value == null ? 'Bất kỳ' : fmt.format(value),
                  style: AppText.body.copyWith(
                      color: value == null ? AppColors.muted : AppColors.text)),
            ),
          ),
        );

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          dateField('Từ ngày', filter.from,
              (v) => n.setFilter(filter.copyWith(from: v)),
              end: false),
          dateField(
              'Đến ngày', filter.to, (v) => n.setFilter(filter.copyWith(to: v)),
              end: true),
          SizedBox(
            width: 180,
            child: DropdownButtonFormField<String?>(
              key: ValueKey('room-${filter.roomId}'),
              initialValue: filter.roomId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Phòng'),
              items: [
                const DropdownMenuItem(
                    value: null, child: Text('Tất cả phòng')),
                for (final r in rooms)
                  DropdownMenuItem(
                      value: r.id, child: Text('Phòng ${r.number}')),
              ],
              onChanged: (v) => n.setFilter(filter.copyWith(roomId: v)),
            ),
          ),
          SizedBox(
            width: 180,
            child: DropdownButtonFormField<String?>(
              key: ValueKey('role-${filter.actorRole}'),
              initialValue: filter.actorRole,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Vai trò'),
              items: const [
                DropdownMenuItem(value: null, child: Text('Tất cả vai trò')),
                DropdownMenuItem(value: 'MANAGER', child: Text('Quản lý')),
                DropdownMenuItem(value: 'RECEPTIONIST', child: Text('Lễ tân')),
                DropdownMenuItem(value: 'STAFF', child: Text('Nhân viên')),
                DropdownMenuItem(value: 'SYSTEM', child: Text('Hệ thống')),
              ],
              onChanged: (v) => n.setFilter(filter.copyWith(actorRole: v)),
            ),
          ),
          if (filter.isActive)
            TextButton(
                onPressed: () => n.setFilter(const AuditFilter()),
                child: const Text('Xóa lọc')),
        ],
      ),
    );
  }
}

/// Nhãn BE → từ ngữ thống nhất của app (vd BE ghi "bình thường" cho trục bảo trì, app dùng "Đang phục vụ").
String _pretty(String label) {
  const map = {
    'bình thường': 'đang phục vụ',
    'nv buồng phòng–bảo trì': 'nhân viên'
  };
  final l = map[label.toLowerCase()] ?? label;
  return l.isEmpty ? l : l[0].toUpperCase() + l.substring(1);
}

/// Màu chip trước/sau theo nhãn trạng thái — cùng bảng màu với ô phòng.
StatusTone _toneFor(String label) {
  switch (label.toLowerCase()) {
    case 'đang ở':
      return StatusTone.occupied;
    case 'chờ nhận':
    case 'đã giao':
      return StatusTone.gold;
    case 'cần dọn':
      return StatusTone.dirty;
    case 'đang dọn':
    case 'đang làm':
    case 'đang sửa':
      return StatusTone.cleaning;
    case 'chờ kiểm tra':
    case 'chờ xác nhận':
      return StatusTone.inspect;
    case 'sạch':
    case 'hoạt động':
    case 'hoàn tất':
      return StatusTone.ready;
    case 'ngừng phục vụ':
      return StatusTone.oos;
    case 'bị khóa':
    case 'quá hạn':
      return StatusTone.danger;
    default:
      return StatusTone.neutral;
  }
}

/// Một dòng nhật ký: giờ, người, hành động, đối tượng, chip trước/sau.
class _EntryRow extends StatelessWidget {
  final AuditEntry entry;
  final bool wide;
  const _EntryRow({required this.entry, required this.wide});

  /// Màn rộng một hàng, hẹp xếp cột. Hệ thống không kèm vai trò trong ngoặc.
  @override
  Widget build(BuildContext context) {
    final time = Text(DateFormat('HH:mm').format(entry.occurredAt.toLocal()),
        style: const TextStyle(
            color: AppColors.muted,
            fontFeatures: [FontFeature.tabularFigures()]));
    final who = Text.rich(TextSpan(children: [
      TextSpan(
          text: entry.isSystem ? 'Hệ thống' : entry.actorName,
          style: const TextStyle(fontWeight: FontWeight.w700)),
      if (!entry.isSystem)
        TextSpan(
            text: ' (${_pretty(entry.actorRoleLabel).toLowerCase()})',
            style: AppText.caption.copyWith(color: AppColors.muted)),
    ]));
    final changes = Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final c in entry.changes) ...[
          MetaText(c.fieldLabel),
          StatusChip(_pretty(c.beforeLabel),
              tone: _toneFor(_pretty(c.beforeLabel)), dense: true),
          const Icon(Icons.arrow_forward, size: 14, color: AppColors.iconMuted),
          StatusChip(_pretty(c.afterLabel),
              tone: _toneFor(_pretty(c.afterLabel)), dense: true),
          const SizedBox(width: 8),
        ],
      ],
    );

    if (wide) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            SizedBox(width: 64, child: time),
            SizedBox(width: 240, child: who),
            SizedBox(width: 200, child: Text(entry.actionLabel)),
            SizedBox(
                width: 120,
                child: Text(entry.entityLabel ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w600))),
            Expanded(child: changes),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            time,
            const SizedBox(width: 10),
            Expanded(child: who)
          ]),
          const SizedBox(height: 4),
          Text(
              '${entry.actionLabel}${entry.entityLabel != null ? ' · ${entry.entityLabel}' : ''}',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          if (entry.changes.isNotEmpty) ...[const SizedBox(height: 6), changes],
        ],
      ),
    );
  }
}
