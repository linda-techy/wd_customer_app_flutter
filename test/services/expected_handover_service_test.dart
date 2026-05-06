import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wd_cust_mobile_app/services/expected_handover_service.dart';

import '../test_helpers/mock_dio_adapter.dart';

void main() {
  late MockDioAdapter adapter;

  setUp(() {
    adapter = MockDioAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://test.example'));
    dio.httpClientAdapter = adapter;
    ExpectedHandoverService.testDio = dio;
  });

  tearDown(() {
    ExpectedHandoverService.testDio = null;
  });

  group('ExpectedHandoverService.fetch', () {
    test('returns model on 200 success', () async {
      adapter.onGet(
        '/api/customer/projects/abc/expected-handover',
        (_) async => jsonResponse({
          'projectFinishDate': '2026-08-12',
          'baselineFinishDate': '2026-08-05',
          'weeksRemaining': 14,
          'hasMaterialDelay': true,
        }),
      );

      final h = await ExpectedHandoverService.fetch('abc');

      expect(h, isNotNull);
      expect(h!.projectFinishDate, DateTime(2026, 8, 12));
      expect(h.baselineFinishDate, DateTime(2026, 8, 5));
      expect(h.weeksRemaining, 14);
      expect(h.hasMaterialDelay, true);
    });

    test('handles all-null fields in 200 response', () async {
      adapter.onGet(
        '/api/customer/projects/abc/expected-handover',
        (_) async => jsonResponse({
          'projectFinishDate': null,
          'baselineFinishDate': null,
          'weeksRemaining': null,
          'hasMaterialDelay': false,
        }),
      );

      final h = await ExpectedHandoverService.fetch('abc');

      expect(h, isNotNull);
      expect(h!.projectFinishDate, isNull);
      expect(h.baselineFinishDate, isNull);
      expect(h.weeksRemaining, isNull);
      expect(h.hasMaterialDelay, false);
    });

    test('returns null on non-200 response', () async {
      adapter.onGet(
        '/api/customer/projects/abc/expected-handover',
        (_) async => jsonResponse({'error': 'Forbidden'}, statusCode: 403),
      );

      final h = await ExpectedHandoverService.fetch('abc');

      expect(h, isNull);
    });

    test('returns null when adapter throws (network error)', () async {
      // No handler registered for this path — adapter throws StateError
      // which the service must catch and translate to null.
      final h = await ExpectedHandoverService.fetch('unknown-uuid');

      expect(h, isNull);
    });
  });
}
