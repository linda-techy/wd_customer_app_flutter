import 'package:flutter_test/flutter_test.dart';
import 'package:wd_cust_mobile_app/models/project_module_models.dart';

void main() {
  group('QualityCheck.fromJson', () {
    // Regression lock for the customer Quality-Check screen crash
    // ("Failed to load quality checks: TypeError: null: type 'Null' is not a
    // subtype of type 'int'"). QC rows can be unattributed (no creator user),
    // so the customer API returns createdById/createdByName as null. The model
    // must tolerate that instead of crashing the whole screen, and surface a
    // sensible author label. Payload mirrors the REAL shape from
    //   GET /api/projects/{uuid}/quality-check
    // for demo project 49 QC id 2.
    test('tolerates a null creator (unattributed QC) and labels the author', () {
      final json = {
        'id': 2,
        'projectId': 49,
        'title': 'Ground floor slab – concrete pour ITP',
        'description': null,
        'sopReference': null,
        'status': 'ACTIVE',
        'priority': 'HIGH',
        'assignedToId': null,
        'assignedToName': null,
        'createdById': null,
        'createdByName': null,
        'createdAt': '2026-05-27T13:29:54.594686',
        'resolvedAt': null,
        'resolvedById': null,
        'resolvedByName': null,
        'resolutionNotes': null,
      };

      final qc = QualityCheck.fromJson(json);

      expect(qc.id, 2);
      expect(qc.projectId, 49);
      expect(qc.title, 'Ground floor slab – concrete pour ITP');
      expect(qc.status, 'ACTIVE');
      expect(qc.priority, 'HIGH');
      expect(qc.createdById, 0); // null creator collapses to 0
      // blank/null author renders as the construction role, not an empty string
      expect(qc.createdByName, 'Site Engineer');
    });

    test('empty-string author name also falls back to Site Engineer', () {
      final json = {
        'id': 3,
        'projectId': 49,
        'title': 'Brickwork – line, level & plumb',
        'status': 'ACTIVE',
        'priority': 'MEDIUM',
        'createdById': 30,
        'createdByName': '   ', // site engineer 30 has blank names
        'createdAt': '2026-05-27T13:29:54.0',
      };

      final qc = QualityCheck.fromJson(json);

      expect(qc.createdById, 30);
      expect(qc.createdByName, 'Site Engineer');
    });

    test('keeps a real author name when present', () {
      final json = {
        'id': 4,
        'projectId': 49,
        'title': 'Plastering check',
        'status': 'RESOLVED',
        'priority': 'LOW',
        'createdById': 12,
        'createdByName': 'Rajesh Nair',
        'createdAt': '2026-05-27T13:29:54.0',
      };

      final qc = QualityCheck.fromJson(json);

      expect(qc.createdByName, 'Rajesh Nair');
    });
  });
}
