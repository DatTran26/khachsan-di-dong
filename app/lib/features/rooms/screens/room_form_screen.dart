import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/rooms_provider.dart';
import '../providers/room_types_provider.dart';
import '../../../core/api/api_client.dart';
import '../../../models/room.dart';
import '../../../shared/utils/error_handler.dart';

/// Màn tạo / sửa phòng — chỉ dùng cho quản lý.
/// Truyền [room] để vào chế độ sửa, để null để tạo mới.
class RoomFormScreen extends ConsumerStatefulWidget {
  final Room? room;

  const RoomFormScreen({super.key, this.room});

  @override
  ConsumerState<RoomFormScreen> createState() => _RoomFormScreenState();
}

class _RoomFormScreenState extends ConsumerState<RoomFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _numberCtrl;
  late final TextEditingController _floorCtrl;
  String? _selectedRoomTypeId;
  bool _saving = false;
  bool _isBulk = false;
  final _fromCtrl = TextEditingController();
  final _toCtrl = TextEditingController();

  bool get isEdit => widget.room != null;

  @override
  void initState() {
    super.initState();
    _numberCtrl = TextEditingController(text: widget.room?.number ?? '');
    _floorCtrl =
        TextEditingController(text: widget.room?.floor.toString() ?? '');
    _selectedRoomTypeId =
        widget.room?.roomType.id; // initial; updated via onChanged
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    _floorCtrl.dispose();
    _fromCtrl.dispose();
    _toCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save(); // populate _selectedRoomTypeId via onSaved
    setState(() => _saving = true);
    try {
      if (isEdit) {
        await ref.read(roomsProvider.notifier).updateRoom(
              roomId: widget.room!.id,
              version: widget.room!.version,
              number: _numberCtrl.text.trim(),
              floor: int.parse(_floorCtrl.text.trim()),
              roomTypeId: _selectedRoomTypeId,
            );
        if (mounted) {
          showAppSnack(
              context, 'Đã cập nhật phòng ${_numberCtrl.text.trim()}.');
          Navigator.pop(context, true);
        }
      } else if (_isBulk) {
        final result = await ref.read(roomsProvider.notifier).createRoomRange(
              floor: int.parse(_floorCtrl.text.trim()),
              from: int.parse(_fromCtrl.text.trim()),
              to: int.parse(_toCtrl.text.trim()),
              roomTypeId: _selectedRoomTypeId!,
            );
        if (mounted) {
          final created = result['created'] as List? ?? [];
          final skipped = result['skipped'] as List? ?? [];
          final msg = 'Đã tạo ${created.length} phòng'
              '${skipped.isNotEmpty ? ', bỏ qua ${skipped.length} số đã tồn tại' : ''}';
          showAppSnack(context, '$msg.');
          Navigator.pop(context, true);
        }
      } else {
        await ref.read(roomsProvider.notifier).createRoom(
              number: _numberCtrl.text.trim(),
              floor: int.parse(_floorCtrl.text.trim()),
              roomTypeId: _selectedRoomTypeId!,
            );
        if (mounted) {
          showAppSnack(context, 'Đã thêm phòng ${_numberCtrl.text.trim()}.');
          Navigator.pop(context, true);
        }
      }
    } on ApiException catch (e) {
      if (mounted) {
        handleApiError(context, e,
            onReload: () => ref.read(roomsProvider.notifier).load());
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final typesState = ref.watch(roomTypesProvider);
    final activeTypes = typesState.activeTypes;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Sửa phòng' : 'Thêm phòng'),
      ),
      body: typesState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : typesState.error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(typesState.error!),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () =>
                            ref.read(roomTypesProvider.notifier).load(),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : Form(
                  key: _formKey,
                  child: ListView(
                    // Form hẹp ở giữa trên màn rộng (web), full chiều ngang trên mobile.
                    padding: EdgeInsets.symmetric(
                      horizontal: math.max(
                          20, (MediaQuery.sizeOf(context).width - 560) / 2),
                      vertical: 24,
                    ),
                    children: [
                      if (!isEdit) ...[
                        Row(
                          children: [
                            ChoiceChip(
                              label: const Text('Tạo một phòng'),
                              selected: !_isBulk,
                              onSelected: (_) =>
                                  setState(() => _isBulk = false),
                            ),
                            const SizedBox(width: 10),
                            ChoiceChip(
                              label: const Text('Tạo theo dải số'),
                              selected: _isBulk,
                              onSelected: (_) => setState(() => _isBulk = true),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                      if (!_isBulk)
                        TextFormField(
                          controller: _numberCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Số phòng *',
                            hintText: 'VD: 101',
                          ),
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(10)
                          ],
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Vui lòng nhập số phòng'
                              : null,
                        ),
                      if (_isBulk) ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _fromCtrl,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'Từ số *',
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Bắt buộc';
                                  final n = int.tryParse(v);
                                  return n == null || n < 1
                                      ? 'Không hợp lệ'
                                      : null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _toCtrl,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'Đến số *',
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Bắt buộc';
                                  final n = int.tryParse(v);
                                  if (n == null || n < 1) return 'Không hợp lệ';
                                  final from =
                                      int.tryParse(_fromCtrl.text) ?? 0;
                                  return n < from ? 'Phải ≥ "Từ số"' : null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _floorCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Tầng *',
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Vui lòng nhập tầng';
                          }
                          final n = int.tryParse(v);
                          return n == null || n < 1
                              ? 'Tầng phải là số nguyên dương'
                              : null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedRoomTypeId,
                        decoration: const InputDecoration(
                          labelText: 'Loại phòng *',
                        ),
                        items: activeTypes
                            .map((t) => DropdownMenuItem(
                                value: t.id, child: Text(t.name)))
                            .toList(),
                        onChanged: (v) => _selectedRoomTypeId = v,
                        onSaved: (v) => _selectedRoomTypeId = v,
                        validator: (v) =>
                            v == null ? 'Vui lòng chọn loại phòng' : null,
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _saving ? null : _submit,
                          child: _saving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(isEdit
                                  ? 'Lưu thay đổi'
                                  : (_isBulk ? 'Tạo theo dải' : 'Thêm phòng')),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
