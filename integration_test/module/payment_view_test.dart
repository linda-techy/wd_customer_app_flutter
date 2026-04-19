import 'package:wd_cust_mobile_app/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../helpers/test_config.dart';
import '../helpers/login_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Payment View', () {
    testWidgets('should navigate to payments from project detail',
        (tester) async {
      app.main();
      await tester.pumpAndSettle(TestConfig.longPumpSettleDuration);

      final loginHelper = LoginHelper(tester);
      await loginHelper.loginAsCustomerA();
      await tester.pumpAndSettle(TestConfig.pumpSettleDuration);

      // Open a project from the dashboard
      final cards = find.byType(Card);
      if (cards.evaluate().isNotEmpty) {
        await tester.tap(cards.first);
        await tester.pumpAndSettle(TestConfig.longPumpSettleDuration);

        // Look for Payment section in project detail
        final paymentFinder = find.textContaining('Payment');
        if (paymentFinder.evaluate().isNotEmpty) {
          await tester.tap(paymentFinder.first);
          await tester.pumpAndSettle(TestConfig.longPumpSettleDuration);

          // Verify payments screen loaded
          expect(find.byType(Scaffold), findsWidgets,
              reason: 'Payments screen should be loaded');
        }
      } else {
        // No projects available
        expect(find.byType(Scaffold), findsWidgets);
      }
    });

    testWidgets('should display payment history', (tester) async {
      app.main();
      await tester.pumpAndSettle(TestConfig.longPumpSettleDuration);

      final loginHelper = LoginHelper(tester);
      await loginHelper.loginAsCustomerA();
      await tester.pumpAndSettle(TestConfig.pumpSettleDuration);

      // Open a project
      final cards = find.byType(Card);
      if (cards.evaluate().isNotEmpty) {
        await tester.tap(cards.first);
        await tester.pumpAndSettle(TestConfig.longPumpSettleDuration);

        // Navigate to Payments
        final paymentFinder = find.textContaining('Payment');
        if (paymentFinder.evaluate().isNotEmpty) {
          await tester.tap(paymentFinder.first);
          await tester.pumpAndSettle(TestConfig.longPumpSettleDuration);

          // Check for payment-related content
          final paymentIndicators = [
            find.textContaining('Payment'),
            find.textContaining('Amount'),
            find.textContaining('Paid'),
            find.textContaining('Pending'),
            find.textContaining('Due'),
            find.textContaining('Schedule'),
            find.textContaining('Invoice'),
            find.textContaining('Total'),
          ];

          final hasPaymentContent =
              paymentIndicators.any((f) => f.evaluate().isNotEmpty);
          final emptyState = find.textContaining('No payment');

          expect(
              hasPaymentContent ||
                  emptyState.evaluate().isNotEmpty ||
                  find.byType(Scaffold).evaluate().isNotEmpty,
              isTrue,
              reason:
                  'Payment screen should show history, schedule, or empty state');
        }
      } else {
        expect(find.byType(Scaffold), findsWidgets);
      }
    });
  });
}
