import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/user.dart';
import '../providers/users_provider.dart';
import 'temp_password_dialog.dart';

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
    try {
      if (widget.isCreate) {
        final data = await ref.read(usersProvider.notifier).createUser(
              fullName: _fullName.text.trim(),
              phone: _phone.text.trim(),
              role: _role,
            );
        if (!mounted) return;
        Navigator.of(context).pop();
        final tempPw = data?['tempPassword'] as String?;
        if (tempPw != null) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => TempPasswordDialog(
              tempPassword: tempPw,
              fullName: _fullName.text.trim(),
            ),
          );
        }
      } else {
        await ref.read(usersProvider.notifier).updateUser(
              id: widget.user!.id,
              version: widget.user!.version,
              fullName: _fullName.text.trim() != widget.user!.fullName
                  ? _fullName.text.trim()
                  : null,
              phone: _phone.text.trim() != widget.user!.phone
                  ? _phone.text.trim()
                  : null,
              role: _role != widget.user!.role ? _role : null,
            );
        if (!mounted) return;
        Navigator.of(context).pop();
      }
    } on Exception catch (e) {
      setState(() {
        _submitting = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isCreate ? 'Tạo tài khoản' : 'Chỉnh sửa tài khoản';
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_error != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Text(_error!, style: TextStyle(color: Colors.red[700], fontSize: 13)),
                ),
              TextFormField(
                controller: _fullName,
                decoration: const InputDecoration(labelText: 'Họ tên *'),
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Vui lòng nhập họ tên.';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                decoration: const InputDecoration(labelText: 'Số điện thoại *'),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Vui lòng nhập số điện thoại.';
                  if (!RegExp(r'^0\d{9}$').hasMatch(v.trim())) {
                    return 'Số điện thoại không hợp lệ.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<UserRole>(
                initialValue: _role,
                decoration: const InputDecoration(labelText: 'Vai trò *'),
                items: UserRole.values
                    .map((r) => DropdownMenuItem(value: r, child: Text(r.label)))
                    .toList(),
                onChanged: (v) => setState(() => _role = v!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Huỷ'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(widget.isCreate ? 'Tạo' : 'Lưu'),
        ),
      ],
    );
  }
}
