import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../exceptions/api_exception.dart';
import '../models/site_report_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        '${ApiConfig.baseUrl}/api/customer/site-reports',
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
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(
        message: 'An unexpected error occurred: $e',
        errorCode: 'UNKNOWN_ERROR',
      );
    }
  }

  /// Get a specific site report by ID
  Future<SiteReport?> getSiteReportById(int id) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/customer/site-reports/$id',
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
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(
        message: 'An unexpected error occurred: $e',
        errorCode: 'UNKNOWN_ERROR',
      );
    }
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
