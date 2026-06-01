import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wd_cust_mobile_app/services/gantt_service.dart';

import '../test_helpers/mock_dio_adapter.dart';

void main() {
  late MockDioAdapter adapter;
  late GanttService service;

  setUp(() {
    adapter = MockDioAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://test.example'));
    dio.httpClientAdapter = adapter;
    service = GanttService(baseUrl: 'https://test.example', token: 't', dio: dio);
  });

  group('GanttService.fetchGanttData (instance)', () {
    test('unwraps a standard {success,data,message} envelope', () async {
      adapter.onGet('/api/projects/p1/schedule/gantt',
          (_) async => jsonResponse({
                'success': true,
                'message': 'ok',
                'data': {
                  'tasks': [
                    {'id': 1, 'name': 'Foundation'},
                  ],
                  'projectStartDate': '2026-01-01',
                  'projectEndDate': '2026-12-31',
                  'overallProgress': 42.5,
                  'overdueTasks': 2,
                },
              }));

      final data = await service.fetchGanttData('p1');

      expect(data, isNotNull);
      expect(data!['overallProgress'], 42.5);
      expect(data['overdueTasks'], 2);
      expect((data['tasks'] as List), hasLength(1));
    });

    test('returns the body itself when no data envelope key', () async {
      adapter.onGet('/api/projects/p1/schedule/gantt',
          (_) async => jsonResponse({
                'tasks': [],
                'overallProgress': 0.0,
                'overdueTasks': 0,
              }));

      final data = await service.fetchGanttData('p1');

      expect(data, isNotNull);
      expect(data!['overallProgress'], 0.0);
      expect(data.containsKey('tasks'), isTrue);
    });

    test('returns null on non-200 response', () async {
      adapter.onGet('/api/projects/p1/schedule/gantt',
          (_) async => jsonResponse({'error': 'forbidden'}, statusCode: 403));

      final data = await service.fetchGanttData('p1');

      expect(data, isNull);
    });

    test('returns null when adapter throws (DioException path)', () async {
      // No handler registered -> MockDioAdapter throws -> Dio wraps as
      // DioException -> service catches and returns null.
      final data = await service.fetchGanttData('unknown');

      expect(data, isNull);
    });

    test('returns null when 200 body is not a Map', () async {
      adapter.onGet('/api/projects/p1/schedule/gantt',
          (_) async => jsonResponse(['not', 'a', 'map']));

      final data = await service.fetchGanttData('p1');

      expect(data, isNull);
    });
  });
}
