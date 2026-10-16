import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/utils/error_handler.dart';
import '../../../shared/widgets/confirm_dialog.dart';

/// Hiện mật khẩu tạm một lần (tạo tài khoản / mở khóa / đặt lại mật khẩu).
class TempPasswordDialog extends StatelessWidget {
  final String tempPassword;
  final String fullName;
  final String heading;

  const TempPasswordDialog({
    super.key,
    required this.tempPassword,
    required this.fullName,
    this.heading = 'Đã tạo tài khoản cho',
  });

  /// Hiện [tempPassword] chọn được và nút sao chép vào clipboard.
  /// Sao chép chỉ snack local, không gọi API. Đóng dialog không xóa mật khẩu trên server.
  @override
  Widget build(BuildContext context) {
    return GoldDialog(
      title: '$heading $fullName',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Chuyển mật khẩu tạm dưới đây cho nhân viên. Mật khẩu chỉ hiện một lần — lần đăng nhập đầu, nhân viên phải đặt mật khẩu mới.',
            style: TextStyle(color: AppColors.muted, height: 1.5),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderStrong),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    tempPassword,
                    style: AppText.headlineLg.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        color: AppColors.goldText),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: tempPassword));
                    showAppSnack(context, 'Đã sao chép mật khẩu tạm.',
                        tone: SnackTone.info);
                  },
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Sao chép'),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Đã chuyển cho nhân viên'),
        ),
      ],
    );
  }
}
