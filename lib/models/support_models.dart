class TicketReply {
  final String id;
  final String userId;
  final String userType;
  final String userName;
  final String message;
  final String? attachmentUrl;
  final String createdAt;

  const TicketReply({
    required this.id,
    required this.userId,
    required this.userType,
    required this.userName,
    required this.message,
    this.attachmentUrl,
    required this.createdAt,
  });

  bool get isStaff => userType == 'STAFF';

  factory TicketReply.fromJson(Map<String, dynamic> json) {
    return TicketReply(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      userType: json['userType']?.toString() ?? '',
      userName: json['userName']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      attachmentUrl: json['attachmentUrl']?.toString(),
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}

class SupportTicket {
  final String id;
  final String ticketNumber;
  final String subject;
  final String description;
  final String category;
  final String priority;
  final String status;
  final int? projectId;
  final String createdAt;
  final String updatedAt;
  final String? resolvedAt;
  final List<TicketReply> replies;

  const SupportTicket({
    required this.id,
    required this.ticketNumber,
    required this.subject,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    this.projectId,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
    this.replies = const [],
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    final rawReplies = json['replies'];
    final List<TicketReply> replies = rawReplies is List
        ? rawReplies
            .map((r) => TicketReply.fromJson(r as Map<String, dynamic>))
            .toList()
        : [];

    return SupportTicket(
      id: json['id']?.toString() ?? '',
      ticketNumber: json['ticketNumber']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      priority: json['priority']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      projectId: json['projectId'] is int ? json['projectId'] as int : null,
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      resolvedAt: json['resolvedAt']?.toString(),
      replies: replies,
    );
  }
}
