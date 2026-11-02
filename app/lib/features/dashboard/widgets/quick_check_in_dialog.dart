import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/room.dart';
import '../../../shared/utils/error_handler.dart';
import '../../../shared/widgets/ui.dart';
import '../../rooms/providers/rooms_provider.dart';
import '../../stays/providers/stays_provider.dart';

/// Hộp thoại nhận phòng nhanh 3 giây (FR-check-in-001 cải tiến).
/// Cho phép lễ tân nhập tên khách và chọn nhanh thời lượng (1h, 2h, 4h, qua đêm 12h trưa)
/// mà không cần mở toàn bộ bảng chi tiết phòng.
Future<bool?> showQuickCheckInDialog(BuildContext context,
    {required Room room}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _QuickCheckInDialog(room: room),
  );
}

class _QuickCheckInDialog extends ConsumerStatefulWidget {
  final Room room;

  const _QuickCheckInDialog({required this.room});

  @override
  ConsumerState<_QuickCheckInDialog> createState() =>
      _QuickCheckInDialogState();
}

class _QuickCheckInDialogState extends ConsumerState<_QuickCheckInDialog> {
  final _formKey = GlobalKey<FormState>();
  final _guestCtrl = TextEditingController();
  int _guestCount = 1;
  DateTime? _expectedCheckout;
  String? _selectedDurationLabel;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Mặc định chọn qua đêm (12:00 trưa ngày mai)
    _selectOvernight();
  }

  @override
  void dispose() {
    _guestCtrl.dispose();
    super.dispose();
  }

  void _selectHours(int hours) {
    final target = DateTime.now().add(Duration(hours: hours));
    setState(() {
      _selectedDurationLabel = '${hours}h';
      _expectedCheckout = target;
    });
  }

  void _selectOvernight() {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    setState(() {
      _selectedDurationLabel = 'overnight';
      _expectedCheckout = DateTime(
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
        12,
        0,
      );
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });

    final guestName = _guestCtrl.text.trim();
    try {
      await ref.read(roomsProvider.notifier).checkIn(
            roomId: widget.room.id,
            version: widget.room.version,
            guestName: guestName,
            guestCount: _guestCount,
            expectedCheckout: _expectedCheckout,
          );
      ref.read(staysProvider.notifier).load();
      if (!mounted) return;
      Navigator.of(context).pop(true);
      showAppSnack(
        context,
        'Đã nhận phòng ${widget.room.number} cho $guestName.',
        tone: SnackTone.info,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = 'Không thể nhận phòng. Vui lòng thử lại.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('HH:mm · dd/MM');

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      actionsPadding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.solidReady.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.flash_on_rounded,
              color: AppColors.solidReady,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nhận nhanh phòng ${widget.room.number}',
                  style: AppText.title.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  widget.room.roomType.name,
                  style: AppText.caption.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null) ...[
                AppBanner(tone: BannerTone.error, message: _error!),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _guestCtrl,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Tên khách hàng *',
                  hintText: 'Ví dụ: Nguyễn Văn A',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Vui lòng nhập tên khách.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Text('Số khách:', style: AppText.meta),
                  const SizedBox(width: 8),
                  for (final count in [1, 2, 3, 4])
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text('$count'),
                        selected: _guestCount == count,
                        onSelected: (sel) {
                          if (sel) setState(() => _guestCount = count);
                        },
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              const Text('Thời lượng dự kiến:', style: AppText.meta),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _durationChip('1 Giờ', '1h', () => _selectHours(1)),
                  _durationChip('2 Giờ', '2h', () => _selectHours(2)),
                  _durationChip('4 Giờ', '4h', () => _selectHours(4)),
                  _durationChip(
                      'Qua đêm (12h trưa)', 'overnight', _selectOvernight),
                ],
              ),
              if (_expectedCheckout != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSunken,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 14, color: AppColors.muted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Dự kiến trả: ${fmt.format(_expectedCheckout!.toLocal())}',
                          style: AppText.micro.copyWith(
                            color: AppColors.text,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(false),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _submitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.espresso,
          ),
          child: _submitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Xác nhận nhận phòng',
                  style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  Widget _durationChip(String label, String id, VoidCallback onSelect) {
    final isSelected = _selectedDurationLabel == id;
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.goldTint : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? AppColors.gold : AppColors.borderStrong,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppText.caption.copyWith(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.goldText : AppColors.text,
          ),
        ),
      ),
    );
  }
}
