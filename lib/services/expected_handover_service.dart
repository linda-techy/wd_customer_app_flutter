import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/expected_handover_model.dart';
import 'auth_service.dart';

/// Static-method wrapper around the customer-api expected-handover endpoint.
///
/// Mirrors the pattern of `DashboardService`, `BoqDiffService`, etc. — a
/// fresh [Dio] per call with the user's access token in `Authorization`
/// header. Returns `null` on auth failure or non-200 so the UI can degrade
/// gracefully (e.g., show "Schedule not yet approved" rather than throwing).
class ExpectedHandoverService {
  ExpectedHandoverService._();

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

  /// Fetches the expected-handover summary for the given project UUID.
  /// Returns `null` on any non-200 response or DioException so the UI can
  /// render the "schedule not yet approved" empty state instead of crashing.
  static Future<ExpectedHandover?> fetch(String projectUuid) async {
    try {
      final dio = await _dio();
      // Dio baseUrl is just the host (e.g. http://localhost:8081 or
      // https://cust-api.walldotbuilders.com — no /api suffix), so the
      // full /api/customer/... path lives here. Matches the convention
      // used by BoqDiffService, DashboardService, etc.
      final response = await dio.get(
        '/api/customer/projects/$projectUuid/expected-handover',
      );
      if (response.statusCode == 200 && response.data is Map) {
        return ExpectedHandover.fromJson(
            response.data as Map<String, dynamic>);
      }
      return null;
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
  }
}
