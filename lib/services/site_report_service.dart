import 'package:dio/dio.dart';
import '../constants.dart';
import '../models/site_report_models.dart';

class SiteReportService {
  final Dio _dio;

  SiteReportService({Dio? dio}) : _dio = dio ?? Dio();

  /// Get all site reports for the current customer's projects
  Future<List<SiteReport>> getCustomerSiteReports({
    int? projectId,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };
      
      if (projectId != null) {
        queryParams['projectId'] = projectId;
      }

      final response = await _dio.get(
        '$baseURL/api/customer/site-reports',
        queryParameters: queryParams,
        options: Options(
          headers: await _getAuthHeaders(),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data != null && data['content'] != null) {
          return (data['content'] as List)
              .map((json) => SiteReport.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching customer site reports: $e');
      rethrow;
    }
  }

  /// Get a specific site report by ID
  Future<SiteReport?> getSiteReportById(int id) async {
    try {
      final response = await _dio.get(
        '$baseURL/api/customer/site-reports/$id',
        options: Options(
          headers: await _getAuthHeaders(),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data != null) {
          return SiteReport.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching site report: $e');
      rethrow;
    }
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    // Implement your token retrieval logic
    // This is a placeholder - adjust based on your auth implementation
    final token = await _getStoredToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<String> _getStoredToken() async {
    // Implement token storage/retrieval
    // This is a placeholder - you might use shared_preferences or secure_storage
    return '';
  }
}
