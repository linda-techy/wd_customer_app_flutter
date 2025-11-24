import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/project_module_models.dart';

class ProjectModuleService {
  final String baseUrl;
  final String? token;

  ProjectModuleService({
    required this.baseUrl,
    this.token,
  });

  Map<String, String> get headers => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  // ===== DOCUMENT METHODS =====

  Future<List<DocumentCategory>> getDocumentCategories(int projectId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/projects/$projectId/documents/categories'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(
        json.decode(response.body),
        (data) => (data as List).map((e) => DocumentCategory.fromJson(e)).toList(),
      );
      return apiResponse.data ?? [];
    } else {
      throw Exception('Failed to load document categories');
    }
  }

  Future<List<ProjectDocument>> getDocuments(int projectId, {int? categoryId}) async {
    var uri = Uri.parse('$baseUrl/api/projects/$projectId/documents');
    if (categoryId != null) {
      uri = uri.replace(queryParameters: {'categoryId': categoryId.toString()});
    }

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(
        json.decode(response.body),
        (data) => (data as List).map((e) => ProjectDocument.fromJson(e)).toList(),
      );
      return apiResponse.data ?? [];
    } else {
      throw Exception('Failed to load documents');
    }
  }

  Future<ProjectDocument> uploadDocument(
    int projectId,
    File file,
    int categoryId, {
    String? description,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/projects/$projectId/documents'),
    );

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    request.fields['categoryId'] = categoryId.toString();
    if (description != null) request.fields['description'] = description;

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(
        json.decode(response.body),
        (data) => ProjectDocument.fromJson(data),
      );
      return apiResponse.data!;
    } else {
      throw Exception('Failed to upload document');
    }
  }

  // ===== QUALITY CHECK METHODS =====

  Future<List<QualityCheck>> getQualityChecks(int projectId, {String? status}) async {
    var uri = Uri.parse('$baseUrl/api/projects/$projectId/quality-check');
    if (status != null) {
      uri = uri.replace(queryParameters: {'status': status});
    }

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(
        json.decode(response.body),
        (data) => (data as List).map((e) => QualityCheck.fromJson(e)).toList(),
      );
      return apiResponse.data ?? [];
    } else {
      throw Exception('Failed to load quality checks');
    }
  }

  Future<QualityCheck> createQualityCheck(
    int projectId,
    String title,
    String description,
    String priority, {
    String? sopReference,
    int? assignedToId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/projects/$projectId/quality-check'),
      headers: headers,
      body: json.encode({
        'title': title,
        'description': description,
        'priority': priority,
        'sopReference': sopReference,
        'assignedToId': assignedToId,
      }),
    );

    if (response.statusCode == 201) {
      final apiResponse = ApiResponse.fromJson(
        json.decode(response.body),
        (data) => QualityCheck.fromJson(data),
      );
      return apiResponse.data!;
    } else {
      throw Exception('Failed to create quality check');
    }
  }

  Future<QualityCheck> resolveQualityCheck(
    int projectId,
    int qcId,
    String resolutionNotes,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/projects/$projectId/quality-check/$qcId'),
      headers: headers,
      body: json.encode({'resolutionNotes': resolutionNotes}),
    );

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(
        json.decode(response.body),
        (data) => QualityCheck.fromJson(data),
      );
      return apiResponse.data!;
    } else {
      throw Exception('Failed to resolve quality check');
    }
  }

  // ===== ACTIVITY FEED METHODS =====

  Future<List<ActivityFeed>> getActivities(int projectId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/projects/$projectId/activities'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(
        json.decode(response.body),
        (data) => (data as List).map((e) => ActivityFeed.fromJson(e)).toList(),
      );
      return apiResponse.data ?? [];
    } else {
      throw Exception('Failed to load activities');
    }
  }

  // ===== GALLERY METHODS =====

  Future<List<GalleryImage>> getGalleryImages(int projectId, {DateTime? date}) async {
    var uri = Uri.parse('$baseUrl/api/projects/$projectId/gallery');
    if (date != null) {
      uri = uri.replace(queryParameters: {'date': date.toIso8601String().split('T')[0]});
    }

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(
        json.decode(response.body),
        (data) => (data as List).map((e) => GalleryImage.fromJson(e)).toList(),
      );
      return apiResponse.data ?? [];
    } else {
      throw Exception('Failed to load gallery images');
    }
  }

  Future<GalleryImage> uploadGalleryImage(
    int projectId,
    File file, {
    String? caption,
    DateTime? takenDate,
    int? siteReportId,
    String? locationTag,
    List<String>? tags,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/projects/$projectId/gallery'),
    );

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    if (caption != null) request.fields['caption'] = caption;
    if (takenDate != null) request.fields['takenDate'] = takenDate.toIso8601String().split('T')[0];
    if (siteReportId != null) request.fields['siteReportId'] = siteReportId.toString();
    if (locationTag != null) request.fields['locationTag'] = locationTag;
    if (tags != null) {
      for (var tag in tags) {
        request.fields['tags'] = tag;
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      final apiResponse = ApiResponse.fromJson(
        json.decode(response.body),
        (data) => GalleryImage.fromJson(data),
      );
      return apiResponse.data!;
    } else {
      throw Exception('Failed to upload image');
    }
  }

  // ===== OBSERVATION METHODS =====

  Future<List<Observation>> getObservations(int projectId, {String? status}) async {
    var uri = Uri.parse('$baseUrl/api/projects/$projectId/observations');
    if (status != null) {
      uri = uri.replace(queryParameters: {'status': status});
    }

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(
        json.decode(response.body),
        (data) => (data as List).map((e) => Observation.fromJson(e)).toList(),
      );
      return apiResponse.data ?? [];
    } else {
      throw Exception('Failed to load observations');
    }
  }

  Future<Observation> createObservation(
    int projectId,
    String title,
    String description,
    String priority, {
    File? image,
    int? reportedByRoleId,
    String? location,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/projects/$projectId/observations'),
    );

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['priority'] = priority;
    if (reportedByRoleId != null) request.fields['reportedByRoleId'] = reportedByRoleId.toString();
    if (location != null) request.fields['location'] = location;
    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      final apiResponse = ApiResponse.fromJson(
        json.decode(response.body),
        (data) => Observation.fromJson(data),
      );
      return apiResponse.data!;
    } else {
      throw Exception('Failed to create observation');
    }
  }

  Future<Observation> resolveObservation(
    int projectId,
    int obsId,
    String resolutionNotes,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/projects/$projectId/observations/$obsId'),
      headers: headers,
      body: json.encode({'resolutionNotes': resolutionNotes}),
    );

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(
        json.decode(response.body),
        (data) => Observation.fromJson(data),
      );
      return apiResponse.data!;
    } else {
      throw Exception('Failed to resolve observation');
    }
  }

  // ===== QUERY METHODS =====

  Future<List<ProjectQuery>> getQueries(int projectId, {String? status}) async {
    var uri = Uri.parse('$baseUrl/api/projects/$projectId/queries');
    if (status != null) {
      uri = uri.replace(queryParameters: {'status': status});
    }

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(
        json.decode(response.body),
        (data) => (data as List).map((e) => ProjectQuery.fromJson(e)).toList(),
      );
      return apiResponse.data ?? [];
    } else {
      throw Exception('Failed to load queries');
    }
  }

  Future<ProjectQuery> createQuery(
    int projectId,
    String title,
    String description,
    String priority, {
    String? category,
    int? raisedByRoleId,
    int? assignedToId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/projects/$projectId/queries'),
      headers: headers,
      body: json.encode({
        'title': title,
        'description': description,
        'priority': priority,
        'category': category,
        'raisedByRoleId': raisedByRoleId,
        'assignedToId': assignedToId,
      }),
    );

    if (response.statusCode == 201) {
      final apiResponse = ApiResponse.fromJson(
        json.decode(response.body),
        (data) => ProjectQuery.fromJson(data),
      );
      return apiResponse.data!;
    } else {
      throw Exception('Failed to create query');
    }
  }

  Future<ProjectQuery> resolveQuery(
    int projectId,
    int queryId,
    String resolution,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/projects/$projectId/queries/$queryId'),
      headers: headers,
      body: json.encode({'resolution': resolution}),
    );

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(
        json.decode(response.body),
        (data) => ProjectQuery.fromJson(data),
      );
      return apiResponse.data!;
    } else {
      throw Exception('Failed to resolve query');
    }
  }

  // ===== CCTV METHODS =====

  Future<List<CctvCamera>> getCameras(int projectId, {bool installedOnly = false}) async {
    var uri = Uri.parse('$baseUrl/api/projects/$projectId/cctv');
    if (installedOnly) {
      uri = uri.replace(queryParameters: {'installedOnly': 'true'});
    }

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(
        json.decode(response.body),
        (data) => (data as List).map((e) => CctvCamera.fromJson(e)).toList(),
      );
      return apiResponse.data ?? [];
    } else {
      throw Exception('Failed to load cameras');
    }
  }

  // ===== 360 VIEW METHODS =====

  Future<List<View360>> get360Views(int projectId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/projects/$projectId/360-views'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(
        json.decode(response.body),
        (data) => (data as List).map((e) => View360.fromJson(e)).toList(),
      );
      return apiResponse.data ?? [];
    } else {
      throw Exception('Failed to load 360 views');
    }
  }

  Future<View360> increment360ViewCount(int projectId, int viewId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/projects/$projectId/360-views/$viewId/increment-count'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(
        json.decode(response.body),
        (data) => View360.fromJson(data),
      );
      return apiResponse.data!;
    } else {
      throw Exception('Failed to increment view count');
    }
  }

  // ===== SITE VISIT METHODS =====

  Future<List<SiteVisit>> getSiteVisits(int projectId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/projects/$projectId/site-visits'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(
        json.decode(response.body),
        (data) => (data as List).map((e) => SiteVisit.fromJson(e)).toList(),
      );
      return apiResponse.data ?? [];
    } else {
      throw Exception('Failed to load site visits');
    }
  }

  Future<SiteVisit> checkIn(
    int projectId, {
    String? purpose,
    String? location,
    String? weatherConditions,
    int? visitorRoleId,
    List<String>? attendees,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/projects/$projectId/site-visits/check-in'),
      headers: headers,
      body: json.encode({
        'purpose': purpose,
        'location': location,
        'weatherConditions': weatherConditions,
        'visitorRoleId': visitorRoleId,
        'attendees': attendees,
      }),
    );

    if (response.statusCode == 201) {
      final apiResponse = ApiResponse.fromJson(
        json.decode(response.body),
        (data) => SiteVisit.fromJson(data),
      );
      return apiResponse.data!;
    } else {
      throw Exception('Failed to check in');
    }
  }

  Future<SiteVisit> checkOut(
    int projectId,
    int visitId, {
    String? notes,
    String? findings,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/projects/$projectId/site-visits/$visitId/check-out'),
      headers: headers,
      body: json.encode({
        'notes': notes,
        'findings': findings,
      }),
    );

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(
        json.decode(response.body),
        (data) => SiteVisit.fromJson(data),
      );
      return apiResponse.data!;
    } else {
      throw Exception('Failed to check out');
    }
  }

  // ===== FEEDBACK METHODS =====

  Future<List<FeedbackForm>> getFeedbackForms(int projectId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/projects/$projectId/feedback'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(
        json.decode(response.body),
        (data) => (data as List).map((e) => FeedbackForm.fromJson(e)).toList(),
      );
      return apiResponse.data ?? [];
    } else {
      throw Exception('Failed to load feedback forms');
    }
  }

  Future<FeedbackForm> submitFeedback(
    int projectId,
    int formId, {
    int? rating,
    String? comments,
    Map<String, dynamic>? responseData,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/projects/$projectId/feedback/$formId/responses'),
      headers: headers,
      body: json.encode({
        'rating': rating,
        'comments': comments,
        'responseData': responseData,
      }),
    );

    if (response.statusCode == 201) {
      final apiResponse = ApiResponse.fromJson(
        json.decode(response.body),
        (data) => FeedbackForm.fromJson(data),
      );
      return apiResponse.data!;
    } else {
      throw Exception('Failed to submit feedback');
    }
  }

  // ===== BOQ METHODS =====

  Future<List<BoqItem>> getBoqItems(int projectId, {int? workTypeId}) async {
    var uri = Uri.parse('$baseUrl/api/projects/$projectId/boq');
    if (workTypeId != null) {
      uri = uri.replace(queryParameters: {'workTypeId': workTypeId.toString()});
    }

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(
        json.decode(response.body),
        (data) => (data as List).map((e) => BoqItem.fromJson(e)).toList(),
      );
      return apiResponse.data ?? [];
    } else {
      throw Exception('Failed to load BoQ items');
    }
  }

  Future<List<BoqWorkType>> getBoqWorkTypes(int projectId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/projects/$projectId/boq/work-types'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(
        json.decode(response.body),
        (data) => (data as List).map((e) => BoqWorkType.fromJson(e)).toList(),
      );
      return apiResponse.data ?? [];
    } else {
      throw Exception('Failed to load work types');
    }
  }
}

