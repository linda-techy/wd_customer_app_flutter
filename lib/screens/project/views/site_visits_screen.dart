import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../constants.dart';
import '../../../services/auth_service.dart';
import '../../../services/project_module_service.dart';
import '../../../models/project_module_models.dart';
import '../../../config/api_config.dart';

class SiteVisitsScreen extends StatefulWidget {
  final String projectId;

  const SiteVisitsScreen({super.key, required this.projectId});

  @override
  State<SiteVisitsScreen> createState() => _SiteVisitsScreenState();
}

class _SiteVisitsScreenState extends State<SiteVisitsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = true;
  String? error;
  List<SiteVisit> completedVisits = [];
  List<SiteVisit> ongoingVisits = [];
  ProjectModuleService? service;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initialize();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    final token = await AuthService.getAccessToken();
    if (token != null) {
      service = ProjectModuleService(
        baseUrl: ApiConfig.baseUrl,
        token: token,
      );
      _loadVisits();
    } else {
      setState(() {
        error = 'Not authenticated';
        isLoading = false;
      });
    }
  }

  Future<void> _loadVisits() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // Load completed and ongoing visits in parallel
      final results = await Future.wait([
        service!.getCompletedSiteVisits(widget.projectId),
        service!.getOngoingSiteVisits(widget.projectId),
      ]);

      setState(() {
        completedVisits = results[0];
        ongoingVisits = results[1];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load site visits: $e';
        isLoading = false;
      });
    }
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
        title: const Text(
          "Site Visits",
          style: TextStyle(color: blackColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: surfaceColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: blackColor),
            onPressed: _loadVisits,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: primaryColor,
              indicatorWeight: 3,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_outline, size: 18),
                      const SizedBox(width: 6),
                      const Text('Completed'),
                      if (completedVisits.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        _buildBadge(completedVisits.length, Colors.green),
                      ],
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timelapse, size: 18),
                      const SizedBox(width: 6),
                      const Text('Ongoing'),
                      if (ongoingVisits.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        _buildBadge(ongoingVisits.length, Colors.blue),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : error != null
              ? _buildErrorState()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildVisitsList(completedVisits, isCompleted: true),
                    _buildVisitsList(ongoingVisits, isCompleted: false),
                  ],
                ),
    );
  }

  Widget _buildBadge(int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
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
          Text(error!, style: const TextStyle(color: errorColor)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadVisits,
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitsList(List<SiteVisit> visits, {required bool isCompleted}) {
    if (visits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: (isCompleted ? Colors.green : Colors.blue).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.check_circle_outline : Icons.timelapse,
                size: 48,
                color: isCompleted ? Colors.green : Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isCompleted ? 'No completed visits' : 'No ongoing visits',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              isCompleted
                  ? 'Completed site visits will appear here.'
                  : 'Ongoing site visits will appear here.',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadVisits,
      color: primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(defaultPadding),
        itemCount: visits.length,
        itemBuilder: (context, index) {
          return _buildVisitCard(visits[index], index, isCompleted: isCompleted);
        },
      ),
    );
  }

  Widget _buildVisitCard(SiteVisit visit, int index, {required bool isCompleted}) {
    final duration = _calculateDuration(visit);

    return Container(
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
      child: InkWell(
        onTap: () => _showVisitDetails(visit),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Visitor Name + Status
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: primaryColor.withOpacity(0.1),
                    child: Text(
                      visit.visitorName.isNotEmpty
                          ? visit.visitorName[0].toUpperCase()
                          : 'V',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          visit.visitorName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        if (visit.visitorRoleName != null)
                          Text(
                            visit.visitorRoleName!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green.withOpacity(0.1)
                          : Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCompleted ? Icons.check_circle : Icons.timelapse,
                          size: 14,
                          color: isCompleted ? Colors.green : Colors.blue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isCompleted ? 'Completed' : 'Ongoing',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isCompleted ? Colors.green : Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Visit Times
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTimeBlock(
                        'Check-in',
                        DateFormat('h:mm a').format(visit.checkInTime),
                        DateFormat('MMM d, y').format(visit.checkInTime),
                        Icons.login,
                        Colors.green,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey[300],
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    Expanded(
                      child: visit.checkOutTime != null
                          ? _buildTimeBlock(
                              'Check-out',
                              DateFormat('h:mm a').format(visit.checkOutTime!),
                              DateFormat('MMM d, y').format(visit.checkOutTime!),
                              Icons.logout,
                              Colors.red,
                            )
                          : _buildTimeBlock(
                              'Check-out',
                              '--:-- --',
                              'Still on site',
                              Icons.logout,
                              Colors.grey,
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Duration and Purpose
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 6),
                  Text(
                    'Duration: $duration',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (visit.purpose != null && visit.purpose!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.description_outlined, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        visit.purpose!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              // GPS Distance Info
              if (visit.formattedCheckInDistance != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.gps_fixed, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 6),
                    Text(
                      'Check-in: ${visit.formattedCheckInDistance} from site',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    if (visit.formattedCheckOutDistance != null) ...[
                      const SizedBox(width: 12),
                      Text(
                        'Check-out: ${visit.formattedCheckOutDistance}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (index * 50).ms).slideY(begin: 0.1);
  }

  Widget _buildTimeBlock(
      String label, String time, String date, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        Text(
          date,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  String _calculateDuration(SiteVisit visit) {
    final endTime = visit.checkOutTime ?? DateTime.now();
    final duration = endTime.difference(visit.checkInTime);

    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  void _showVisitDetails(SiteVisit visit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SiteVisitDetailsSheet(visit: visit),
    );
  }
}

class _SiteVisitDetailsSheet extends StatelessWidget {
  final SiteVisit visit;

  const _SiteVisitDetailsSheet({required this.visit});

  @override
  Widget build(BuildContext context) {
    final isCompleted = visit.checkOutTime != null;
    final duration = _calculateDuration(visit);

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
                    // Header
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: primaryColor.withOpacity(0.1),
                          child: Text(
                            visit.visitorName.isNotEmpty
                                ? visit.visitorName[0].toUpperCase()
                                : 'V',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                visit.visitorName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              if (visit.visitorRoleName != null)
                                Text(
                                  visit.visitorRoleName!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Status Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: (isCompleted ? Colors.green : Colors.blue)
                            .withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              (isCompleted ? Colors.green : Colors.blue).withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isCompleted ? Icons.check_circle : Icons.timelapse,
                            color: isCompleted ? Colors.green : Colors.blue,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isCompleted ? 'Visit Completed' : 'Currently On Site',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isCompleted ? Colors.green : Colors.blue,
                                  ),
                                ),
                                Text(
                                  'Duration: $duration',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Visit Details
                    _buildDetailRow(
                      Icons.login,
                      'Check-in Time',
                      DateFormat('MMMM d, y • h:mm a').format(visit.checkInTime),
                    ),
                    if (visit.checkOutTime != null)
                      _buildDetailRow(
                        Icons.logout,
                        'Check-out Time',
                        DateFormat('MMMM d, y • h:mm a').format(visit.checkOutTime!),
                      ),
                    if (visit.purpose != null && visit.purpose!.isNotEmpty)
                      _buildDetailRow(
                        Icons.description_outlined,
                        'Purpose of Visit',
                        visit.purpose!,
                      ),
                    if (visit.notes != null && visit.notes!.isNotEmpty)
                      _buildDetailRow(
                        Icons.notes,
                        'Notes',
                        visit.notes!,
                      ),
                    // GPS Location Details
                    if (visit.checkInLatitude != null && visit.checkInLongitude != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.gps_fixed, size: 16, color: Colors.grey[700]),
                                const SizedBox(width: 8),
                                Text(
                                  'GPS Location Data',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _buildGpsRow(
                              'Check-in',
                              visit.checkInLatitude!,
                              visit.checkInLongitude!,
                              visit.formattedCheckInDistance,
                            ),
                            if (visit.checkOutLatitude != null && visit.checkOutLongitude != null) ...[
                              const SizedBox(height: 6),
                              _buildGpsRow(
                                'Check-out',
                                visit.checkOutLatitude!,
                                visit.checkOutLongitude!,
                                visit.formattedCheckOutDistance,
                              ),
                            ],
                          ],
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
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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

  Widget _buildGpsRow(String label, double lat, double lng, String? distance) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
        Expanded(
          child: Text(
            '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}',
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
          ),
        ),
        if (distance != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              distance,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
          ),
      ],
    );
  }

  String _calculateDuration(SiteVisit visit) {
    final endTime = visit.checkOutTime ?? DateTime.now();
    final duration = endTime.difference(visit.checkInTime);

    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h ${duration.inMinutes % 60}m';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes} minutes';
    }
  }
}
