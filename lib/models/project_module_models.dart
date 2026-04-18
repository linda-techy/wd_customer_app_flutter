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
  final int? projectId;
  final String cameraName;
  final String? location;
  final String? provider;
  final String? streamProtocol;
  final String? streamUrl;
  final String? snapshotUrl;
  final bool isActive;
  final String? resolution;
  final DateTime? installationDate;

  CctvCamera({
    required this.id,
    this.projectId,
    required this.cameraName,
    this.location,
    this.provider,
    this.streamProtocol,
    this.streamUrl,
    this.snapshotUrl,
    required this.isActive,
    this.resolution,
    this.installationDate,
  });

  factory CctvCamera.fromJson(Map<String, dynamic> json) {
    return CctvCamera(
      id: json['id'] ?? 0,
      projectId: json['projectId'],
      cameraName: json['cameraName'] ?? json['camera_name'] ?? '',
      location: json['location'],
      provider: json['provider'],
      streamProtocol: json['streamProtocol'] ?? json['stream_protocol'],
      streamUrl: json['streamUrl'] ?? json['stream_url'],
      snapshotUrl: json['snapshotUrl'] ?? json['snapshot_url'],
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      resolution: json['resolution'],
      installationDate: json['installationDate'] != null
          ? DateTime.tryParse(json['installationDate'])
          : null,
    );
  }

  bool get hasStream => streamUrl != null && streamUrl!.isNotEmpty;
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
  final double? checkInLatitude;
  final double? checkInLongitude;
  final double? checkOutLatitude;
  final double? checkOutLongitude;
  final double? distanceFromProjectCheckIn;
  final double? distanceFromProjectCheckOut;

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
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkOutLatitude,
    this.checkOutLongitude,
    this.distanceFromProjectCheckIn,
    this.distanceFromProjectCheckOut,
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
      checkInLatitude: json['checkInLatitude']?.toDouble(),
      checkInLongitude: json['checkInLongitude']?.toDouble(),
      checkOutLatitude: json['checkOutLatitude']?.toDouble(),
      checkOutLongitude: json['checkOutLongitude']?.toDouble(),
      distanceFromProjectCheckIn: json['distanceFromProjectCheckIn']?.toDouble(),
      distanceFromProjectCheckOut: json['distanceFromProjectCheckOut']?.toDouble(),
    );
  }

  /// Format distance for display (e.g., "1.5 km" or "350 m")
  String? get formattedCheckInDistance {
    if (distanceFromProjectCheckIn == null) return null;
    if (distanceFromProjectCheckIn! < 1.0) {
      return '${(distanceFromProjectCheckIn! * 1000).round()} m';
    }
    return '${distanceFromProjectCheckIn!.toStringAsFixed(1)} km';
  }

  String? get formattedCheckOutDistance {
    if (distanceFromProjectCheckOut == null) return null;
    if (distanceFromProjectCheckOut! < 1.0) {
      return '${(distanceFromProjectCheckOut! * 1000).round()} m';
    }
    return '${distanceFromProjectCheckOut!.toStringAsFixed(1)} km';
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
  final int? categoryId;
  final String? categoryName;
  final String? itemCode;
  final String description;
  final double quantity;
  final String unit;
  final double rate;
  final double amount;
  final String? status;
  final double executedQuantity;
  final double billedQuantity;
  final double remainingQuantity;
  final double totalExecutedAmount;
  final double totalBilledAmount;
  final double executionPercentage;
  final double billingPercentage;
  final String? specifications;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int createdById;
  final String createdByName;
  final bool isActive;
  // BASE | ADDON | OPTIONAL | EXCLUSION
  final String itemKind;

  BoqItem({
    required this.id,
    required this.projectId,
    required this.workTypeId,
    required this.workTypeName,
    this.categoryId,
    this.categoryName,
    this.itemCode,
    required this.description,
    required this.quantity,
    required this.unit,
    required this.rate,
    required this.amount,
    this.status,
    required this.executedQuantity,
    required this.billedQuantity,
    required this.remainingQuantity,
    required this.totalExecutedAmount,
    required this.totalBilledAmount,
    required this.executionPercentage,
    required this.billingPercentage,
    this.specifications,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.createdById,
    required this.createdByName,
    required this.isActive,
    this.itemKind = 'BASE',
  });

  bool get isAddon => itemKind == 'ADDON' || itemKind == 'OPTIONAL';
  bool get isExclusion => itemKind == 'EXCLUSION';

  factory BoqItem.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) => v == null ? 0.0 : (v as num).toDouble();
    return BoqItem(
      id: json['id'],
      projectId: json['projectId'],
      workTypeId: json['workTypeId'],
      workTypeName: json['workTypeName'] ?? '',
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      itemCode: json['itemCode'],
      description: json['description'] ?? '',
      quantity: toDouble(json['quantity']),
      unit: json['unit'] ?? '',
      rate: toDouble(json['rate']),
      amount: toDouble(json['amount'] ?? json['totalAmount']),
      status: json['status'],
      executedQuantity: toDouble(json['executedQuantity']),
      billedQuantity: toDouble(json['billedQuantity']),
      remainingQuantity: toDouble(json['remainingQuantity']),
      totalExecutedAmount: toDouble(json['totalExecutedAmount']),
      totalBilledAmount: toDouble(json['totalBilledAmount']),
      executionPercentage: toDouble(json['executionPercentage']),
      billingPercentage: toDouble(json['billingPercentage']),
      specifications: json['specifications'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      createdById: json['createdById'],
      createdByName: json['createdByName'] ?? '',
      isActive: json['isActive'] ?? true,
      itemKind: json['itemKind'] ?? 'BASE',
    );
  }
}

