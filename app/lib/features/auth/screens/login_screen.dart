import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';
import '../../../core/router/nav.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/ui.dart';
import '../providers/auth_provider.dart';
import '../widgets/login_slideshow.dart';

/// Đăng nhập. Web: nửa trái espresso giới thiệu, nửa phải là form. Mobile: đầu trang espresso + form.
/// Nền phần giới thiệu là ảnh trình chiếu từ `assets/images/login/` (xem [LoginSlideshow]).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  /// Tạo state form đăng nhập.
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

/// SĐT, mật khẩu, cờ ẩn ký tự và lỗi đăng nhập.
class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  String? _error;

  /// Giải phóng controller SĐT và mật khẩu.
  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  /// [AuthNotifier.login]. Thành công thì vào đổi mật khẩu nếu còn MK tạm, không thì [homeFor].
  /// [ApiException] hiện trên form, không snack.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _error = null);
    try {
      await ref
          .read(authProvider.notifier)
          .login(_phoneCtrl.text.trim(), _passwordCtrl.text);
      if (!mounted) return;
      // Báo trình duyệt/hệ điều hành lưu số điện thoại + mật khẩu vừa dùng.
      TextInput.finishAutofillContext();
      final user = ref.read(authProvider).user!;
      context
          .go(user.mustChangePassword ? '/doi-mat-khau' : homeFor(user.role));
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    }
  }

  /// Form giữa màn. Rộng từ 900px thì có [_BrandPanel]. Hiện [AuthNotifier.revokedMessage] nếu phiên vừa bị thu.
  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;
    final revokedMsg = ref.read(authProvider.notifier).revokedMessage;
    final wide = MediaQuery.sizeOf(context).width >= 900;

    final form = Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: AutofillGroup(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Đăng nhập',
                style: AppText.displaySm.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('Dùng số điện thoại quản lý đã cấp cho bạn.',
                style: AppText.body.copyWith(color: AppColors.muted)),
            const SizedBox(height: 20),
            if (revokedMsg != null && _error == null) ...[
              AppBanner(
                  tone: BannerTone.warn,
                  icon: Icons.logout_rounded,
                  message: revokedMsg),
              const SizedBox(height: 16),
            ],
            if (_error != null) ...[
              AppBanner(tone: BannerTone.error, message: _error!),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.telephoneNumber],
              decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  prefixIcon: Icon(Icons.phone_outlined)),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Vui lòng nhập số điện thoại.';
                }
                if (!RegExp(r'^0\d{9}$').hasMatch(v.trim())) {
                  return 'Số điện thoại cần gồm 10 chữ số và bắt đầu bằng 0.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscure,
              autofillHints: const [AutofillHints.password],
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'Mật khẩu',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  tooltip: _obscure ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
                  icon: Icon(_obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Vui lòng nhập mật khẩu.' : null,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, semanticsLabel: 'Đang đăng nhập'))
                    : const Text('Đăng nhập', style: AppText.bodyLg),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Quên mật khẩu? Liên hệ quản lý để được cấp mật khẩu tạm.',
              textAlign: TextAlign.center,
              style: AppText.overline.copyWith(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );

    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            const Expanded(flex: 9, child: _BrandPanel()),
            Expanded(
              flex: 11,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child:
                        AppCard(padding: const EdgeInsets.all(36), child: form),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: const BoxDecoration(
                border:
                    Border(bottom: BorderSide(color: AppColors.gold, width: 3)),
              ),
              child: LoginSlideshow(
                dotsAlignment: Alignment.topRight,
                dotsPadding: EdgeInsets.fromLTRB(
                    24, MediaQuery.paddingOf(context).top + 16, 24, 0),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      24, MediaQuery.paddingOf(context).top + 32, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const BrandMark(size: 40),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text('Khách Sạn Di Động',
                              style: AppText.titleLg.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ]),
                      // Chừa khoảng cho ảnh trình chiếu lộ ra phía sau.
                      const SizedBox(height: 72),
                      Text('Một trạng thái phòng cho cả khách sạn.',
                          style: AppText.headlineLg.copyWith(
                              color: AppColors.goldLight,
                              fontWeight: FontWeight.w800,
                              height: 1.25)),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: form),
          ],
        ),
      ),
    );
  }
}

/// Cột trái espresso trên màn rộng: khẩu hiệu và ba pill trục phòng.
class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  /// Không có tương tác. Không đọc auth.
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: AppColors.gold, width: 4)),
      ),
      child: LoginSlideshow(
        dotsPadding: const EdgeInsets.all(56),
        child: Padding(
          padding: const EdgeInsets.all(56),
          child: _brandContent(),
        ),
      ),
    );
  }

  Widget _brandContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const BrandMark(size: 44),
          const SizedBox(width: 12),
          Flexible(
            child: Text('Khách Sạn Di Động',
                style: AppText.titleLg.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ]),
        const Spacer(),
        Container(width: 56, height: 2, color: AppColors.gold),
        const SizedBox(height: 20),
        Text(
          'Một trạng thái phòng\ncho cả khách sạn.',
          style: AppText.hero.copyWith(
              color: AppColors.goldLight,
              fontWeight: FontWeight.w800,
              height: 1.2),
        ),
        const SizedBox(height: 20),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Text(
            'Lễ tân, buồng phòng và bảo trì cùng cập nhật một nguồn dữ liệu — thay đổi hiện trên mọi thiết bị trong vài giây.',
            style: AppText.title
                .copyWith(color: AppColors.onDarkSoft, height: 1.6),
          ),
        ),
        const SizedBox(height: 20),
        const Wrap(
            spacing: 10,
            children: [_Pill('Lưu trú'), _Pill('Vệ sinh'), _Pill('Bảo trì')]),
        const Spacer(),
        Text('WPCTeam · Đồ án QLDA CNTT · Dữ liệu giả lập',
            style: AppText.caption.copyWith(color: AppColors.onDarkFaint)),
      ],
    );
  }
}

/// Chip chữ trên nền tối của [_BrandPanel].
class _Pill extends StatelessWidget {
  final String text;
  const _Pill(this.text);

  /// [text] trên nền trắng mờ. Không bấm được.
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
            color: AppColors.onDarkOverlay,
            borderRadius: BorderRadius.circular(14)),
        child: Text(text,
            style: AppText.overline
                .copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
      );
}
