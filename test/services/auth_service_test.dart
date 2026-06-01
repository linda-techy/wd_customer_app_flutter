import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wd_cust_mobile_app/config/api_config.dart';
import 'package:wd_cust_mobile_app/services/api_service.dart';
import 'package:wd_cust_mobile_app/services/auth_service.dart';

import '../test_helpers/mock_dio_adapter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // ApiConfig.baseUrl reads dotenv.env; initialize it (empty) so it falls back
  // to the dev URL instead of throwing NotInitializedError.
  dotenv.loadFromString(envString: '', isOptional: true);

  late MockDioAdapter adapter;

  // AuthService delegates to ApiService(), which builds absolute URLs via
  // ApiConfig (e.g. '$baseUrl/auth/login'), so register handlers with the full
  // URL string.
  final base = ApiConfig.baseUrl;

  // Secure-storage keys (mirrors the private constants in AuthService).
  const accessTokenKey = 'access_token';
  const refreshTokenKey = 'refresh_token';

  // In-memory secure-storage backing the mocked MethodChannel so write/read/
  // delete round-trips behave like the real plugin. Matches the channel-mock
  // approach from session_manager_test.dart / lead_service_test.dart.
  const secureStorageChannel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  late Map<String, String> secureStore;

  void installSecureStorageMock() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (call) async {
      final args = (call.arguments as Map?) ?? const {};
      final key = args['key'] as String?;
      switch (call.method) {
        case 'read':
          return key != null ? secureStore[key] : null;
        case 'write':
          if (key != null) secureStore[key] = args['value'] as String? ?? '';
          return null;
        case 'delete':
          if (key != null) secureStore.remove(key);
          return null;
        case 'readAll':
          return Map<String, String>.from(secureStore);
        case 'deleteAll':
          secureStore.clear();
          return null;
        case 'containsKey':
          return key != null && secureStore.containsKey(key);
        default:
          return null;
      }
    });
  }

  setUp(() {
    // 1) ApiService HTTP — inject a mock-adapter-backed Dio into the singleton.
    adapter = MockDioAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://test.example'))
      ..httpClientAdapter = adapter;
    ApiService().setTestDio(dio);

    // 2) SharedPreferences — start empty; individual tests seed what they read.
    SharedPreferences.setMockInitialValues(<String, Object>{});

    // 3) flutter_secure_storage — fresh in-memory store per test.
    secureStore = <String, String>{};
    installSecureStorageMock();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, null);
  });

  // Builds a login-response JSON body the API would return.
  Map<String, dynamic> loginBody({
    String accessToken = 'access-abc',
    String refreshToken = 'refresh-xyz',
    int expiresIn = 3600000,
    List<String> permissions = const ['VIEW_PROJECT', 'VIEW_BILLS'],
  }) {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'tokenType': 'Bearer',
      'expiresIn': expiresIn,
      'user': {
        'id': 42,
        'email': 'krishnan@example.com',
        'firstName': 'Krishnan',
        'lastName': 'Nair',
        'role': 'CUSTOMER',
        'phone': '9999',
      },
      'permissions': permissions,
      'projectCount': 1,
      'redirectUrl': '/dashboard',
    };
  }

  // ---------------------------------------------------------------------------
  // Secure-storage reads
  // ---------------------------------------------------------------------------
  group('getAccessToken', () {
    test('returns the value stored under access_token', () async {
      secureStore[accessTokenKey] = 'tok-123';

      expect(await AuthService.getAccessToken(), 'tok-123');
    });

    test('returns null when no access token is stored', () async {
      expect(await AuthService.getAccessToken(), isNull);
    });
  });

  group('getRefreshToken', () {
    test('returns the value stored under refresh_token', () async {
      secureStore[refreshTokenKey] = 'rtok-456';

      expect(await AuthService.getRefreshToken(), 'rtok-456');
    });

    test('returns null when no refresh token is stored', () async {
      expect(await AuthService.getRefreshToken(), isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // isTokenExpired — reads SharedPreferences 'token_expiry' (ms epoch).
  // Treated as expired if missing, or if now is past (expiry - 1 minute).
  // ---------------------------------------------------------------------------
  group('isTokenExpired', () {
    test('returns true when no expiry is stored', () async {
      expect(await AuthService.isTokenExpired(), isTrue);
    });

    test('returns true when expiry is in the past', () async {
      final past = DateTime.now()
          .subtract(const Duration(hours: 1))
          .millisecondsSinceEpoch;
      SharedPreferences.setMockInitialValues({'token_expiry': past});

      expect(await AuthService.isTokenExpired(), isTrue);
    });

    test('returns false when expiry is comfortably in the future', () async {
      final future = DateTime.now()
          .add(const Duration(hours: 1))
          .millisecondsSinceEpoch;
      SharedPreferences.setMockInitialValues({'token_expiry': future});

      expect(await AuthService.isTokenExpired(), isFalse);
    });

    test('returns true within the 1-minute pre-expiry safety window', () async {
      // Expiry is 30s away -> inside the (expiry - 1min) window -> expired.
      final soon = DateTime.now()
          .add(const Duration(seconds: 30))
          .millisecondsSinceEpoch;
      SharedPreferences.setMockInitialValues({'token_expiry': soon});

      expect(await AuthService.isTokenExpired(), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // getUserInfo — reads SharedPreferences 'user_info' (json) -> UserInfo?.
  // ---------------------------------------------------------------------------
  group('getUserInfo', () {
    test('returns null when no user_info is stored', () async {
      expect(await AuthService.getUserInfo(), isNull);
    });

    test('parses stored user_info json into a UserInfo', () async {
      SharedPreferences.setMockInitialValues({
        'user_info': jsonEncode({
          'id': 7,
          'email': 'demo@walldot.com',
          'firstName': 'Demo',
          'lastName': 'Customer',
          'role': 'CUSTOMER',
        }),
      });

      final info = await AuthService.getUserInfo();

      expect(info, isNotNull);
      expect(info!.id, 7);
      expect(info.email, 'demo@walldot.com');
      expect(info.fullName, 'Demo Customer');
      expect(info.role, 'CUSTOMER');
    });
  });

  // ---------------------------------------------------------------------------
  // getPermissions — reads SharedPreferences 'permissions' (stringList),
  // defaults to []. hasPermission delegates to it.
  // ---------------------------------------------------------------------------
  group('getPermissions', () {
    test('returns an empty list when none are stored', () async {
      expect(await AuthService.getPermissions(), isEmpty);
    });

    test('returns the stored permission list', () async {
      SharedPreferences.setMockInitialValues({
        'permissions': <String>['VIEW_PROJECT', 'VIEW_BILLS'],
      });

      final perms = await AuthService.getPermissions();

      expect(perms, ['VIEW_PROJECT', 'VIEW_BILLS']);
    });
  });

  group('hasPermission', () {
    test('returns true when the permission is present', () async {
      SharedPreferences.setMockInitialValues({
        'permissions': <String>['VIEW_PROJECT', 'VIEW_BILLS'],
      });

      expect(await AuthService.hasPermission('VIEW_BILLS'), isTrue);
    });

    test('returns false when the permission is absent', () async {
      SharedPreferences.setMockInitialValues({
        'permissions': <String>['VIEW_PROJECT'],
      });

      expect(await AuthService.hasPermission('ADMIN'), isFalse);
    });

    test('returns false when no permissions are stored', () async {
      expect(await AuthService.hasPermission('VIEW_PROJECT'), isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // loginWithApi — POST /auth/login. On success persists tokens (secure
  // storage) + user/permissions/expiry/is_logged_in (prefs). FCM init is
  // fire-and-forget (unawaited) so it does not block or affect the result.
  // ---------------------------------------------------------------------------
  group('loginWithApi', () {
    test('on 200 returns success and persists tokens + user data', () async {
      adapter.onPost('$base/auth/login',
          (_) async => jsonResponse(loginBody()));

      final response =
          await AuthService.loginWithApi('krishnan@example.com', 'pw');

      expect(response.success, isTrue);
      expect(response.data, isNotNull);
      expect(response.data!.accessToken, 'access-abc');

      // Tokens written to secure storage.
      expect(secureStore[accessTokenKey], 'access-abc');
      expect(secureStore[refreshTokenKey], 'refresh-xyz');

      // Non-sensitive data written to SharedPreferences.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('is_logged_in'), isTrue);
      expect(prefs.getStringList('permissions'),
          ['VIEW_PROJECT', 'VIEW_BILLS']);
      expect(prefs.getInt('token_expiry'), isNotNull);

      final storedUserInfo =
          jsonDecode(prefs.getString('user_info')!) as Map<String, dynamic>;
      expect(storedUserInfo['id'], 42);
      expect(storedUserInfo['email'], 'krishnan@example.com');

      // Backward-compat User record under 'user_data'.
      final storedUser =
          jsonDecode(prefs.getString('user_data')!) as Map<String, dynamic>;
      expect(storedUser['name'], 'Krishnan Nair');
      expect(storedUser['email'], 'krishnan@example.com');

      // The mocked endpoint reads back from secure storage too.
      expect(await AuthService.getAccessToken(), 'access-abc');
      expect(await AuthService.getRefreshToken(), 'refresh-xyz');
    });

    test('on non-2xx returns error and persists nothing', () async {
      adapter.onPost(
          '$base/auth/login',
          (_) async => jsonResponse(
              {'message': 'Invalid credentials'}, statusCode: 401));

      final response =
          await AuthService.loginWithApi('bad@example.com', 'wrong');

      expect(response.success, isFalse);
      expect(secureStore[accessTokenKey], isNull);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('is_logged_in'), isNull);
      expect(prefs.getString('user_info'), isNull);
    });

    test('on network error (no handler) returns a graceful error', () async {
      final response =
          await AuthService.loginWithApi('a@b.com', 'pw');

      // ApiService maps DioException -> ApiResponse.error (does not throw).
      expect(response.success, isFalse);
      expect(response.error, isNotNull);
      expect(secureStore[accessTokenKey], isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // refreshAccessToken — needs a stored refresh token, POSTs /auth/refresh-token,
  // writes the new access token + updates expiry. False if no refresh token or
  // the call fails.
  // ---------------------------------------------------------------------------
  group('refreshAccessToken', () {
    test('returns false when there is no stored refresh token', () async {
      final ok = await AuthService.refreshAccessToken();

      expect(ok, isFalse);
    });

    test('on 200 writes the new access token + new expiry, returns true',
        () async {
      secureStore[refreshTokenKey] = 'rtok-456';
      secureStore[accessTokenKey] = 'old-access';
      adapter.onPost(
          '$base/auth/refresh-token',
          (_) async => jsonResponse({
                'accessToken': 'new-access',
                'tokenType': 'Bearer',
                'expiresIn': 3600000,
              }));

      final ok = await AuthService.refreshAccessToken();

      expect(ok, isTrue);
      expect(secureStore[accessTokenKey], 'new-access');
      // Refresh token is left untouched.
      expect(secureStore[refreshTokenKey], 'rtok-456');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('token_expiry'), isNotNull);
      expect(await AuthService.isTokenExpired(), isFalse);
    });

    test('on non-2xx returns false and leaves the access token unchanged',
        () async {
      secureStore[refreshTokenKey] = 'rtok-456';
      secureStore[accessTokenKey] = 'old-access';
      adapter.onPost('$base/auth/refresh-token',
          (_) async => jsonResponse({'message': 'expired'}, statusCode: 401));

      final ok = await AuthService.refreshAccessToken();

      expect(ok, isFalse);
      expect(secureStore[accessTokenKey], 'old-access');
    });
  });

  // ---------------------------------------------------------------------------
  // forgotPassword / resetPassword — thin delegates to ApiService.
  // ---------------------------------------------------------------------------
  group('forgotPassword', () {
    test('on 200 returns success with the response body', () async {
      adapter.onPost('$base/auth/forgot-password',
          (_) async => jsonResponse({'sent': true}));

      final response = await AuthService.forgotPassword('a@b.com');

      expect(response.success, isTrue);
      expect(response.data!['sent'], true);
    });

    test('on non-2xx returns an error', () async {
      adapter.onPost(
          '$base/auth/forgot-password',
          (_) async =>
              jsonResponse({'message': 'no such user'}, statusCode: 404));

      final response = await AuthService.forgotPassword('a@b.com');

      expect(response.success, isFalse);
      expect(response.error, isNotNull);
    });
  });

  group('resetPassword', () {
    test('on 200 returns success and posts the reset payload', () async {
      Map<String, dynamic>? body;
      adapter.onPost('$base/auth/reset-password', (options) async {
        body = options.data as Map<String, dynamic>;
        return jsonResponse({'reset': true});
      });

      final response =
          await AuthService.resetPassword('a@b.com', '123456', 'newpw');

      expect(response.success, isTrue);
      expect(response.data!['reset'], true);
      expect(body!['email'], 'a@b.com');
      expect(body!['resetCode'], '123456');
      expect(body!['newPassword'], 'newpw');
    });

    test('on non-2xx returns an error', () async {
      adapter.onPost(
          '$base/auth/reset-password',
          (_) async =>
              jsonResponse({'message': 'bad code'}, statusCode: 400));

      final response =
          await AuthService.resetPassword('a@b.com', '000000', 'newpw');

      expect(response.success, isFalse);
      expect(response.error, isNotNull);
    });
  });

  // ---------------------------------------------------------------------------
  // logoutWithApi -> _clearAuthData: deletes both tokens from secure storage
  // and clears the prefs auth keys (is_logged_in set to false). The logout API
  // call is fire-and-forget (unawaited) and only fires if both tokens exist.
  // ---------------------------------------------------------------------------
  group('logoutWithApi / _clearAuthData', () {
    test('clears tokens and prefs auth data when logged in', () async {
      secureStore[accessTokenKey] = 'access-abc';
      secureStore[refreshTokenKey] = 'refresh-xyz';
      SharedPreferences.setMockInitialValues({
        'is_logged_in': true,
        'token_expiry': DateTime.now().millisecondsSinceEpoch,
        'user_info': jsonEncode({'id': 1}),
        'permissions': <String>['VIEW_PROJECT'],
        'user_data': jsonEncode({'id': '1'}),
      });
      // The unawaited logout API call hits this endpoint; provide a handler so
      // it resolves cleanly rather than throwing into a fire-and-forget future.
      adapter.onPost('$base/auth/logout',
          (_) async => jsonResponse({'ok': true}));

      await AuthService.logoutWithApi();

      // Tokens gone from secure storage.
      expect(secureStore[accessTokenKey], isNull);
      expect(secureStore[refreshTokenKey], isNull);

      // Prefs auth keys cleared; is_logged_in explicitly set to false.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('is_logged_in'), isFalse);
      expect(prefs.getInt('token_expiry'), isNull);
      expect(prefs.getString('user_info'), isNull);
      expect(prefs.getStringList('permissions'), isNull);
      expect(prefs.getString('user_data'), isNull);
    });

    test('still clears local data when no tokens are present', () async {
      SharedPreferences.setMockInitialValues({'is_logged_in': true});

      await AuthService.logoutWithApi();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('is_logged_in'), isFalse);
      expect(secureStore[accessTokenKey], isNull);
    });
  });
}