class BoqWorkTypeSummary {
  final int workTypeId;
  final String workTypeName;
  final double subtotal;
  final int itemCount;

  BoqWorkTypeSummary({
    required this.workTypeId,
    required this.workTypeName,
    required this.subtotal,
    required this.itemCount,
  });

  factory BoqWorkTypeSummary.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) => v == null ? 0.0 : (v as num).toDouble();
    return BoqWorkTypeSummary(
      workTypeId: json['workTypeId'] ?? 0,
      workTypeName: json['workTypeName'] ?? '',
      subtotal: toDouble(json['subtotal']),
      itemCount: json['itemCount'] ?? 0,
    );
  }
}

class BoqSummary {
  final int projectId;
  final double totalPlannedAmount;
  final double totalExecutedAmount;
  final double totalBilledAmount;
  final double executionPercentage;
  final double billingPercentage;
  final int totalItems;
  final List<BoqWorkTypeSummary> workTypeSummaries;
  final double baseScopeAmount;
  final double addonAmount;

  BoqSummary({
    required this.projectId,
    required this.totalPlannedAmount,
    required this.totalExecutedAmount,
    required this.totalBilledAmount,
    required this.executionPercentage,
    required this.billingPercentage,
    required this.totalItems,
    required this.workTypeSummaries,
    this.baseScopeAmount = 0.0,
    this.addonAmount = 0.0,
  });

  double get costToComplete => totalPlannedAmount - totalExecutedAmount;
  bool get hasAddons => addonAmount > 0;

