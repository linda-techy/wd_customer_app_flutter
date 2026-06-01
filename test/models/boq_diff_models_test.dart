import 'package:flutter_test/flutter_test.dart';
import 'package:wd_cust_mobile_app/models/boq_diff_models.dart';

void main() {
  group('BoqRevision.fromJson', () {
    test('parses a real-shaped revision row', () {
      final r = BoqRevision.fromJson({
        'id': 12,
        'revisionNumber': 3,
        'status': 'APPROVED',
        'createdAt': '2026-05-01T10:00:00',
        'totalValueExGst': 1500000.0,
        'totalValueInclGst': 1770000.0,
      });

      expect(r.id, 12);
      expect(r.revisionNumber, 3);
      expect(r.status, 'APPROVED');
      expect(r.createdAt, '2026-05-01T10:00:00');
      expect(r.totalValueExGst, 1500000.0);
      expect(r.totalValueInclGst, 1770000.0);
    });

    test('tolerates missing optionals (status empty, values null)', () {
      final r = BoqRevision.fromJson({'id': 5});
      expect(r.id, 5);
      expect(r.revisionNumber, isNull);
      expect(r.status, ''); // status defaults to empty string
      expect(r.createdAt, isNull);
      // totals run through _d(), which collapses null → 0.0 (NOT null).
      expect(r.totalValueExGst, 0.0);
      expect(r.totalValueInclGst, 0.0);
    });

    test('coerces numeric id/revisionNumber from num', () {
      final r = BoqRevision.fromJson({'id': 7.0, 'revisionNumber': 2.0});
      expect(r.id, 7);
      expect(r.revisionNumber, 2);
    });

    test('parses string-typed totals via _d helper', () {
      final r = BoqRevision.fromJson({
        'id': 1,
        'totalValueExGst': '1234.5',
        'totalValueInclGst': '1456.7',
      });
      expect(r.totalValueExGst, 1234.5);
      expect(r.totalValueInclGst, 1456.7);
    });

    test('displayLabel uses revisionNumber and maps status', () {
      final approved = BoqRevision.fromJson(
          {'id': 12, 'revisionNumber': 3, 'status': 'APPROVED'});
      expect(approved.displayLabel, 'Rev 3 — Approved');

      final pending = BoqRevision.fromJson(
          {'id': 9, 'revisionNumber': 1, 'status': 'PENDING_APPROVAL'});
      expect(pending.displayLabel, 'Rev 1 — Pending');
    });

    test('displayLabel falls back to Doc #id without revisionNumber', () {
      final r = BoqRevision.fromJson({'id': 88, 'status': 'DRAFT'});
      expect(r.displayLabel, 'Doc #88 — Draft');
    });

    test('displayLabel passes through unknown status verbatim', () {
      final r = BoqRevision.fromJson({'id': 4, 'status': 'SUPERSEDED'});
      expect(r.displayLabel, 'Doc #4 — SUPERSEDED');
    });
  });

  group('BoqDiffItem.fromJson', () {
    test('parses a fully-populated added/removed item', () {
      final item = BoqDiffItem.fromJson({
        'itemCode': 'RF-01',
        'description': 'Sloped tiled roof',
        'quantity': 120.0,
        'unit': 'sqm',
        'rate': 850.0,
        'amount': 102000.0,
      });

      expect(item.itemCode, 'RF-01');
      expect(item.description, 'Sloped tiled roof');
      expect(item.quantity, 120.0);
      expect(item.unit, 'sqm');
      expect(item.rate, 850.0);
      expect(item.amount, 102000.0);
    });

    test('defaults description to empty and numbers to 0.0 via _d', () {
      // _d collapses null → 0.0 (NOT null) for quantity/rate/amount.
      final item = BoqDiffItem.fromJson({});
      expect(item.itemCode, isNull);
      expect(item.description, '');
      expect(item.quantity, 0.0);
      expect(item.unit, isNull);
      expect(item.rate, 0.0);
      expect(item.amount, 0.0);
    });

    test('parses string-typed numerics', () {
      final item = BoqDiffItem.fromJson({
        'description': 'x',
        'quantity': '5',
        'rate': '99.5',
        'amount': '497.5',
      });
      expect(item.quantity, 5.0);
      expect(item.rate, 99.5);
      expect(item.amount, 497.5);
    });
  });

  group('BoqDiffChange.fromJson', () {
    test('preserves dynamic old/new values of any type', () {
      final c = BoqDiffChange.fromJson({'oldValue': 100, 'newValue': 120});
      expect(c.oldValue, 100);
      expect(c.newValue, 120);

      final s = BoqDiffChange.fromJson({'oldValue': 'A', 'newValue': 'B'});
      expect(s.oldValue, 'A');
      expect(s.newValue, 'B');
    });

    test('tolerates null old/new values', () {
      final c = BoqDiffChange.fromJson({});
      expect(c.oldValue, isNull);
      expect(c.newValue, isNull);
    });
  });

  group('BoqDiffModifiedItem.fromJson', () {
    test('parses changes map into BoqDiffChange entries', () {
      final m = BoqDiffModifiedItem.fromJson({
        'itemCode': 'RF-01',
        'description': 'Sloped tiled roof',
        'changes': {
          'rate': {'oldValue': 800, 'newValue': 850},
          'quantity': {'oldValue': 100, 'newValue': 120},
        },
      });

      expect(m.itemCode, 'RF-01');
      expect(m.description, 'Sloped tiled roof');
      expect(m.changes.keys, containsAll(['rate', 'quantity']));
      expect(m.changes['rate']!.oldValue, 800);
      expect(m.changes['rate']!.newValue, 850);
      expect(m.changes['quantity']!.newValue, 120);
    });

    test('defaults itemCode/description to empty and changes to empty map', () {
      final m = BoqDiffModifiedItem.fromJson({});
      expect(m.itemCode, '');
      expect(m.description, '');
      expect(m.changes, isEmpty);
    });
  });

  group('BoqDiffSummary.fromJson', () {
    test('parses a real-shaped summary', () {
      final s = BoqDiffSummary.fromJson({
        'oldTotal': 1500000.0,
        'newTotal': 1620000.0,
        'delta': 120000.0,
        'addedCount': 2,
        'removedCount': 1,
        'modifiedCount': 3,
        'fromRevision': 2,
        'toRevision': 3,
      });

      expect(s.oldTotal, 1500000.0);
      expect(s.newTotal, 1620000.0);
      expect(s.delta, 120000.0);
      expect(s.addedCount, 2);
      expect(s.removedCount, 1);
      expect(s.modifiedCount, 3);
      expect(s.fromRevision, 2);
      expect(s.toRevision, 3);
      expect(s.totalChanges, 6); // 2 + 1 + 3
    });

    test('defaults totals to 0.0 and counts to 0; revisions null', () {
      final s = BoqDiffSummary.fromJson({});
      expect(s.oldTotal, 0.0);
      expect(s.newTotal, 0.0);
      expect(s.delta, 0.0);
      expect(s.addedCount, 0);
      expect(s.removedCount, 0);
      expect(s.modifiedCount, 0);
      expect(s.fromRevision, isNull);
      expect(s.toRevision, isNull);
      expect(s.totalChanges, 0);
    });
  });

  group('BoqDiffResult.fromJson', () {
    test('parses added/removed/modified lists and summary', () {
      final result = BoqDiffResult.fromJson({
        'added': [
          {'itemCode': 'A1', 'description': 'New item', 'amount': 5000.0},
        ],
        'removed': [
          {'itemCode': 'R1', 'description': 'Dropped item', 'amount': 2000.0},
        ],
        'modified': [
          {
            'itemCode': 'M1',
            'description': 'Changed item',
            'changes': {
              'rate': {'oldValue': 10, 'newValue': 12},
            },
          },
        ],
        'summary': {
          'oldTotal': 100.0,
          'newTotal': 103.0,
          'delta': 3.0,
          'addedCount': 1,
          'removedCount': 1,
          'modifiedCount': 1,
        },
      });

      expect(result.added.length, 1);
      expect(result.added.first.itemCode, 'A1');
      expect(result.removed.length, 1);
      expect(result.removed.first.itemCode, 'R1');
      expect(result.modified.length, 1);
      expect(result.modified.first.changes['rate']!.newValue, 12);
      expect(result.summary.delta, 3.0);
      expect(result.isEmpty, isFalse);
    });

    test('tolerates null lists and reports isEmpty', () {
      final result = BoqDiffResult.fromJson({
        'added': null,
        'removed': null,
        'modified': null,
        'summary': {
          'oldTotal': 0.0,
          'newTotal': 0.0,
          'delta': 0.0,
        },
      });

      expect(result.added, isEmpty);
      expect(result.removed, isEmpty);
      expect(result.modified, isEmpty);
      expect(result.isEmpty, isTrue);
    });
  });
}
