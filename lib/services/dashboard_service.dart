import 'dart:async';

import 'package:flutter/foundation.dart';
import '../models/api_models.dart';
import '../models/team_contact.dart';
import '../models/timeline_item.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'session_manager.dart';

class DashboardService {
  static final ApiService _apiService = ApiService();

  /// No usable session before a request could even be sent (token absent, or
  /// a refresh failed). Trigger the global redirect to login — otherwise the
  /// calling screen renders this error with a "Retry" button that can never
  /// succeed, stranding the customer. Also returns a jargon-free error (no
  /// "token") for any UI that paints it in the frame before the redirect lands.
  static ApiResponse<T> _sessionExpired<T>() {
    unawaited(SessionManager.expireSession(
        reason: 'DashboardService: no valid session'));
    return ApiResponse.error(
      ApiError(message: SessionManager.sessionExpiredMessage, statusCode: 401),
    );
  }

  // Get dashboard data
  static Future<ApiResponse<DashboardDto>> getDashboard() async {
    try {
      // Get access token
      final accessToken = await AuthService.getAccessToken();
      if (accessToken == null) {
        return _sessionExpired();
      }

      // Check if token is expired and refresh if needed
      final isExpired = await AuthService.isTokenExpired();
      if (isExpired) {
        final refreshSuccess = await AuthService.refreshAccessToken();
        if (!refreshSuccess) {
          return _sessionExpired();
        }
        // Get the new token
        final newToken = await AuthService.getAccessToken();
        if (newToken == null) {
          return _sessionExpired();
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

  /// Server-side project search. [query] null or empty returns recent projects.
  static Future<ApiResponse<List<ProjectCard>>> searchProjects([String? query]) async {
    try {
      final accessToken = await AuthService.getAccessToken();
      if (accessToken == null) {
        return _sessionExpired();
      }
      if (await AuthService.isTokenExpired()) {
        final refreshed = await AuthService.refreshAccessToken();
        if (!refreshed) {
          return _sessionExpired();
        }
        final newToken = await AuthService.getAccessToken();
        if (newToken == null) {
          return _sessionExpired();
        }
        return await _apiService.searchProjects(newToken, query);
      }
      return await _apiService.searchProjects(accessToken, query);
    } catch (e) {
      return ApiResponse.error(
        ApiError(
          message: 'Failed to search projects: ${e.toString()}',
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
      debugPrint('Error getting user summary: $e');
      return null;
    }
  }

  // Get detailed project information
  static Future<ApiResponse<ProjectDetails>> getProjectDetails(String projectUuid) async {
    try {
      // Get access token
      final accessToken = await AuthService.getAccessToken();
      if (accessToken == null) {
        return _sessionExpired();
      }

      // Check if token is expired and refresh if needed
      final isExpired = await AuthService.isTokenExpired();
      if (isExpired) {
        final refreshSuccess = await AuthService.refreshAccessToken();
        if (!refreshSuccess) {
          return _sessionExpired();
        }
        // Get the new token
        final newToken = await AuthService.getAccessToken();
        if (newToken == null) {
          return _sessionExpired();
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

  /// Fetch the ordered construction phase timeline for a project.
  /// Returns phases sorted by displayOrder. Used to render MilestoneTimeline.
  static Future<ApiResponse<List<ProjectPhaseModel>>> getProjectPhases(
      String projectUuid) async {
    try {
      final accessToken = await AuthService.getAccessToken();
      if (accessToken == null) {
        return _sessionExpired();
      }
      if (await AuthService.isTokenExpired()) {
        final refreshed = await AuthService.refreshAccessToken();
        if (!refreshed) {
          return _sessionExpired();
        }
        final newToken = await AuthService.getAccessToken();
        if (newToken == null) {
          return _sessionExpired();
        }
        return await _apiService.getProjectPhases(projectUuid, newToken);
      }
      return await _apiService.getProjectPhases(projectUuid, accessToken);
    } catch (e) {
      return ApiResponse.error(
          ApiError(message: 'Failed to get project phases: ${e.toString()}', statusCode: 0));
    }
  }

  /// Fetch the team contacts visible to the customer for a project.
  static Future<ApiResponse<List<TeamContact>>> getProjectTeam(
      String projectUuid) async {
    try {
      final accessToken = await AuthService.getAccessToken();
      if (accessToken == null) {
        return _sessionExpired();
      }
      if (await AuthService.isTokenExpired()) {
        final refreshed = await AuthService.refreshAccessToken();
        if (!refreshed) {
          return _sessionExpired();
        }
        final newToken = await AuthService.getAccessToken();
        if (newToken == null) {
          return _sessionExpired();
        }
        return await _apiService.getProjectTeam(projectUuid, newToken);
      }
      return await _apiService.getProjectTeam(projectUuid, accessToken);
    } catch (e) {
      return ApiResponse.error(
          ApiError(message: 'Failed to get project team: ${e.toString()}', statusCode: 0));
    }
  }

  /// Fetch paginated timeline tasks for a project bucket (week / upcoming / completed).
  static Future<ApiResponse<TimelinePage>> getTimeline(
      String projectUuid, String bucket,
      {int page = 0, int size = 20}) async {
    try {
      final accessToken = await AuthService.getAccessToken();
      if (accessToken == null) {
        return _sessionExpired();
      }
      if (await AuthService.isTokenExpired()) {
        final refreshed = await AuthService.refreshAccessToken();
        if (!refreshed) {
          return _sessionExpired();
        }
        final newToken = await AuthService.getAccessToken();
        if (newToken == null) {
          return _sessionExpired();
        }
        return await _apiService.getTimeline(projectUuid, bucket, newToken,
            page: page, size: size);
      }
      return await _apiService.getTimeline(projectUuid, bucket, accessToken,
          page: page, size: size);
    } catch (e) {
      return ApiResponse.error(
          ApiError(message: 'Failed to get timeline: ${e.toString()}', statusCode: 0));
    }
  }

  /// Fetch timeline summary counts + project progress for a project.
  static Future<ApiResponse<TimelineSummary>> getTimelineSummary(
      String projectUuid) async {
    try {
      final accessToken = await AuthService.getAccessToken();
      if (accessToken == null) {
        return _sessionExpired();
      }
      if (await AuthService.isTokenExpired()) {
        final refreshed = await AuthService.refreshAccessToken();
        if (!refreshed) {
          return _sessionExpired();
        }
        final newToken = await AuthService.getAccessToken();
        if (newToken == null) {
          return _sessionExpired();
        }
        return await _apiService.getTimelineSummary(projectUuid, newToken);
      }
      return await _apiService.getTimelineSummary(projectUuid, accessToken);
    } catch (e) {
      return ApiResponse.error(
          ApiError(message: 'Failed to get timeline summary: ${e.toString()}', statusCode: 0));
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
        return _sessionExpired();
      }

      // Check if token is expired and refresh if needed
      final isExpired = await AuthService.isTokenExpired();
      if (isExpired) {
        final refreshSuccess = await AuthService.refreshAccessToken();
        if (!refreshSuccess) {
          return _sessionExpired();
        }
        final newToken = await AuthService.getAccessToken();
        if (newToken == null) {
          return _sessionExpired();
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