  factory BoqSummary.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) => v == null ? 0.0 : (v as num).toDouble();
    return BoqSummary(
      projectId: json['projectId'] ?? 0,
      totalPlannedAmount: toDouble(json['totalPlannedAmount']),
      totalExecutedAmount: toDouble(json['totalExecutedAmount']),
      totalBilledAmount: toDouble(json['totalBilledAmount']),
      executionPercentage: toDouble(json['executionPercentage']),
      billingPercentage: toDouble(json['billingPercentage']),
      totalItems: json['totalItems'] ?? 0,
      workTypeSummaries: (json['workTypeSummaries'] as List? ?? [])
          .map((e) => BoqWorkTypeSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
      baseScopeAmount: toDouble(json['baseScopeAmount']),
      addonAmount: toDouble(json['addonAmount']),
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

// ─── Warranty ────────────────────────────────────────────────────────────────

class ProjectWarranty {
  final int id;
  final String componentName;
  final String? description;
  final String? providerName;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;
  final String? coverageDetails;

  ProjectWarranty({
    required this.id,
    required this.componentName,
    this.description,
    this.providerName,
    this.startDate,
    this.endDate,
    required this.status,
    this.coverageDetails,
  });

  bool get isActive => status.toUpperCase() == 'ACTIVE';
  bool get isExpired => status.toUpperCase() == 'EXPIRED';

  factory ProjectWarranty.fromJson(Map<String, dynamic> json) {
    return ProjectWarranty(
      id: json['id'],
      componentName: json['componentName'] ?? '',
      description: json['description'],
      providerName: json['providerName'],
      startDate: json['startDate'] != null ? DateTime.tryParse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null,
      status: json['status'] ?? 'UNKNOWN',
      coverageDetails: json['coverageDetails'],
    );
  }
}

// ─── Delay Log ───────────────────────────────────────────────────────────────

class DelayLog {
  final int id;
  final String delayType;
  final DateTime fromDate;
  final DateTime? toDate;
  final String? reasonText;
  final bool isOpen;
  final int impactDays;

  DelayLog({
    required this.id,
    required this.delayType,
    required this.fromDate,
    this.toDate,
    this.reasonText,
    required this.isOpen,
    required this.impactDays,
  });

  factory DelayLog.fromJson(Map<String, dynamic> json) {
    return DelayLog(
      id: json['id'],
      delayType: json['delayType'] ?? '',
      fromDate: DateTime.parse(json['fromDate']),
      toDate: json['toDate'] != null ? DateTime.tryParse(json['toDate']) : null,
      reasonText: json['reasonText'],
      isOpen: json['isOpen'] ?? true,
      impactDays: (json['impactDays'] as num?)?.toInt() ?? 0,
    );
  }
}

// ─── BOQ Invoice ─────────────────────────────────────────────────────────────

class BoqInvoice {
  final int id;
  final String? invoiceNumber;
  final String? invoiceType;
  final double subtotalExGst;
  final double gstRate;
  final double gstAmount;
  final double totalInclGst;
  final double totalCreditApplied;
  final double netAmountDue;
  final String status;
  final DateTime? issueDate;
  final DateTime? dueDate;
  final DateTime? sentAt;
  final DateTime? paidAt;

  BoqInvoice({
    required this.id,
    this.invoiceNumber,
    this.invoiceType,
    required this.subtotalExGst,
    required this.gstRate,
    required this.gstAmount,
    required this.totalInclGst,
    required this.totalCreditApplied,
    required this.netAmountDue,
    required this.status,
    this.issueDate,
    this.dueDate,
    this.sentAt,
    this.paidAt,
  });

  factory BoqInvoice.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return BoqInvoice(
      id: json['id'],
      invoiceNumber: json['invoiceNumber'],
      invoiceType: json['invoiceType'],
      subtotalExGst: toDouble(json['subtotalExGst']),
      gstRate: toDouble(json['gstRate']),
      gstAmount: toDouble(json['gstAmount']),
      totalInclGst: toDouble(json['totalInclGst']),
      totalCreditApplied: toDouble(json['totalCreditApplied']),
      netAmountDue: toDouble(json['netAmountDue']),
      status: json['status'] ?? 'UNKNOWN',
      issueDate: json['issueDate'] != null ? DateTime.tryParse(json['issueDate']) : null,
      dueDate: json['dueDate'] != null ? DateTime.tryParse(json['dueDate']) : null,
      sentAt: json['sentAt'] != null ? DateTime.tryParse(json['sentAt']) : null,
      paidAt: json['paidAt'] != null ? DateTime.tryParse(json['paidAt']) : null,
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

