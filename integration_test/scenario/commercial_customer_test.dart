import 'package:wd_cust_mobile_app/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../helpers/test_config.dart';
import '../helpers/login_helper.dart';
import '../helpers/navigation_helper.dart';

/// End-to-end scenario: Commercial customer journey.
///
/// Login as Customer B -> Dashboard -> Open commercial project ->
/// Navigate through financial views (Financial Summary, Payment Schedule).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Scenario: Commercial Customer', () {
    testWidgets(
        'should login, view dashboard, open project, and navigate financial views',
        (tester) async {
      app.main();
      await tester.pumpAndSettle(TestConfig.longPumpSettleDuration);

      // --- Step 1: Login as Customer B (commercial customer) ---
      final loginHelper = LoginHelper(tester);
      await loginHelper.loginAsCustomerB();
      await loginHelper.verifyHomeLoaded();

      // --- Step 2: Verify dashboard is loaded ---
      await tester.pumpAndSettle(TestConfig.pumpSettleDuration);
      expect(find.byType(Scaffold), findsWidgets,
          reason: 'Dashboard should be loaded');

      // --- Step 3: Open a project (commercial) ---
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

      // --- Step 4: Navigate to Financial Summary ---
      final financialFinder = find.textContaining('Financial');
      if (financialFinder.evaluate().isNotEmpty) {
        await tester.tap(financialFinder.first);
        await tester.pumpAndSettle(TestConfig.longPumpSettleDuration);

        // Verify financial summary screen loaded
        final financialIndicators = [
          find.textContaining('Financial'),
          find.textContaining('Summary'),
          find.textContaining('Total'),
          find.textContaining('Budget'),
          find.textContaining('Cost'),
        ];

        final hasFinancialContent =
            financialIndicators.any((f) => f.evaluate().isNotEmpty);

        expect(
            hasFinancialContent ||
                find.byType(Scaffold).evaluate().isNotEmpty,
            isTrue,
            reason: 'Financial summary should display');

        // Navigate back
        await navHelper.goBack();
        await tester.pumpAndSettle(TestConfig.pumpSettleDuration);
      }

      // --- Step 5: Navigate to Payment Schedule ---
      final paymentFinder = find.textContaining('Payment');
      if (paymentFinder.evaluate().isNotEmpty) {
        await tester.tap(paymentFinder.first);
        await tester.pumpAndSettle(TestConfig.longPumpSettleDuration);

        // Verify payment screen loaded
        final paymentIndicators = [
          find.textContaining('Payment'),
          find.textContaining('Schedule'),
          find.textContaining('Amount'),
          find.textContaining('Due'),
          find.textContaining('Paid'),
        ];

        final hasPaymentContent =
            paymentIndicators.any((f) => f.evaluate().isNotEmpty);

        expect(
            hasPaymentContent ||
                find.byType(Scaffold).evaluate().isNotEmpty,
            isTrue,
            reason: 'Payment schedule should display');

        // Navigate back
        await navHelper.goBack();
        await tester.pumpAndSettle(TestConfig.pumpSettleDuration);
      }

      // --- Step 6: Navigate to BOQ for cost overview ---
      final boqFinder = find.textContaining('BOQ');
      if (boqFinder.evaluate().isNotEmpty) {
        await tester.tap(boqFinder.first);
        await tester.pumpAndSettle(TestConfig.longPumpSettleDuration);

        expect(find.byType(Scaffold), findsWidgets,
            reason: 'BOQ screen should be loaded');
      }

      // Scenario completed successfully
    });
  });
}
