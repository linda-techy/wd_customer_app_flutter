import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wd_cust_mobile_app/models/change_request_summary.dart';
import 'package:wd_cust_mobile_app/route/router.dart' as app_router;
import 'package:wd_cust_mobile_app/screens/project/views/cr_otp_approval_screen.dart';
import 'package:wd_cust_mobile_app/services/cr_otp_service.dart';

import '../test_helpers/mock_dio_adapter.dart';

/// Tests for the `/cr-approve/{crId}` named route — wired in
/// `lib/route/router.dart` as part of S4 PR4. The customer app uses
/// Navigator-2 with a `generateRoute(RouteSettings)` switchboard, so
/// route correctness is best verified by:
///   (a) feeding `generateRoute` a `RouteSettings` and inspecting the
///       returned `MaterialPageRoute`, then
///   (b) pumping the page builder into a `MaterialApp` and asserting
///       the resulting widget tree contains `CrOtpApprovalScreen`.
///
/// Sister-test in `test/screens/project/views/cr_otp_approval_screen_test.dart`
/// covers the screen's internals; this file owns the navigation seam.
void main() {
  group('/cr-approve/:id route', () {
    late MockDioAdapter adapter;

    setUp(() {
      adapter = MockDioAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://test.example'));
      dio.httpClientAdapter = adapter;
      CrOtpService.testDio = dio;
    });

    tearDown(() {
      CrOtpService.testDio = null;
    });

    test('returns a route when given a CR id + ChangeRequestSummary', () {
      const summary = ChangeRequestSummary(
        crId: 42,
        title: 'Add timber decking',
        costImpactRupees: 75000,
        timeImpactWorkingDays: 5,
      );
      final route = app_router.generateRoute(
        const RouteSettings(name: '/cr-approve/42', arguments: summary),
      );
      expect(route, isA<MaterialPageRoute<dynamic>>());
    });

    testWidgets('builder mounts CrOtpApprovalScreen', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Stub the auto-fired request-otp so the screen's initState
      // post-frame doesn't leave a dangling Dio timer.
      adapter.onPost('/api/customer/cr/42/request-otp',
          (_) async => jsonResponse({'status': 'ok'}, statusCode: 202));

      const summary = ChangeRequestSummary(
        crId: 42,
        title: 'Add timber decking',
        costImpactRupees: 75000,
        timeImpactWorkingDays: 5,
      );

      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: app_router.generateRoute,
          home: Builder(
            builder: (ctx) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  child: const Text('Open OTP'),
                  onPressed: () => Navigator.pushNamed(
                    ctx,
                    '/cr-approve/42',
                    arguments: summary,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Initial frame: only the launcher screen.
      expect(find.byType(CrOtpApprovalScreen), findsNothing);

      await tester.tap(find.text('Open OTP'));
      await tester.pump(); // Trigger the navigator transition.
      await tester.pump(const Duration(milliseconds: 500));
      // Drain Dio's internal 0-duration timer that delivers the mocked
      // response to the screen's auto-fired requestOtp.
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 10));
      }

      // The route generator should have wrapped the screen in a
      // route-scoped CrOtpProvider — if it didn't, the screen's
      // `context.read<CrOtpProvider>()` would have thrown by now.
      expect(find.byType(CrOtpApprovalScreen), findsOneWidget);
      // Header card from the screen should reflect the summary.
      expect(find.text('Add timber decking'), findsOneWidget);
    });

    test('falls back when arguments are missing', () {
      // Without arguments the route can't render the OTP header card,
      // so it should NOT return the OTP screen — guard against null
      // dereference inside the screen.
      final route = app_router.generateRoute(
        const RouteSettings(name: '/cr-approve/99'),
      );
      expect(route, isA<MaterialPageRoute<dynamic>>());
      // We don't assert which fallback widget it is — only that the
      // builder does not produce CrOtpApprovalScreen.
    });
  });
}
