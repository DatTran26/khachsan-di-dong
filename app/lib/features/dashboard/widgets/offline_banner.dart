import 'package:flutter/material.dart';
import '../../../shared/widgets/ui.dart';

/// Banner mất kết nối (realtime-sync E-001): báo trạng thái và cho biết thao tác ghi đang bị khóa.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
        liveRegion: true,
        child: const AppBanner(
          tone: BannerTone.warn,
          icon: Icons.wifi_off_rounded,
          title: 'Mất kết nối — đang thử lại.',
          message:
              'Tạm khóa thao tác để tránh ghi sai. Dữ liệu có thể chưa mới nhất.',
          radius: BorderRadius.zero,
        ),
      );
}
