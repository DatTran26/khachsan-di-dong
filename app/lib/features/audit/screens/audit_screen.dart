import 'package:flutter/material.dart';

/// Màn nhật ký thay đổi — chỉ dành cho quản lý.
/// Backend API (GET /api/audit-logs) chưa sẵn sàng (task 93 chưa hoàn tất).
class AuditScreen extends StatelessWidget {
  const AuditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_rounded, size: 72, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Nhật ký thay đổi',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Tính năng đang được phát triển.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              'Vui lòng quay lại sau.',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
