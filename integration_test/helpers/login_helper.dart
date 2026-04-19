import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'test_config.dart';

/// Helper to perform login in customer app integration tests.
class LoginHelper {
  final WidgetTester tester;

  LoginHelper(this.tester);

  /// Logs in as Customer A (residential customer) and waits for home to load.
  Future<void> loginAsCustomerA() async {
    await login(TestConfig.customerAEmail, TestConfig.password);
  }

  /// Logs in as Customer B (commercial customer) and waits for home to load.
  Future<void> loginAsCustomerB() async {
    await login(TestConfig.customerBEmail, TestConfig.password);
  }

  /// Logs in as Customer C (renovation customer) and waits for home to load.
  Future<void> loginAsCustomerC() async {
    await login(TestConfig.customerCEmail, TestConfig.password);
  }

  /// Fills the login form and taps the Sign In button.
  ///
  /// Navigates to the login screen first if not already there (e.g. the app
  /// may open on the onboarding or guest welcome screen).
  Future<void> login(String email, String password) async {
    // Wait for the initial screen to render
    await tester.pumpAndSettle(TestConfig.pumpSettleDuration);

    // If we land on the onboarding/welcome screen we need to get to login.
    // Try tapping a "Sign In" or "Login" text if visible (guest welcome).
    final signInLink = find.text('Sign In');
    final loginLink = find.text('Login');
    if (signInLink.evaluate().isNotEmpty) {
      await tester.tap(signInLink.first);
      await tester.pumpAndSettle(TestConfig.pumpSettleDuration);
    } else if (loginLink.evaluate().isNotEmpty) {
      await tester.tap(loginLink.first);
      await tester.pumpAndSettle(TestConfig.pumpSettleDuration);
    }

    // Find email and password TextFormFields
    final textFormFields = find.byType(TextFormField);
    expect(textFormFields, findsAtLeast(2),
        reason: 'Login screen should have email and password fields');

    final emailField = textFormFields.first;
    final passwordField = textFormFields.at(1);

    // Enter credentials
    await tester.enterText(emailField, email);
    await tester.enterText(passwordField, password);

    // Tap the Sign In (ElevatedButton)
    final loginButton = find.byType(ElevatedButton).first;
    await tester.tap(loginButton);

    // Wait for navigation after login
    await tester.pumpAndSettle(TestConfig.longPumpSettleDuration);
  }

  /// Attempts login with invalid credentials (for negative tests).
  Future<void> loginWithInvalidCredentials() async {
    await login(TestConfig.invalidEmail, TestConfig.invalidPassword);
  }

  /// Verifies the main screen loaded after a successful login.
  ///
  /// After login the app navigates to either the customer dashboard or the
  /// entry point with bottom navigation. We verify by checking a Scaffold
  /// with a BottomNavigationBar or the dashboard text is present.
  Future<void> verifyHomeLoaded() async {
    await tester.pumpAndSettle(TestConfig.pumpSettleDuration);

    // The app should show at least one Scaffold after login
    expect(find.byType(Scaffold), findsWidgets);

    // Check for either BottomNavigationBar (entry point) or dashboard content
    final bottomNav = find.byType(BottomNavigationBar);
    final dashboardText = find.textContaining('Dashboard');
    final projectText = find.textContaining('Project');

    final homeVisible = bottomNav.evaluate().isNotEmpty ||
        dashboardText.evaluate().isNotEmpty ||
        projectText.evaluate().isNotEmpty;

    expect(homeVisible, isTrue,
        reason:
            'After login, either bottom nav, dashboard, or project content should be visible');
  }
}
