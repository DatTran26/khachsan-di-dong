import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/room.dart';
import '../../../models/user.dart';
import '../../../shared/utils/error_handler.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/ui.dart';
import '../../auth/providers/auth_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../../maintenance/widgets/report_issue_dialog.dart';
import '../../stays/providers/stays_provider.dart';
import '../providers/rooms_provider.dart';
import '../screens/room_form_screen.dart';

/// Mở chi tiết phòng dạng tấm trượt từ dưới lên (mobile, hoặc khi bấm ô phòng trên Tổng quan).
Future<void> showRoomDetailSheet(BuildContext context, String roomId) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: 560),
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: .75,
      maxChildSize: .95,
      builder: (ctx, controller) => RoomDetailPanel(
        roomId: roomId,
        scrollController: controller,
        onClose: () => Navigator.pop(ctx),
      ),
    ),
  );
}

/// Lý do phòng chưa nhận khách được — cùng câu chữ với BE (check-in-out error matrix).
String? checkInBlockReason(Room r) {
  if (r.occupancy == OccupancyStatus.occupied) {
    return 'Phòng đang có khách — không thể nhận.';
  }
  if (r.service == ServiceStatus.outOfService) {
    return 'Phòng đang ngừng phục vụ — không thể nhận.';
  }
  if (r.cleaning != CleaningStatus.clean) {
    return 'Phòng chưa dọn xong (${r.cleaning.label}) — không thể nhận.';
  }
  return null;
}

/// Chi tiết một phòng + thao tác theo vai trò (bám đúng quyền API):
/// - Lễ tân: nhận phòng / trả phòng.
/// - Quản lý, lễ tân: đặt / mở lại phục vụ.
/// - Mọi vai trò: báo hỏng.
/// - Quản lý: sửa / xóa phòng.
class RoomDetailPanel extends ConsumerWidget {
  final String roomId;
  final VoidCallback? onClose;
  final ScrollController? scrollController;

