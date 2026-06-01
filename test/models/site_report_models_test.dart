import 'package:flutter_test/flutter_test.dart';
import 'package:wd_cust_mobile_app/models/site_report_models.dart';

void main() {
  // ReportType.fromJson maps backend SCREAMING_SNAKE_CASE → camelCase enum.
  group('ReportType.fromJson', () {
    test('maps each backend SCREAMING_SNAKE_CASE value', () {
      expect(ReportType.fromJson('DAILY_PROGRESS'), ReportType.dailyProgress);
      expect(ReportType.fromJson('QUALITY_CHECK'), ReportType.qualityCheck);
      expect(ReportType.fromJson('SAFETY_INCIDENT'), ReportType.safetyIncident);
      expect(
          ReportType.fromJson('MATERIAL_DELIVERY'), ReportType.materialDelivery);
      expect(ReportType.fromJson('SITE_VISIT_SUMMARY'),
          ReportType.siteVisitSummary);
      expect(ReportType.fromJson('OTHER'), ReportType.other);
    });

    test('defaults to dailyProgress when null', () {
      expect(ReportType.fromJson(null), ReportType.dailyProgress);
    });

    test('falls back to matching the camelCase enum name', () {
      // Not in the SCREAMING_SNAKE map, but matches an enum .name directly.
      expect(ReportType.fromJson('qualityCheck'), ReportType.qualityCheck);
    });

    test('unknown non-null value falls back to other', () {
      expect(ReportType.fromJson('SOMETHING_NEW'), ReportType.other);
    });

    test('label exposes a human-readable string', () {
      expect(ReportType.dailyProgress.label, 'Daily Progress');
      expect(ReportType.siteVisitSummary.label, 'Site Visit Summary');
      expect(ReportType.other.label, 'Other');
    });
  });

  group('SiteReportPhoto.fromJson', () {
    test('parses a real-shaped photo row', () {
      final json = {
        'id': 9001,
        'photoUrl': '/uploads/site-reports/42/img_001.jpg',
        'storagePath': 'site-reports/42/img_001.jpg',
        'createdAt': '2026-04-23T10:15:00',
      };

      final photo = SiteReportPhoto.fromJson(json);

      expect(photo.id, 9001);
      expect(photo.photoUrl, '/uploads/site-reports/42/img_001.jpg');
      expect(photo.storagePath, 'site-reports/42/img_001.jpg');
      expect(photo.createdAt, DateTime.parse('2026-04-23T10:15:00'));
    });

    test('defaults missing url/path to empty string and null id/date', () {
      final photo = SiteReportPhoto.fromJson({});
      expect(photo.id, isNull);
      expect(photo.photoUrl, '');
      expect(photo.storagePath, '');
      expect(photo.createdAt, isNull);
    });

    test('fullUrl returns absolute URLs as-is', () {
      // Absolute-URL branch short-circuits before touching ApiConfig.baseUrl
      // (which needs DotEnv); the relative-path branch is excluded here to
      // keep these tests pure parsing with no env/config dependency.
      final photo = SiteReportPhoto.fromJson({
        'photoUrl': 'https://cdn.example.com/a.jpg',
        'storagePath': 'x',
      });
      expect(photo.fullUrl, 'https://cdn.example.com/a.jpg');
    });
  });

  group('SiteReportSummaryRow.fromJson', () {
    test('parses a real-shaped summary row', () {
      final row = SiteReportSummaryRow.fromJson({
        'projectId': 50,
        'projectName': 'Krishnan Residence',
        'count': 12,
      });
      expect(row.projectId, 50);
      expect(row.projectName, 'Krishnan Residence');
      expect(row.count, 12);
    });

    test('coerces num projectId/count to int and tolerates null name', () {
      final row = SiteReportSummaryRow.fromJson({
        'projectId': 50.0,
        'projectName': null,
        'count': 3.0,
      });
      expect(row.projectId, 50);
      expect(row.count, 3);
      expect(row.projectName, isNull);
    });
  });

  group('SiteReportActivity.fromJson', () {
    test('parses a fully-populated activity', () {
      final json = {
        'id': 7,
        'name': 'RCC slab pour',
        'manpower': 8,
        'equipment': 'Concrete pump',
        'notes': 'Pour completed by 4pm',
      };

      final a = SiteReportActivity.fromJson(json);

      expect(a.id, 7);
      expect(a.name, 'RCC slab pour');
      expect(a.manpower, 8);
      expect(a.equipment, 'Concrete pump');
      expect(a.notes, 'Pour completed by 4pm');
    });

    test('defaults missing name to empty and leaves optionals null', () {
      final a = SiteReportActivity.fromJson({});
      expect(a.id, isNull);
      expect(a.name, '');
      expect(a.manpower, isNull);
      expect(a.equipment, isNull);
      expect(a.notes, isNull);
    });

    test('toJson omits null/empty optionals', () {
      final a = SiteReportActivity.fromJson({'name': 'Plastering'});
      final out = a.toJson();
      expect(out, {'name': 'Plastering'});
      expect(out.containsKey('id'), isFalse);
      expect(out.containsKey('manpower'), isFalse);
    });
  });

  group('SiteReport.fromJson', () {
    test('parses a full flat customer-API DTO with photos and activities', () {
      final json = {
        'id': 555,
        'projectId': 50,
        'projectName': 'Krishnan Residence',
        'title': 'Daily Progress 23 Apr',
        'description': 'Slab pour and curing',
        'reportDate': '2026-04-23T09:00:00',
        'status': 'APPROVED',
        'reportType': 'DAILY_PROGRESS',
        'siteVisitId': 321,
        'submittedByName': 'Ravi Engineer',
        'weather': 'Sunny',
        'manpowerDeployed': 12,
        'equipmentUsed': 'Pump, vibrator',
        'workProgress': '35%',
        'latitude': 10.5,
        'longitude': 76.2,
        'distanceFromProject': 0.4,
        'photos': [
          {
            'id': 1,
            'photoUrl': '/uploads/p1.jpg',
            'storagePath': 'p1.jpg',
            'createdAt': '2026-04-23T09:10:00',
          },
        ],
        'activities': [
          {'id': 11, 'name': 'RCC slab pour', 'manpower': 8},
          {'id': 12, 'name': 'Plastering', 'manpower': 4},
        ],
      };

      final r = SiteReport.fromJson(json);

      expect(r.id, 555);
      expect(r.projectId, 50);
      expect(r.projectName, 'Krishnan Residence');
      expect(r.title, 'Daily Progress 23 Apr');
      expect(r.description, 'Slab pour and curing');
      expect(r.reportDate, DateTime.parse('2026-04-23T09:00:00'));
      expect(r.status, 'APPROVED');
      expect(r.reportType, ReportType.dailyProgress);
      expect(r.siteVisitId, 321);
      expect(r.submittedByName, 'Ravi Engineer');
      expect(r.weather, 'Sunny');
      expect(r.manpowerDeployed, 12);
      expect(r.equipmentUsed, 'Pump, vibrator');
      expect(r.workProgress, '35%');
      expect(r.latitude, 10.5);
      expect(r.longitude, 76.2);
      expect(r.distanceFromProject, 0.4);
      expect(r.photos.length, 1);
      expect(r.photos.first.photoUrl, '/uploads/p1.jpg');
      expect(r.activities.length, 2);
      expect(r.activities.first.name, 'RCC slab pour');
      expect(r.activities[1].manpower, 4);
    });

    test('applies defaults for a minimal/empty payload', () {
      final before = DateTime.now();
      final r = SiteReport.fromJson({});
      final after = DateTime.now();

      expect(r.id, isNull);
      expect(r.projectId, 0); // sentinel
      expect(r.projectName, isNull);
      expect(r.title, 'Untitled Report');
      expect(r.description, isNull);
      expect(r.status, 'SUBMITTED');
      expect(r.reportType, ReportType.dailyProgress); // null reportType default
      expect(r.siteVisitId, isNull);
      expect(r.photos, isEmpty);
      expect(r.activities, isEmpty);
      // reportDate falls back to DateTime.now()
      expect(
          r.reportDate.isAfter(before.subtract(const Duration(seconds: 1))) &&
              r.reportDate.isBefore(after.add(const Duration(seconds: 1))),
          isTrue);
    });

    test('falls back to createdAt when reportDate is absent', () {
      final r = SiteReport.fromJson({
        'createdAt': '2026-04-20T08:00:00',
      });
      expect(r.reportDate, DateTime.parse('2026-04-20T08:00:00'));
    });

    test('derives submittedByName from nested submittedBy entity', () {
      final r = SiteReport.fromJson({
        'submittedBy': {'firstName': 'Asha', 'lastName': 'Nair'},
      });
      expect(r.submittedByName, 'Asha Nair');
    });

    test('coerces num latitude/longitude/distance to double', () {
      final r = SiteReport.fromJson({
        'latitude': 10,
        'longitude': 76,
        'distanceFromProject': 1,
      });
      expect(r.latitude, 10.0);
      expect(r.longitude, 76.0);
      expect(r.distanceFromProject, 1.0);
    });
  });
}
