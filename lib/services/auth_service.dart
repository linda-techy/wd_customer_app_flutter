import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_models.dart';
import 'api_service.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String phone;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
    };
  }

  // Create User from UserInfo API model
  factory User.fromUserInfo(UserInfo userInfo) {
    return User(
      id: userInfo.id.toString(),
      name: userInfo.fullName,
      email: userInfo.email,
      phone:
          '', // Phone is not in UserInfo, can be fetched separately if needed
    );
  }
}

class AuthService {
  static const String _userKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _hasSeenWelcomeKey = 'has_seen_welcome';
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _userInfoKey = 'user_info';
  static const String _permissionsKey = 'permissions';

  static final ApiService _apiService = ApiService();

  // Login with API
  static Future<ApiResponse<LoginResponse>> loginWithApi(
      String email, String password) async {
    final response = await _apiService.login(email, password);

    if (response.success && response.data != null) {
      // Save tokens and user data
      await _saveLoginData(response.data!);
    }

    return response;
  }

  // Save login data to SharedPreferences
  static Future<void> _saveLoginData(LoginResponse loginResponse) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_accessTokenKey, loginResponse.accessToken);
    await prefs.setString(_refreshTokenKey, loginResponse.refreshToken);
    await prefs.setString(
        _userInfoKey, jsonEncode(loginResponse.user.toJson()));
    await prefs.setStringList(_permissionsKey, loginResponse.permissions);
    await prefs.setBool(_isLoggedInKey, true);

    // Calculate and save token expiry time
    final expiryTime = DateTime.now()
        .add(Duration(milliseconds: loginResponse.expiresIn))
        .millisecondsSinceEpoch;
    await prefs.setInt(_tokenExpiryKey, expiryTime);

    // Convert UserInfo to User for backward compatibility
    final user = User.fromUserInfo(loginResponse.user);
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }

  // Get access token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  // Get refresh token
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  // Check if token is expired
  static Future<bool> isTokenExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryTime = prefs.getInt(_tokenExpiryKey);

    if (expiryTime == null) return true;

    final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiryTime);
    // Consider expired 1 minute before actual expiry
    return DateTime.now()
        .isAfter(expiryDate.subtract(const Duration(minutes: 1)));
  }

  // Refresh access token
  static Future<bool> refreshAccessToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return false;

    final response = await _apiService.refreshToken(refreshToken);

    if (response.success && response.data != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_accessTokenKey, response.data!.accessToken);

      // Update expiry time
      final expiryTime = DateTime.now()
          .add(Duration(milliseconds: response.data!.expiresIn))
          .millisecondsSinceEpoch;
      await prefs.setInt(_tokenExpiryKey, expiryTime);

      return true;
    }

    return false;
  }

  // Get UserInfo from storage
  static Future<UserInfo?> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userInfoJson = prefs.getString(_userInfoKey);

    if (userInfoJson != null) {
      return UserInfo.fromJson(jsonDecode(userInfoJson));
    }
    return null;
  }

  // Get permissions
  static Future<List<String>> getPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_permissionsKey) ?? [];
  }

  // Check if user has permission
  static Future<bool> hasPermission(String permission) async {
    final permissions = await getPermissions();
    return permissions.contains(permission);
  }

  // Logout with API
  static Future<void> logoutWithApi() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();

    if (accessToken != null && refreshToken != null) {
      // Call logout API (don't wait for response, clear local data anyway)
      _apiService.logout(refreshToken, accessToken);
    }

    await _clearAuthData();
  }

  // Clear all authentication data
  static Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_tokenExpiryKey);
    await prefs.remove(_userInfoKey);
    await prefs.remove(_permissionsKey);
    await prefs.remove(_userKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  // Old methods for backward compatibility
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedInFlag = prefs.getBool(_isLoggedInKey) ?? false;

    developer.log('AuthService.isLoggedIn(): isLoggedInFlag = $isLoggedInFlag',
        name: 'AuthService');

    // If the flag is false, user is not logged in
    if (!isLoggedInFlag) {
      developer.log(
          'AuthService.isLoggedIn(): User not logged in (flag is false)',
          name: 'AuthService');
      return false;
    }

    // Check if we have valid tokens and user data
    final accessToken = prefs.getString(_accessTokenKey);
    final userInfo = prefs.getString(_userInfoKey);

    developer.log(
        'AuthService.isLoggedIn(): accessToken = ${accessToken != null ? "present" : "null"}',
        name: 'AuthService');
    developer.log(
        'AuthService.isLoggedIn(): userInfo = ${userInfo != null ? "present" : "null"}',
        name: 'AuthService');

    // If no token or user info, user is not logged in
    if (accessToken == null || userInfo == null) {
      developer.log(
          'AuthService.isLoggedIn(): Missing token or user info, clearing auth data',
          name: 'AuthService');
      await _clearAuthData(); // Clean up invalid data
      return false;
    }

    // Check if token is expired
    final isExpired = await isTokenExpired();
    developer.log('AuthService.isLoggedIn(): Token expired = $isExpired',
        name: 'AuthService');

    if (isExpired) {
      // Try to refresh the token
      developer.log('AuthService.isLoggedIn(): Attempting to refresh token',
          name: 'AuthService');
      final refreshSuccess = await refreshAccessToken();
      if (!refreshSuccess) {
        developer.log(
            'AuthService.isLoggedIn(): Token refresh failed, clearing auth data',
            name: 'AuthService');
        await _clearAuthData(); // Clean up expired data
        return false;
      }
      developer.log('AuthService.isLoggedIn(): Token refresh successful',
          name: 'AuthService');
    }

    developer.log('AuthService.isLoggedIn(): User is logged in',
        name: 'AuthService');
    return true;
  }

  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return User.fromJson(json.decode(userJson));
    }
    return null;
  }

  static Future<void> login(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
    await prefs.setBool(_isLoggedInKey, true);
  }

  static Future<void> logout() async {
    await _clearAuthData();
  }

  static Future<bool> hasSeenWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenWelcomeKey) ?? false;
  }

  static Future<void> setWelcomeSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenWelcomeKey, true);
  }

  // Clear all authentication data (useful for app startup or logout)
  static Future<void> clearAllAuthData() async {
    await _clearAuthData();
  }

  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
}
