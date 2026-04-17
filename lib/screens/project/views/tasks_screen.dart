import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../services/auth_service.dart';
import '../../../services/project_module_service.dart';
import '../../../models/task_models.dart';
import '../../../config/api_config.dart';
import 'task_list_view.dart';

class TasksScreen extends StatefulWidget {
  final String projectId;

  const TasksScreen({super.key, required this.projectId});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  bool isLoading = true;
  String? error;
  List<ProjectTask> tasks = [];
  ProjectModuleService? service;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final token = await AuthService.getAccessToken();
    if (token != null) {
      service = ProjectModuleService(
        baseUrl: ApiConfig.baseUrl,
        token: token,
      );
      _loadTasks();
    } else {
      setState(() {
        error = 'Not authenticated';
        isLoading = false;
      });
    }
  }

  Future<void> _loadTasks() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });
      final result = await service!.getProjectTasks(widget.projectId);
      setState(() {
        tasks = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load tasks: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        title: const Text('Tasks', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: surfaceColor,
        elevation: 0,
        foregroundColor: blackColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: errorColor),
                      const SizedBox(height: 16),
                      Text(error!, style: const TextStyle(color: errorColor)),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadTasks,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : TaskListView(tasks: tasks),
    );
  }
}
