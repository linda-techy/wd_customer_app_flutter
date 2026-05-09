import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/next_payment_milestone.dart';
import 'auth_service.dart';

/// Static-method wrapper around the customer-api payment-schedule endpoint
/// in `?nextOnly=true` mode.
///
/// Mirrors the pattern of [ExpectedHandoverService] — a fresh [Dio] per
/// call with the user's access token in the Authorization header. Returns
/// `null` on auth failure, non-200, or any DioException so the project-detail
/// screen can render the empty state instead of crashing.
class NextPaymentService {
  NextPaymentService._();

  /// Test seam — set in tests to a [Dio] backed by a MockDioAdapter so the
  /// service does not need to hit the network. Production code leaves this
  /// `null` and a token-bearing Dio is built per-call.
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

  /// Fetches the next-payment milestone for the given project UUID. Returns
  /// `null` on any non-200 response or DioException so the UI can hide the
  /// card instead of throwing.
  static Future<NextPaymentMilestone?> fetch(String projectUuid) async {
    try {
      final dio = await _dio();
      final response = await dio.get(
        '/api/projects/$projectUuid/boq/payment-schedule',
        queryParameters: const {'nextOnly': 'true'},
      );
      if (response.statusCode == 200 && response.data is Map) {
        return NextPaymentMilestone.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
  }
}
