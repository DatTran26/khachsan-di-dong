import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../models/user.dart';
import '../../../shared/utils/error_handler.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/ui.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/users_provider.dart';
import 'temp_password_dialog.dart';

/// Tạo / sửa tài khoản. Lễ tân không tạo hoặc gán vai trò Quản lý (BE chặn — ẩn luôn lựa chọn).
class UserFormDialog extends ConsumerStatefulWidget {
  final AppUser? user;

  const UserFormDialog({super.key, this.user});

  bool get isCreate => user == null;

  @override
  ConsumerState<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends ConsumerState<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullName;
  late final TextEditingController _phone;
  late UserRole _role;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fullName = TextEditingController(text: widget.user?.fullName ?? '');
    _phone = TextEditingController(text: widget.user?.phone ?? '');
    _role = widget.user?.role ?? UserRole.staff;
  }

  @override
  void dispose() {
    _fullName.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    final name = _fullName.text.trim();
    try {
      if (widget.isCreate) {
        final data = await ref.read(usersProvider.notifier).createUser(
              fullName: name,
              phone: _phone.text.trim(),
              role: _role,
            );
        if (!mounted) return;
        final navigator = Navigator.of(context);
        final rootContext = navigator.context;
        navigator.pop();
        final tempPw = data?['tempPassword'] as String?;
        if (tempPw != null && rootContext.mounted) {
          await showDialog(
            context: rootContext,
            barrierDismissible: false,
            builder: (_) =>
                TempPasswordDialog(tempPassword: tempPw, fullName: name),
          );
        }
      } else {
        await ref.read(usersProvider.notifier).updateUser(
              id: widget.user!.id,
              version: widget.user!.version,
              fullName: name != widget.user!.fullName ? name : null,
              phone: _phone.text.trim() != widget.user!.phone
                  ? _phone.text.trim()
                  : null,
              role: _role != widget.user!.role ? _role : null,
            );
        if (!mounted) return;
        Navigator.of(context).pop();
        showAppSnack(context, 'Đã cập nhật tài khoản $name.');
      }
    } on ApiException catch (e) {
      setState(() {
        _submitting = false;
        _error = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final actorRole = ref.watch(authProvider.select((s) => s.user?.role));
    final roles = actorRole == UserRole.manager
        ? UserRole.values
        : UserRole.values.where((r) => r != UserRole.manager).toList();

    return GoldDialog(
      title: widget.isCreate ? 'Tạo tài khoản' : 'Sửa tài khoản',
      width: 420,
      content: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null) ...[
              AppBanner(tone: BannerTone.error, message: _error!),
              const SizedBox(height: 12),
            ],
            TextFormField(
              controller: _fullName,
              decoration: const InputDecoration(labelText: 'Họ tên *'),
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Vui lòng nhập họ tên.'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phone,
              decoration: const InputDecoration(
                  labelText: 'Số điện thoại *',
                  helperText: 'Dùng để đăng nhập.'),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
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
            const SizedBox(height: 14),
            DropdownButtonFormField<UserRole>(
              initialValue: roles.contains(_role) ? _role : roles.first,
              decoration: const InputDecoration(labelText: 'Vai trò *'),
              items: [
                for (final r in roles)
                  DropdownMenuItem(value: r, child: Text(r.label))
              ],
              onChanged: (v) => setState(() => _role = v!),
            ),
            if (widget.isCreate) ...[
              const SizedBox(height: 12),
              const MetaText(
                  'Hệ thống cấp mật khẩu tạm sau khi tạo. Nhân viên đổi mật khẩu ở lần đăng nhập đầu.'),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(widget.isCreate ? 'Tạo tài khoản' : 'Lưu thay đổi'),
        ),
      ],
    );
  }
}
