import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wd_cust_mobile_app/models/api_models.dart';
import 'package:wd_cust_mobile_app/models/expected_handover_model.dart';
import 'package:wd_cust_mobile_app/screens/project/views/project_details_screen.dart';
import 'package:wd_cust_mobile_app/widgets/progress_header.dart';

// ---------------------------------------------------------------------------
// These tests cover the ProgressHeader wiring on the customer project-detail
// screen. Driving the full ProjectDetailsScreen would require mocking
// DashboardService (which has no test seam today), so we instead exercise the
// public adapter `buildAdaptedProgressHeaderProject` plus the rendered
// ProgressHeader subtree — exactly the contract the wiring change is
// responsible for.
// ---------------------------------------------------------------------------

ProjectDetails _makeDetails({
  String name = 'Test Project Alpha',
  double progress = 45,
  String? location = '123 Main St',
  String? uuid = 'test-uuid',
  int id = 1,
}) =>
    ProjectDetails(
      id: id,
      projectUuid: uuid,
      name: name,
      code: 'TPA-001',
      location: location,
      status: 'IN_PROGRESS',
      progress: progress,
      phase: 'Construction',
      projectType: 'Residential',
      startDate: '2025-01-15',
      endDate: '2025-12-31',
      sqFeet: 2500.0,
    );

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void _widenView(WidgetTester tester) {
  // Wide surface so the rich material-delay row lays out without overflow on
  // the default 800x600 test viewport (matches progress_header_handover_test).
  tester.view.physicalSize = const Size(2400, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

void main() {
  group('ProjectDetailsScreen ProgressHeader wiring', () {
    testWidgets(
      'buildAdaptedProgressHeaderProject copies name + progress from ProjectDetails',
      (tester) async {
        final details = _makeDetails(name: 'Alpha Tower', progress: 73);
        final adapted = buildAdaptedProgressHeaderProject(details, null);

        expect(adapted.name, 'Alpha Tower');
        expect(adapted.progress, 73);
        expect(adapted.id, 'test-uuid');
      },
    );

    testWidgets(
      'falls back to ProjectCard when ProjectDetails is null',
      (tester) async {
        final card = ProjectCard(
          id: 7,
          projectUuid: 'card-uuid',
          name: 'Card Only Project',
          progress: 12,
          location: 'Card location',
        );
        final adapted = buildAdaptedProgressHeaderProject(null, card);

        expect(adapted.name, 'Card Only Project');
        expect(adapted.progress, 12);
        expect(adapted.id, 'card-uuid');
        expect(adapted.location, 'Card location');
      },
    );

    testWidgets(
      'renders ProgressHeader with on-track handover line',
      (tester) async {
        _widenView(tester);
        final adapted = buildAdaptedProgressHeaderProject(
          _makeDetails(progress: 60),
          null,
        );
        final handover = ExpectedHandover(
          projectFinishDate: DateTime(2026, 8, 12),
          baselineFinishDate: DateTime(2026, 8, 12),
          weeksRemaining: 14,
          hasMaterialDelay: false,
        );

        await tester.pumpWidget(_wrap(ProgressHeader(
          project: adapted,
          handover: handover,
          showBreakdown: false,
          now: DateTime(2026, 5, 5),
        )));
        await tester.pump();

        // Wiring asserts: ProgressHeader is in the tree.
        expect(find.byType(ProgressHeader), findsOneWidget);

        // Handover row is visible with the on-track copy.
        expect(find.textContaining('Expected handover:'), findsOneWidget);
        expect(find.textContaining('12 Aug 2026'), findsOneWidget);
        expect(find.textContaining('14 weeks'), findsOneWidget);
      },
    );

    testWidgets(
      'omits handover row when ExpectedHandover is null',
      (tester) async {
        _widenView(tester);
        final adapted = buildAdaptedProgressHeaderProject(
          _makeDetails(progress: 60),
          null,
        );

        await tester.pumpWidget(_wrap(ProgressHeader(
          project: adapted,
          handover: null,
          showBreakdown: false,
        )));
        await tester.pump();

        expect(find.byType(ProgressHeader), findsOneWidget);
        // No handover row because handover is null.
        expect(find.textContaining('Expected handover:'), findsNothing);
        expect(find.text('Schedule not yet approved'), findsNothing);
      },
    );
  });
}
