import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

/// Nền ảnh trình chiếu màn đăng nhập — tự đọc mọi ảnh trong `assets/images/login/` (thả ảnh vào là chạy).
/// - Ảnh chuyển mờ dần, mỗi ảnh phóng chậm nhẹ như clip quảng cáo; lớp phủ tối giữ chữ vàng/trắng đọc rõ.
/// - Thư mục trống / không đọc được → chỉ còn nền espresso như cũ.
/// - Máy bật "giảm chuyển động" → đứng yên ở ảnh đầu, không tự chuyển.
class LoginSlideshow extends StatefulWidget {
  final Widget child;
  final Alignment dotsAlignment;
  final EdgeInsets dotsPadding;
  final Duration interval;

  const LoginSlideshow({
    super.key,
    required this.child,
    this.dotsAlignment = Alignment.bottomRight,
    this.dotsPadding = const EdgeInsets.all(16),
    this.interval = const Duration(seconds: 5),
  });

  static const _dir = 'assets/images/login/';
  static const _exts = ['.jpg', '.jpeg', '.png', '.webp'];

  @override
  State<LoginSlideshow> createState() => _LoginSlideshowState();
}

class _LoginSlideshowState extends State<LoginSlideshow> {
  List<String> _images = const [];
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Đợi sau frame đầu: lần thứ hai trở đi danh sách ảnh lấy từ cache và trả về đồng bộ,
    // nếu gọi thẳng ở đây thì precacheImage chạy trong initState và lỗi (đổi khổ màn hình là mất ảnh).
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final images = manifest
          .listAssets()
          .where((p) =>
              p.startsWith(LoginSlideshow._dir) &&
              LoginSlideshow._exts.any(p.toLowerCase().endsWith))
          .toList()
        ..sort();
      if (!mounted || images.isEmpty) return;
      for (final p in images) {
        precacheImage(AssetImage(p), context);
      }
      setState(() => _images = images);
      if (images.length > 1) {
        _timer = Timer.periodic(widget.interval, (_) => _next());
      }
    } catch (_) {
      // Không đọc được danh sách ảnh → giữ nền trơn, màn đăng nhập vẫn dùng bình thường.
    }
  }

  void _next() {
    if (!mounted || MediaQuery.disableAnimationsOf(context)) return;
    setState(() => _index = (_index + 1) % _images.length);
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    return Stack(
      fit: StackFit.passthrough,
      children: [
        const Positioned.fill(child: ColoredBox(color: AppColors.espresso)),
        if (_images.isNotEmpty) ...[
          // Cắt theo khung: ảnh đang phóng to không được tràn qua vạch vàng sang phần form.
          Positioned.fill(
            child: ClipRect(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 900),
                layoutBuilder: (current, previous) => Stack(
                    fit: StackFit.expand,
                    children: [...previous, if (current != null) current]),
                child: _Slide(
                    key: ValueKey(_index),
                    path: _images[_index],
                    zoom: !still,
                    duration: widget.interval),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.espressoDeep.withValues(alpha: .55),
                    AppColors.espressoDeep.withValues(alpha: .85),
                  ],
                ),
              ),
            ),
          ),
        ],
        widget.child,
        if (_images.length > 1)
          Positioned.fill(
            child: Padding(
              padding: widget.dotsPadding,
              child: Align(
                alignment: widget.dotsAlignment,
                child: ExcludeSemantics(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < _images.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.only(left: 6),
                          width: i == _index ? 18 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: i == _index
                                ? AppColors.gold
                                : Colors.white.withValues(alpha: .45),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Một ảnh nền, phóng chậm 1 → 1.08 trong suốt thời gian hiển thị.
class _Slide extends StatelessWidget {
  final String path;
  final bool zoom;
  final Duration duration;

  const _Slide(
      {super.key,
      required this.path,
      required this.zoom,
      required this.duration});

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(path,
        fit: BoxFit.cover,
        excludeFromSemantics: true, // ảnh trang trí
        errorBuilder: (_, __, ___) => const SizedBox.shrink());
    if (!zoom) return image;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1, end: 1.08),
      duration: duration + const Duration(seconds: 1),
      builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
      child: image,
    );
  }
}
