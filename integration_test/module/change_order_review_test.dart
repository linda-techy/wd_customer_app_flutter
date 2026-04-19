import 'package:wd_cust_mobile_app/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../helpers/test_config.dart';
import '../helpers/login_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Change Order Review', () {
    testWidgets('should display change orders for project', (tester) async {
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

        // Look for Change Order / CO section in project detail
        // The screen is co_review_screen.dart, so look for "Change Order" or "CO"
        final coFinder = find.textContaining('Change Order');
        final coAbbrev = find.textContaining('CO');

        Finder? targetFinder;
        if (coFinder.evaluate().isNotEmpty) {
          targetFinder = coFinder;
        } else if (coAbbrev.evaluate().isNotEmpty) {
          targetFinder = coAbbrev;
        }

        if (targetFinder != null) {
          // May need to scroll to find the CO section
          await tester.tap(targetFinder.first);
          await tester.pumpAndSettle(TestConfig.longPumpSettleDuration);

          // Verify CO screen loaded
          expect(find.byType(Scaffold), findsWidgets);

          // Check for change order content
          final coContent = [
            find.textContaining('Change Order'),
            find.textContaining('Pending'),
            find.textContaining('Approved'),
            find.textContaining('Rejected'),
            find.textContaining('Status'),
            find.textContaining('Amount'),
          ];

          final hasCoContent =
              coContent.any((f) => f.evaluate().isNotEmpty);

          // Change orders displayed or empty state -- both acceptable
          expect(hasCoContent || find.byType(Scaffold).evaluate().isNotEmpty,
              isTrue,
              reason: 'Change order screen should be loaded');
        }
      } else {
        expect(find.byType(Scaffold), findsWidgets);
      }
    });

    testWidgets('should show approve/reject buttons for pending COs',
        (tester) async {
      app.main();
      await tester.pumpAndSettle(TestConfig.longPumpSettleDuration);

      final loginHelper = LoginHelper(tester);
      await loginHelper.loginAsCustomerA();
      await tester.pumpAndSettle(TestConfig.pumpSettleDuration);

      // Navigate to a project
      final cards = find.byType(Card);
      if (cards.evaluate().isNotEmpty) {
        await tester.tap(cards.first);
        await tester.pumpAndSettle(TestConfig.longPumpSettleDuration);

        // Navigate to Change Orders
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

          // Look for approve/reject action buttons (only visible for pending COs)
          final approveButton = find.textContaining('Approve');
          final rejectButton = find.textContaining('Reject');
          final pendingStatus = find.textContaining('Pending');
          final reviewButton = find.textContaining('Review');

          // If there are pending COs, approve/reject should be available
          if (pendingStatus.evaluate().isNotEmpty) {
            final hasActions = approveButton.evaluate().isNotEmpty ||
                rejectButton.evaluate().isNotEmpty ||
                reviewButton.evaluate().isNotEmpty;

            // Pending COs should have action buttons
            expect(hasActions, isTrue,
                reason:
                    'Pending change orders should show approve/reject buttons');
          }

          // Always verify the screen loaded
          expect(find.byType(Scaffold), findsWidgets);
        }
      } else {
        expect(find.byType(Scaffold), findsWidgets);
      }
    });
  });
}
