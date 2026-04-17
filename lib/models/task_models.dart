class ProjectTask {
  final int id;
  final String title;
  final String? description;
  final String status;
  final String priority;
  final String? dueDate;
  final DateTime? createdAt;

  ProjectTask({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.dueDate,
    this.createdAt,
  });

  factory ProjectTask.fromJson(Map<String, dynamic> json) {
    return ProjectTask(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] as String?) ?? '',
      description: json['description'] as String?,
      status: (json['status'] as String?) ?? 'PENDING',
      priority: (json['priority'] as String?) ?? 'MEDIUM',
      dueDate: json['dueDate'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }

  bool get isOverdue => dueDate != null &&
      status != 'COMPLETED' &&
      DateTime.tryParse(dueDate!)?.isBefore(DateTime.now()) == true;

  bool get isPending => status == 'PENDING';
  bool get isInProgress => status == 'IN_PROGRESS';
  bool get isCompleted => status == 'COMPLETED';
}
