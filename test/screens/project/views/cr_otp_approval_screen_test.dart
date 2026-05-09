import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:wd_cust_mobile_app/models/change_request_summary.dart';
import 'package:wd_cust_mobile_app/providers/cr_otp_provider.dart';
import 'package:wd_cust_mobile_app/screens/project/views/cr_otp_approval_screen.dart';
import 'package:wd_cust_mobile_app/services/cr_otp_service.dart';

import '../../../test_helpers/mock_dio_adapter.dart';

ChangeRequestSummary _summary({int id = 7}) => ChangeRequestSummary(
      crId: id,
      title: 'Add 2 extra rooms',
      description: 'East wing upgrade',
      costImpactRupees: 125000,
      timeImpactWorkingDays: 12,
    );

Widget _wrap(CrOtpProvider provider) {
  return MaterialApp(
    home: ChangeNotifierProvider<CrOtpProvider>.value(
      value: provider,
      child: const CrOtpApprovalScreen(),
    ),
  );
}

void _resizeForPhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

/// Drain Dio's internal `Timer.run(...)` / 0-duration timers (used to
/// deliver the mocked response asynchronously) by pumping a small
/// fake-async window. Has to be called after any `requestOtp` / verify
/// trigger or the screen will stay in `sending` / `verifying`.
Future<void> _drainDio(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 10));
  }
}

void main() {
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

  testWidgets('renders Idle state with CR header + email hint',
      (tester) async {
    _resizeForPhone(tester);
    // Screen's initState fires `requestOtp` post-frame — register a
    // stub so the resulting Dio call resolves cleanly.
    adapter.onPost('/api/customer/cr/7/request-otp',
        (_) async => jsonResponse({'status': 'ok'}, statusCode: 202));
    final p = CrOtpProvider(_summary());
    await tester.pumpWidget(_wrap(p));
    await _drainDio(tester);

    expect(find.textContaining('Add 2 extra rooms'), findsOneWidget);
    expect(find.textContaining('Check your email'), findsOneWidget);
    expect(find.text('Verify & Approve'), findsOneWidget);
    p.dispose();
  });

  testWidgets('Verify button disabled until 6 digits typed',
      (tester) async {
    _resizeForPhone(tester);
    adapter.onPost('/api/customer/cr/7/request-otp',
        (_) async => jsonResponse({'status': 'ok'}, statusCode: 202));
    final p = CrOtpProvider(_summary());
    await tester.pumpWidget(_wrap(p));
    await _drainDio(tester);

    final verifyBtn = find.widgetWithText(ElevatedButton, 'Verify & Approve');
    expect(verifyBtn, findsOneWidget);
    expect(tester.widget<ElevatedButton>(verifyBtn).onPressed, isNull);

    // Type 5 digits — still disabled.
    await tester.enterText(find.byType(TextField), '12345');
    await tester.pump();
    expect(tester.widget<ElevatedButton>(verifyBtn).onPressed, isNull);

    // Type the 6th digit — enabled.
    await tester.enterText(find.byType(TextField), '123456');
    await tester.pump();
    expect(tester.widget<ElevatedButton>(verifyBtn).onPressed, isNotNull);
    p.dispose();
  });

  testWidgets('Tapping Resend in Sent (cooldown 0) fires requestOtp',
      (tester) async {
    _resizeForPhone(tester);
    int requestCount = 0;
    adapter.onPost('/api/customer/cr/7/request-otp', (_) async {
      requestCount++;
      return jsonResponse({'status': 'ok'}, statusCode: 202);
    });
    final p = CrOtpProvider(_summary());
    await tester.pumpWidget(_wrap(p));
    await _drainDio(tester);
    expect(requestCount, 1);

    // Force cooldown to 0 so the Resend button is enabled.
    for (var i = 0; i < 60; i++) {
      p.tickCooldownForTest();
    }
    await tester.pump();

    await tester.tap(find.text('Resend code'));
    await _drainDio(tester);
    expect(requestCount, 2);
    p.dispose();
  });

  testWidgets('Resend shows countdown when cooldown > 0', (tester) async {
    _resizeForPhone(tester);
    adapter.onPost('/api/customer/cr/7/request-otp',
        (_) async => jsonResponse({'status': 'ok'}, statusCode: 202));
    final p = CrOtpProvider(_summary());
    await tester.pumpWidget(_wrap(p));
    await _drainDio(tester);

    expect(find.textContaining('Resend code in 60s'), findsOneWidget);
    p.dispose();
  });

  testWidgets('On VERIFIED → screen pops with true result', (tester) async {
    _resizeForPhone(tester);
    adapter.onPost('/api/customer/cr/7/request-otp',
        (_) async => jsonResponse({'status': 'ok'}, statusCode: 202));
    adapter.onPost('/api/customer/cr/7/approve',
        (_) async => jsonResponse({'result': 'VERIFIED'}));

    final p = CrOtpProvider(_summary());

    Object? popResult;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (ctx) => Scaffold(
          body: Center(
            child: ElevatedButton(
              child: const Text('Open'),
              onPressed: () async {
                popResult = await Navigator.push<bool>(
                  ctx,
                  MaterialPageRoute(
                    builder: (_) =>
                        ChangeNotifierProvider<CrOtpProvider>.value(
                      value: p,
                      child: const CrOtpApprovalScreen(),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await _drainDio(tester);

    await tester.enterText(find.byType(TextField), '123456');
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Verify & Approve'));
    await _drainDio(tester);
    await tester.pump(const Duration(milliseconds: 500));

    expect(popResult, true);
    p.dispose();
  });

  testWidgets('Locked state shows "Request new code" button', (tester) async {
    _resizeForPhone(tester);
    adapter.onPost('/api/customer/cr/7/request-otp',
        (_) async => jsonResponse({'status': 'ok'}, statusCode: 202));
    adapter.onPost('/api/customer/cr/7/approve',
        (_) async => jsonResponse({'result': 'EXPIRED'}));
    final p = CrOtpProvider(_summary());
    await tester.pumpWidget(_wrap(p));
    await _drainDio(tester);

    // Now in `sent` — type a code and tap verify; server responds EXPIRED.
    await tester.enterText(find.byType(TextField), '123456');
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Verify & Approve'));
    await _drainDio(tester);

    expect(find.textContaining('expired'), findsOneWidget);
    expect(find.text('Request new code'), findsOneWidget);
    p.dispose();
  });

  testWidgets('Footer disclosure copy is rendered', (tester) async {
    _resizeForPhone(tester);
    adapter.onPost('/api/customer/cr/7/request-otp',
        (_) async => jsonResponse({'status': 'ok'}, statusCode: 202));
    final p = CrOtpProvider(_summary());
    await tester.pumpWidget(_wrap(p));
    await _drainDio(tester);

    expect(find.textContaining('By approving'), findsOneWidget);
    expect(find.textContaining('timestamp'), findsOneWidget);
    p.dispose();
  });
}
