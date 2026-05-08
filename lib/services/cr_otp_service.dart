import 'package:dio/dio.dart';

import '../config/api_config.dart';
import 'auth_service.dart';

/// Possible outcomes of `requestOtp`.
enum RequestOtpResult { success }

/// Possible outcomes of `verifyOtp`. Mirrors the backend
/// `OtpVerifyResult` enum from S4 PR3 byte-for-byte.
enum OtpVerifyResult {
  verified,
  wrongCode,
  expired,
  maxAttempts,
  noActiveToken,
}

/// Thrown when the server returns 429 on `requestOtp`. The
/// `retryAfterSeconds` field surfaces the rate-limit window so the
/// UI can render a "try again later" hint.
class RateLimitException implements Exception {
  final int retryAfterSeconds;
  final String message;
  RateLimitException(this.retryAfterSeconds, this.message);

  @override
  String toString() =>
      'RateLimitException(retryAfter=${retryAfterSeconds}s, message=$message)';
}

/// Generic non-2xx / network failure. UI should render a simple
/// "Something went wrong, try again" banner.
class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode, $message)';
}

/// Static-method wrapper around the customer-API CR-OTP endpoints
/// (S4 PR3). Mirrors the `ExpectedHandoverService` pattern: a
/// `testDio` seam for unit tests + a token-bearing per-call Dio in
/// production. Throws on error so `CrOtpProvider` can drive the
/// state machine off explicit exception types.
class CrOtpService {
  CrOtpService._();

  /// Test seam — set in tests to a Dio backed by MockDioAdapter.
  static Dio? testDio;

  static Future<Dio> _dio() async {
    if (testDio != null) return testDio!;
    final token = await AuthService.getAccessToken() ?? '';
    return Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      headers: ApiConfig.getAuthHeaders(token),
      connectTimeout: ApiConfig.connectionTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
    ));
  }

  /// POST /api/customer/cr/{crId}/request-otp.
  /// 2xx → success. 429 → [RateLimitException]. Other non-2xx /
  /// network errors → [ApiException].
  static Future<RequestOtpResult> requestOtp(int crId) async {
    try {
      final dio = await _dio();
      final r = await dio.post(
        '/api/customer/cr/$crId/request-otp',
        // Dio default validateStatus rejects 4xx/5xx — we want the
        // 429 body so we override.
        options: Options(validateStatus: (_) => true),
      );
      if (r.statusCode != null && r.statusCode! >= 200 && r.statusCode! < 300) {
        return RequestOtpResult.success;
      }
      if (r.statusCode == 429) {
        final retryAfter =
            ((r.data is Map ? r.data['retryAfterSeconds'] : null) as num?)
                    ?.toInt() ??
                3600;
        final msg = (r.data is Map ? r.data['message'] : null) as String? ??
            'Too many OTP requests';
        throw RateLimitException(retryAfter, msg);
      }
      throw ApiException(r.statusCode ?? 0, 'request-otp failed');
    } on RateLimitException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(0, 'request-otp network error: $e');
    }
  }

  /// POST /api/customer/cr/{crId}/approve, body `{otpCode}`.
  /// Returns the parsed [OtpVerifyResult]. Network / non-2xx →
  /// [ApiException].
  static Future<OtpVerifyResult> verifyOtp(int crId, String code) async {
    try {
      final dio = await _dio();
      final r = await dio.post(
        '/api/customer/cr/$crId/approve',
        data: {'otpCode': code},
        options: Options(validateStatus: (_) => true),
      );
      if (r.statusCode == null || r.statusCode! < 200 || r.statusCode! >= 300) {
        throw ApiException(r.statusCode ?? 0, 'approve failed');
      }
      final result = (r.data is Map ? r.data['result'] : null) as String?;
      switch (result) {
        case 'VERIFIED':
          return OtpVerifyResult.verified;
        case 'WRONG_CODE':
          return OtpVerifyResult.wrongCode;
        case 'EXPIRED':
          return OtpVerifyResult.expired;
        case 'MAX_ATTEMPTS':
          return OtpVerifyResult.maxAttempts;
        case 'NO_ACTIVE_TOKEN':
          return OtpVerifyResult.noActiveToken;
        default:
          throw ApiException(r.statusCode ?? 0,
              'unknown verify result: $result');
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(0, 'approve network error: $e');
    }
  }
}
