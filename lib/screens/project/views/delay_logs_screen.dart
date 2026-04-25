import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../constants.dart';
import '../../../services/auth_service.dart';
import '../../../services/project_module_service.dart';
import '../../../models/project_module_models.dart';
import '../../../config/api_config.dart';

class DelayLogsScreen extends StatefulWidget {
  final String projectId;

  const DelayLogsScreen({super.key, required this.projectId});

  @override
  State<DelayLogsScreen> createState() => _DelayLogsScreenState();
}

class _DelayLogsScreenState extends State<DelayLogsScreen> {
  bool _isLoading = true;
  String? _error;
  List<DelayLog> _delays = [];
  ProjectModuleService? _service;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final token = await AuthService.getAccessToken();
    if (token != null) {
      _service = ProjectModuleService(
        baseUrl: ApiConfig.baseUrl,
        token: token,
      );
      _loadDelayLogs();
    } else {
      setState(() {
        _error = 'Not authenticated';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDelayLogs() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final delays = await _service!.getDelayLogs(widget.projectId);
      setState(() {
        _delays = delays;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load delay logs: $e';
        _isLoading = false;
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
          'Delay Logs',
          style: TextStyle(color: blackColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: surfaceColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: blackColor),
            onPressed: _loadDelayLogs,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : _error != null
              ? _buildErrorState()
              : _delays.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadDelayLogs,
                      color: primaryColor,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _delays.length,
                        itemBuilder: (context, index) =>
                            _buildDelayCard(_delays[index], index),
                      ),
                    ),
    );
  }

  Widget _buildDelayCard(DelayLog delay, int index) {
    final typeColor = _typeColor(delay.delayType);
    final dateFormat = DateFormat('MMM d, y');

    final String durationText;
    if (delay.isOpen) {
      final days = DateTime.now().difference(delay.fromDate).inDays;
      durationText = '$days day${days == 1 ? '' : 's'} (ongoing)';
    } else {
      durationText = '${delay.impactDays} day${delay.impactDays == 1 ? '' : 's'}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: typeColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: type badge + status badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _formatType(delay.delayType),
                  style: TextStyle(
                    color: typeColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (delay.isOpen ? Colors.amber : Colors.grey)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  delay.isOpen ? 'Ongoing' : 'Resolved',
                  style: TextStyle(
                    color: delay.isOpen ? Colors.amber[800] : Colors.grey[600],
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              // Duration chip
              Row(
                children: [
                  Icon(Icons.schedule, size: 13, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    durationText,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          // Impact-on-handover badge (primary customer-facing signal)
          if (delay.impactOnHandover != null) ...[
            const SizedBox(height: 10),
            _buildImpactBadge(delay.impactOnHandover!),
          ],
          // Curated customer summary
          if (delay.customerSummary != null && delay.customerSummary!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              delay.customerSummary!,
              style: const TextStyle(fontSize: 14, height: 1.4),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          // Date range
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 13, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                _dateRange(delay.fromDate, delay.toDate, dateFormat),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms, delay: (index * 50).ms).slideX(begin: 0.05);
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.schedule_outlined, size: 60, color: blackColor40),
          SizedBox(height: 16),
          Text('No delay logs found',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          SizedBox(height: 8),
          Text('Delay records will appear here once logged.',
              textAlign: TextAlign.center,
              style: TextStyle(color: blackColor60, fontSize: 13)),
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
          Text(_error!, style: const TextStyle(color: errorColor)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadDelayLogs,
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactBadge(String impact) {
    final Color color;
    final String label;
    switch (impact) {
      case 'MATERIAL':
        color = Colors.red;
        label = 'Handover impact: material (date may change)';
        break;
      case 'MINOR':
        color = Colors.orange;
        label = 'Handover impact: minor (<1 week)';
        break;
      case 'NONE':
      default:
        color = Colors.green;
        label = 'No impact on handover date';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type.toUpperCase()) {
      case 'WEATHER':
        return Colors.blue;
      case 'LABOUR_STRIKE':
        return Colors.red;
      case 'MATERIAL_DELAY':
        return Colors.orange;
      case 'CLIENT_APPROVAL':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatType(String type) {
    return type
        .split('_')
        .map((w) => w.isEmpty
            ? ''
            : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  String _dateRange(DateTime from, DateTime? to, DateFormat fmt) {
    if (to != null) {
      return '${fmt.format(from)} – ${fmt.format(to)}';
    }
    return 'From ${fmt.format(from)}';
  }
}
