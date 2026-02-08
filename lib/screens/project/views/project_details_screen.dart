import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../models/api_models.dart';
import '../../../route/route_constants.dart';
import '../../../services/dashboard_service.dart';
import '../../../constants.dart';
import '../../../components/animations/fade_entry.dart';
import '../../../components/animations/hover_card.dart';
import '../../../components/animations/scale_button.dart';
import '../../../models/project_phase.dart';
import 'design_package_selection_screen.dart';
import '../../site_reports/site_reports_screen.dart';
import '../../payments/views/payments_screen.dart';
import 'activity_feed_screen.dart';
import 'snags_screen.dart';
import 'site_visits_screen.dart';
import 'boq_screen.dart';
import 'quality_check_screen.dart';
import 'view_360_screen.dart';
import 'feedback_dialog.dart';

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
      debugPrint('Error getting project from route: $e');
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
      debugPrint('Error getting project from route: $e');
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
                  Row(
                    children: [
                      if (_projectDetails?.phase != null || p?.projectPhase != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.5)),
                          ),
                          child: Text(
                            ProjectPhase.fromString(_projectDetails?.phase ?? p?.projectPhase).displayName.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ).animate().slideX(begin: -0.2, curve: Curves.easeOut),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    _projectDetails?.name ?? p?.name ?? 'Project Details',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                      Expanded(
                        child: Text(
                          _projectDetails?.location ?? p?.location ?? 'Location not specified',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
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
        // Phase stepper (Planning → Design → Construction → Completed)
        FadeEntry(
          delay: 380.ms,
          child: _buildPhaseStepper(p),
        ),
        const SizedBox(height: 20),
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

  Widget _buildPhaseStepper(ProjectCard? p) {
    final phaseValue = _projectDetails?.phase ?? p?.projectPhase;
    final current = ProjectPhase.fromString(phaseValue);
    const allPhases = ProjectPhase.values;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: blackColor.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          for (int i = 0; i < allPhases.length; i++) ...[
            if (i > 0)
              Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.only(bottom: 20),
                  color: current.order > i ? successColor.withOpacity(0.7) : blackColor10,
                ),
              ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: allPhases[i] == current
                        ? _getPhaseColor(phaseValue)
                        : allPhases[i].order < current.order
                            ? successColor.withOpacity(0.5)
                            : blackColor10,
                    border: Border.all(
                      color: allPhases[i] == current
                          ? _getPhaseColor(phaseValue)
                          : blackColor20,
                      width: allPhases[i] == current ? 2.5 : 1,
                    ),
                  ),
                  child: Center(
                    child: allPhases[i].order < current.order
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                        : Text(
                            '${allPhases[i].order}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: allPhases[i] == current
                                  ? Colors.white
                                  : blackColor60,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 70,
                  child: Text(
                    allPhases[i].displayName,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: allPhases[i] == current ? FontWeight.bold : FontWeight.w500,
                      color: allPhases[i] == current ? _getPhaseColor(phaseValue) : blackColor60,
                    ),
                  ),
                ),
              ],
            ),
            if (i < allPhases.length - 1)
              Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.only(bottom: 20),
                  color: current.order > i + 1 ? successColor.withOpacity(0.7) : blackColor10,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildPhaseCard(BuildContext context, ProjectCard? p) {
    final progress = _projectDetails?.progress ?? p?.progress ?? 0;
    final phaseValue = _projectDetails?.phase ?? p?.projectPhase;
    final phase = ProjectPhase.fromString(phaseValue);

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current phase row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getPhaseColor(phaseValue).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getPhaseColor(phaseValue).withOpacity(0.4)),
                  ),
                  child: Text(
                    phase.displayName,
                    style: TextStyle(
                      color: _getPhaseColor(phaseValue),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    phase.shortDescription,
                    style: const TextStyle(color: blackColor60, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
                    "${progress.toStringAsFixed(0)}%",
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
                value: (progress / 100.0).clamp(0.0, 1.0),
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

  Color _getPhaseColor(String? phaseValue) {
    if (phaseValue == null || phaseValue.isEmpty) return primaryColor;
    final p = phaseValue.trim().toUpperCase();
    switch (p) {
      case 'PLANNING': return Colors.blue;
      case 'DESIGN': return Colors.purple;
      case 'EXECUTION':
      case 'CONSTRUCTION': return warningColor;
      case 'COMPLETION':
      case 'HANDOVER':
      case 'WARRANTY':
      case 'COMPLETED': return successColor;
      default: return primaryColor;
    }
  }

  Widget _buildOverviewSection(BuildContext context) {
    final startStr = _projectDetails?.startDate;
    final endStr = _projectDetails?.endDate;
    final startDate = _parseDate(startStr);
    final endDate = _parseDate(endStr);
    final startDisplay = startDate != null ? _formatDate(startDate) : (startStr ?? '—');
    final endDisplay = endDate != null ? _formatDate(endDate) : (endStr ?? '—');

    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            "Start Date",
            startDisplay,
            Icons.calendar_today_outlined,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildInfoCard(
            "Est. Completion",
            endDisplay,
            Icons.flag_outlined,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
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
    final projectId = _getProjectId() ?? '';
    final phase = ProjectPhase.fromString(_projectDetails?.phase ?? _getProjectCard()?.projectPhase);
    final actions = _getPhaseActions(phase, projectId);

    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        for (int i = 0; i < actions.length; i += 2) ...[
          if (i > 0) const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildActionTile(actions[i].label, actions[i].icon, actions[i].color, actions[i].onTap)),
              if (i + 1 < actions.length) ...[
                const SizedBox(width: 16),
                Expanded(child: _buildActionTile(actions[i + 1].label, actions[i + 1].icon, actions[i + 1].color, actions[i + 1].onTap)),
              ] else
                const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ],
    );
  }

  List<_ActionItem> _getPhaseActions(ProjectPhase phase, String projectId) {
    final list = <_ActionItem>[];
    final nav = Navigator.of(context);

    switch (phase) {
      case ProjectPhase.planning:
        list.add(_ActionItem('Activity Feed', Icons.timeline, Colors.indigo, () {
          nav.push(MaterialPageRoute(builder: (_) => ActivityFeedScreen(projectId: projectId)));
        }));
        list.add(_ActionItem('Site Reports', Icons.assignment_outlined, Colors.orange, () {
          nav.push(MaterialPageRoute(builder: (_) => SiteReportsScreen(projectId: projectId.isNotEmpty ? int.tryParse(projectId) : null)));
        }));
        list.add(_ActionItem('Documents', Icons.folder_outlined, Colors.blue, () => nav.pushNamed(projectId.isNotEmpty ? projectDocumentsRoute(projectId) : documentsScreenRoute)));
        list.add(_ActionItem('Site Visits', Icons.person_pin_circle_outlined, Colors.purple, () {
          nav.push(MaterialPageRoute(builder: (_) => SiteVisitsScreen(projectId: projectId)));
        }));
        list.add(_ActionItem('BOQ', Icons.receipt_long_outlined, Colors.green, () {
          nav.push(MaterialPageRoute(builder: (_) => BoqScreen(projectId: projectId)));
        }));
        list.add(_ActionItem('360° Views', Icons.view_in_ar, Colors.cyan, () {
          nav.push(MaterialPageRoute(builder: (_) => View360Screen(projectId: projectId)));
        }));
        list.add(_ActionItem('Feedback', Icons.feedback_outlined, Colors.pink, () {
          showFeedbackDialog(context: context, projectId: projectId);
        }));
        break;
      case ProjectPhase.design:
        list.add(_ActionItem('Activity Feed', Icons.timeline, Colors.indigo, () {
          nav.push(MaterialPageRoute(builder: (_) => ActivityFeedScreen(projectId: projectId)));
        }));
        list.add(_ActionItem('Design Package', Icons.design_services_outlined, Colors.purple, () {
          if (projectId.isNotEmpty) {
            final sqFeet = _projectDetails?.sqFeet ?? 0.0;
            nav.push(MaterialPageRoute(builder: (_) => DesignPackageSelectionScreen(projectId: projectId, sqFeet: sqFeet)));
          }
        }));
        list.add(_ActionItem('Site Reports', Icons.assignment_outlined, Colors.orange, () {
          nav.push(MaterialPageRoute(builder: (_) => SiteReportsScreen(projectId: projectId.isNotEmpty ? int.tryParse(projectId) : null)));
        }));
        list.add(_ActionItem('Documents', Icons.folder_outlined, Colors.blue, () => nav.pushNamed(projectId.isNotEmpty ? projectDocumentsRoute(projectId) : documentsScreenRoute)));
        list.add(_ActionItem('Site Visits', Icons.person_pin_circle_outlined, Colors.teal, () {
          nav.push(MaterialPageRoute(builder: (_) => SiteVisitsScreen(projectId: projectId)));
        }));
        list.add(_ActionItem('BOQ', Icons.receipt_long_outlined, Colors.green, () {
          nav.push(MaterialPageRoute(builder: (_) => BoqScreen(projectId: projectId)));
        }));
        list.add(_ActionItem('360° Views', Icons.view_in_ar, Colors.cyan, () {
          nav.push(MaterialPageRoute(builder: (_) => View360Screen(projectId: projectId)));
        }));
        list.add(_ActionItem('Feedback', Icons.feedback_outlined, Colors.pink, () {
          showFeedbackDialog(context: context, projectId: projectId);
        }));
        break;
      case ProjectPhase.construction:
        list.add(_ActionItem('Activity Feed', Icons.timeline, Colors.indigo, () {
          nav.push(MaterialPageRoute(builder: (_) => ActivityFeedScreen(projectId: projectId)));
        }));
        list.add(_ActionItem('Gallery', Icons.photo_library_outlined, Colors.teal, () => nav.pushNamed(projectId.isNotEmpty ? projectGalleryRoute(projectId) : projectGalleryScreenRoute)));
        list.add(_ActionItem('Site Visits', Icons.person_pin_circle_outlined, Colors.purple, () {
          nav.push(MaterialPageRoute(builder: (_) => SiteVisitsScreen(projectId: projectId)));
        }));
        list.add(_ActionItem('Snags', Icons.warning_amber_rounded, Colors.red, () {
          nav.push(MaterialPageRoute(builder: (_) => SnagsScreen(projectId: projectId)));
        }));
        list.add(_ActionItem('Quality Check', Icons.checklist, Colors.deepPurple, () {
          nav.push(MaterialPageRoute(builder: (_) => QualityCheckScreen(projectId: projectId)));
        }));
        list.add(_ActionItem('BOQ', Icons.receipt_long_outlined, Colors.green, () {
          nav.push(MaterialPageRoute(builder: (_) => BoqScreen(projectId: projectId)));
        }));
        list.add(_ActionItem('360° Views', Icons.view_in_ar, Colors.cyan, () {
          nav.push(MaterialPageRoute(builder: (_) => View360Screen(projectId: projectId)));
        }));
        list.add(_ActionItem('Site Reports', Icons.assignment_outlined, Colors.orange, () {
          nav.push(MaterialPageRoute(builder: (_) => SiteReportsScreen(projectId: projectId.isNotEmpty ? int.tryParse(projectId) : null)));
        }));
        list.add(_ActionItem('Documents', Icons.folder_outlined, Colors.blue, () => nav.pushNamed(projectId.isNotEmpty ? projectDocumentsRoute(projectId) : documentsScreenRoute)));
        list.add(_ActionItem('Payments', Icons.account_balance_wallet_outlined, Colors.amber, () {
          nav.push(MaterialPageRoute(builder: (_) => PaymentsScreen(projectId: projectId.isNotEmpty ? projectId : null)));
        }));
        list.add(_ActionItem('CCTV', Icons.videocam_outlined, Colors.grey, () => nav.pushNamed(projectId.isNotEmpty ? projectCctvRoute(projectId) : cctvSurveillanceScreenRoute)));
        list.add(_ActionItem('Feedback', Icons.feedback_outlined, Colors.pink, () {
          showFeedbackDialog(context: context, projectId: projectId);
        }));
        break;
      case ProjectPhase.completed:
        list.add(_ActionItem('Activity Feed', Icons.timeline, Colors.indigo, () {
          nav.push(MaterialPageRoute(builder: (_) => ActivityFeedScreen(projectId: projectId)));
        }));
        list.add(_ActionItem('Gallery', Icons.photo_library_outlined, Colors.teal, () => nav.pushNamed(projectId.isNotEmpty ? projectGalleryRoute(projectId) : projectGalleryScreenRoute)));
        list.add(_ActionItem('Snags', Icons.warning_amber_rounded, Colors.red, () {
          nav.push(MaterialPageRoute(builder: (_) => SnagsScreen(projectId: projectId)));
        }));
        list.add(_ActionItem('Quality Check', Icons.checklist, Colors.deepPurple, () {
          nav.push(MaterialPageRoute(builder: (_) => QualityCheckScreen(projectId: projectId)));
        }));
        list.add(_ActionItem('BOQ', Icons.receipt_long_outlined, Colors.green, () {
          nav.push(MaterialPageRoute(builder: (_) => BoqScreen(projectId: projectId)));
        }));
        list.add(_ActionItem('360° Views', Icons.view_in_ar, Colors.cyan, () {
          nav.push(MaterialPageRoute(builder: (_) => View360Screen(projectId: projectId)));
        }));
        list.add(_ActionItem('Site Reports', Icons.assignment_outlined, Colors.orange, () {
          nav.push(MaterialPageRoute(builder: (_) => SiteReportsScreen(projectId: projectId.isNotEmpty ? int.tryParse(projectId) : null)));
        }));
        list.add(_ActionItem('Documents', Icons.folder_outlined, Colors.blue, () => nav.pushNamed(projectId.isNotEmpty ? projectDocumentsRoute(projectId) : documentsScreenRoute)));
        list.add(_ActionItem('Payments', Icons.account_balance_wallet_outlined, Colors.amber, () {
          nav.push(MaterialPageRoute(builder: (_) => PaymentsScreen(projectId: projectId.isNotEmpty ? projectId : null)));
        }));
        list.add(_ActionItem('Feedback', Icons.feedback_outlined, Colors.pink, () {
          showFeedbackDialog(context: context, projectId: projectId);
        }));
        break;
    }
    return list;
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

class _ActionItem {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _ActionItem(this.label, this.icon, this.color, this.onTap);
}
