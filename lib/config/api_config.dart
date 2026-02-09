import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // Base URL from .env (API_BASE_URL)
  // Dev: http://localhost:8080
  // Staging: https://cust-api-staging.walldotbuilders.com
  // Production: https://cust-api.walldotbuilders.com
  static String get baseUrl =>
      dotenv.get('API_BASE_URL', fallback: 'http://localhost:8080');

  // API endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String forgotPasswordEndpoint = '/auth/forgot-password';
  static const String resetPasswordEndpoint = '/auth/reset-password';
  static const String refreshTokenEndpoint = '/auth/refresh-token';
  static const String logoutEndpoint = '/auth/logout';
  static const String getCurrentUserEndpoint = '/auth/me';
  static const String testEndpoint = '/auth/test';
  static const String dashboardEndpoint = '/api/dashboard';

  // Full URLs
  static String get loginUrl => '$baseUrl$loginEndpoint';
  static String get registerUrl => '$baseUrl$registerEndpoint';
  static String get forgotPasswordUrl => '$baseUrl$forgotPasswordEndpoint';
  static String get resetPasswordUrl => '$baseUrl$resetPasswordEndpoint';
  static String get refreshTokenUrl => '$baseUrl$refreshTokenEndpoint';
  static String get logoutUrl => '$baseUrl$logoutEndpoint';
  static String get getCurrentUserUrl => '$baseUrl$getCurrentUserEndpoint';
  static String get testUrl => '$baseUrl$testEndpoint';
  static String get dashboardUrl => '$baseUrl$dashboardEndpoint';

  // Request timeouts
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);

  // Headers
  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Map<String, String> getAuthHeaders(String token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
}
