import 'package:flutter/material.dart';
import '../../../services/project_module_service.dart';
import '../../../services/auth_service.dart';
import '../../../config/api_config.dart';

class ObservationsScreen extends StatefulWidget {
  final String projectId;
  const ObservationsScreen({super.key, required this.projectId});
  @override
  State<ObservationsScreen> createState() => _ObservationsScreenState();
}
class _ObservationsScreenState extends State<ObservationsScreen> with SingleTickerProviderStateMixin {
  ProjectModuleService? _service;
  late TabController _tabController;
  List<dynamic> _active = [];
  List<dynamic> _resolved = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initService();
  }
  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  Future<void> _initService() async {
    final token = await AuthService.getAccessToken();
    _service = ProjectModuleService(baseUrl: ApiConfig.baseUrl, token: token);
    _loadData();
  }

  Future<void> _loadData() async {
    if (_service == null) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final active = await _service!.getActiveObservations(widget.projectId);
      final resolved = await _service!.getResolvedObservations(widget.projectId);
      setState(() { _active = active; _resolved = resolved; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Widget _buildObservationList(List<dynamic> observations, {bool isResolved = false}) {
    if (observations.isEmpty) {
      return Center(child: Text(isResolved ? 'No resolved observations' : 'No active observations', style: const TextStyle(color: Colors.grey)));
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: observations.length,
        itemBuilder: (context, index) {
          final obs = observations[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(isResolved ? Icons.check_circle : Icons.warning_amber_rounded, color: isResolved ? Colors.green : Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(obs['title'] ?? obs['category'] ?? 'Observation', style: const TextStyle(fontWeight: FontWeight.bold))),
                ]),
                if (obs['description'] != null) ...[const SizedBox(height: 8), Text(obs['description'], style: TextStyle(color: Colors.grey.shade600))],
                if (obs['observedBy'] != null) ...[const SizedBox(height: 8), Text('Observed by: ${obs['observedBy']}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12))],
                if (obs['createdAt'] != null) Text('Date: ${obs['createdAt'].toString().split('T')[0]}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ]),
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
        title: const Text('Observations'),
        backgroundColor: const Color(0xFFD32F2F),
        foregroundColor: Colors.white,
        bottom: TabBar(controller: _tabController, indicatorColor: Colors.white, labelColor: Colors.white, unselectedLabelColor: Colors.white70,
          tabs: [Tab(text: 'Active (${_active.length})'), Tab(text: 'Resolved (${_resolved.length})')]),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text('Error: $_error'), const SizedBox(height: 16), ElevatedButton(onPressed: _loadData, child: const Text('Retry'))]))
              : TabBarView(controller: _tabController, children: [_buildObservationList(_active), _buildObservationList(_resolved, isResolved: true)]),
    );
  }
}
