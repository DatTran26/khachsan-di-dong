import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/ai_summary.dart';
import '../../../shared/utils/error_handler.dart';
import '../../../shared/widgets/ui.dart';
import '../../rooms/providers/rooms_provider.dart';
import '../providers/ai_summary_provider.dart';

/// Tóm tắt vận hành (ai-ops-summary) — chỉ quản lý.
/// Chọn kỳ → Tạo tóm tắt → bản AI (nhãn tham khảo) hoặc báo cáo mẫu; việc cần chú ý mở dashboard (FR-012).
/// AI chỉ tham khảo: màn này không có nút nào sửa dữ liệu nghiệp vụ.
class AiSummaryScreen extends ConsumerWidget {
  const AiSummaryScreen({super.key});

  Future<void> _generate(BuildContext context, WidgetRef ref) async {
    final error = await ref.read(aiSummaryProvider.notifier).generate();
    if (error != null && context.mounted) handleApiError(context, error);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aiSummaryProvider);
    final online = ref.watch(isOnlineProvider);
    final wide = Breakpoints.hasSidebar(context);
    final pad = wide
        ? const EdgeInsets.fromLTRB(32, 24, 32, 32)
        : const EdgeInsets.fromLTRB(16, 16, 16, 24);
    final summary = state.current;

    Widget body;
    if (state.isLoading && state.latest.isEmpty) {
      body = const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (state.error != null && state.latest.isEmpty) {
      body = ErrorState(
          message: state.error!,
          onRetry: () => ref.read(aiSummaryProvider.notifier).load());
    } else if (summary == null) {
      body = EmptyState(
        icon: Icons.auto_awesome_outlined,
        title: 'Chưa có bản tóm tắt nào cho ${state.period.label.toLowerCase()}.',
        message: 'Bấm "Tạo tóm tắt" để xem tình hình vận hành của kỳ này.',
      );
    } else {
      body = _SummaryCard(summary: summary);
    }

    return ListView(
      padding: pad,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const MetaText(
                    'Tóm tắt chỉ để tham khảo, dựa trên số liệu tổng hợp — không chứa thông tin khách.'),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    SegmentedPills<SummaryPeriod>(
                      options: [
                        for (final p in SummaryPeriod.values) (p, p.label)
                      ],
                      value: state.period,
                      // Đang tạo → giữ nguyên kỳ để kết quả không lẫn sang kỳ khác.
                      onChanged: (p) {
                        if (!state.isGenerating) {
                          ref.read(aiSummaryProvider.notifier).selectPeriod(p);
                        }
                      },
                    ),
                    ElevatedButton.icon(
                      onPressed: online && !state.isGenerating
                          ? () => _generate(context, ref)
                          : null,
                      icon: state.isGenerating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.auto_awesome, size: 18),
                      label: Text(
                          state.isGenerating ? 'Đang tạo…' : 'Tạo tóm tắt'),
                    ),
                  ],
                ),
                if (state.notice != null) ...[
                  const SizedBox(height: 16),
                  AppBanner(
                    tone: BannerTone.info,
                    icon: Icons.info_outline,
                    message: state.notice!,
                  ),
                ],
                if (state.error != null && state.latest.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  AppBanner(tone: BannerTone.error, message: state.error!),
                ],
                const SizedBox(height: 16),
                body,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final AiSummary summary;
  const _SummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final created = DateFormat('HH:mm dd/MM').format(summary.createdAt.toLocal());
    final isAi = summary.source == SummarySource.ai;
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(summary.periodLabel,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          MetaText(
              '${summary.dataAsOfText} · tạo bởi ${summary.createdByName} lúc $created'),
          if (summary.label != null) ...[
            const SizedBox(height: 12),
            // Nhãn cố định (FR-006, FR-007): bản AI là "tham khảo", báo cáo mẫu nói rõ chưa qua AI.
            _SourceLabel(text: summary.label!, ai: isAi),
          ],
          const SizedBox(height: 16),
          const SectionLabel('Tổng quan'),
          const SizedBox(height: 6),
          Text(summary.overview,
              style: const TextStyle(fontSize: 15, height: 1.5)),
          if (summary.highlights.isNotEmpty) ...[
            const SizedBox(height: 16),
            const SectionLabel('Điểm nổi bật'),
            const SizedBox(height: 6),
            for (final h in summary.highlights) _Bullet(h),
          ],
          const SizedBox(height: 16),
          SectionLabel('Việc cần chú ý · ${summary.attention.length}'),
          const SizedBox(height: 6),
          if (summary.attention.isEmpty)
            const MetaText('Không có việc quá hạn hay phòng ngừng phục vụ.')
          else
            for (final a in summary.attention) _AttentionRow(item: a),
        ],
      ),
    );
  }
}

class _SourceLabel extends StatelessWidget {
  final String text;
  final bool ai;
  const _SourceLabel({required this.text, required this.ai});

  @override
  Widget build(BuildContext context) {
    final fg = ai ? AppColors.goldText : AppColors.neutral;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ai ? AppColors.goldTint : AppColors.neutralBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ai ? Icons.auto_awesome : Icons.table_chart_outlined,
              size: 16, color: fg),
          const SizedBox(width: 6),
          Flexible(
            child: Text(text,
                style: TextStyle(
                    fontSize: 13, color: fg, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('•  ', style: TextStyle(fontSize: 14, height: 1.5)),
            Expanded(
                child: Text(text,
                    style: const TextStyle(fontSize: 14, height: 1.5))),
          ],
        ),
      );
}

/// Một việc cần chú ý — "Tới dashboard" mở đúng ô phòng (FR-012).
class _AttentionRow extends StatelessWidget {
  final AttentionItem item;
  const _AttentionRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final oos = item.type == 'OUT_OF_SERVICE';
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(oos ? Icons.block_rounded : Icons.schedule_rounded,
              size: 18, color: oos ? AppColors.oos : AppColors.danger),
          const SizedBox(width: 8),
          Expanded(
              child: Text(item.text, style: const TextStyle(fontSize: 14))),
          TextButton(
            onPressed: () => context.go('/dashboard?phong=${item.roomId}'),
            child: const Text('Tới dashboard'),
          ),
        ],
      ),
    );
  }
}
