import 'package:flutter_test/flutter_test.dart';
import 'package:wd_cust_mobile_app/models/next_payment_milestone.dart';

// NOTE: next_payment_milestone_model_test.dart already covers
// NextPaymentMilestone.fromJson (the top-level wrapper). This file targets the
// two nested parsers it composes — NextPaymentStage.fromJson and
// NextPaymentSummary.fromJson — directly, plus the _toDouble coercion behaviour
// surfaced through them.

void main() {
  group('NextPaymentStage.fromJson', () {
    test('parses a full happy-path stage', () {
      final json = {
        'stageNumber': 4,
        'stageName': 'Plastering',
        'dueDate': '2026-05-15',
        'daysUntilDue': 5,
        'status': 'DUE',
        'netPayableAmount': 425000.50,
        'stagePercentage': 12.5,
        'percentOfContract': 12.5,
        'totalStages': 7,
      };

      final s = NextPaymentStage.fromJson(json);

      expect(s.stageNumber, 4);
      expect(s.stageName, 'Plastering');
      expect(s.dueDate, DateTime(2026, 5, 15));
      expect(s.daysUntilDue, 5);
      expect(s.status, 'DUE');
      expect(s.netPayableAmount, 425000.50);
      expect(s.stagePercentage, 12.5);
      expect(s.percentOfContract, 12.5);
      expect(s.totalStages, 7);
    });

    test('null dueDate and daysUntilDue stay null', () {
      final json = {
        'stageNumber': 2,
        'stageName': 'Foundation',
        'dueDate': null,
        'daysUntilDue': null,
        'status': 'UPCOMING',
        'netPayableAmount': 250000,
        'stagePercentage': 10,
        'percentOfContract': 10,
        'totalStages': 7,
      };

      final s = NextPaymentStage.fromJson(json);

      expect(s.dueDate, isNull);
      expect(s.daysUntilDue, isNull);
      expect(s.status, 'UPCOMING');
    });

    test('coerces int-shaped amounts/percentages to double', () {
      // Jackson sends whole-rupee BigDecimal as a bare JSON int.
      final json = {
        'stageNumber': 1,
        'stageName': 'Booking',
        'dueDate': '2026-05-15',
        'daysUntilDue': 0,
        'status': 'OVERDUE',
        'netPayableAmount': 425000, // int
        'stagePercentage': 12, // int
        'percentOfContract': 12, // int
        'totalStages': 1,
      };

      final s = NextPaymentStage.fromJson(json);

      expect(s.netPayableAmount, 425000.0);
      expect(s.netPayableAmount, isA<double>());
      expect(s.stagePercentage, 12.0);
      expect(s.percentOfContract, 12.0);
      expect(s.daysUntilDue, 0);
    });

    test('negative daysUntilDue (overdue) is preserved', () {
      final json = {
        'stageNumber': 3,
        'stageName': 'RCC',
        'dueDate': '2026-04-01',
        'daysUntilDue': -10,
        'status': 'OVERDUE',
        'netPayableAmount': 300000,
        'stagePercentage': 15,
        'percentOfContract': 15,
        'totalStages': 7,
      };

      expect(NextPaymentStage.fromJson(json).daysUntilDue, -10);
    });

    test('netPayableAmount null coerces to 0.0 via _toDouble', () {
      final json = {
        'stageNumber': 5,
        'stageName': 'Finishing',
        'dueDate': '2026-07-01',
        'daysUntilDue': 30,
        'status': 'UPCOMING',
        'netPayableAmount': null, // _toDouble(null) -> 0.0
        'stagePercentage': null,
        'percentOfContract': null,
        'totalStages': 7,
      };

      final s = NextPaymentStage.fromJson(json);

      expect(s.netPayableAmount, 0.0);
      expect(s.stagePercentage, 0.0);
      expect(s.percentOfContract, 0.0);
    });
  });

  group('NextPaymentSummary.fromJson', () {
    test('parses a full happy-path summary', () {
      final json = {
        'totalContractValue': 3500000.0,
        'totalPaid': 1400000.0,
        'totalOutstanding': 2100000.0,
        'stageCount': 7,
      };

      final s = NextPaymentSummary.fromJson(json);

      expect(s.totalContractValue, 3500000.0);
      expect(s.totalPaid, 1400000.0);
      expect(s.totalOutstanding, 2100000.0);
      expect(s.stageCount, 7);
    });

    test('coerces int-shaped totals to double', () {
      final json = {
        'totalContractValue': 3500000, // int
        'totalPaid': 0, // int
        'totalOutstanding': 3500000, // int
        'stageCount': 1,
      };

      final s = NextPaymentSummary.fromJson(json);

      expect(s.totalContractValue, 3500000.0);
      expect(s.totalContractValue, isA<double>());
      expect(s.totalPaid, 0.0);
      expect(s.totalOutstanding, 3500000.0);
      expect(s.stageCount, 1);
    });

    test('null totals coerce to 0.0 via _toDouble', () {
      final json = {
        'totalContractValue': null,
        'totalPaid': null,
        'totalOutstanding': null,
        'stageCount': 0,
      };

      final s = NextPaymentSummary.fromJson(json);

      expect(s.totalContractValue, 0.0);
      expect(s.totalPaid, 0.0);
      expect(s.totalOutstanding, 0.0);
      expect(s.stageCount, 0);
    });
  });
}
