import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wd_cust_mobile_app/config/api_config.dart';
import 'package:wd_cust_mobile_app/models/payment_models.dart';
import 'package:wd_cust_mobile_app/services/payment_service.dart';

import '../test_helpers/mock_dio_adapter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const secureStorageChannel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

  late MockDioAdapter adapter;
  late PaymentService service;

  // dotenv must be loaded before ApiConfig.baseUrl is read, else it throws
  // NotInitializedError. ApiConfig.baseUrl then resolves to its localhost
  // fallback; the service passes the FULL url to _dio.get, so handlers
  // register on that.
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
    service = PaymentService(dio: dio);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, null);
  });

  group('getCustomerPayments', () {
    final path = '$base/api/customer/payments';

    test('parses data.content into PaymentSchedule list on 200', () async {
      adapter.onGet(path, (_) async => jsonResponse({
            'data': {
              'content': [
                {
                  'id': 1,
                  'installmentNumber': 1,
                  'description': 'Advance',
                  'amount': 200000.0,
                  'status': 'PAID',
                  'paidAmount': 200000.0,
                  'dueDate': '2026-01-01',
                },
                {
                  'id': 2,
                  'installmentNumber': 2,
                  'description': 'Foundation',
                  'amount': 300000.0,
                  'status': 'PENDING',
                  'paidAmount': 0.0,
                },
              ],
            },
          }));

      final result = await service.getCustomerPayments();

      expect(result, hasLength(2));
      expect(result.first.description, 'Advance');
      expect(result.first.isPaid, isTrue);
      expect(result[1].remainingAmount, 300000.0);
    });

    test('sends page/size and optional projectId query params', () async {
      String? capturedQuery;
      adapter.onGet(path, (options) async {
        capturedQuery = options.uri.query;
        return jsonResponse({
          'data': {'content': []},
        });
      });

      await service.getCustomerPayments(projectId: 42, page: 2, size: 5);

      expect(capturedQuery, contains('projectId=42'));
      expect(capturedQuery, contains('page=2'));
      expect(capturedQuery, contains('size=5'));
    });

    test('returns empty list when data is null', () async {
      adapter.onGet(path, (_) async => jsonResponse({'data': null}));

      expect(await service.getCustomerPayments(), isEmpty);
    });

    test('returns empty list when content absent', () async {
      adapter.onGet(path, (_) async => jsonResponse({
            'data': {'totalElements': 0},
          }));

      expect(await service.getCustomerPayments(), isEmpty);
    });

    test('returns empty list on non-200 (validateStatus false)', () async {
      // Default Dio validateStatus throws on non-2xx -> caught & rethrown,
      // so a 204 (success, empty body) exercises the empty path instead.
      adapter.onGet(path, (_) async => jsonResponse({}, statusCode: 204));

      expect(await service.getCustomerPayments(), isEmpty);
    });

    test('rethrows DioException on server error', () async {
      adapter.onGet(path,
          (_) async => jsonResponse({'error': 'boom'}, statusCode: 500));

      expect(() => service.getCustomerPayments(),
          throwsA(isA<DioException>()));
    });
  });

  group('getPaymentScheduleById', () {
    final path = '$base/api/customer/payments/7';

    test('parses data into PaymentSchedule on 200', () async {
      adapter.onGet(path, (_) async => jsonResponse({
            'data': {
              'id': 7,
              'installmentNumber': 3,
              'description': 'Roofing',
              'amount': 150000.0,
              'status': 'OVERDUE',
              'paidAmount': 50000.0,
            },
          }));

      final result = await service.getPaymentScheduleById(7);

      expect(result, isNotNull);
      expect(result!.id, 7);
      expect(result.isOverdue, isTrue);
      expect(result.remainingAmount, 100000.0);
    });

    test('returns null when data is null', () async {
      adapter.onGet(path, (_) async => jsonResponse({'data': null}));

      expect(await service.getPaymentScheduleById(7), isNull);
    });

    test('rethrows DioException on 404', () async {
      adapter.onGet(path,
          (_) async => jsonResponse({'error': 'nf'}, statusCode: 404));

      expect(() => service.getPaymentScheduleById(7),
          throwsA(isA<DioException>()));
    });
  });

  group('getProjectInvoices', () {
    final path = '$base/api/customer/invoices';

    test('parses data.content into CustomerInvoice list on 200', () async {
      adapter.onGet(path, (_) async => jsonResponse({
            'data': {
              'content': [
                {
                  'id': 1,
                  'invoiceNumber': 'INV-1',
                  'invoiceDate': '2026-03-01',
                  'dueDate': '2026-03-15',
                  'subTotal': 100000.0,
                  'gstAmount': 18000.0,
                  'totalAmount': 118000.0,
                  'status': 'ISSUED',
                  'createdAt': '2026-03-01T08:00:00',
                },
              ],
            },
          }));

      final result = await service.getProjectInvoices(projectUuid: 'uuid-1');

      expect(result, hasLength(1));
      expect(result.first.invoiceNumber, 'INV-1');
      expect(result.first.isIssued, isTrue);
      expect(result.first.totalAmount, 118000.0);
    });

    test('sends projectId/page/size query params', () async {
      String? capturedQuery;
      adapter.onGet(path, (options) async {
        capturedQuery = options.uri.query;
        return jsonResponse({
          'data': {'content': []},
        });
      });

      await service.getProjectInvoices(
          projectUuid: 'uuid-9', page: 1, size: 3);

      expect(capturedQuery, contains('projectId=uuid-9'));
      expect(capturedQuery, contains('page=1'));
      expect(capturedQuery, contains('size=3'));
    });

    test('returns empty list when content absent', () async {
      adapter.onGet(path, (_) async => jsonResponse({
            'data': {'totalElements': 0},
          }));

      expect(
          await service.getProjectInvoices(projectUuid: 'uuid-1'), isEmpty);
    });

    test('rethrows DioException on server error', () async {
      adapter.onGet(path,
          (_) async => jsonResponse({'error': 'boom'}, statusCode: 500));

      expect(() => service.getProjectInvoices(projectUuid: 'uuid-1'),
          throwsA(isA<DioException>()));
    });
  });

  group('calculateSummary', () {
    test('sums totals and computes due amount', () {
      final schedules = [
        PaymentSchedule(
          id: 1,
          installmentNumber: 1,
          description: 'A',
          amount: 100000.0,
          status: 'PAID',
          paidAmount: 100000.0,
        ),
        PaymentSchedule(
          id: 2,
          installmentNumber: 2,
          description: 'B',
          amount: 200000.0,
          status: 'PENDING',
          paidAmount: 50000.0,
        ),
      ];

      final summary = service.calculateSummary(schedules);

      expect(summary.totalAmount, 300000.0);
      expect(summary.paidAmount, 150000.0);
      expect(summary.dueAmount, 150000.0);
      expect(summary.progress, closeTo(0.5, 1e-9));
    });

    test('progress is 0 for empty list', () {
      final summary = service.calculateSummary([]);

      expect(summary.totalAmount, 0.0);
      expect(summary.progress, 0.0);
    });
  });
}
