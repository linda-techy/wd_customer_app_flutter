import 'package:flutter_test/flutter_test.dart';
import 'package:wd_cust_mobile_app/models/change_request_summary.dart';

void main() {
  group('ChangeRequestSummary.fromJson', () {
    test('parses a full CR summary payload', () {
      final json = {
        'crId': 501,
        'title': 'Add solar water heater',
        'description': 'Customer-requested addition',
        'costImpactRupees': 45000,
        'timeImpactWorkingDays': 3,
      };

      final cr = ChangeRequestSummary.fromJson(json);

      expect(cr.crId, 501);
      expect(cr.title, 'Add solar water heater');
      expect(cr.description, 'Customer-requested addition');
      expect(cr.costImpactRupees, 45000);
      expect(cr.timeImpactWorkingDays, 3);
    });

    test('handles signed (negative) cost and double impact values', () {
      final cr = ChangeRequestSummary.fromJson({
        'crId': 502,
        'title': 'Reduce tile spec',
        'costImpactRupees': -12500.50,
        'timeImpactWorkingDays': -2,
      });

      expect(cr.crId, 502);
      expect(cr.title, 'Reduce tile spec');
      expect(cr.description, isNull);
      expect(cr.costImpactRupees, -12500.50);
      expect(cr.timeImpactWorkingDays, -2);
    });

    test('defaults cost and time to 0 when missing', () {
      final cr = ChangeRequestSummary.fromJson({
        'crId': 503,
        'title': 'Untitled change',
      });

      expect(cr.crId, 503);
      expect(cr.description, isNull);
      expect(cr.costImpactRupees, 0);
      expect(cr.timeImpactWorkingDays, 0);
    });

    test('coerces numeric crId from double', () {
      final cr = ChangeRequestSummary.fromJson({
        'crId': 504.0,
        'title': 'X',
      });
      expect(cr.crId, 504);
    });
  });
}
