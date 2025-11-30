import '../models/api_models.dart';
import 'api_service.dart';
import 'auth_service.dart';

class DashboardService {
  static final ApiService _apiService = ApiService();

  // Get dashboard data
  static Future<ApiResponse<DashboardDto>> getDashboard() async {
    try {
      // Get access token
      final accessToken = await AuthService.getAccessToken();
      if (accessToken == null) {
        return ApiResponse.error(
          ApiError(
            message: 'No access token found. Please login again.',
            statusCode: 401,
          ),
        );
      }

      // Check if token is expired and refresh if needed
      final isExpired = await AuthService.isTokenExpired();
      if (isExpired) {
        final refreshSuccess = await AuthService.refreshAccessToken();
        if (!refreshSuccess) {
          return ApiResponse.error(
            ApiError(
              message: 'Session expired. Please login again.',
              statusCode: 401,
            ),
          );
        }
        // Get the new token
        final newToken = await AuthService.getAccessToken();
        if (newToken == null) {
          return ApiResponse.error(
            ApiError(
              message: 'Failed to get new access token.',
              statusCode: 401,
            ),
          );
        }
        return await _apiService.getDashboard(newToken);
      }

      return await _apiService.getDashboard(accessToken);
    } catch (e) {
      return ApiResponse.error(
        ApiError(
          message: 'Failed to get dashboard data: ${e.toString()}',
          statusCode: 0,
        ),
      );
    }
  }

  // Get user info for dashboard
  static Future<UserSummary?> getUserSummary() async {
    try {
      final userInfo = await AuthService.getUserInfo();
      if (userInfo == null) return null;

      return UserSummary(
        id: userInfo.id,
        email: userInfo.email,
        firstName: userInfo.firstName,
        lastName: userInfo.lastName,
        role: userInfo.role,
      );
    } catch (e) {
      print('Error getting user summary: $e');
      return null;
    }
  }

  // Get detailed project information
  static Future<ApiResponse<ProjectDetails>> getProjectDetails(String projectUuid) async {
    try {
      // Get access token
      final accessToken = await AuthService.getAccessToken();
      if (accessToken == null) {
        return ApiResponse.error(
          ApiError(
            message: 'No access token found. Please login again.',
            statusCode: 401,
          ),
        );
      }

      // Check if token is expired and refresh if needed
      final isExpired = await AuthService.isTokenExpired();
      if (isExpired) {
        final refreshSuccess = await AuthService.refreshAccessToken();
        if (!refreshSuccess) {
          return ApiResponse.error(
            ApiError(
              message: 'Session expired. Please login again.',
              statusCode: 401,
            ),
          );
        }
        // Get the new token
        final newToken = await AuthService.getAccessToken();
        if (newToken == null) {
          return ApiResponse.error(
            ApiError(
              message: 'Failed to get new access token.',
              statusCode: 401,
            ),
          );
        }
        return await _apiService.getProjectDetails(projectUuid, newToken);
      }

      return await _apiService.getProjectDetails(projectUuid, accessToken);
    } catch (e) {
      return ApiResponse.error(
        ApiError(
          message: 'Failed to get project details: ${e.toString()}',
          statusCode: 0,
        ),
      );
    }
  }

  // Update design package for a project
  static Future<ApiResponse<ProjectDetails>> updateDesignPackage(
    String projectUuid,
    String designPackage,
  ) async {
    try {
      // Get access token
      final accessToken = await AuthService.getAccessToken();
      if (accessToken == null) {
        return ApiResponse.error(
          ApiError(
            message: 'No access token found. Please login again.',
            statusCode: 401,
          ),
        );
      }

      // Check if token is expired and refresh if needed
      final isExpired = await AuthService.isTokenExpired();
      if (isExpired) {
        final refreshSuccess = await AuthService.refreshAccessToken();
        if (!refreshSuccess) {
          return ApiResponse.error(
            ApiError(
              message: 'Session expired. Please login again.',
              statusCode: 401,
            ),
          );
        }
        final newToken = await AuthService.getAccessToken();
        if (newToken == null) {
          return ApiResponse.error(
            ApiError(
              message: 'Failed to get new access token.',
              statusCode: 401,
            ),
          );
        }
        return await _apiService.updateDesignPackage(newToken, projectUuid, designPackage);
      }

      return await _apiService.updateDesignPackage(accessToken, projectUuid, designPackage);
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
