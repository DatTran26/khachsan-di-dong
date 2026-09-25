import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../core/api/api_client.dart';
import '../../../models/user.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  final bool forced;
  const ChangePasswordScreen({super.key, this.forced = false});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscureCurrent = true, _obscureNew = true, _obscureConfirm = true;
  String? _error;
  String? _success;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool _hasLetterAndNumber(String v) =>
      RegExp(r'[a-zA-Z]').hasMatch(v) && RegExp(r'\d').hasMatch(v);

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _error = null;
      _success = null;
    });
    try {
      await ref.read(authProvider.notifier).changePassword(
            _currentCtrl.text,
            _newCtrl.text,
          );
      if (!mounted) return;
      setState(() => _success = 'Đổi mật khẩu thành công.');
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      final user = ref.read(authProvider).user!;
      _navigateHome(user);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    }
  }

  void _navigateHome(AppUser user) {
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.lock_reset, color: Color(0xFF1565C0)),
                      const SizedBox(width: 8),
                      Text(
                        widget.forced ? 'Đổi mật khẩu bắt buộc' : 'Đổi mật khẩu',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ]),
                    if (widget.forced) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.amber[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber),
                        ),
                        child: const Text(
                          'Bạn đang dùng mật khẩu tạm — vui lòng đặt mật khẩu mới để tiếp tục.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    _PasswordField(
                      controller: _currentCtrl,
                      label: 'Mật khẩu hiện tại',
                      obscure: _obscureCurrent,
                      onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Vui lòng nhập mật khẩu hiện tại.' : null,
                    ),
                    const SizedBox(height: 16),
                    _PasswordField(
                      controller: _newCtrl,
                      label: 'Mật khẩu mới',
                      obscure: _obscureNew,
                      onToggle: () => setState(() => _obscureNew = !_obscureNew),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu mới.';
                        if (v.length < 8) return 'Mật khẩu mới cần ít nhất 8 ký tự, gồm cả chữ và số.';
                        if (!_hasLetterAndNumber(v)) {
                          return 'Mật khẩu mới cần ít nhất 8 ký tự, gồm cả chữ và số.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _PasswordField(
                      controller: _confirmCtrl,
                      label: 'Xác nhận mật khẩu mới',
                      obscure: _obscureConfirm,
                      onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      validator: (v) => v != _newCtrl.text ? 'Mật khẩu xác nhận không khớp.' : null,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      _StatusBanner(message: _error!, isError: true),
                    ],
                    if (_success != null) ...[
                      const SizedBox(height: 12),
                      _StatusBanner(message: _success!, isError: false),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Lưu mật khẩu'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;
  final String? Function(String?) validator;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.obscure,
    required this.onToggle,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.lock),
          suffixIcon: IconButton(
            icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
            onPressed: onToggle,
          ),
        ),
        validator: validator,
      );
}

class _StatusBanner extends StatelessWidget {
  final String message;
  final bool isError;

  const _StatusBanner({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isError ? Colors.red[50] : Colors.green[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isError ? Colors.red[300]! : Colors.green[300]!),
        ),
        child: Row(children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? Colors.red[700] : Colors.green[700],
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isError ? Colors.red[700] : Colors.green[700],
                fontSize: 13,
              ),
            ),
          ),
        ]),
      );
}
