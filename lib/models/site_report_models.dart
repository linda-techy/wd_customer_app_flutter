import '../config/api_config.dart';
import 'package:intl/intl.dart';

enum ReportType {
  dailyProgress,
  qualityCheck,
  safetyIncident,
  materialDelivery,
  siteVisitSummary,
  other;

  String get label {
    switch (this) {
      case ReportType.dailyProgress: return 'Daily Progress';
      case ReportType.qualityCheck: return 'Quality Check';
      case ReportType.safetyIncident: return 'Safety Incident';
      case ReportType.materialDelivery: return 'Material Delivery';
      case ReportType.siteVisitSummary: return 'Site Visit Summary';
      case ReportType.other: return 'Other';
    }
  }

  // Convert from backend SCREAMING_SNAKE_CASE to camelCase enum
  static ReportType fromJson(String? json) {
    if (json == null) return ReportType.dailyProgress;
    
    // Normalize string to match enum names
    const map = {
      'DAILY_PROGRESS': ReportType.dailyProgress,
      'QUALITY_CHECK': ReportType.qualityCheck,
      'SAFETY_INCIDENT': ReportType.safetyIncident,
      'MATERIAL_DELIVERY': ReportType.materialDelivery,
      'SITE_VISIT_SUMMARY': ReportType.siteVisitSummary,
      'OTHER': ReportType.other,
    };

    return map[json] ?? 
           ReportType.values.firstWhere(
             (e) => e.name == json,
             orElse: () => ReportType.other,
           );
  }
}

class SiteReportPhoto {
  final int? id;
  final String photoUrl;
  final String storagePath;
  final DateTime? createdAt;

  SiteReportPhoto({
    this.id,
    required this.photoUrl,
    required this.storagePath,
    this.createdAt,
  });

  /// Full URL for loading the photo. If photoUrl is already a full URL, return as-is.
  /// Otherwise, prepend the API base URL for relative paths.
  String get fullUrl {
    if (photoUrl.startsWith('http://') || photoUrl.startsWith('https://')) {
      return photoUrl;
    }
    // Prepend API base URL for relative paths
    return '${ApiConfig.baseUrl}$photoUrl';
  }

  factory SiteReportPhoto.fromJson(Map<String, dynamic> json) {
    return SiteReportPhoto(
      id: json['id'] as int?,
      photoUrl: json['photoUrl'] as String? ?? '',
      storagePath: json['storagePath'] as String? ?? '',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }
}

class SiteReport {
  final int? id;
  final int projectId;
  final String? projectName;
  final String title;
  final String? description;
  final DateTime reportDate;
  final String status;
  final ReportType reportType;
  final int? siteVisitId;
  final List<SiteReportPhoto> photos;
  final String? submittedByName;

  SiteReport({
    this.id,
    required this.projectId,
    this.projectName,
    required this.title,
    this.description,
    required this.reportDate,
    required this.status,
    required this.reportType,
    this.siteVisitId,
    this.photos = const [],
    this.submittedByName,
  });

  factory SiteReport.fromJson(Map<String, dynamic> json) {
    // Determine report date from multiple possible fields
    DateTime? parsedDate;
    if (json['reportDate'] != null) parsedDate = DateTime.tryParse(json['reportDate'].toString());
    parsedDate ??= json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null;

    return SiteReport(
      id: json['id'] as int?,
      // Map from flat DTO structure fields
      projectId: json['projectId'] as int? ?? 0, 
      projectName: json['projectName'] as String?,
      title: json['title'] as String? ?? 'Untitled Report',
      description: json['description'] as String?,
      reportDate: parsedDate ?? DateTime.now(),
      status: json['status'] as String? ?? 'SUBMITTED',
      reportType: ReportType.fromJson(json['reportType']),
      // SiteVisitId might not be in DTO, check if it's there or null
      siteVisitId: json['siteVisitId'] as int?,
      photos: (json['photos'] as List? ?? [])
          .map((p) => SiteReportPhoto.fromJson(p))
          .toList(),
      // submittedByName might not be in DTO, as it might be anonymized or not needed for customer
      submittedByName: null, 
    );
  }

  String get formattedDate => DateFormat('dd MMM yyyy, hh:mm a').format(reportDate);
}
