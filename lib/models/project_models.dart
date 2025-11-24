// Project Status Enum
enum ProjectStatus { active, paused, completed, planning }

// QC Status Enum
enum QCStatus { pending, completed, failed, inProgress }

// Query Status Enum
enum QueryStatus { open, closed, resolved, inProgress }

// Query Priority Enum
enum QueryPriority { low, medium, high, urgent }

// Document Type Enum
enum DocumentType { floorPlan, structural, electrical, plumbing, other }

// Project Model
class Project {
  final String id;
  final String name;
  final String location;
  final String city;
  final String area;
  final ProjectStatus status;
  final double progress;
  final String nextMilestone;
  final DateTime nextMilestoneDate;
  final String thumbnailUrl;
  final String lastUpdate;
  final DateTime lastUpdatedAt;
  final double totalBudget;
  final double paidAmount;
  final double dueAmount;
  final int qcCompleted;
  final int qcPending;
  final int activeQueries;
  final int galleryPhotos;
  final ProjectDetails details;

  Project({
    required this.id,
    required this.name,
    required this.location,
    required this.city,
    required this.area,
    required this.status,
    required this.progress,
    required this.nextMilestone,
    required this.nextMilestoneDate,
    required this.thumbnailUrl,
    required this.lastUpdate,
    required this.lastUpdatedAt,
    required this.totalBudget,
    required this.paidAmount,
    required this.dueAmount,
    required this.qcCompleted,
    required this.qcPending,
    required this.activeQueries,
    required this.galleryPhotos,
    required this.details,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      city: json['city'],
      area: json['area'],
      status: ProjectStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ProjectStatus.planning,
      ),
      progress: json['progress'].toDouble(),
      nextMilestone: json['nextMilestone'],
      nextMilestoneDate: DateTime.parse(json['nextMilestoneDate']),
      thumbnailUrl: json['thumbnailUrl'],
      lastUpdate: json['lastUpdate'],
      lastUpdatedAt: DateTime.parse(json['lastUpdatedAt']),
      totalBudget: json['totalBudget'].toDouble(),
      paidAmount: json['paidAmount'].toDouble(),
      dueAmount: json['dueAmount'].toDouble(),
      qcCompleted: json['qcCompleted'],
      qcPending: json['qcPending'],
      activeQueries: json['activeQueries'],
      galleryPhotos: json['galleryPhotos'],
      details: ProjectDetails.fromJson(json['details']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'city': city,
      'area': area,
      'status': status.name,
      'progress': progress,
      'nextMilestone': nextMilestone,
      'nextMilestoneDate': nextMilestoneDate.toIso8601String(),
      'thumbnailUrl': thumbnailUrl,
      'lastUpdate': lastUpdate,
      'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
      'totalBudget': totalBudget,
      'paidAmount': paidAmount,
      'dueAmount': dueAmount,
      'qcCompleted': qcCompleted,
      'qcPending': qcPending,
      'activeQueries': activeQueries,
      'galleryPhotos': galleryPhotos,
      'details': details.toJson(),
    };
  }
}

// Project Details Model
class ProjectDetails {
  final String description;
  final DateTime startDate;
  final DateTime expectedEndDate;
  final String contractor;
  final String architect;
  final Map<String, double> progressBreakdown;
  final List<String> milestones;

  ProjectDetails({
    required this.description,
    required this.startDate,
    required this.expectedEndDate,
    required this.contractor,
    required this.architect,
    required this.progressBreakdown,
    required this.milestones,
  });

