import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wd_cust_mobile_app/services/cr_otp_service.dart';

import '../test_helpers/mock_dio_adapter.dart';

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

  group('CrOtpService.requestOtp', () {
    test('returns success on 202', () async {
      adapter.onPost(
        '/api/customer/cr/42/request-otp',
        (_) async => jsonResponse({'status': 'ok'}, statusCode: 202),
      );
      final r = await CrOtpService.requestOtp(42);
      expect(r, RequestOtpResult.success);
    });

    test('throws RateLimitException on 429', () async {
      adapter.onPost(
        '/api/customer/cr/42/request-otp',
        (_) async => jsonResponse(
          {'message': 'Rate limit exceeded', 'retryAfterSeconds': 3600},
          statusCode: 429,
        ),
      );
      await expectLater(
        CrOtpService.requestOtp(42),
        throwsA(isA<RateLimitException>()
            .having((e) => e.retryAfterSeconds, 'retryAfterSeconds', 3600)),
      );
    });

    test('throws ApiException on generic 500', () async {
      adapter.onPost(
        '/api/customer/cr/42/request-otp',
        (_) async => jsonResponse({'error': 'boom'}, statusCode: 500),
      );
      await expectLater(
        CrOtpService.requestOtp(42),
        throwsA(isA<ApiException>()),
      );
    });

    test('throws ApiException on network error', () async {
      // No handler registered for this path; adapter throws StateError.
      await expectLater(
        CrOtpService.requestOtp(99),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('CrOtpService.verifyOtp', () {
    test('returns VERIFIED', () async {
      adapter.onPost(
        '/api/customer/cr/42/approve',
        (_) async => jsonResponse({'result': 'VERIFIED'}),
      );
      final r = await CrOtpService.verifyOtp(42, '123456');
      expect(r, OtpVerifyResult.verified);
    });

    test('returns WRONG_CODE', () async {
      adapter.onPost(
        '/api/customer/cr/42/approve',
        (_) async => jsonResponse({'result': 'WRONG_CODE'}),
      );
      final r = await CrOtpService.verifyOtp(42, '999999');
      expect(r, OtpVerifyResult.wrongCode);
    });

    test('returns EXPIRED', () async {
      adapter.onPost(
        '/api/customer/cr/42/approve',
        (_) async => jsonResponse({'result': 'EXPIRED'}),
      );
      expect(await CrOtpService.verifyOtp(42, '123456'),
          OtpVerifyResult.expired);
    });

    test('returns MAX_ATTEMPTS', () async {
      adapter.onPost(
        '/api/customer/cr/42/approve',
        (_) async => jsonResponse({'result': 'MAX_ATTEMPTS'}),
      );
      expect(await CrOtpService.verifyOtp(42, '123456'),
          OtpVerifyResult.maxAttempts);
    });

    test('returns NO_ACTIVE_TOKEN', () async {
      adapter.onPost(
        '/api/customer/cr/42/approve',
        (_) async => jsonResponse({'result': 'NO_ACTIVE_TOKEN'}),
      );
      expect(await CrOtpService.verifyOtp(42, '123456'),
          OtpVerifyResult.noActiveToken);
    });

    test('sends otpCode in request body', () async {
      String? capturedBody;
      adapter.onPost('/api/customer/cr/42/approve', (options) async {
        capturedBody = (options.data as Map)['otpCode'] as String?;
        return jsonResponse({'result': 'VERIFIED'});
      });
      await CrOtpService.verifyOtp(42, '654321');
      expect(capturedBody, '654321');
    });

    test('throws ApiException on network error', () async {
      // No handler registered for this path; adapter throws StateError.
      await expectLater(
        CrOtpService.verifyOtp(99, '123456'),
        throwsA(isA<ApiException>()),
      );
    });
  });
}
