import 'package:flutter_test/flutter_test.dart';
import 'package:wd_cust_mobile_app/models/timeline_item.dart';

void main() {
  group('TimelineItem.fromJson', () {
    test('parses a fully-populated timeline task', () {
      final json = {
        'taskId': 4001,
        'title': 'Excavation',
        'milestoneName': 'Foundation',
        'milestoneId': 7,
        'plannedStart': '2026-05-01T00:00:00',
        'plannedEnd': '2026-05-05T00:00:00',
        'actualStart': '2026-05-02T00:00:00',
        'actualEnd': '2026-05-06T00:00:00',
        'progressPercent': 100,
        'status': 'COMPLETED',
        'statusLabel': 'DONE',
        'crewName': 'Crew A',
      };

      final t = TimelineItem.fromJson(json);

      expect(t.taskId, 4001);
      expect(t.title, 'Excavation');
      expect(t.milestoneName, 'Foundation');
      expect(t.milestoneId, 7);
      expect(t.plannedStart, DateTime.parse('2026-05-01T00:00:00'));
      expect(t.plannedEnd, DateTime.parse('2026-05-05T00:00:00'));
      expect(t.actualStart, DateTime.parse('2026-05-02T00:00:00'));
      expect(t.actualEnd, DateTime.parse('2026-05-06T00:00:00'));
      expect(t.progressPercent, 100);
      expect(t.status, 'COMPLETED');
      expect(t.statusLabel, 'DONE');
      expect(t.crewName, 'Crew A');
    });

    test('applies defaults for a minimal payload', () {
      final t = TimelineItem.fromJson({'taskId': 5});

      expect(t.taskId, 5);
      expect(t.title, 'Task'); // default
      expect(t.milestoneName, isNull);
      expect(t.milestoneId, isNull);
      expect(t.plannedStart, isNull);
      expect(t.plannedEnd, isNull);
      expect(t.actualStart, isNull);
      expect(t.actualEnd, isNull);
      expect(t.progressPercent, 0); // default
      expect(t.status, 'PENDING'); // default
      expect(t.statusLabel, 'ON_TRACK'); // default
      expect(t.crewName, isNull);
    });

    test('coerces num taskId/milestoneId/progressPercent to int', () {
      final t = TimelineItem.fromJson({
        'taskId': 9.0,
        'milestoneId': 3.0,
        'progressPercent': 45.0,
      });
      expect(t.taskId, 9);
      expect(t.milestoneId, 3);
      expect(t.progressPercent, 45);
    });
  });

  group('TimelineSummary.fromJson', () {
    test('parses a real-shaped summary', () {
      final s = TimelineSummary.fromJson({
        'weekCount': 5,
        'upcomingCount': 8,
        'completedCount': 20,
        'projectProgressPercent': 42,
      });
      expect(s.weekCount, 5);
      expect(s.upcomingCount, 8);
      expect(s.completedCount, 20);
      expect(s.projectProgressPercent, 42);
    });

    test('defaults all counts to 0 when absent', () {
      final s = TimelineSummary.fromJson({});
      expect(s.weekCount, 0);
      expect(s.upcomingCount, 0);
      expect(s.completedCount, 0);
      expect(s.projectProgressPercent, 0);
    });
  });

  group('TimelinePage.fromJson', () {
    test('parses items list and pagination metadata', () {
      final page = TimelinePage.fromJson({
        'items': [
          {'taskId': 1, 'title': 'A'},
          {'taskId': 2, 'title': 'B'},
        ],
        'totalElements': 42,
        'totalPages': 3,
        'page': 1,
        'size': 20,
        'projectProgressPercent': 55,
      });

      expect(page.items.length, 2);
      expect(page.items.first.taskId, 1);
      expect(page.items[1].title, 'B');
      expect(page.totalElements, 42);
      expect(page.totalPages, 3);
      expect(page.page, 1);
      expect(page.size, 20);
      expect(page.projectProgressPercent, 55);
    });

    test('defaults: empty items, size 20, other counts 0', () {
      final page = TimelinePage.fromJson({});
      expect(page.items, isEmpty);
      expect(page.totalElements, 0);
      expect(page.totalPages, 0);
      expect(page.page, 0);
      expect(page.size, 20); // size defaults to 20
      expect(page.projectProgressPercent, 0);
    });
  });
}
