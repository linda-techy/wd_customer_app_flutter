import 'package:flutter/material.dart';
import '../../../models/api_models.dart';
import '../../../route/route_constants.dart';
import '../../../design_tokens/app_colors.dart';
import '../../../design_tokens/app_spacing.dart';
import '../../../design_tokens/app_typography.dart';
import '../../../responsive/responsive_builder.dart';
import '../../../services/dashboard_service.dart';
import 'design_package_selection_screen.dart';

class ProjectDetailsScreen extends StatefulWidget {
  const ProjectDetailsScreen({super.key, this.project, this.projectId});

  final ProjectCard? project;
  final String? projectId; // Support direct project ID for web refresh

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  ProjectDetails? _projectDetails;
  bool _isLoading = true;
  String? _errorMessage;
  bool _hasLoadedOnce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only load once when dependencies are ready
    if (!_hasLoadedOnce) {
      _hasLoadedOnce = true;
      _loadProjectDetails();
    }
  }

  ProjectCard? _getProjectCard() {
    // Try to get project from widget first, then from route arguments
    if (widget.project != null) {
      return widget.project;
    }
    
    // Fallback to route arguments
    try {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is ProjectCard) {
        return args;
      }
    } catch (e) {
      print('Error getting project from route: $e');
    }
    
    return null;
  }

  String? _getProjectId() {
    // Priority 1: Direct projectId parameter
    if (widget.projectId != null) {
      return widget.projectId;
    }
    
    // Priority 2: From ProjectCard widget parameter
    if (widget.project != null) {
      return widget.project!.projectUuid;
    }
    
    // Priority 3: From route arguments
    try {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is ProjectCard) {
        return args.projectUuid;
      }
    } catch (e) {
      print('Error getting project from route: $e');
    }
    
    return null;
  }

  Future<void> _loadProjectDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final projectId = _getProjectId();
      
      if (projectId == null) {
        setState(() {
          _errorMessage = 'No project selected';
          _isLoading = false;
        });
        return;
      }

      print('=== LOADING PROJECT DETAILS ===');
      print('Project ID: $projectId');

      final response = await DashboardService.getProjectDetails(projectId);

      if (response.success && response.data != null) {
        setState(() {
          _projectDetails = response.data;
          _isLoading = false;
        });
        print('Project details loaded successfully');
      } else {
        setState(() {
          _errorMessage = response.error?.message ?? 'Failed to load project details';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading project details: $e');
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final ProjectCard? p = _getProjectCard();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading project details...'),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_errorMessage!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadProjectDetails,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 260,
                      floating: false,
                      pinned: true,
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      flexibleSpace: FlexibleSpaceBar(
                        titlePadding:
                            const EdgeInsetsDirectional.only(start: 60, bottom: 16),
                        centerTitle: false,
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _projectDetails?.name ?? p?.name ?? 'Project Details',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  letterSpacing: -0.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_projectDetails?.status != null || p?.status?.isNotEmpty == true) ...[
                              const SizedBox(width: 8),
                              _buildStatusChip(_projectDetails?.status ?? p?.status ?? 'UNKNOWN'),
                            ],
                          ],
                        ),
                        background: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.primary, AppColors.secondary],
                            ),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.white.withOpacity(0.1),
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.05),
                                      ],
                                      stops: const [0.0, 0.5, 1.0],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 16,
                                right: 16,
                                bottom: 80,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_rounded,
                                          size: 14,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            _projectDetails?.location ?? p?.location ?? 'Location not specified',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.95),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 0.2,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: ResponsiveBuilder(
                        mobile: (context) => Padding(
                          padding: EdgeInsets.all(context.marginSize),
                          child: _buildContent(context, p),
                        ),
                        tablet: (context) => Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.marginSize,
                            vertical: AppSpacing.md,
                          ),
                          child: _buildContent(context, p),
                        ),
                        desktop: (context) => Center(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 1200),
                            padding: EdgeInsets.symmetric(
                              horizontal: context.marginSize,
                              vertical: AppSpacing.lg,
                            ),
                            child: _buildContent(context, p),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildContent(BuildContext context, ProjectCard? p) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        // Check if we're on a desktop screen (width > 900 typically)
        if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Phase/Progress (Flex 2)
              Expanded(
                flex: 2,
                child: _buildPhaseCard(context, p),
              ),
              const SizedBox(width: AppSpacing.lg),
              // Right Column: Overview (Flex 1)
              Expanded(
                flex: 1,
                child: _buildOverviewCard(context),
              ),
            ],
          );
        }

        // Mobile/Tablet: Stack vertically
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPhaseCard(context, p),
            const SizedBox(height: AppSpacing.lg),
            _buildOverviewCard(context),
            const SizedBox(height: AppSpacing.lg),
          ],
        );
      },
    );
  }

  Widget _buildPhaseCard(BuildContext context, ProjectCard? p) {
    final progress = _projectDetails?.progress ?? p?.progress ?? 0;
    final phase = _projectDetails?.phase ?? p?.projectPhase;
    final designPackage = _projectDetails?.designPackage ?? p?.designPackage;

    if (phase != null && 
        phase.toLowerCase() == 'design' && 
        (designPackage == null || designPackage.isEmpty)) {
      return _buildActionRequiredCard(context);
    } 
    
    if (progress < 50) {
      return _buildDesignProgressCard(context, p);
    } else {
      return _buildSiteProgressCard(context, p);
    }
  }

  Widget _buildActionRequiredCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.palette_outlined, color: AppColors.warning),
              const SizedBox(width: 12),
              const Expanded(child: Text('Action Required: Select Design Package')),
              const Icon(Icons.arrow_forward),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesignProgressCard(BuildContext context, ProjectCard? p) {
    final progress = _projectDetails?.progress ?? p?.progress ?? 0;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.design_services_outlined, color: AppColors.info),
                const SizedBox(width: 12),
                const Expanded(child: Text('Design in Progress')),
                Text('$progress%'),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: progress / 100.0),
          ],
        ),
      ),
    );
  }

  Widget _buildSiteProgressCard(BuildContext context, ProjectCard? p) {
    final progress = _projectDetails?.progress ?? p?.progress ?? 0;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.construction, color: AppColors.success),
                const SizedBox(width: 12),
                const Expanded(child: Text('Site Progress')),
                Text('$progress%'),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: progress / 100.0),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Overview', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            // Add overview details here
            Text('Status: ${_projectDetails?.status ?? "Unknown"}'),
            Text('Location: ${_projectDetails?.location ?? "Unknown"}'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toUpperCase()) {
      case 'ACTIVE':
      case 'IN_PROGRESS':
        color = Colors.green;
        break;
      case 'COMPLETED':
        color = Colors.blue;
        break;
      case 'ON_HOLD':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
