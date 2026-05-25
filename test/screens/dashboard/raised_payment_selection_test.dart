import 'package:flutter_test/flutter_test.dart';
import 'package:wd_cust_mobile_app/models/api_models.dart';
import 'package:wd_cust_mobile_app/models/next_payment_milestone.dart';
import 'package:wd_cust_mobile_app/screens/dashboard/raised_payment_selection.dart';

/// Builds a [ProjectPayment] for the given stage [status] and optional
/// [dueDate]. A null [status] means the milestone has no stage (every stage
/// PAID/ON_HOLD) — which must be excluded.
ProjectPayment _pp(String? status, {DateTime? dueDate, int id = 1}) {
  final stage = status == null
      ? null
      : NextPaymentStage(
          stageNumber: 1,
          stageName: 'Stage 1',
          dueDate: dueDate,
          daysUntilDue: null,
          status: status,
          netPayableAmount: 1000,
          stagePercentage: 0.1,
          percentOfContract: 10,
          totalStages: 10,
        );
  return ProjectPayment(
    project: ProjectCard(id: id, name: 'Project $id', progress: 0),
    milestone: NextPaymentMilestone(
      stage: stage,
      summary: const NextPaymentSummary(
        totalContractValue: 100000,
        totalPaid: 0,
        totalOutstanding: 100000,
        stageCount: 10,
      ),
    ),
  );
}

void main() {
  group('selectRaisedPayments', () {
    test('keeps only INVOICED/DUE/OVERDUE; excludes UPCOMING, PAID, ON_HOLD, null stage', () {
      final result = selectRaisedPayments([
        _pp('UPCOMING'),
        _pp('INVOICED'),
        _pp('PAID'),
        _pp('DUE'),
        _pp('ON_HOLD'),
        _pp('OVERDUE'),
        _pp(null), // milestone with no stage
      ]);
      expect(result.length, 3);
      expect(
        result.map((p) => p.milestone.stage!.status).toSet(),
        {'INVOICED', 'DUE', 'OVERDUE'},
      );
    });

    test('sorts by urgency: OVERDUE -> DUE -> INVOICED', () {
      final result = selectRaisedPayments([
        _pp('INVOICED'),
        _pp('OVERDUE'),
        _pp('DUE'),
      ]);
      expect(
        result.map((p) => p.milestone.stage!.status).toList(),
        ['OVERDUE', 'DUE', 'INVOICED'],
      );
    });

    test('within same status, earliest dueDate first and null dueDate last', () {
      final result = selectRaisedPayments([
        _pp('DUE', dueDate: DateTime(2026, 6, 10), id: 1),
        _pp('DUE', dueDate: null, id: 2),
        _pp('DUE', dueDate: DateTime(2026, 6, 1), id: 3),
      ]);
      expect(result.map((p) => p.project.id).toList(), [3, 1, 2]);
    });

    test('empty input returns empty', () {
      expect(selectRaisedPayments(const []), isEmpty);
    });
  });
}
