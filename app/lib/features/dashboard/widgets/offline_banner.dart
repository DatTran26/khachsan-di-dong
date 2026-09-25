import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.orange[100],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.orange[800], size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Mất kết nối — dữ liệu có thể chưa mới nhất. Đang thử kết nối lại…',
                  style: TextStyle(color: Colors.orange[900], fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      );
}

class ReconnectedBanner extends StatefulWidget {
  const ReconnectedBanner({super.key});

  @override
  State<ReconnectedBanner> createState() => _ReconnectedBannerState();
}

class _ReconnectedBannerState extends State<ReconnectedBanner> {
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    return Material(
      color: Colors.green[100],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[800], size: 18),
            const SizedBox(width: 8),
            Text(
              'Đã kết nối lại — dữ liệu đã cập nhật.',
              style: TextStyle(color: Colors.green[900], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
