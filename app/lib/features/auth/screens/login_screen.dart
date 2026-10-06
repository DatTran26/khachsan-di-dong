import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';
import '../../../core/router/nav.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/ui.dart';
import '../providers/auth_provider.dart';

/// Đăng nhập. Web: nửa trái espresso giới thiệu, nửa phải là form. Mobile: đầu trang espresso + form.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _error = null);
    try {
      await ref
          .read(authProvider.notifier)
          .login(_phoneCtrl.text.trim(), _passwordCtrl.text);
      if (!mounted) return;
      final user = ref.read(authProvider).user!;
      context
          .go(user.mustChangePassword ? '/doi-mat-khau' : homeFor(user.role));
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;
    final revokedMsg = ref.read(authProvider.notifier).revokedMessage;
    final wide = MediaQuery.sizeOf(context).width >= 900;

    final form = Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Đăng nhập',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text('Dùng số điện thoại quản lý đã cấp cho bạn.',
                style: TextStyle(fontSize: 14, color: AppColors.muted)),
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
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Đăng nhập', style: TextStyle(fontSize: 15)),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Quên mật khẩu? Liên hệ quản lý để được cấp mật khẩu tạm.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: AppColors.muted),
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
              padding: EdgeInsets.fromLTRB(
                  24, MediaQuery.paddingOf(context).top + 32, 24, 28),
              decoration: const BoxDecoration(
                color: AppColors.espresso,
                border:
                    Border(bottom: BorderSide(color: AppColors.gold, width: 3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    BrandMark(size: 40),
                    SizedBox(width: 12),
                    Text('Khách Sạn Di Động',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700)),
                  ]),
                  SizedBox(height: 20),
                  Text('Một trạng thái phòng cho cả khách sạn.',
                      style: TextStyle(
                          color: AppColors.goldLight,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          height: 1.25)),
                ],
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

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.espresso,
        border: Border(right: BorderSide(color: AppColors.gold, width: 4)),
      ),
      padding: const EdgeInsets.all(56),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            BrandMark(size: 44),
            SizedBox(width: 12),
            Text('Khách Sạn Di Động',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
          ]),
          const Spacer(),
          Container(width: 56, height: 2, color: AppColors.gold),
          const SizedBox(height: 20),
          const Text(
            'Một trạng thái phòng\ncho cả khách sạn.',
            style: TextStyle(
                color: AppColors.goldLight,
                fontSize: 40,
                fontWeight: FontWeight.w800,
                height: 1.2),
          ),
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: const Text(
              'Lễ tân, buồng phòng và bảo trì cùng cập nhật một nguồn dữ liệu — thay đổi hiện trên mọi thiết bị trong vài giây.',
              style: TextStyle(
                  color: Color(0xFFCFC5B3), fontSize: 16, height: 1.6),
            ),
          ),
          const SizedBox(height: 20),
          const Wrap(
              spacing: 10,
              children: [_Pill('Lưu trú'), _Pill('Vệ sinh'), _Pill('Bảo trì')]),
          const Spacer(),
          const Text('WPCTeam · Đồ án QLDA CNTT · Dữ liệu giả lập',
              style: TextStyle(color: Color(0xFFA89C87), fontSize: 12)),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  const _Pill(this.text);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
            color: const Color(0x1FFFFFFF),
            borderRadius: BorderRadius.circular(14)),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w600)),
      );
}
