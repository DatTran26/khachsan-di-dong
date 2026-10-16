import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../shared/utils/error_handler.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/ui.dart';
import '../../rooms/providers/rooms_provider.dart';
import '../providers/maintenance_provider.dart';

/// Báo hỏng — mọi vai trò. Phòng sẽ chuyển Ngừng phục vụ cho tới khi sửa xong.
Future<void> showReportIssueDialog(BuildContext context, {String? roomId}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _ReportIssueDialog(initialRoomId: roomId),
  );
}

class _ReportIssueDialog extends ConsumerStatefulWidget {
  final String? initialRoomId;
  const _ReportIssueDialog({this.initialRoomId});

  @override
  ConsumerState<_ReportIssueDialog> createState() => _ReportIssueDialogState();
}

class _ReportIssueDialogState extends ConsumerState<_ReportIssueDialog> {
  final _formKey = GlobalKey<FormState>();
  final _location = TextEditingController();
  final _desc = TextEditingController();
  String? _roomId;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _roomId = widget.initialRoomId;
  }

  @override
  void dispose() {
    _location.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final room = ref.read(roomsProvider).byId(_roomId!);
    try {
      final warning = await ref.read(maintenanceProvider.notifier).report(
            roomId: _roomId!,
            description: _desc.text.trim(),
            location: _location.text.trim(),
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      showAppSnack(
        context,
        warning ??
            'Đã gửi báo hỏng phòng ${room?.number ?? ''}. Phòng chuyển sang Ngừng phục vụ.',
        tone: warning != null ? SnackTone.warn : SnackTone.success,
      );
    } on ApiException catch (e) {
      setState(() {
        _saving = false;
        _error = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final rooms = ref.watch(roomsProvider).sorted;
    final online = ref.watch(isOnlineProvider);
    return GoldDialog(
      title: 'Báo hỏng',
      width: 480,
      content: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null) ...[
              AppBanner(tone: BannerTone.error, message: _error!),
              const SizedBox(height: 12),
            ],
            if (!online) ...[
              const OfflineActionNote(),
              const SizedBox(height: 12),
            ],
            DropdownButtonFormField<String>(
              initialValue: _roomId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Phòng *'),
              items: [
                for (final r in rooms)
                  DropdownMenuItem(
                      value: r.id,
                      child: Text('Phòng ${r.number} · Tầng ${r.floor}')),
              ],
              onChanged: (v) => setState(() => _roomId = v),
              validator: (v) => v == null ? 'Vui lòng chọn phòng.' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _location,
              maxLength: 100,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                  labelText: 'Vị trí',
                  hintText: 'Ví dụ: Phòng tắm',
                  counterText: ''),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _desc,
              // Mở từ một phòng cụ thể → phòng đã chọn sẵn, gõ mô tả ngay.
              autofocus: widget.initialRoomId != null,
              maxLines: 4,
              maxLength: 500,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Mô tả sự cố *',
                alignLabelWithHint: true,
                helperText:
                    'Ghi rõ cái gì hỏng và ở đâu để thợ mang đúng dụng cụ.',
                helperMaxLines: 2,
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Vui lòng mô tả sự cố.'
                  : null,
            ),
            const SizedBox(height: 12),
            const AppBanner(
              tone: BannerTone.warn,
              icon: Icons.warning_amber_rounded,
              message:
                  'Phòng sẽ chuyển sang Ngừng phục vụ và lễ tân không nhận khách vào phòng này cho tới khi sửa xong.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: _saving ? null : () => Navigator.pop(context),
            child: const Text('Hủy')),
        ElevatedButton(
          onPressed: (_saving || !online) ? null : _submit,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Gửi báo hỏng'),
        ),
      ],
    );
  }
}
