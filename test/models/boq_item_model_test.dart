import 'package:flutter_test/flutter_test.dart';
import 'package:wd_cust_mobile_app/models/project_module_models.dart';

void main() {
  group('BoqItem.fromJson', () {
    // Regression lock for the customer BoQ-screen crash
    // ("TypeError: null: type 'Null' is not a subtype of type 'int'").
    //
    // Work type is OPTIONAL on a BoQ item (portal migration V161 dropped the
    // legacy NOT NULL on boq_items.work_type_id), so the customer API legitimately
    // returns workTypeId: null. The model must tolerate it instead of crashing
    // the whole screen. This payload mirrors the REAL shape returned by
    //   GET /api/projects/{uuid}/boq
    // for demo project 49 item 101 (commercials redacted for the customer).
    test('tolerates a null workTypeId (work type is optional)', () {
      final json = {
        'id': 101,
        'projectId': 49,
        'workTypeId': null,
        'workTypeName': null,
        'categoryId': 18,
        'categoryName': 'Roofing & Finishing',
        'itemCode': 'RF-01',
        'description': 'Sloped tiled roof + parapet',
        // commercials redacted for the customer
        'quantity': null,
        'unit': null,
        'rate': null,
        'amount': null,
        'status': 'APPROVED',
        'executionPercentage': null,
        'billingPercentage': null,
        'createdById': null,
        'createdByName': null,
        'createdAt': '2026-04-23T10:00:00',
        'updatedAt': '2026-04-23T10:00:00',
        'isActive': true,
        'itemKind': 'BASE',
      };

      final item = BoqItem.fromJson(json);

      expect(item.id, 101);
      expect(item.projectId, 49);
      expect(item.workTypeId, 0); // null work type collapses to the 0 sentinel
      expect(item.workTypeName, '');
      expect(item.categoryName, 'Roofing & Finishing');
      expect(item.description, 'Sloped tiled roof + parapet');
      // redacted commercials stay null (not coerced to 0)
      expect(item.rate, isNull);
      expect(item.amount, isNull);
      expect(item.quantity, isNull);
      // grouping uses workTypeName→categoryName, so the row still renders
      expect(item.workTypeName.isNotEmpty ? item.workTypeName : item.categoryName,
          'Roofing & Finishing');
    });

    test('parses an item that does carry a work type', () {
      final json = {
        'id': 42,
        'projectId': 49,
        'workTypeId': 7,
        'workTypeName': 'RCC Superstructure',
        'categoryId': 12,
        'categoryName': 'RCC Superstructure',
        'description': 'GF slab/beams',
        'status': 'APPROVED',
        'createdAt': '2026-04-23T10:00:00',
        'updatedAt': '2026-04-23T10:00:00',
        'isActive': true,
        'itemKind': 'BASE',
      };

      final item = BoqItem.fromJson(json);

      expect(item.workTypeId, 7);
      expect(item.workTypeName, 'RCC Superstructure');
    });
  });
}
