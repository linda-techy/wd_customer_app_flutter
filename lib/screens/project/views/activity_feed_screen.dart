import 'package:flutter/material.dart';
import '../../../services/project_module_service.dart';
import '../../../services/auth_service.dart';
import '../../../config/api_config.dart';

class ActivityFeedScreen extends StatefulWidget {
  final String projectId;
  const ActivityFeedScreen({super.key, required this.projectId});
  @override
  State<ActivityFeedScreen> createState() => _ActivityFeedScreenState();
}
class _ActivityFeedScreenState extends State<ActivityFeedScreen> {
  ProjectModuleService? _service;
  Map<String, List<dynamic>> _groupedActivities = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initService();
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
      final grouped = await _service!.getCombinedActivitiesGrouped(widget.projectId);
      // Convert Map<DateTime, List<CombinedActivityItem>> to Map<String, List<dynamic>>
      final converted = <String, List<dynamic>>{};
      grouped.forEach((key, value) {
        converted[key.toIso8601String().split('T')[0]] = value.map((e) => {
          'type': e.type,
          'description': e.description ?? e.title,
          'timestamp': e.timestamp.toIso8601String(),
        }).toList();
      });
      setState(() { _groupedActivities = converted; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'document': return Icons.description;
      case 'gallery': return Icons.photo;
      case 'observation': return Icons.visibility;
      case 'site_visit': return Icons.place;
      case 'quality_check': return Icons.verified;
      default: return Icons.event_note;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(title: const Text('Activity Feed'), backgroundColor: const Color(0xFFD32F2F), foregroundColor: Colors.white),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('Error: $_error', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
                ]))
              : _groupedActivities.isEmpty
                  ? const Center(child: Text('No activities recorded yet', style: TextStyle(color: Colors.grey)))
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _groupedActivities.keys.length,
                        itemBuilder: (context, groupIndex) {
                          final date = _groupedActivities.keys.elementAt(groupIndex);
                          final activities = _groupedActivities[date]!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Text(date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFD32F2F))),
                              ),
                              ...activities.map((activity) {
                                final type = activity['type']?.toString() ?? 'activity';
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: const Color(0xFFD32F2F).withOpacity(0.1),
                                      child: Icon(_getActivityIcon(type), color: const Color(0xFFD32F2F), size: 20),
                                    ),
                                    title: Text(activity['description']?.toString() ?? type, style: const TextStyle(fontSize: 14)),
                                    subtitle: Text(activity['timestamp']?.toString().split('T')[0] ?? '', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                                      child: Text(type, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(height: 8),
                            ],
                          );
                        },
                      ),
                    ),
    );
  }
}
