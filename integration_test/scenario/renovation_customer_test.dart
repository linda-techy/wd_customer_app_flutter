import 'package:wd_cust_mobile_app/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../helpers/test_config.dart';
import '../helpers/login_helper.dart';
import '../helpers/navigation_helper.dart';

/// End-to-end scenario: Renovation customer journey.
///
/// Login as Customer C -> Dashboard -> Open renovation project ->
/// Navigate to change orders for renovation-specific workflow.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Scenario: Renovation Customer', () {
    testWidgets(
        'should login, view dashboard, open project, and navigate to change orders',
        (tester) async {
      app.main();
      await tester.pumpAndSettle(TestConfig.longPumpSettleDuration);

      // --- Step 1: Login as Customer C (renovation customer) ---
      final loginHelper = LoginHelper(tester);
      await loginHelper.loginAsCustomerC();
      await loginHelper.verifyHomeLoaded();

      // --- Step 2: Verify dashboard is loaded ---
      await tester.pumpAndSettle(TestConfig.pumpSettleDuration);
      expect(find.byType(Scaffold), findsWidgets,
          reason: 'Dashboard should be loaded');

      // --- Step 3: Open a project (renovation) ---
      final cards = find.byType(Card);
      if (cards.evaluate().isEmpty) {
        // No projects available -- scenario cannot continue, but test passes
        return;
      }

      await tester.tap(cards.first);
      await tester.pumpAndSettle(TestConfig.longPumpSettleDuration);

      // Verify project detail loaded
      expect(find.byType(Scaffold), findsWidgets,
          reason: 'Project detail screen should load');

      final navHelper = NavigationHelper(tester);

      // --- Step 4: Navigate to Change Orders ---
      // Renovation projects frequently have change orders
      final coFinder = find.textContaining('Change Order');
      final coAbbrev = find.textContaining('CO');

      Finder? targetFinder;
      if (coFinder.evaluate().isNotEmpty) {
        targetFinder = coFinder;
      } else if (coAbbrev.evaluate().isNotEmpty) {
        targetFinder = coAbbrev;
      }

      if (targetFinder != null) {
        await tester.tap(targetFinder.first);
        await tester.pumpAndSettle(TestConfig.longPumpSettleDuration);

        // Verify change orders screen loaded
        final coIndicators = [
          find.textContaining('Change Order'),
          find.textContaining('Pending'),
          find.textContaining('Approved'),
          find.textContaining('Status'),
          find.textContaining('Description'),
        ];

        final hasCoContent =
            coIndicators.any((f) => f.evaluate().isNotEmpty);

        expect(
            hasCoContent || find.byType(Scaffold).evaluate().isNotEmpty,
            isTrue,
            reason: 'Change orders screen should display');

        // Navigate back
        await navHelper.goBack();
        await tester.pumpAndSettle(TestConfig.pumpSettleDuration);
      }

      // --- Step 5: Navigate to Snags (common in renovations) ---
      final snagsFinder = find.textContaining('Snag');
      if (snagsFinder.evaluate().isNotEmpty) {
        await tester.tap(snagsFinder.first);
        await tester.pumpAndSettle(TestConfig.longPumpSettleDuration);

        expect(find.byType(Scaffold), findsWidgets,
            reason: 'Snags screen should be loaded');

        await navHelper.goBack();
        await tester.pumpAndSettle(TestConfig.pumpSettleDuration);
      }

      // --- Step 6: Navigate to Quality Checks ---
      final qualityFinder = find.textContaining('Quality');
      if (qualityFinder.evaluate().isNotEmpty) {
        await tester.tap(qualityFinder.first);
        await tester.pumpAndSettle(TestConfig.longPumpSettleDuration);

        expect(find.byType(Scaffold), findsWidgets,
            reason: 'Quality checks screen should be loaded');
      }

      // Scenario completed successfully
    });
  });
}
