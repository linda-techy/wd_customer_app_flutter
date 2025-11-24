class ApiConfig {
  // Base URL for the API
  // Production: https://cust-api.walldotbuilders.com
  // For Android emulator use: http://10.0.2.2:8081
  // For iOS simulator use: http://localhost:8081
  // For physical device use: http://YOUR_IP_ADDRESS:8081
  //static const String baseUrl = 'http://localhost:8081';
  static const String baseUrl = 'https://cust-api.walldotbuilders.com';

  // API endpoints
  static const String loginEndpoint = '/auth/login';
  static const String refreshTokenEndpoint = '/auth/refresh-token';
  static const String logoutEndpoint = '/auth/logout';
  static const String getCurrentUserEndpoint = '/auth/me';
  static const String testEndpoint = '/auth/test';
  static const String dashboardEndpoint = '/api/dashboard';

  // Full URLs
  static String get loginUrl => '$baseUrl$loginEndpoint';
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
