import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/housekeeping_photo.dart';
import '../../../models/housekeeping_task.dart';
import '../../../shared/utils/error_handler.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/ui.dart';
import '../../rooms/providers/rooms_provider.dart';
import '../providers/housekeeping_provider.dart';
import '../providers/photos_provider.dart';
import '../widgets/photo_gallery.dart';

/// Ảnh nghiệm thu — nhân viên (wireframe housekeeping/anh-nghiem-thu).
/// Đủ 3 ảnh bắt buộc mới báo hoàn tất được; đánh dấu bất thường thì cần thêm ảnh cận cảnh (FR-005, BR-006).
class AcceptancePhotosScreen extends ConsumerStatefulWidget {
  final String taskId;
  const AcceptancePhotosScreen({super.key, required this.taskId});

  @override
  ConsumerState<AcceptancePhotosScreen> createState() =>
      _AcceptancePhotosScreenState();
}

class _AcceptancePhotosScreenState
    extends ConsumerState<AcceptancePhotosScreen> {
  final _picker = ImagePicker();
  bool _hasIssue = false;
  bool _submitting = false;

  /// Điện thoại: chọn chụp mới hay lấy từ thư viện. Web: mở hộp chọn tệp.
  Future<ImageSource?> _askSource() async {
    if (kIsWeb) return ImageSource.gallery;
    return showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Chụp ảnh'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Chọn từ thư viện'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addPhoto(PhotoCategory category) async {
    final source = await _askSource();
    if (source == null) return;
    // Thu nhỏ trước khi gửi: ảnh điện thoại 10+ MB vượt giới hạn 5 MB của server.
    final file = await _picker.pickImage(
        source: source, maxWidth: 1920, maxHeight: 1920, imageQuality: 80);
    if (file == null || !mounted) return;
    try {
      await ref
          .read(taskPhotosProvider(widget.taskId).notifier)
          .upload(category, await file.readAsBytes());
    } on ApiException catch (e) {
      if (mounted) handleApiError(context, e);
    }
  }

  Future<void> _deleteCloseup(HousekeepingPhoto photo) async {
    await showConfirmDialog(
      context,
      title: 'Xóa ảnh cận cảnh này?',
      message:
          'Ảnh chưa nộp nên xóa được; sau khi báo hoàn tất ảnh sẽ được giữ làm bằng chứng.',
      confirmLabel: 'Xóa ảnh',
      destructive: true,
      onConfirm: () =>
          ref.read(taskPhotosProvider(widget.taskId).notifier).delete(photo),
    );
  }

  Future<void> _submit(HousekeepingTask task) async {
    setState(() => _submitting = true);
    try {
      await ref
          .read(housekeepingProvider.notifier)
          .complete(task.id, task.version, hasIssue: _hasIssue);
      if (!mounted) return;
      Navigator.pop(context);
      showAppSnack(context,
          'Đã báo xong phòng ${task.room.number} — chờ quản lý xác nhận.');
    } on ApiException catch (e) {
      if (!mounted) return;
      handleApiError(context, e,
          onReload: () => ref.read(housekeepingProvider.notifier).load());
      // Thiếu ảnh theo server (vd vừa bị xóa ở máy khác) → tải lại để thấy đúng.
      ref.read(taskPhotosProvider(widget.taskId).notifier).load();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = ref.watch(housekeepingProvider.select((s) {
      for (final t in s.tasks) {
        if (t.id == widget.taskId) return t;
      }
      return null;
    }));
    final state = ref.watch(taskPhotosProvider(widget.taskId));
    final online = ref.watch(isOnlineProvider);
    final data = state.data;
    final editable = task?.status == HousekeepingStatus.inProgress;
    final canWrite = online && editable && !_submitting;

    final missing = data == null
        ? <String>[]
        : requiredPhotoCategories
            .where((c) => data.of(c) == null)
            .map((c) => c.label)
            .toList();
    final needsCloseup = _hasIssue && (data?.closeups.isEmpty ?? true);
    final blockReason = !editable
        ? 'Việc không còn ở trạng thái đang dọn.'
        : missing.isNotEmpty
            ? 'Còn thiếu ảnh: ${missing.join(', ')}.'
            : needsCloseup
                ? 'Có bất thường — cần ít nhất 1 ảnh cận cảnh.'
                : state.uploading.isNotEmpty
                    ? 'Đợi ảnh tải xong.'
                    : null;

    Widget body;
    if (data == null && state.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (data == null) {
      body = ErrorState(
          message: state.error ?? 'Chưa tải được ảnh nghiệm thu.',
          onRetry: () =>
              ref.read(taskPhotosProvider(widget.taskId).notifier).load());
    } else {
      body = ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // Nhắc quyền riêng tư (NFR-housekeeping-006).
          const AppBanner(
            tone: BannerTone.info,
            icon: Icons.privacy_tip_outlined,
            message:
                'Chỉ chụp phòng và đồ của khách sạn — không chụp đồ cá nhân, giấy tờ của khách.',
          ),
          if (task?.returnNote != null) ...[
            const SizedBox(height: 12),
            AppBanner(
              tone: BannerTone.error,
              title: 'Quản lý trả lại:',
              message:
                  '${task!.returnNote!} Chụp lại theo ghi chú rồi báo hoàn tất.',
            ),
          ],
          const SizedBox(height: 16),
          for (var i = 0; i < requiredPhotoCategories.length; i++) ...[
            _RequiredSlot(
              index: i + 1,
              category: requiredPhotoCategories[i],
              photo: data.of(requiredPhotoCategories[i]),
              uploading: state.uploading.contains(requiredPhotoCategories[i]),
              enabled: canWrite,
              onPick: () => _addPhoto(requiredPhotoCategories[i]),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 8),
          _IssueSection(
            hasIssue: _hasIssue,
            closeups: data.closeups,
            uploading: state.uploading.contains(PhotoCategory.closeup),
            enabled: canWrite,
            onToggle: (v) => setState(() => _hasIssue = v),
            onAdd: () => _addPhoto(PhotoCategory.closeup),
            onDelete: _deleteCloseup,
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(task == null
            ? 'Ảnh nghiệm thu'
            : 'Phòng ${task.room.number} · Ảnh nghiệm thu'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: body,
        ),
      ),
      bottomNavigationBar: data == null || task == null
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                // heightFactor 1: thanh dưới chỉ cao bằng nội dung, không chiếm cả màn.
                child: Center(
                  heightFactor: 1,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 608),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (blockReason != null) ...[
                          MetaText(blockReason),
                          const SizedBox(height: 8),
                        ],
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48)),
                          onPressed: canWrite && blockReason == null
                              ? () => _submit(task)
                              : null,
                          child:
                              Text(_submitting ? 'Đang gửi…' : 'Báo hoàn tất'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

/// Một nhóm ảnh bắt buộc: số thứ tự, tên nhóm, trạng thái; có ảnh → ảnh thu nhỏ + "Chụp lại".
class _RequiredSlot extends StatelessWidget {
  final int index;
  final PhotoCategory category;
  final HousekeepingPhoto? photo;
  final bool uploading;
  final bool enabled;
  final VoidCallback onPick;

  const _RequiredSlot({
    required this.index,
    required this.category,
    required this.photo,
    required this.uploading,
    required this.enabled,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final done = photo != null;
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? AppColors.ready : AppColors.neutralBg,
                ),
                child: done
                    ? const Icon(Icons.check, size: 15, color: Colors.white)
                    : Text('$index',
                        style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.muted)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(category.label,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
              ),
              uploading
                  ? const StatusChip('Đang tải…', tone: StatusTone.gold)
                  : done
                      ? const StatusChip('Đã tải', tone: StatusTone.ready)
                      : const StatusChip('Cần ảnh', tone: StatusTone.neutral),
            ],
          ),
          const SizedBox(height: 12),
          if (done)
            Row(
              children: [
                PhotoThumb(
                  photo: photo!,
                  onTap: () => showPhotoViewer(context, [photo!], 0),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: enabled && !uploading ? onPick : null,
                  icon: const Icon(Icons.photo_camera_outlined, size: 18),
                  label: const Text('Chụp lại'),
                ),
              ],
            )
          else
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48)),
              onPressed: enabled && !uploading ? onPick : null,
              icon: uploading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.add_a_photo_outlined, size: 18),
              label: Text(uploading ? 'Đang tải ảnh…' : 'Chụp ảnh'),
            ),
        ],
      ),
    );
  }
}

