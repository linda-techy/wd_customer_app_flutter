import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../utils/responsive.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String selectedFilter = 'All';

  final List<ConstructionNotification> notifications = [
    ConstructionNotification(
      id: '1',
      type: NotificationType.projectUpdate,
      title: 'Project Milestone Achieved',
      message:
          'Foundation work for your villa project has been completed successfully.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
      icon: Icons.construction_rounded,
      color: logoRed,
    ),
    ConstructionNotification(
      id: '2',
      type: NotificationType.payment,
      title: 'Payment Due Reminder',
      message: 'Your next installment of ₹5,00,000 is due on 25th Oct 2025.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: false,
      icon: Icons.payments_rounded,
      color: const Color(0xFFFF9800), // Warm orange matching logo palette
    ),
    ConstructionNotification(
      id: '3',
      type: NotificationType.siteVisit,
      title: 'Site Visit Scheduled',
      message: 'Your site inspection is scheduled for tomorrow at 10:00 AM.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      icon: Icons.calendar_today_rounded,
      color: const Color(0xFF2196F3), // Professional blue
    ),
    ConstructionNotification(
      id: '4',
      type: NotificationType.document,
      title: 'New Document Available',
      message:
          'Building plan approval certificate has been uploaded to your account.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      icon: Icons.insert_drive_file_rounded,
      color: const Color(0xFF4CAF50), // Success green
    ),
    ConstructionNotification(
      id: '5',
      type: NotificationType.projectUpdate,
      title: 'Material Delivery Update',
      message: 'Steel and cement delivery scheduled for 20th Oct 2025.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
      icon: Icons.local_shipping_rounded,
      color: logoPink,
    ),
    ConstructionNotification(
      id: '6',
      type: NotificationType.alert,
      title: 'Weather Alert',
      message:
          'Heavy rain expected this week. Construction work may be delayed.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
      icon: Icons.warning_amber_rounded,
      color: const Color(0xFFF44336), // Alert red
    ),
    ConstructionNotification(
      id: '7',
      type: NotificationType.projectUpdate,
      title: 'Quality Inspection Passed',
      message: 'Your project has passed the quality inspection for Phase 1.',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      isRead: true,
      icon: Icons.verified_rounded,
      color: const Color(0xFF4CAF50), // Success green
    ),
    ConstructionNotification(
      id: '8',
      type: NotificationType.general,
      title: 'Welcome to Walldot Builders',
      message:
          'Thank you for choosing us for your construction project. We are committed to delivering excellence.',
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      isRead: true,
      icon: Icons.celebration_rounded,
      color: logoRed,
    ),
  ];

  List<ConstructionNotification> get filteredNotifications {
    if (selectedFilter == 'All') {
      return notifications;
    } else if (selectedFilter == 'Unread') {
      return notifications.where((n) => !n.isRead).toList();
    } else {
      return notifications
          .where((n) =>
              n.type.toString().split('.').last ==
              selectedFilter.toLowerCase().replaceAll(' ', ''))
          .toList();
    }
  }

  void markAsRead(String id) {
    setState(() {
      final notification = notifications.firstWhere((n) => n.id == id);
      notification.isRead = true;
    });
  }

  void markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification.isRead = true;
      }
    });
  }

  void deleteNotification(String id) {
    setState(() {
      notifications.removeWhere((n) => n.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = notifications.where((n) => !n.isRead).length;
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                logoRed,
                logoPink,
              ],
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Notifications",
              style: TextStyle(color: Colors.white),
            ),
            if (unreadCount > 0)
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "$unreadCount new",
                  style: TextStyle(
                    fontSize: ResponsiveFontSize.getBody(context) - 3,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          if (unreadCount > 0)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: markAllAsRead,
                icon: const Icon(Icons.done_all, color: Colors.white, size: 18),
                label: const Text(
                  "Mark all",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          IconButton(
            onPressed: () {
              // TODO: Open notification settings
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Notification settings coming soon'),
                  backgroundColor: logoRed,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.settings, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips with gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  logoRed.withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
            ),
            padding: EdgeInsets.all(ResponsiveSpacing.getPadding(context)),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Unread'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Project Update'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Payment'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Site Visit'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Document'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Alert'),
                ],
              ),
            ),
          ),
          // Notifications list
          Expanded(
            child: filteredNotifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding:
                        EdgeInsets.all(ResponsiveSpacing.getPadding(context)),
                    itemCount: filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final notification = filteredNotifications[index];
                      return _buildNotificationCard(
                        notification,
                        isDesktop,
                        isTablet,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = selectedFilter == label;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            selectedFilter = label;
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [logoRed, logoPink],
                  )
                : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : logoGreyLight.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: logoRed.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : logoGreyDark,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              fontSize: ResponsiveFontSize.getBody(context) - 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    ConstructionNotification notification,
    bool isDesktop,
    bool isTablet,
  ) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [logoRed, logoPink],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      onDismissed: (direction) {
        deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notification deleted'),
            backgroundColor: logoRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            action: SnackBarAction(
              label: 'Undo',
              textColor: Colors.white,
              onPressed: () {
                // TODO: Implement undo
              },
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          if (!notification.isRead) {
            markAsRead(notification.id);
          }
          // TODO: Navigate to relevant screen based on notification type
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notification.isRead
                  ? logoGreyLight.withOpacity(0.3)
                  : logoRed.withOpacity(0.5),
              width: notification.isRead ? 1 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: notification.isRead
                    ? Colors.black.withOpacity(0.05)
                    : logoRed.withOpacity(0.15),
                blurRadius: notification.isRead ? 8 : 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Gradient accent bar for unread
              if (!notification.isRead)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [logoRed, logoPink],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                  ),
                ),
              // Main content
              Padding(
                padding:
                    EdgeInsets.all(ResponsiveSpacing.getCardPadding(context)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon with gradient background for unread
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: !notification.isRead
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  notification.color.withOpacity(0.2),
                                  notification.color.withOpacity(0.1),
                                ],
                              )
                            : null,
                        color: notification.isRead
                            ? notification.color.withOpacity(0.1)
                            : null,
                        borderRadius: BorderRadius.circular(12),
                        border: !notification.isRead
                            ? Border.all(
                                color: notification.color.withOpacity(0.3),
                                width: 1,
                              )
                            : null,
                      ),
                      child: Icon(
                        notification.icon,
                        color: notification.color,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notification.title,
                                  style: TextStyle(
                                    fontSize:
                                        ResponsiveFontSize.getBody(context),
                                    fontWeight: notification.isRead
                                        ? FontWeight.w600
                                        : FontWeight.w800,
                                    color: notification.isRead
                                        ? logoGreyDark
                                        : logoBackground,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (!notification.isRead)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [logoRed, logoPink],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    'NEW',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            notification.message,
                            style: TextStyle(
                              fontSize: ResponsiveFontSize.getBody(context) - 1,
                              color: logoGreyDark.withOpacity(0.8),
                              height: 1.5,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: logoGreyLight.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: logoGreyDark.withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formatTimestamp(notification.timestamp),
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveFontSize.getBody(context) - 2,
                                  color: logoGreyDark.withOpacity(0.6),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    logoRed.withOpacity(0.1),
                    logoPink.withOpacity(0.1),
                  ],
                ),
                border: Border.all(
                  color: logoRed.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                selectedFilter == 'Unread'
                    ? Icons.check_circle_outline
                    : Icons.notifications_none,
                size: 64,
                color: logoRed,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              selectedFilter == 'Unread'
                  ? 'All Caught Up!'
                  : 'No Notifications Yet',
              style: TextStyle(
                fontSize: ResponsiveFontSize.getTitle(context),
                fontWeight: FontWeight.w700,
                color: logoBackground,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                selectedFilter == 'Unread'
                    ? 'You are up to date with all your construction project notifications'
                    : 'We will notify you about project updates, payments, and site visits',
                style: TextStyle(
                  fontSize: ResponsiveFontSize.getBody(context),
                  color: logoGreyDark.withOpacity(0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (selectedFilter == 'Unread') ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      logoRed.withOpacity(0.1),
                      logoPink.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: logoRed.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.celebration,
                      size: 20,
                      color: logoRed,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Great job staying on top of things!',
                      style: TextStyle(
                        fontSize: ResponsiveFontSize.getBody(context) - 1,
                        fontWeight: FontWeight.w600,
                        color: logoRed,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

// Notification model
class ConstructionNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  bool isRead;
  final IconData icon;
  final Color color;
  final String priority; // 'high', 'medium', 'low'
  final bool actionRequired;

  ConstructionNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    required this.icon,
    required this.color,
    this.priority = 'medium',
    this.actionRequired = false,
  });
}

enum NotificationType {
  projectUpdate,
  payment,
  siteVisit,
  document,
  alert,
  general,
}
