import 'package:wd_cust_mobile_app/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../helpers/test_config.dart';
import '../helpers/login_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication', () {
    testWidgets('should display login screen on launch', (tester) async {
      app.main();
      await tester.pumpAndSettle(TestConfig.longPumpSettleDuration);

      // The app starts with either the onboarding screen or login screen.
      // Check for the login form elements or a Sign In/Login link.
      final textFormFields = find.byType(TextFormField);
      final signInText = find.text('Sign In');
      final loginText = find.text('Login');
      final welcomeText = find.textContaining('Welcome');

      final loginScreenVisible = textFormFields.evaluate().length >= 2 ||
          signInText.evaluate().isNotEmpty ||
          loginText.evaluate().isNotEmpty ||
          welcomeText.evaluate().isNotEmpty;

      expect(loginScreenVisible, isTrue,
          reason:
              'On launch, the login screen or onboarding with login link should be visible');
    });

    testWidgets('should login with valid credentials', (tester) async {
      app.main();
      await tester.pumpAndSettle(TestConfig.longPumpSettleDuration);

      final loginHelper = LoginHelper(tester);
      await loginHelper.loginAsCustomerA();
      await loginHelper.verifyHomeLoaded();
    });

    testWidgets('should show error for invalid credentials', (tester) async {
      app.main();
      await tester.pumpAndSettle(TestConfig.longPumpSettleDuration);

      final loginHelper = LoginHelper(tester);
      await loginHelper.loginWithInvalidCredentials();

      // After invalid login, we should still be on the login screen or see
      // an error dialog/snackbar.
      await tester.pumpAndSettle(TestConfig.pumpSettleDuration);

      // Check for error indicators: AlertDialog, SnackBar, or error text
      final alertDialog = find.byType(AlertDialog);
      final loginFailed = find.textContaining('Login Failed');
      final invalidCreds = find.textContaining('Invalid');
      final errorText = find.textContaining('error');
      final signInButton = find.text('Sign In');

      final errorShown = alertDialog.evaluate().isNotEmpty ||
          loginFailed.evaluate().isNotEmpty ||
          invalidCreds.evaluate().isNotEmpty ||
          errorText.evaluate().isNotEmpty ||
          signInButton.evaluate().isNotEmpty; // still on login screen

      expect(errorShown, isTrue,
          reason:
              'Invalid credentials should show an error or remain on login screen');
    });
  });
}