/// "Khi có bất thường": bật → bắt buộc ảnh cận cảnh (tối đa [maxCloseups]).
class _IssueSection extends StatelessWidget {
  final bool hasIssue;
  final List<HousekeepingPhoto> closeups;
  final bool uploading;
  final bool enabled;
  final ValueChanged<bool> onToggle;
  final VoidCallback onAdd;
  final ValueChanged<HousekeepingPhoto> onDelete;

  const _IssueSection({
    required this.hasIssue,
    required this.closeups,
    required this.uploading,
    required this.enabled,
    required this.onToggle,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final full = closeups.length >= maxCloseups;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(14, 6, 8, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: hasIssue,
            onChanged: enabled ? onToggle : null,
            title: const Text('Có bất thường',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            subtitle: const Text(
                'Hỏng hóc, thiếu đồ, vết bẩn khó xử lý — chụp cận cảnh để quản lý xem.'),
          ),
          if (hasIssue || closeups.isNotEmpty) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (var i = 0; i < closeups.length; i++)
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        PhotoThumb(
                          photo: closeups[i],
                          onTap: () => showPhotoViewer(context, closeups, i),
                        ),
                        Positioned(
                          top: -10,
                          right: -10,
                          child: IconButton(
                            tooltip: 'Xóa ảnh cận cảnh ${i + 1}',
                            visualDensity: VisualDensity.compact,
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.surface,
                              side: const BorderSide(color: AppColors.border),
                            ),
                            icon: const Icon(Icons.close, size: 16),
                            onPressed:
                                enabled ? () => onDelete(closeups[i]) : null,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            if (closeups.isNotEmpty) const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48)),
              onPressed: enabled && !uploading && !full ? onAdd : null,
              icon: uploading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.add_a_photo_outlined, size: 18),
              label: Text(uploading
                  ? 'Đang tải ảnh…'
                  : full
                      ? 'Đã đủ $maxCloseups ảnh cận cảnh'
                      : 'Thêm ảnh cận cảnh'),
            ),
          ],
        ],
      ),
    );
  }
}
