import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TempPasswordDialog extends StatelessWidget {
  final String tempPassword;
  final String fullName;

  const TempPasswordDialog({
    super.key,
    required this.tempPassword,
    required this.fullName,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Mật khẩu tạm thời'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tài khoản của $fullName đã được tạo.'),
          const SizedBox(height: 8),
          const Text(
            'Giao mật khẩu dưới đây cho nhân viên. Mật khẩu chỉ hiển thị một lần.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    tempPassword,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  tooltip: 'Sao chép',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: tempPassword));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã sao chép mật khẩu.')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Đã giao cho nhân viên'),
        ),
      ],
    );
  }
}