  const RoomDetailPanel(
      {super.key, required this.roomId, this.onClose, this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final room = ref.watch(roomsProvider.select((s) => s.byId(roomId)));
    final role = ref.watch(authProvider.select((s) => s.user?.role));
    final online = ref.watch(isOnlineProvider);

    if (room == null) {
      return const EmptyState(
        icon: Icons.meeting_room_outlined,
        title: 'Phòng này không còn trong danh mục.',
        message:
            'Có thể quản lý vừa xóa phòng. Chọn phòng khác trong danh sách.',
      );
    }

    final isReceptionist = role == UserRole.receptionist;
    final isManager = role == UserRole.manager;
    final canToggleService = isManager || isReceptionist;
    final occupied = room.occupancy == OccupancyStatus.occupied;
    final oos = room.service == ServiceStatus.outOfService;

    return ListView(
      controller: scrollController,
      padding: EdgeInsets.zero,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.divider))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Phòng ${room.number}',
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w700)),
                  ),
                  if (isManager)
                    IconButton(
                      tooltip: 'Sửa phòng',
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => RoomFormScreen(room: room)),
                      ),
                    ),
                  if (onClose != null)
                    IconButton(
                        tooltip: 'Đóng',
                        icon: const Icon(Icons.close),
                        onPressed: onClose),
                ],
              ),
              MetaText('${room.roomType.name} · Tầng ${room.floor}'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  StatusChip(room.summaryLabel, tone: room.summaryTone),
                  StatusChip('Lưu trú: ${room.occupancy.label}',
                      tone: room.occupancy.tone),
                  StatusChip('Vệ sinh: ${room.cleaning.label}',
                      tone: room.cleaning.tone),
                  StatusChip('Bảo trì: ${room.service.label}',
                      tone: room.service.tone),
                ],
              ),
              const SizedBox(height: 8),
              MetaText(
                  'Cập nhật lúc ${DateFormat('HH:mm dd/MM').format(room.updatedAt.toLocal())}'),
            ],
          ),
        ),
        // Nhân viên không xem được chỉ số dashboard (403) → không hiện mục quá hạn ở đây.
        if (isManager || isReceptionist)
          _OverdueSection(roomId: room.id, isManager: isManager),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isReceptionist && room.isReady)
                _CheckInForm(room: room, online: online),
              if (isReceptionist && !room.isReady && !occupied)
                AppBanner(
                    tone: BannerTone.info,
                    message: checkInBlockReason(room) ?? ''),
              if (isReceptionist && occupied)
                _CheckOutBlock(room: room, online: online),
              if (!isReceptionist && room.isReady)
                const AppBanner(
                  tone: BannerTone.info,
                  message: 'Phòng sẵn sàng. Lễ tân nhận khách tại quầy.',
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: online
                    ? () => showReportIssueDialog(context, roomId: room.id)
                    : null,
                icon: const Icon(Icons.report_problem_outlined, size: 18),
                label: const Text('Báo hỏng'),
              ),
              if (canToggleService && !oos)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: Color(0xFFF2C4C6)),
                  ),
                  onPressed: online
                      ? () => _placeOutOfService(context, ref, room)
                      : null,
                  icon: const Icon(Icons.block, size: 18),
                  label: const Text('Đặt ngừng phục vụ'),
                ),
              if (canToggleService && oos)
                OutlinedButton.icon(
                  onPressed:
                      online ? () => _backInService(context, ref, room) : null,
                  icon: const Icon(Icons.play_circle_outline, size: 18),
                  label: const Text('Mở lại phục vụ'),
                ),
              if (isManager)
                TextButton.icon(
                  onPressed: () => context.go('/nhat-ky?phong=${room.id}'),
                  icon: const Icon(Icons.history_rounded, size: 18),
                  label: const Text('Nhật ký phòng'),
                ),
              if (isManager)
                TextButton.icon(
                  style:
                      TextButton.styleFrom(foregroundColor: AppColors.danger),
                  onPressed:
                      online ? () => _deleteRoom(context, ref, room) : null,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Xóa phòng'),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _placeOutOfService(
      BuildContext context, WidgetRef ref, Room room) async {
    final reason = TextEditingController();
    final occupied = room.occupancy == OccupancyStatus.occupied;
    String? error;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => GoldDialog(
          title: 'Đặt ngừng phục vụ phòng ${room.number}?',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                occupied
                    ? 'Phòng đang có khách — khách vẫn ở hết kỳ. Sau khi trả phòng, phòng sẽ không được nhận khách mới cho tới khi mở lại.'
                    : 'Lễ tân sẽ không nhận khách vào phòng này cho tới khi mở lại phục vụ.',
                style: const TextStyle(color: AppColors.muted, height: 1.5),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: reason,
                maxLength: 200,
                autofocus: true,
                decoration: InputDecoration(
                    labelText: 'Lý do *',
                    errorText: error,
                    hintText: 'Ví dụ: sơn lại tường'),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Để sau')),
            ElevatedButton(
              onPressed: () {
                if (reason.text.trim().isEmpty) {
                  setState(() => error = 'Vui lòng nhập lý do ngừng phục vụ.');
                  return;
                }
                Navigator.pop(ctx, true);
              },
              child: const Text('Đặt ngừng phục vụ'),
            ),
          ],
        ),
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await ref.read(roomsProvider.notifier).setOutOfService(
            roomId: room.id,
            version: room.version,
            reason: reason.text.trim(),
            confirmOccupied: occupied,
          );
      if (context.mounted) {
        showAppSnack(context, 'Đã đặt ngừng phục vụ phòng ${room.number}.');
      }
    } on ApiException catch (e) {
      if (context.mounted) {
        handleApiError(context, e,
            onReload: () => ref.read(roomsProvider.notifier).load());
      }
    }
  }

  Future<void> _backInService(
      BuildContext context, WidgetRef ref, Room room) async {
    await showConfirmDialog(
      context,
      title: 'Mở lại phục vụ phòng ${room.number}?',
      message:
          'Phòng sẽ được nhận khách trở lại khi đã sạch. Không mở được nếu phòng còn việc sửa đang mở.',
      confirmLabel: 'Mở lại phục vụ',
      onConfirm: () async {
        await ref
            .read(roomsProvider.notifier)
            .backInService(roomId: room.id, version: room.version);
        if (context.mounted) {
          showAppSnack(context, 'Đã mở lại phục vụ phòng ${room.number}.');
        }
      },
    );
  }

  Future<void> _deleteRoom(
      BuildContext context, WidgetRef ref, Room room) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Xóa phòng ${room.number}?',
      message:
          'Chỉ xóa được phòng chưa có lịch sử hoạt động. Phòng đã từng có khách, dọn hoặc sửa thì hãy đặt Ngừng phục vụ. Không thể hoàn tác.',
      confirmLabel: 'Xóa phòng',
      destructive: true,
      onConfirm: () => ref
          .read(roomsProvider.notifier)
          .deleteRoom(roomId: room.id, version: room.version),
    );
    if (ok && context.mounted) {
      showAppSnack(context, 'Đã xóa phòng ${room.number}.');
      onClose?.call();
    }
  }
}

class _CheckInForm extends ConsumerStatefulWidget {
  final Room room;
  final bool online;
  const _CheckInForm({required this.room, required this.online});

  @override
  ConsumerState<_CheckInForm> createState() => _CheckInFormState();
}

