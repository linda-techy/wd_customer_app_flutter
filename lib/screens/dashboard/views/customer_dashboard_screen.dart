import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../widgets/auth_guard.dart';
import '../../../services/dashboard_service.dart';
import '../../../models/api_models.dart';
import '../../../route/route_constants.dart';
import '../../../components/molecules/responsive_project_card.dart';
import '../../../constants.dart';
import '../../../components/animations/hover_card.dart';
import '../../../components/animations/fade_entry.dart';
import '../../../components/animations/scale_button.dart';
import '../../../models/project_phase.dart';

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() =>
      _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  DashboardDto? _dashboardData;
  bool _isLoading = true;
  String? _errorMessage;

  // Server-side project search
  final TextEditingController _searchController = TextEditingController();
  List<ProjectCard> _searchResults = [];
  bool _isSearching = false;
  String _lastSearchQuery = '';
  static const _searchDebounceMs = 400;

  // Phase filter (null = All)
  ProjectPhase? _selectedPhase;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {}); // Update section title and clear button
    final q = _searchController.text.trim();
    if (q == _lastSearchQuery) return;
    _lastSearchQuery = q;
    _debounceSearch();
  }

  void _debounceSearch() {
    Future.delayed(const Duration(milliseconds: _searchDebounceMs), () {
      if (!mounted) return;
      if (_searchController.text.trim() != _lastSearchQuery) return;
      _runSearch(_searchController.text.trim());
    });
  }

  Future<void> _runSearch(String query) async {
    setState(() {
      _isSearching = true;
      _lastSearchQuery = query;
    });
    try {
      final response = await DashboardService.searchProjects(
        query.isEmpty ? null : query,
      );
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        if (response.success && response.data != null) {
          _searchResults = response.data!;
        } else {
          _searchResults = [];
        }
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _searchResults = [];
        });
      }
    }
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await DashboardService.getDashboard();
      if (response.success && response.data != null) {
        setState(() {
          _dashboardData = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              response.error?.message ?? 'Failed to load dashboard data';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: _isLoading
            ? _buildLoadingState()
            : _errorMessage != null
                ? _buildErrorState()
                : _buildDashboardContent(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            'Building your experience...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1200.ms),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 64, color: errorColor),
            const SizedBox(height: 16),
            Text(
              'Connection Interrupted',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: errorColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unable to sync with the server.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: blackColor60),
            ),
            const SizedBox(height: 24),
            ScaleButton(
              onTap: _loadDashboardData,
              child: ElevatedButton(
                onPressed: _loadDashboardData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: errorColor,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('Try Again'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    final user = _dashboardData!.user;
    final projects = _dashboardData!.projects;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Premium Sliver App Bar
        SliverAppBar(
          expandedHeight: 280,
          floating: false,
          pinned: true,
          backgroundColor: surfaceColor,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                // "Live Site Look" Background Image (Placeholder)
                Image.network(
                  "https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=800",
                  fit: BoxFit.cover,
                ).animate().fadeIn(duration: 800.ms),
                // Premium Gradient Overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                // Content
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.wb_sunny_rounded, color: Colors.orangeAccent, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              "Today's Site Status",
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ).animate().slideX(begin: -0.2, duration: 600.ms, curve: Curves.easeOut),
                      const SizedBox(height: 12),
                      Text(
                        'Good Morning,\n${user.fullName.split(' ').first}',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          height: 1.1,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, duration: 600.ms),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Key Metrics Grid
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeEntry(
                  delay: 300.ms,
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          label: "Active Projects",
                          value: "${projects.activeProjects}",
                          icon: Icons.construction,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          label: "Completed",
                          value: "${projects.completedProjects}",
                          icon: Icons.verified,
                          color: successColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                
                // Project search (server-side)
                FadeEntry(
                  delay: 380.ms,
                  child: _buildProjectSearchBar(),
                ),
                const SizedBox(height: 20),
                
                // Section Title with Action
                FadeEntry(
                  delay: 400.ms,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _searchController.text.trim().isEmpty
                              ? "Your Projects"
                              : "Search results",
                          style: Theme.of(context).textTheme.titleLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (projects.totalProjects > 0)
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, projectsListScreenRoute);
                          },
                          child: const Text("View All"),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Phase filter chips
                FadeEntry(
                  delay: 420.ms,
                  child: _buildPhaseChips(),
                ),
                const SizedBox(height: 16),
                
                // Project List (server-rendered when searching, else dashboard recent)
                _buildProjectListWithSearch(projects),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return HoverCard(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: blackColor.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: blackColor,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: blackColor60,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ProjectCard> _filterByPhase(List<ProjectCard> list) {
    if (_selectedPhase == null) return list;
    return list
        .where((p) =>
            ProjectPhase.fromString(p.projectPhase) == _selectedPhase)
        .toList();
  }

  Widget _buildPhaseChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildPhaseChip(label: 'All', selected: _selectedPhase == null, onTap: () => setState(() => _selectedPhase = null)),
          const SizedBox(width: 8),
          ...ProjectPhase.values.map((phase) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildPhaseChip(
                  label: phase.displayName,
                  selected: _selectedPhase == phase,
                  onTap: () => setState(() => _selectedPhase = phase),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildPhaseChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.white,
      selectedColor: primaryColor.withOpacity(0.2),
      checkmarkColor: primaryColor,
      labelStyle: TextStyle(
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        color: selected ? primaryColor : blackColor60,
      ),
      side: BorderSide(
        color: selected ? primaryColor : blackColor.withOpacity(0.15),
      ),
    );
  }

  Widget _buildProjectSearchBar() {
    final isSearchActive = _searchController.text.trim().isNotEmpty;
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search by name, code or location...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: isSearchActive
            ? IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: () {
                  _searchController.clear();
                  _lastSearchQuery = '';
                  _searchResults = [];
                  setState(() {});
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      onSubmitted: (value) => _runSearch(value.trim()),
    );
  }

  Widget _buildProjectListWithSearch(ProjectSummary projects) {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      if (_isSearching) {
        return const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
                SizedBox(height: 12),
                Text('Searching projects...'),
              ],
            ),
          ),
        );
      }
      final filtered = _filterByPhase(_searchResults);
      if (filtered.isEmpty) {
        return FadeEntry(
          delay: 0.ms,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: blackColor.withOpacity(0.05)),
            ),
            child: Column(
              children: [
                Icon(Icons.search_off_rounded, size: 48, color: greyColor),
                const SizedBox(height: 12),
                Text(
                  _selectedPhase != null
                      ? 'No ${_selectedPhase!.displayName} projects in search'
                      : 'No projects match your search',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedPhase != null
                      ? 'Try another phase or clear the phase filter.'
                      : 'Try a different name, code or location.',
                  style: TextStyle(color: greyColor, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }
      return Column(
        children: filtered.asMap().entries.map((entry) {
          final index = entry.key;
          final project = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: FadeEntry(
              delay: (100 * index).ms,
              child: ResponsiveProjectCard(
                project: project,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    projectDetailsRoute(project.projectUuid ?? ''),
                    arguments: project,
                  );
                },
              ),
            ),
          );
        }).toList(),
      );
    }
    return _buildProjectList(projects);
  }

  Widget _buildProjectList(ProjectSummary projects) {
    final recent = _filterByPhase(projects.recentProjects);
    if (recent.isEmpty && projects.totalProjects > 0) {
      return FadeEntry(
        delay: 500.ms,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: blackColor.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              Icon(Icons.filter_list_rounded, size: 48, color: greyColor),
              const SizedBox(height: 12),
              Text(
                'No projects in ${_selectedPhase?.displayName ?? "this phase"}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => setState(() => _selectedPhase = null),
                child: const Text('Show all'),
              ),
            ],
          ),
        ),
      );
    }
    if (projects.totalProjects == 0) {
      return FadeEntry(
        delay: 500.ms,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: blackColor.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: lightGreyColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.rocket_launch, size: 40, color: greyColor),
              ),
              const SizedBox(height: 16),
              const Text(
                "No Active Projects",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                "Contact us to start your dream project.",
                textAlign: TextAlign.center,
                style: TextStyle(color: greyColor),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: recent.asMap().entries.map((entry) {
        final index = entry.key;
        final project = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: FadeEntry(
            delay: (500 + (index * 100)).ms,
            child: ResponsiveProjectCard(
              project: project,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  projectDetailsRoute(project.projectUuid),
                  arguments: project,
                );
              },
            ),
          ),
        );
      }).toList(),
    );
  }


}
