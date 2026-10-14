import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/theme/app_theme.dart';

/// Xử lý lỗi API nhất quán trên toàn app.
/// - VERSION_CONFLICT: tự tải lại bản mới nhất rồi báo (câu chữ realtime-sync E-002).
/// - Các lỗi khác: hiện nguyên câu BE trả về (đã theo mẫu "chuyện gì + cách xử lý").
void handleApiError(
  BuildContext context,
  ApiException e, {
  VoidCallback? onReload,
}) {
  if (!context.mounted) return;
  if (e.isVersionConflict) {
    onReload?.call();
    showAppSnack(context,
        'Dữ liệu vừa được người khác cập nhật — đã tải lại bản mới nhất.',
        tone: SnackTone.warn);
  } else {
    showAppSnack(context, e.message, tone: SnackTone.error);
  }
}

/// Tông snack: thành công, thông tin, cảnh báo, lỗi. Lỗi hiện lâu hơn một giây.
enum SnackTone { success, info, warn, error }

/// Thông báo ngắn ở cuối màn hình — thành công nói cụ thể việc vừa làm ("Đã nhận phòng 105 cho …").
void showAppSnack(BuildContext context, String message,
    {SnackTone tone = SnackTone.success, SnackBarAction? action}) {
  if (!context.mounted) return;
  final (Color bg, IconData icon) = switch (tone) {
    SnackTone.success => (AppColors.espresso, Icons.check_circle_outline),
    SnackTone.info => (AppColors.espresso, Icons.info_outline),
    SnackTone.warn => (AppColors.dirty, Icons.sync_problem_rounded),
    SnackTone.error => (AppColors.danger, Icons.error_outline),
  };
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: bg,
        // Web: thông báo gọn ở giữa đáy màn hình thay vì trải hết chiều ngang.
        width: MediaQuery.sizeOf(context).width >= 900 ? 520 : null,
        duration: Duration(seconds: tone == SnackTone.error ? 5 : 4),
        action: action,
        content: Row(
          children: [
            Icon(icon,
                color: tone == SnackTone.success
                    ? AppColors.goldLight
                    : Colors.white,
                size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
}
