import 'package:flutter/material.dart';
import '../../../services/project_module_service.dart';
import '../../../services/auth_service.dart';
import '../../../config/api_config.dart';

class SiteVisitsListScreen extends StatefulWidget {
  final String projectId;
  const SiteVisitsListScreen({super.key, required this.projectId});
  @override
  State<SiteVisitsListScreen> createState() => _SiteVisitsListScreenState();
}
class _SiteVisitsListScreenState extends State<SiteVisitsListScreen> with SingleTickerProviderStateMixin {
  ProjectModuleService? _service;
  late TabController _tabController;
  List<dynamic> _allVisits = [];
  List<dynamic> _completedVisits = [];
  List<dynamic> _ongoingVisits = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initService();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initService() async {
    final token = await AuthService.getAccessToken();
    _service = ProjectModuleService(baseUrl: ApiConfig.baseUrl, token: token);
    _loadData();
  }

  Future<void> _loadData() async {
    if (_service == null) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final all = await _service!.getSiteVisits(widget.projectId);
      final completed = await _service!.getCompletedSiteVisits(widget.projectId);
      final ongoing = await _service!.getOngoingSiteVisits(widget.projectId);
      setState(() { _allVisits = all; _completedVisits = completed; _ongoingVisits = ongoing; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Widget _buildVisitList(List<dynamic> visits) {
    if (visits.isEmpty) {
      return const Center(child: Text('No site visits found', style: TextStyle(color: Colors.grey)));
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: visits.length,
        itemBuilder: (context, index) {
          final visit = visits[index];
          final status = visit['status']?.toString() ?? '';
          final isComplete = status.toLowerCase().contains('complete') || status.toLowerCase().contains('checked_out');
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(isComplete ? Icons.check_circle : Icons.location_on, color: isComplete ? Colors.green : Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(visit['purpose'] ?? 'Site Visit', style: const TextStyle(fontWeight: FontWeight.bold))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: isComplete ? Colors.green.shade50 : Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
                      child: Text(status, style: TextStyle(color: isComplete ? Colors.green.shade700 : Colors.orange.shade700, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  if (visit['checkInTime'] != null)
                    Text('Check-in: ${visit['checkInTime'].toString().split('T').join(' ').substring(0, 16)}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  if (visit['checkOutTime'] != null)
                    Text('Check-out: ${visit['checkOutTime'].toString().split('T').join(' ').substring(0, 16)}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  if (visit['notes'] != null && visit['notes'].toString().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(visit['notes'], style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                  ],
                  if (visit['visitedBy'] != null) ...[
                    const SizedBox(height: 4),
                    Text('Visited by: ${visit['visitedBy']}', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Site Visits'),
        backgroundColor: const Color(0xFFD32F2F),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'All (${_allVisits.length})'),
            Tab(text: 'Ongoing (${_ongoingVisits.length})'),
            Tab(text: 'Completed (${_completedVisits.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('Error: $_error', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
                ]))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildVisitList(_allVisits),
                    _buildVisitList(_ongoingVisits),
                    _buildVisitList(_completedVisits),
                  ],
                ),
    );
  }
}
