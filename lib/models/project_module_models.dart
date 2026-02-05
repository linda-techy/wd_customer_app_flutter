// Project Module Models for all 11 modules

class DocumentCategory {
  final int id;
  final String name;
  final String? description;
  final int displayOrder;

  DocumentCategory({
    required this.id,
    required this.name,
    this.description,
    required this.displayOrder,
  });

  factory DocumentCategory.fromJson(Map<String, dynamic> json) {
    return DocumentCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      displayOrder: json['displayOrder'] ?? 0,
    );
  }
}

class ProjectDocument {
  final int id;
  final int projectId;
  final int categoryId;
  final String categoryName;
  final String filename;
  final String filePath;
  final String downloadUrl;  // Full URL for viewing/downloading
  final int? fileSize;
  final String? fileType;
  final int uploadedById;
  final String uploadedByName;
  final DateTime uploadDate;
  final String? description;
  final int version;
  final bool isActive;

  ProjectDocument({
    required this.id,
    required this.projectId,
    required this.categoryId,
    required this.categoryName,
    required this.filename,
    required this.filePath,
    required this.downloadUrl,
    this.fileSize,
    this.fileType,
    required this.uploadedById,
    required this.uploadedByName,
    required this.uploadDate,
    this.description,
    required this.version,
    required this.isActive,
  });

  factory ProjectDocument.fromJson(Map<String, dynamic> json) {
    return ProjectDocument(
      id: json['id'],
      projectId: json['projectId'],
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      filename: json['filename'],
      filePath: json['filePath'],
      downloadUrl: json['downloadUrl'] ?? '',
      fileSize: json['fileSize'],
      fileType: json['fileType'],
      uploadedById: json['uploadedById'],
      uploadedByName: json['uploadedByName'],
      uploadDate: DateTime.parse(json['uploadDate']),
      description: json['description'],
      version: json['version'],
      isActive: json['isActive'] ?? true,
    );
  }
}

class QualityCheck {
  final int id;
  final int projectId;
  final String title;
  final String? description;
  final String? sopReference;
  final String status;
  final String priority;
  final int? assignedToId;
  final String? assignedToName;
  final int createdById;
  final String createdByName;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final int? resolvedById;
  final String? resolvedByName;
  final String? resolutionNotes;

  QualityCheck({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    this.sopReference,
    required this.status,
    required this.priority,
    this.assignedToId,
    this.assignedToName,
    required this.createdById,
    required this.createdByName,
    required this.createdAt,
    this.resolvedAt,
    this.resolvedById,
    this.resolvedByName,
    this.resolutionNotes,
  });

  factory QualityCheck.fromJson(Map<String, dynamic> json) {
    return QualityCheck(
      id: json['id'],
      projectId: json['projectId'],
      title: json['title'],
      description: json['description'],
      sopReference: json['sopReference'],
      status: json['status'],
      priority: json['priority'],
      assignedToId: json['assignedToId'],
      assignedToName: json['assignedToName'],
      createdById: json['createdById'],
      createdByName: json['createdByName'],
      createdAt: DateTime.parse(json['createdAt']),
      resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt']) : null,
      resolvedById: json['resolvedById'],
      resolvedByName: json['resolvedByName'],
      resolutionNotes: json['resolutionNotes'],
    );
  }
}

class ActivityFeed {
  final int id;
  final int projectId;
  final String activityTypeName;
  final String activityTypeIcon;
  final String activityTypeColor;
  final String title;
  final String? description;
  final int? referenceId;
  final String? referenceType;
  final int createdById;
  final String createdByName;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  ActivityFeed({
    required this.id,
    required this.projectId,
    required this.activityTypeName,
    required this.activityTypeIcon,
    required this.activityTypeColor,
    required this.title,
    this.description,
    this.referenceId,
    this.referenceType,
    required this.createdById,
    required this.createdByName,
    required this.createdAt,
    this.metadata,
  });

