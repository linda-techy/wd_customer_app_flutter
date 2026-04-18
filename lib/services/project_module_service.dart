import 'dart:io';
import 'package:dio/dio.dart';
import '../models/project_module_models.dart';
import '../models/task_models.dart';

class ProjectModuleService {
  final String baseUrl;
  final String? token;

  late final Dio _dio;

  ProjectModuleService({
    required this.baseUrl,
    this.token,
  }) {
    _dio = Dio(BaseOptions(baseUrl: baseUrl));
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  // ===== DOCUMENT METHODS =====

  Future<List<DocumentCategory>> getDocumentCategories(String projectId) async {
    final response = await _dio.get(
      '/api/projects/$projectId/documents/categories',
    );

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) =>
            (data as List).map((e) => DocumentCategory.fromJson(e)).toList(),
      );
      return apiResponse.data ?? [];
    } else {
      throw Exception('Failed to load document categories');
    }
  }

  Future<List<ProjectDocument>> getDocuments(String projectId,
      {int? categoryId}) async {
    final queryParameters = <String, dynamic>{};
    if (categoryId != null) {
      queryParameters['categoryId'] = categoryId.toString();
    }

    final response = await _dio.get(
      '/api/projects/$projectId/documents',
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) =>
            (data as List).map((e) => ProjectDocument.fromJson(e)).toList(),
      );
      return apiResponse.data ?? [];
    } else {
      throw Exception('Failed to load documents');
    }
  }

  Future<ProjectDocument> uploadDocument(
    String projectId,
    File file,
    int categoryId, {
    String? description,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path,
          filename: file.path.split('/').last),
      'categoryId': categoryId.toString(),
      if (description != null) 'description': description,
    });

    final response = await _dio.post(
      '/api/projects/$projectId/documents',
      data: formData,
    );

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => ProjectDocument.fromJson(data),
      );
      return apiResponse.data!;
    } else {
      throw Exception('Failed to upload document');
    }
  }

  // ===== QUALITY CHECK METHODS =====

  Future<List<QualityCheck>> getQualityChecks(String projectId,
      {String? status}) async {
    final queryParameters = <String, dynamic>{};
    if (status != null) {
      queryParameters['status'] = status;
    }

    final response = await _dio.get(
      '/api/projects/$projectId/quality-check',
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) =>
            (data as List).map((e) => QualityCheck.fromJson(e)).toList(),
      );
      return apiResponse.data ?? [];
    } else {
      throw Exception('Failed to load quality checks');
    }
  }

  Future<QualityCheck> createQualityCheck(
    String projectId,
    String title,
    String description,
    String priority, {
    String? sopReference,
    int? assignedToId,
  }) async {
    final response = await _dio.post(
      '/api/projects/$projectId/quality-check',
      data: {
        'title': title,
        'description': description,
        'priority': priority,
        'sopReference': sopReference,
        'assignedToId': assignedToId,
      },
    );

    if (response.statusCode == 201) {
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => QualityCheck.fromJson(data),
      );
      return apiResponse.data!;
    } else {
      throw Exception('Failed to create quality check');
    }
  }

  Future<QualityCheck> resolveQualityCheck(
    String projectId,
    int qcId,
    String resolutionNotes,
  ) async {
    final response = await _dio.put(
      '/api/projects/$projectId/quality-check/$qcId',
      data: {'resolutionNotes': resolutionNotes},
    );

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => QualityCheck.fromJson(data),
      );
      return apiResponse.data!;
    } else {
      throw Exception('Failed to resolve quality check');
    }
  }

  // ===== ACTIVITY FEED METHODS =====

  Future<List<ActivityFeed>> getActivities(String projectId) async {
    final response = await _dio.get(
      '/api/projects/$projectId/activities',
    );

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) =>
            (data as List).map((e) => ActivityFeed.fromJson(e)).toList(),
      );
      return apiResponse.data ?? [];
    } else {
      throw Exception('Failed to load activities');
    }
  }

  /// Get combined activity feed with site reports and queries
  Future<List<CombinedActivityItem>> getCombinedActivities(String projectId,
      {String? type}) async {
    final queryParameters = <String, dynamic>{};
    if (type != null) {
      queryParameters['type'] = type;
    }

    final response = await _dio.get(
      '/api/projects/$projectId/activities/combined',
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => (data as List)
            .map((e) => CombinedActivityItem.fromJson(e))
            .toList(),
      );
      return apiResponse.data ?? [];
    } else {
      throw Exception('Failed to load combined activities');
    }
  }

  /// Get combined activities grouped by date
  Future<Map<DateTime, List<CombinedActivityItem>>>
      getCombinedActivitiesGrouped(String projectId) async {
    final response = await _dio.get(
      '/api/projects/$projectId/activities/combined/grouped',
    );

    if (response.statusCode == 200) {
      final jsonData = response.data;
      if (jsonData['success'] == true && jsonData['data'] != null) {
        final Map<String, dynamic> data = jsonData['data'];
        return data.map((key, value) {
          return MapEntry(
            DateTime.parse(key),
            (value as List)
                .map((e) => CombinedActivityItem.fromJson(e))
                .toList(),
          );
        });
      }
      return {};
    } else {
      throw Exception('Failed to load grouped activities');
    }
  }

  // ===== GALLERY METHODS =====

  Future<List<GalleryImage>> getGalleryImages(String projectId,
      {DateTime? date}) async {
    final queryParameters = <String, dynamic>{};
    if (date != null) {
      queryParameters['date'] = date.toIso8601String().split('T')[0];
    }

    final response = await _dio.get(
      '/api/projects/$projectId/gallery',
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) =>
            (data as List).map((e) => GalleryImage.fromJson(e)).toList(),
      );
      return apiResponse.data ?? [];
    } else {
      throw Exception('Failed to load gallery images');
    }
  }

  /// Get gallery images grouped by date
  Future<Map<DateTime, List<GalleryImage>>> getGalleryImagesGrouped(
      String projectId) async {
    final response = await _dio.get(
      '/api/projects/$projectId/gallery/grouped',
    );

    if (response.statusCode == 200) {
      final jsonData = response.data;
      if (jsonData['success'] == true && jsonData['data'] != null) {
        final Map<String, dynamic> data = jsonData['data'];
        return data.map((key, value) {
          return MapEntry(
            DateTime.parse(key),
            (value as List).map((e) => GalleryImage.fromJson(e)).toList(),
          );
        });
      }
      return {};
    } else {
      throw Exception('Failed to load grouped gallery images');
    }
  }

  Future<GalleryImage> uploadGalleryImage(
    String projectId,
    File file, {
    String? caption,
    DateTime? takenDate,
    int? siteReportId,
    String? locationTag,
    List<String>? tags,
  }) async {
    final fields = <String, dynamic>{
      'file': await MultipartFile.fromFile(file.path,
          filename: file.path.split('/').last),
      if (caption != null) 'caption': caption,
      if (takenDate != null)
        'takenDate': takenDate.toIso8601String().split('T')[0],
      if (siteReportId != null) 'siteReportId': siteReportId.toString(),
      if (locationTag != null) 'locationTag': locationTag,
    };

    // Dio FormData handles repeated keys via MultiValue — for tags we use
    // a plain comma-separated string or repeated fields. The original code
    // overwrote the single 'tags' field on each iteration, so we replicate
    // that behaviour: only the last tag would have been sent. Keep identical
    // semantics by passing tags as a list entry if provided.
    if (tags != null && tags.isNotEmpty) {
      fields['tags'] = tags.last;
    }

    final formData = FormData.fromMap(fields);

    final response = await _dio.post(
      '/api/projects/$projectId/gallery',
      data: formData,
    );

    if (response.statusCode == 201) {
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => GalleryImage.fromJson(data),
      );
      return apiResponse.data!;
    } else {
      throw Exception('Failed to upload image');
    }
  }

  // ===== OBSERVATION (SNAGS) METHODS =====

  Future<List<Observation>> getObservations(String projectId,
      {String? status}) async {
    final queryParameters = <String, dynamic>{};
    if (status != null) {
      queryParameters['status'] = status;
    }

    final response = await _dio.get(
      '/api/projects/$projectId/observations',
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) =>
            (data as List).map((e) => Observation.fromJson(e)).toList(),
      );
      return apiResponse.data ?? [];
    } else {
      throw Exception('Failed to load observations');
    }
  }

  /// Get active (OPEN, IN_PROGRESS) observations/snags
  Future<List<Observation>> getActiveObservations(String projectId) async {
    final response = await _dio.get(
      '/api/projects/$projectId/observations/active',
    );

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) =>
            (data as List).map((e) => Observation.fromJson(e)).toList(),
      );
      return apiResponse.data ?? [];
    } else {
      throw Exception('Failed to load active observations');
    }
  }

  /// Get resolved observations/snags
  Future<List<Observation>> getResolvedObservations(String projectId) async {
    final response = await _dio.get(
      '/api/projects/$projectId/observations/resolved',
    );

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) =>
            (data as List).map((e) => Observation.fromJson(e)).toList(),
      );
      return apiResponse.data ?? [];
    } else {
      throw Exception('Failed to load resolved observations');
    }
  }

  /// Get observation counts (active, resolved, total)
  Future<Map<String, int>> getObservationCounts(String projectId) async {
    final response = await _dio.get(
      '/api/projects/$projectId/observations/counts',
    );

    if (response.statusCode == 200) {
      final jsonData = response.data;
      if (jsonData['success'] == true && jsonData['data'] != null) {
        return Map<String, int>.from(jsonData['data']);
      }
      return {};
    } else {
      throw Exception('Failed to load observation counts');
    }
  }

  Future<Observation> createObservation(
    String projectId,
    String title,
    String description,
    String priority, {
    File? image,
    int? reportedByRoleId,
    String? location,
  }) async {
    final fields = <String, dynamic>{
      'title': title,
      'description': description,
      'priority': priority,
      if (reportedByRoleId != null)
        'reportedByRoleId': reportedByRoleId.toString(),
      if (location != null) 'location': location,
      if (image != null)
        'image': await MultipartFile.fromFile(image.path,
            filename: image.path.split('/').last),
    };

    final formData = FormData.fromMap(fields);

    final response = await _dio.post(
      '/api/projects/$projectId/observations',
      data: formData,
    );

    if (response.statusCode == 201) {
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => Observation.fromJson(data),
      );
      return apiResponse.data!;
    } else {
      throw Exception('Failed to create observation');
    }
  }

  Future<Observation> resolveObservation(
    String projectId,
    int obsId,
    String resolutionNotes,
  ) async {
    final response = await _dio.put(
      '/api/projects/$projectId/observations/$obsId',
      data: {'resolutionNotes': resolutionNotes},
    );

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => Observation.fromJson(data),
      );
      return apiResponse.data!;
    } else {
      throw Exception('Failed to resolve observation');
    }
  }

  // ===== QUERY METHODS =====

  Future<List<ProjectQuery>> getQueries(String projectId,
      {String? status}) async {
    final queryParameters = <String, dynamic>{};
    if (status != null) {
      queryParameters['status'] = status;
    }

    final response = await _dio.get(
      '/api/projects/$projectId/queries',
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) =>
            (data as List).map((e) => ProjectQuery.fromJson(e)).toList(),
      );
      return apiResponse.data ?? [];
    } else {
      throw Exception('Failed to load queries');
    }
  }

  Future<ProjectQuery> createQuery(
    String projectId,
    String title,
    String description,
    String priority, {
    String? category,
    int? raisedByRoleId,
    int? assignedToId,
  }) async {
    final response = await _dio.post(
      '/api/projects/$projectId/queries',
      data: {
        'title': title,
        'description': description,
        'priority': priority,
        'category': category,
        'raisedByRoleId': raisedByRoleId,
        'assignedToId': assignedToId,
      },
    );

    if (response.statusCode == 201) {
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => ProjectQuery.fromJson(data),
      );
      return apiResponse.data!;
    } else {
      throw Exception('Failed to create query');
    }
  }

  Future<ProjectQuery> resolveQuery(
    String projectId,
    int queryId,
    String resolution,
  ) async {
    final response = await _dio.put(
      '/api/projects/$projectId/queries/$queryId',
      data: {'resolution': resolution},
    );

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => ProjectQuery.fromJson(data),
      );
      return apiResponse.data!;
    } else {
      throw Exception('Failed to resolve query');
    }
  }

  // ===== CCTV METHODS =====

  Future<List<CctvCamera>> getCameras(String projectId,
      {bool installedOnly = false}) async {
    final queryParameters = <String, dynamic>{};
    if (installedOnly) {
      queryParameters['installedOnly'] = 'true';
    }

    final response = await _dio.get(
      '/api/projects/$projectId/cctv',
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) =>
            (data as List).map((e) => CctvCamera.fromJson(e)).toList(),
      );
      return apiResponse.data ?? [];
    } else {
      throw Exception('Failed to load cameras');
    }
  }

  // ===== 360 VIEW METHODS =====

  Future<List<View360>> get360Views(String projectId) async {
    final response = await _dio.get(
      '/api/projects/$projectId/360-views',
    );

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => (data as List).map((e) => View360.fromJson(e)).toList(),
      );
      return apiResponse.data ?? [];
    } else {
      throw Exception('Failed to load 360 views');
    }
  }

  Future<View360> increment360ViewCount(String projectId, int viewId) async {
    final response = await _dio.post(
      '/api/projects/$projectId/360-views/$viewId/increment-count',
    );

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => View360.fromJson(data),
      );
      return apiResponse.data!;
    } else {
      throw Exception('Failed to increment view count');
    }
  }

  // ===== SITE VISIT METHODS =====

  Future<List<SiteVisit>> getSiteVisits(String projectId) async {
    final response = await _dio.get(
      '/api/projects/$projectId/site-visits',
    );

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) =>
            (data as List).map((e) => SiteVisit.fromJson(e)).toList(),
      );
      return apiResponse.data ?? [];
    } else {
      throw Exception('Failed to load site visits');
    }
  }

  /// Get completed site visits (with checkout time)
  Future<List<SiteVisit>> getCompletedSiteVisits(String projectId) async {
    final response = await _dio.get(
      '/api/projects/$projectId/site-visits/completed',
    );

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) =>
            (data as List).map((e) => SiteVisit.fromJson(e)).toList(),
      );
      return apiResponse.data ?? [];
    } else {
      throw Exception('Failed to load completed site visits');
    }
  }

  /// Get ongoing site visits (without checkout time)
  Future<List<SiteVisit>> getOngoingSiteVisits(String projectId) async {
    final response = await _dio.get(
      '/api/projects/$projectId/site-visits/ongoing',
    );

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) =>
            (data as List).map((e) => SiteVisit.fromJson(e)).toList(),
      );
      return apiResponse.data ?? [];
    } else {
      throw Exception('Failed to load ongoing site visits');
    }
  }

  Future<SiteVisit> checkIn(
    String projectId, {
    String? purpose,
    String? location,
    String? weatherConditions,
    int? visitorRoleId,
    List<String>? attendees,
    required double latitude,
    required double longitude,
  }) async {
    final response = await _dio.post(
      '/api/projects/$projectId/site-visits/check-in',
      data: {
        'purpose': purpose,
        'location': location,
        'weatherConditions': weatherConditions,
        'visitorRoleId': visitorRoleId,
        'attendees': attendees,
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    if (response.statusCode == 201) {
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => SiteVisit.fromJson(data),
      );
      return apiResponse.data!;
    } else {
      final body = response.data;
      throw Exception(body['message'] ?? 'Failed to check in');
    }
  }

  Future<SiteVisit> checkOut(
    String projectId,
    int visitId, {
    String? notes,
    String? findings,
    required double latitude,
    required double longitude,
  }) async {
    final response = await _dio.put(
      '/api/projects/$projectId/site-visits/$visitId/check-out',
      data: {
        'notes': notes,
        'findings': findings,
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => SiteVisit.fromJson(data),
      );
      return apiResponse.data!;
    } else {
      final body = response.data;
      throw Exception(body['message'] ?? 'Failed to check out');
    }
  }

  // ===== FEEDBACK METHODS =====

  Future<List<FeedbackForm>> getFeedbackForms(String projectId) async {
    final response = await _dio.get(
      '/api/projects/$projectId/feedback',
    );

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) =>
            (data as List).map((e) => FeedbackForm.fromJson(e)).toList(),
      );
      return apiResponse.data ?? [];
    } else {
      throw Exception('Failed to load feedback forms');
    }
  }

  Future<FeedbackForm> submitFeedback(
    String projectId,
    int formId, {
    int? rating,
    String? comments,
    Map<String, dynamic>? responseData,
  }) async {
    final response = await _dio.post(
      '/api/projects/$projectId/feedback/$formId/responses',
      data: {
        'rating': rating,
        'comments': comments,
        'responseData': responseData,
      },
    );

    if (response.statusCode == 201) {
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => FeedbackForm.fromJson(data),
      );
      return apiResponse.data!;
    } else {
      throw Exception('Failed to submit feedback');
    }
  }

  // ===== BOQ METHODS =====

  Future<List<BoqItem>> getBoqItems(String projectId,
      {int? workTypeId}) async {
    final queryParameters = <String, dynamic>{};
    if (workTypeId != null) {
      queryParameters['workTypeId'] = workTypeId.toString();
    }

    final response = await _dio.get(
      '/api/projects/$projectId/boq',
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => (data as List).map((e) => BoqItem.fromJson(e)).toList(),
      );
      return apiResponse.data ?? [];
    } else {
      throw Exception('Failed to load BoQ items');
    }
  }

  Future<List<BoqWorkType>> getBoqWorkTypes(String projectId) async {
    final response = await _dio.get(
      '/api/projects/$projectId/boq/work-types',
    );

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) =>
            (data as List).map((e) => BoqWorkType.fromJson(e)).toList(),
      );
      return apiResponse.data ?? [];
    } else {
      throw Exception('Failed to load work types');
    }
  }

  /// Returns aggregated BOQ financial summary from the backend.
  /// Only available for CUSTOMER / CUSTOMER_ADMIN / ADMIN roles (others get 403).
  Future<BoqSummary> getBoqSummary(String projectId) async {
    final response = await _dio.get('/api/projects/$projectId/boq/summary');
    if (response.statusCode == 200 && response.data['success'] == true) {
      return BoqSummary.fromJson(response.data['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to load BOQ summary');
  }

  /// Returns the latest customer BOQ approval status for this project.
  /// Possible status values: 'PENDING', 'APPROVED', 'CHANGE_REQUESTED'
  Future<Map<String, String>> getBoqApprovalStatus(String projectId) async {
    final response = await _dio.get('/api/projects/$projectId/boq/approval');
    if (response.statusCode == 200) {
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      return data.map((k, v) => MapEntry(k, v?.toString() ?? ''));
    }
    throw Exception('Failed to fetch BOQ approval status');
  }

  /// Submits a customer BOQ approval or change request.
  /// [status] must be 'APPROVED' or 'CHANGE_REQUESTED'.
  Future<void> submitBoqApproval(String projectId,
      {required String status, String? message}) async {
    final body = <String, String>{'status': status};
    if (message != null && message.isNotEmpty) body['message'] = message;
    final response = await _dio.post(
      '/api/projects/$projectId/boq/approval',
      data: body,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to submit BOQ response');
    }
  }

  // ===== WARRANTY METHODS =====

  Future<List<ProjectWarranty>> getWarranties(String projectId) async {
    final response = await _dio.get(
      '/api/customer/projects/$projectId/warranties',
    );

    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      final list = data['warranties'] as List? ?? [];
      return list.map((e) => ProjectWarranty.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load warranties');
    }
  }

  // ===== DELAY LOG METHODS =====

  Future<List<DelayLog>> getDelayLogs(String projectId) async {
    final response = await _dio.get(
      '/api/customer/projects/$projectId/delays',
    );

    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      final list = data['delays'] as List? ?? [];
      return list.map((e) => DelayLog.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load delay logs');
    }
  }

  // ===== TASK METHODS =====

  Future<List<ProjectTask>> getProjectTasks(String projectUuid, {String? status}) async {
    String path = '/api/projects/$projectUuid/tasks';
    if (status != null && status.isNotEmpty) {
      path += '?status=$status';
    }
    final response = await _dio.get(path);
    final List<dynamic> data = response.data is List ? response.data : [];
    return data.map((e) => ProjectTask.fromJson(e as Map<String, dynamic>)).toList();
  }
}
