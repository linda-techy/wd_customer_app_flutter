import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../models/api_models.dart';
import '../../../route/route_constants.dart';
import '../../../design_tokens/app_colors.dart';
import '../../../design_tokens/app_spacing.dart';
import '../../../design_tokens/app_typography.dart';
import '../../../responsive/responsive_builder.dart';
import '../../../services/dashboard_service.dart';
import '../../../constants.dart';
import '../../../components/animations/fade_entry.dart';
import '../../../components/animations/hover_card.dart';
import '../../../components/animations/scale_button.dart';
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
    if (!_hasLoadedOnce) {
      _hasLoadedOnce = true;
      _loadProjectDetails();
    }
  }

  ProjectCard? _getProjectCard() {
    if (widget.project != null) return widget.project;
    try {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is ProjectCard) return args;
    } catch (e) {
      print('Error getting project from route: $e');
    }
    return null;
  }

  String? _getProjectId() {
    if (widget.projectId != null) return widget.projectId;
    if (widget.project != null) return widget.project!.projectUuid;
    try {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is ProjectCard) return args.projectUuid;
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

      final response = await DashboardService.getProjectDetails(projectId);

      if (response.success && response.data != null) {
        setState(() {
          _projectDetails = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.error?.message ?? 'Failed to load project details';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ProjectCard? p = _getProjectCard();

    return Scaffold(
      backgroundColor: surfaceColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : _errorMessage != null
              ? _buildErrorState()
              : CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    _buildSliverAppBar(p),
                    SliverPadding(
                      padding: const EdgeInsets.all(defaultPadding),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildContent(context, p),
                        ]),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildSliverAppBar(ProjectCard? p) {
    return SliverAppBar(
      expandedHeight: 280,
      floating: false,
      pinned: true,
      backgroundColor: surfaceColor,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Image.network(
              "https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=800",
              fit: BoxFit.cover,
            ).animate().fadeIn(duration: 800.ms),
            
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),

            // Content
            Positioned(
              left: 20,
              right: 20,
              bottom: 30,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_projectDetails?.status != null || p?.status?.isNotEmpty == true)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(_projectDetails?.status ?? p?.status ?? '').withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _getStatusColor(_projectDetails?.status ?? p?.status ?? '').withOpacity(0.5)),
                      ),
                      child: Text(
                        (_projectDetails?.status ?? p?.status ?? 'UNKNOWN').toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ).animate().slideX(begin: -0.2, curve: Curves.easeOut),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    _projectDetails?.name ?? p?.name ?? 'Project Details',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: grandisExtendedFont,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      height: 1.1,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                  
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        _projectDetails?.location ?? p?.location ?? 'Location not specified',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 300.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProjectCard? p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress Section
        FadeEntry(
          delay: 400.ms,
          child: _buildPhaseCard(context, p),
        ),
        const SizedBox(height: 24),

        // Quick Stats / Overview
        FadeEntry(
          delay: 500.ms,
          child: _buildOverviewSection(context),
        ),
        const SizedBox(height: 24),

        // Action Buttons Grid
        FadeEntry(
          delay: 600.ms,
          child: _buildActionGrid(context),
        ),
      ],
    );
  }

  Widget _buildPhaseCard(BuildContext context, ProjectCard? p) {
    final progress = _projectDetails?.progress ?? p?.progress ?? 0;
    
    return HoverCard(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total Progress", style: TextStyle(color: blackColor60, fontSize: 12)),
                    SizedBox(height: 4),
                    Text("On Track", style: TextStyle(color: successColor, fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "$progress%",
                    style: const TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress / 100.0,
                minHeight: 8,
                backgroundColor: blackColor5,
                valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewSection(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            "Start Date",
            "Oct 24, 2023",
            Icons.calendar_today_outlined,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildInfoCard(
            "Est. Completion",
            "Aug 15, 2024",
            Icons.flag_outlined,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: blackColor.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: blackColor60, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionTile(
                "Timeline",
                Icons.timeline,
                Colors.purple,
                () {
                  // TODO: Navigate or show Timeline
                  // Since timeline is a widget, maybe open a bottom sheet or new screen
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionTile(
                "Documents",
                Icons.folder_outlined,
                Colors.blue,
                 () => Navigator.pushNamed(context, documentsScreenRoute),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionTile(
                "Site Updates",
                Icons.camera_alt_outlined,
                Colors.green,
                () => Navigator.pushNamed(context, siteUpdatesScreenRoute),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionTile(
                "Payments",
                Icons.account_balance_wallet_outlined,
                Colors.orange,
                () => Navigator.pushNamed(context, paymentsScreenRoute),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionTile(String label, IconData icon, Color color, VoidCallback onTap) {
    return ScaleButton(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: blackColor.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: blackColor80,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: errorColor),
          const SizedBox(height: 16),
          Text(_errorMessage!, style: const TextStyle(color: errorColor)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadProjectDetails,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE': return successColor;
      case 'COMPLETED': return primaryColor;
      case 'ON_HOLD': return Colors.orange;
      default: return Colors.grey;
    }
  }
}
