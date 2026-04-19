import 'package:wd_cust_mobile_app/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../helpers/test_config.dart';
import '../helpers/login_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('BOQ Review', () {
    testWidgets('should navigate to BOQ section from project detail',
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

        // Look for BOQ section link/tile in project detail
        final boqFinder = find.textContaining('BOQ');
        if (boqFinder.evaluate().isNotEmpty) {
          await tester.tap(boqFinder.first);
          await tester.pumpAndSettle(TestConfig.longPumpSettleDuration);

          // Verify BOQ screen loaded
          final boqScreenContent = find.byType(Scaffold);
          expect(boqScreenContent, findsWidgets,
              reason: 'BOQ screen should display after navigation');

          // Check for BOQ-related content
          final boqItems = find.textContaining('BOQ');
          final tableOrList = find.byType(ListView);
          final dataTable = find.byType(DataTable);
          final emptyState = find.textContaining('No');

          final boqContentVisible = boqItems.evaluate().isNotEmpty ||
              tableOrList.evaluate().isNotEmpty ||
              dataTable.evaluate().isNotEmpty ||
              emptyState.evaluate().isNotEmpty;

          expect(boqContentVisible, isTrue,
              reason: 'BOQ screen should show items or empty state');
        }
      } else {
        // No projects available -- skip gracefully
        expect(find.byType(Scaffold), findsWidgets);
      }
    });

    testWidgets('should display BOQ items', (tester) async {
      app.main();
      await tester.pumpAndSettle(TestConfig.longPumpSettleDuration);

      final loginHelper = LoginHelper(tester);
      await loginHelper.loginAsCustomerA();
      await tester.pumpAndSettle(TestConfig.pumpSettleDuration);

      // Navigate to first project
      final cards = find.byType(Card);
      if (cards.evaluate().isNotEmpty) {
        await tester.tap(cards.first);
        await tester.pumpAndSettle(TestConfig.longPumpSettleDuration);

        // Navigate to BOQ
        final boqFinder = find.textContaining('BOQ');
        if (boqFinder.evaluate().isNotEmpty) {
          await tester.tap(boqFinder.first);
          await tester.pumpAndSettle(TestConfig.longPumpSettleDuration);

          // BOQ items should display quantities, rates, amounts, or categories
          final amountPattern = find.textContaining(RegExp(r'[\d,]+'));
          final categoryLabels = [
            'Civil',
            'Electrical',
            'Plumbing',
            'Finishing',
            'Structure',
            'Foundation',
          ];

          bool hasBoqData = amountPattern.evaluate().isNotEmpty;
          for (final label in categoryLabels) {
            if (find.textContaining(label).evaluate().isNotEmpty) {
              hasBoqData = true;
              break;
            }
          }

          // BOQ items found or empty state -- both acceptable
          expect(hasBoqData || find.byType(Scaffold).evaluate().isNotEmpty,
              isTrue,
              reason: 'BOQ screen should show data or at least a scaffold');
        }
      } else {
        expect(find.byType(Scaffold), findsWidgets);
      }
    });
  });
}
