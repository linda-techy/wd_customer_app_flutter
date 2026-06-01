import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wd_cust_mobile_app/services/boq_diff_service.dart';

import '../test_helpers/mock_dio_adapter.dart';

void main() {
  late MockDioAdapter adapter;

  setUp(() {
    adapter = MockDioAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://test.example'));
    dio.httpClientAdapter = adapter;
    BoqDiffService.testDio = dio;
  });

  tearDown(() {
    BoqDiffService.testDio = null;
  });

  group('BoqDiffService.getRevisions', () {
    test('parses real-shaped revisions list, oldest first', () async {
      adapter.onGet('/api/projects/p1/boq/revisions', (_) async => jsonResponse({
            'success': true,
            'revisions': [
              {
                'id': 10,
                'revisionNumber': 1,
                'status': 'APPROVED',
                'createdAt': '2026-01-01T10:00:00Z',
                'totalValueExGst': 1000000.0,
                'totalValueInclGst': 1180000.0,
              },
              {
                'id': 11,
                'revisionNumber': 2,
                'status': 'DRAFT',
                'createdAt': '2026-02-01T10:00:00Z',
                'totalValueExGst': 1200000.0,
                'totalValueInclGst': 1416000.0,
              },
            ],
          }));

      final revs = await BoqDiffService.getRevisions('p1');

      expect(revs, hasLength(2));
      expect(revs.first.id, 10);
      expect(revs.first.revisionNumber, 1);
      expect(revs.first.status, 'APPROVED');
      expect(revs[1].id, 11);
      expect(revs[1].totalValueInclGst, 1416000.0);
    });

    test('returns empty list when revisions key missing', () async {
      adapter.onGet('/api/projects/p1/boq/revisions',
          (_) async => jsonResponse({'success': true}));

      final revs = await BoqDiffService.getRevisions('p1');

      expect(revs, isEmpty);
    });

    test('throws when API returns success:false (with message)', () async {
      adapter.onGet('/api/projects/p1/boq/revisions',
          (_) async => jsonResponse({
                'success': false,
                'message': 'Not allowed',
              }));

      expect(
        () => BoqDiffService.getRevisions('p1'),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Not allowed'),
        )),
      );
    });

    test('throws fallback message when success:false and no message', () async {
      adapter.onGet('/api/projects/p1/boq/revisions',
          (_) async => jsonResponse({'success': false}));

      expect(
        () => BoqDiffService.getRevisions('p1'),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Failed to load BOQ revisions'),
        )),
      );
    });
  });

  group('BoqDiffService.getDiff', () {
    test('sends fromDoc/toDoc query params', () async {
      String? capturedQuery;
      adapter.onGet('/api/projects/p1/boq/diff', (options) async {
        capturedQuery = options.uri.query;
        return jsonResponse({
          'success': true,
          'data': _diffData(),
        });
      });

      await BoqDiffService.getDiff('p1', 10, 11);

      expect(capturedQuery, contains('fromDoc=10'));
      expect(capturedQuery, contains('toDoc=11'));
    });

    test('parses a real-shaped diff result', () async {
      adapter.onGet('/api/projects/p1/boq/diff', (_) async => jsonResponse({
            'success': true,
            'data': _diffData(),
          }));

      final diff = await BoqDiffService.getDiff('p1', 10, 11);

      expect(diff.added, hasLength(1));
      expect(diff.added.first.description, 'New steel item');
      expect(diff.removed, hasLength(1));
      expect(diff.modified, hasLength(1));
      expect(diff.modified.first.itemCode, 'C-200');
      expect(diff.modified.first.changes['rate']!.oldValue, 100);
      expect(diff.modified.first.changes['rate']!.newValue, 120);
      expect(diff.summary.addedCount, 1);
      expect(diff.summary.delta, 50000.0);
      expect(diff.isEmpty, isFalse);
    });

    test('throws when API returns success:false', () async {
      adapter.onGet('/api/projects/p1/boq/diff', (_) async => jsonResponse({
            'success': false,
            'message': 'Bad docs',
          }));

      expect(
        () => BoqDiffService.getDiff('p1', 10, 11),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Bad docs'),
        )),
      );
    });
  });
}

Map<String, dynamic> _diffData() => {
      'added': [
        {
          'itemCode': 'A-100',
          'description': 'New steel item',
          'quantity': 5.0,
          'unit': 'kg',
          'rate': 60.0,
          'amount': 300.0,
        },
      ],
      'removed': [
        {
          'itemCode': 'R-300',
          'description': 'Removed brick item',
          'quantity': 2.0,
          'unit': 'nos',
          'rate': 10.0,
          'amount': 20.0,
        },
      ],
      'modified': [
        {
          'itemCode': 'C-200',
          'description': 'Cement',
          'changes': {
            'rate': {'oldValue': 100, 'newValue': 120},
          },
        },
      ],
      'summary': {
        'oldTotal': 1000000.0,
        'newTotal': 1050000.0,
        'delta': 50000.0,
        'addedCount': 1,
        'removedCount': 1,
        'modifiedCount': 1,
        'fromRevision': 1,
        'toRevision': 2,
      },
    };
