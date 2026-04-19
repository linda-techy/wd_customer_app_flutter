/// Shared configuration constants for customer app integration tests.
class TestConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8081',
  );

  // Test customer accounts
  static const String customerAEmail = 'customerA@test.com';
  static const String customerBEmail = 'customerB@test.com';
  static const String customerCEmail = 'customerC@test.com';
  static const String password = 'password123';

  // Invalid credentials for negative tests
  static const String invalidEmail = 'nobody@invalid.com';
  static const String invalidPassword = 'wrongpassword';

  // Pump-and-settle durations
  static const Duration pumpSettleDuration = Duration(seconds: 5);
  static const Duration longPumpSettleDuration = Duration(seconds: 10);
  static const Duration extraLongPumpSettleDuration = Duration(seconds: 15);
}
