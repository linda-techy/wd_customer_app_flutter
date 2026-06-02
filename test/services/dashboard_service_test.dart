import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wd_cust_mobile_app/config/api_config.dart';
import 'package:wd_cust_mobile_app/models/api_models.dart';
import 'package:wd_cust_mobile_app/models/timeline_item.dart';
import 'package:wd_cust_mobile_app/services/api_service.dart';
import 'package:wd_cust_mobile_app/services/dashboard_service.dart';

import '../test_helpers/mock_dio_adapter.dart';

/// MockDioAdapter-based unit tests for [DashboardService].
///
/// DashboardService is fully static and routes every HTTP call through the
/// ApiService singleton (`static final _apiService = ApiService()`). We swap
/// that singleton's underlying Dio for one backed by [MockDioAdapter] via the
/// `testDio` test seam, so the service's calls hit the mock transport.
///
/// Each DashboardService method also runs a pre-flight token check:
///   1. AuthService.getAccessToken()  -> flutter_secure_storage `read`
///   2. AuthService.isTokenExpired()  -> SharedPreferences `token_expiry`
/// We mock both:
///   - secure-storage channel returns a fake token (or null for the
///     session-expired path),
///   - SharedPreferences carries a far-future `token_expiry` so the refresh
///     branch is never taken (isTokenExpired -> false).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // ApiConfig.baseUrl reads dotenv.env; initialise it (empty) so it falls back
  // to the dev URL instead of throwing NotInitializedError.
  dotenv.loadFromString(envString: '', isOptional: true);

  late MockDioAdapter adapter;

  // ApiService builds absolute URLs ('${ApiConfig.baseUrl}/api/...'), so
  // options.path is the full URL string -> register handlers with the same.
  final base = ApiConfig.baseUrl;

  const secureStorageChannel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

  void mockToken(String? token) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (call) async {
      if (call.method == 'read') return token;
      // delete/write (used by SessionManager cleanup) -> no-op.
      return null;
    });
  }

  setUp(() {
    adapter = MockDioAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://test.example'))
      ..httpClientAdapter = adapter;
    ApiService().testDio = dio; // dashboard's _apiService is this singleton.

    mockToken('fake-token');
    // Far-future expiry => AuthService.isTokenExpired() == false, so the
    // happy-path calls skip the refresh branch entirely.
    final future = DateTime.now()
        .add(const Duration(days: 1))
        .millisecondsSinceEpoch;
    SharedPreferences.setMockInitialValues(<String, Object>{
      'token_expiry': future,
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, null);
  });

  group('DashboardService.getDashboard', () {
    test('parses a full dashboard payload into DashboardDto on 200', () async {
      adapter.onGet('$base/api/dashboard', (_) async => jsonResponse({
            'user': {
              'id': 24,
              'email': 'demo@x.com',
              'firstName': 'Demo',
              'lastName': 'Customer',
              'role': 'CUSTOMER',
            },
            'projects': {
              'totalProjects': 3,
              'activeProjects': 2,
              'completedProjects': 1,
              'recentProjects': [
                {
                  'id': 50,
                  'projectUuid': '6043e82e',
                  'name': 'Kerala G+1',
                  'progress': 42.5,
                  'status': 'CONSTRUCTION',
                },
              ],
            },
            'recentActivities': [
              {
                'type': 'PAYMENT',
                'description': 'Stage 4 paid',
                'timestamp': '2026-05-15T10:00:00',
                'projectId': 50,
                'projectName': 'Kerala G+1',
              },
            ],
            'quickStats': {
              'totalBills': 7,
              'pendingBills': 3,
              'paidBills': 4,
              'totalAmount': 3500000.0,
              'pendingAmount': 2100000.0,
            },
          }));

      final res = await DashboardService.getDashboard();

      expect(res.success, isTrue);
      expect(res.data, isA<DashboardDto>());
      final dto = res.data!;
      expect(dto.user.id, 24);
      expect(dto.user.fullName, 'Demo Customer');
      expect(dto.projects.totalProjects, 3);
      expect(dto.projects.recentProjects, hasLength(1));
      expect(dto.projects.recentProjects.first.name, 'Kerala G+1');
      expect(dto.projects.recentProjects.first.progress, 42.5);
      expect(dto.recentActivities, hasLength(1));
      expect(dto.recentActivities.first.type, 'PAYMENT');
      expect(dto.quickStats.pendingBills, 3);
      expect(dto.quickStats.totalAmount, 3500000.0);
    });

    test('returns a session-expired error (401) when token is null', () async {
      mockToken(null);

      final res = await DashboardService.getDashboard();

      expect(res.success, isFalse);
      expect(res.error, isNotNull);
      expect(res.error!.statusCode, 401);
      expect(res.error!.message, SessionExpiredMessageMatcher.value);
    });

    test('maps a non-2xx server response to an error ApiResponse', () async {
      // Default Dio validateStatus rejects 500 -> DioException -> caught by
      // ApiService.getDashboard and surfaced as an error ApiResponse.
      adapter.onGet('$base/api/dashboard',
          (_) async => jsonResponse({'message': 'boom'}, statusCode: 500));

      final res = await DashboardService.getDashboard();

      expect(res.success, isFalse);
      expect(res.error, isNotNull);
      expect(res.error!.statusCode, 500);
      expect(res.error!.message, contains('boom'));
    });

    test('returns an error on transport failure (no handler registered)',
        () async {
      final res = await DashboardService.getDashboard();

      expect(res.success, isFalse);
      expect(res.error, isNotNull);
    });
  });

  group('DashboardService.searchProjects', () {
    test('parses a JSON list into ProjectCard models on 200', () async {
      adapter.onGet('$base/api/dashboard/search-projects',
          (_) async => jsonResponse([
                {
                  'id': 50,
                  'projectUuid': '6043e82e',
                  'name': 'Kerala G+1',
                  'progress': 42.5,
                  'status': 'CONSTRUCTION',
                },
                {
                  'id': 51,
                  'name': 'Villa',
                  'progress': 0,
                },
              ]));

      final res = await DashboardService.searchProjects('ker');

      expect(res.success, isTrue);
      expect(res.data, hasLength(2));
      expect(res.data!.first.id, 50);
      expect(res.data!.first.projectUuid, '6043e82e');
      expect(res.data![1].progress, 0.0);
    });

    test('sends the q query param when a query is supplied', () async {
      String? capturedQuery;
      adapter.onGet('$base/api/dashboard/search-projects', (options) async {
        capturedQuery = options.uri.query;
        return jsonResponse([]);
      });

      await DashboardService.searchProjects('ker');

      expect(capturedQuery, contains('q=ker'));
    });

    test('omits the q query param when query is null/empty', () async {
      String? capturedQuery;
      adapter.onGet('$base/api/dashboard/search-projects', (options) async {
        capturedQuery = options.uri.query;
        return jsonResponse([]);
      });

      await DashboardService.searchProjects();

      expect(capturedQuery, isEmpty);
    });

    test('returns an empty list (success) on a 200 empty array', () async {
      adapter.onGet('$base/api/dashboard/search-projects',
          (_) async => jsonResponse([]));

      final res = await DashboardService.searchProjects('none');

      expect(res.success, isTrue);
      expect(res.data, isEmpty);
    });

    test('returns a session-expired error (401) when token is null', () async {
      mockToken(null);

      final res = await DashboardService.searchProjects('ker');

      expect(res.success, isFalse);
      expect(res.error!.statusCode, 401);
    });

    test('maps a non-2xx response to an error ApiResponse', () async {
      adapter.onGet('$base/api/dashboard/search-projects',
          (_) async => jsonResponse({'message': 'forbidden'}, statusCode: 403));

      final res = await DashboardService.searchProjects('ker');

      expect(res.success, isFalse);
      expect(res.error!.statusCode, 403);
    });
  });

  group('DashboardService.getUserSummary', () {
    test('maps stored UserInfo into a UserSummary', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'user_info':
            '{"id":24,"email":"demo@x.com","firstName":"Demo","lastName":"Customer","role":"CUSTOMER"}',
      });

      final summary = await DashboardService.getUserSummary();

      expect(summary, isNotNull);
      expect(summary!.id, 24);
      expect(summary.email, 'demo@x.com');
      expect(summary.fullName, 'Demo Customer');
      expect(summary.role, 'CUSTOMER');
    });

    test('returns null when no user info is stored', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      final summary = await DashboardService.getUserSummary();

      expect(summary, isNull);
    });
  });

  group('DashboardService.getProjectDetails', () {
    const uuid = '6043e82e';

    test('parses project details on 200', () async {
      adapter.onGet('$base/api/dashboard/projects/$uuid',
          (_) async => jsonResponse({
                'id': 50,
                'projectUuid': uuid,
                'name': 'Kerala G+1',
                'progress': 42.5,
                'status': 'CONSTRUCTION',
                'projectPhase': 'Plastering',
                'designProgress': 100.0,
              }));

      final res = await DashboardService.getProjectDetails(uuid);

      expect(res.success, isTrue);
      expect(res.data, isA<ProjectDetails>());
      expect(res.data!.id, 50);
      expect(res.data!.name, 'Kerala G+1');
      expect(res.data!.progress, 42.5);
      expect(res.data!.phase, 'Plastering');
      expect(res.data!.documents, isEmpty);
    });

    test('returns a session-expired error (401) when token is null', () async {
      mockToken(null);

      final res = await DashboardService.getProjectDetails(uuid);

      expect(res.success, isFalse);
      expect(res.error!.statusCode, 401);
    });

    test('maps a non-2xx response to an error ApiResponse', () async {
      adapter.onGet('$base/api/dashboard/projects/$uuid',
          (_) async => jsonResponse({'message': 'not found'}, statusCode: 404));

      final res = await DashboardService.getProjectDetails(uuid);

      expect(res.success, isFalse);
      expect(res.error!.statusCode, 404);
    });
  });

  group('DashboardService.getProjectPhases', () {
    const uuid = '6043e82e';

    test('parses an ordered phase list on 200', () async {
      adapter.onGet('$base/api/dashboard/projects/$uuid/phases',
          (_) async => jsonResponse([
                {
                  'id': 1,
                  'phaseName': 'Foundation',
                  'status': 'COMPLETED',
                  'displayOrder': 1,
                },
                {
                  'id': 2,
                  'phaseName': 'Plastering',
                  'status': 'IN_PROGRESS',
                  'displayOrder': 2,
                },
              ]));

      final res = await DashboardService.getProjectPhases(uuid);

      expect(res.success, isTrue);
      expect(res.data, hasLength(2));
      expect(res.data!.first.phaseName, 'Foundation');
      expect(res.data!.first.isCompleted, isTrue);
      expect(res.data![1].isInProgress, isTrue);
    });

    test('returns an empty list (success) on a 200 empty array', () async {
      adapter.onGet('$base/api/dashboard/projects/$uuid/phases',
          (_) async => jsonResponse([]));

      final res = await DashboardService.getProjectPhases(uuid);

      expect(res.success, isTrue);
      expect(res.data, isEmpty);
    });

    test('returns a session-expired error (401) when token is null', () async {
      mockToken(null);

      final res = await DashboardService.getProjectPhases(uuid);

      expect(res.success, isFalse);
      expect(res.error!.statusCode, 401);
    });

    test('maps a non-2xx response to an error ApiResponse', () async {
      adapter.onGet('$base/api/dashboard/projects/$uuid/phases',
          (_) async => jsonResponse({'message': 'denied'}, statusCode: 403));

      final res = await DashboardService.getProjectPhases(uuid);

      expect(res.success, isFalse);
      expect(res.error!.statusCode, 403);
    });
  });

  group('DashboardService.getProjectTeam', () {
    const uuid = '6043e82e';

    test('parses a team-contact list on 200', () async {
      adapter.onGet('$base/api/dashboard/projects/$uuid/team',
          (_) async => jsonResponse([
                {
                  'userId': 7,
                  'name': 'Site Engineer',
                  'designation': 'Engineer',
                  'role': 'SITE_ENGINEER',
                  'phone': '9999',
                },
              ]));

      final res = await DashboardService.getProjectTeam(uuid);

      expect(res.success, isTrue);
      expect(res.data, hasLength(1));
      expect(res.data!.first.userId, 7);
      expect(res.data!.first.name, 'Site Engineer');
      expect(res.data!.first.hasPhone, isTrue);
    });

    test('returns a session-expired error (401) when token is null', () async {
      mockToken(null);

      final res = await DashboardService.getProjectTeam(uuid);

      expect(res.success, isFalse);
      expect(res.error!.statusCode, 401);
    });

    test('maps a non-2xx response to an error ApiResponse', () async {
      adapter.onGet('$base/api/dashboard/projects/$uuid/team',
          (_) async => jsonResponse({'message': 'denied'}, statusCode: 403));

      final res = await DashboardService.getProjectTeam(uuid);

      expect(res.success, isFalse);
      expect(res.error!.statusCode, 403);
    });
  });

  group('DashboardService.getTimeline', () {
    const uuid = '6043e82e';
    // ApiService bakes ?bucket&page&size straight into the URL string (not via
    // Dio queryParameters), so options.path carries the full query — register
    // handlers with the exact path+query the method builds.
    final timelineBase = '$base/api/customer/projects/$uuid/timeline';

    test('parses a paginated timeline page on 200', () async {
      adapter.onGet('$timelineBase?bucket=week&page=0&size=20',
          (_) async => jsonResponse({
            'items': [
              {
                'taskId': 101,
                'title': 'Brickwork',
                'progressPercent': 60,
                'status': 'IN_PROGRESS',
                'statusLabel': 'ON_TRACK',
              },
            ],
            'totalElements': 1,
            'totalPages': 1,
            'page': 0,
            'size': 20,
            'projectProgressPercent': 42,
          }));

      final res = await DashboardService.getTimeline(uuid, 'week');

      expect(res.success, isTrue);
      expect(res.data, isA<TimelinePage>());
      expect(res.data!.items, hasLength(1));
      expect(res.data!.items.first.taskId, 101);
      expect(res.data!.items.first.title, 'Brickwork');
      expect(res.data!.projectProgressPercent, 42);
    });

    test('passes bucket/page/size through as query params', () async {
      String? capturedQuery;
      adapter.onGet('$timelineBase?bucket=upcoming&page=2&size=5',
          (options) async {
        capturedQuery = options.uri.query;
        return jsonResponse({
          'items': [],
          'totalElements': 0,
          'totalPages': 0,
          'page': 2,
          'size': 5,
          'projectProgressPercent': 0,
        });
      });

      await DashboardService.getTimeline(uuid, 'upcoming', page: 2, size: 5);

      expect(capturedQuery, contains('bucket=upcoming'));
      expect(capturedQuery, contains('page=2'));
      expect(capturedQuery, contains('size=5'));
    });

    test('returns a session-expired error (401) when token is null', () async {
      mockToken(null);

      final res = await DashboardService.getTimeline(uuid, 'week');

      expect(res.success, isFalse);
      expect(res.error!.statusCode, 401);
    });

    test('maps a non-2xx response to an error ApiResponse', () async {
      adapter.onGet('$timelineBase?bucket=week&page=0&size=20',
          (_) async => jsonResponse({'message': 'denied'}, statusCode: 403));

      final res = await DashboardService.getTimeline(uuid, 'week');

      expect(res.success, isFalse);
      expect(res.error!.statusCode, 403);
    });
  });

  group('DashboardService.getTimelineSummary', () {
    const uuid = '6043e82e';

    test('parses the timeline summary on 200', () async {
      adapter.onGet('$base/api/customer/projects/$uuid/timeline/summary',
          (_) async => jsonResponse({
                'weekCount': 4,
                'upcomingCount': 9,
                'completedCount': 12,
                'projectProgressPercent': 42,
              }));

      final res = await DashboardService.getTimelineSummary(uuid);

      expect(res.success, isTrue);
      expect(res.data, isA<TimelineSummary>());
      expect(res.data!.weekCount, 4);
      expect(res.data!.upcomingCount, 9);
      expect(res.data!.completedCount, 12);
      expect(res.data!.projectProgressPercent, 42);
    });

    test('returns a session-expired error (401) when token is null', () async {
      mockToken(null);

      final res = await DashboardService.getTimelineSummary(uuid);

      expect(res.success, isFalse);
      expect(res.error!.statusCode, 401);
    });

    test('maps a non-2xx response to an error ApiResponse', () async {
      adapter.onGet('$base/api/customer/projects/$uuid/timeline/summary',
          (_) async => jsonResponse({'message': 'denied'}, statusCode: 403));

      final res = await DashboardService.getTimelineSummary(uuid);

      expect(res.success, isFalse);
      expect(res.error!.statusCode, 403);
    });
  });

  group('DashboardService.updateDesignPackage', () {
    const uuid = '6043e82e';

    test('PUTs the design package and parses the returned ProjectDetails',
        () async {
      Map<String, dynamic>? capturedBody;
      adapter.onPut('$base/api/dashboard/projects/$uuid/design-package',
          (options) async {
        capturedBody = options.data as Map<String, dynamic>;
        return jsonResponse({
          'id': 50,
          'projectUuid': uuid,
          'name': 'Kerala G+1',
          'progress': 42.5,
          'designPackage': 'PREMIUM',
          'isDesignAgreementSigned': true,
        });
      });

      final res =
          await DashboardService.updateDesignPackage(uuid, 'PREMIUM');

      expect(res.success, isTrue);
      expect(res.data!.designPackage, 'PREMIUM');
      expect(res.data!.isDesignAgreementSigned, isTrue);
      expect(capturedBody!['designPackage'], 'PREMIUM');
      expect(capturedBody!['isDesignAgreementSigned'], true);
    });

    test('returns a session-expired error (401) when token is null', () async {
      mockToken(null);

      final res =
          await DashboardService.updateDesignPackage(uuid, 'PREMIUM');

      expect(res.success, isFalse);
      expect(res.error!.statusCode, 401);
    });

    test('maps a non-2xx response to an error ApiResponse', () async {
      adapter.onPut('$base/api/dashboard/projects/$uuid/design-package',
          (_) async => jsonResponse({'message': 'denied'}, statusCode: 403));

      final res =
          await DashboardService.updateDesignPackage(uuid, 'PREMIUM');

      expect(res.success, isFalse);
      expect(res.error!.statusCode, 403);
    });
  });
}

/// The exact session-expired copy DashboardService._sessionExpired() returns.
/// Mirrored here (rather than importing SessionManager) to keep this test off
/// the widget/navigator stack that SessionManager pulls in.
class SessionExpiredMessageMatcher {
  static const String value = 'Session expired. Please log in again.';
}
