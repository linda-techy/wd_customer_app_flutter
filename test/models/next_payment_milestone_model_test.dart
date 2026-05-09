import 'package:flutter_test/flutter_test.dart';
import 'package:wd_cust_mobile_app/models/next_payment_milestone.dart';

void main() {
  group('NextPaymentMilestone.fromJson', () {
    test('parses full happy-path payload', () {
      final json = {
        'stage': {
          'stageNumber': 4,
          'stageName': 'Plastering',
          'dueDate': '2026-05-15',
          'daysUntilDue': 5,
          'status': 'DUE',
          'netPayableAmount': 425000.00,
          'stagePercentage': 12.0,
          'percentOfContract': 12.0,
          'totalStages': 7,
        },
        'summary': {
          'totalContractValue': 3500000.00,
          'totalPaid': 1400000.00,
          'totalOutstanding': 2100000.00,
          'stageCount': 7,
        },
      };

      final m = NextPaymentMilestone.fromJson(json);

      expect(m.stage, isNotNull);
      expect(m.stage!.stageNumber, 4);
      expect(m.stage!.stageName, 'Plastering');
      expect(m.stage!.dueDate, DateTime(2026, 5, 15));
      expect(m.stage!.daysUntilDue, 5);
      expect(m.stage!.status, 'DUE');
      expect(m.stage!.netPayableAmount, 425000.00);
      expect(m.stage!.percentOfContract, 12.0);
      expect(m.stage!.totalStages, 7);
      expect(m.summary.stageCount, 7);
      expect(m.summary.totalContractValue, 3500000.00);
    });

    test('parses null stage (all paid)', () {
      final json = {
        'stage': null,
        'summary': {
          'totalContractValue': 3500000.00,
          'totalPaid': 3500000.00,
          'totalOutstanding': 0,
          'stageCount': 7,
        },
      };

      final m = NextPaymentMilestone.fromJson(json);

      expect(m.stage, isNull);
      expect(m.summary.totalOutstanding, 0);
    });

    test('parses missing dueDate / daysUntilDue', () {
      final json = {
        'stage': {
          'stageNumber': 2,
          'stageName': 'Foundation',
          'dueDate': null,
          'daysUntilDue': null,
          'status': 'UPCOMING',
          'netPayableAmount': 250000,
          'stagePercentage': 10,
          'percentOfContract': 10.0,
          'totalStages': 7,
        },
        'summary': {
          'totalContractValue': 2500000,
          'totalPaid': 0,
          'totalOutstanding': 2500000,
          'stageCount': 7,
        },
      };

      final m = NextPaymentMilestone.fromJson(json);

      expect(m.stage!.dueDate, isNull);
      expect(m.stage!.daysUntilDue, isNull);
    });

    test('coerces int-shaped numerics into double for amounts', () {
      // Jackson sends BigDecimal as a JSON number; whole-rupee values
      // arrive as int over the wire (no decimal). The model must accept both.
      final json = {
        'stage': {
          'stageNumber': 1,
          'stageName': 'Booking',
          'dueDate': '2026-05-15',
          'daysUntilDue': 5,
          'status': 'DUE',
          'netPayableAmount': 425000, // int, not double
          'stagePercentage': 12,
          'percentOfContract': 12,
          'totalStages': 1,
        },
        'summary': {
          'totalContractValue': 3500000,
          'totalPaid': 0,
          'totalOutstanding': 3500000,
          'stageCount': 1,
        },
      };

      final m = NextPaymentMilestone.fromJson(json);

      expect(m.stage!.netPayableAmount, 425000.0);
      expect(m.stage!.percentOfContract, 12.0);
    });
  });
}
