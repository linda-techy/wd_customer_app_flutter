import 'package:wd_cust_mobile_app/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../helpers/test_config.dart';
import '../helpers/login_helper.dart';
import '../helpers/navigation_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Dashboard', () {
    testWidgets('should display dashboard after login', (tester) async {
      app.main();
      await tester.pumpAndSettle(TestConfig.longPumpSettleDuration);

      final loginHelper = LoginHelper(tester);
      await loginHelper.loginAsCustomerA();
      await loginHelper.verifyHomeLoaded();

      // The customer dashboard should be visible after login.
      // Logged-in users default to the Dashboard tab (index 3).
      await tester.pumpAndSettle(TestConfig.pumpSettleDuration);

      // Check for dashboard elements
      final scaffold = find.byType(Scaffold);
      expect(scaffold, findsWidgets);

      // Look for dashboard-related text content
      final dashboardText = find.textContaining('Dashboard');
      final projectsText = find.textContaining('Project');
      final welcomeText = find.textContaining('Welcome');

      final dashboardVisible = dashboardText.evaluate().isNotEmpty ||
          projectsText.evaluate().isNotEmpty ||
          welcomeText.evaluate().isNotEmpty;

      expect(dashboardVisible, isTrue,
          reason: 'Dashboard should display project or welcome content');
    });

    testWidgets('dashboard should show project cards or list', (tester) async {
      app.main();
      await tester.pumpAndSettle(TestConfig.longPumpSettleDuration);

      final loginHelper = LoginHelper(tester);
      await loginHelper.loginAsCustomerA();
      await tester.pumpAndSettle(TestConfig.pumpSettleDuration);

      // Navigate to the Project tab to see projects list
      final navigationHelper = NavigationHelper(tester);
      await navigationHelper.navigateToTab('Project');
      await tester.pumpAndSettle(TestConfig.pumpSettleDuration);

      // Verify project content is displayed (cards, list, or empty state)
      final cards = find.byType(Card);
      final listView = find.byType(ListView);
      final gridView = find.byType(GridView);
      final emptyState = find.textContaining('No project');
      final projectContent = find.textContaining('Project');

      final hasContent = cards.evaluate().isNotEmpty ||
          listView.evaluate().isNotEmpty ||
          gridView.evaluate().isNotEmpty ||
          emptyState.evaluate().isNotEmpty ||
          projectContent.evaluate().isNotEmpty;

      expect(hasContent, isTrue,
          reason:
              'Dashboard/project tab should show project cards, list, or empty state');
    });
  });
}
