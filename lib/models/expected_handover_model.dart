/// Customer-API GET /api/customer/projects/{uuid}/expected-handover.
///
/// Mirrors com.wd.custapi.dto.ExpectedHandoverDto byte-for-byte:
/// - projectFinishDate: ISO date string or null (CPM not yet run)
/// - baselineFinishDate: ISO date string or null (no approved baseline)
/// - weeksRemaining: int or null (null when projectFinishDate is null)
/// - hasMaterialDelay: bool, always present (defaults false on partial payloads)
class ExpectedHandover {
  final DateTime? projectFinishDate;
  final DateTime? baselineFinishDate;
  final int? weeksRemaining;
  final bool hasMaterialDelay;

  const ExpectedHandover({
    required this.projectFinishDate,
    required this.baselineFinishDate,
    required this.weeksRemaining,
    required this.hasMaterialDelay,
  });

  factory ExpectedHandover.fromJson(Map<String, dynamic> json) {
    return ExpectedHandover(
      projectFinishDate: json['projectFinishDate'] != null
          ? DateTime.parse(json['projectFinishDate'] as String)
          : null,
      baselineFinishDate: json['baselineFinishDate'] != null
          ? DateTime.parse(json['baselineFinishDate'] as String)
          : null,
      weeksRemaining: json['weeksRemaining'] as int?,
      hasMaterialDelay: (json['hasMaterialDelay'] as bool?) ?? false,
    );
  }
}
