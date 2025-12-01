import 'dart:convert';

// Login Request Model
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

// User Info Model
class UserInfo {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;

  UserInfo({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
    };
  }

  String get fullName => '$firstName $lastName'.trim();
}

// Login Response Model
class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final UserInfo user;
  final List<String> permissions;
  final int projectCount;
  final String redirectUrl;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
    required this.permissions,
    required this.projectCount,
    required this.redirectUrl,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      tokenType: json['tokenType'] ?? 'Bearer',
      expiresIn: json['expiresIn'] ?? 0,
      user: UserInfo.fromJson(json['user'] ?? {}),
      permissions: List<String>.from(json['permissions'] ?? []),
      projectCount: json['projectCount'] ?? 0,
      redirectUrl: json['redirectUrl'] ?? '/dashboard',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'tokenType': tokenType,
      'expiresIn': expiresIn,
      'user': user.toJson(),
      'permissions': permissions,
      'projectCount': projectCount,
      'redirectUrl': redirectUrl,
    };
  }
}

// Refresh Token Request Model
class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest({
    required this.refreshToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'refreshToken': refreshToken,
    };
  }
}

// Refresh Token Response Model
class RefreshTokenResponse {
  final String accessToken;
  final String tokenType;
  final int expiresIn;

  RefreshTokenResponse({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponse(
      accessToken: json['accessToken'] ?? '',
      tokenType: json['tokenType'] ?? 'Bearer',
      expiresIn: json['expiresIn'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'tokenType': tokenType,
      'expiresIn': expiresIn,
    };
  }
}

// API Error Model
class ApiError {
  final String message;
  final int? statusCode;
  final String? error;

  ApiError({
    required this.message,
    this.statusCode,
    this.error,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      message: json['message'] ?? json['error'] ?? 'Unknown error',
      statusCode: json['status'] ?? json['statusCode'],
      error: json['error'],
    );
  }

  @override
  String toString() {
    return 'ApiError: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
  }
}

// Dashboard Models
class DashboardDto {
  final UserSummary user;
  final ProjectSummary projects;
  final List<RecentActivity> recentActivities;
  final QuickStats quickStats;

  DashboardDto({
    required this.user,
    required this.projects,
    required this.recentActivities,
    required this.quickStats,
  });

  factory DashboardDto.fromJson(Map<String, dynamic> json) {
    return DashboardDto(
      user: UserSummary.fromJson(json['user'] ?? {}),
      projects: ProjectSummary.fromJson(json['projects'] ?? {}),
      recentActivities: (json['recentActivities'] as List<dynamic>?)
              ?.map((e) => RecentActivity.fromJson(e))
              .toList() ??
          [],
      quickStats: QuickStats.fromJson(json['quickStats'] ?? {}),
    );
  }
}

class UserSummary {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;

  UserSummary({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
  });

  factory UserSummary.fromJson(Map<String, dynamic> json) {
    return UserSummary(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      role: json['role'] ?? '',
    );
  }

  String get fullName => '$firstName $lastName'.trim();
}

class ProjectSummary {
  final int totalProjects;
  final int activeProjects;
  final int completedProjects;
  final List<ProjectCard> recentProjects;

  ProjectSummary({
    required this.totalProjects,
    required this.activeProjects,
    required this.completedProjects,
    required this.recentProjects,
  });

  factory ProjectSummary.fromJson(Map<String, dynamic> json) {
    return ProjectSummary(
      totalProjects: json['totalProjects'] ?? 0,
      activeProjects: json['activeProjects'] ?? 0,
      completedProjects: json['completedProjects'] ?? 0,
      recentProjects: (json['recentProjects'] as List<dynamic>?)
              ?.map((e) => ProjectCard.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ProjectCard {
  final int id;
  final String? projectUuid;
  final String name;
  final String? code;
  final String? location;
  final String? startDate;
  final String? endDate;
  final String? status;
  final double progress;
  final String? projectPhase;
  final String? designPackage;
  final bool isDesignAgreementSigned;

  ProjectCard({
    required this.id,
    this.projectUuid,
    required this.name,
    this.code,
    this.location,
    this.startDate,
    this.endDate,
    this.status,
    required this.progress,
    this.projectPhase,
    this.designPackage,
    this.isDesignAgreementSigned = false,
  });

  factory ProjectCard.fromJson(Map<String, dynamic> json) {
    return ProjectCard(
      id: json['id'] ?? 0,
      projectUuid: json['projectUuid'],
      name: json['name'] ?? '',
  final String timestamp;
  final int projectId;
  final String projectName;

  RecentActivity({
    required this.type,
    required this.description,
    required this.timestamp,
    required this.projectId,
    required this.projectName,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      timestamp: json['timestamp'] ?? '',
      projectId: json['projectId'] ?? 0,
      projectName: json['projectName'] ?? '',
    );
  }
}

class QuickStats {
  final int totalBills;
  final int pendingBills;
  final int paidBills;
  final double totalAmount;
  final double pendingAmount;

  QuickStats({
    required this.totalBills,
    required this.pendingBills,
    required this.paidBills,
    required this.totalAmount,
    required this.pendingAmount,
  });

  factory QuickStats.fromJson(Map<String, dynamic> json) {
    return QuickStats(
      totalBills: json['totalBills'] ?? 0,
      pendingBills: json['pendingBills'] ?? 0,
      paidBills: json['paidBills'] ?? 0,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      pendingAmount: (json['pendingAmount'] ?? 0).toDouble(),
    );
  }
}

class ApiResponse<T> {
  final bool success;
  final T? data;
  final ApiError? error;
  final String? message;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.message,
  });

  factory ApiResponse.success(T data) {
    return ApiResponse(success: true, data: data);
  }

  factory ApiResponse.error(ApiError error) {
    return ApiResponse(success: false, error: error);
  }

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return ApiResponse(
      success: json['success'] ?? true,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      message: json['message'],
    );
  }
}

class ProjectDetails {
  final int id;
  final String? projectUuid;
  final String name;
  final String? code;
  final String? location;
  final String? startDate;
  final String? endDate;
  final String? status;
  final double progress;
  final String? phase;
  final String? designPackage;
  final bool isDesignAgreementSigned;
    this.startDate,
    this.endDate,
    this.status,
    required this.progress,
    this.phase,
    this.designPackage,
    this.isDesignAgreementSigned = false,
            .map((i) => ProjectDocumentSummary.fromJson(i))
            .toList()
        : [];

    return ProjectDetails(
      id: json['id'] ?? 0,
      projectUuid: json['projectUuid'],
      name: json['name'] ?? '',
      code: json['code'],
      location: json['location'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      status: json['status'],
      progress: (json['progress'] ?? 0).toDouble(),
      phase: json['projectPhase'],
      designPackage: json['designPackage'],
      isDesignAgreementSigned: json['isDesignAgreementSigned'] ?? false,
      state: json['state'],
  final int? fileSize;
  final String? fileType;
  final String? categoryName;
  final DateTime? uploadDate;
  final String? uploadedBy;

  ProjectDocumentSummary({
    required this.id,
    required this.filename,
    required this.downloadUrl,
    this.fileSize,
    this.fileType,
    this.categoryName,
    this.uploadDate,
    this.uploadedBy,
  });

  factory ProjectDocumentSummary.fromJson(Map<String, dynamic> json) {
    return ProjectDocumentSummary(
      id: json['id'] ?? 0,
      filename: json['filename'] ?? '',
      downloadUrl: json['downloadUrl'] ?? '',
      fileSize: json['fileSize'],
      fileType: json['fileType'],
      categoryName: json['categoryName'],
      uploadDate: json['uploadDate'] != null ? DateTime.parse(json['uploadDate']) : null,
      uploadedBy: json['uploadedBy'],
    );
  }
}

// Progress Data Model
class ProgressData {
  final double overallProgress;
  final int daysRemaining;
  final int totalDays;
  final int daysElapsed;
  final String progressStatus;
  final List<ProgressMilestone> milestones;

  ProgressData({
    required this.overallProgress,
    required this.daysRemaining,
    required this.totalDays,
    required this.daysElapsed,
    required this.progressStatus,
    required this.milestones,
  });

  factory ProgressData.fromJson(Map<String, dynamic> json) {
    return ProgressData(
      overallProgress: (json['overallProgress'] as num?)?.toDouble() ?? 0.0,
      daysRemaining: json['daysRemaining'] ?? 0,
      totalDays: json['totalDays'] ?? 0,
      daysElapsed: json['daysElapsed'] ?? 0,
      progressStatus: json['progressStatus'] ?? 'UNKNOWN',
      milestones: (json['milestones'] as List<dynamic>?)
              ?.map((e) => ProgressMilestone.fromJson(e))
              .toList() ??
          [],
    );
  }
}

// Progress Milestone Model
class ProgressMilestone {
  final String name;
  final double progressPercentage;
  final DateTime? targetDate;
  final DateTime? completedDate;
  final String status;

  ProgressMilestone({
    required this.name,
    required this.progressPercentage,
    this.targetDate,
    this.completedDate,
    required this.status,
  });

  factory ProgressMilestone.fromJson(Map<String, dynamic> json) {
    return ProgressMilestone(
      name: json['name'] ?? '',
      progressPercentage: (json['progressPercentage'] as num?)?.toDouble() ?? 0.0,
      targetDate: json['targetDate'] != null ? DateTime.parse(json['targetDate']) : null,
      completedDate: json['completedDate'] != null ? DateTime.parse(json['completedDate']) : null,
      status: json['status'] ?? 'PENDING',
    );
  }
}