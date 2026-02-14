import 'package:flutter/foundation.dart';

class ApiConfig {
  // API Base URL Configuration
  // Development: Uses localhost as default fallback (port 8080)
  // Production: Must be set via dart-define: --dart-define=API_BASE_URL=https://cust-api.walldotbuilders.com
  // Staging: Can be set via dart-define: --dart-define=API_BASE_URL=https://cust-api-staging.walldotbuilders.com
  // For release builds, API_BASE_URL should always be provided via dart-define
  static const String _devApiUrl = 'http://localhost:8080';
  static const String _prodApiUrl = 'https://cust-api.walldotbuilders.com';
  
  // Get API URL from environment variable (dart-define) or use defaults
  // In production (kReleaseMode), this will use the dart-define value or production URL
  // In development, this will use the dart-define value or localhost
  static String get baseUrl {
    const String envApiUrl = String.fromEnvironment('API_BASE_URL');
    if (envApiUrl.isNotEmpty) {
      return envApiUrl;
    }
    // Fallback: use production URL in release mode, localhost in development
    return kReleaseMode ? _prodApiUrl : _devApiUrl;
  }

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
