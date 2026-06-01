import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wd_cust_mobile_app/config/api_config.dart';
import 'package:wd_cust_mobile_app/exceptions/api_exception.dart';
import 'package:wd_cust_mobile_app/models/site_report_models.dart';
import 'package:wd_cust_mobile_app/services/site_report_service.dart';

import '../test_helpers/mock_dio_adapter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const secureStorageChannel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

  late MockDioAdapter adapter;
  late SiteReportService service;

  // Load dotenv before reading ApiConfig.baseUrl (else NotInitializedError).
  dotenv.loadFromString(isOptional: true);
  final base = ApiConfig.baseUrl;

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (call) async {
      if (call.method == 'read') return 'test-token';
      if (call.method == 'readAll') return <String, String>{};
      return null;
    });

    adapter = MockDioAdapter();
    final dio = Dio();
    dio.httpClientAdapter = adapter;
    service = SiteReportService(dio: dio);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, null);
  });

  group('getReportSummary', () {
    final path = '$base/api/customer/site-reports/summary';

    test('parses data list into SiteReportSummaryRow on 200', () async {
      adapter.onGet(path, (_) async => jsonResponse({
            'data': [
              {'projectId': 1, 'projectName': 'Demo A', 'count': 3},
              {'projectId': 2, 'projectName': 'Demo B', 'count': 0},
            ],
          }));

      final result = await service.getReportSummary();

      expect(result, hasLength(2));
      expect(result.first.projectName, 'Demo A');
      expect(result.first.count, 3);
      expect(result[1].projectId, 2);
    });

    test('returns empty list when data is not a List', () async {
      adapter.onGet(path, (_) async => jsonResponse({'data': null}));

      expect(await service.getReportSummary(), isEmpty);
    });

    test('throws ApiException on non-200', () async {
      adapter.onGet(path,
          (_) async => jsonResponse({'message': 'forbidden'}, statusCode: 403));

      expect(() => service.getReportSummary(),
          throwsA(isA<ApiException>()));
    });

    test('throws ApiException when no handler (StateError caught)', () async {
      // No handler registered -> adapter throws StateError -> generic catch
      // wraps into ApiException(UNKNOWN_ERROR).
      expect(() => service.getReportSummary(),
          throwsA(isA<ApiException>()));
    });
  });

  group('getCustomerSiteReports', () {
    final path = '$base/api/customer/site-reports';

    test('parses Spring Page (data.content) into SiteReport list', () async {
      adapter.onGet(path, (_) async => jsonResponse({
            'data': {
              'content': [
                {
                  'id': 1,
                  'projectId': 5,
                  'title': 'Day 1',
                  'reportDate': '2026-04-01',
                  'status': 'SUBMITTED',
                  'reportType': 'DAILY_PROGRESS',
                },
              ],
            },
          }));

      final result = await service.getCustomerSiteReports();

      expect(result, hasLength(1));
      expect(result.first.title, 'Day 1');
      expect(result.first.reportType, ReportType.dailyProgress);
    });

    test('parses data when it is already a List', () async {
      adapter.onGet(path, (_) async => jsonResponse({
            'data': [
              {
                'id': 2,
                'projectId': 5,
                'title': 'QC',
                'reportDate': '2026-04-02',
                'status': 'SUBMITTED',
                'reportType': 'QUALITY_CHECK',
              },
            ],
          }));

      final result = await service.getCustomerSiteReports();

      expect(result, hasLength(1));
      expect(result.first.reportType, ReportType.qualityCheck);
    });

    test('returns empty list when content is null', () async {
      adapter.onGet(path, (_) async => jsonResponse({
            'data': {'content': null},
          }));

      expect(await service.getCustomerSiteReports(), isEmpty);
    });

    test('sends page/size and optional projectId query params', () async {
      String? capturedQuery;
      adapter.onGet(path, (options) async {
        capturedQuery = options.uri.query;
        return jsonResponse({
          'data': {'content': []},
        });
      });

      await service.getCustomerSiteReports(projectId: 9, page: 1, size: 5);

      expect(capturedQuery, contains('projectId=9'));
      expect(capturedQuery, contains('page=1'));
      expect(capturedQuery, contains('size=5'));
    });

    test('throws ApiException on non-200', () async {
      adapter.onGet(path,
          (_) async => jsonResponse({'message': 'boom'}, statusCode: 500));

      expect(() => service.getCustomerSiteReports(),
          throwsA(isA<ApiException>()));
    });
  });

  group('getSiteReportById', () {
    final path = '$base/api/customer/site-reports/15';

    test('parses data into SiteReport on 200', () async {
      adapter.onGet(path, (_) async => jsonResponse({
            'data': {
              'id': 15,
              'projectId': 5,
              'title': 'Report 15',
              'reportDate': '2026-04-10',
              'status': 'SUBMITTED',
              'reportType': 'SAFETY_INCIDENT',
              'submittedByName': 'Eng A',
            },
          }));

      final result = await service.getSiteReportById(15);

      expect(result, isNotNull);
      expect(result!.id, 15);
      expect(result.title, 'Report 15');
      expect(result.reportType, ReportType.safetyIncident);
      expect(result.submittedByName, 'Eng A');
    });

    test('returns null when data is null', () async {
      adapter.onGet(path, (_) async => jsonResponse({'data': null}));

      expect(await service.getSiteReportById(15), isNull);
    });

    test('throws ApiException on 404', () async {
      adapter.onGet(path,
          (_) async => jsonResponse({'message': 'nf'}, statusCode: 404));

      expect(() => service.getSiteReportById(15),
          throwsA(isA<ApiException>()));
    });
  });
}
