import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wd_cust_mobile_app/config/api_config.dart';
import 'package:wd_cust_mobile_app/models/lead_models.dart';
import 'package:wd_cust_mobile_app/services/lead_service.dart';

import '../test_helpers/mock_dio_adapter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // ApiConfig.baseUrl reads dotenv.env; initialize it (empty) so it falls back
  // to the dev URL instead of throwing NotInitializedError.
  dotenv.loadFromString(envString: '', isOptional: true);

  late MockDioAdapter adapter;

  // LeadService passes absolute URLs ('${ApiConfig.baseUrl}/api/leads/...'),
  // so options.path is the full URL string -> register handlers with the same.
  final base = ApiConfig.baseUrl;

  // LeadService short-circuits when AuthService.getAccessToken() is null, so
  // mock flutter_secure_storage to return a token.
  const secureStorageChannel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

  void mockToken(String? token) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (call) async {
      if (call.method == 'read') return token;
      return null;
    });
  }

  setUp(() {
    adapter = MockDioAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://test.example'))
      ..httpClientAdapter = adapter;
    LeadService.testDio = dio;
    mockToken('fake-token');
  });

  tearDown(() {
    LeadService.testDio = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, null);
  });

  group('LeadService.getMyLeads', () {
    test('parses a JSON list into CustomerLead models', () async {
      adapter.onGet('$base/api/leads/my', (_) async => jsonResponse([
            {
              'id': 1,
              'name': 'Krishnan',
              'email': 'k@x.com',
              'phone': '9999',
              'projectType': 'NEW_BUILD',
              'budget': '50L',
              'area': '2400',
              'location': 'Kakkanad',
              'district': 'Ernakulam',
              'state': 'Kerala',
              'status': 'In Discussion',
              'internalStatus': 'negotiation',
              'source': 'APP',
              'createdAt': '2026-05-01',
            },
          ]));

      final result = await LeadService.getMyLeads();

      expect(result, hasLength(1));
      expect(result.first.id, 1);
      expect(result.first.name, 'Krishnan');
      expect(result.first.internalStatus, 'negotiation');
      expect(result.first.statusStepIndex, 4);
    });

    test('returns empty list when token is null', () async {
      mockToken(null);

      final result = await LeadService.getMyLeads();

      expect(result, isEmpty);
    });

    test('returns empty list on non-200', () async {
      adapter.onGet('$base/api/leads/my',
          (_) async => jsonResponse([], statusCode: 401));

      final result = await LeadService.getMyLeads();

      expect(result, isEmpty);
    });

    test('returns empty list when 200 body is not a list', () async {
      adapter.onGet(
          '$base/api/leads/my', (_) async => jsonResponse({'oops': true}));

      final result = await LeadService.getMyLeads();

      expect(result, isEmpty);
    });

    test('returns empty list on network error (no handler)', () async {
      final result = await LeadService.getMyLeads();

      expect(result, isEmpty);
    });
  });

  group('LeadService.getMyReferrals', () {
    test('returns the raw list of maps on 200', () async {
      adapter.onGet('$base/api/leads/my-referrals', (_) async => jsonResponse([
            {'id': 1, 'friendName': 'Anand', 'status': 'Processing'},
            {'id': 2, 'friendName': 'Bina', 'status': 'Converted'},
          ]));

      final result = await LeadService.getMyReferrals();

      expect(result, hasLength(2));
      expect(result[0]['friendName'], 'Anand');
      expect(result[1]['status'], 'Converted');
    });

    test('returns empty list when token is null', () async {
      mockToken(null);

      final result = await LeadService.getMyReferrals();

      expect(result, isEmpty);
    });

    test('returns empty list on non-200', () async {
      adapter.onGet('$base/api/leads/my-referrals',
          (_) async => jsonResponse([], statusCode: 500));

      final result = await LeadService.getMyReferrals();

      expect(result, isEmpty);
    });

    test('returns empty list on network error (no handler)', () async {
      final result = await LeadService.getMyReferrals();

      expect(result, isEmpty);
    });
  });

  group('LeadService.getLeadDetail', () {
    test('parses a single CustomerLead on map body', () async {
      adapter.onGet('$base/api/leads/my/7', (_) async => jsonResponse({
            'id': 7,
            'name': 'Detail Lead',
            'email': 'd@x.com',
            'phone': '8888',
            'projectType': 'NEW_BUILD',
            'budget': '40L',
            'area': '1800',
            'location': 'Aluva',
            'district': 'Ernakulam',
            'state': 'Kerala',
            'status': 'Contacted',
            'internalStatus': 'contacted',
            'source': 'APP',
            'createdAt': '2026-05-01',
          }));

      final result = await LeadService.getLeadDetail(7);

      expect(result, isNotNull);
      expect(result!.id, 7);
      expect(result.name, 'Detail Lead');
      expect(result.statusStepIndex, 1);
    });

    test('returns null when token is null', () async {
      mockToken(null);

      final result = await LeadService.getLeadDetail(7);

      expect(result, isNull);
    });

    test('returns null on non-200', () async {
      adapter.onGet('$base/api/leads/my/7',
          (_) async => jsonResponse({}, statusCode: 404));

      final result = await LeadService.getLeadDetail(7);

      expect(result, isNull);
    });

    test('returns null when 200 body is not a map', () async {
      adapter.onGet('$base/api/leads/my/7', (_) async => jsonResponse([]));

      final result = await LeadService.getLeadDetail(7);

      expect(result, isNull);
    });
  });

  group('LeadService.submitEnquiry', () {
    const request = NewEnquiryRequest(
      projectType: 'NEW_BUILD',
      state: 'Kerala',
      district: 'Ernakulam',
      location: 'Kochi',
      budget: '50L',
    );

    test('returns true on 200 and posts the request body', () async {
      Map<String, dynamic>? capturedBody;
      adapter.onPost('$base/api/leads/enquiry', (options) async {
        capturedBody = options.data as Map<String, dynamic>;
        return jsonResponse({'ok': true});
      });

      final ok = await LeadService.submitEnquiry(request);

      expect(ok, isTrue);
      expect(capturedBody!['projectType'], 'NEW_BUILD');
      expect(capturedBody!['state'], 'Kerala');
      expect(capturedBody!['district'], 'Ernakulam');
      expect(capturedBody!['location'], 'Kochi');
      expect(capturedBody!['budget'], '50L');
    });

    test('returns true on 201', () async {
      adapter.onPost('$base/api/leads/enquiry',
          (_) async => jsonResponse({'id': 1}, statusCode: 201));

      final ok = await LeadService.submitEnquiry(request);

      expect(ok, isTrue);
    });

    test('returns false when token is null', () async {
      mockToken(null);

      final ok = await LeadService.submitEnquiry(request);

      expect(ok, isFalse);
    });

    test('returns false on non-2xx', () async {
      adapter.onPost('$base/api/leads/enquiry',
          (_) async => jsonResponse({'error': 'bad'}, statusCode: 400));

      final ok = await LeadService.submitEnquiry(request);

      expect(ok, isFalse);
    });

    test('returns false on network error (no handler)', () async {
      final ok = await LeadService.submitEnquiry(request);

      expect(ok, isFalse);
    });
  });
}
