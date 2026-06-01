import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wd_cust_mobile_app/services/customer_boq_service.dart';

import '../test_helpers/mock_dio_adapter.dart';

void main() {
  late MockDioAdapter adapter;
  late CustomerBoqService service;

  setUp(() {
    adapter = MockDioAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://test.example'));
    dio.httpClientAdapter = adapter;
    service = CustomerBoqService(
        baseUrl: 'https://test.example', token: 'tkn', dio: dio);
  });

  group('getPaymentSchedule', () {
    const uuid = 'proj-1';
    const path = '/api/projects/$uuid/boq/payment-schedule';

    test('parses stages + summary on 200', () async {
      adapter.onGet(path, (_) async => jsonResponse({
            'stages': [
              {
                'id': 1,
                'stageNumber': 1,
                'stageName': 'Foundation',
                'stagePercentage': 10.0,
                'stageAmountExGst': 100000.0,
                'gstAmount': 18000.0,
                'stageAmountInclGst': 118000.0,
                'appliedCreditAmount': 0.0,
                'netPayableAmount': 118000.0,
                'paidAmount': 118000.0,
                'status': 'PAID',
                'dueDate': '2026-01-15',
                'milestoneDescription': 'Footing done',
                'paidAt': '2026-01-20T10:00:00',
              },
              {
                'id': 2,
                'stageNumber': 2,
                'stageName': 'Plastering',
                'stagePercentage': 12.0,
                'netPayableAmount': 141600.0,
                'status': 'UPCOMING',
              },
            ],
            'summary': {
              'totalContractValue': 3500000.0,
              'totalPaid': 118000.0,
              'totalOutstanding': 3382000.0,
              'stageCount': 7,
            },
          }));

      final result = await service.getPaymentSchedule(uuid);

      expect(result.stages, hasLength(2));
      expect(result.stages.first.stageName, 'Foundation');
      expect(result.stages.first.status, 'PAID');
      expect(result.stages.first.dueDate, DateTime(2026, 1, 15));
      expect(result.stages[1].status, 'UPCOMING');
      // missing numeric fields default to 0.0 via _d
      expect(result.stages[1].gstAmount, 0.0);
      expect(result.totalContractValue, 3500000.0);
      expect(result.totalPaid, 118000.0);
      expect(result.totalOutstanding, 3382000.0);
      expect(result.stageCount, 7);
    });

    test('falls back stageCount to stages.length when absent', () async {
      adapter.onGet(path, (_) async => jsonResponse({
            'stages': [
              {'id': 1, 'stageNumber': 1, 'stageName': 'A', 'status': 'PAID'},
            ],
            'summary': {
              'totalContractValue': 1000.0,
              'totalPaid': 0.0,
              'totalOutstanding': 1000.0,
            },
          }));

      final result = await service.getPaymentSchedule(uuid);

      expect(result.stageCount, 1);
    });

    test('throws when body has success:false (_check)', () async {
      adapter.onGet(path, (_) async => jsonResponse({
            'success': false,
            'message': 'No BOQ found',
          }));

      expect(() => service.getPaymentSchedule(uuid), throwsA(isA<Exception>()));
    });

    test('throws DioException on non-200', () async {
      adapter.onGet(path,
          (_) async => jsonResponse({'error': 'forbidden'}, statusCode: 403));

      expect(() => service.getPaymentSchedule(uuid),
          throwsA(isA<DioException>()));
    });
  });

  group('getChangeOrders', () {
    const uuid = 'proj-2';
    const path = '/api/projects/$uuid/boq/change-orders';

    test('parses changeOrders on 200', () async {
      adapter.onGet(path, (_) async => jsonResponse({
            'changeOrders': [
              {
                'id': 10,
                'referenceNumber': 'CO-001',
                'coType': 'ADDITION',
                'status': 'CUSTOMER_REVIEW',
                'title': 'Extra room',
                'netAmountExGst': 50000.0,
                'gstAmount': 9000.0,
                'netAmountInclGst': 59000.0,
                'submittedAt': '2026-02-01T09:00:00',
              },
            ],
          }));

      final result = await service.getChangeOrders(uuid);

      expect(result, hasLength(1));
      expect(result.first.referenceNumber, 'CO-001');
      expect(result.first.isPendingReview, isTrue);
      expect(result.first.netAmountInclGst, 59000.0);
    });

    test('returns empty list when changeOrders key absent', () async {
      adapter.onGet(path, (_) async => jsonResponse({}));

      final result = await service.getChangeOrders(uuid);

      expect(result, isEmpty);
    });

    test('throws when success:false', () async {
      adapter.onGet(path, (_) async =>
          jsonResponse({'success': false, 'message': 'nope'}));

      expect(() => service.getChangeOrders(uuid), throwsA(isA<Exception>()));
    });

    test('throws DioException on non-200', () async {
      adapter.onGet(path,
          (_) async => jsonResponse({'error': 'oops'}, statusCode: 500));

      expect(
          () => service.getChangeOrders(uuid), throwsA(isA<DioException>()));
    });
  });

  group('getPendingReview', () {
    const uuid = 'proj-3';
    const path = '/api/projects/$uuid/boq/change-orders/pending-review';

    test('parses changeOrders on 200', () async {
      adapter.onGet(path, (_) async => jsonResponse({
            'changeOrders': [
              {
                'id': 11,
                'referenceNumber': 'CO-002',
                'coType': 'REDUCTION',
                'status': 'CUSTOMER_REVIEW',
                'title': 'Remove balcony',
                'netAmountExGst': -20000.0,
                'gstAmount': -3600.0,
                'netAmountInclGst': -23600.0,
              },
            ],
          }));

      final result = await service.getPendingReview(uuid);

      expect(result, hasLength(1));
      expect(result.first.isReduction, isTrue);
    });

    test('returns empty list when key absent', () async {
      adapter.onGet(path, (_) async => jsonResponse({}));

      final result = await service.getPendingReview(uuid);

      expect(result, isEmpty);
    });

    test('throws DioException on non-200', () async {
      adapter.onGet(path,
          (_) async => jsonResponse({'error': 'oops'}, statusCode: 403));

      expect(
          () => service.getPendingReview(uuid), throwsA(isA<DioException>()));
    });
  });

  group('approve', () {
    const uuid = 'proj-4';
    const coId = 22;
    const path = '/api/projects/$uuid/boq/change-orders/$coId/approve';

    test('returns parsed change order on 200', () async {
      adapter.onPatch(path, (_) async => jsonResponse({
            'changeOrder': {
              'id': coId,
              'referenceNumber': 'CO-022',
              'coType': 'ADDITION',
              'status': 'APPROVED',
              'title': 'Approved CO',
              'netAmountExGst': 1000.0,
              'gstAmount': 180.0,
              'netAmountInclGst': 1180.0,
              'approvedAt': '2026-03-01T12:00:00',
            },
          }));

      final result = await service.approve(uuid, coId);

      expect(result.id, coId);
      expect(result.status, 'APPROVED');
      expect(result.approvedAt, DateTime(2026, 3, 1, 12));
    });

    test('throws when success:false', () async {
      adapter.onPatch(path, (_) async =>
          jsonResponse({'success': false, 'message': 'cannot approve'}));

      expect(
          () => service.approve(uuid, coId), throwsA(isA<Exception>()));
    });

    test('throws DioException on non-200', () async {
      adapter.onPatch(path,
          (_) async => jsonResponse({'error': 'conflict'}, statusCode: 409));

      expect(
          () => service.approve(uuid, coId), throwsA(isA<DioException>()));
    });
  });

  group('reject', () {
    const uuid = 'proj-5';
    const coId = 33;
    const path = '/api/projects/$uuid/boq/change-orders/$coId/reject';

    test('sends reason and returns parsed change order on 200', () async {
      Object? capturedBody;
      adapter.onPatch(path, (options) async {
        capturedBody = options.data;
        return jsonResponse({
          'changeOrder': {
            'id': coId,
            'referenceNumber': 'CO-033',
            'coType': 'ADDITION',
            'status': 'REJECTED',
            'title': 'Rejected CO',
            'netAmountExGst': 0.0,
            'gstAmount': 0.0,
            'netAmountInclGst': 0.0,
            'rejectionReason': 'Too costly',
          },
        });
      });

      final result = await service.reject(uuid, coId, 'Too costly');

      expect(result.status, 'REJECTED');
      expect(result.rejectionReason, 'Too costly');
      expect(capturedBody, {'reason': 'Too costly'});
    });

    test('throws DioException on non-200', () async {
      adapter.onPatch(path,
          (_) async => jsonResponse({'error': 'bad'}, statusCode: 400));

      expect(() => service.reject(uuid, coId, 'x'),
          throwsA(isA<DioException>()));
    });
  });

  group('getFinancialStages', () {
    const uuid = 'proj-6';
    const path = '/api/projects/$uuid/financial/stages';

    test('returns map on 200', () async {
      adapter.onGet(path,
          (_) async => jsonResponse({'stages': [], 'currency': 'INR'}));

      final result = await service.getFinancialStages(uuid);

      expect(result, isNotNull);
      expect(result!['currency'], 'INR');
    });

    test('returns null on 404', () async {
      adapter.onGet(path,
          (_) async => jsonResponse({'error': 'not found'}, statusCode: 404));

      final result = await service.getFinancialStages(uuid);

      expect(result, isNull);
    });

    test('rethrows non-404 DioException', () async {
      adapter.onGet(path,
          (_) async => jsonResponse({'error': 'boom'}, statusCode: 500));

      expect(() => service.getFinancialStages(uuid),
          throwsA(isA<DioException>()));
    });
  });

  group('getFinancialVOs', () {
    const uuid = 'proj-7';
    const path = '/api/projects/$uuid/financial/variation-orders';

    test('returns map on 200', () async {
      adapter.onGet(path, (_) async => jsonResponse({'variationOrders': []}));

      final result = await service.getFinancialVOs(uuid);

      expect(result, isNotNull);
      expect(result!.containsKey('variationOrders'), isTrue);
    });

    test('returns null on 404', () async {
      adapter.onGet(path,
          (_) async => jsonResponse({'error': 'nf'}, statusCode: 404));

      expect(await service.getFinancialVOs(uuid), isNull);
    });
  });

  group('getFinancialDeductions', () {
    const uuid = 'proj-8';
    const path = '/api/projects/$uuid/financial/deductions';

    test('returns map on 200', () async {
      adapter.onGet(path, (_) async => jsonResponse({'deductions': []}));

      final result = await service.getFinancialDeductions(uuid);

      expect(result, isNotNull);
    });

    test('returns null on 404', () async {
      adapter.onGet(path,
          (_) async => jsonResponse({'error': 'nf'}, statusCode: 404));

      expect(await service.getFinancialDeductions(uuid), isNull);
    });
  });

  group('getFinancialFinalAccount', () {
    const uuid = 'proj-9';
    const path = '/api/projects/$uuid/financial/final-account';

    test('returns map on 200', () async {
      adapter.onGet(path,
          (_) async => jsonResponse({'finalAccount': {'total': 100}}));

      final result = await service.getFinancialFinalAccount(uuid);

      expect(result, isNotNull);
      expect(result!.containsKey('finalAccount'), isTrue);
    });

    test('returns null on 404', () async {
      adapter.onGet(path,
          (_) async => jsonResponse({'error': 'nf'}, statusCode: 404));

      expect(await service.getFinancialFinalAccount(uuid), isNull);
    });
  });

  group('getBoqInvoices', () {
    const uuid = 'proj-10';
    const path = '/api/projects/$uuid/financial/boq-invoices';

    test('parses invoices on 200', () async {
      adapter.onGet(path, (_) async => jsonResponse({
            'invoices': [
              {
                'id': 100,
                'invoiceNumber': 'INV-100',
                'invoiceType': 'STAGE',
                'subtotalExGst': 100000.0,
                'gstRate': 18.0,
                'gstAmount': 18000.0,
                'totalInclGst': 118000.0,
                'totalCreditApplied': 0.0,
                'netAmountDue': 118000.0,
                'status': 'ISSUED',
                'issueDate': '2026-04-01',
              },
            ],
          }));

      final result = await service.getBoqInvoices(uuid);

      expect(result, hasLength(1));
      expect(result.first.invoiceNumber, 'INV-100');
      expect(result.first.netAmountDue, 118000.0);
      expect(result.first.status, 'ISSUED');
    });

    test('returns empty list when invoices key absent', () async {
      adapter.onGet(path, (_) async => jsonResponse({}));

      expect(await service.getBoqInvoices(uuid), isEmpty);
    });

    test('throws when success:false', () async {
      adapter.onGet(path, (_) async =>
          jsonResponse({'success': false, 'message': 'nope'}));

      expect(() => service.getBoqInvoices(uuid), throwsA(isA<Exception>()));
    });
  });
}