  factory ActivityFeed.fromJson(Map<String, dynamic> json) {
    return ActivityFeed(
      id: json['id'],
      projectId: json['projectId'],
      activityTypeName: json['activityTypeName'],
      activityTypeIcon: json['activityTypeIcon'],
      activityTypeColor: json['activityTypeColor'],
      title: json['title'],
      description: json['description'],
      referenceId: json['referenceId'],
      referenceType: json['referenceType'],
      createdById: json['createdById'],
      createdByName: json['createdByName'],
      createdAt: DateTime.parse(json['createdAt']),
      metadata: json['metadata'],
    );
  }
}

class GalleryImage {
  final int id;
  final int projectId;
  final String imagePath;
  final String? thumbnailPath;
  final String? caption;
  final DateTime takenDate;
  final int uploadedById;
  final String uploadedByName;
  final DateTime uploadedAt;
  final int? siteReportId;
  final String? locationTag;
  final List<String>? tags;

  GalleryImage({
    required this.id,
    required this.projectId,
    required this.imagePath,
    this.thumbnailPath,
    this.caption,
    required this.takenDate,
    required this.uploadedById,
    required this.uploadedByName,
    required this.uploadedAt,
    this.siteReportId,
    this.locationTag,
    this.tags,
  });

  factory GalleryImage.fromJson(Map<String, dynamic> json) {
    return GalleryImage(
      id: json['id'],
      projectId: json['projectId'],
      imagePath: json['imagePath'],
      thumbnailPath: json['thumbnailPath'],
      caption: json['caption'],
      takenDate: DateTime.parse(json['takenDate']),
      uploadedById: json['uploadedById'],
      uploadedByName: json['uploadedByName'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
      siteReportId: json['siteReportId'],
      locationTag: json['locationTag'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
    );
  }
}

class Observation {
  final int id;
  final int projectId;
  final String title;
  final String description;
  final int reportedById;
  final String reportedByName;
  final int? reportedByRoleId;
  final String? reportedByRoleName;
  final DateTime reportedDate;
  final String status;
  final String priority;
  final String? location;
  final String? imagePath;
  final DateTime? resolvedDate;
  final int? resolvedById;
  final String? resolvedByName;
  final String? resolutionNotes;

  Observation({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.reportedById,
    required this.reportedByName,
    this.reportedByRoleId,
    this.reportedByRoleName,
    required this.reportedDate,
    required this.status,
    required this.priority,
    this.location,
    this.imagePath,
    this.resolvedDate,
    this.resolvedById,
    this.resolvedByName,
    this.resolutionNotes,
  });

  factory Observation.fromJson(Map<String, dynamic> json) {
    return Observation(
      id: json['id'],
      projectId: json['projectId'],
      title: json['title'],
      description: json['description'],
      reportedById: json['reportedById'],
      reportedByName: json['reportedByName'],
      reportedByRoleId: json['reportedByRoleId'],
      reportedByRoleName: json['reportedByRoleName'],
      reportedDate: DateTime.parse(json['reportedDate']),
      status: json['status'],
      priority: json['priority'],
      location: json['location'],
      imagePath: json['imagePath'],
      resolvedDate: json['resolvedDate'] != null ? DateTime.parse(json['resolvedDate']) : null,
      resolvedById: json['resolvedById'],
      resolvedByName: json['resolvedByName'],
      resolutionNotes: json['resolutionNotes'],
    );
  }
}

class ProjectQuery {
  final int id;
  final int projectId;
  final String title;
  final String description;
  final int raisedById;
  final String raisedByName;
  final int? raisedByRoleId;
  final String? raisedByRoleName;
  final DateTime raisedDate;
  final String status;
  final String priority;
  final String? category;
  final int? assignedToId;
  final String? assignedToName;
  final DateTime? resolvedDate;
  final int? resolvedById;
  final String? resolvedByName;
  final String? resolution;

  ProjectQuery({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.raisedById,
    required this.raisedByName,
    this.raisedByRoleId,
    this.raisedByRoleName,
    required this.raisedDate,
    required this.status,
    required this.priority,
    this.category,
    this.assignedToId,
    this.assignedToName,
    this.resolvedDate,
    this.resolvedById,
    this.resolvedByName,
    this.resolution,
  });

  factory ProjectQuery.fromJson(Map<String, dynamic> json) {
    return ProjectQuery(
      id: json['id'],
      projectId: json['projectId'],
      title: json['title'],
      description: json['description'],
      raisedById: json['raisedById'],
      raisedByName: json['raisedByName'],
      raisedByRoleId: json['raisedByRoleId'],
      raisedByRoleName: json['raisedByRoleName'],
      raisedDate: DateTime.parse(json['raisedDate']),
      status: json['status'],
      priority: json['priority'],
      category: json['category'],
      assignedToId: json['assignedToId'],
      assignedToName: json['assignedToName'],
      resolvedDate: json['resolvedDate'] != null ? DateTime.parse(json['resolvedDate']) : null,
      resolvedById: json['resolvedById'],
      resolvedByName: json['resolvedByName'],
      resolution: json['resolution'],
    );
  }
}

class CctvCamera {
  final int id;
  final int projectId;
  final String cameraName;
  final String? location;
  final String? streamUrl;
  final String? snapshotUrl;
  final bool isInstalled;
  final bool isActive;
  final DateTime? installationDate;
  final DateTime? lastActive;
  final String? cameraType;
  final String? resolution;
  final String? notes;

  CctvCamera({
    required this.id,
    required this.projectId,
    required this.cameraName,
    this.location,
    this.streamUrl,
    this.snapshotUrl,
    required this.isInstalled,
    required this.isActive,
    this.installationDate,
    this.lastActive,
    this.cameraType,
    this.resolution,
    this.notes,
  });

  factory CctvCamera.fromJson(Map<String, dynamic> json) {
    return CctvCamera(
      id: json['id'],
      projectId: json['projectId'],
      cameraName: json['cameraName'],
      location: json['location'],
      streamUrl: json['streamUrl'],
      snapshotUrl: json['snapshotUrl'],
      isInstalled: json['isInstalled'] ?? false,
      isActive: json['isActive'] ?? true,
      installationDate: json['installationDate'] != null ? DateTime.parse(json['installationDate']) : null,
      lastActive: json['lastActive'] != null ? DateTime.parse(json['lastActive']) : null,
      cameraType: json['cameraType'],
      resolution: json['resolution'],
      notes: json['notes'],
    );
  }
}

class View360 {
  final int id;
  final int projectId;
  final String title;
  final String? description;
  final String viewUrl;
  final String? thumbnailUrl;
  final DateTime? captureDate;
  final String? location;
  final int uploadedById;
  final String uploadedByName;
  final DateTime uploadedAt;
  final bool isActive;
  final int viewCount;

  View360({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    required this.viewUrl,
    this.thumbnailUrl,
    this.captureDate,
    this.location,
    required this.uploadedById,
    required this.uploadedByName,
    required this.uploadedAt,
    required this.isActive,
    required this.viewCount,
  });

  factory View360.fromJson(Map<String, dynamic> json) {
    return View360(
      id: json['id'],
      projectId: json['projectId'],
      title: json['title'],
      description: json['description'],
      viewUrl: json['viewUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      captureDate: json['captureDate'] != null ? DateTime.parse(json['captureDate']) : null,
      location: json['location'],
      uploadedById: json['uploadedById'],
      uploadedByName: json['uploadedByName'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
      isActive: json['isActive'] ?? true,
      viewCount: json['viewCount'] ?? 0,
    );
  }
}

class SiteVisit {
  final int id;
  final int projectId;
  final int visitorId;
  final String visitorName;
  final int? visitorRoleId;
  final String? visitorRoleName;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final String? purpose;
  final String? notes;
  final String? findings;
  final String? location;
  final String? weatherConditions;
  final List<String>? attendees;

  SiteVisit({
    required this.id,
    required this.projectId,
    required this.visitorId,
    required this.visitorName,
    this.visitorRoleId,
    this.visitorRoleName,
    required this.checkInTime,
    this.checkOutTime,
    this.purpose,
    this.notes,
    this.findings,
    this.location,
    this.weatherConditions,
    this.attendees,
  });

  factory SiteVisit.fromJson(Map<String, dynamic> json) {
    return SiteVisit(
      id: json['id'],
      projectId: json['projectId'],
      visitorId: json['visitorId'],
      visitorName: json['visitorName'],
      visitorRoleId: json['visitorRoleId'],
      visitorRoleName: json['visitorRoleName'],
      checkInTime: DateTime.parse(json['checkInTime']),
      checkOutTime: json['checkOutTime'] != null ? DateTime.parse(json['checkOutTime']) : null,
      purpose: json['purpose'],
      notes: json['notes'],
      findings: json['findings'],
      location: json['location'],
      weatherConditions: json['weatherConditions'],
      attendees: json['attendees'] != null ? List<String>.from(json['attendees']) : null,
    );
  }
}

class FeedbackForm {
  final int id;
  final int projectId;
  final String title;
  final String? description;
  final String? formType;
  final int createdById;
  final String createdByName;
  final DateTime createdAt;
  final bool isActive;
  final bool? isCompleted;

  FeedbackForm({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    this.formType,
    required this.createdById,
    required this.createdByName,
    required this.createdAt,
    required this.isActive,
    this.isCompleted,
  });

  factory FeedbackForm.fromJson(Map<String, dynamic> json) {
    return FeedbackForm(
      id: json['id'],
      projectId: json['projectId'],
      title: json['title'],
      description: json['description'],
      formType: json['formType'],
      createdById: json['createdById'],
      createdByName: json['createdByName'],
      createdAt: DateTime.parse(json['createdAt']),
      isActive: json['isActive'] ?? true,
      isCompleted: json['isCompleted'],
    );
  }
}

class BoqWorkType {
  final int id;
  final String name;
  final String? description;
  final int displayOrder;

  BoqWorkType({
    required this.id,
    required this.name,
    this.description,
    required this.displayOrder,
  });

  factory BoqWorkType.fromJson(Map<String, dynamic> json) {
    return BoqWorkType(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      displayOrder: json['displayOrder'] ?? 0,
    );
  }
}

class BoqItem {
  final int id;
  final int projectId;
  final int workTypeId;
  final String workTypeName;
  final String? itemCode;
  final String description;
  final double quantity;
  final String unit;
  final double rate;
  final double amount;
  final String? specifications;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int createdById;
  final String createdByName;
  final bool isActive;

  BoqItem({
    required this.id,
    required this.projectId,
    required this.workTypeId,
    required this.workTypeName,
    this.itemCode,
    required this.description,
    required this.quantity,
    required this.unit,
    required this.rate,
    required this.amount,
    this.specifications,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.createdById,
    required this.createdByName,
    required this.isActive,
  });

  factory BoqItem.fromJson(Map<String, dynamic> json) {
    return BoqItem(
      id: json['id'],
      projectId: json['projectId'],
      workTypeId: json['workTypeId'],
      workTypeName: json['workTypeName'],
      itemCode: json['itemCode'],
      description: json['description'],
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'],
      rate: (json['rate'] as num).toDouble(),
      amount: (json['amount'] as num).toDouble(),
      specifications: json['specifications'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      createdById: json['createdById'],
      createdByName: json['createdByName'],
      isActive: json['isActive'] ?? true,
    );
  }
}

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? fromJsonT) {
    return ApiResponse<T>(
      success: json['success'],
      message: json['message'],
      data: fromJsonT != null && json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }
}

/// Combined activity item for timeline display (site reports + queries)
class CombinedActivityItem {
  final int id;
  final String type; // "SITE_REPORT" or "QUERY"
  final String title;
  final String? description;
  final DateTime timestamp;
  final DateTime date;
  final String? status;
  final String createdByName;
  final Map<String, dynamic>? metadata;

  CombinedActivityItem({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    required this.timestamp,
    required this.date,
    this.status,
    required this.createdByName,
    this.metadata,
  });

  factory CombinedActivityItem.fromJson(Map<String, dynamic> json) {
    return CombinedActivityItem(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      date: DateTime.parse(json['date']),
      status: json['status'],
      createdByName: json['createdByName'],
      metadata: json['metadata'],
    );
  }

  bool get isSiteReport => type == 'SITE_REPORT';
  bool get isQuery => type == 'QUERY';
}

