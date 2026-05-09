import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wd_cust_mobile_app/models/next_payment_milestone.dart';
import 'package:wd_cust_mobile_app/route/route_constants.dart';
import 'package:wd_cust_mobile_app/widgets/next_payment_milestone_card.dart';

void _widenView(WidgetTester tester) {
  tester.view.physicalSize = const Size(2400, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

NextPaymentMilestone _milestone({
  String status = 'DUE',
  int? daysUntilDue = 3,
  DateTime? dueDate,
}) {
  return NextPaymentMilestone(
    stage: NextPaymentStage(
      stageNumber: 4,
      stageName: 'Plastering',
      dueDate: dueDate ?? DateTime(2026, 5, 15),
      daysUntilDue: daysUntilDue,
      status: status,
      netPayableAmount: 425000.00,
      stagePercentage: 12.0,
      percentOfContract: 12.0,
      totalStages: 7,
    ),
    summary: const NextPaymentSummary(
      totalContractValue: 3500000.00,
      totalPaid: 1400000.00,
      totalOutstanding: 2100000.00,
      stageCount: 7,
    ),
  );
}

Widget _wrap(Widget child, {Map<String, WidgetBuilder>? routes}) {
  return MaterialApp(
    routes: {
      paymentsScreenRoute: (_) => const Scaffold(
            body: Text('PAYMENTS_SCREEN_PLACEHOLDER'),
          ),
      ...?routes,
    },
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  group('NextPaymentMilestoneCard', () {
    testWidgets('DUE state renders amber pill, "Due in 3 days" countdown, '
        'stage name, formatted amount, and "Stage 4 of 7"', (tester) async {
      _widenView(tester);
      await tester.pumpWidget(_wrap(NextPaymentMilestoneCard(milestone: _milestone())));
      await tester.pump();

      // Status pill text — DUE → amber.
      expect(find.text('DUE'), findsOneWidget);
      // Sequence label.
      expect(find.text('Stage 4 of 7'), findsOneWidget);
      // Stage name.
      expect(find.text('Plastering'), findsOneWidget);
      // Indian-grouped amount via CurrencyFormatter.formatCompact(425000) → "₹4,25,000".
      expect(find.textContaining('4,25,000'), findsOneWidget);
      // % of contract line.
      expect(find.textContaining('12'), findsWidgets);
      // Countdown.
      expect(find.text('Due in 3 days'), findsOneWidget);
    });

    testWidgets('OVERDUE state renders red pill + "Overdue by 2 days"',
        (tester) async {
      _widenView(tester);
      await tester.pumpWidget(_wrap(NextPaymentMilestoneCard(
        milestone: _milestone(status: 'OVERDUE', daysUntilDue: -2),
      )));
      await tester.pump();

      expect(find.text('OVERDUE'), findsOneWidget);
      expect(find.text('Overdue by 2 days'), findsOneWidget);
    });

    testWidgets('Due today renders "Due today"', (tester) async {
      _widenView(tester);
      await tester.pumpWidget(_wrap(NextPaymentMilestoneCard(
        milestone: _milestone(status: 'DUE', daysUntilDue: 0),
      )));
      await tester.pump();

      expect(find.text('Due today'), findsOneWidget);
    });

    testWidgets('null daysUntilDue + null dueDate → "Due date pending"',
        (tester) async {
      _widenView(tester);
      final m = NextPaymentMilestone(
        stage: const NextPaymentStage(
          stageNumber: 2,
          stageName: 'Foundation',
          dueDate: null,
          daysUntilDue: null,
          status: 'UPCOMING',
          netPayableAmount: 250000,
          stagePercentage: 10,
          percentOfContract: 10,
          totalStages: 7,
        ),
        summary: const NextPaymentSummary(
          totalContractValue: 2500000,
          totalPaid: 0,
          totalOutstanding: 2500000,
          stageCount: 7,
        ),
      );

      await tester.pumpWidget(_wrap(NextPaymentMilestoneCard(milestone: m)));
      await tester.pump();

      expect(find.text('Due date pending'), findsOneWidget);
    });

    testWidgets('milestone == null → SizedBox.shrink (zero pixels)',
        (tester) async {
      _widenView(tester);
      await tester.pumpWidget(_wrap(
        const NextPaymentMilestoneCard(milestone: null),
      ));
      await tester.pump();

      // No card content is rendered.
      expect(find.text('Plastering'), findsNothing);
      expect(find.byType(Card), findsNothing);
      // The widget itself is in the tree but takes no layout space.
      expect(find.byType(NextPaymentMilestoneCard), findsOneWidget);
      final renderBox =
          tester.renderObject<RenderBox>(find.byType(NextPaymentMilestoneCard));
      expect(renderBox.size, Size.zero);
    });

    testWidgets('milestone.stage == null → SizedBox.shrink', (tester) async {
      _widenView(tester);
      final m = NextPaymentMilestone(
        stage: null,
        summary: const NextPaymentSummary(
          totalContractValue: 3500000,
          totalPaid: 3500000,
          totalOutstanding: 0,
          stageCount: 7,
        ),
      );

      await tester.pumpWidget(_wrap(NextPaymentMilestoneCard(milestone: m)));
      await tester.pump();

      expect(find.byType(Card), findsNothing);
    });

    testWidgets('tap pushes paymentsScreenRoute', (tester) async {
      _widenView(tester);
      await tester.pumpWidget(_wrap(NextPaymentMilestoneCard(milestone: _milestone())));
      await tester.pump();

      // Tap the card — anywhere on the rendered Card surface.
      await tester.tap(find.byType(NextPaymentMilestoneCard));
      await tester.pumpAndSettle();

      // Placeholder for paymentsScreenRoute is now visible.
      expect(find.text('PAYMENTS_SCREEN_PLACEHOLDER'), findsOneWidget);
    });
  });
}
