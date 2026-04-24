class TimelineItem {
  final int taskId;
  final String title;
  final String? milestoneName;
  final int? milestoneId;
  final DateTime? plannedStart;
  final DateTime? plannedEnd;
  final DateTime? actualStart;
  final DateTime? actualEnd;
  final int progressPercent;
  final String status;
  final String statusLabel;
  final String? crewName;

  const TimelineItem({
    required this.taskId,
    required this.title,
    this.milestoneName,
    this.milestoneId,
    this.plannedStart,
    this.plannedEnd,
    this.actualStart,
    this.actualEnd,
    required this.progressPercent,
    required this.status,
    required this.statusLabel,
    this.crewName,
  });

  factory TimelineItem.fromJson(Map<String, dynamic> json) => TimelineItem(
    taskId: (json['taskId'] as num).toInt(),
    title: json['title'] as String? ?? 'Task',
    milestoneName: json['milestoneName'] as String?,
    milestoneId: (json['milestoneId'] as num?)?.toInt(),
    plannedStart: json['plannedStart'] != null ? DateTime.parse(json['plannedStart'] as String) : null,
    plannedEnd: json['plannedEnd'] != null ? DateTime.parse(json['plannedEnd'] as String) : null,
    actualStart: json['actualStart'] != null ? DateTime.parse(json['actualStart'] as String) : null,
    actualEnd: json['actualEnd'] != null ? DateTime.parse(json['actualEnd'] as String) : null,
    progressPercent: (json['progressPercent'] as num?)?.toInt() ?? 0,
    status: json['status'] as String? ?? 'PENDING',
    statusLabel: json['statusLabel'] as String? ?? 'ON_TRACK',
    crewName: json['crewName'] as String?,
  );
}

class TimelineSummary {
  final int weekCount;
  final int upcomingCount;
  final int completedCount;
  final int projectProgressPercent;

  const TimelineSummary({
    required this.weekCount,
    required this.upcomingCount,
    required this.completedCount,
    required this.projectProgressPercent,
  });

  factory TimelineSummary.fromJson(Map<String, dynamic> json) => TimelineSummary(
    weekCount: (json['weekCount'] as num?)?.toInt() ?? 0,
    upcomingCount: (json['upcomingCount'] as num?)?.toInt() ?? 0,
    completedCount: (json['completedCount'] as num?)?.toInt() ?? 0,
    projectProgressPercent: (json['projectProgressPercent'] as num?)?.toInt() ?? 0,
  );
}

class TimelinePage {
  final List<TimelineItem> items;
  final int totalElements;
  final int totalPages;
  final int page;
  final int size;
  final int projectProgressPercent;

  const TimelinePage({
    required this.items,
    required this.totalElements,
    required this.totalPages,
    required this.page,
    required this.size,
    required this.projectProgressPercent,
  });

  factory TimelinePage.fromJson(Map<String, dynamic> json) => TimelinePage(
    items: (json['items'] as List? ?? [])
        .map((e) => TimelineItem.fromJson(e as Map<String, dynamic>))
        .toList(),
    totalElements: (json['totalElements'] as num?)?.toInt() ?? 0,
    totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
    page: (json['page'] as num?)?.toInt() ?? 0,
    size: (json['size'] as num?)?.toInt() ?? 20,
    projectProgressPercent: (json['projectProgressPercent'] as num?)?.toInt() ?? 0,
  );
}
