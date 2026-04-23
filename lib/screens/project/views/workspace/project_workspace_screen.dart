import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../providers/project_workspace_provider.dart';
import '_placeholder_tab.dart';

class ProjectWorkspaceScreen extends StatefulWidget {
  final String projectUuid;
  const ProjectWorkspaceScreen({super.key, required this.projectUuid});

  @override
  State<ProjectWorkspaceScreen> createState() => _ProjectWorkspaceScreenState();
}

class _ProjectWorkspaceScreenState extends State<ProjectWorkspaceScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProjectWorkspaceProvider>(
      create: (ctx) {
        final provider = ProjectWorkspaceProvider(widget.projectUuid);
        provider.load();
        return provider;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Project Workspace')),
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            PlaceholderTab(title: 'Info'), // Task 14 will swap to ProjectInfoTab
            PlaceholderTab(title: 'Timeline'),
            PlaceholderTab(title: 'Queries'),
            PlaceholderTab(title: 'Live'),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: 'Info'),
            BottomNavigationBarItem(icon: Icon(Icons.timeline), label: 'Timeline'),
            BottomNavigationBarItem(icon: Icon(Icons.question_answer), label: 'Queries'),
            BottomNavigationBarItem(icon: Icon(Icons.videocam), label: 'Live'),
          ],
        ),
      ),
    );
  }
}
