import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wd_cust_mobile_app/config/api_config.dart';
import 'package:wd_cust_mobile_app/models/support_models.dart';
import 'package:wd_cust_mobile_app/services/support_service.dart';

import '../test_helpers/mock_dio_adapter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockDioAdapter adapter;

  // SupportService builds auth headers via AuthService.getAccessToken(), which
  // reads from flutter_secure_storage. Provide a mock channel returning a token
  // so the request actually fires (otherwise the platform channel throws and
  // every method short-circuits to its catch-block fallback).
  const secureStorageChannel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

  setUp(() {
    adapter = MockDioAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://test.example'))
      ..httpClientAdapter = adapter;
    SupportService.testDio = dio;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (call) async {
      if (call.method == 'read') return 'fake-token';
      return null;
    });
  });

  tearDown(() {
    SupportService.testDio = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, null);
  });

  group('SupportService.createTicket', () {
    test('posts body and parses the created SupportTicket', () async {
      Map<String, dynamic>? capturedBody;
      adapter.onPost(ApiConfig.supportTicketsEndpoint, (options) async {
        capturedBody = options.data as Map<String, dynamic>;
        return jsonResponse({
          'id': 99,
          'ticketNumber': 'TKT-0099',
          'subject': 'Leaky roof',
          'description': 'Water dripping',
          'category': 'COMPLAINT',
          'priority': 'HIGH',
          'status': 'OPEN',
          'projectId': 50,
          'createdAt': '2026-05-30T10:00:00Z',
          'updatedAt': '2026-05-30T10:00:00Z',
        });
      });

      final ticket = await SupportService.createTicket(
        subject: 'Leaky roof',
        description: 'Water dripping',
        category: 'COMPLAINT',
        priority: 'HIGH',
        projectId: 50,
      );

      expect(ticket, isNotNull);
      expect(ticket!.id, '99');
      expect(ticket.ticketNumber, 'TKT-0099');
      expect(ticket.status, 'OPEN');
      expect(ticket.projectId, 50);
      expect(capturedBody!['subject'], 'Leaky roof');
      expect(capturedBody!['category'], 'COMPLAINT');
      expect(capturedBody!['priority'], 'HIGH');
      expect(capturedBody!['projectId'], 50);
    });

    test('omits projectId from body when null', () async {
      Map<String, dynamic>? capturedBody;
      adapter.onPost(ApiConfig.supportTicketsEndpoint, (options) async {
        capturedBody = options.data as Map<String, dynamic>;
        return jsonResponse({
          'id': 1,
          'ticketNumber': 'TKT-0001',
          'subject': 'Q',
          'description': 'D',
          'category': 'GENERAL',
          'priority': 'MEDIUM',
          'status': 'OPEN',
          'createdAt': '',
          'updatedAt': '',
        });
      });

      await SupportService.createTicket(subject: 'Q', description: 'D');

      expect(capturedBody!.containsKey('projectId'), isFalse);
      expect(capturedBody!['category'], 'GENERAL');
      expect(capturedBody!['priority'], 'MEDIUM');
    });

    test('returns null on DioException', () async {
      adapter.onPost(ApiConfig.supportTicketsEndpoint,
          (_) async => jsonResponse({'error': 'boom'}, statusCode: 500));

      final ticket = await SupportService.createTicket(
        subject: 'X',
        description: 'Y',
      );

      expect(ticket, isNull);
    });
  });

  group('SupportService.getMyTickets', () {
    test('parses paged content into SupportTicket list', () async {
      adapter.onGet(ApiConfig.supportTicketsEndpoint, (_) async => jsonResponse({
            'content': [
              {
                'id': 1,
                'ticketNumber': 'TKT-0001',
                'subject': 'A',
                'description': 'DA',
                'category': 'GENERAL',
                'priority': 'LOW',
                'status': 'OPEN',
                'createdAt': '',
                'updatedAt': '',
              },
              {
                'id': 2,
                'ticketNumber': 'TKT-0002',
                'subject': 'B',
                'description': 'DB',
                'category': 'GENERAL',
                'priority': 'HIGH',
                'status': 'CLOSED',
                'createdAt': '',
                'updatedAt': '',
              },
            ],
            'totalElements': 12,
            'totalPages': 2,
          }));

      final result = await SupportService.getMyTickets();

      final content = result['content'] as List<SupportTicket>;
      expect(content, hasLength(2));
      expect(content[0].ticketNumber, 'TKT-0001');
      expect(content[1].status, 'CLOSED');
      expect(result['totalElements'], 12);
      expect(result['totalPages'], 2);
    });

    test('passes page, size and status query params', () async {
      String? capturedQuery;
      adapter.onGet(ApiConfig.supportTicketsEndpoint, (options) async {
        capturedQuery = options.uri.query;
        return jsonResponse(
            {'content': [], 'totalElements': 0, 'totalPages': 0});
      });

      await SupportService.getMyTickets(page: 3, size: 25, status: 'OPEN');

      expect(capturedQuery, contains('page=3'));
      expect(capturedQuery, contains('size=25'));
      expect(capturedQuery, contains('status=OPEN'));
    });

    test('omits status param when empty', () async {
      String? capturedQuery;
      adapter.onGet(ApiConfig.supportTicketsEndpoint, (options) async {
        capturedQuery = options.uri.query;
        return jsonResponse(
            {'content': [], 'totalElements': 0, 'totalPages': 0});
      });

      await SupportService.getMyTickets(status: '');

      expect(capturedQuery, isNot(contains('status')));
    });

    test('returns empty/zero map on DioException', () async {
      adapter.onGet(ApiConfig.supportTicketsEndpoint,
          (_) async => jsonResponse({'error': 'boom'}, statusCode: 500));

      final result = await SupportService.getMyTickets();

      expect(result['content'], isEmpty);
      expect(result['totalElements'], 0);
      expect(result['totalPages'], 0);
    });
  });

  group('SupportService.getTicketDetail', () {
    test('parses the ticket (with replies) on map body', () async {
      adapter.onGet('${ApiConfig.supportTicketsEndpoint}/42',
          (_) async => jsonResponse({
                'id': 42,
                'ticketNumber': 'TKT-0042',
                'subject': 'Detail',
                'description': 'D',
                'category': 'GENERAL',
                'priority': 'MEDIUM',
                'status': 'OPEN',
                'createdAt': '',
                'updatedAt': '',
                'replies': [
                  {
                    'id': 5,
                    'userId': 'u1',
                    'userType': 'STAFF',
                    'userName': 'Agent',
                    'message': 'Looking into it',
                    'createdAt': '',
                  },
                ],
              }));

      final ticket = await SupportService.getTicketDetail(42);

      expect(ticket, isNotNull);
      expect(ticket!.ticketNumber, 'TKT-0042');
      expect(ticket.replies, hasLength(1));
      expect(ticket.replies.first.isStaff, isTrue);
      expect(ticket.replies.first.message, 'Looking into it');
    });

    test('returns null on DioException', () async {
      adapter.onGet('${ApiConfig.supportTicketsEndpoint}/42',
          (_) async => jsonResponse({'error': 'nope'}, statusCode: 404));

      final ticket = await SupportService.getTicketDetail(42);

      expect(ticket, isNull);
    });
  });

  group('SupportService.addReply', () {
    test('posts message body and parses the created TicketReply', () async {
      Map<String, dynamic>? capturedBody;
      adapter.onPost('${ApiConfig.supportTicketsEndpoint}/42/replies',
          (options) async {
        capturedBody = options.data as Map<String, dynamic>;
        return jsonResponse({
          'id': 7,
          'userId': 'cust-1',
          'userType': 'CUSTOMER',
          'userName': 'Krishnan',
          'message': 'Thanks',
          'attachmentUrl': 'http://x/y.png',
          'createdAt': '2026-05-30',
        });
      });

      final reply = await SupportService.addReply(42, 'Thanks',
          attachmentUrl: 'http://x/y.png');

      expect(reply, isNotNull);
      expect(reply!.id, '7');
      expect(reply.message, 'Thanks');
      expect(reply.attachmentUrl, 'http://x/y.png');
      expect(reply.isStaff, isFalse);
      expect(capturedBody!['message'], 'Thanks');
      expect(capturedBody!['attachmentUrl'], 'http://x/y.png');
    });

    test('omits attachmentUrl from body when null', () async {
      Map<String, dynamic>? capturedBody;
      adapter.onPost('${ApiConfig.supportTicketsEndpoint}/42/replies',
          (options) async {
        capturedBody = options.data as Map<String, dynamic>;
        return jsonResponse({
          'id': 8,
          'userId': 'cust-1',
          'userType': 'CUSTOMER',
          'userName': 'Krishnan',
          'message': 'No attachment',
          'createdAt': '',
        });
      });

      await SupportService.addReply(42, 'No attachment');

      expect(capturedBody!.containsKey('attachmentUrl'), isFalse);
      expect(capturedBody!['message'], 'No attachment');
    });

    test('returns null on DioException', () async {
      adapter.onPost('${ApiConfig.supportTicketsEndpoint}/42/replies',
          (_) async => jsonResponse({'error': 'boom'}, statusCode: 500));

      final reply = await SupportService.addReply(42, 'X');

      expect(reply, isNull);
    });
  });

  group('SupportService.closeTicket', () {
    test('returns true on success', () async {
      adapter.onPatch('${ApiConfig.supportTicketsEndpoint}/42/close',
          (_) async => jsonResponse({'status': 'CLOSED'}));

      final ok = await SupportService.closeTicket(42);

      expect(ok, isTrue);
    });

    test('returns false on DioException', () async {
      adapter.onPatch('${ApiConfig.supportTicketsEndpoint}/42/close',
          (_) async => jsonResponse({'error': 'boom'}, statusCode: 500));

      final ok = await SupportService.closeTicket(42);

      expect(ok, isFalse);
    });

    test('returns false when no handler is registered (network error)',
        () async {
      final ok = await SupportService.closeTicket(999);

      expect(ok, isFalse);
    });
  });
}
