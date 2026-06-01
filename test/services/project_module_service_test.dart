import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wd_cust_mobile_app/services/project_module_service.dart';

import '../test_helpers/mock_dio_adapter.dart';

/// Unit tests for [ProjectModuleService] driven through an injected [Dio]
/// backed by [MockDioAdapter]. Handlers are keyed on the RELATIVE path the
/// service passes to `_dio.get/post/put(...)` (the service sets baseUrl in
/// BaseOptions, so `options.path` is the relative path).
///
/// Notes on error semantics:
/// - Dio's default `validateStatus` rejects any non-2xx status, so a 500/403
///   response surfaces as a thrown [DioException] BEFORE the method's own
///   `else { throw Exception(...) }` branch can run. Those branches are only
///   reachable for unexpected 2xx codes (e.g. a method that requires 201 but
///   the server answers 200). Tests assert the realistic behaviour.
void main() {
  const pid = 'proj-uuid-1';
  late MockDioAdapter adapter;
  late ProjectModuleService service;

  setUp(() {
    adapter = MockDioAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://test.example'))
      ..httpClientAdapter = adapter;
    service = ProjectModuleService(
      baseUrl: 'https://test.example',
      token: 'tkn',
      dio: dio,
    );
  });

  // Wraps a payload in the customer-API standard {success, message, data}.
  Map<String, dynamic> envelope(Object? data, {bool success = true}) => {
        'success': success,
        'message': 'ok',
        'data': data,
      };

  // ===== DOCUMENT CATEGORIES =====
  group('getDocumentCategories', () {
    test('parses category list on 200', () async {
      adapter.onGet('/api/projects/$pid/documents/categories', (_) async {
        return jsonResponse(envelope([
          {'id': 1, 'name': 'Drawings', 'description': 'CAD', 'displayOrder': 2},
          {'id': 2, 'name': 'Permits', 'displayOrder': 1},
        ]));
      });

      final result = await service.getDocumentCategories(pid);

      expect(result, hasLength(2));
      expect(result[0].id, 1);
      expect(result[0].name, 'Drawings');
      expect(result[1].description, isNull);
    });

    test('returns [] when data is null on 200', () async {
      adapter.onGet('/api/projects/$pid/documents/categories',
          (_) async => jsonResponse(envelope(null)));

      expect(await service.getDocumentCategories(pid), isEmpty);
    });

    test('throws on 500 (DioException)', () async {
      adapter.onGet('/api/projects/$pid/documents/categories',
          (_) async => jsonResponse(envelope(null), statusCode: 500));

      expect(service.getDocumentCategories(pid), throwsA(isA<DioException>()));
    });
  });

  // ===== DOCUMENTS =====
  group('getDocuments', () {
    test('parses document list on 200', () async {
      adapter.onGet('/api/projects/$pid/documents', (_) async {
        return jsonResponse(envelope([
          {
            'id': 10,
            'projectId': 5,
            'categoryId': 1,
            'categoryName': 'Drawings',
            'filename': 'plan.pdf',
            'filePath': '/x/plan.pdf',
            'downloadUrl': 'https://x/plan.pdf',
            'uploadDate': '2026-05-01T10:00:00',
            'version': 1,
            'isActive': true,
          },
        ]));
      });

      final result = await service.getDocuments(pid);
      expect(result, hasLength(1));
      expect(result.first.filename, 'plan.pdf');
      expect(result.first.version, 1);
    });

    test('forwards categoryId query param', () async {
      String? capturedQuery;
      adapter.onGet('/api/projects/$pid/documents', (options) async {
        capturedQuery = options.uri.query;
        return jsonResponse(envelope([]));
      });

      await service.getDocuments(pid, categoryId: 7);
      expect(capturedQuery, contains('categoryId=7'));
    });

    test('throws on 500', () async {
      adapter.onGet('/api/projects/$pid/documents',
          (_) async => jsonResponse(envelope(null), statusCode: 500));
      expect(service.getDocuments(pid), throwsA(isA<DioException>()));
    });
  });

  // ===== QUALITY CHECKS =====
  group('getQualityChecks', () {
    test('parses quality-check list on 200', () async {
      adapter.onGet('/api/projects/$pid/quality-check', (_) async {
        return jsonResponse(envelope([
          {
            'id': 1,
            'projectId': 5,
            'title': 'Slab cure',
            'status': 'OPEN',
            'priority': 'HIGH',
            'createdById': 3,
            'createdByName': 'Eng A',
            'createdAt': '2026-05-01T08:00:00',
          },
          {
            // Unattributed row → defaults to 'Site Engineer'
            'id': 2,
            'projectId': 5,
            'title': 'Rebar check',
            'status': 'OPEN',
            'priority': 'MEDIUM',
            'createdAt': '2026-05-02T08:00:00',
          },
        ]));
      });

      final result = await service.getQualityChecks(pid, status: 'OPEN');
      expect(result, hasLength(2));
      expect(result[0].title, 'Slab cure');
      expect(result[1].createdByName, 'Site Engineer');
    });

    test('forwards status query param', () async {
      String? q;
      adapter.onGet('/api/projects/$pid/quality-check', (o) async {
        q = o.uri.query;
        return jsonResponse(envelope([]));
      });
      await service.getQualityChecks(pid, status: 'RESOLVED');
      expect(q, contains('status=RESOLVED'));
    });

    test('throws on 500', () async {
      adapter.onGet('/api/projects/$pid/quality-check',
          (_) async => jsonResponse(envelope(null), statusCode: 500));
      expect(service.getQualityChecks(pid), throwsA(isA<DioException>()));
    });
  });

  // ===== ACTIVITIES =====
  group('getActivities', () {
    test('parses activity list on 200', () async {
      adapter.onGet('/api/projects/$pid/activities', (_) async {
        return jsonResponse(envelope([
          {
            'id': 1,
            'projectId': 5,
            'activityTypeName': 'Pour',
            'activityTypeIcon': 'build',
            'activityTypeColor': '#fff',
            'title': 'Concrete poured',
            'createdById': 3,
            'createdByName': 'Eng',
            'createdAt': '2026-05-01T08:00:00',
          },
        ]));
      });
      final result = await service.getActivities(pid);
      expect(result, hasLength(1));
      expect(result.first.title, 'Concrete poured');
    });

    test('throws on 500', () async {
      adapter.onGet('/api/projects/$pid/activities',
          (_) async => jsonResponse(envelope(null), statusCode: 500));
      expect(service.getActivities(pid), throwsA(isA<DioException>()));
    });
  });

  // ===== COMBINED ACTIVITIES =====
  group('getCombinedActivities', () {
    test('parses combined items on 200', () async {
      adapter.onGet('/api/projects/$pid/activities/combined', (_) async {
        return jsonResponse(envelope([
          {
            'id': 1,
            'type': 'SITE_REPORT',
            'title': 'Day 1',
            'timestamp': '2026-05-01T08:00:00',
            'date': '2026-05-01T00:00:00',
            'createdByName': 'Eng',
          },
        ]));
      });
      final result = await service.getCombinedActivities(pid, type: 'SITE_REPORT');
      expect(result, hasLength(1));
      expect(result.first.isSiteReport, isTrue);
    });

    test('forwards type query param', () async {
      String? q;
      adapter.onGet('/api/projects/$pid/activities/combined', (o) async {
        q = o.uri.query;
        return jsonResponse(envelope([]));
      });
      await service.getCombinedActivities(pid, type: 'QUERY');
      expect(q, contains('type=QUERY'));
    });

    test('throws on 500', () async {
      adapter.onGet('/api/projects/$pid/activities/combined',
          (_) async => jsonResponse(envelope(null), statusCode: 500));
      expect(service.getCombinedActivities(pid), throwsA(isA<DioException>()));
    });
  });

  // ===== COMBINED ACTIVITIES GROUPED =====
  group('getCombinedActivitiesGrouped', () {
    test('parses date-keyed map on 200', () async {
      adapter.onGet('/api/projects/$pid/activities/combined/grouped', (_) async {
        return jsonResponse(envelope({
          '2026-05-01': [
            {
              'id': 1,
              'type': 'GALLERY',
              'title': 'Photos',
              'timestamp': '2026-05-01T09:00:00',
              'date': '2026-05-01T00:00:00',
              'createdByName': 'Eng',
            },
          ],
        }));
      });
      final result = await service.getCombinedActivitiesGrouped(pid);
      expect(result, hasLength(1));
      final key = DateTime.parse('2026-05-01');
      expect(result[key], hasLength(1));
      expect(result[key]!.first.type, 'GALLERY');
    });

    test('returns {} when success != true', () async {
      adapter.onGet('/api/projects/$pid/activities/combined/grouped',
          (_) async => jsonResponse({'success': false, 'data': null}));
      expect(await service.getCombinedActivitiesGrouped(pid), isEmpty);
    });

    test('throws on 500', () async {
      adapter.onGet('/api/projects/$pid/activities/combined/grouped',
          (_) async => jsonResponse(envelope(null), statusCode: 500));
      expect(service.getCombinedActivitiesGrouped(pid),
          throwsA(isA<DioException>()));
    });
  });

  // ===== GALLERY IMAGES =====
  group('getGalleryImages', () {
    test('parses gallery list on 200', () async {
      adapter.onGet('/api/projects/$pid/gallery', (_) async {
        return jsonResponse(envelope([
          {
            'id': 1,
            'projectId': 5,
            'imagePath': '/img/1.jpg',
            'takenDate': '2026-05-01',
            'uploadedAt': '2026-05-01T08:00:00',
            'tags': ['exterior', 'day1'],
          },
        ]));
      });
      final result = await service.getGalleryImages(pid);
      expect(result, hasLength(1));
      expect(result.first.tags, ['exterior', 'day1']);
    });

    test('forwards date query param (date only)', () async {
      String? q;
      adapter.onGet('/api/projects/$pid/gallery', (o) async {
        q = o.uri.query;
        return jsonResponse(envelope([]));
      });
      await service.getGalleryImages(pid, date: DateTime(2026, 5, 1, 13, 30));
      expect(q, contains('date=2026-05-01'));
      expect(q, isNot(contains('13')));
    });

    test('throws on 500', () async {
      adapter.onGet('/api/projects/$pid/gallery',
          (_) async => jsonResponse(envelope(null), statusCode: 500));
      expect(service.getGalleryImages(pid), throwsA(isA<DioException>()));
    });
  });

  // ===== GALLERY IMAGES GROUPED =====
  group('getGalleryImagesGrouped', () {
    test('parses date-keyed map on 200', () async {
      adapter.onGet('/api/projects/$pid/gallery/grouped', (_) async {
        return jsonResponse(envelope({
          '2026-05-02': [
            {
              'id': 7,
              'projectId': 5,
              'imagePath': '/img/7.jpg',
              'takenDate': '2026-05-02',
              'uploadedAt': '2026-05-02T08:00:00',
            },
          ],
        }));
      });
      final result = await service.getGalleryImagesGrouped(pid);
      final key = DateTime.parse('2026-05-02');
      expect(result[key], hasLength(1));
      expect(result[key]!.first.id, 7);
    });

    test('returns {} when success != true', () async {
      adapter.onGet('/api/projects/$pid/gallery/grouped',
          (_) async => jsonResponse({'success': false, 'data': null}));
      expect(await service.getGalleryImagesGrouped(pid), isEmpty);
    });

    test('throws on 500', () async {
      adapter.onGet('/api/projects/$pid/gallery/grouped',
          (_) async => jsonResponse(envelope(null), statusCode: 500));
      expect(
          service.getGalleryImagesGrouped(pid), throwsA(isA<DioException>()));
    });
  });

  // ===== OBSERVATIONS =====
  Map<String, dynamic> obs(int id, String status) => {
        'id': id,
        'projectId': 5,
        'title': 'Crack $id',
        'description': 'desc',
        'reportedById': 3,
        'reportedByName': 'Eng',
        'reportedDate': '2026-05-01T08:00:00',
        'status': status,
        'priority': 'HIGH',
      };

  group('getObservations', () {
    test('parses observation list on 200', () async {
      adapter.onGet('/api/projects/$pid/observations',
          (_) async => jsonResponse(envelope([obs(1, 'OPEN')])));
      final result = await service.getObservations(pid, status: 'OPEN');
      expect(result, hasLength(1));
      expect(result.first.status, 'OPEN');
    });

    test('forwards status query param', () async {
      String? q;
      adapter.onGet('/api/projects/$pid/observations', (o) async {
        q = o.uri.query;
        return jsonResponse(envelope([]));
      });
      await service.getObservations(pid, status: 'RESOLVED');
      expect(q, contains('status=RESOLVED'));
    });

    test('throws on 500', () async {
      adapter.onGet('/api/projects/$pid/observations',
          (_) async => jsonResponse(envelope(null), statusCode: 500));
      expect(service.getObservations(pid), throwsA(isA<DioException>()));
    });
  });

  group('getActiveObservations', () {
    test('parses list on 200', () async {
      adapter.onGet('/api/projects/$pid/observations/active',
          (_) async => jsonResponse(envelope([obs(1, 'OPEN'), obs(2, 'IN_PROGRESS')])));
      expect(await service.getActiveObservations(pid), hasLength(2));
    });

    test('throws on 500', () async {
      adapter.onGet('/api/projects/$pid/observations/active',
          (_) async => jsonResponse(envelope(null), statusCode: 500));
      expect(service.getActiveObservations(pid), throwsA(isA<DioException>()));
    });
  });

  group('getResolvedObservations', () {
    test('parses list on 200', () async {
      adapter.onGet('/api/projects/$pid/observations/resolved',
          (_) async => jsonResponse(envelope([obs(9, 'RESOLVED')])));
      final r = await service.getResolvedObservations(pid);
      expect(r.single.status, 'RESOLVED');
    });

    test('throws on 500', () async {
      adapter.onGet('/api/projects/$pid/observations/resolved',
          (_) async => jsonResponse(envelope(null), statusCode: 500));
      expect(service.getResolvedObservations(pid),
          throwsA(isA<DioException>()));
    });
  });

  // ===== OBSERVATION COUNTS =====
  group('getObservationCounts', () {
    test('parses counts map on 200', () async {
      adapter.onGet('/api/projects/$pid/observations/counts', (_) async {
        return jsonResponse(envelope({'active': 3, 'resolved': 5, 'total': 8}));
      });
      final r = await service.getObservationCounts(pid);
      expect(r['active'], 3);
      expect(r['total'], 8);
    });

    test('returns {} when success != true', () async {
      adapter.onGet('/api/projects/$pid/observations/counts',
          (_) async => jsonResponse({'success': false, 'data': null}));
      expect(await service.getObservationCounts(pid), isEmpty);
    });

    test('throws on 500', () async {
      adapter.onGet('/api/projects/$pid/observations/counts',
          (_) async => jsonResponse(envelope(null), statusCode: 500));
      expect(service.getObservationCounts(pid), throwsA(isA<DioException>()));
    });
  });

  // ===== CCTV =====
  group('getCameras', () {
    test('parses camera list on 200', () async {
      adapter.onGet('/api/projects/$pid/cctv', (_) async {
        return jsonResponse(envelope([
          {'id': 1, 'cameraName': 'Front', 'isActive': true},
          {'id': 2, 'camera_name': 'Rear', 'is_active': false},
        ]));
      });
      final r = await service.getCameras(pid);
      expect(r, hasLength(2));
      expect(r[0].cameraName, 'Front');
      expect(r[1].cameraName, 'Rear');
      expect(r[1].isActive, isFalse);
    });

    test('forwards installedOnly query param when true', () async {
      String? q;
      adapter.onGet('/api/projects/$pid/cctv', (o) async {
        q = o.uri.query;
        return jsonResponse(envelope([]));
      });
      await service.getCameras(pid, installedOnly: true);
      expect(q, contains('installedOnly=true'));
    });

    test('throws on 500', () async {
      adapter.onGet('/api/projects/$pid/cctv',
          (_) async => jsonResponse(envelope(null), statusCode: 500));
      expect(service.getCameras(pid), throwsA(isA<DioException>()));
    });
  });

  // ===== 360 VIEWS =====
  Map<String, dynamic> view(int id) => {
        'id': id,
        'projectId': 5,
        'title': 'Living room',
        'viewUrl': 'https://x/$id',
        'uploadedAt': '2026-05-01T08:00:00',
        'viewCount': 4,
      };

  group('get360Views', () {
    test('parses 360 list on 200', () async {
      adapter.onGet('/api/projects/$pid/360-views',
          (_) async => jsonResponse(envelope([view(1)])));
      final r = await service.get360Views(pid);
      expect(r.single.viewCount, 4);
    });

    test('throws on 500', () async {
      adapter.onGet('/api/projects/$pid/360-views',
          (_) async => jsonResponse(envelope(null), statusCode: 500));
      expect(service.get360Views(pid), throwsA(isA<DioException>()));
    });
  });

  group('increment360ViewCount', () {
    test('returns updated view on 200', () async {
      adapter.onPost('/api/projects/$pid/360-views/1/increment-count',
          (_) async => jsonResponse(envelope(view(1))));
      final r = await service.increment360ViewCount(pid, 1);
      expect(r.id, 1);
      expect(r.viewCount, 4);
    });

    test('throws on 500', () async {
      adapter.onPost('/api/projects/$pid/360-views/1/increment-count',
          (_) async => jsonResponse(envelope(null), statusCode: 500));
      expect(service.increment360ViewCount(pid, 1),
          throwsA(isA<DioException>()));
    });
  });

  // ===== SITE VISITS =====
  Map<String, dynamic> visit(int id, {bool checkedOut = false}) => {
        'id': id,
        'projectId': 5,
        'visitorId': 3,
        'visitorName': 'Eng',
        'checkInTime': '2026-05-01T08:00:00',
        if (checkedOut) 'checkOutTime': '2026-05-01T12:00:00',
      };

  group('getSiteVisits', () {
    test('parses visit list on 200', () async {
      adapter.onGet('/api/projects/$pid/site-visits',
          (_) async => jsonResponse(envelope([visit(1), visit(2, checkedOut: true)])));
      final r = await service.getSiteVisits(pid);
      expect(r, hasLength(2));
      expect(r[1].checkOutTime, isNotNull);
    });

    test('throws on 500', () async {
      adapter.onGet('/api/projects/$pid/site-visits',
          (_) async => jsonResponse(envelope(null), statusCode: 500));
      expect(service.getSiteVisits(pid), throwsA(isA<DioException>()));
    });
  });

  group('getCompletedSiteVisits', () {
    test('parses list on 200', () async {
      adapter.onGet('/api/projects/$pid/site-visits/completed',
          (_) async => jsonResponse(envelope([visit(1, checkedOut: true)])));
      expect(await service.getCompletedSiteVisits(pid), hasLength(1));
    });

    test('throws on 500', () async {
      adapter.onGet('/api/projects/$pid/site-visits/completed',
          (_) async => jsonResponse(envelope(null), statusCode: 500));
      expect(service.getCompletedSiteVisits(pid),
          throwsA(isA<DioException>()));
    });
  });

  group('getOngoingSiteVisits', () {
    test('parses list on 200', () async {
      adapter.onGet('/api/projects/$pid/site-visits/ongoing',
          (_) async => jsonResponse(envelope([visit(1)])));
      expect(await service.getOngoingSiteVisits(pid), hasLength(1));
    });

    test('throws on 500', () async {
      adapter.onGet('/api/projects/$pid/site-visits/ongoing',
          (_) async => jsonResponse(envelope(null), statusCode: 500));
      expect(service.getOngoingSiteVisits(pid), throwsA(isA<DioException>()));
    });
  });

  group('checkIn', () {
    test('returns visit on 201', () async {
      adapter.onPost('/api/projects/$pid/site-visits/check-in',
          (_) async => jsonResponse(envelope(visit(11)), statusCode: 201));
      final r = await service.checkIn(pid, latitude: 10.0, longitude: 76.0);
      expect(r.id, 11);
    });

    test('sends lat/long in body', () async {
      Map<String, dynamic>? body;
      adapter.onPost('/api/projects/$pid/site-visits/check-in', (o) async {
        body = o.data as Map<String, dynamic>;
        return jsonResponse(envelope(visit(11)), statusCode: 201);
      });
      await service.checkIn(pid,
          latitude: 12.5, longitude: 77.5, purpose: 'Inspection');
      expect(body!['latitude'], 12.5);
      expect(body!['longitude'], 77.5);
      expect(body!['purpose'], 'Inspection');
    });

    test('throws on 500', () async {
      adapter.onPost('/api/projects/$pid/site-visits/check-in',
          (_) async => jsonResponse({'message': 'nope'}, statusCode: 500));
      expect(service.checkIn(pid, latitude: 1, longitude: 2),
          throwsA(isA<DioException>()));
    });
  });

  group('checkOut', () {
    test('returns visit on 200', () async {
      adapter.onPut('/api/projects/$pid/site-visits/11/check-out',
          (_) async => jsonResponse(envelope(visit(11, checkedOut: true))));
      final r =
          await service.checkOut(pid, 11, latitude: 10.0, longitude: 76.0);
      expect(r.id, 11);
      expect(r.checkOutTime, isNotNull);
    });

    test('throws on 500', () async {
      adapter.onPut('/api/projects/$pid/site-visits/11/check-out',
          (_) async => jsonResponse({'message': 'nope'}, statusCode: 500));
      expect(service.checkOut(pid, 11, latitude: 1, longitude: 2),
          throwsA(isA<DioException>()));
    });
  });

  // ===== FEEDBACK =====
  Map<String, dynamic> form(int id) => {
        'id': id,
        'projectId': 5,
        'title': 'Satisfaction',
        'createdById': 3,
        'createdByName': 'Admin',
        'createdAt': '2026-05-01T08:00:00',
        'isActive': true,
      };

  group('getFeedbackForms', () {
    test('parses form list on 200', () async {
      adapter.onGet('/api/projects/$pid/feedback',
          (_) async => jsonResponse(envelope([form(1)])));
      final r = await service.getFeedbackForms(pid);
      expect(r.single.title, 'Satisfaction');
    });

    test('throws on 500', () async {
      adapter.onGet('/api/projects/$pid/feedback',
          (_) async => jsonResponse(envelope(null), statusCode: 500));
      expect(service.getFeedbackForms(pid), throwsA(isA<DioException>()));
    });
  });

  group('submitFeedback', () {
    test('returns form on 201', () async {
      adapter.onPost('/api/projects/$pid/feedback/1/responses',
          (_) async => jsonResponse(envelope(form(1)), statusCode: 201));
      final r = await service.submitFeedback(pid, 1, rating: 5);
      expect(r.id, 1);
    });

    test('sends rating and comments in body', () async {
      Map<String, dynamic>? body;
      adapter.onPost('/api/projects/$pid/feedback/1/responses', (o) async {
        body = o.data as Map<String, dynamic>;
        return jsonResponse(envelope(form(1)), statusCode: 201);
      });
      await service.submitFeedback(pid, 1, rating: 4, comments: 'Good');
      expect(body!['rating'], 4);
      expect(body!['comments'], 'Good');
    });

    test('throws when server answers 200 instead of 201', () async {
      // 200 is a 2xx, so Dio does NOT throw; the method's own else-branch fires.
      adapter.onPost('/api/projects/$pid/feedback/1/responses',
          (_) async => jsonResponse(envelope(form(1))));
      expect(service.submitFeedback(pid, 1), throwsA(isA<Exception>()));
    });
  });

  group('getFeedbackResponses', () {
    test('parses response list on 200', () async {
      adapter.onGet('/api/projects/$pid/feedback/1/responses', (_) async {
        return jsonResponse(envelope([
          {
            'id': 1,
            'formId': 1,
            'formTitle': 'Satisfaction',
            'rating': 5,
            'comments': 'Great',
            'submittedAt': '2026-05-01T08:00:00',
          },
        ]));
      });
      final r = await service.getFeedbackResponses(pid, 1);
      expect(r.single.rating, 5);
      expect(r.single.adminResponse, isNull);
    });

    test('throws on 500', () async {
      adapter.onGet('/api/projects/$pid/feedback/1/responses',
          (_) async => jsonResponse(envelope(null), statusCode: 500));
      expect(service.getFeedbackResponses(pid, 1),
          throwsA(isA<DioException>()));
    });
  });

  // ===== BOQ =====
  Map<String, dynamic> boqItem(int id) => {
        'id': id,
        'projectId': 5,
        'workTypeId': 2,
        'workTypeName': 'Civil',
        'description': 'Brickwork',
        'executionPercentage': 50,
        'billingPercentage': 25,
        'createdAt': '2026-05-01T08:00:00',
        'updatedAt': '2026-05-02T08:00:00',
        'createdById': 3,
        'createdByName': 'Eng',
        'isActive': true,
        'itemKind': 'BASE',
      };

  group('getBoqItems', () {
    test('parses item list on 200', () async {
      adapter.onGet('/api/projects/$pid/boq',
          (_) async => jsonResponse(envelope([boqItem(1)])));
      final r = await service.getBoqItems(pid);
      expect(r.single.description, 'Brickwork');
      expect(r.single.executionPercentage, 50.0);
    });

    test('forwards workTypeId query param', () async {
      String? q;
      adapter.onGet('/api/projects/$pid/boq', (o) async {
        q = o.uri.query;
        return jsonResponse(envelope([]));
      });
      await service.getBoqItems(pid, workTypeId: 9);
      expect(q, contains('workTypeId=9'));
    });

    test('throws on 500', () async {
      adapter.onGet('/api/projects/$pid/boq',
          (_) async => jsonResponse(envelope(null), statusCode: 500));
      expect(service.getBoqItems(pid), throwsA(isA<DioException>()));
    });
  });

  group('getBoqWorkTypes', () {
    test('parses work-type list on 200', () async {
      adapter.onGet('/api/projects/$pid/boq/work-types', (_) async {
        return jsonResponse(envelope([
          {'id': 1, 'name': 'Civil', 'displayOrder': 1},
        ]));
      });
      final r = await service.getBoqWorkTypes(pid);
      expect(r.single.name, 'Civil');
    });

    test('throws on 500', () async {
      adapter.onGet('/api/projects/$pid/boq/work-types',
          (_) async => jsonResponse(envelope(null), statusCode: 500));
      expect(service.getBoqWorkTypes(pid), throwsA(isA<DioException>()));
    });
  });

  group('getBoqSummary', () {
    test('parses summary on 200', () async {
      adapter.onGet('/api/projects/$pid/boq/summary', (_) async {
        return jsonResponse(envelope({
          'projectId': 5,
          'totalExecutedAmount': 100000,
          'totalBilledAmount': 50000,
          'executionPercentage': 40,
          'billingPercentage': 20,
          'totalItems': 12,
          'workTypeSummaries': [
            {'workTypeId': 1, 'workTypeName': 'Civil', 'subtotal': 100000, 'itemCount': 12},
          ],
          'totalValueInclGst': 250000,
        }));
      });
      final r = await service.getBoqSummary(pid);
      expect(r, isNotNull);
      expect(r!.totalItems, 12);
      // Falls back to inclGst when totalPlannedAmount is absent.
      expect(r.totalPlannedAmount, 250000.0);
      expect(r.workTypeSummaries, hasLength(1));
    });

    test('returns null when data is null on 200', () async {
      adapter.onGet('/api/projects/$pid/boq/summary',
          (_) async => jsonResponse(envelope(null)));
      expect(await service.getBoqSummary(pid), isNull);
    });

    test('throws when success != true', () async {
      // 200 with success:false → method throws its own Exception.
      adapter.onGet('/api/projects/$pid/boq/summary',
          (_) async => jsonResponse({'success': false, 'data': null}));
      expect(service.getBoqSummary(pid), throwsA(isA<Exception>()));
    });

    test('throws on 500', () async {
      adapter.onGet('/api/projects/$pid/boq/summary',
          (_) async => jsonResponse(envelope(null), statusCode: 500));
      expect(service.getBoqSummary(pid), throwsA(isA<DioException>()));
    });
  });

  group('getBoqApprovalStatus', () {
    test('parses approval map on 200', () async {
      adapter.onGet('/api/projects/$pid/boq/approval', (_) async {
        return jsonResponse(envelope({'status': 'APPROVED', 'approvedAt': '2026-05-01'}));
      });
      final r = await service.getBoqApprovalStatus(pid);
      expect(r['status'], 'APPROVED');
      expect(r['approvedAt'], '2026-05-01');
    });

    test('returns {} when data absent on 200', () async {
      adapter.onGet('/api/projects/$pid/boq/approval',
          (_) async => jsonResponse({'success': true, 'data': null}));
      expect(await service.getBoqApprovalStatus(pid), isEmpty);
    });

    test('throws on 500', () async {
      adapter.onGet('/api/projects/$pid/boq/approval',
          (_) async => jsonResponse(envelope(null), statusCode: 500));
      expect(service.getBoqApprovalStatus(pid), throwsA(isA<DioException>()));
    });
  });

  group('submitBoqApproval', () {
    test('completes on 200 and sends status/message', () async {
      Map<String, dynamic>? body;
      adapter.onPost('/api/projects/$pid/boq/approval', (o) async {
        body = o.data as Map<String, dynamic>;
        return jsonResponse(envelope(null));
      });
      await service.submitBoqApproval(pid,
          status: 'CHANGE_REQUESTED', message: 'Revise kitchen');
      expect(body!['status'], 'CHANGE_REQUESTED');
      expect(body!['message'], 'Revise kitchen');
    });

    test('throws on 500', () async {
      adapter.onPost('/api/projects/$pid/boq/approval',
          (_) async => jsonResponse(envelope(null), statusCode: 500));
      expect(service.submitBoqApproval(pid, status: 'APPROVED'),
          throwsA(isA<DioException>()));
    });
  });

  // ===== WARRANTY =====
  group('getWarranties', () {
    test('parses warranties from data.warranties on 200', () async {
      adapter.onGet('/api/customer/projects/$pid/warranties', (_) async {
        return jsonResponse({
          'warranties': [
            {'id': 1, 'componentName': 'Waterproofing', 'status': 'ACTIVE'},
          ],
        });
      });
      final r = await service.getWarranties(pid);
      expect(r.single.componentName, 'Waterproofing');
      expect(r.single.isActive, isTrue);
    });

    test('returns [] when warranties key missing on 200', () async {
      adapter.onGet('/api/customer/projects/$pid/warranties',
          (_) async => jsonResponse({'other': true}));
      expect(await service.getWarranties(pid), isEmpty);
    });

    test('throws on 500', () async {
      adapter.onGet('/api/customer/projects/$pid/warranties',
          (_) async => jsonResponse({}, statusCode: 500));
      expect(service.getWarranties(pid), throwsA(isA<DioException>()));
    });
  });

  // ===== DELAY LOGS =====
  group('getDelayLogs', () {
    test('parses delays from data.delays on 200', () async {
      adapter.onGet('/api/customer/projects/$pid/delays', (_) async {
        return jsonResponse({
          'delays': [
            {
              'id': 1,
              'delayType': 'WEATHER',
              'fromDate': '2026-05-01',
              'isOpen': true,
              'impactDays': 3,
            },
          ],
        });
      });
      final r = await service.getDelayLogs(pid);
      expect(r.single.delayType, 'WEATHER');
      expect(r.single.impactDays, 3);
    });

    test('returns [] when delays key missing on 200', () async {
      adapter.onGet('/api/customer/projects/$pid/delays',
          (_) async => jsonResponse({'other': true}));
      expect(await service.getDelayLogs(pid), isEmpty);
    });

    test('throws on 500', () async {
      adapter.onGet('/api/customer/projects/$pid/delays',
          (_) async => jsonResponse({}, statusCode: 500));
      expect(service.getDelayLogs(pid), throwsA(isA<DioException>()));
    });
  });
}
