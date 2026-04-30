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

/// One row of the customer-side per-project summary
/// `GET /api/customer/site-reports/summary`. Drives the SiteReportsScreen
/// empty-state hint when the current project has no reports but other
/// projects do (common when an admin files a report against the wrong
/// project from the portal dropdown).
class SiteReportSummaryRow {
  final int projectId;
  final String? projectName;
  final int count;

  const SiteReportSummaryRow({
    required this.projectId,
    this.projectName,
    required this.count,
  });

  factory SiteReportSummaryRow.fromJson(Map<String, dynamic> json) {
    return SiteReportSummaryRow(
      projectId: (json['projectId'] as num).toInt(),
      projectName: json['projectName'] as String?,
      count: (json['count'] as num).toInt(),
    );
  }
}

/// One activity carried by a site report — e.g. "RCC slab pour" with 8
/// labourers, "Plastering" with 4. Lets a single report capture multiple
/// concurrent work fronts on a project. The flat
/// [SiteReport.manpowerDeployed] is preserved as a roll-up for legacy
/// reports; new reports populate [SiteReport.activities] and [manpower]
/// is summed from there.
class SiteReportActivity {
  final int? id;
  final String name;
  final int? manpower;
  final String? equipment;
  final String? notes;

  const SiteReportActivity({
    this.id,
    required this.name,
    this.manpower,
    this.equipment,
    this.notes,
  });

  factory SiteReportActivity.fromJson(Map<String, dynamic> json) {
    return SiteReportActivity(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      manpower: json['manpower'] as int?,
      equipment: json['equipment'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'name': name,
        if (manpower != null) 'manpower': manpower,
        if (equipment != null && equipment!.isNotEmpty) 'equipment': equipment,
        if (notes != null && notes!.isNotEmpty) 'notes': notes,
      };
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
  final String? weather;
  final int? manpowerDeployed;
  final String? equipmentUsed;
  final String? workProgress;
  final double? latitude;
  final double? longitude;
  final double? distanceFromProject;
  final List<SiteReportActivity> activities;

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
    this.weather,
    this.manpowerDeployed,
    this.equipmentUsed,
    this.workProgress,
    this.latitude,
    this.longitude,
    this.distanceFromProject,
    this.activities = const [],
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
      // Surface the submitter so the customer can see "Site report by
      // <Engineer Name>" — the customer API DTO carries this as a flat
      // field. Falls back to nested entity shape for legacy responses.
      submittedByName: json['submittedByName'] as String?
          ?? (json['submittedBy'] is Map
              ? ('${json['submittedBy']['firstName'] ?? ''} '
                      '${json['submittedBy']['lastName'] ?? ''}')
                  .trim()
              : null),
      weather: json['weather'] as String?,
      manpowerDeployed: json['manpowerDeployed'] as int?,
      equipmentUsed: json['equipmentUsed'] as String?,
      workProgress: json['workProgress'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      distanceFromProject: (json['distanceFromProject'] as num?)?.toDouble(),
      activities: (json['activities'] as List? ?? const [])
          .map((a) => SiteReportActivity.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }

  String get formattedDate => DateFormat('dd MMM yyyy, hh:mm a').format(reportDate);
}
