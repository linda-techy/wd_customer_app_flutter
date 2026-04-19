import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'test_config.dart';

/// Helper for navigating between screens in customer app integration tests.
class NavigationHelper {
  final WidgetTester tester;

  NavigationHelper(this.tester);

  /// Taps a bottom navigation tab by its label text.
  ///
  /// Bottom nav tabs in the customer app (mobile):
  ///   Home, Blog, Project, Portfolio, Profile
  Future<void> navigateToTab(String label) async {
    final tab = find.text(label);
    if (tab.evaluate().isNotEmpty) {
      await tester.tap(tab.last); // .last to prefer the bottom-nav label
      await tester.pumpAndSettle(TestConfig.pumpSettleDuration);
    }
  }

  /// Taps a widget with the given text. Uses `.first` when multiple matches.
  Future<void> tapButton(String text) async {
    final button = find.text(text);
    if (button.evaluate().isNotEmpty) {
      await tester.tap(button.first);
      await tester.pumpAndSettle(TestConfig.pumpSettleDuration);
    }
  }

  /// Taps an icon button by its icon data.
  Future<void> tapIcon(IconData icon) async {
    final iconFinder = find.byIcon(icon);
    if (iconFinder.evaluate().isNotEmpty) {
      await tester.tap(iconFinder.first);
      await tester.pumpAndSettle(TestConfig.pumpSettleDuration);
    }
  }

  /// Taps the first widget matching a given [Key].
  Future<void> tapByKey(Key key) async {
    final finder = find.byKey(key);
    if (finder.evaluate().isNotEmpty) {
      await tester.tap(finder.first);
      await tester.pumpAndSettle(TestConfig.pumpSettleDuration);
    }
  }

  /// Taps the first item in a list view (e.g. project card).
  Future<void> tapFirstListItem() async {
    // Try tapping the first InkWell/GestureDetector inside a ListView
    final listView = find.byType(ListView);
    if (listView.evaluate().isNotEmpty) {
      final inkWells = find.descendant(
        of: listView.first,
        matching: find.byType(InkWell),
      );
      if (inkWells.evaluate().isNotEmpty) {
        await tester.tap(inkWells.first);
        await tester.pumpAndSettle(TestConfig.pumpSettleDuration);
        return;
      }
    }

    // Fallback: try tapping the first Card widget
    final cards = find.byType(Card);
    if (cards.evaluate().isNotEmpty) {
      await tester.tap(cards.first);
      await tester.pumpAndSettle(TestConfig.pumpSettleDuration);
    }
  }

  /// Scrolls down in the current scrollable area.
  Future<void> scrollDown({double pixels = 300}) async {
    final scrollable = find.byType(Scrollable);
    if (scrollable.evaluate().isNotEmpty) {
      await tester.drag(scrollable.first, Offset(0, -pixels));
      await tester.pumpAndSettle(TestConfig.pumpSettleDuration);
    }
  }

  /// Scrolls up in the current scrollable area.
  Future<void> scrollUp({double pixels = 300}) async {
    final scrollable = find.byType(Scrollable);
    if (scrollable.evaluate().isNotEmpty) {
      await tester.drag(scrollable.first, Offset(0, pixels));
      await tester.pumpAndSettle(TestConfig.pumpSettleDuration);
    }
  }

  /// Navigates back (pops the current route).
  Future<void> goBack() async {
    final backButton = find.byType(BackButton);
    if (backButton.evaluate().isNotEmpty) {
      await tester.tap(backButton.first);
      await tester.pumpAndSettle(TestConfig.pumpSettleDuration);
      return;
    }
    // Fallback: try the AppBar back arrow icon
    final arrowBack = find.byIcon(Icons.arrow_back);
    if (arrowBack.evaluate().isNotEmpty) {
      await tester.tap(arrowBack.first);
      await tester.pumpAndSettle(TestConfig.pumpSettleDuration);
    }
  }

  /// Waits for the page to settle after an action.
  Future<void> waitForSettle() async {
    await tester.pumpAndSettle(TestConfig.pumpSettleDuration);
  }
}
