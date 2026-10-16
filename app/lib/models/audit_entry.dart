/// Một thay đổi trong bản ghi nhật ký — trục/trường: trước → sau (nhãn tiếng Việt do BE dựng sẵn).
class AuditChange {
  final String field;
  final String fieldLabel;
  final String beforeLabel;
  final String afterLabel;

  const AuditChange({
    required this.field,
    required this.fieldLabel,
    required this.beforeLabel,
    required this.afterLabel,
  });

  /// Dựng một thay đổi. Thiếu nhãn thì chuỗi rỗng, thiếu trước/sau thì "—". Không ném.
  factory AuditChange.fromJson(Map<String, dynamic> json) => AuditChange(
        field: json['field'] as String? ?? '',
        fieldLabel: json['fieldLabel'] as String? ?? '',
        beforeLabel: json['beforeLabel'] as String? ?? '—',
        afterLabel: json['afterLabel'] as String? ?? '—',
      );
}

/// Bản ghi nhật ký (GET /api/audit-logs) — ai / khi / hành động / đối tượng / trước → sau.
class AuditEntry {
  final String id;
  final DateTime occurredAt;
  final String actorName;
  final String actorRole;
  final String actorRoleLabel;
  final String actionLabel;
  final String? entityLabel;
  final String? roomId;
  final List<AuditChange> changes;

  const AuditEntry({
    required this.id,
    required this.occurredAt,
    required this.actorName,
    required this.actorRole,
    required this.actorRoleLabel,
    required this.actionLabel,
    required this.entityLabel,
    required this.roomId,
    required this.changes,
  });

  /// Đúng khi người thao tác là hệ thống, không phải user.
  bool get isSystem => actorRole == 'SYSTEM';

  /// Dựng từ một dòng `GET /audit-logs`. Thiếu actor thì tên "Hệ thống".
  /// Thiếu `changes` thì danh sách rỗng. [roomId] và [entityLabel] có thể null.
  factory AuditEntry.fromJson(Map<String, dynamic> json) {
    final actor = json['actor'] as Map<String, dynamic>?;
    final entity = json['entity'] as Map<String, dynamic>?;
    return AuditEntry(
      id: json['id'] as String,
      occurredAt: DateTime.parse(json['occurredAt'] as String),
      actorName: actor?['fullName'] as String? ?? 'Hệ thống',
      actorRole: json['actorRole'] as String? ?? '',
      actorRoleLabel: json['actorRoleLabel'] as String? ?? '',
      actionLabel: json['actionLabel'] as String? ?? '',
      entityLabel: entity?['label'] as String?,
      roomId: json['roomId'] as String?,
      changes: ((json['changes'] as List?) ?? const [])
          .cast<Map<String, dynamic>>()
          .map(AuditChange.fromJson)
          .toList(),
    );
  }
}
