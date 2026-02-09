import 'package:flutter/material.dart';
import '../../../services/project_module_service.dart';
import '../../../services/auth_service.dart';
import '../../../config/api_config.dart';

class QualityChecksScreen extends StatefulWidget {
  final String projectId;
  const QualityChecksScreen({super.key, required this.projectId});
  @override
  State<QualityChecksScreen> createState() => _QualityChecksScreenState();
}
class _QualityChecksScreenState extends State<QualityChecksScreen> {
  ProjectModuleService? _service;
  List<dynamic> _checks = [];
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
      final checks = await _service!.getQualityChecks(widget.projectId);
      setState(() { _checks = checks; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(title: const Text('Quality Checks'), backgroundColor: const Color(0xFFD32F2F), foregroundColor: Colors.white),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('Error: $_error', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
                ]))
              : _checks.isEmpty
                  ? const Center(child: Text('No quality checks recorded yet', style: TextStyle(color: Colors.grey)))
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _checks.length,
                        itemBuilder: (context, index) {
                          final check = _checks[index];
                          final status = check['status'] ?? 'Pending';
                          final isPass = status.toString().toLowerCase().contains('pass') || status.toString().toLowerCase().contains('approved');
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Icon(isPass ? Icons.check_circle : Icons.pending, color: isPass ? Colors.green : Colors.orange, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(check['category'] ?? 'Quality Check', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: isPass ? Colors.green.shade50 : Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
                                      child: Text(status, style: TextStyle(color: isPass ? Colors.green.shade700 : Colors.orange.shade700, fontSize: 12, fontWeight: FontWeight.w600)),
                                    ),
                                  ]),
                                  if (check['description'] != null) ...[
                                    const SizedBox(height: 8),
                                    Text(check['description'], style: TextStyle(color: Colors.grey.shade600)),
                                  ],
                                  if (check['checkedBy'] != null) ...[
                                    const SizedBox(height: 8),
                                    Text('Inspected by: ${check['checkedBy']}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                  ],
                                  if (check['createdAt'] != null) ...[
                                    const SizedBox(height: 4),
                                    Text('Date: ${check['createdAt'].toString().split('T')[0]}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
