import '../services/customer_boq_service.dart' show CustomerChangeOrder;

/// Lightweight DTO for the CR detail rendered on `CrOtpApprovalScreen`.
///
/// Distinct from [CustomerChangeOrder] (legacy BOQ-style change order) —
/// this model carries only the fields the OTP screen needs:
/// the CR's database id, its title + description, and the cost / time
/// impacts the customer is being asked to approve.
///
/// `costImpactRupees` is `num` (Dart's `BigDecimal` proxy) so signed
/// rupee amounts can flow through without locale loss.
class ChangeRequestSummary {
  /// Backend `project_variations.id`. Used in OTP request + verify URL paths.
  final int crId;
  final String title;
  final String? description;

  /// Signed rupees (positive for additions, negative for reductions).
  final num costImpactRupees;

  /// Whole working-day delta. Positive = pushes downstream tasks out.
  final int timeImpactWorkingDays;

  const ChangeRequestSummary({
    required this.crId,
    required this.title,
    this.description,
    required this.costImpactRupees,
    required this.timeImpactWorkingDays,
  });

  factory ChangeRequestSummary.fromJson(Map<String, dynamic> j) =>
      ChangeRequestSummary(
        crId: (j['crId'] as num).toInt(),
        title: j['title'] as String,
        description: j['description'] as String?,
        costImpactRupees: (j['costImpactRupees'] as num?) ?? 0,
        timeImpactWorkingDays:
            ((j['timeImpactWorkingDays'] as num?) ?? 0).toInt(),
      );

  /// Adapter from the legacy `CustomerChangeOrder` (used by
  /// `co_review_screen`) into the lightweight summary the OTP screen
  /// needs. The legacy model carries a signed `netAmountInclGst` plus an
  /// `isReduction` flag — collapse those into a signed rupee amount.
  /// `timeImpactWorkingDays` is not modelled on `CustomerChangeOrder`,
  /// so it falls through as `0` (the OTP screen will simply render
  /// "+0 working days").
  factory ChangeRequestSummary.fromCustomerChangeOrder(CustomerChangeOrder co) {
    final num signedCost =
        co.isReduction ? -co.netAmountInclGst : co.netAmountInclGst;
    return ChangeRequestSummary(
      crId: co.id,
      title: co.title,
      description: co.description,
      costImpactRupees: signedCost,
      timeImpactWorkingDays: 0,
    );
  }
}