  factory ProjectDetails.fromJson(Map<String, dynamic> json) {
    return ProjectDetails(
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      expectedEndDate: DateTime.parse(json['expectedEndDate']),
      contractor: json['contractor'],
      architect: json['architect'],
      progressBreakdown: Map<String, double>.from(json['progressBreakdown']),
      milestones: List<String>.from(json['milestones']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'startDate': startDate.toIso8601String(),
      'expectedEndDate': expectedEndDate.toIso8601String(),
      'contractor': contractor,
      'architect': architect,
      'progressBreakdown': progressBreakdown,
      'milestones': milestones,
    };
  }
}

// Document Model
class Document {
  final String id;
  final String name;
  final DocumentType type;
  final String uploadedBy;
  final DateTime uploadDate;
  final String version;
  final String url;
  final String thumbnailUrl;
  final int fileSize;
  final String description;

  Document({
    required this.id,
    required this.name,
    required this.type,
    required this.uploadedBy,
    required this.uploadDate,
    required this.version,
    required this.url,
    required this.thumbnailUrl,
    required this.fileSize,
    required this.description,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      name: json['name'],
      type: DocumentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DocumentType.other,
      ),
      uploadedBy: json['uploadedBy'],
      uploadDate: DateTime.parse(json['uploadDate']),
      version: json['version'],
      url: json['url'],
      thumbnailUrl: json['thumbnailUrl'],
      fileSize: json['fileSize'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'uploadedBy': uploadedBy,
      'uploadDate': uploadDate.toIso8601String(),
      'version': version,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'fileSize': fileSize,
      'description': description,
    };
  }
}

// QC Item Model
class QCItem {
  final String id;
  final String title;
  final String description;
  final QCStatus status;
  final DateTime dueDate;
  final String assignedTo;
  final List<String> photos;
  final String comments;
  final List<String> correctiveActions;
  final DateTime createdAt;
  final DateTime? completedAt;

  QCItem({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.dueDate,
    required this.assignedTo,
    required this.photos,
    required this.comments,
    required this.correctiveActions,
    required this.createdAt,
    this.completedAt,
  });

  factory QCItem.fromJson(Map<String, dynamic> json) {
    return QCItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: QCStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => QCStatus.pending,
      ),
      dueDate: DateTime.parse(json['dueDate']),
      assignedTo: json['assignedTo'],
      photos: List<String>.from(json['photos']),
      comments: json['comments'],
      correctiveActions: List<String>.from(json['correctiveActions']),
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.name,
      'dueDate': dueDate.toIso8601String(),
      'assignedTo': assignedTo,
      'photos': photos,
      'comments': comments,
      'correctiveActions': correctiveActions,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}

// Query Model
class Query {
  final String id;
  final String title;
  final String description;
  final QueryStatus status;
  final QueryPriority priority;
  final String category;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String createdBy;
  final List<QueryMessage> messages;
  final List<String> attachments;

  Query({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.category,
    required this.createdAt,
    this.resolvedAt,
    required this.createdBy,
    required this.messages,
    required this.attachments,
  });

  factory Query.fromJson(Map<String, dynamic> json) {
    return Query(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: QueryStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => QueryStatus.open,
      ),
      priority: QueryPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => QueryPriority.medium,
      ),
      category: json['category'],
      createdAt: DateTime.parse(json['createdAt']),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'])
          : null,
      createdBy: json['createdBy'],
      messages: (json['messages'] as List)
          .map((m) => QueryMessage.fromJson(m))
          .toList(),
      attachments: List<String>.from(json['attachments']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.name,
      'priority': priority.name,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'createdBy': createdBy,
      'messages': messages.map((m) => m.toJson()).toList(),
      'attachments': attachments,
    };
  }
}

// Query Message Model
class QueryMessage {
  final String id;
  final String content;
  final String sender;
  final DateTime timestamp;
  final List<String> attachments;

  QueryMessage({
    required this.id,
    required this.content,
    required this.sender,
    required this.timestamp,
    required this.attachments,
  });