class _CheckInFormState extends ConsumerState<_CheckInForm> {
  final _formKey = GlobalKey<FormState>();
  final _guest = TextEditingController();
  final _count = TextEditingController(text: '1');
  final _note = TextEditingController();
  DateTime? _expected;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _guest.dispose();
    _count.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickExpected() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _expected ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Ngày dự kiến trả phòng',
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
      helpText: 'Giờ dự kiến trả phòng',
    );
    if (!mounted) return;
    setState(() {
      _expected = DateTime(
          date.year, date.month, date.day, time?.hour ?? 12, time?.minute ?? 0);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final name = _guest.text.trim();
    try {
      await ref.read(roomsProvider.notifier).checkIn(
            roomId: widget.room.id,
            version: widget.room.version,
            guestName: name,
            guestCount: int.parse(_count.text.trim()),
            note: _note.text.trim(),
            expectedCheckout: _expected,
          );
      ref.read(staysProvider.notifier).load();
      if (!mounted) return;
      showAppSnack(context, 'Đã nhận phòng ${widget.room.number} cho $name.');
      _guest.clear();
      _note.clear();
      setState(() {
        _saving = false;
        _expected = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.isVersionConflict) ref.read(roomsProvider.notifier).load();
      setState(() {
        _saving = false;
        _error = e.isVersionConflict
            ? 'Dữ liệu vừa được người khác cập nhật — đã tải lại bản mới nhất.'
            : e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Nhận phòng',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          if (_error != null) ...[
            AppBanner(tone: BannerTone.error, message: _error!),
            const SizedBox(height: 12),
          ],
          TextFormField(
            controller: _guest,
            maxLength: 100,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
                labelText: 'Tên khách *', counterText: ''),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Vui lòng nhập tên khách.'
                : null,
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 110,
                child: TextFormField(
                  controller: _count,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'Số người *'),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 1) return 'Từ 1 trở lên.';
                    if (n > 20) return 'Tối đa 20.';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: _pickExpected,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Dự kiến trả',
                      suffixIcon: _expected == null
                          ? const Icon(Icons.event_outlined)
                          : IconButton(
                              tooltip: 'Bỏ ngày dự kiến',
                              icon: const Icon(Icons.close),
                              onPressed: () => setState(() => _expected = null),
                            ),
                    ),
                    child: Text(
                      _expected == null
                          ? 'Chưa chọn'
                          : DateFormat('HH:mm · dd/MM').format(_expected!),
                      style: TextStyle(
                          color: _expected == null
                              ? AppColors.muted
                              : AppColors.text),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _note,
            maxLines: 2,
            maxLength: 500,
            decoration: const InputDecoration(
                labelText: 'Ghi chú', hintText: 'Ví dụ: khách cần thêm gối'),
          ),
          const MetaText(
              'Chỉ nhận được phòng Trống, Sạch và Đang phục vụ. Dữ liệu khách là giả lập.'),
          const SizedBox(height: 14),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: (_saving || !widget.online) ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text('Nhận phòng ${widget.room.number}'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckOutBlock extends ConsumerWidget {
  final Room room;
  final bool online;
  const _CheckOutBlock({required this.room, required this.online});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stays = ref.watch(staysProvider).stays;
    final stay = stays.where((s) => s.room.id == room.id).firstOrNull;
    final fmt = DateFormat('HH:mm dd/MM');
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Khách đang ở',
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(stay?.guestName ?? '—',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          if (stay != null) ...[
            MetaText(
                '${stay.guestCount} người · nhận lúc ${fmt.format(stay.checkedInAt.toLocal())}'),
            if (stay.expectedCheckout != null)
              MetaText(
                  'Dự kiến trả ${fmt.format(stay.expectedCheckout!.toLocal())}'),
          ],
          const SizedBox(height: 14),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: online
                  ? () => confirmCheckOut(context, ref, room,
                      guestName: stay?.guestName)
                  : null,
              child: Text('Trả phòng ${room.number}'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Xác nhận trả phòng — dùng chung cho màn Phòng và Lưu trú.
Future<void> confirmCheckOut(BuildContext context, WidgetRef ref, Room room,
    {String? guestName}) async {
  final ok = await showConfirmDialog(
    context,
    title: 'Trả phòng ${room.number}?',
    message: '${guestName != null ? 'Khách: $guestName. ' : ''}'
        'Phòng sẽ chuyển sang Cần dọn và hệ thống tự tạo việc dọn cho buồng phòng.',
    confirmLabel: 'Trả phòng',
    onConfirm: () async {
      await ref
          .read(roomsProvider.notifier)
          .checkOut(roomId: room.id, version: room.version);
      ref.read(staysProvider.notifier).load();
    },
  );
  if (ok && context.mounted) {
    showAppSnack(context, 'Đã trả phòng ${room.number}. Việc dọn đã được tạo.');
  }
}

/// Việc quá hạn của phòng (FR-room-dashboard-006) — mở đúng màn việc để xử lý.
/// Lễ tân không có màn dọn phòng → chỉ thấy nút mở việc sửa.
class _OverdueSection extends ConsumerWidget {
  final String roomId;
  final bool isManager;
  const _OverdueSection({required this.roomId, required this.isManager});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(dashboardSummaryProvider
        .select((s) => s.summary.overdueTasksOf(roomId)));
    if (tasks.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
        decoration: BoxDecoration(
          color: AppColors.dangerBg,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: const Color(0xFFF2C4C6)),
        ),
        child: Column(
          children: [
            for (final t in tasks)
              Row(
                children: [
                  const OverdueBadge(),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                        t.isHousekeeping
                            ? 'Việc dọn phòng quá hạn'
                            : 'Việc sửa quá hạn',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                  if (!t.isHousekeeping || isManager)
                    TextButton(
                      onPressed: () => context.go(
                          '${t.isHousekeeping ? '/don-phong' : '/bao-tri'}?viec=${t.taskId}'),
                      child: const Text('Mở việc'),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
