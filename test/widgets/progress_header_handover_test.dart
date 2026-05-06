import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wd_cust_mobile_app/models/expected_handover_model.dart';
import 'package:wd_cust_mobile_app/models/project_models.dart';
import 'package:wd_cust_mobile_app/widgets/progress_header.dart';

Project _makeProject() {
  return Project(
    id: 'p-1',
    name: 'Test Project',
    location: 'Loc',
    city: 'C',
    area: 'A',
    status: ProjectStatus.active,
    progress: 50,
    nextMilestone: 'Foundation',
    nextMilestoneDate: DateTime(2026, 6, 1),
    thumbnailUrl: '',
    lastUpdate: '',
    lastUpdatedAt: DateTime(2026, 5, 1),
    totalBudget: 0,
    paidAmount: 0,
    dueAmount: 0,
    qcCompleted: 0,
    qcPending: 0,
    activeQueries: 0,
    galleryPhotos: 0,
    details: ProjectDetails(
      description: '',
      startDate: DateTime(2026, 1, 1),
      expectedEndDate: DateTime(2026, 12, 31),
      contractor: '',
      architect: '',
      progressBreakdown: const {},
      milestones: const [],
    ),
  );
}

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void main() {
  // Use a wide viewport so the rich row in the material-delay state has
  // room to lay out without overflow on the default 800x600 test surface.
  void widenView(WidgetTester tester) {
    tester.view.physicalSize = const Size(2400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('ProgressHeader handover row', () {
    testWidgets('State 1: no schedule → "Schedule not yet approved"',
        (tester) async {
      widenView(tester);
      const handover = ExpectedHandover(
        projectFinishDate: null,
        baselineFinishDate: null,
        weeksRemaining: null,
        hasMaterialDelay: false,
      );
      await tester.pumpWidget(_wrap(ProgressHeader(
        project: _makeProject(),
        showBreakdown: false,
        handover: handover,
        now: DateTime(2026, 5, 5),
      )));
      // No pumpAndSettle (avoids potential Tooltip animation deadlocks).
      await tester.pump();

      expect(find.text('Schedule not yet approved'), findsOneWidget);
      expect(find.textContaining('Expected handover:'), findsNothing);
    });

    testWidgets('State 2: on-track → single date + (in N weeks)',
        (tester) async {
      widenView(tester);
      const handover = ExpectedHandover(
        projectFinishDate: null,
        baselineFinishDate: null,
        weeksRemaining: 14,
        hasMaterialDelay: false,
      );
      // State 2 uses projectFinishDate non-null + baselineFinishDate equal:
      final h2 = ExpectedHandover(
        projectFinishDate: DateTime(2026, 8, 12),
        baselineFinishDate: DateTime(2026, 8, 12),
        weeksRemaining: handover.weeksRemaining,
        hasMaterialDelay: handover.hasMaterialDelay,
      );

      await tester.pumpWidget(_wrap(ProgressHeader(
        project: _makeProject(),
        showBreakdown: false,
        handover: h2,
        now: DateTime(2026, 5, 5),
      )));
      await tester.pump();

      expect(find.textContaining('Expected handover:'), findsOneWidget);
      expect(find.textContaining('12 Aug 2026'), findsOneWidget);
      expect(find.textContaining('14 weeks'), findsOneWidget);
      // No struck-through text.
      final struckThrough = find.byWidgetPredicate((w) =>
          w is Text && w.style?.decoration == TextDecoration.lineThrough);
      expect(struckThrough, findsNothing);
    });

    testWidgets('State 3: minor delay (no MATERIAL flag) renders like State 2',
        (tester) async {
      widenView(tester);
      final h = ExpectedHandover(
        projectFinishDate: DateTime(2026, 8, 12),
        baselineFinishDate: DateTime(2026, 8, 5),
        weeksRemaining: 14,
        hasMaterialDelay: false,
      );

      await tester.pumpWidget(_wrap(ProgressHeader(
        project: _makeProject(),
        showBreakdown: false,
        handover: h,
        now: DateTime(2026, 5, 5),
      )));
      await tester.pump();

      expect(find.textContaining('12 Aug 2026'), findsOneWidget);
      // 5 Aug 2026 (the baseline) is NOT shown as struck-through.
      final struckThrough = find.byWidgetPredicate((w) =>
          w is Text && w.style?.decoration == TextDecoration.lineThrough);
      expect(struckThrough, findsNothing);
    });

    testWidgets(
        'State 4: material delay → struck-through baseline + new date + was/now',
        (tester) async {
      widenView(tester);
      final h = ExpectedHandover(
        projectFinishDate: DateTime(2026, 8, 12),
        baselineFinishDate: DateTime(2026, 8, 5),
        weeksRemaining: 14,
        hasMaterialDelay: true,
      );

      await tester.pumpWidget(_wrap(ProgressHeader(
        project: _makeProject(),
        showBreakdown: false,
        handover: h,
        now: DateTime(2026, 5, 5),
      )));
      await tester.pump();

      // Baseline date present, struck-through.
      final struckThrough = find.byWidgetPredicate((w) =>
          w is Text &&
          w.style?.decoration == TextDecoration.lineThrough &&
          w.data == '5 Aug 2026');
      expect(struckThrough, findsOneWidget);
      // New date present, NOT struck-through.
      expect(find.text('12 Aug 2026'), findsOneWidget);
      // Secondary "(was N weeks, now M weeks)" line.
      expect(find.textContaining('was'), findsOneWidget);
      expect(find.textContaining('now'), findsOneWidget);
    });
  });
}
