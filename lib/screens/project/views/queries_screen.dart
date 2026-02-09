import 'package:flutter/material.dart';
import '../../../services/project_module_service.dart';
import '../../../services/auth_service.dart';
import '../../../config/api_config.dart';

class QueriesScreen extends StatefulWidget {
  final String projectId;
  const QueriesScreen({super.key, required this.projectId});
  @override
  State<QueriesScreen> createState() => _QueriesScreenState();
}
class _QueriesScreenState extends State<QueriesScreen> {
  ProjectModuleService? _service;
  List<dynamic> _queries = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() { super.initState(); _initService(); }

  Future<void> _initService() async {
    final token = await AuthService.getAccessToken();
    _service = ProjectModuleService(baseUrl: ApiConfig.baseUrl, token: token);
    _loadData();
  }

  Future<void> _loadData() async {
    if (_service == null) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final queries = await _service!.getQueries(widget.projectId);
      setState(() { _queries = queries; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  void _showCreateQueryDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Raise a Query'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Subject', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()), maxLines: 3),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD32F2F)),
            onPressed: () async {
              if (titleController.text.isEmpty) return;
              try {
                await _service!.createQuery(widget.projectId, titleController.text, descController.text, 'medium');
                if (ctx.mounted) Navigator.pop(ctx);
                _loadData();
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Query submitted successfully')));
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(title: const Text('Queries'), backgroundColor: const Color(0xFFD32F2F), foregroundColor: Colors.white),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateQueryDialog,
        backgroundColor: const Color(0xFFD32F2F),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Query', style: TextStyle(color: Colors.white)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text('Error: $_error'), const SizedBox(height: 16), ElevatedButton(onPressed: _loadData, child: const Text('Retry'))]))
              : _queries.isEmpty
                  ? const Center(child: Text('No queries yet. Tap + to raise one.', style: TextStyle(color: Colors.grey)))
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _queries.length,
                        itemBuilder: (context, index) {
                          final query = _queries[index];
                          final status = query['status']?.toString() ?? 'Open';
                          final isResolved = status.toLowerCase().contains('resolved') || status.toLowerCase().contains('closed');
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(children: [
                                  Icon(isResolved ? Icons.check_circle : Icons.help_outline, color: isResolved ? Colors.green : Colors.blue, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(query['title'] ?? 'Query', style: const TextStyle(fontWeight: FontWeight.bold))),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: isResolved ? Colors.green.shade50 : Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                                    child: Text(status, style: TextStyle(color: isResolved ? Colors.green.shade700 : Colors.blue.shade700, fontSize: 12, fontWeight: FontWeight.w600)),
                                  ),
                                ]),
                                if (query['description'] != null) ...[const SizedBox(height: 8), Text(query['description'], style: TextStyle(color: Colors.grey.shade600))],
                                if (query['response'] != null) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      const Text('Response:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                      const SizedBox(height: 4),
                                      Text(query['response'], style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                                    ]),
                                  ),
                                ],
                                if (query['createdAt'] != null) ...[const SizedBox(height: 8), Text('Submitted: ${query['createdAt'].toString().split('T')[0]}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12))],
                              ]),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
