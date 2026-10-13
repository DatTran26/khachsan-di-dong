import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/room.dart';
import '../../../shared/utils/error_handler.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/ui.dart';
import '../providers/room_types_provider.dart';
import '../providers/rooms_provider.dart';

/// Loại phòng (room-catalog FR-010, wireframe manage-room-type) — chỉ quản lý.
/// Thêm / đổi tên / tắt–bật. Tắt không đổi phòng đang có, chỉ ẩn loại khỏi ô chọn khi thêm/sửa phòng.
class RoomTypesScreen extends ConsumerWidget {
  const RoomTypesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(roomTypesProvider);
    final online = ref.watch(isOnlineProvider);
    final rooms = ref.watch(roomsProvider.select((s) => s.rooms));
    int countOf(RoomType t) => rooms.where((r) => r.roomType.id == t.id).length;

    Widget body;
    if (state.isLoading && state.types.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (state.error != null && state.types.isEmpty) {
      body = ErrorState(
          message: state.error!,
          onRetry: () => ref.read(roomTypesProvider.notifier).load());
    } else if (state.types.isEmpty) {
      body = EmptyState(
        icon: Icons.category_outlined,
        title: 'Chưa có loại phòng nào.',
        message: 'Thêm loại (vd Standard, Deluxe) trước khi thêm phòng.',
        action: ElevatedButton.icon(
          onPressed: online ? () => _showNameDialog(context, ref) : null,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Thêm loại phòng'),
        ),
      );
    } else {
      body = ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          const MetaText(
              'Loại đã tắt không chọn được khi thêm hay sửa phòng; phòng đang thuộc loại đó giữ nguyên.'),
          const SizedBox(height: 12),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < state.types.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  _TypeRow(
                    type: state.types[i],
                    roomCount: countOf(state.types[i]),
                    online: online,
                    onRename: () =>
                        _showNameDialog(context, ref, type: state.types[i]),
                    onToggle: () => _toggle(context, ref, state.types[i]),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loại phòng'),
        actions: [
          if (state.types.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ElevatedButton.icon(
                onPressed: online ? () => _showNameDialog(context, ref) : null,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Thêm loại'),
              ),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: body,
        ),
      ),
    );
  }

  Future<void> _toggle(
      BuildContext context, WidgetRef ref, RoomType type) async {
    final n = ref.read(roomTypesProvider.notifier);
    if (!type.isActive) {
      try {
        await n.setActive(type.id, true);
        if (context.mounted) {
          showAppSnack(context, 'Đã bật lại loại phòng ${type.name}.');
        }
      } on ApiException catch (e) {
        if (context.mounted) handleApiError(context, e);
      }
      return;
    }
    final ok = await showConfirmDialog(
      context,
      title: 'Tắt loại phòng ${type.name}?',
      message:
          'Phòng đang thuộc loại này giữ nguyên. Khi thêm hay sửa phòng sẽ không chọn được loại ${type.name} cho tới khi bật lại.',
      confirmLabel: 'Tắt loại',
      onConfirm: () => n.setActive(type.id, false),
    );
    if (ok && context.mounted) {
      showAppSnack(context, 'Đã tắt loại phòng ${type.name}.');
    }
  }
}

/// Hộp thoại tên loại — thêm mới khi [type] null, còn lại là đổi tên.
Future<void> _showNameDialog(BuildContext context, WidgetRef ref,
    {RoomType? type}) async {
  final saved = await showDialog<String>(
    context: context,
    builder: (_) => _NameDialog(type: type),
  );
  if (saved == null || !context.mounted) return;
  // Đổi tên → danh sách phòng hiện tên loại mới.
  if (type != null) ref.read(roomsProvider.notifier).load();
  showAppSnack(
      context,
      type == null
          ? 'Đã thêm loại phòng $saved.'
          : 'Đã đổi tên loại ${type.name} thành $saved.');
}

class _NameDialog extends ConsumerStatefulWidget {
  final RoomType? type;
  const _NameDialog({this.type});

  @override
  ConsumerState<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends ConsumerState<_NameDialog> {
  late final _name = TextEditingController(text: widget.type?.name);
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Vui lòng nhập tên loại phòng.');
      return;
    }
    if (name == widget.type?.name) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final n = ref.read(roomTypesProvider.notifier);
    try {
      if (widget.type == null) {
        await n.create(name);
      } else {
        await n.rename(widget.type!.id, name);
      }
      if (mounted) Navigator.pop(context, name);
    } on ApiException catch (e) {
      // Trùng tên (E-room-catalog-005) … hiện ngay dưới ô nhập.
      if (mounted) {
        setState(() {
          _saving = false;
          _error = e.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final online = ref.watch(isOnlineProvider);
    return GoldDialog(
      title: widget.type == null ? 'Thêm loại phòng' : 'Đổi tên loại phòng',
      content: TextField(
        controller: _name,
        autofocus: true,
        maxLength: 50,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _save(),
        decoration: InputDecoration(
          labelText: 'Tên loại *',
          hintText: 'Ví dụ: Deluxe hướng biển',
          errorText: _error,
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
        ElevatedButton(
          onPressed: online && !_saving ? _save : null,
          child: Text(_saving ? 'Đang lưu…' : 'Lưu'),
        ),
      ],
    );
  }
}

class _TypeRow extends StatelessWidget {
  final RoomType type;
  final int roomCount;
  final bool online;
  final VoidCallback onRename;
  final VoidCallback onToggle;

  const _TypeRow({
    required this.type,
    required this.roomCount,
    required this.online,
    required this.onRename,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color:
                            type.isActive ? AppColors.text : AppColors.muted)),
                const SizedBox(height: 2),
                MetaText(roomCount == 0 ? 'Chưa có phòng' : '$roomCount phòng'),
              ],
            ),
          ),
          const SizedBox(width: 8),
          type.isActive
              ? const StatusChip('Đang dùng', tone: StatusTone.ready)
              : const StatusChip('Đã ngừng', tone: StatusTone.neutral),
          const SizedBox(width: 4),
          TextButton(
            onPressed: online ? onRename : null,
            child: const Text('Sửa'),
          ),
          TextButton(
            onPressed: online ? onToggle : null,
            child: Text(type.isActive ? 'Tắt' : 'Bật'),
          ),
        ],
      ),
    );
  }
}
