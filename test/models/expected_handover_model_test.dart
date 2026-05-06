import 'package:flutter_test/flutter_test.dart';
import 'package:wd_cust_mobile_app/models/expected_handover_model.dart';

void main() {
  group('ExpectedHandover.fromJson', () {
    test('parses fully-populated JSON', () {
      final json = {
        'projectFinishDate': '2026-08-12',
        'baselineFinishDate': '2026-08-05',
        'weeksRemaining': 14,
        'hasMaterialDelay': true,
      };

      final h = ExpectedHandover.fromJson(json);

      expect(h.projectFinishDate, DateTime(2026, 8, 12));
      expect(h.baselineFinishDate, DateTime(2026, 8, 5));
      expect(h.weeksRemaining, 14);
      expect(h.hasMaterialDelay, true);
    });

    test('handles all-nullable fields as null', () {
      final json = {
        'projectFinishDate': null,
        'baselineFinishDate': null,
        'weeksRemaining': null,
        'hasMaterialDelay': false,
      };

      final h = ExpectedHandover.fromJson(json);

      expect(h.projectFinishDate, isNull);
      expect(h.baselineFinishDate, isNull);
      expect(h.weeksRemaining, isNull);
      expect(h.hasMaterialDelay, false);
    });

    test('partial data — only projectFinishDate + hasMaterialDelay set', () {
      final json = {
        'projectFinishDate': '2026-09-01',
        'baselineFinishDate': null,
        'weeksRemaining': null,
        'hasMaterialDelay': true,
      };

      final h = ExpectedHandover.fromJson(json);

      expect(h.projectFinishDate, DateTime(2026, 9, 1));
      expect(h.baselineFinishDate, isNull);
      expect(h.weeksRemaining, isNull);
      expect(h.hasMaterialDelay, true);
    });

    test('hasMaterialDelay defaults to false when omitted', () {
      final json = <String, dynamic>{
        'projectFinishDate': null,
        'baselineFinishDate': null,
        'weeksRemaining': null,
      };

      final h = ExpectedHandover.fromJson(json);

      expect(h.hasMaterialDelay, false);
    });
  });
}
