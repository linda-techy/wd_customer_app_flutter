// Construction Project Model

class Project {
  final String id;
  final String name;
  final String description;
  final String type; // Residential, Commercial, Industrial, Renovation
  final ProjectStatus status;
  final String? imageUrl;
  final DateTime startDate;
  final DateTime? estimatedEndDate;
  final DateTime? actualEndDate;
  final String location;
  final double? budget;
  final double? completionPercentage;
  final List<String> features;
  final ProjectManager? projectManager;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.status,
    this.imageUrl,
    required this.startDate,
    this.estimatedEndDate,
    this.actualEndDate,
    required this.location,
    this.budget,
    this.completionPercentage,
    this.features = const [],
    this.projectManager,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'Residential',
      status: ProjectStatus.fromString(json['status'] ?? 'planning'),
      imageUrl: json['imageUrl'],
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      estimatedEndDate: json['estimatedEndDate'] != null
          ? DateTime.parse(json['estimatedEndDate'])
          : null,
      actualEndDate: json['actualEndDate'] != null
          ? DateTime.parse(json['actualEndDate'])
          : null,
      location: json['location'] ?? '',
      budget: json['budget']?.toDouble(),
      completionPercentage: json['completionPercentage']?.toDouble() ?? 0.0,
      features:
          json['features'] != null ? List<String>.from(json['features']) : [],
      projectManager: json['projectManager'] != null
          ? ProjectManager.fromJson(json['projectManager'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'status': status.toString(),
      'imageUrl': imageUrl,
      'startDate': startDate.toIso8601String(),
      'estimatedEndDate': estimatedEndDate?.toIso8601String(),
      'actualEndDate': actualEndDate?.toIso8601String(),
      'location': location,
      'budget': budget,
      'completionPercentage': completionPercentage,
      'features': features,
      'projectManager': projectManager?.toJson(),
    };
  }

  bool get isCompleted => status == ProjectStatus.completed;
  bool get isInProgress => status == ProjectStatus.inProgress;
  bool get isOnHold => status == ProjectStatus.onHold;

  String get statusDisplay => status.displayName;

  int get daysElapsed {
    return DateTime.now().difference(startDate).inDays;
  }

  int? get daysRemaining {
    if (estimatedEndDate == null) return null;
    final diff = estimatedEndDate!.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }
}

// Project Status Enum
enum ProjectStatus {
  planning,
  inProgress,
  onHold,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case ProjectStatus.planning:
        return 'Planning';
      case ProjectStatus.inProgress:
        return 'In Progress';
      case ProjectStatus.onHold:
        return 'On Hold';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.cancelled:
        return 'Cancelled';
    }
  }

  static ProjectStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'planning':
        return ProjectStatus.planning;
      case 'in_progress':
      case 'inprogress':
        return ProjectStatus.inProgress;
      case 'on_hold':
      case 'onhold':
        return ProjectStatus.onHold;
      case 'completed':
        return ProjectStatus.completed;
      case 'cancelled':
        return ProjectStatus.cancelled;
      default:
        return ProjectStatus.planning;
    }
  }

  @override
  String toString() {
    return name;
  }
}

// Project Manager Model
class ProjectManager {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? imageUrl;

  ProjectManager({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.imageUrl,
  });

  factory ProjectManager.fromJson(Map<String, dynamic> json) {
    return ProjectManager(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'imageUrl': imageUrl,
    };
  }
}

// Project Milestone Model
class ProjectMilestone {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isCompleted;
  final DateTime? completedDate;

  ProjectMilestone({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    this.completedDate,
  });

  factory ProjectMilestone.fromJson(Map<String, dynamic> json) {
    return ProjectMilestone(
      id: json['id']?.toString() ?? '',
      projectId: json['projectId']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'])
          : DateTime.now(),
      isCompleted: json['isCompleted'] ?? false,
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'completedDate': completedDate?.toIso8601String(),
    };
  }
}

// Project Document Model
class ProjectDocument {
  final String id;
  final String projectId;
  final String name;
  final String type; // Contract, Permit, Invoice, Plan, Photo, etc.
  final String? url;
  final DateTime uploadDate;
  final String? uploadedBy;
  final int? fileSize; // in bytes

  ProjectDocument({
    required this.id,
    required this.projectId,
    required this.name,
    required this.type,
    this.url,
    required this.uploadDate,
    this.uploadedBy,
    this.fileSize,
  });

  factory ProjectDocument.fromJson(Map<String, dynamic> json) {
    return ProjectDocument(
      id: json['id']?.toString() ?? '',
      projectId: json['projectId']?.toString() ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'Document',
      url: json['url'],
      uploadDate: json['uploadDate'] != null
          ? DateTime.parse(json['uploadDate'])
          : DateTime.now(),
      uploadedBy: json['uploadedBy'],
      fileSize: json['fileSize'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'name': name,
      'type': type,
      'url': url,
      'uploadDate': uploadDate.toIso8601String(),
      'uploadedBy': uploadedBy,
      'fileSize': fileSize,
    };
  }

  String get fileSizeDisplay {
    if (fileSize == null) return 'Unknown';
    if (fileSize! < 1024) return '$fileSize B';
    if (fileSize! < 1024 * 1024) {
      return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
