import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/api_models.dart';
import '../models/team_contact.dart';
import 'auth_interceptor.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  ApiService._internal() {
    _dio.interceptors.add(AuthInterceptor(_dio));
  }

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: ApiConfig.connectionTimeout,
    receiveTimeout: ApiConfig.receiveTimeout,
  ));

  // Login method
  Future<ApiResponse<LoginResponse>> login(
      String email, String password) async {
    try {
      final loginRequest = LoginRequest(email: email, password: password);

      // Debug: Log request (no sensitive data)
      if (kDebugMode) {
        debugPrint('=== API LOGIN REQUEST ===');
        debugPrint('URL: ${ApiConfig.loginUrl}');
        debugPrint('========================');
      }

      final response = await _dio.post(
        ApiConfig.loginUrl,
        data: loginRequest.toJson(),
        options: Options(headers: ApiConfig.defaultHeaders),
      );

      // Debug: Log response status only
      if (kDebugMode) {
        debugPrint('=== API LOGIN RESPONSE ===');
        debugPrint('Status Code: ${response.statusCode}');
        debugPrint('=========================');
      }

      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(response.data);
        return ApiResponse.success(loginResponse);
      } else {
        final error = ApiError.fromJson(response.data);
        return ApiResponse.error(error);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return ApiResponse.error(
          ApiError(
            message:
                'Cannot reach the server. Please check your network connection.',
            statusCode: 0,
          ),
        );
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return ApiResponse.error(
          ApiError(
            message:
                'Request timed out while contacting the server. Please try again.',
            statusCode: 0,
          ),
        );
      }
      final message =
          e.response?.data?['message'] ?? 'An unexpected error occurred';
      final statusCode = e.response?.statusCode ?? 0;
      return ApiResponse.error(
          ApiError(message: message.toString(), statusCode: statusCode));
    } catch (e) {
      return ApiResponse.error(
        ApiError(
          message: 'An unexpected error occurred: ${e.toString()}',
          statusCode: 0,
        ),
      );
    }
  }

  // Forgot password method
  Future<ApiResponse<Map<String, dynamic>>> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        ApiConfig.forgotPasswordUrl,
        data: {'email': email},
        options: Options(headers: ApiConfig.defaultHeaders),
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(response.data as Map<String, dynamic>);
      } else {
        String errorMessage = 'Failed to send reset code';
        final data = response.data;
        if (data is Map) {
          errorMessage =
              (data['message'] ?? data['error'] ?? errorMessage).toString();
        }
        return ApiResponse.error(
          ApiError(
              message: errorMessage, statusCode: response.statusCode ?? 0),
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return ApiResponse.error(
          ApiError(
            message:
                'Cannot connect to the server. Please check if the API is running.',
            statusCode: 0,
          ),
        );
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return ApiResponse.error(
          ApiError(
            message:
                'Request timed out. We could not submit your reset link request.',
            statusCode: 0,
          ),
        );
      }
      final message = e.response?.data?['message'] ?? 'Failed to send reset code';
      return ApiResponse.error(
          ApiError(message: message.toString(), statusCode: e.response?.statusCode ?? 0));
    } catch (e) {
      return ApiResponse.error(
        ApiError(
          message:
              'An unexpected error occurred while sending reset link.',
          statusCode: 0,
        ),
      );
    }
  }

  // Reset password method
  Future<ApiResponse<Map<String, dynamic>>> resetPassword(
      String email, String resetCode, String newPassword) async {
    try {
      final response = await _dio.post(
        ApiConfig.resetPasswordUrl,
        data: {
          'email': email,
          'resetCode': resetCode,
          'newPassword': newPassword,
        },
        options: Options(headers: ApiConfig.defaultHeaders),
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(response.data as Map<String, dynamic>);
      } else {
        String errorMessage = 'Failed to reset password';
        final data = response.data;
        if (data is Map) {
          errorMessage =
              (data['message'] ?? data['error'] ?? errorMessage).toString();
        }
        return ApiResponse.error(
          ApiError(
              message: errorMessage, statusCode: response.statusCode ?? 0),
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return ApiResponse.error(
          ApiError(
            message:
                'Cannot connect to the server. Please check if the API is running.',
            statusCode: 0,
          ),
        );
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return ApiResponse.error(
          ApiError(
            message: 'Request timed out. Please retry resetting your password.',
            statusCode: 0,
          ),
        );
      }
      final message =
          e.response?.data?['message'] ?? 'Failed to reset password';
      return ApiResponse.error(
          ApiError(message: message.toString(), statusCode: e.response?.statusCode ?? 0));
    } catch (e) {
      return ApiResponse.error(
        ApiError(
          message: 'An unexpected error occurred while resetting password.',
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

      final response = await _dio.post(
        ApiConfig.refreshTokenUrl,
        data: refreshRequest.toJson(),
        options: Options(headers: ApiConfig.defaultHeaders),
      );

      if (response.statusCode == 200) {
        final refreshResponse = RefreshTokenResponse.fromJson(response.data);
        return ApiResponse.success(refreshResponse);
      } else {
        final error = ApiError.fromJson(response.data);
        return ApiResponse.error(error);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return ApiResponse.error(
          ApiError(
            message: 'No internet connection.',
            statusCode: 0,
          ),
        );
      }
      final message =
          e.response?.data?['message'] ?? 'Failed to refresh token';
      return ApiResponse.error(
        ApiError(
          message: 'Failed to refresh token: ${message.toString()}',
          statusCode: e.response?.statusCode ?? 0,
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

      final response = await _dio.post(
        ApiConfig.logoutUrl,
        data: refreshRequest.toJson(),
        options: Options(headers: ApiConfig.getAuthHeaders(accessToken)),
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(null);
      } else {
        final error = ApiError.fromJson(response.data);
        return ApiResponse.error(error);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return ApiResponse.error(
          ApiError(
            message: 'No internet connection.',
            statusCode: 0,
          ),
        );
      }
      final message = e.response?.data?['message'] ?? 'Failed to logout';
      return ApiResponse.error(
        ApiError(
          message: 'Failed to logout: ${message.toString()}',
          statusCode: e.response?.statusCode ?? 0,
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
      final response = await _dio.get(
        ApiConfig.getCurrentUserUrl,
        options: Options(headers: ApiConfig.getAuthHeaders(accessToken)),
      );

      if (response.statusCode == 200) {
        final userInfo = UserInfo.fromJson(response.data);
        return ApiResponse.success(userInfo);
      } else {
        final error = ApiError.fromJson(response.data);
        return ApiResponse.error(error);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return ApiResponse.error(
          ApiError(
            message: 'No internet connection.',
            statusCode: 0,
          ),
        );
      }
      final message = e.response?.data?['message'] ?? 'Failed to get user info';
      return ApiResponse.error(
        ApiError(
          message: 'Failed to get user info: ${message.toString()}',
          statusCode: e.response?.statusCode ?? 0,
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
      if (kDebugMode) {
        debugPrint('=== API DASHBOARD REQUEST ===');
        debugPrint('URL: ${ApiConfig.dashboardUrl}');
        debugPrint('============================');
      }

      final response = await _dio.get(
        ApiConfig.dashboardUrl,
        options: Options(headers: ApiConfig.getAuthHeaders(accessToken)),
      );

      if (kDebugMode) {
        debugPrint('=== API DASHBOARD RESPONSE ===');
        debugPrint('Status Code: ${response.statusCode}');
        debugPrint('Response Body: ${response.data}');
        debugPrint('=============================');
      }

      if (response.statusCode == 200) {
        final dashboardData = DashboardDto.fromJson(response.data);
        return ApiResponse.success(dashboardData);
      } else {
        final error = ApiError.fromJson(response.data);
        return ApiResponse.error(error);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return ApiResponse.error(
          ApiError(
            message: 'No internet connection.',
            statusCode: 0,
          ),
        );
      }
      final message =
          e.response?.data?['message'] ?? 'Failed to get dashboard data';
      return ApiResponse.error(
        ApiError(
          message: 'Failed to get dashboard data: ${message.toString()}',
          statusCode: e.response?.statusCode ?? 0,
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
  Future<ApiResponse<ProjectDetails>> getProjectDetails(
      String projectUuid, String accessToken) async {
    try {
      final url =
          '${ApiConfig.baseUrl}/api/dashboard/projects/$projectUuid';

      if (kDebugMode) {
        debugPrint('=== API PROJECT DETAILS REQUEST ===');
        debugPrint('URL: $url');
        debugPrint('Project UUID: $projectUuid');
        debugPrint('==================================');
      }

      final response = await _dio.get(
        url,
        options: Options(headers: ApiConfig.getAuthHeaders(accessToken)),
      );

      if (kDebugMode) {
        debugPrint('=== API PROJECT DETAILS RESPONSE ===');
        debugPrint('Status Code: ${response.statusCode}');
        debugPrint('Response Body: ${response.data}');
        debugPrint('===================================');
      }

      if (response.statusCode == 200) {
        final projectDetails = ProjectDetails.fromJson(response.data);
        return ApiResponse.success(projectDetails);
      } else {
        final error = ApiError.fromJson(response.data);
        return ApiResponse.error(error);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return ApiResponse.error(
          ApiError(
            message: 'No internet connection.',
            statusCode: 0,
          ),
        );
      }
      final message =
          e.response?.data?['message'] ?? 'Failed to get project details';
      return ApiResponse.error(
        ApiError(
          message: 'Failed to get project details: ${message.toString()}',
          statusCode: e.response?.statusCode ?? 0,
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

  /// Fetch construction phase timeline for a project.
  Future<ApiResponse<List<ProjectPhaseModel>>> getProjectPhases(
      String projectUuid, String accessToken) async {
    try {
      final url =
          '${ApiConfig.baseUrl}/api/dashboard/projects/$projectUuid/phases';

      final response = await _dio.get(
        url,
        options: Options(headers: ApiConfig.getAuthHeaders(accessToken)),
      );

      if (response.statusCode == 200) {
        final list = response.data as List<dynamic>?;
        final phases = (list ?? [])
            .map((e) =>
                ProjectPhaseModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiResponse.success(phases);
      } else {
        final data = response.data;
        return ApiResponse.error(data != null
            ? ApiError.fromJson(data as Map<String, dynamic>)
            : ApiError(
                message:
                    'Failed to load phases (${response.statusCode})',
                statusCode: response.statusCode ?? 0));
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return ApiResponse.error(
            ApiError(message: 'No internet connection.', statusCode: 0));
      }
      return ApiResponse.error(ApiError(
          message:
              'Failed to get project phases: ${e.response?.data?['message'] ?? e.toString()}',
          statusCode: e.response?.statusCode ?? 0));
    } catch (e) {
      return ApiResponse.error(ApiError(
          message: 'Failed to get project phases: ${e.toString()}',
          statusCode: 0));
    }
  }

  /// Server-side project search. Empty/null [query] returns recent projects (backend default).
  Future<ApiResponse<List<ProjectCard>>> searchProjects(String accessToken,
      [String? query]) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (query != null && query.trim().isNotEmpty) {
        queryParameters['q'] = query.trim();
      }

      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/dashboard/search-projects',
        queryParameters:
            queryParameters.isNotEmpty ? queryParameters : null,
        options: Options(headers: ApiConfig.getAuthHeaders(accessToken)),
      );

      if (response.statusCode == 200) {
        final list = response.data as List<dynamic>?;
        final projects = (list ?? [])
            .map((e) =>
                ProjectCard.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiResponse.success(projects);
      } else {
        final data = response.data;
        final error = data != null
            ? ApiError.fromJson(data as Map<String, dynamic>)
            : ApiError(
                message: 'Search failed (${response.statusCode})',
                statusCode: response.statusCode ?? 0,
              );
        return ApiResponse.error(error);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return ApiResponse.error(
          ApiError(message: 'No internet connection.', statusCode: 0),
        );
      }
      final message =
          e.response?.data?['message'] ?? 'Failed to search projects';
      return ApiResponse.error(
        ApiError(
          message: 'Failed to search projects: ${message.toString()}',
          statusCode: e.response?.statusCode ?? 0,
        ),
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
      if (kDebugMode) {
        debugPrint('Testing API connection to: ${ApiConfig.testUrl}');
      }

      final response = await _dio.get(
        ApiConfig.testUrl,
        options: Options(headers: ApiConfig.defaultHeaders),
      );

      if (kDebugMode) {
        debugPrint('Test response status: ${response.statusCode}');
        debugPrint('Test response body: ${response.data}');
      }

      if (response.statusCode == 200) {
        return ApiResponse.success(response.data.toString());
      } else {
        return ApiResponse.error(
          ApiError(
            message:
                'Server returned status code: ${response.statusCode}',
            statusCode: response.statusCode ?? 0,
          ),
        );
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('DioException: Cannot connect to server: $e');
      }
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return ApiResponse.error(
          ApiError(
            message:
                'Cannot connect to server. Please check if the API is running on ${ApiConfig.baseUrl}',
            statusCode: 0,
          ),
        );
      }
      return ApiResponse.error(
        ApiError(
          message:
              'Connection test failed: ${e.response?.data?['message'] ?? e.toString()}',
          statusCode: e.response?.statusCode ?? 0,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Test connection error: $e');
      }
      return ApiResponse.error(
        ApiError(
          message: 'Connection test failed: ${e.toString()}',
          statusCode: 0,
        ),
      );
    }
  }

  /// Fetch the team contacts visible to the customer for a project.
  Future<ApiResponse<List<TeamContact>>> getProjectTeam(
      String projectUuid, String accessToken) async {
    try {
      final url =
          '${ApiConfig.baseUrl}/api/dashboard/projects/$projectUuid/team';

      final response = await _dio.get(
        url,
        options: Options(headers: ApiConfig.getAuthHeaders(accessToken)),
      );

      if (response.statusCode == 200) {
        final list = response.data as List<dynamic>?;
        final team = (list ?? [])
            .map((e) => TeamContact.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiResponse.success(team);
      } else {
        final data = response.data;
        return ApiResponse.error(data != null
            ? ApiError.fromJson(data as Map<String, dynamic>)
            : ApiError(
                message: 'Failed to load team (${response.statusCode})',
                statusCode: response.statusCode ?? 0));
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return ApiResponse.error(
            ApiError(message: 'No internet connection.', statusCode: 0));
      }
      return ApiResponse.error(ApiError(
          message:
              'Failed to get project team: ${e.response?.data?['message'] ?? e.toString()}',
          statusCode: e.response?.statusCode ?? 0));
    } catch (e) {
      return ApiResponse.error(ApiError(
          message: 'Failed to get project team: ${e.toString()}',
          statusCode: 0));
    }
  }

  // Update design package
  Future<ApiResponse<ProjectDetails>> updateDesignPackage(
    String accessToken,
    String projectUuid,
    String designPackage,
  ) async {
    try {
      final response = await _dio.put(
        '${ApiConfig.baseUrl}/api/dashboard/projects/$projectUuid/design-package',
        data: {
          'designPackage': designPackage,
          'isDesignAgreementSigned': true,
        },
        options: Options(headers: ApiConfig.getAuthHeaders(accessToken)),
      );

      if (response.statusCode == 200) {
        final projectDetails = ProjectDetails.fromJson(response.data);
        return ApiResponse.success(projectDetails);
      } else {
        final error = ApiError.fromJson(response.data);
        return ApiResponse.error(error);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return ApiResponse.error(
          ApiError(
            message: 'No internet connection.',
            statusCode: 0,
          ),
        );
      }
      final message =
          e.response?.data?['message'] ?? 'Failed to update design package';
      return ApiResponse.error(
        ApiError(
          message: 'Failed to update design package: ${message.toString()}',
          statusCode: e.response?.statusCode ?? 0,
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
