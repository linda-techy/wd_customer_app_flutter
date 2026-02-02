import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../constants.dart';
import '../../../services/auth_service.dart';
import '../../../services/project_module_service.dart';
import '../../../models/project_module_models.dart';
import '../../../config/api_config.dart';

class ActivityFeedScreen extends StatefulWidget {
  final String projectId;

  const ActivityFeedScreen({super.key, required this.projectId});

  @override
  State<ActivityFeedScreen> createState() => _ActivityFeedScreenState();
}

class _ActivityFeedScreenState extends State<ActivityFeedScreen> {
  bool isLoading = true;
  String? error;
  List<ActivityFeed> activities = [];
  ProjectModuleService? service;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final token = await AuthService.getAccessToken();
    if (token != null) {
      service = ProjectModuleService(
        baseUrl: ApiConfig.baseUrl,
        token: token,
      );
      _loadActivities();
    } else {
      setState(() {
        error = 'Not authenticated';
        isLoading = false;
      });
    }
  }

  Future<void> _loadActivities() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final loadedActivities = await service!.getActivities(widget.projectId);
      
      // Sort by newest first
      loadedActivities.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        activities = loadedActivities;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load activities: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Project Activity", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadActivities,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : error != null
              ? _buildErrorState()
              : _buildActivityList(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(error!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadActivities,
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList() {
    if (activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.timeline, size: 48, color: Colors.blue),
            ),
            const SizedBox(height: 16),
            const Text('No activity yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text(
              'Project updates will appear here.',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        final isLast = index == activities.length - 1;
        return _buildActivityItem(activity, isLast, index);
      },
    );
  }

  Widget _buildActivityItem(ActivityFeed activity, bool isLast, int index) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Line & Dot
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _hexToColor(activity.activityTypeColor).withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _hexToColor(activity.activityTypeColor).withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    _getIconData(activity.activityTypeIcon),
                    size: 16,
                    color: _hexToColor(activity.activityTypeColor),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.grey[300],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            activity.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ),
                        Text(
                          _formatTime(activity.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(activity.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w500
                      ),
                    ),
                    if (activity.description != null && activity.description!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        activity.description!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4B5563),
                          height: 1.4,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.grey[200],
                          child: Text(
                            activity.createdByName.isNotEmpty 
                                ? activity.createdByName[0].toUpperCase() 
                                : 'U',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          activity.createdByName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: (index * 50).ms).slideX(begin: 0.1, duration: 400.ms);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, y').format(date);
    }
  }

  String _formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  Color _hexToColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return primaryColor;
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return primaryColor;
    }
  }

  IconData _getIconData(String? iconName) {
    if (iconName == null) return Icons.circle;
    switch (iconName.toLowerCase()) {
      case 'document': return Icons.description_outlined;
      case 'image': return Icons.image_outlined;
      case 'comment': return Icons.chat_bubble_outline;
      case 'check': return Icons.check_circle_outline;
      case 'alert': return Icons.warning_amber_rounded;
      case 'info': return Icons.info_outline;
      case 'upload': return Icons.upload_file;
      case 'edit': return Icons.edit_outlined;
      case 'delete': return Icons.delete_outline;
      case 'money': return Icons.attach_money;
      case 'schedule': return Icons.calendar_today;
      case 'user': return Icons.person_outline;
      case 'settings': return Icons.settings_outlined;
      default: return Icons.circle;
    }
  }
}
