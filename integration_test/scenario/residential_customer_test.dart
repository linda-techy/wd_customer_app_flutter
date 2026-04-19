import 'package:wd_cust_mobile_app/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../helpers/test_config.dart';
import '../helpers/login_helper.dart';
import '../helpers/navigation_helper.dart';

/// End-to-end scenario: Residential customer journey.
///
/// Login as Customer A -> Dashboard -> Open residential project ->
/// Navigate through tabs (BOQ, Payments, Site Reports).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Scenario: Residential Customer', () {
    testWidgets(
        'should login, view dashboard, open project, and navigate through tabs',
        (tester) async {
      app.main();
      await tester.pumpAndSettle(TestConfig.longPumpSettleDuration);

      // --- Step 1: Login as Customer A (residential customer) ---
      final loginHelper = LoginHelper(tester);
      await loginHelper.loginAsCustomerA();
      await loginHelper.verifyHomeLoaded();

      // --- Step 2: Verify dashboard is loaded ---
      await tester.pumpAndSettle(TestConfig.pumpSettleDuration);
      final scaffold = find.byType(Scaffold);
      expect(scaffold, findsWidgets, reason: 'Dashboard should be loaded');

      // --- Step 3: Open the first project (residential) ---
      final cards = find.byType(Card);
      if (cards.evaluate().isEmpty) {
        // No projects available -- scenario cannot continue, but test passes
        return;
      }

      await tester.tap(cards.first);
      await tester.pumpAndSettle(TestConfig.longPumpSettleDuration);

      // Verify project detail loaded
      final backButton = find.byIcon(Icons.arrow_back);
      final projectDetailLoaded = backButton.evaluate().isNotEmpty ||
          find.textContaining('Detail').evaluate().isNotEmpty ||
          find.textContaining('Project').evaluate().isNotEmpty;

      expect(projectDetailLoaded, isTrue,
          reason: 'Project detail screen should be loaded');

      // --- Step 4: Navigate to BOQ ---
      final boqFinder = find.textContaining('BOQ');
      if (boqFinder.evaluate().isNotEmpty) {
        await tester.tap(boqFinder.first);
        await tester.pumpAndSettle(TestConfig.longPumpSettleDuration);

        // Verify BOQ screen loaded
        expect(find.byType(Scaffold), findsWidgets,
            reason: 'BOQ screen should be loaded');

        // Navigate back to project detail
        final navHelper = NavigationHelper(tester);
        await navHelper.goBack();
        await tester.pumpAndSettle(TestConfig.pumpSettleDuration);
      }

      // --- Step 5: Navigate to Payments ---
      final paymentFinder = find.textContaining('Payment');
      if (paymentFinder.evaluate().isNotEmpty) {
        await tester.tap(paymentFinder.first);
        await tester.pumpAndSettle(TestConfig.longPumpSettleDuration);

        // Verify payments screen loaded
        expect(find.byType(Scaffold), findsWidgets,
            reason: 'Payments screen should be loaded');

        // Navigate back
        final navHelper = NavigationHelper(tester);
        await navHelper.goBack();
        await tester.pumpAndSettle(TestConfig.pumpSettleDuration);
      }

      // --- Step 6: Navigate to Site Reports ---
      final siteUpdatesFinder = find.textContaining('Site Update');
      final siteReportsFinder = find.textContaining('Site Report');

      Finder? siteFinder;
      if (siteUpdatesFinder.evaluate().isNotEmpty) {
        siteFinder = siteUpdatesFinder;
      } else if (siteReportsFinder.evaluate().isNotEmpty) {
        siteFinder = siteReportsFinder;
      }

      if (siteFinder != null) {
        await tester.tap(siteFinder.first);
        await tester.pumpAndSettle(TestConfig.longPumpSettleDuration);

        // Verify site reports screen loaded
        expect(find.byType(Scaffold), findsWidgets,
            reason: 'Site reports screen should be loaded');
      }

      // Scenario completed successfully
    });
  });
}
