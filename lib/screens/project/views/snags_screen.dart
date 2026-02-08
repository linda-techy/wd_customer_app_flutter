import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../constants.dart';
import '../../../services/auth_service.dart';
import '../../../services/project_module_service.dart';
import '../../../models/project_module_models.dart';
import '../../../config/api_config.dart';

class SnagsScreen extends StatefulWidget {
  final String projectId;

  const SnagsScreen({super.key, required this.projectId});

  @override
  State<SnagsScreen> createState() => _SnagsScreenState();
}

class _SnagsScreenState extends State<SnagsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = true;
  String? error;
  List<Observation> activeSnags = [];
  List<Observation> resolvedSnags = [];
  Map<String, int> counts = {'active': 0, 'resolved': 0, 'total': 0};
  ProjectModuleService? service;
  String? _authToken;

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
      setState(() {
        _authToken = token;
      });
      _loadSnags();
    } else {
      setState(() {
        error = 'Not authenticated';
        isLoading = false;
      });
    }
  }

  Future<void> _loadSnags() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // Load active, resolved snags and counts in parallel
      final results = await Future.wait([
        service!.getActiveObservations(widget.projectId),
        service!.getResolvedObservations(widget.projectId),
        service!.getObservationCounts(widget.projectId),
      ]);

      setState(() {
        activeSnags = results[0] as List<Observation>;
        resolvedSnags = results[1] as List<Observation>;
        counts = results[2] as Map<String, int>;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load snags: $e';
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
          "Snags / Observations",
          style: TextStyle(color: blackColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: surfaceColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: blackColor),
            onPressed: _loadSnags,
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
                      const Icon(Icons.warning_amber_rounded, size: 18),
                      const SizedBox(width: 6),
                      const Text('Active'),
                      if (counts['active']! > 0) ...[
                        const SizedBox(width: 6),
                        _buildBadge(counts['active']!, Colors.orange),
                      ],
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_outline, size: 18),
                      const SizedBox(width: 6),
                      const Text('Resolved'),
                      if (counts['resolved']! > 0) ...[
                        const SizedBox(width: 6),
                        _buildBadge(counts['resolved']!, Colors.green),
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
                    _buildSnagsList(activeSnags, isActive: true),
                    _buildSnagsList(resolvedSnags, isActive: false),
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
            onPressed: _loadSnags,
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSnagsList(List<Observation> snags, {required bool isActive}) {
    if (snags.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: (isActive ? Colors.orange : Colors.green).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isActive ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                size: 48,
                color: isActive ? Colors.orange : Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isActive ? 'No active snags' : 'No resolved snags',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              isActive
                  ? 'All issues have been resolved.'
                  : 'Resolved issues will appear here.',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSnags,
      color: primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(defaultPadding),
        itemCount: snags.length,
        itemBuilder: (context, index) {
          return _buildSnagCard(snags[index], index);
        },
      ),
    );
  }

  Widget _buildSnagCard(Observation snag, int index) {
    final priorityColor = _getPriorityColor(snag.priority);
    final statusColor = _getStatusColor(snag.status);

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
        onTap: () => _showSnagDetails(snag),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image if available
            if (snag.imagePath != null && snag.imagePath!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: _resolveUrl(snag.imagePath!),
                    httpHeaders: _authToken != null
                        ? {'Authorization': 'Bearer $_authToken'}
                        : null,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row: Title + Priority
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          snag.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: priorityColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          snag.priority.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: priorityColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Description
                  if (snag.description.isNotEmpty)
                    Text(
                      snag.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 12),
                  // Location
                  if (snag.location != null && snag.location!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            snag.location!,
                            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  // Footer: Status, Date, Reporter
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getStatusIcon(snag.status),
                              size: 12,
                              color: statusColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              snag.status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM d, y').format(snag.reportedDate),
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                      const Spacer(),
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.grey[200],
                        child: Text(
                          snag.reportedByName.isNotEmpty
                              ? snag.reportedByName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          snag.reportedByName,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
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
    ).animate().fadeIn(duration: 300.ms, delay: (index * 50).ms).slideY(begin: 0.1);
  }

  void _showSnagDetails(Observation snag) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SnagDetailsSheet(
        snag: snag,
        authToken: _authToken,
        resolveUrl: _resolveUrl,
      ),
    );
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toUpperCase()) {
      case 'HIGH':
      case 'CRITICAL':
        return Colors.red;
      case 'MEDIUM':
        return Colors.orange;
      case 'LOW':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'OPEN':
        return Colors.orange;
      case 'IN_PROGRESS':
        return Colors.blue;
      case 'RESOLVED':
      case 'CLOSED':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toUpperCase()) {
      case 'OPEN':
        return Icons.warning_amber_rounded;
      case 'IN_PROGRESS':
        return Icons.hourglass_empty;
      case 'RESOLVED':
      case 'CLOSED':
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  String _resolveUrl(String url) {
    if (url.startsWith('http')) return url;
    final baseUrl = ApiConfig.baseUrl;
    final cleanBase =
        baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final cleanUrl = url.startsWith('/') ? url : '/$url';
    return '$cleanBase$cleanUrl';
  }
}

class _SnagDetailsSheet extends StatelessWidget {
  final Observation snag;
  final String? authToken;
  final String Function(String) resolveUrl;

  const _SnagDetailsSheet({
    required this.snag,
    this.authToken,
    required this.resolveUrl,
  });

  @override
  Widget build(BuildContext context) {
    final isResolved = snag.status.toUpperCase() == 'RESOLVED' ||
        snag.status.toUpperCase() == 'CLOSED';

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
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
                    // Image
                    if (snag.imagePath != null && snag.imagePath!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: CachedNetworkImage(
                            imageUrl: resolveUrl(snag.imagePath!),
                            httpHeaders: authToken != null
                                ? {'Authorization': 'Bearer $authToken'}
                                : null,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    // Title
                    Text(
                      snag.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Priority and Status Chips
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildChip(
                          snag.priority.toUpperCase(),
                          _getPriorityColor(snag.priority),
                        ),
                        _buildChip(
                          snag.status,
                          _getStatusColor(snag.status),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Description
                    if (snag.description.isNotEmpty) ...[
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
                        snag.description,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF374151),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    // Location
                    if (snag.location != null && snag.location!.isNotEmpty)
                      _buildDetailRow(
                        Icons.location_on_outlined,
                        'Location',
                        snag.location!,
                      ),
                    // Reported By
                    _buildDetailRow(
                      Icons.person_outline,
                      'Reported By',
                      '${snag.reportedByName}${snag.reportedByRoleName != null ? ' (${snag.reportedByRoleName})' : ''}',
                    ),
                    // Reported Date
                    _buildDetailRow(
                      Icons.calendar_today_outlined,
                      'Reported Date',
                      DateFormat('MMMM d, y').format(snag.reportedDate),
                    ),
                    // Resolution Section
                    if (isResolved) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Resolution Details',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (snag.resolvedDate != null)
                              _buildMiniDetailRow(
                                'Resolved On',
                                DateFormat('MMMM d, y').format(snag.resolvedDate!),
                              ),
                            if (snag.resolvedByName != null)
                              _buildMiniDetailRow('Resolved By', snag.resolvedByName!),
                            if (snag.resolutionNotes != null &&
                                snag.resolutionNotes!.isNotEmpty)
                              _buildMiniDetailRow('Notes', snag.resolutionNotes!),
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

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
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

  Widget _buildMiniDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toUpperCase()) {
      case 'HIGH':
      case 'CRITICAL':
        return Colors.red;
      case 'MEDIUM':
        return Colors.orange;
      case 'LOW':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'OPEN':
        return Colors.orange;
      case 'IN_PROGRESS':
        return Colors.blue;
      case 'RESOLVED':
      case 'CLOSED':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
