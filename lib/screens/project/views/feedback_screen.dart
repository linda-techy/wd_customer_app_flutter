import 'package:flutter/material.dart';
import '../../../services/project_module_service.dart';
import '../../../services/auth_service.dart';
import '../../../config/api_config.dart';

class FeedbackScreen extends StatefulWidget {
  final String projectId;
  const FeedbackScreen({super.key, required this.projectId});
  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}
class _FeedbackScreenState extends State<FeedbackScreen> {
  ProjectModuleService? _service;
  List<dynamic> _forms = [];
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
      final forms = await _service!.getFeedbackForms(widget.projectId);
      setState(() { _forms = forms; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  void _showFeedbackDialog(dynamic form) {
    final ratingNotifier = ValueNotifier<int>(0);
    final commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(form['title'] ?? 'Feedback'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          if (form['description'] != null) ...[Text(form['description'], style: TextStyle(color: Colors.grey.shade600)), const SizedBox(height: 16)],
          const Text('Your Rating:', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ValueListenableBuilder<int>(
            valueListenable: ratingNotifier,
            builder: (_, rating, __) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) => IconButton(
                icon: Icon(i < rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 32),
                onPressed: () => ratingNotifier.value = i + 1,
              )),
            ),
          ),
          const SizedBox(height: 12),
          TextField(controller: commentController, decoration: const InputDecoration(labelText: 'Comments (optional)', border: OutlineInputBorder()), maxLines: 3),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD32F2F)),
            onPressed: () async {
              if (ratingNotifier.value == 0) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a rating')));
                return;
              }
              try {
                await _service!.submitFeedback(widget.projectId, form['id'] as int, rating: ratingNotifier.value, comments: commentController.text);
                if (ctx.mounted) Navigator.pop(ctx);
                _loadData();
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feedback submitted successfully')));
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
      appBar: AppBar(title: const Text('Feedback'), backgroundColor: const Color(0xFFD32F2F), foregroundColor: Colors.white),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text('Error: $_error'), const SizedBox(height: 16), ElevatedButton(onPressed: _loadData, child: const Text('Retry'))]))
              : _forms.isEmpty
                  ? const Center(child: Text('No feedback forms available', style: TextStyle(color: Colors.grey)))
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _forms.length,
                        itemBuilder: (context, index) {
                          final form = _forms[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(backgroundColor: const Color(0xFFD32F2F).withOpacity(0.1), child: const Icon(Icons.feedback, color: Color(0xFFD32F2F))),
                              title: Text(form['title'] ?? 'Feedback Form', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: form['description'] != null ? Text(form['description'], maxLines: 2, overflow: TextOverflow.ellipsis) : null,
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => _showFeedbackDialog(form),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
