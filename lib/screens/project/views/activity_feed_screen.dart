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
  List<CombinedActivityItem> activities = [];
  List<CombinedActivityItem> filteredActivities = [];
  Map<DateTime, List<CombinedActivityItem>> groupedActivities = {};
  ProjectModuleService? service;
  String _selectedFilter = 'ALL'; // ALL, SITE_REPORT, QUERY

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

      // Load combined activities (site reports + queries)
      final loadedActivities = await service!.getCombinedActivities(widget.projectId);
      
      // Sort by newest first
      loadedActivities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      setState(() {
        activities = loadedActivities;
        isLoading = false;
      });
      _applyFilter();
    } catch (e) {
      setState(() {
        error = 'Failed to load activities: $e';
        isLoading = false;
      });
    }
  }

  void _applyFilter() {
    final filtered = _selectedFilter == 'ALL'
        ? activities
        : activities.where((a) => a.type == _selectedFilter).toList();

    // Group by date
    final grouped = <DateTime, List<CombinedActivityItem>>{};
    for (final activity in filtered) {
      final dateKey = DateTime(activity.date.year, activity.date.month, activity.date.day);
      grouped.putIfAbsent(dateKey, () => []).add(activity);
    }

    setState(() {
      filteredActivities = filtered;
      groupedActivities = grouped;
    });
  }

  void _setFilter(String filter) {
    if (_selectedFilter == filter) return;
    setState(() {
      _selectedFilter = filter;
    });
    _applyFilter();
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
          "Activity Feed", 
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
              : Column(
                  children: [
                    _buildFilterChips(),
                    Expanded(child: _buildTimelineLayout()),
                  ],
                ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _buildFilterChip('ALL', 'All', primaryColor, Icons.list),
          const SizedBox(width: 8),
          _buildFilterChip('SITE_REPORT', 'Site Reports', Colors.blue, Icons.description_outlined),
          const SizedBox(width: 8),
          _buildFilterChip('QUERY', 'Queries', Colors.orange, Icons.help_outline),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1);
  }

  Widget _buildFilterChip(String value, String label, Color color, IconData icon) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => _setFilter(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color.withOpacity(0.4) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? color : Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? color : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildTimelineLayout() {
    if (filteredActivities.isEmpty) {
      final isFiltered = _selectedFilter != 'ALL';
      final filterLabel = _selectedFilter == 'SITE_REPORT' ? 'site reports' : 
                          _selectedFilter == 'QUERY' ? 'queries' : 'activities';
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.timeline, size: 48, color: primaryColor),
            ),
            const SizedBox(height: 16),
            Text(
              isFiltered ? 'No $filterLabel found' : 'No activity yet',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered 
                  ? 'Try changing the filter to see other activities.'
                  : 'Site reports and queries will appear here.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (isFiltered) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => _setFilter('ALL'),
                child: const Text('Show All Activities', style: TextStyle(color: primaryColor)),
              ),
            ],
          ],
        ),
      );
    }

    // Sort dates in descending order (newest first)
    final sortedDates = groupedActivities.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return RefreshIndicator(
      onRefresh: _loadActivities,
      color: primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sortedDates.length,
        itemBuilder: (context, dateIndex) {
          final date = sortedDates[dateIndex];
          final dateActivities = groupedActivities[date]!;
          
          return _buildDateSection(date, dateActivities, dateIndex);
        },
      ),
    );
  }

  Widget _buildDateSection(DateTime date, List<CombinedActivityItem> dateActivities, int dateIndex) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side: Date column
        SizedBox(
          width: 70,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  DateFormat('d').format(date),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _isToday(date) ? primaryColor : const Color(0xFF1F2937),
                  ),
                ),
                Text(
                  DateFormat('MMM').format(date).toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _isToday(date) ? primaryColor : Colors.grey[600],
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  DateFormat('yyyy').format(date),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
                if (_isToday(date)) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'TODAY',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ).animate().fadeIn(duration: 300.ms, delay: (dateIndex * 100).ms),
        // Vertical timeline connector
        SizedBox(
          width: 24,
          child: Column(
            children: [
              const SizedBox(height: 16),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _isToday(date) ? primaryColor : Colors.grey[400],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_isToday(date) ? primaryColor : Colors.grey).withOpacity(0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              Container(
                width: 2,
                height: dateActivities.length * 140.0, // Approximate height
                color: Colors.grey[300],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Right side: Activity cards
        Expanded(
          child: Column(
            children: dateActivities.asMap().entries.map((entry) {
              final index = entry.key;
              final activity = entry.value;
              final isLast = index == dateActivities.length - 1;
              return _buildActivityCard(activity, isLast, dateIndex * 10 + index);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(CombinedActivityItem activity, bool isLast, int index) {
    final typeColor = _getTypeColor(activity.type);
    final typeIcon = _getTypeIcon(activity.type);

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 24 : 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () => _showActivityDetails(activity),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Type badge + Time
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(typeIcon, size: 14, color: typeColor),
                          const SizedBox(width: 4),
                          Text(
                            _formatType(activity.type),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: typeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat('h:mm a').format(activity.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Title
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1F2937),
                  ),
                ),
                // Description
                if (activity.description != null && activity.description!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    activity.description!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4B5563),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 10),
                // Footer: Status + Created By
                Row(
                  children: [
                    if (activity.status != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _getStatusColor(activity.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          activity.status!.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(activity.status),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    const Spacer(),
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.grey[200],
                      child: Text(
                        activity.createdByName.isNotEmpty 
                            ? activity.createdByName[0].toUpperCase() 
                            : 'U',
                        style: const TextStyle(
                          fontSize: 10, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.grey
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        activity.createdByName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (index * 30).ms).slideX(begin: 0.05);
  }

  void _showActivityDetails(CombinedActivityItem activity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ActivityDetailsSheet(activity: activity),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  Color _getTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'SITE_REPORT':
        return Colors.blue;
      case 'QUERY':
        return Colors.orange;
      default:
        return primaryColor;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'SITE_REPORT':
        return Icons.description_outlined;
      case 'QUERY':
        return Icons.help_outline;
      default:
        return Icons.circle;
    }
  }

  String _formatType(String type) {
    switch (type.toUpperCase()) {
      case 'SITE_REPORT':
        return 'Site Report';
      case 'QUERY':
        return 'Query';
      default:
        return type;
    }
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    switch (status.toUpperCase()) {
      case 'SUBMITTED':
      case 'APPROVED':
        return Colors.green;
      case 'PENDING':
      case 'IN_PROGRESS':
        return Colors.orange;
      case 'REJECTED':
        return Colors.red;
      case 'RESOLVED':
      case 'ANSWERED':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

class _ActivityDetailsSheet extends StatelessWidget {
  final CombinedActivityItem activity;

  const _ActivityDetailsSheet({required this.activity});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Type Badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getTypeColor(activity.type).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_getTypeIcon(activity.type), size: 16, color: _getTypeColor(activity.type)),
                              const SizedBox(width: 6),
                              Text(
                                _formatType(activity.type),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _getTypeColor(activity.type),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        if (activity.status != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(activity.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              activity.status!.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(activity.status),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Title
                    Text(
                      activity.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Description
                    if (activity.description != null && activity.description!.isNotEmpty) ...[
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        activity.description!,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF374151),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    // Date & Time
                    _buildDetailRow(
                      Icons.calendar_today_outlined,
                      'Date',
                      DateFormat('MMMM d, y').format(activity.date),
                    ),
                    _buildDetailRow(
                      Icons.access_time,
                      'Time',
                      DateFormat('h:mm a').format(activity.timestamp),
                    ),
                    // Created By
                    _buildDetailRow(
                      Icons.person_outline,
                      'Created By',
                      activity.createdByName,
                    ),
                    // Additional Metadata
                    if (activity.metadata != null && activity.metadata!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      const Text(
                        'Additional Details',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...activity.metadata!.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 120,
                                child: Text(
                                  _formatMetadataKey(entry.key),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '${entry.value}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[500]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatMetadataKey(String key) {
    // Convert camelCase or snake_case to Title Case
    return key
        .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(1)}')
        .replaceAll('_', ' ')
        .trim()
        .split(' ')
        .map((word) => word.isNotEmpty 
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }

  Color _getTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'SITE_REPORT':
        return Colors.blue;
      case 'QUERY':
        return Colors.orange;
      default:
        return primaryColor;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'SITE_REPORT':
        return Icons.description_outlined;
      case 'QUERY':
        return Icons.help_outline;
      default:
        return Icons.circle;
    }
  }

  String _formatType(String type) {
    switch (type.toUpperCase()) {
      case 'SITE_REPORT':
        return 'Site Report';
      case 'QUERY':
        return 'Query';
      default:
        return type;
    }
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    switch (status.toUpperCase()) {
      case 'SUBMITTED':
      case 'APPROVED':
        return Colors.green;
      case 'PENDING':
      case 'IN_PROGRESS':
        return Colors.orange;
      case 'REJECTED':
        return Colors.red;
      case 'RESOLVED':
      case 'ANSWERED':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
