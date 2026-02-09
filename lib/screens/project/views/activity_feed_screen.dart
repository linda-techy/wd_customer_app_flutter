import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../constants.dart';
import '../../../services/project_module_service.dart';
import '../../../services/auth_service.dart';
import '../../../config/api_config.dart';
import '../../../models/project_module_models.dart';

class ActivityFeedScreen extends StatefulWidget {
  final String projectId;
  const ActivityFeedScreen({super.key, required this.projectId});

  @override
  State<ActivityFeedScreen> createState() => _ActivityFeedScreenState();
}

class _ActivityFeedScreenState extends State<ActivityFeedScreen> {
  ProjectModuleService? _service;
  Map<DateTime, List<CombinedActivityItem>> _groupedActivities = {};
  bool _isLoading = true;
  String? _error;
  String _filterType = 'all';

  static const _activityTypes = ['all', 'site_report', 'query', 'observation', 'gallery', 'quality_check', 'site_visit'];

  @override
  void initState() {
    super.initState();
    _initService();
  }

  Future<void> _initService() async {
    final token = await AuthService.getAccessToken();
    if (token != null) {
      _service = ProjectModuleService(baseUrl: ApiConfig.baseUrl, token: token);
      _loadData();
    } else {
      setState(() {
        _error = 'Not authenticated';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadData() async {
    if (_service == null) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final grouped = await _service!.getCombinedActivitiesGrouped(widget.projectId);
      setState(() {
        _groupedActivities = grouped;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load activities: $e';
        _isLoading = false;
      });
    }
  }

  /// Filter grouped activities by type
  Map<DateTime, List<CombinedActivityItem>> get _filteredActivities {
    if (_filterType == 'all') return _groupedActivities;

    final filtered = <DateTime, List<CombinedActivityItem>>{};
    for (final entry in _groupedActivities.entries) {
      final items = entry.value
          .where((item) => item.type.toLowerCase() == _filterType)
          .toList();
      if (items.isNotEmpty) {
        filtered[entry.key] = items;
      }
    }
    return filtered;
  }

  int get _totalActivityCount {
    return _groupedActivities.values.fold(0, (sum, list) => sum + list.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: blackColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Activity Feed",
              style: TextStyle(color: blackColor, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            if (!_isLoading && _error == null)
              Text(
                '$_totalActivityCount activities',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
          ],
        ),
        backgroundColor: surfaceColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: blackColor),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : _error != null
              ? _buildErrorState()
              : Column(
                  children: [
                    _buildFilterChips(),
                    Expanded(child: _buildTimeline()),
                  ],
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: errorColor),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _error!,
              style: const TextStyle(color: errorColor),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
        children: _activityTypes.map((type) {
          final isSelected = _filterType == type;
          final config = _getActivityConfig(type);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(config.icon, size: 14, color: isSelected ? Colors.white : config.color),
                  const SizedBox(width: 6),
                  Text(config.label),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _filterType = selected ? type : 'all';
                });
              },
              selectedColor: config.color,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              backgroundColor: Colors.white,
              side: BorderSide(color: isSelected ? config.color : Colors.grey.shade300),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimeline() {
    final filtered = _filteredActivities;

    if (filtered.isEmpty) {
      return _buildEmptyState();
    }

    final sortedDates = filtered.keys.toList()..sort((a, b) => b.compareTo(a));

    return RefreshIndicator(
      onRefresh: _loadData,
      color: primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(defaultPadding),
        itemCount: sortedDates.length,
        itemBuilder: (context, dateIndex) {
          final date = sortedDates[dateIndex];
          final activities = filtered[date]!;

          return _buildDateGroup(date, activities, dateIndex);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.timeline, size: 48, color: primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            _filterType == 'all' ? 'No activities recorded' : 'No ${_getActivityConfig(_filterType).label.toLowerCase()} found',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Project activities will appear here as they happen.',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildDateGroup(DateTime date, List<CombinedActivityItem> activities, int dateIndex) {
    final isToday = _isToday(date);
    final isYesterday = _isYesterday(date);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isToday ? primaryColor.withOpacity(0.1) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: isToday ? primaryColor : Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isToday
                            ? 'Today'
                            : isYesterday
                                ? 'Yesterday'
                                : DateFormat('EEEE, MMMM d, y').format(date),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isToday ? primaryColor : Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  '${activities.length} ${activities.length == 1 ? 'activity' : 'activities'}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms, delay: (dateIndex * 50).ms),
          const SizedBox(height: 8),
          // Timeline items
          ...activities.asMap().entries.map((entry) {
            final index = entry.key;
            final activity = entry.value;
            final isLast = index == activities.length - 1;
            return _buildTimelineItem(activity, isLast, dateIndex * 10 + index);
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(CombinedActivityItem activity, bool isLast, int animIndex) {
    final config = _getActivityConfig(activity.type);
    final timeStr = DateFormat('h:mm a').format(activity.timestamp);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line and dot
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: config.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: config.color.withOpacity(0.3), width: 2),
                  ),
                  child: Icon(config.icon, size: 14, color: config.color),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.grey[200],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Activity card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
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
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _showActivityDetails(activity),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row: type badge + time
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: config.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                config.label,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: config.color,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.access_time, size: 12, color: Colors.grey[400]),
                            const SizedBox(width: 4),
                            Text(
                              timeStr,
                              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Title
                        Text(
                          activity.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Color(0xFF1F2937),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Description (if available)
                        if (activity.description != null && activity.description!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            activity.description!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms, delay: (animIndex * 30).ms).slideX(begin: 0.05);
  }

  void _showActivityDetails(CombinedActivityItem activity) {
    final config = _getActivityConfig(activity.type);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
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
                      // Type badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: config.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(config.icon, color: config.color, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  config.label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: config.color,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormat('MMMM d, y • h:mm a').format(activity.timestamp),
                                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Title
                      Text(
                        activity.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      // Description
                      if (activity.description != null && activity.description!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          activity.description!,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
  }

  _ActivityTypeConfig _getActivityConfig(String type) {
    switch (type.toLowerCase()) {
      case 'site_report':
        return _ActivityTypeConfig('Site Report', Icons.assignment, const Color(0xFF2563EB));
      case 'query':
        return _ActivityTypeConfig('Query', Icons.help_outline, const Color(0xFF7C3AED));
      case 'observation':
        return _ActivityTypeConfig('Observation', Icons.visibility, const Color(0xFFEA580C));
      case 'gallery':
        return _ActivityTypeConfig('Gallery', Icons.photo_library, const Color(0xFFEC4899));
      case 'quality_check':
        return _ActivityTypeConfig('Quality Check', Icons.verified, const Color(0xFF059669));
      case 'site_visit':
        return _ActivityTypeConfig('Site Visit', Icons.location_on, const Color(0xFFD97706));
      case 'document':
        return _ActivityTypeConfig('Document', Icons.description, const Color(0xFF0891B2));
      case 'all':
        return _ActivityTypeConfig('All', Icons.list, primaryColor);
      default:
        return _ActivityTypeConfig(
          type.replaceAll('_', ' ').split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' '),
          Icons.event_note,
          Colors.grey,
        );
    }
  }
}

class _ActivityTypeConfig {
  final String label;
  final IconData icon;
  final Color color;

  const _ActivityTypeConfig(this.label, this.icon, this.color);
}
