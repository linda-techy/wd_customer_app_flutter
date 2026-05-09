/// Customer-API GET /api/projects/{uuid}/boq/payment-schedule?nextOnly=true.
///
/// Mirrors com.wd.custapi.dto.NextPaymentMilestoneDto byte-for-byte:
/// - stage: nullable record (null when all stages are PAID/ON_HOLD)
/// - summary: required totals across the whole schedule
///
/// This is the typed contract the [NextPaymentMilestoneCard] widget consumes
/// — the widget never inspects raw JSON.
class NextPaymentMilestone {
  final NextPaymentStage? stage;
  final NextPaymentSummary summary;

  const NextPaymentMilestone({
    required this.stage,
    required this.summary,
  });

  factory NextPaymentMilestone.fromJson(Map<String, dynamic> json) {
    final s = json['stage'];
    return NextPaymentMilestone(
      stage: s == null ? null : NextPaymentStage.fromJson(s as Map<String, dynamic>),
      summary: NextPaymentSummary.fromJson(json['summary'] as Map<String, dynamic>),
    );
  }
}

class NextPaymentStage {
  final int stageNumber;
  final String stageName;
  final DateTime? dueDate;
  final int? daysUntilDue;
  final String status; // raw enum name, e.g. 'DUE'/'OVERDUE'/'UPCOMING'/'INVOICED'
  final double netPayableAmount;
  final double stagePercentage;
  final double percentOfContract;
  final int totalStages;

  const NextPaymentStage({
    required this.stageNumber,
    required this.stageName,
    required this.dueDate,
    required this.daysUntilDue,
    required this.status,
    required this.netPayableAmount,
    required this.stagePercentage,
    required this.percentOfContract,
    required this.totalStages,
  });

  factory NextPaymentStage.fromJson(Map<String, dynamic> json) {
    return NextPaymentStage(
      stageNumber: json['stageNumber'] as int,
      stageName: json['stageName'] as String,
      dueDate: json['dueDate'] == null ? null : DateTime.parse(json['dueDate'] as String),
      daysUntilDue: json['daysUntilDue'] as int?,
      status: json['status'] as String,
      netPayableAmount: _toDouble(json['netPayableAmount']),
      stagePercentage: _toDouble(json['stagePercentage']),
      percentOfContract: _toDouble(json['percentOfContract']),
      totalStages: json['totalStages'] as int,
    );
  }
}

class NextPaymentSummary {
  final double totalContractValue;
  final double totalPaid;
  final double totalOutstanding;
  final int stageCount;

  const NextPaymentSummary({
    required this.totalContractValue,
    required this.totalPaid,
    required this.totalOutstanding,
    required this.stageCount,
  });

  factory NextPaymentSummary.fromJson(Map<String, dynamic> json) {
    return NextPaymentSummary(
      totalContractValue: _toDouble(json['totalContractValue']),
      totalPaid: _toDouble(json['totalPaid']),
      totalOutstanding: _toDouble(json['totalOutstanding']),
      stageCount: json['stageCount'] as int,
    );
  }
}

/// Jackson serialises BigDecimal as a JSON number — whole-rupee values
/// arrive as int over the wire, fractional values as double. Coerce both.
double _toDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is int) return v.toDouble();
  if (v is double) return v;
  if (v is num) return v.toDouble();
  return double.parse(v.toString());
}
