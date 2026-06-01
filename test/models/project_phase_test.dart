import 'package:flutter_test/flutter_test.dart';
import 'package:wd_cust_mobile_app/models/project_phase.dart';

void main() {
  group('ProjectPhase.displayName', () {
    test('maps each phase to its label', () {
      expect(ProjectPhase.planning.displayName, 'Planning');
      expect(ProjectPhase.design.displayName, 'Design');
      expect(ProjectPhase.construction.displayName, 'Construction');
      expect(ProjectPhase.completed.displayName, 'Completed');
      expect(ProjectPhase.onHold.displayName, 'On Hold');
    });
  });

  group('ProjectPhase.shortDescription', () {
    test('returns a non-empty description per phase', () {
      for (final p in ProjectPhase.values) {
        expect(p.shortDescription, isNotEmpty);
      }
      expect(ProjectPhase.construction.shortDescription,
          'Work in progress on site');
      expect(ProjectPhase.onHold.shortDescription,
          'Project temporarily paused');
    });
  });

  group('ProjectPhase.order', () {
    test('is 1-based index', () {
      expect(ProjectPhase.planning.order, 1);
      expect(ProjectPhase.design.order, 2);
      expect(ProjectPhase.construction.order, 3);
      expect(ProjectPhase.completed.order, 4);
      expect(ProjectPhase.onHold.order, 5);
    });
  });

  group('ProjectPhase.fromString', () {
    test('parses canonical backend values', () {
      expect(ProjectPhase.fromString('PLANNING'), ProjectPhase.planning);
      expect(ProjectPhase.fromString('DESIGN'), ProjectPhase.design);
      expect(
          ProjectPhase.fromString('CONSTRUCTION'), ProjectPhase.construction);
      expect(ProjectPhase.fromString('COMPLETED'), ProjectPhase.completed);
      expect(ProjectPhase.fromString('ON_HOLD'), ProjectPhase.onHold);
    });

    test('maps legacy execution-stage aliases to construction', () {
      expect(ProjectPhase.fromString('EXECUTION'), ProjectPhase.construction);
      expect(ProjectPhase.fromString('FOUNDATION'), ProjectPhase.construction);
      expect(ProjectPhase.fromString('FINISHING'), ProjectPhase.construction);
    });

    test('maps legacy completion aliases to completed', () {
      expect(ProjectPhase.fromString('COMPLETION'), ProjectPhase.completed);
      expect(ProjectPhase.fromString('HANDOVER'), ProjectPhase.completed);
      expect(ProjectPhase.fromString('WARRANTY'), ProjectPhase.completed);
    });

    test('normalizes case, whitespace and spaces-to-underscores', () {
      expect(ProjectPhase.fromString('  design  '), ProjectPhase.design);
      expect(ProjectPhase.fromString('on hold'), ProjectPhase.onHold);
      expect(ProjectPhase.fromString('Construction'),
          ProjectPhase.construction);
    });

    test('defaults to planning for null, empty, or unknown values', () {
      expect(ProjectPhase.fromString(null), ProjectPhase.planning);
      expect(ProjectPhase.fromString(''), ProjectPhase.planning);
      expect(ProjectPhase.fromString('   '), ProjectPhase.planning);
      expect(ProjectPhase.fromString('SOMETHING_ELSE'), ProjectPhase.planning);
    });
  });
}
