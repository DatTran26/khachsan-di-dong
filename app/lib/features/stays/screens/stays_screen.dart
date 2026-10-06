import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/stay.dart';
import '../../../models/user.dart';
import '../../../shared/widgets/ui.dart';
import '../../auth/providers/auth_provider.dart';
import '../../rooms/providers/rooms_provider.dart';
import '../../rooms/widgets/room_detail_panel.dart';
import '../providers/stays_provider.dart';

/// Lưu trú: các phòng đang có khách (FR-check-in-out-005). Trả phòng: chỉ lễ tân.
class StaysScreen extends ConsumerStatefulWidget {
  const StaysScreen({super.key});

  @override
  ConsumerState<StaysScreen> createState() => _StaysScreenState();
}

class _StaysScreenState extends ConsumerState<StaysScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(staysProvider);
    final role = ref.watch(authProvider.select((s) => s.user?.role));
    final online = ref.watch(isOnlineProvider);
    final canCheckOut = role == UserRole.receptionist;
    // Phòng đổi trạng thái (vd lễ tân khác vừa trả phòng) → tải lại danh sách lưu trú.
    ref.listen(roomsProvider.select((s) => s.lastUpdated),
        (_, __) => ref.read(staysProvider.notifier).load());

    final wide = Breakpoints.isWide(context);
    final pad = Breakpoints.hasSidebar(context) ? 32.0 : 16.0;

    if (state.isLoading && state.stays.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null && state.stays.isEmpty) {
      return ErrorState(
          message: state.error!,
          onRetry: () => ref.read(staysProvider.notifier).load());
    }

    final q = _query.trim().toLowerCase();
    final stays = state.stays
        .where((s) =>
            q.isEmpty ||
            s.room.number.contains(q) ||
            s.guestName.toLowerCase().contains(q))
        .toList()
      ..sort((a, b) => a.room.number.compareTo(b.room.number));

    void checkOut(Stay s) {
      final room = ref.read(roomsProvider).byId(s.room.id);
      if (room != null) {
        confirmCheckOut(context, ref, room, guestName: s.guestName);
      }
    }

    final Widget body;
    if (state.stays.isEmpty) {
      body = const EmptyState(
        icon: Icons.key_outlined,
        title: 'Chưa có phòng nào đang có khách.',
        message: 'Khi lễ tân nhận phòng cho khách, lượt lưu trú sẽ hiện ở đây.',
      );
    } else if (stays.isEmpty) {
      body = const EmptyState(
          icon: Icons.search_off,
          title: 'Không tìm thấy khách hoặc phòng này.');
    } else if (wide) {
      body = _StayTable(
          stays: stays,
          canCheckOut: canCheckOut,
          online: online,
          onCheckOut: checkOut);
    } else {
      body = ListView.separated(
        padding: EdgeInsets.fromLTRB(pad, 0, pad, 24),
        itemCount: stays.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _StayCard(
          stay: stays[i],
          canCheckOut: canCheckOut,
          online: online,
          onCheckOut: () => checkOut(stays[i]),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: wide ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: pad),
            child: Wrap(
              spacing: 12,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                StatusChip('Đang ở · ${state.stays.length}',
                    tone: StatusTone.occupied),
                SizedBox(
                  width: 280,
                  child: TextField(
                    onChanged: (v) => setState(() => _query = v),
                    decoration: const InputDecoration(
                      hintText: 'Tìm tên khách hoặc số phòng…',
                      prefixIcon: Icon(Icons.search, size: 20),
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                if (!canCheckOut)
                  const MetaText('Chỉ lễ tân trả phòng tại quầy.'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: wide
                ? Padding(
                    padding: EdgeInsets.fromLTRB(pad, 0, pad, 24), child: body)
                : body,
          ),
        ],
      ),
    );
  }
}

final _fmt = DateFormat('dd/MM · HH:mm');

bool _isDue(Stay s) =>
    s.expectedCheckout != null && s.expectedCheckout!.isBefore(DateTime.now());

class _StayTable extends StatelessWidget {
  final List<Stay> stays;
  final bool canCheckOut;
  final bool online;
  final ValueChanged<Stay> onCheckOut;

  const _StayTable(
      {required this.stays,
      required this.canCheckOut,
      required this.online,
      required this.onCheckOut});

  static const _flex = [10, 18, 8, 14, 14, 18, 12];

  @override
  Widget build(BuildContext context) {
    Widget cell(int i, Widget child, {bool end = false}) => Expanded(
          flex: _flex[i],
          child: Align(
              alignment: end ? Alignment.centerRight : Alignment.centerLeft,
              child: child),
        );
    const head = TextStyle(
        fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.muted);
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            color: const Color(0xFFFAF8F3),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              cell(0, const Text('Phòng', style: head)),
              cell(1, const Text('Khách', style: head)),
              cell(2, const Text('Số người', style: head)),
              cell(3, const Text('Nhận lúc', style: head)),
              cell(4, const Text('Dự kiến trả', style: head)),
              cell(5, const Text('Ghi chú', style: head)),
              cell(6, const Text('Thao tác', style: head), end: true),
            ]),
          ),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: ListView.separated(
              itemCount: stays.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final s = stays[i];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(children: [
                    cell(
                      0,
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.room.number,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            Text('Tầng ${s.room.floor}',
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.muted)),
                          ]),
                    ),
                    cell(1, Text(s.guestName, overflow: TextOverflow.ellipsis)),
                    cell(2, Text('${s.guestCount}')),
                    cell(3, Text(_fmt.format(s.checkedInAt.toLocal()))),
                    cell(
                      4,
                      s.expectedCheckout == null
                          ? const MetaText('—')
                          : _isDue(s)
                              ? StatusChip(
                                  'Quá giờ ${_fmt.format(s.expectedCheckout!.toLocal())}',
                                  tone: StatusTone.danger,
                                  dot: false)
                              : Text(
                                  _fmt.format(s.expectedCheckout!.toLocal())),
                    ),
                    cell(5,
                        MetaText(s.note?.isNotEmpty == true ? s.note! : '—')),
                    cell(
                      6,
                      canCheckOut
                          ? OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 36)),
                              onPressed: online ? () => onCheckOut(s) : null,
                              child: const Text('Trả phòng'),
                            )
                          : const SizedBox.shrink(),
                      end: true,
                    ),
                  ]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StayCard extends StatelessWidget {
  final Stay stay;
  final bool canCheckOut;
  final bool online;
  final VoidCallback onCheckOut;

  const _StayCard(
      {required this.stay,
      required this.canCheckOut,
      required this.online,
      required this.onCheckOut});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Phòng ${stay.room.number}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
              ),
              if (_isDue(stay))
                const StatusChip('Quá giờ trả', tone: StatusTone.danger),
            ],
          ),
          const SizedBox(height: 4),
          Text(stay.guestName,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          MetaText(
              '${stay.guestCount} người · nhận ${_fmt.format(stay.checkedInAt.toLocal())}'),
          if (stay.expectedCheckout != null)
            MetaText(
                'Dự kiến trả ${_fmt.format(stay.expectedCheckout!.toLocal())}'),
          if (stay.note?.isNotEmpty == true) MetaText('Ghi chú: ${stay.note}'),
          if (canCheckOut) ...[
            const SizedBox(height: 10),
            ElevatedButton(
                onPressed: online ? onCheckOut : null,
                child: const Text('Trả phòng')),
          ],
        ],
      ),
    );
  }
}
