import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';

/// Xử lý lỗi API một cách nhất quán trên toàn app.
/// - VERSION_CONFLICT: snackbar cam với nút "Tải lại"
/// - Các lỗi khác: snackbar đỏ với thông điệp lỗi
void handleApiError(
  BuildContext context,
  ApiException e, {
  VoidCallback? onReload,
}) {
  if (!context.mounted) return;
  if (e.isVersionConflict) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Dữ liệu vừa được người khác cập nhật, vui lòng tải lại.'),
        backgroundColor: Colors.orange[700],
        duration: const Duration(seconds: 6),
        action: onReload != null
            ? SnackBarAction(
                label: 'Tải lại',
                textColor: Colors.white,
                onPressed: onReload,
              )
            : null,
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.message),
        backgroundColor: Colors.red[700],
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
