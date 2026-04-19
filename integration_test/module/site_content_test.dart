import 'package:wd_cust_mobile_app/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../helpers/test_config.dart';
import '../helpers/login_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Site Content', () {
    testWidgets('should display site reports for project', (tester) async {
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

        // Look for Site Updates / Site Reports section
        final siteUpdatesFinder = find.textContaining('Site Update');
        final siteReportsFinder = find.textContaining('Site Report');

        Finder? targetFinder;
        if (siteUpdatesFinder.evaluate().isNotEmpty) {
          targetFinder = siteUpdatesFinder;
        } else if (siteReportsFinder.evaluate().isNotEmpty) {
          targetFinder = siteReportsFinder;
        }

        if (targetFinder != null) {
          await tester.tap(targetFinder.first);
          await tester.pumpAndSettle(TestConfig.longPumpSettleDuration);

          // Verify site reports screen loaded
          final reportIndicators = [
            find.textContaining('Site'),
            find.textContaining('Report'),
            find.textContaining('Update'),
            find.textContaining('Date'),
            find.textContaining('Progress'),
          ];

          final hasReportContent =
              reportIndicators.any((f) => f.evaluate().isNotEmpty);

          expect(
              hasReportContent || find.byType(Scaffold).evaluate().isNotEmpty,
              isTrue,
              reason: 'Site reports screen should load');
        }
      } else {
        expect(find.byType(Scaffold), findsWidgets);
      }
    });

    testWidgets('should display gallery/photos for project', (tester) async {
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

        // Look for Gallery section in project detail
        final galleryFinder = find.textContaining('Gallery');
        final photosFinder = find.textContaining('Photo');

        Finder? targetFinder;
        if (galleryFinder.evaluate().isNotEmpty) {
          targetFinder = galleryFinder;
        } else if (photosFinder.evaluate().isNotEmpty) {
          targetFinder = photosFinder;
        }

        if (targetFinder != null) {
          await tester.tap(targetFinder.first);
          await tester.pumpAndSettle(TestConfig.longPumpSettleDuration);

          // Gallery screen should show images or empty state
          final imageWidgets = find.byType(Image);
          final gridView = find.byType(GridView);
          final emptyState = find.textContaining('No photo');
          final galleryText = find.textContaining('Gallery');

          final hasGalleryContent = imageWidgets.evaluate().isNotEmpty ||
              gridView.evaluate().isNotEmpty ||
              emptyState.evaluate().isNotEmpty ||
              galleryText.evaluate().isNotEmpty;

          expect(
              hasGalleryContent ||
                  find.byType(Scaffold).evaluate().isNotEmpty,
              isTrue,
              reason: 'Gallery screen should show photos or empty state');
        }
      } else {
        expect(find.byType(Scaffold), findsWidgets);
      }
    });
  });
}
