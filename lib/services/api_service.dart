import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/api_models.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Login method
  Future<ApiResponse<LoginResponse>> login(
      String email, String password) async {
    try {
      final loginRequest = LoginRequest(email: email, password: password);

      // Debug: Print the request details
      print('=== API LOGIN REQUEST ===');
      print('URL: ${ApiConfig.loginUrl}');
      print('Headers: ${ApiConfig.defaultHeaders}');
      print('Body: ${jsonEncode(loginRequest.toJson())}');
      print('Email: $email');
      print('Password length: ${password.length}');
      print(
          'Password contains special chars: ${password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))}');
      print('========================');

      final response = await http
          .post(
            Uri.parse(ApiConfig.loginUrl),
            headers: ApiConfig.defaultHeaders,
            body: jsonEncode(loginRequest.toJson()),
          )
          .timeout(ApiConfig.connectionTimeout);

      // Debug: Print the response details
      print('=== API LOGIN RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');
      print('=========================');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(jsonResponse);
        return ApiResponse.success(loginResponse);
      } else {
        final errorJson = jsonDecode(response.body);
        final error = ApiError.fromJson(errorJson);
        return ApiResponse.error(error);
      }
    } on SocketException {
      return ApiResponse.error(
        ApiError(
          message: 'No internet connection. Please check your network.',
          statusCode: 0,
        ),
      );
    } on HttpException {
      return ApiResponse.error(
        ApiError(
          message: 'Server error. Please try again later.',
          statusCode: 500,
        ),
      );
    } on FormatException {
      return ApiResponse.error(
        ApiError(
          message: 'Invalid response format from server.',
          statusCode: 0,
        ),
      );
    } catch (e) {
      return ApiResponse.error(
        ApiError(
          message: 'An unexpected error occurred: ${e.toString()}',
          statusCode: 0,
        ),
      );
    }
  }

  // Refresh token method
  Future<ApiResponse<RefreshTokenResponse>> refreshToken(
      String refreshToken) async {
    try {
      final refreshRequest = RefreshTokenRequest(refreshToken: refreshToken);

      final response = await http
          .post(
            Uri.parse(ApiConfig.refreshTokenUrl),
            headers: ApiConfig.defaultHeaders,
            body: jsonEncode(refreshRequest.toJson()),
          )
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final refreshResponse = RefreshTokenResponse.fromJson(jsonResponse);
        return ApiResponse.success(refreshResponse);
      } else {
        final errorJson = jsonDecode(response.body);
        final error = ApiError.fromJson(errorJson);
        return ApiResponse.error(error);
      }
    } on SocketException {
      return ApiResponse.error(
        ApiError(
          message: 'No internet connection.',
          statusCode: 0,
        ),
      );
    } catch (e) {
      return ApiResponse.error(
        ApiError(
          message: 'Failed to refresh token: ${e.toString()}',
          statusCode: 0,
        ),
      );
    }
  }

  // Logout method
  Future<ApiResponse<void>> logout(
      String refreshToken, String accessToken) async {
    try {
      final refreshRequest = RefreshTokenRequest(refreshToken: refreshToken);

      final response = await http
          .post(
            Uri.parse(ApiConfig.logoutUrl),
            headers: ApiConfig.getAuthHeaders(accessToken),
            body: jsonEncode(refreshRequest.toJson()),
          )
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        return ApiResponse.success(null);
      } else {
        final errorJson = jsonDecode(response.body);
        final error = ApiError.fromJson(errorJson);
        return ApiResponse.error(error);
      }
    } on SocketException {
      return ApiResponse.error(
        ApiError(
          message: 'No internet connection.',
          statusCode: 0,
        ),
      );
    } catch (e) {
      return ApiResponse.error(
        ApiError(
          message: 'Failed to logout: ${e.toString()}',
          statusCode: 0,
        ),
      );
    }
  }

  // Get current user method
  Future<ApiResponse<UserInfo>> getCurrentUser(String accessToken) async {
    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.getCurrentUserUrl),
            headers: ApiConfig.getAuthHeaders(accessToken),
          )
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final userInfo = UserInfo.fromJson(jsonResponse);
        return ApiResponse.success(userInfo);
      } else {
        final errorJson = jsonDecode(response.body);
        final error = ApiError.fromJson(errorJson);
        return ApiResponse.error(error);
      }
    } on SocketException {
      return ApiResponse.error(
        ApiError(
          message: 'No internet connection.',
          statusCode: 0,
        ),
      );
    } catch (e) {
      return ApiResponse.error(
        ApiError(
          message: 'Failed to get user info: ${e.toString()}',
          statusCode: 0,
        ),
      );
    }
  }

  // Get dashboard data method
  Future<ApiResponse<DashboardDto>> getDashboard(String accessToken) async {
    try {
      print('=== API DASHBOARD REQUEST ===');
      print('URL: ${ApiConfig.dashboardUrl}');
      print('Access Token: ${accessToken.substring(0, 20)}...');
      print('============================');

      final response = await http
          .get(
            Uri.parse(ApiConfig.dashboardUrl),
            headers: ApiConfig.getAuthHeaders(accessToken),
          )
          .timeout(ApiConfig.connectionTimeout);

      print('=== API DASHBOARD RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('=============================');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final dashboardData = DashboardDto.fromJson(jsonResponse);
        return ApiResponse.success(dashboardData);
      } else {
        final errorJson = jsonDecode(response.body);
        final error = ApiError.fromJson(errorJson);
        return ApiResponse.error(error);
      }
    } on SocketException {
      return ApiResponse.error(
        ApiError(
          message: 'No internet connection.',
          statusCode: 0,
        ),
      );
    } catch (e) {
      return ApiResponse.error(
        ApiError(
          message: 'Failed to get dashboard data: ${e.toString()}',
          statusCode: 0,
        ),
      );
    }
  }

  // Get project details method
  Future<ApiResponse<ProjectDetails>> getProjectDetails(String projectUuid, String accessToken) async {
    try {
      final url = '${ApiConfig.baseUrl}/api/dashboard/projects/$projectUuid';
      
      print('=== API PROJECT DETAILS REQUEST ===');
      print('URL: $url');
      print('Project UUID: $projectUuid');
      print('Access Token: ${accessToken.substring(0, 20)}...');
      print('==================================');

      final response = await http
          .get(
            Uri.parse(url),
            headers: ApiConfig.getAuthHeaders(accessToken),
          )
          .timeout(ApiConfig.connectionTimeout);

      print('=== API PROJECT DETAILS RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('===================================');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final projectDetails = ProjectDetails.fromJson(jsonResponse);
        return ApiResponse.success(projectDetails);
      } else {
        final errorJson = jsonDecode(response.body);
        final error = ApiError.fromJson(errorJson);
        return ApiResponse.error(error);
      }
    } on SocketException {
      return ApiResponse.error(
        ApiError(
          message: 'No internet connection.',
          statusCode: 0,
        ),
      );
    } catch (e) {
      return ApiResponse.error(
        ApiError(
          message: 'Failed to get project details: ${e.toString()}',
          statusCode: 0,
        ),
      );
    }
  }

  /// Server-side project search. Empty/null [query] returns recent projects (backend default).
  Future<ApiResponse<List<ProjectCard>>> searchProjects(String accessToken, [String? query]) async {
    try {
      final path = query != null && query.trim().isNotEmpty
          ? '/api/dashboard/search-projects?q=${Uri.encodeQueryComponent(query.trim())}'
          : '/api/dashboard/search-projects';
      final uri = Uri.parse('${ApiConfig.baseUrl}$path');

      final response = await http
          .get(
            uri,
            headers: ApiConfig.getAuthHeaders(accessToken),
          )
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>?;
        final projects = (list ?? [])
            .map((e) => ProjectCard.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiResponse.success(projects);
      } else {
        final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
        final error = body != null ? ApiError.fromJson(body as Map<String, dynamic>) : ApiError(
          message: 'Search failed (${response.statusCode})',
          statusCode: response.statusCode,
        );
        return ApiResponse.error(error);
      }
    } on SocketException {
      return ApiResponse.error(
        ApiError(message: 'No internet connection.', statusCode: 0),
      );
    } catch (e) {
      return ApiResponse.error(
        ApiError(
          message: 'Failed to search projects: ${e.toString()}',
          statusCode: 0,
        ),
      );
    }
  }

  // Test connection method
  Future<ApiResponse<String>> testConnection() async {
    try {
      print('Testing API connection to: ${ApiConfig.testUrl}');

      final response = await http
          .get(
            Uri.parse(ApiConfig.testUrl),
            headers: ApiConfig.defaultHeaders,
          )
          .timeout(ApiConfig.connectionTimeout);

      print('Test response status: ${response.statusCode}');
      print('Test response body: ${response.body}');

      if (response.statusCode == 200) {
        return ApiResponse.success(response.body);
      } else {
        return ApiResponse.error(
          ApiError(
            message: 'Server returned status code: ${response.statusCode}',
            statusCode: response.statusCode,
          ),
        );
      }
    } on SocketException {
      print('SocketException: Cannot connect to server');
      return ApiResponse.error(
        ApiError(
          message:
              'Cannot connect to server. Please check if the API is running on ${ApiConfig.baseUrl}',
          statusCode: 0,
        ),
      );
    } catch (e) {
      print('Test connection error: $e');
      return ApiResponse.error(
        ApiError(
          message: 'Connection test failed: ${e.toString()}',
          statusCode: 0,
        ),
      );
    }
  }

  // Update design package
  Future<ApiResponse<ProjectDetails>> updateDesignPackage(
    String accessToken,
    String projectUuid,
    String designPackage,
  ) async {
    try {
      final response = await http
          .put(
            Uri.parse('${ApiConfig.baseUrl}/api/dashboard/projects/$projectUuid/design-package'),
            headers: ApiConfig.getAuthHeaders(accessToken),
            body: jsonEncode({
              'designPackage': designPackage,
              'isDesignAgreementSigned': true,
            }),
          )
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final projectDetails = ProjectDetails.fromJson(jsonResponse);
        return ApiResponse.success(projectDetails);
      } else {
        final errorJson = jsonDecode(response.body);
        final error = ApiError.fromJson(errorJson);
        return ApiResponse.error(error);
      }
    } on SocketException {
      return ApiResponse.error(
        ApiError(
          message: 'No internet connection.',
          statusCode: 0,
        ),
      );
    } catch (e) {
      return ApiResponse.error(
        ApiError(
          message: 'Failed to update design package: ${e.toString()}',
          statusCode: 0,
        ),
      );
    }
  }
}
