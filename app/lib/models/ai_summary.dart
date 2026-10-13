/// Kỳ tóm tắt (ai-ops-summary FR-001) — không có kỳ tương lai.
enum SummaryPeriod { currentShift, previousShift, today }

extension SummaryPeriodX on SummaryPeriod {
  String get value => switch (this) {
        SummaryPeriod.currentShift => 'CURRENT_SHIFT',
        SummaryPeriod.previousShift => 'PREVIOUS_SHIFT',
        SummaryPeriod.today => 'TODAY',
      };

  String get label => switch (this) {
        SummaryPeriod.currentShift => 'Ca hiện tại',
        SummaryPeriod.previousShift => 'Ca trước',
        SummaryPeriod.today => 'Hôm nay',
      };

  static SummaryPeriod parse(String v) =>
      SummaryPeriod.values.firstWhere((p) => p.value == v,
          orElse: () => SummaryPeriod.currentShift);
}

/// AI: bản AI đã kiểm số liệu · FALLBACK: báo cáo mẫu · EMPTY: kỳ không có hoạt động.
enum SummarySource { ai, fallback, empty }

/// Việc cần chú ý — dựng theo quy tắc ở server, có phòng/việc để mở dashboard (FR-012).
class AttentionItem {
  final String type; // HOUSEKEEPING_OVERDUE | MAINTENANCE_OVERDUE | OUT_OF_SERVICE
  final String roomId;
  final String roomNumber;
  final String? taskId;
  final String text;

  const AttentionItem({
    required this.type,
    required this.roomId,
    required this.roomNumber,
    this.taskId,
    required this.text,
  });

  factory AttentionItem.fromJson(Map<String, dynamic> json) => AttentionItem(
        type: json['type'] as String,
        roomId: json['roomId'] as String,
        roomNumber: json['roomNumber'] as String,
        taskId: json['taskId'] as String?,
        text: json['text'] as String,
      );
}

class AiSummary {
  final String id;
  final SummaryPeriod period;
  final String periodLabel;
  final String dataAsOfText; // "Dữ liệu tính đến …" (FR-006)
  final SummarySource source;
  final String? label; // nhãn "tham khảo" / "báo cáo mẫu"; kỳ rỗng → null
  final String overview;
  final List<String> highlights;
  final List<AttentionItem> attention;
  final String createdByName;
  final DateTime createdAt;

  const AiSummary({
    required this.id,
    required this.period,
    required this.periodLabel,
    required this.dataAsOfText,
    required this.source,
    this.label,
    required this.overview,
    this.highlights = const [],
    this.attention = const [],
    required this.createdByName,
    required this.createdAt,
  });

  factory AiSummary.fromJson(Map<String, dynamic> json) {
    final attention = json['attention'] as Map<String, dynamic>? ?? {};
    return AiSummary(
      id: json['id'] as String,
      period: SummaryPeriodX.parse(json['period'] as String),
      periodLabel: json['periodLabel'] as String,
      dataAsOfText: json['dataAsOfText'] as String,
      source: switch (json['source'] as String) {
        'AI' => SummarySource.ai,
        'FALLBACK' => SummarySource.fallback,
        _ => SummarySource.empty,
      },
      label: json['label'] as String?,
      overview: json['overview'] as String,
      highlights: List<String>.from(json['highlights'] as List? ?? const []),
      attention: [
        for (final a in (attention['items'] as List?) ?? const [])
          AttentionItem.fromJson(a as Map<String, dynamic>),
      ],
      createdByName:
          (json['createdBy'] as Map<String, dynamic>?)?['fullName'] as String? ??
              '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
