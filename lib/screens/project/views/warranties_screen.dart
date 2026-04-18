import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../constants.dart';
import '../../../services/auth_service.dart';
import '../../../services/project_module_service.dart';
import '../../../models/project_module_models.dart';
import '../../../config/api_config.dart';

class WarrantiesScreen extends StatefulWidget {
  final String projectId;

  const WarrantiesScreen({super.key, required this.projectId});

  @override
  State<WarrantiesScreen> createState() => _WarrantiesScreenState();
}

class _WarrantiesScreenState extends State<WarrantiesScreen> {
  bool _isLoading = true;
  String? _error;
  List<ProjectWarranty> _warranties = [];
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
      _loadWarranties();
    } else {
      setState(() {
        _error = 'Not authenticated';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadWarranties() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final warranties = await _service!.getWarranties(widget.projectId);
      setState(() {
        _warranties = warranties;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load warranties: $e';
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
          'Warranties',
          style: TextStyle(color: blackColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: surfaceColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: blackColor),
            onPressed: _loadWarranties,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : _error != null
              ? _buildErrorState()
              : _warranties.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadWarranties,
                      color: primaryColor,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _warranties.length,
                        itemBuilder: (context, index) =>
                            _buildWarrantyCard(_warranties[index], index),
                      ),
                    ),
    );
  }

  Widget _buildWarrantyCard(ProjectWarranty warranty, int index) {
    final statusColor = _statusColor(warranty.status);
    final dateFormat = DateFormat('MMM d, y');

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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.verified_user, color: statusColor, size: 22),
          ),
          title: Text(
            warranty.componentName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (warranty.providerName != null) ...[
                const SizedBox(height: 2),
                Text(
                  warranty.providerName!,
                  style: const TextStyle(color: blackColor60, fontSize: 12),
                ),
              ],
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      warranty.status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (warranty.startDate != null || warranty.endDate != null) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _dateRange(warranty.startDate, warranty.endDate, dateFormat),
                        style: const TextStyle(color: blackColor60, fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          childrenPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            if (warranty.description != null &&
                warranty.description!.isNotEmpty) ...[
              _buildDetailRow(
                icon: Icons.info_outline,
                label: 'Description',
                value: warranty.description!,
              ),
              const SizedBox(height: 8),
            ],
            if (warranty.coverageDetails != null &&
                warranty.coverageDetails!.isNotEmpty)
              _buildDetailRow(
                icon: Icons.shield_outlined,
                label: 'Coverage Details',
                value: warranty.coverageDetails!,
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms, delay: (index * 50).ms).slideX(begin: 0.05);
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style:
                      TextStyle(fontSize: 11, color: Colors.grey[500])),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(fontSize: 13, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_user_outlined, size: 60, color: blackColor40),
          SizedBox(height: 16),
          Text('No warranties found',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          SizedBox(height: 8),
          Text('Warranty records will appear here once added.',
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
            onPressed: _loadWarranties,
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return Colors.green;
      case 'EXPIRED':
        return Colors.red;
      case 'VOID':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _dateRange(DateTime? start, DateTime? end, DateFormat fmt) {
    if (start != null && end != null) {
      return '${fmt.format(start)} – ${fmt.format(end)}';
    } else if (start != null) {
      return 'From ${fmt.format(start)}';
    } else if (end != null) {
      return 'Until ${fmt.format(end)}';
    }
    return '';
  }
}
