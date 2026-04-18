import 'package:dio/dio.dart';
import '../config/api_config.dart';

class GanttService {
  final String _baseUrl;
  final String _token;

  late final Dio _dio;

  GanttService({required String baseUrl, required String token})
      : _baseUrl = baseUrl,
        _token = token {
    _dio = Dio(BaseOptions(baseUrl: _baseUrl));
    _dio.options.headers['Authorization'] = 'Bearer $_token';
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.connectTimeout = ApiConfig.connectionTimeout;
    _dio.options.receiveTimeout = ApiConfig.receiveTimeout;
  }

  /// Fetches Gantt data for a project.
  /// Returns a map with keys:
  ///   tasks: List of task maps
  ///   projectStartDate: ISO date string
  ///   projectEndDate: ISO date string
  ///   overallProgress: double (0-100)
  ///   overdueTasks: int
  static Future<Map<String, dynamic>?> getGanttData(String projectId) async {
    // This static factory is intentionally left as a convenience wrapper.
    // Callers that already have a token should prefer the instance method below.
    throw UnimplementedError(
        'Use GanttService(baseUrl:, token:).fetchGanttData() instead.');
  }

  Future<Map<String, dynamic>?> fetchGanttData(String projectId) async {
    try {
      final response = await _dio.get(
        '/api/projects/$projectId/schedule/gantt',
      );
      if (response.statusCode == 200) {
        final body = response.data;
        if (body is Map<String, dynamic>) {
          // API may wrap in a standard envelope {success, data, message}
          if (body.containsKey('data') && body['data'] is Map<String, dynamic>) {
            return body['data'] as Map<String, dynamic>;
          }
          return body;
        }
      }
      return null;
    } on DioException {
      return null;
    }
  }
}
