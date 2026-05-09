import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wd_cust_mobile_app/models/change_request_summary.dart';
import 'package:wd_cust_mobile_app/providers/cr_otp_provider.dart';
import 'package:wd_cust_mobile_app/services/cr_otp_service.dart';

import '../test_helpers/mock_dio_adapter.dart';

ChangeRequestSummary _summary({int id = 7}) => ChangeRequestSummary(
      crId: id,
      title: 'Add 2 extra rooms',
      description: 'East wing upgrade',
      costImpactRupees: 125000,
      timeImpactWorkingDays: 12,
    );

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

  test('initial state is Idle', () {
    final p = CrOtpProvider(_summary());
    expect(p.state, CrOtpState.idle);
    expect(p.attempts, 0);
    expect(p.errorMessage, isNull);
  });

  test('requestOtp success → state Sent + cooldown active', () async {
    adapter.onPost(
      '/api/customer/cr/7/request-otp',
      (_) async => jsonResponse({'status': 'ok'}, statusCode: 202),
    );
    final p = CrOtpProvider(_summary());
    await p.requestOtp();
    expect(p.state, CrOtpState.sent);
    expect(p.resendCooldownSeconds, 60);
    p.dispose();
  });

  test('requestOtp 429 → state Error with rate-limit message', () async {
    adapter.onPost(
      '/api/customer/cr/7/request-otp',
      (_) async => jsonResponse(
        {'message': 'Too many', 'retryAfterSeconds': 3600},
        statusCode: 429,
      ),
    );
    final p = CrOtpProvider(_summary());
    await p.requestOtp();
    expect(p.state, CrOtpState.error);
    expect(p.errorMessage, contains('Too many'));
    p.dispose();
  });

  test('verifyOtp VERIFIED → state Approved', () async {
    adapter.onPost(
      '/api/customer/cr/7/request-otp',
      (_) async => jsonResponse({'status': 'ok'}, statusCode: 202),
    );
    adapter.onPost(
      '/api/customer/cr/7/approve',
      (_) async => jsonResponse({'result': 'VERIFIED'}),
    );
    final p = CrOtpProvider(_summary());
    await p.requestOtp();
    await p.verifyOtp('123456');
    expect(p.state, CrOtpState.approved);
    p.dispose();
  });

  test('verifyOtp WRONG_CODE → state Sent, attempts=1', () async {
    adapter.onPost(
      '/api/customer/cr/7/request-otp',
      (_) async => jsonResponse({'status': 'ok'}, statusCode: 202),
    );
    adapter.onPost(
      '/api/customer/cr/7/approve',
      (_) async => jsonResponse({'result': 'WRONG_CODE'}),
    );
    final p = CrOtpProvider(_summary());
    await p.requestOtp();
    await p.verifyOtp('999999');
    // After a wrong code we go back to Sent (cooldown still ticking) so
    // the customer can re-enter the code without re-requesting OTP.
    expect(p.state, CrOtpState.sent);
    expect(p.attempts, 1);
    expect(p.errorMessage, contains('Incorrect'));
    p.dispose();
  });

  test('three wrong attempts → state Locked', () async {
    adapter.onPost(
      '/api/customer/cr/7/request-otp',
      (_) async => jsonResponse({'status': 'ok'}, statusCode: 202),
    );
    int call = 0;
    adapter.onPost('/api/customer/cr/7/approve', (_) async {
      call++;
      // Backend reports MAX_ATTEMPTS on the third wrong code.
      return jsonResponse({
        'result': call < 3 ? 'WRONG_CODE' : 'MAX_ATTEMPTS',
      });
    });
    final p = CrOtpProvider(_summary());
    await p.requestOtp();
    await p.verifyOtp('111111');
    await p.verifyOtp('222222');
    await p.verifyOtp('333333');
    expect(p.state, CrOtpState.locked);
    expect(p.attempts, 3);
    p.dispose();
  });

  test('verifyOtp EXPIRED → state Locked (must request new OTP)', () async {
    adapter.onPost(
      '/api/customer/cr/7/request-otp',
      (_) async => jsonResponse({'status': 'ok'}, statusCode: 202),
    );
    adapter.onPost(
      '/api/customer/cr/7/approve',
      (_) async => jsonResponse({'result': 'EXPIRED'}),
    );
    final p = CrOtpProvider(_summary());
    await p.requestOtp();
    await p.verifyOtp('123456');
    expect(p.state, CrOtpState.locked);
    expect(p.errorMessage, contains('expired'));
    p.dispose();
  });

  test('cooldown ticks down on each second', () async {
    adapter.onPost(
      '/api/customer/cr/7/request-otp',
      (_) async => jsonResponse({'status': 'ok'}, statusCode: 202),
    );
    final p = CrOtpProvider(_summary());
    await p.requestOtp();
    expect(p.resendCooldownSeconds, 60);
    p.tickCooldownForTest();
    expect(p.resendCooldownSeconds, 59);
    p.tickCooldownForTest();
    expect(p.resendCooldownSeconds, 58);
    p.dispose();
  });

  test('resend after cooldown expires fires a new request', () async {
    int requestCount = 0;
    adapter.onPost('/api/customer/cr/7/request-otp', (_) async {
      requestCount++;
      return jsonResponse({'status': 'ok'}, statusCode: 202);
    });
    final p = CrOtpProvider(_summary());
    await p.requestOtp();
    expect(requestCount, 1);
    // Force-zero the cooldown so we can resend.
    for (var i = 0; i < 60; i++) {
      p.tickCooldownForTest();
    }
    expect(p.resendCooldownSeconds, 0);
    await p.requestOtp();
    expect(requestCount, 2);
    p.dispose();
  });

  test('dispose cancels timer (no listeners notified after)', () async {
    adapter.onPost(
      '/api/customer/cr/7/request-otp',
      (_) async => jsonResponse({'status': 'ok'}, statusCode: 202),
    );
    final p = CrOtpProvider(_summary());
    await p.requestOtp();
    int notifications = 0;
    p.addListener(() => notifications++);
    p.dispose();
    // After dispose() the periodic Timer is cancelled; no more
    // notifyListeners() calls fire from cooldown ticks. We rely on
    // dispose() not throwing as the success signal.
    expect(notifications, 0);
  });
}
