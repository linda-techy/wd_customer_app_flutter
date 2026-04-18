import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/boq_diff_models.dart';
import 'auth_service.dart';

class BoqDiffService {
  BoqDiffService._();

  static Future<Dio> _dio() async {
    final token = await AuthService.getAccessToken() ?? '';
    return Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      headers: ApiConfig.getAuthHeaders(token),
      connectTimeout: ApiConfig.connectionTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
    ));
  }

  /// Returns all BOQ document revisions for [projectId], oldest first.
  static Future<List<BoqRevision>> getRevisions(String projectId) async {
    final dio = await _dio();
    final res = await dio.get('/api/projects/$projectId/boq/revisions');
    _check(res.data, 'Failed to load BOQ revisions');
    final list = (res.data['revisions'] ?? []) as List;
    return list
        .map((j) => BoqRevision.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  /// Computes a diff between [fromDocId] and [toDocId] for [projectId].
  static Future<BoqDiffResult> getDiff(
      String projectId, int fromDocId, int toDocId) async {
    final dio = await _dio();
    final res = await dio.get(
      '/api/projects/$projectId/boq/diff',
      queryParameters: {'fromDoc': fromDocId, 'toDoc': toDocId},
    );
    _check(res.data, 'Failed to load BOQ diff');
    return BoqDiffResult.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  static void _check(dynamic data, String fallback) {
    if (data is Map && data['success'] == false) {
      throw Exception(data['message'] ?? fallback);
    }
  }
}
