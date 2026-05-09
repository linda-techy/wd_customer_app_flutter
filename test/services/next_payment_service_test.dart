import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wd_cust_mobile_app/services/next_payment_service.dart';

import '../test_helpers/mock_dio_adapter.dart';

void main() {
  late MockDioAdapter adapter;

  setUp(() {
    adapter = MockDioAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://test.example'));
    dio.httpClientAdapter = adapter;
    NextPaymentService.testDio = dio;
  });

  tearDown(() {
    NextPaymentService.testDio = null;
  });

  group('NextPaymentService.fetch', () {
    test('sends ?nextOnly=true query param', () async {
      String? capturedQuery;
      adapter.onGet('/api/projects/abc/boq/payment-schedule', (options) async {
        capturedQuery = options.uri.query;
        return jsonResponse({
          'stage': null,
          'summary': {
            'totalContractValue': 0,
            'totalPaid': 0,
            'totalOutstanding': 0,
            'stageCount': 0,
          },
        });
      });

      await NextPaymentService.fetch('abc');

      expect(capturedQuery, contains('nextOnly=true'));
    });

    test('returns model on 200', () async {
      adapter.onGet('/api/projects/abc/boq/payment-schedule', (_) async => jsonResponse({
        'stage': {
          'stageNumber': 4,
          'stageName': 'Plastering',
          'dueDate': '2026-05-15',
          'daysUntilDue': 5,
          'status': 'DUE',
          'netPayableAmount': 425000.00,
          'stagePercentage': 12.0,
          'percentOfContract': 12.0,
          'totalStages': 7,
        },
        'summary': {
          'totalContractValue': 3500000.00,
          'totalPaid': 1400000.00,
          'totalOutstanding': 2100000.00,
          'stageCount': 7,
        },
      }));

      final m = await NextPaymentService.fetch('abc');

      expect(m, isNotNull);
      expect(m!.stage, isNotNull);
      expect(m.stage!.stageNumber, 4);
      expect(m.stage!.daysUntilDue, 5);
    });

    test('returns null on non-200', () async {
      adapter.onGet('/api/projects/abc/boq/payment-schedule',
          (_) async => jsonResponse({'error': 'forbidden'}, statusCode: 403));

      final m = await NextPaymentService.fetch('abc');

      expect(m, isNull);
    });

    test('returns null when adapter throws (network error)', () async {
      // No handler registered → MockDioAdapter throws StateError → service catches.
      final m = await NextPaymentService.fetch('unknown-uuid');

      expect(m, isNull);
    });
  });
}
