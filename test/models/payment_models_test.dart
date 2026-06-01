import 'package:flutter_test/flutter_test.dart';
import 'package:wd_cust_mobile_app/models/payment_models.dart';

void main() {
  group('PaymentSchedule.fromJson', () {
    test('parses a full camelCase payload with nested transactions', () {
      final json = {
        'id': 7,
        'installmentNumber': 3,
        'description': 'Plastering stage',
        'amount': 425000.0,
        'dueDate': '2026-06-15',
        'status': 'PAID',
        'paidAmount': 425000.0,
        'paidDate': '2026-06-14',
        'transactions': [
          {
            'id': 11,
            'amount': 425000.0,
            'paymentMethod': 'UPI',
            'referenceNumber': 'UPI-123',
            'paymentDate': '2026-06-14',
            'receiptNumber': 'RCPT-9',
            'status': 'COMPLETED',
            'tdsPercentage': 0.0,
            'tdsAmount': 0.0,
            'netAmount': 425000.0,
          }
        ],
      };

      final s = PaymentSchedule.fromJson(json);

      expect(s.id, 7);
      expect(s.installmentNumber, 3);
      expect(s.description, 'Plastering stage');
      expect(s.amount, 425000.0);
      expect(s.dueDate, '2026-06-15');
      expect(s.status, 'PAID');
      expect(s.paidAmount, 425000.0);
      expect(s.paidDate, '2026-06-14');
      expect(s.transactions, hasLength(1));
      expect(s.transactions.first.id, 11);
      expect(s.transactions.first.paymentMethod, 'UPI');
      // computed getters
      expect(s.isPaid, isTrue);
      expect(s.isPending, isFalse);
      expect(s.isOverdue, isFalse);
      expect(s.remainingAmount, 0.0);
    });

    test('reads snake_case keys as fallbacks', () {
      final json = {
        'id': 2,
        'installment_number': 1,
        'description': 'Foundation',
        'amount': 250000,
        'due_date': '2026-05-01',
        'status': 'OVERDUE',
        'paid_amount': 50000,
        'paid_date': '2026-05-02',
        'transactions': [],
      };

      final s = PaymentSchedule.fromJson(json);

      expect(s.installmentNumber, 1);
      expect(s.dueDate, '2026-05-01');
      expect(s.paidAmount, 50000.0);
      expect(s.paidDate, '2026-05-02');
      expect(s.status, 'OVERDUE');
      expect(s.isOverdue, isTrue);
      expect(s.remainingAmount, 200000.0);
    });

    test('applies defaults for an empty/missing payload', () {
      final s = PaymentSchedule.fromJson({});

      expect(s.id, 0);
      expect(s.installmentNumber, 0);
      expect(s.description, '');
      expect(s.amount, 0.0);
      expect(s.dueDate, isNull);
      expect(s.status, 'PENDING'); // default
      expect(s.paidAmount, 0.0);
      expect(s.paidDate, isNull);
      expect(s.transactions, isEmpty);
      expect(s.isPending, isTrue);
    });

    test('coerces int amounts to double and omits transactions list', () {
      final json = {
        'id': 5,
        'installmentNumber': 2,
        'description': 'RCC',
        'amount': 500000, // int
        'status': 'PENDING',
        'paidAmount': 0, // int
        // no transactions key at all
      };

      final s = PaymentSchedule.fromJson(json);

      expect(s.amount, 500000.0);
      expect(s.paidAmount, 0.0);
      expect(s.transactions, isEmpty);
    });
  });

  group('PaymentTransaction.fromJson', () {
    test('parses a full camelCase payload', () {
      final json = {
        'id': 11,
        'amount': 425000.0,
        'paymentMethod': 'BANK_TRANSFER',
        'referenceNumber': 'NEFT-99',
        'paymentDate': '2026-06-14',
        'receiptNumber': 'RCPT-9',
        'status': 'COMPLETED',
        'tdsPercentage': 2.0,
        'tdsAmount': 8500.0,
        'netAmount': 416500.0,
      };

      final t = PaymentTransaction.fromJson(json);

      expect(t.id, 11);
      expect(t.amount, 425000.0);
      expect(t.paymentMethod, 'BANK_TRANSFER');
      expect(t.referenceNumber, 'NEFT-99');
      expect(t.paymentDate, '2026-06-14');
      expect(t.receiptNumber, 'RCPT-9');
      expect(t.status, 'COMPLETED');
      expect(t.tdsPercentage, 2.0);
      expect(t.tdsAmount, 8500.0);
      expect(t.netAmount, 416500.0);
    });

    test('reads snake_case fallbacks and coerces int numerics', () {
      final json = {
        'id': 12,
        'amount': 100000, // int
        'payment_method': 'CASH',
        'reference_number': 'CASH-1',
        'payment_date': '2026-06-10',
        'receipt_number': 'RCPT-10',
        'status': 'COMPLETED',
        'tds_percentage': 0, // int
        'tds_amount': 0, // int
        'net_amount': 100000, // int
      };

      final t = PaymentTransaction.fromJson(json);

      expect(t.amount, 100000.0);
      expect(t.paymentMethod, 'CASH');
      expect(t.referenceNumber, 'CASH-1');
      expect(t.paymentDate, '2026-06-10');
      expect(t.receiptNumber, 'RCPT-10');
      expect(t.tdsPercentage, 0.0);
      expect(t.tdsAmount, 0.0);
      expect(t.netAmount, 100000.0);
    });

    test('applies defaults for an empty payload', () {
      final t = PaymentTransaction.fromJson({});

      expect(t.id, 0);
      expect(t.amount, 0.0);
      expect(t.paymentMethod, isNull);
      expect(t.referenceNumber, isNull);
      expect(t.paymentDate, ''); // default
      expect(t.receiptNumber, isNull);
      expect(t.status, 'PENDING'); // default
      expect(t.tdsPercentage, 0.0);
      expect(t.tdsAmount, 0.0);
      expect(t.netAmount, 0.0);
    });
  });

  group('CustomerInvoice.fromJson', () {
    test('parses a full ISSUED invoice with dueDate', () {
      final json = {
        'id': 100,
        'invoiceNumber': 'INV-2026-100',
        'invoiceDate': '2026-05-01',
        'dueDate': '2026-05-31',
        'subTotal': 100000.0,
        'gstAmount': 18000.0,
        'totalAmount': 118000.0,
        'status': 'ISSUED',
        'createdAt': '2026-05-01T10:00:00',
      };

      final inv = CustomerInvoice.fromJson(json);

      expect(inv.id, 100);
      expect(inv.invoiceNumber, 'INV-2026-100');
      expect(inv.invoiceDate, DateTime(2026, 5, 1));
      expect(inv.dueDate, DateTime(2026, 5, 31));
      expect(inv.subTotal, 100000.0);
      expect(inv.gstAmount, 18000.0);
      expect(inv.totalAmount, 118000.0);
      expect(inv.status, 'ISSUED');
      expect(inv.createdAt, DateTime(2026, 5, 1, 10));
      expect(inv.isIssued, isTrue);
      expect(inv.isPaid, isFalse);
      expect(inv.isCancelled, isFalse);
    });

    test('applies defaults for missing optional/numeric fields', () {
      final json = {
        // id missing -> 0
        // invoiceNumber missing -> ''
        'invoiceDate': '2026-05-01',
        // dueDate missing -> null
        // subTotal/gstAmount/totalAmount missing -> 0.0
        // status missing -> 'ISSUED'
        'createdAt': '2026-05-01T10:00:00',
      };

      final inv = CustomerInvoice.fromJson(json);

      expect(inv.id, 0);
      expect(inv.invoiceNumber, '');
      expect(inv.dueDate, isNull);
      expect(inv.subTotal, 0.0);
      expect(inv.gstAmount, 0.0);
      expect(inv.totalAmount, 0.0);
      expect(inv.status, 'ISSUED'); // default
    });

    test('coerces int amounts to double', () {
      final json = {
        'id': 101,
        'invoiceNumber': 'INV-101',
        'invoiceDate': '2026-05-01',
        'dueDate': null,
        'subTotal': 100000, // int
        'gstAmount': 0, // int
        'totalAmount': 100000, // int
        'status': 'PAID',
        'createdAt': '2026-05-01T10:00:00',
      };

      final inv = CustomerInvoice.fromJson(json);

      expect(inv.subTotal, 100000.0);
      expect(inv.gstAmount, 0.0);
      expect(inv.totalAmount, 100000.0);
      expect(inv.dueDate, isNull);
      expect(inv.isPaid, isTrue);
      expect(inv.isOverdue, isFalse); // no dueDate
    });

    test('isOverdue true for an unpaid, past-due invoice', () {
      final json = {
        'id': 102,
        'invoiceNumber': 'INV-102',
        'invoiceDate': '2020-01-01',
        'dueDate': '2020-02-01', // long past
        'subTotal': 100000,
        'gstAmount': 0,
        'totalAmount': 100000,
        'status': 'ISSUED',
        'createdAt': '2020-01-01T10:00:00',
      };

      final inv = CustomerInvoice.fromJson(json);

      expect(inv.isOverdue, isTrue);
    });

    test('isOverdue false when a past-due invoice is already paid', () {
      final json = {
        'id': 103,
        'invoiceNumber': 'INV-103',
        'invoiceDate': '2020-01-01',
        'dueDate': '2020-02-01',
        'subTotal': 100000,
        'gstAmount': 0,
        'totalAmount': 100000,
        'status': 'PAID',
        'createdAt': '2020-01-01T10:00:00',
      };

      expect(CustomerInvoice.fromJson(json).isOverdue, isFalse);
    });
  });

  // PaymentSummary has no fromJson; just covering the computed getter for completeness.
  group('PaymentSummary', () {
    test('progress is paid/total when total > 0', () {
      final s = PaymentSummary(
          totalAmount: 1000000, paidAmount: 250000, dueAmount: 750000);
      expect(s.progress, 0.25);
    });

    test('progress is 0.0 when total is 0 (no divide-by-zero)', () {
      final s = PaymentSummary(totalAmount: 0, paidAmount: 0, dueAmount: 0);
      expect(s.progress, 0.0);
    });
  });
}
