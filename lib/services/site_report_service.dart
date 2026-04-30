import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../exceptions/api_exception.dart';
import '../models/site_report_models.dart';
import 'auth_service.dart';

class SiteReportService {
  final Dio _dio;

  SiteReportService({Dio? dio}) : _dio = dio ?? Dio();

  /// Per-project report-count summary across every project the customer
  /// can access. Used by the empty-state on the SiteReportsScreen so a
  /// customer who lands on a project with zero reports still gets a hint
  /// like "you have 1 report on Demo Project A". Common when an admin
  /// files a report against the wrong project from the portal dropdown.
  Future<List<SiteReportSummaryRow>> getReportSummary() async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/customer/site-reports/summary',
        options: Options(headers: await _getAuthHeaders()),
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data is List) {
          return data
              .map((row) =>
                  SiteReportSummaryRow.fromJson(row as Map<String, dynamic>))
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
        // Backend returns ApiResponse<Page<...>>; the page payload may
        // arrive in a few shapes depending on which controller produced
        // it. Handle each defensively so the customer app doesn't crash
        // on a future shape tweak:
        //   1. data == { content: [...] }              ← Spring Page
        //   2. data == [...]                           ← already a List
        //   3. data == { content: null } or absent     ← empty result
        if (data is List) {
          return data
              .map((json) => SiteReport.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        if (data is Map<String, dynamic>) {
          final content = data['content'];
          if (content is List) {
            return content
                .map((json) => SiteReport.fromJson(json as Map<String, dynamic>))
                .toList();
          }
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
    final token = await AuthService.getAccessToken();
    
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
