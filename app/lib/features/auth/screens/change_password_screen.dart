import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';
import '../../../core/router/nav.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/utils/error_handler.dart';
import '../../../shared/widgets/ui.dart';
import '../providers/auth_provider.dart';

/// Đổi mật khẩu. [forced] = đang dùng mật khẩu tạm → phải đặt mới mới vào được app.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  final bool forced;
  const ChangePasswordScreen({super.key, this.forced = false});

  /// Tạo state form đổi mật khẩu.
  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

/// Mật khẩu hiện tại, mật khẩu mới, nhập lại, cờ ẩn và lỗi API.
class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  String? _error;

  /// Nghe hai ô mới để checklist cập nhật theo từng ký tự. Không gọi API.
  @override
  void initState() {
    super.initState();
    _newCtrl.addListener(() => setState(() {}));
    _confirmCtrl.addListener(() => setState(() {}));
  }

  /// Giải phóng ba controller.
  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  /// Ít nhất 8 ký tự. Checklist và validator dùng chung.
  bool get _longEnough => _newCtrl.text.length >= 8;
  /// Có ít nhất một chữ và một chữ số.
  bool get _letterAndNumber =>
      RegExp(r'[a-zA-Z]').hasMatch(_newCtrl.text) &&
      RegExp(r'\d').hasMatch(_newCtrl.text);
  /// Hai ô mới trùng và không rỗng.
  bool get _matches =>
      _newCtrl.text.isNotEmpty && _newCtrl.text == _confirmCtrl.text;

  /// [AuthNotifier.changePassword] rồi snack và [homeFor]. [ApiException] hiện trên form.
  /// Không tự logout.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _error = null);
    try {
      await ref
          .read(authProvider.notifier)
          .changePassword(_currentCtrl.text, _newCtrl.text);
      if (!mounted) return;
      showAppSnack(context, 'Đổi mật khẩu thành công.');
      context.go(homeFor(ref.read(authProvider).user?.role));
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    }
  }

  /// [forced] true thì nút phụ là đăng xuất, không thì quay lại màn chủ. Nút lưu tắt khi đang gửi.
  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;
    final forced = widget.forced;

    /// Một dòng checklist. [ok] true thì icon và chữ xanh.
    Widget rule(bool ok, String text) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(children: [
            Icon(ok ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 18, color: ok ? AppColors.ready : AppColors.dotMuted),
            const SizedBox(width: 8),
            Text(text,
                style: AppText.meta
                    .copyWith(color: ok ? AppColors.ready : AppColors.muted)),
          ]),
        );

    /// Trang trí ô mật khẩu với [label]. Không gắn validator.
    InputDecoration pw(String label) => InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.lock_outline),
        );

    final form = AutofillGroup(
        child: Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_error != null) ...[
            AppBanner(tone: BannerTone.error, message: _error!),
            const SizedBox(height: 16),
          ],
          TextFormField(
            controller: _currentCtrl,
            obscureText: _obscure,
            autofillHints: const [AutofillHints.password],
            textInputAction: TextInputAction.next,
            decoration: pw(forced ? 'Mật khẩu tạm' : 'Mật khẩu hiện tại'),
            validator: (v) => (v == null || v.isEmpty)
                ? (forced
                    ? 'Vui lòng nhập mật khẩu tạm.'
                    : 'Vui lòng nhập mật khẩu hiện tại.')
                : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _newCtrl,
            obscureText: _obscure,
            autofillHints: const [AutofillHints.newPassword],
            textInputAction: TextInputAction.next,
            decoration: pw('Mật khẩu mới'),
            validator: (_) => (_longEnough && _letterAndNumber)
                ? null
                : 'Mật khẩu mới cần ít nhất 8 ký tự, gồm cả chữ và số.',
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _confirmCtrl,
            obscureText: _obscure,
            autofillHints: const [AutofillHints.newPassword],
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            decoration: pw('Nhập lại mật khẩu mới'),
            validator: (_) => _matches ? null : 'Mật khẩu nhập lại chưa khớp.',
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18),
              label: Text(_obscure ? 'Hiện mật khẩu' : 'Ẩn mật khẩu'),
            ),
          ),
          AppCard(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            child: Column(children: [
              rule(_longEnough, 'Ít nhất 8 ký tự'),
              rule(_letterAndNumber, 'Có cả chữ và số'),
              rule(_matches, 'Hai lần nhập khớp nhau'),
            ]),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: isLoading ? null : _submit,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, semanticsLabel: 'Đang lưu mật khẩu'))
                  : const Text('Lưu mật khẩu mới'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 48,
            child: TextButton(
              onPressed: forced
                  ? () => ref.read(authProvider.notifier).logout()
                  : () =>
                      context.go(homeFor(ref.read(authProvider).user?.role)),
              child: Text(forced ? 'Đăng xuất' : 'Quay lại'),
            ),
          ),
        ],
      ),
    ));

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                  24, MediaQuery.paddingOf(context).top + 28, 24, 28),
              decoration: const BoxDecoration(
                color: AppColors.espresso,
                border:
                    Border(bottom: BorderSide(color: AppColors.gold, width: 3)),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const BrandMark(size: 40),
                      const SizedBox(height: 14),
                      Text(forced ? 'Đặt mật khẩu mới' : 'Đổi mật khẩu',
                          style: AppText.headlineLg.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(
                        forced
                            ? 'Bạn đang dùng mật khẩu tạm — vui lòng đặt mật khẩu mới để tiếp tục.'
                            : 'Mật khẩu mới áp dụng từ lần đăng nhập sau trên mọi thiết bị.',
                        style: AppText.body.copyWith(
                            color: AppColors.onDarkMuted, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Center(
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: form),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
