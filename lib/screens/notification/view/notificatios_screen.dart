import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../constants.dart';
import '../../../components/animations/fade_entry.dart';
import '../../../components/animations/hover_card.dart';
import '../../../components/animations/scale_button.dart';

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
      message: 'Foundation work for your villa project has been completed successfully.',
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
      color: Colors.orange,
    ),
    ConstructionNotification(
      id: '3',
      type: NotificationType.siteVisit,
      title: 'Site Visit Scheduled',
      message: 'Your site inspection is scheduled for tomorrow at 10:00 AM.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      icon: Icons.calendar_today_rounded,
      color: Colors.blue,
    ),
     ConstructionNotification(
      id: '4',
      type: NotificationType.document,
      title: 'New Document Available',
      message: 'Building plan approval certificate has been uploaded to your account.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      icon: Icons.insert_drive_file_rounded,
      color: successColor,
    ),
  ];

  List<ConstructionNotification> get filteredNotifications {
    if (selectedFilter == 'All') return notifications;
    if (selectedFilter == 'Unread') return notifications.where((n) => !n.isRead).toList();
    
    // Simple filter mapping
    return notifications.where((n) {
       switch(selectedFilter) {
         case 'Updates': return n.type == NotificationType.projectUpdate;
         case 'Payments': return n.type == NotificationType.payment;
         case 'Site': return n.type == NotificationType.siteVisit;
         default: return true;
       }
    }).toList();
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

    return Scaffold(
      backgroundColor: surfaceColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: surfaceColor,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Row(
                children: [
                   const Text(
                    "Notifications",
                    style: TextStyle(
                      color: blackColor,
                      fontFamily: grandisExtendedFont,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  if (unreadCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: logoRed,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "$unreadCount new",
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ).animate().scale(),
                  ],
                ],
              ),
            ),
            actions: [
               if (unreadCount > 0)
                IconButton(
                  onPressed: markAllAsRead,
                  icon: const Icon(Icons.done_all, color: primaryColor),
                  tooltip: "Mark all as read",
                ),
            ],
          ),
          
          // Filters
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  _buildFilterChip('All'),
                  _buildFilterChip('Unread'),
                  _buildFilterChip('Updates'),
                  _buildFilterChip('Payments'),
                  _buildFilterChip('Site'),
                ],
              ),
            ),
          ),

          // List
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: filteredNotifications.isEmpty
                ? SliverToBoxAdapter(child: _buildEmptyState())
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return FadeEntry(
                          delay: (index * 50).ms,
                          child: _buildNotificationItem(filteredNotifications[index]),
                        );
                      },
                      childCount: filteredNotifications.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = selectedFilter == label;
    return ScaleButton(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: AnimatedContainer(
        duration: 300.ms,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? primaryColor : blackColor10),
          boxShadow: isSelected
              ? [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : blackColor60,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(ConstructionNotification notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: errorColor,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => deleteNotification(notification.id),
      child: HoverCard(
        child: GestureDetector(
          onTap: () {
             if (!notification.isRead) markAsRead(notification.id);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: notification.isRead ? Colors.white : primaryColor.withOpacity(0.03),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: notification.isRead ? blackColor5 : primaryColor.withOpacity(0.3),
              ),
              boxShadow: [
                 BoxShadow(
                  color: blackColor.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: notification.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(notification.icon, color: notification.color, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w800,
                                fontSize: 14,
                                color: blackColor,
                              ),
                            ),
                          ),
                          Text(
                            _formatTimestamp(notification.timestamp),
                            style: const TextStyle(fontSize: 10, color: blackColor40),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.message,
                        style: const TextStyle(fontSize: 13, color: blackColor60, height: 1.4),
                      ),
                    ],
                  ),
                ),
                if (!notification.isRead) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
     return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: blackColor5,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none, size: 48, color: blackColor40),
          ).animate().scale(duration: 500.ms),
          const SizedBox(height: 16),
          const Text("No Notifications", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${timestamp.day}/${timestamp.month}';
  }
}

class ConstructionNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  bool isRead;
  final IconData icon;
  final Color color;

  ConstructionNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    required this.icon,
    required this.color,
  });
}

enum NotificationType { projectUpdate, payment, siteVisit, document, alert, general }
