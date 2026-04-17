import 'package:flutter/material.dart';
import '../../../models/task_models.dart';

class TaskListView extends StatelessWidget {
  final List<ProjectTask> tasks;

  const TaskListView({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text('No tasks yet', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              color: task.isCompleted ? Colors.green
                  : task.isOverdue ? Colors.red
                  : Colors.orange,
            ),
            title: Text(
              task.title,
              style: TextStyle(
                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Text(
              '${task.priority} · Due: ${task.dueDate ?? "N/A"}',
              style: TextStyle(
                color: task.isOverdue ? Colors.red : null,
              ),
            ),
            trailing: Chip(
              label: Text(task.status, style: const TextStyle(fontSize: 10)),
              backgroundColor: _statusColor(task.status),
            ),
          ),
        );
      },
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'COMPLETED': return Colors.green.shade100;
      case 'IN_PROGRESS': return Colors.blue.shade100;
      case 'CANCELLED': return Colors.grey.shade300;
      default: return Colors.orange.shade100;
    }
  }
}
