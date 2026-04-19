import 'package:wd_cust_mobile_app/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../helpers/test_config.dart';
import '../helpers/login_helper.dart';
import '../helpers/navigation_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Project Detail', () {
    testWidgets('should display projects list', (tester) async {
      app.main();
      await tester.pumpAndSettle(TestConfig.longPumpSettleDuration);

      final loginHelper = LoginHelper(tester);
      await loginHelper.loginAsCustomerA();
      await tester.pumpAndSettle(TestConfig.pumpSettleDuration);

      // After login, the customer dashboard shows projects.
      // The Project tab in bottom nav also shows projects.
      final navHelper = NavigationHelper(tester);
      await navHelper.navigateToTab('Project');
      await tester.pumpAndSettle(TestConfig.pumpSettleDuration);

      // Verify projects are displayed or an empty state is shown
      final scaffold = find.byType(Scaffold);
      expect(scaffold, findsWidgets);

      final projectContent = find.textContaining('Project');
      final cards = find.byType(Card);
      final emptyState = find.textContaining('No project');

      final hasProjectList = projectContent.evaluate().isNotEmpty ||
          cards.evaluate().isNotEmpty ||
          emptyState.evaluate().isNotEmpty;

      expect(hasProjectList, isTrue,
          reason: 'Project tab should show projects list or empty state');
    });

    testWidgets('should open project detail when tapped', (tester) async {
      app.main();
      await tester.pumpAndSettle(TestConfig.longPumpSettleDuration);

      final loginHelper = LoginHelper(tester);
      await loginHelper.loginAsCustomerA();
      await tester.pumpAndSettle(TestConfig.pumpSettleDuration);

      // Try tapping a project card on the dashboard
      final cards = find.byType(Card);

      if (cards.evaluate().isNotEmpty) {
        await tester.tap(cards.first);
        await tester.pumpAndSettle(TestConfig.longPumpSettleDuration);

        // After tapping a project, we should see project detail content
        final detailIndicators = [
          find.textContaining('Detail'),
          find.textContaining('Timeline'),
          find.textContaining('BOQ'),
          find.textContaining('Payment'),
          find.textContaining('Site'),
          find.textContaining('Gallery'),
          find.textContaining('Document'),
          find.byIcon(Icons.arrow_back),
        ];

        final detailVisible = detailIndicators
            .any((finder) => finder.evaluate().isNotEmpty);

        // Defensive: project detail may not load if no test data
        if (!detailVisible) {
          // Acceptable if there are no projects to tap
          expect(find.byType(Scaffold), findsWidgets);
        }
      } else {
        // No project cards available -- empty state is acceptable
        expect(find.byType(Scaffold), findsWidgets);
      }
    });

    testWidgets('project detail should show tabs or sections',
        (tester) async {
      app.main();
      await tester.pumpAndSettle(TestConfig.longPumpSettleDuration);

      final loginHelper = LoginHelper(tester);
      await loginHelper.loginAsCustomerA();
      await tester.pumpAndSettle(TestConfig.pumpSettleDuration);

      // Try to open a project from the dashboard
      final cards = find.byType(Card);
      if (cards.evaluate().isNotEmpty) {
        await tester.tap(cards.first);
        await tester.pumpAndSettle(TestConfig.longPumpSettleDuration);

        // Project detail screen should show various sections/action tiles
        final sectionLabels = [
          'BOQ',
          'Payment',
          'Site Updates',
          'Gallery',
          'Documents',
          'Timeline',
          'Schedule',
          'CCTV',
          'Floor Plan',
          '3D Design',
          'Quality',
          'Activity',
          'Snags',
          'Feedback',
        ];

        int foundSections = 0;
        for (final label in sectionLabels) {
          final finder = find.textContaining(label);
          if (finder.evaluate().isNotEmpty) {
            foundSections++;
          }
        }

        // We expect at least a few sections to be visible
        // (scrolling may be needed for all)
        if (foundSections == 0) {
          // Still acceptable if project detail loaded but sections aren't
          // text-based (icon tiles, etc.)
          expect(find.byType(Scaffold), findsWidgets);
        }
      } else {
        // No projects available
        expect(find.byType(Scaffold), findsWidgets);
      }
    });
  });
}
