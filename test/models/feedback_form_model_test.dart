import 'package:flutter_test/flutter_test.dart';
import 'package:wd_cust_mobile_app/models/project_module_models.dart';

void main() {
  group('FeedbackForm.fromJson', () {
    // Regression lock for the customer Feedback screen/dialog crash
    // ("TypeError: null: type 'Null' is not a subtype of type 'int'").
    // A feedback form can be unattributed (no creator user on the row), so the
    // customer API returns createdById/createdByName as null. The customer only
    // fills the form (the form author isn't surfaced), so we just need to parse
    // without crashing. Payload mirrors the REAL shape from
    //   GET /api/projects/{uuid}/feedback
    // for demo project 49 form id 1.
    test('tolerates a null creator (unattributed form)', () {
      final json = {
        'id': 1,
        'projectId': 49,
        'title': 'Construction Progress Feedback',
        'description': null,
        'formType': null,
        'createdById': null,
        'createdByName': null,
        'createdAt': '2026-05-27T19:07:32.597606',
        'isActive': true,
        'isCompleted': true,
      };

      final form = FeedbackForm.fromJson(json);

      expect(form.id, 1);
      expect(form.projectId, 49);
      expect(form.title, 'Construction Progress Feedback');
      expect(form.createdById, 0);
      expect(form.createdByName, '');
      expect(form.isCompleted, true);
    });

    test('keeps a real creator when present', () {
      final json = {
        'id': 2,
        'projectId': 49,
        'title': 'Handover Satisfaction',
        'createdById': 5,
        'createdByName': 'Walldot Builders',
        'createdAt': '2026-05-27T19:07:32.0',
        'isActive': true,
      };

      final form = FeedbackForm.fromJson(json);

      expect(form.createdById, 5);
      expect(form.createdByName, 'Walldot Builders');
    });
  });
}