  factory QueryMessage.fromJson(Map<String, dynamic> json) {
    return QueryMessage(
      id: json['id'],
      content: json['content'],
      sender: json['sender'],
      timestamp: DateTime.parse(json['timestamp']),
      attachments: List<String>.from(json['attachments']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'sender': sender,
      'timestamp': timestamp.toIso8601String(),
      'attachments': attachments,
    };
  }
}

// Project Activity Model
class ProjectActivity {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final String type;
  final String user;
  final String? imageUrl;
  final Map<String, dynamic> metadata;

  ProjectActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
    required this.user,
    this.imageUrl,
    required this.metadata,
  });

  factory ProjectActivity.fromJson(Map<String, dynamic> json) {
    return ProjectActivity(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'],
      user: json['user'],
      imageUrl: json['imageUrl'],
      metadata: Map<String, dynamic>.from(json['metadata']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'user': user,
      'imageUrl': imageUrl,
      'metadata': metadata,
    };
  }
}

// Payment Model
class Payment {
  final String id;
  final String invoiceNumber;
  final double amount;
  final double paidAmount;
  final DateTime dueDate;
  final DateTime? paidDate;
  final String status;
  final String description;
  final String downloadUrl;

  Payment({
    required this.id,
    required this.invoiceNumber,
    required this.amount,
    required this.paidAmount,
    required this.dueDate,
    this.paidDate,
    required this.status,
    required this.description,
    required this.downloadUrl,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      invoiceNumber: json['invoiceNumber'],
      amount: json['amount'].toDouble(),
      paidAmount: json['paidAmount'].toDouble(),
      dueDate: DateTime.parse(json['dueDate']),
      paidDate:
          json['paidDate'] != null ? DateTime.parse(json['paidDate']) : null,
      status: json['status'],
      description: json['description'],
      downloadUrl: json['downloadUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'amount': amount,
      'paidAmount': paidAmount,
      'dueDate': dueDate.toIso8601String(),
      'paidDate': paidDate?.toIso8601String(),
      'status': status,
      'description': description,
      'downloadUrl': downloadUrl,
    };
  }
}

// Gallery Photo Model
class GalleryPhoto {
  final String id;
  final String url;
  final String thumbnailUrl;
  final String caption;
  final DateTime uploadedAt;
  final String uploadedBy;
  final String category;

  GalleryPhoto({
    required this.id,
    required this.url,
    required this.thumbnailUrl,
    required this.caption,
    required this.uploadedAt,
    required this.uploadedBy,
    required this.category,
  });

  factory GalleryPhoto.fromJson(Map<String, dynamic> json) {
    return GalleryPhoto(
      id: json['id'],
      url: json['url'],
      thumbnailUrl: json['thumbnailUrl'],
      caption: json['caption'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
      uploadedBy: json['uploadedBy'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'caption': caption,
      'uploadedAt': uploadedAt.toIso8601String(),
      'uploadedBy': uploadedBy,
      'category': category,
    };
  }
}

// Surveillance Camera Model
class SurveillanceCamera {
  final String id;
  final String name;
  final String location;
  final String snapshotUrl;
  final String streamUrl;
  final bool isOnline;
  final DateTime lastUpdated;

  SurveillanceCamera({
    required this.id,
    required this.name,
    required this.location,
    required this.snapshotUrl,
    required this.streamUrl,
    required this.isOnline,
    required this.lastUpdated,
  });

  factory SurveillanceCamera.fromJson(Map<String, dynamic> json) {
    return SurveillanceCamera(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      snapshotUrl: json['snapshotUrl'],
      streamUrl: json['streamUrl'],
      isOnline: json['isOnline'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'snapshotUrl': snapshotUrl,
      'streamUrl': streamUrl,
      'isOnline': isOnline,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

// Progress Data Point Model
class ProgressDataPoint {
  final DateTime date;
  final double progress;

  ProgressDataPoint({
    required this.date,
    required this.progress,
  });

  factory ProgressDataPoint.fromJson(Map<String, dynamic> json) {
    return ProgressDataPoint(
      date: DateTime.parse(json['date']),
      progress: json['progress'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'progress': progress,
    };
  }
}
