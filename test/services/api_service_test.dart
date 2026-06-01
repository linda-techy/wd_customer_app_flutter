import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wd_cust_mobile_app/config/api_config.dart';
import 'package:wd_cust_mobile_app/services/api_service.dart';

import '../test_helpers/mock_dio_adapter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // ApiConfig.baseUrl reads dotenv.env; initialize it (empty) so it falls back
  // to the dev URL (http://localhost:8081) instead of throwing.
  dotenv.loadFromString(envString: '', isOptional: true);

  // ApiService methods pass ABSOLUTE urls (ApiConfig.xxxUrl or
  // '${ApiConfig.baseUrl}/...'), so options.path is the full URL string ->
  // register handlers with the same absolute URL.
  final base = ApiConfig.baseUrl;

  late MockDioAdapter adapter;
  late ApiService api;

  setUp(() {
    adapter = MockDioAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://test.example'))
      ..httpClientAdapter = adapter;
    api = ApiService();
    api.setTestDio(dio);
  });

  // Note on error paths: Dio's default validateStatus REJECTS non-2xx, so a
  // 4xx/5xx surfaces as a thrown DioException (caught -> ApiResponse.error).
  // The methods' own `else { statusCode != 200 }` error-body branch is NOT
  // reachable through this adapter for 2xx, so error tests drive the catch
  // branch via a 500 (DioException) or no-handler (StateError -> unknown).

  group('login', () {
    final path = ApiConfig.loginUrl;

    test('returns success with parsed LoginResponse on 200', () async {
      adapter.onPost(path, (_) async => jsonResponse({
            'accessToken': 'acc-123',
            'refreshToken': 'ref-456',
            'tokenType': 'Bearer',
            'expiresIn': 3600,
            'user': {
              'id': 7,
              'email': 'k@x.com',
              'firstName': 'Krishnan',
              'lastName': 'R',
              'role': 'CUSTOMER',
            },
            'permissions': ['VIEW_PROJECT'],
            'projectCount': 2,
            'redirectUrl': '/dashboard',
          }));

      final res = await api.login('k@x.com', 'pw');

      expect(res.success, isTrue);
      expect(res.data!.accessToken, 'acc-123');
      expect(res.data!.user.firstName, 'Krishnan');
      expect(res.data!.permissions, contains('VIEW_PROJECT'));
      expect(res.data!.projectCount, 2);
    });

    test('returns error on 500 (DioException caught)', () async {
      adapter.onPost(path,
          (_) async => jsonResponse({'message': 'boom'}, statusCode: 500));

      final res = await api.login('k@x.com', 'pw');

      expect(res.success, isFalse);
      expect(res.error, isNotNull);
      expect(res.error!.message, 'boom');
      expect(res.error!.statusCode, 500);
    });

    test('returns connectivity error on transport failure (no handler)',
        () async {
      final res = await api.login('k@x.com', 'pw');

      expect(res.success, isFalse);
      expect(res.error!.statusCode, 0);
      expect(res.error!.message, contains('Cannot reach the server'));
    });
  });

  group('forgotPassword', () {
    final path = ApiConfig.forgotPasswordUrl;

    test('returns success with raw map on 200', () async {
      adapter.onPost(path,
          (_) async => jsonResponse({'message': 'Reset code sent'}));

      final res = await api.forgotPassword('k@x.com');

      expect(res.success, isTrue);
      expect(res.data!['message'], 'Reset code sent');
    });

    test('returns error on 400 (DioException caught)', () async {
      adapter.onPost(path,
          (_) async => jsonResponse({'message': 'No such user'}, statusCode: 400));

      final res = await api.forgotPassword('k@x.com');

      expect(res.success, isFalse);
      expect(res.error!.message, 'No such user');
      expect(res.error!.statusCode, 400);
    });
  });

  group('resetPassword', () {
    final path = ApiConfig.resetPasswordUrl;

    test('returns success with raw map on 200', () async {
      adapter.onPost(path,
          (_) async => jsonResponse({'message': 'Password reset'}));

      final res = await api.resetPassword('k@x.com', '123456', 'newpw');

      expect(res.success, isTrue);
      expect(res.data!['message'], 'Password reset');
    });

    test('returns error on 400 (DioException caught)', () async {
      adapter.onPost(path,
          (_) async => jsonResponse({'message': 'Bad code'}, statusCode: 400));

      final res = await api.resetPassword('k@x.com', 'wrong', 'newpw');

      expect(res.success, isFalse);
      expect(res.error!.message, 'Bad code');
      expect(res.error!.statusCode, 400);
    });
  });

  group('refreshToken', () {
    final path = ApiConfig.refreshTokenUrl;

    test('returns success with parsed RefreshTokenResponse on 200', () async {
      adapter.onPost(path, (_) async => jsonResponse({
            'accessToken': 'new-acc',
            'tokenType': 'Bearer',
            'expiresIn': 1800,
          }));

      final res = await api.refreshToken('ref-456');

      expect(res.success, isTrue);
      expect(res.data!.accessToken, 'new-acc');
      expect(res.data!.expiresIn, 1800);
    });

    test('returns error on 401 (DioException caught)', () async {
      adapter.onPost(path,
          (_) async => jsonResponse({'message': 'expired'}, statusCode: 401));

      final res = await api.refreshToken('ref-456');

      expect(res.success, isFalse);
      expect(res.error!.message, contains('expired'));
      expect(res.error!.statusCode, 401);
    });
  });

  group('logout', () {
    final path = ApiConfig.logoutUrl;

    test('returns success on 200', () async {
      adapter.onPost(path, (_) async => jsonResponse({}));

      final res = await api.logout('ref-456', 'tkn');

      expect(res.success, isTrue);
    });

    test('returns error on 500 (DioException caught)', () async {
      adapter.onPost(path,
          (_) async => jsonResponse({'message': 'fail'}, statusCode: 500));

      final res = await api.logout('ref-456', 'tkn');

      expect(res.success, isFalse);
      expect(res.error!.message, contains('fail'));
      expect(res.error!.statusCode, 500);
    });
  });

  group('getCurrentUser', () {
    final path = ApiConfig.getCurrentUserUrl;

    test('returns success with parsed UserInfo on 200', () async {
      adapter.onGet(path, (_) async => jsonResponse({
            'id': 7,
            'email': 'k@x.com',
            'firstName': 'Krishnan',
            'lastName': 'R',
            'role': 'CUSTOMER',
            'phone': '9999',
          }));

      final res = await api.getCurrentUser('tkn');

      expect(res.success, isTrue);
      expect(res.data!.id, 7);
      expect(res.data!.fullName, 'Krishnan R');
      expect(res.data!.phone, '9999');
    });

    test('returns error on 401 (DioException caught)', () async {
      adapter.onGet(path,
          (_) async => jsonResponse({'message': 'unauth'}, statusCode: 401));

      final res = await api.getCurrentUser('tkn');

      expect(res.success, isFalse);
      expect(res.error!.message, contains('unauth'));
      expect(res.error!.statusCode, 401);
    });
  });

  group('getDashboard', () {
    final path = ApiConfig.dashboardUrl;

    test('returns success with parsed DashboardDto on 200', () async {
      adapter.onGet(path, (_) async => jsonResponse({
            'user': {
              'id': 7,
              'email': 'k@x.com',
              'firstName': 'Krishnan',
              'lastName': 'R',
              'role': 'CUSTOMER',
            },
            'projects': {
              'totalProjects': 1,
              'activeProjects': 1,
              'completedProjects': 0,
              'recentProjects': [
                {'id': 50, 'name': 'Villa', 'progress': 35.0},
              ],
            },
            'recentActivities': [
              {
                'type': 'PHOTO',
                'description': 'Slab poured',
                'timestamp': '2026-05-01T08:00:00',
                'projectId': 50,
                'projectName': 'Villa',
              },
            ],
            'quickStats': {
              'totalBills': 5,
              'pendingBills': 2,
              'paidBills': 3,
              'totalAmount': 1000000.0,
              'pendingAmount': 400000.0,
            },
          }));

      final res = await api.getDashboard('tkn');

      expect(res.success, isTrue);
      expect(res.data!.user.fullName, 'Krishnan R');
      expect(res.data!.projects.totalProjects, 1);
      expect(res.data!.projects.recentProjects.first.name, 'Villa');
      expect(res.data!.recentActivities, hasLength(1));
      expect(res.data!.quickStats.pendingAmount, 400000.0);
    });

    test('returns error on 500 (DioException caught)', () async {
      adapter.onGet(path,
          (_) async => jsonResponse({'message': 'boom'}, statusCode: 500));

      final res = await api.getDashboard('tkn');

      expect(res.success, isFalse);
      expect(res.error!.message, contains('boom'));
      expect(res.error!.statusCode, 500);
    });
  });

  group('getProjectDetails', () {
    final path = '$base/api/dashboard/projects/uuid-50';

    test('returns success with parsed ProjectDetails on 200', () async {
      adapter.onGet(path, (_) async => jsonResponse({
            'id': 50,
            'projectUuid': 'uuid-50',
            'name': 'Villa',
            'code': 'PRJ-50',
            'location': 'Kochi',
            'progress': 42.5,
            'projectPhase': 'CONSTRUCTION',
            'designProgress': 100.0,
          }));

      final res = await api.getProjectDetails('uuid-50', 'tkn');

      expect(res.success, isTrue);
      expect(res.data!.id, 50);
      expect(res.data!.name, 'Villa');
      expect(res.data!.progress, 42.5);
      expect(res.data!.phase, 'CONSTRUCTION');
    });

    test('returns error on 404 (DioException caught)', () async {
      adapter.onGet(path,
          (_) async => jsonResponse({'message': 'not found'}, statusCode: 404));

      final res = await api.getProjectDetails('uuid-50', 'tkn');

      expect(res.success, isFalse);
      expect(res.error!.message, contains('not found'));
      expect(res.error!.statusCode, 404);
    });
  });

  group('getProjectPhases', () {
    final path = '$base/api/dashboard/projects/uuid-50/phases';

    test('returns success with parsed phase list on 200', () async {
      adapter.onGet(path, (_) async => jsonResponse([
            {
              'id': 1,
              'phaseName': 'Foundation',
              'status': 'COMPLETED',
              'displayOrder': 1,
            },
            {
              'id': 2,
              'phaseName': 'Superstructure',
              'status': 'IN_PROGRESS',
              'displayOrder': 2,
            },
          ]));

      final res = await api.getProjectPhases('uuid-50', 'tkn');

      expect(res.success, isTrue);
      expect(res.data, hasLength(2));
      expect(res.data!.first.phaseName, 'Foundation');
      expect(res.data!.first.isCompleted, isTrue);
      expect(res.data![1].isInProgress, isTrue);
    });

    test('returns error on 500 (DioException caught)', () async {
      adapter.onGet(path,
          (_) async => jsonResponse({'message': 'boom'}, statusCode: 500));

      final res = await api.getProjectPhases('uuid-50', 'tkn');

      expect(res.success, isFalse);
      expect(res.error!.message, contains('boom'));
      expect(res.error!.statusCode, 500);
    });
  });

  group('searchProjects', () {
    final path = '$base/api/dashboard/search-projects';

    test('returns success with parsed ProjectCard list on 200', () async {
      adapter.onGet(path, (_) async => jsonResponse([
            {'id': 50, 'name': 'Villa', 'progress': 35.0},
            {'id': 51, 'name': 'Apartment', 'progress': 10.0},
          ]));

      final res = await api.searchProjects('tkn');

      expect(res.success, isTrue);
      expect(res.data, hasLength(2));
      expect(res.data!.first.name, 'Villa');
    });

    test('passes trimmed q query param when given', () async {
      String? capturedQuery;
      adapter.onGet(path, (options) async {
        capturedQuery = options.uri.query;
        return jsonResponse([]);
      });

      await api.searchProjects('tkn', '  villa  ');

      expect(capturedQuery, contains('q=villa'));
    });

    test('returns error on 500 (DioException caught)', () async {
      adapter.onGet(path,
          (_) async => jsonResponse({'message': 'boom'}, statusCode: 500));

      final res = await api.searchProjects('tkn');

      expect(res.success, isFalse);
      expect(res.error!.message, contains('boom'));
      expect(res.error!.statusCode, 500);
    });
  });

  group('testConnection', () {
    final path = ApiConfig.testUrl;

    test('returns success with stringified body on 200', () async {
      adapter.onGet(path, (_) async => jsonResponse({'status': 'ok'}));

      final res = await api.testConnection();

      expect(res.success, isTrue);
      expect(res.data, contains('ok'));
    });

    test('returns error on transport failure (no handler)', () async {
      final res = await api.testConnection();

      expect(res.success, isFalse);
      expect(res.error!.statusCode, 0);
      expect(res.error!.message, contains('Cannot connect to server'));
    });
  });

  group('getProjectTeam', () {
    final path = '$base/api/dashboard/projects/uuid-50/team';

    test('returns success with parsed TeamContact list on 200', () async {
      adapter.onGet(path, (_) async => jsonResponse([
            {
              'userId': 11,
              'name': 'Site Engineer',
              'designation': 'SE',
              'role': 'SITE_ENGINEER',
              'phone': '9999',
            },
          ]));

      final res = await api.getProjectTeam('uuid-50', 'tkn');

      expect(res.success, isTrue);
      expect(res.data, hasLength(1));
      expect(res.data!.first.name, 'Site Engineer');
      expect(res.data!.first.hasPhone, isTrue);
    });

    test('returns error on 500 (DioException caught)', () async {
      adapter.onGet(path,
          (_) async => jsonResponse({'message': 'boom'}, statusCode: 500));

      final res = await api.getProjectTeam('uuid-50', 'tkn');

      expect(res.success, isFalse);
      expect(res.error!.message, contains('boom'));
      expect(res.error!.statusCode, 500);
    });
  });

  group('getTimeline', () {
    // URL has an embedded query string -> options.path includes it, so the
    // registered handler key must match the full string Dio uses.
    final path = '$base/api/customer/projects/uuid-50/timeline'
        '?bucket=week&page=0&size=20';

    test('returns success with parsed TimelinePage on 200', () async {
      adapter.onGet(path, (_) async => jsonResponse({
            'items': [
              {
                'taskId': 1,
                'title': 'Excavation',
                'progressPercent': 50,
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

      final res = await api.getTimeline('uuid-50', 'week', 'tkn');

      expect(res.success, isTrue);
      expect(res.data!.items, hasLength(1));
      expect(res.data!.items.first.title, 'Excavation');
      expect(res.data!.projectProgressPercent, 42);
    });

    test('returns error on 500 (DioException caught)', () async {
      adapter.onGet(path,
          (_) async => jsonResponse({'message': 'boom'}, statusCode: 500));

      final res = await api.getTimeline('uuid-50', 'week', 'tkn');

      expect(res.success, isFalse);
      expect(res.error!.message, contains('boom'));
      expect(res.error!.statusCode, 500);
    });
  });

  group('getTimelineSummary', () {
    final path =
        '$base/api/customer/projects/uuid-50/timeline/summary';

    test('returns success with parsed TimelineSummary on 200', () async {
      adapter.onGet(path, (_) async => jsonResponse({
            'weekCount': 3,
            'upcomingCount': 5,
            'completedCount': 10,
            'projectProgressPercent': 55,
          }));

      final res = await api.getTimelineSummary('uuid-50', 'tkn');

      expect(res.success, isTrue);
      expect(res.data!.weekCount, 3);
      expect(res.data!.completedCount, 10);
      expect(res.data!.projectProgressPercent, 55);
    });

    test('returns error on 500 (DioException caught)', () async {
      adapter.onGet(path,
          (_) async => jsonResponse({'message': 'boom'}, statusCode: 500));

      final res = await api.getTimelineSummary('uuid-50', 'tkn');

      expect(res.success, isFalse);
      expect(res.error!.message, contains('boom'));
      expect(res.error!.statusCode, 500);
    });
  });

  group('updateDesignPackage', () {
    final path =
        '$base/api/dashboard/projects/uuid-50/design-package';

    test('returns success with parsed ProjectDetails on 200', () async {
      Map<String, dynamic>? capturedBody;
      adapter.onPut(path, (options) async {
        capturedBody = options.data as Map<String, dynamic>;
        return jsonResponse({
          'id': 50,
          'projectUuid': 'uuid-50',
          'name': 'Villa',
          'progress': 0.0,
          'designPackage': 'PREMIUM',
          'isDesignAgreementSigned': true,
        });
      });

      final res = await api.updateDesignPackage('tkn', 'uuid-50', 'PREMIUM');

      expect(res.success, isTrue);
      expect(res.data!.designPackage, 'PREMIUM');
      expect(res.data!.isDesignAgreementSigned, isTrue);
      expect(capturedBody!['designPackage'], 'PREMIUM');
      expect(capturedBody!['isDesignAgreementSigned'], true);
    });

    test('returns error on 500 (DioException caught)', () async {
      adapter.onPut(path,
          (_) async => jsonResponse({'message': 'boom'}, statusCode: 500));

      final res = await api.updateDesignPackage('tkn', 'uuid-50', 'PREMIUM');

      expect(res.success, isFalse);
      expect(res.error!.message, contains('boom'));
      expect(res.error!.statusCode, 500);
    });
  });
}
