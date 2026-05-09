import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wd_cust_mobile_app/models/next_payment_milestone.dart';
import 'package:wd_cust_mobile_app/route/route_constants.dart';
import 'package:wd_cust_mobile_app/widgets/next_payment_milestone_card.dart';

// ---------------------------------------------------------------------------
// Mirrors project_detail_handover_test.dart: covers the *card subtree* the
// project-detail screen places between the ProgressHeader and the phase
// stepper. Driving the full ProjectDetailsScreen would require mocking
// DashboardService — not the contract under test here.
// ---------------------------------------------------------------------------

void _widenView(WidgetTester tester) {
  tester.view.physicalSize = const Size(2400, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

NextPaymentMilestone _due() => NextPaymentMilestone(
      stage: NextPaymentStage(
        stageNumber: 4,
        stageName: 'Plastering',
        dueDate: DateTime(2026, 5, 15),
        daysUntilDue: 5,
        status: 'DUE',
        netPayableAmount: 425000,
        stagePercentage: 12,
        percentOfContract: 12.0,
        totalStages: 7,
      ),
      summary: const NextPaymentSummary(
        totalContractValue: 3500000,
        totalPaid: 1400000,
        totalOutstanding: 2100000,
        stageCount: 7,
      ),
    );

Widget _wrap(Widget child) => MaterialApp(
      routes: {
        paymentsScreenRoute: (_) => const Scaffold(body: Text('PAYMENTS_PLACEHOLDER')),
      },
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void main() {
  group('ProjectDetailsScreen NextPaymentMilestoneCard wiring', () {
    testWidgets('renders the card with the next-stage values', (tester) async {
      _widenView(tester);
      await tester.pumpWidget(_wrap(NextPaymentMilestoneCard(milestone: _due())));
      await tester.pump();

      expect(find.byType(NextPaymentMilestoneCard), findsOneWidget);
      expect(find.text('Plastering'), findsOneWidget);
      expect(find.text('Stage 4 of 7'), findsOneWidget);
      expect(find.text('Due in 5 days'), findsOneWidget);
    });

    testWidgets('takes zero space when milestone is null', (tester) async {
      _widenView(tester);
      await tester.pumpWidget(_wrap(
        const NextPaymentMilestoneCard(milestone: null),
      ));
      await tester.pump();

      final size =
          tester.renderObject<RenderBox>(find.byType(NextPaymentMilestoneCard)).size;
      expect(size, Size.zero);
    });
  });
}
