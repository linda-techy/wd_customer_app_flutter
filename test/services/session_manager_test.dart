import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wd_cust_mobile_app/main.dart' show MyApp;
import 'package:wd_cust_mobile_app/route/route_constants.dart';
import 'package:wd_cust_mobile_app/services/session_manager.dart';

/// Locks the customer-facing session-expiry behaviour:
///   1. The copy is jargon-free — customers don't know what a "token" is.
///   2. A dead session ROUTES the user to login (clearing the back stack)
///      instead of leaving them on a screen with a Retry button that can
///      never succeed.
///
/// SessionManager is the single chokepoint both the AuthInterceptor (server
/// 401/403) and DashboardService's pre-flight token checks delegate to.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // expireSession() clears auth via SharedPreferences + flutter_secure_storage.
    // Provide no-op mocks so it completes fast in the harness instead of
    // throwing/hanging on a missing platform channel.
    SharedPreferences.setMockInitialValues(<String, Object>{});
    const secureStorage =
        MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorage, (call) async => null);
  });

  test('sessionExpiredMessage is jargon-free (no "token")', () {
    expect(SessionManager.sessionExpiredMessage.toLowerCase(),
        isNot(contains('token')));
    expect(SessionManager.sessionExpiredMessage,
        'Session expired. Please log in again.');
  });

  testWidgets('expireSession redirects to login and shows a friendly message',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(MaterialApp(
      navigatorKey: MyApp.navigatorKey,
      scaffoldMessengerKey: MyApp.scaffoldMessengerKey,
      initialRoute: 'home',
      routes: {
        'home': (_) => const Scaffold(body: Center(child: Text('HOME SCREEN'))),
        logInScreenRoute: (_) =>
            const Scaffold(body: Center(child: Text('LOGIN SCREEN'))),
      },
    ));

    // Start on a normal in-app screen.
    expect(find.text('HOME SCREEN'), findsOneWidget);
    expect(find.text('LOGIN SCREEN'), findsNothing);

    await SessionManager.expireSession(reason: 'test');
    await tester.pump(); // run the post-frame callback: nav + showSnackBar
    await tester.pump(const Duration(milliseconds: 400)); // route transition
    await tester.pump(const Duration(milliseconds: 400)); // SnackBar enter

    // Bounced to login, back stack wiped — no Retry-stuck dead end.
    expect(find.text('LOGIN SCREEN'), findsOneWidget);
    expect(find.text('HOME SCREEN'), findsNothing);

    // Friendly, jargon-free SnackBar.
    expect(find.text(SessionManager.sessionExpiredMessage), findsOneWidget);

    // Drain the SnackBar's 4s auto-dismiss timer so the test ends clean
    // (a pending Timer at teardown fails the test).
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(seconds: 1));
  });
}
