import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wd_cust_mobile_app/main.dart' show MyApp;
import 'package:wd_cust_mobile_app/route/route_constants.dart';
import 'package:wd_cust_mobile_app/services/notification_service.dart';

/// Mounts a stub MaterialApp with the same navigatorKey NotificationService uses,
/// then routes a synthetic RemoteMessage through the public test seam
/// `NotificationService.handleTapForTest` and asserts the resulting
/// Navigator.pushNamed call.
void main() {
  testWidgets('PAYMENT_MILESTONE_DUE tap routes to paymentsScreenRoute with projectId',
      (tester) async {
    final pushedRoutes = <RouteSettings>[];

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: MyApp.navigatorKey,
        home: const Scaffold(body: Text('home')),
        onGenerateRoute: (settings) {
          pushedRoutes.add(settings);
          return MaterialPageRoute(
            builder: (_) => const Scaffold(body: Text('routed')),
            settings: settings,
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    const message = RemoteMessage(
      data: {
        'type': 'PAYMENT_MILESTONE_DUE',
        'projectId': '42',
        'referenceId': '113',
        'deepLink': 'payments',
        'notificationType': 'PAYMENT_MILESTONE_DUE',
      },
    );

    NotificationService.handleTapForTest(message);
    await tester.pumpAndSettle();

    expect(pushedRoutes, hasLength(1));
    expect(pushedRoutes.single.name, paymentsScreenRoute);
    expect(pushedRoutes.single.arguments, 42);
  });

  testWidgets('PAYMENT_RECORDED tap still routes to paymentsScreenRoute (no regression)',
      (tester) async {
    final pushedRoutes = <RouteSettings>[];

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: MyApp.navigatorKey,
        home: const Scaffold(body: Text('home')),
        onGenerateRoute: (settings) {
          pushedRoutes.add(settings);
          return MaterialPageRoute(
            builder: (_) => const Scaffold(body: Text('routed')),
            settings: settings,
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    NotificationService.handleTapForTest(const RemoteMessage(
      data: {'type': 'PAYMENT_RECORDED', 'projectId': '42'},
    ));
    await tester.pumpAndSettle();

    expect(pushedRoutes.single.name, paymentsScreenRoute);
    expect(pushedRoutes.single.arguments, 42);
  });
}
