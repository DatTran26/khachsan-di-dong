import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/theme/app_theme.dart';

/// Hộp thoại xác nhận dùng chung.
/// Quy ước câu chữ: tiêu đề là câu hỏi cụ thể ("Trả phòng 204?"), [message] nói rõ hệ quả,
/// nút ghi đúng hành động ("Trả phòng" / "Để sau") — không dùng "OK" / "Bạn có chắc?".
///
/// Trả `true` nếu người dùng xác nhận và [onConfirm] (nếu có) chạy xong; lỗi của [onConfirm] hiện ngay trong hộp.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Xác nhận',
  String cancelLabel = 'Để sau',
  bool destructive = false,
  Future<void> Function()? onConfirm,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _ConfirmDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      destructive: destructive,
      onConfirm: onConfirm,
    ),
  );
  return result ?? false;
}

/// Khung hộp thoại có viền vàng phía trên — dùng cho mọi hộp thoại trong app.
class GoldDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget> actions;
  final double width;

  const GoldDialog(
      {super.key,
      required this.title,
      required this.content,
      required this.actions,
      this.width = 460});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width),
        child: Container(
          decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.gold, width: 4))),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title,
                  style: AppText.titleLg.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Flexible(child: SingleChildScrollView(child: content)),
              const SizedBox(height: 20),
              Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 10,
                  runSpacing: 8,
                  children: actions),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfirmDialog extends StatefulWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool destructive;
  final Future<void> Function()? onConfirm;

  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.destructive,
    this.onConfirm,
  });

  @override
  State<_ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<_ConfirmDialog> {
  bool _loading = false;
  String? _error;

  Future<void> _handleConfirm() async {
    if (widget.onConfirm == null) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.onConfirm!();
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e is ApiException ? e.message : e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GoldDialog(
      title: widget.title,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.message,
              style:
                  AppText.body.copyWith(color: AppColors.muted, height: 1.55)),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.dangerBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.dangerBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.danger, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_error!,
                        style:
                            AppText.meta.copyWith(color: AppColors.dangerText)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(false),
          child: Text(widget.cancelLabel),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _handleConfirm,
          style: widget.destructive
              ? ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  foregroundColor: Colors.white)
              : null,
          child: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
