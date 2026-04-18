import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/content_models.dart';

class ContentService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: ApiConfig.connectionTimeout,
    receiveTimeout: ApiConfig.receiveTimeout,
    headers: ApiConfig.defaultHeaders,
  ));

  static Future<List<LiveActivity>> getLiveActivities() async {
    try {
      final response = await _dio.get(ApiConfig.liveActivitiesEndpoint);
      final data = response.data;
      if (data is List) {
        return data
            .map((e) => LiveActivity.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> getBlogs({
    int page = 0,
    int size = 10,
    String? search,
  }) async {
    try {
      final params = <String, dynamic>{'page': page, 'size': size};
      if (search != null && search.isNotEmpty) params['search'] = search;

      final response =
          await _dio.get(ApiConfig.blogsEndpoint, queryParameters: params);
      final data = response.data;

      final List<BlogPost> content = [];
      if (data is Map && data['content'] is List) {
        for (final item in data['content'] as List) {
          content.add(BlogPost.fromJson(item as Map<String, dynamic>));
        }
      }

      return {
        'content': content,
        'totalElements': (data is Map ? data['totalElements'] ?? 0 : 0),
        'totalPages': (data is Map ? data['totalPages'] ?? 0 : 0),
      };
    } catch (_) {
      return {'content': <BlogPost>[], 'totalElements': 0, 'totalPages': 0};
    }
  }

  static Future<BlogPost?> getBlogBySlug(String slug) async {
    try {
      final response =
          await _dio.get('${ApiConfig.blogsEndpoint}/$slug');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return BlogPost.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> getPortfolio({
    int page = 0,
    int size = 10,
    String? projectType,
  }) async {
    try {
      final params = <String, dynamic>{'page': page, 'size': size};
      if (projectType != null && projectType.isNotEmpty) {
        params['projectType'] = projectType;
      }

      final response = await _dio.get(ApiConfig.portfolioEndpoint,
          queryParameters: params);
      final data = response.data;

      final List<PortfolioItem> content = [];
      if (data is Map && data['content'] is List) {
        for (final item in data['content'] as List) {
          content.add(PortfolioItem.fromJson(item as Map<String, dynamic>));
        }
      }

      return {
        'content': content,
        'totalElements': (data is Map ? data['totalElements'] ?? 0 : 0),
        'totalPages': (data is Map ? data['totalPages'] ?? 0 : 0),
      };
    } catch (_) {
      return {
        'content': <PortfolioItem>[],
        'totalElements': 0,
        'totalPages': 0
      };
    }
  }

  static Future<PortfolioItem?> getPortfolioBySlug(String slug) async {
    try {
      final response =
          await _dio.get('${ApiConfig.portfolioEndpoint}/$slug');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return PortfolioItem.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
