import '../../models/api_models.dart';
import '../../models/next_payment_milestone.dart';

/// A project card paired with its fetched next-payment milestone.
///
/// Extracted from the private `_ProjectPayment` holder inside
/// [CustomerDashboardScreen] so that [selectRaisedPayments] can be
/// tested independently without any widget infrastructure.
class ProjectPayment {
  final ProjectCard project;
  final NextPaymentMilestone milestone;

  const ProjectPayment({required this.project, required this.milestone});
}

/// Statuses that constitute a "raised" (actionable) payment.
const _raisedStatuses = {'INVOICED', 'DUE', 'OVERDUE'};

/// Priority order for sorting: lower number = shown first.
const _statusOrder = {'OVERDUE': 0, 'DUE': 1, 'INVOICED': 2};

/// Filters [all] to only entries whose stage status is `INVOICED`, `DUE`, or
/// `OVERDUE`, then sorts them:
///
/// 1. By status priority: OVERDUE → DUE → INVOICED.
/// 2. Within the same status, by [NextPaymentStage.dueDate] ascending;
///    entries with a `null` dueDate sort last.
///
/// Entries whose milestone has a `null` stage are excluded (they represent
/// projects where every stage is PAID or ON_HOLD).
List<ProjectPayment> selectRaisedPayments(List<ProjectPayment> all) {
  final raised = all.where((pp) {
    final stage = pp.milestone.stage;
    if (stage == null) return false;
    return _raisedStatuses.contains(stage.status);
  }).toList();

  raised.sort((a, b) {
    final sa = _statusOrder[a.milestone.stage!.status] ?? 3;
    final sb = _statusOrder[b.milestone.stage!.status] ?? 3;
    if (sa != sb) return sa.compareTo(sb);

    // Within same status: sort by dueDate ascending, nulls last.
    final da = a.milestone.stage!.dueDate;
    final db = b.milestone.stage!.dueDate;
    if (da == null && db == null) return 0;
    if (da == null) return 1; // null sorts last
    if (db == null) return -1;
    return da.compareTo(db);
  });

  return raised;
}
