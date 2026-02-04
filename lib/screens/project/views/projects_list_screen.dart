import 'dart:async';
import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../models/api_models.dart';
import '../../../route/route_constants.dart';
import '../../../services/dashboard_service.dart';
import '../../../widgets/auth_guard.dart';
import '../../../components/molecules/responsive_project_card.dart';

/// Full projects list with server-side search. Used from dashboard "View All".
class ProjectsListScreen extends StatefulWidget {
  const ProjectsListScreen({super.key});

  @override
  State<ProjectsListScreen> createState() => _ProjectsListScreenState();
}

class _ProjectsListScreenState extends State<ProjectsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ProjectCard> _projects = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _lastQuery = '';
  static const _searchDebounceMs = 400;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadProjects(null);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {}); // Update clear button visibility
    _debounceTimer?.cancel();
    final q = _searchController.text.trim();
    _debounceTimer = Timer(
      const Duration(milliseconds: _searchDebounceMs),
      () {
        if (!mounted) return;
        if (q != _lastQuery) _loadProjects(q.isEmpty ? null : q);
      },
    );
  }

  Future<void> _loadProjects(String? query) async {
    setState(() {
      _lastQuery = query ?? '';
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await DashboardService.searchProjects(query);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        if (response.success && response.data != null) {
          _projects = response.data!;
        } else {
          _projects = [];
          _errorMessage = response.error?.message;
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _projects = [];
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('All Projects'),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name, code or location...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.trim().isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            _loadProjects(null);
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: blackColor.withOpacity(0.08)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: blackColor.withOpacity(0.08)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: primaryColor, width: 1.5),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onSubmitted: (value) => _loadProjects(value.trim().isEmpty ? null : value.trim()),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                          ),
                          SizedBox(height: 16),
                          Text('Loading projects...'),
                        ],
                      ),
                    )
                  : _errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.cloud_off_rounded, size: 48, color: errorColor),
                                const SizedBox(height: 12),
                                Text(
                                  _errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: blackColor60),
                                ),
                                const SizedBox(height: 16),
                                TextButton.icon(
                                  onPressed: () => _loadProjects(_searchController.text.trim().isEmpty ? null : _searchController.text.trim()),
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _projects.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.folder_open_rounded, size: 64, color: greyColor),
                                  const SizedBox(height: 16),
                                  Text(
                                    _lastQuery.isEmpty
                                        ? 'No projects yet'
                                        : 'No projects match your search',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _lastQuery.isEmpty
                                        ? 'Your projects will appear here.'
                                        : 'Try a different name, code or location.',
                                    style: TextStyle(color: greyColor),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: () => _loadProjects(
                                _searchController.text.trim().isEmpty
                                    ? null
                                    : _searchController.text.trim(),
                              ),
                              color: primaryColor,
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                                itemCount: _projects.length,
                                itemBuilder: (context, index) {
                                  final project = _projects[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: ResponsiveProjectCard(
                                      project: project,
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          projectDetailsRoute(
                                            project.projectUuid ?? '',
                                          ),
                                          arguments: project,
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
