import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../constants.dart';
import '../../../utils/responsive.dart';
import '../../../components/animations/fade_entry.dart';
import '../../../components/animations/hover_card.dart';
import '../../../components/animations/scale_button.dart';
import '../../../services/dashboard_service.dart';
import '../../../models/api_models.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  List<ProjectCard> _projects = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await DashboardService.searchProjects();
      if (response.success && response.data != null) {
        setState(() {
          _projects = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.error?.message ?? 'Failed to load projects';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading projects: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        title: const Text("Job Sites", style: TextStyle(color: blackColor, fontWeight: FontWeight.bold)),
        backgroundColor: surfaceColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: blackColor),
        actions: [
          IconButton(
            onPressed: _showAddJobSiteDialog,
            icon: const Icon(Icons.add_circle, color: primaryColor),
            tooltip: 'Add New Job Site',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: blackColor),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadProjects,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _projects.isEmpty
                  ? _buildEmptyState()
                  : _buildJobSitesList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: FadeEntry(
        delay: 200.ms,
        child: Padding(
          padding: EdgeInsets.all(ResponsiveSpacing.getPadding(context) * 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_city_rounded,
                  size: 60,
                  color: primaryColor,
                ),
              ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 24),
              Text(
                "No Job Sites Yet",
                style: TextStyle(
                  fontSize: ResponsiveFontSize.getTitle(context),
                  fontWeight: FontWeight.bold,
                  color: blackColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Add your construction project locations to track progress and manage site visits",
                style: TextStyle(
                  fontSize: ResponsiveFontSize.getBody(context),
                  color: blackColor60,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ScaleButton(
                onTap: _showAddJobSiteDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        "Add First Job Site",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobSitesList() {
    return RefreshIndicator(
      onRefresh: _loadProjects,
      child: ListView.builder(
        padding: const EdgeInsets.only(
            left: defaultPadding,
            right: defaultPadding,
            top: defaultPadding,
            bottom: defaultPadding),
        itemCount: _projects.length,
        itemBuilder: (context, index) {
          final project = _projects[index];
          return FadeEntry(
            delay: (100 * index).ms,
            child: _buildJobSiteCard(project, index),
          );
        },
      ),
    );
  }

  Widget _buildJobSiteCard(ProjectCard project, int index) {
    Color statusColor;
    IconData statusIcon;
    String statusText = project.status ?? 'Unknown';

    switch (statusText.toLowerCase()) {
      case 'active':
      case 'in_progress':
      case 'ongoing':
        statusColor = successColor;
        statusIcon = Icons.engineering;
        break;
      case 'planning':
      case 'planned':
        statusColor = warningColor;
        statusIcon = Icons.architecture;
        break;
      case 'completed':
      case 'finished':
        statusColor = Colors.blue;
        statusIcon = Icons.verified;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    // Determine project type from name or use default
    String projectType = 'Construction';
    if (project.name.toLowerCase().contains('villa') || 
        project.name.toLowerCase().contains('residential')) {
      projectType = 'Residential';
    } else if (project.name.toLowerCase().contains('office') || 
               project.name.toLowerCase().contains('commercial')) {
      projectType = 'Commercial';
    } else if (project.name.toLowerCase().contains('industrial')) {
      projectType = 'Industrial';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: HoverCard(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: blackColor.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: blackColor.withOpacity(0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with placeholder image
              Stack(
                children: [
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          primaryColor.withOpacity(0.8),
                          primaryColor.withOpacity(0.6),
                          primaryColor.withOpacity(0.4),
                        ],
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.construction,
                          size: 64,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.business, size: 14, color: blackColor),
                          const SizedBox(width: 4),
                          Text(
                            projectType.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10, 
                              fontWeight: FontWeight.w900,
                              color: blackColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(statusIcon, size: 12, color: Colors.white),
                          const SizedBox(width: 6),
                          if (statusText.toLowerCase() == 'active' || 
                              statusText.toLowerCase() == 'in_progress')
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(right: 6),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ).animate(onPlay: (c) => c.repeat()).fade(duration: 800.ms),
                          Text(
                            statusText,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: blackColor,
                        height: 1.2,
                      ),
                    ),
                    if (project.code != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Code: ${project.code}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: blackColor60,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined, size: 18, color: blackColor60),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            project.location ?? 'Location not specified',
                            style: const TextStyle(
                              fontSize: 14,
                              color: blackColor60,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ScaleButton(
                            onTap: () => _showSiteDetails(project),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: blackColor10),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Text(
                                  "View Details",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: blackColor,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ScaleButton(
                            onTap: () => _requestSiteVisit(project),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: blackColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Text(
                                  "Request Visit",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
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
    );
  }

  void _showAddJobSiteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.add_location_alt, color: primaryColor),
            SizedBox(width: 12),
            Text("Add New Job Site"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Contact our team to add a new job site:"),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor.withOpacity(0.1)),
              ),
              child: const Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.phone, size: 20, color: primaryColor),
                      SizedBox(width: 12),
                      Text(
                        "+91-9074-9548-74",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                   SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.email, size: 20, color: primaryColor),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          companyEmail,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
             const SizedBox(height: 20),
            const Text(
              "We'll serve you set up site tracking surveillance and project management for your new location.",
              style: TextStyle(fontSize: 13, color: blackColor60, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: blackColor60)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Call action
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Call Now", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSiteDetails(ProjectCard project) {
    String projectType = 'Construction';
    if (project.name.toLowerCase().contains('villa') || 
        project.name.toLowerCase().contains('residential')) {
      projectType = 'Residential';
    } else if (project.name.toLowerCase().contains('office') || 
               project.name.toLowerCase().contains('commercial')) {
      projectType = 'Commercial';
    } else if (project.name.toLowerCase().contains('industrial')) {
      projectType = 'Industrial';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
             const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.location_city, color: primaryColor),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Text(
                              projectType,
                              style: const TextStyle(color: blackColor60, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 48),
                   _buildDetailRow("Status", project.status ?? 'Unknown', isStatus: true),
                  _buildDetailRow("Address", project.location ?? 'Not specified'),
                  if (project.code != null)
                    _buildDetailRow("Project Code", project.code!),
                  if (project.startDate != null)
                    _buildDetailRow("Start Date", project.startDate!),
                  if (project.endDate != null)
                    _buildDetailRow("End Date", project.endDate!),
                  _buildDetailRow("Progress", "${(project.progress * 100).toStringAsFixed(0)}%"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: blackColor60,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: isStatus 
            ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontSize: 14,
                ),
              ),
            )
            : Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: blackColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _requestSiteVisit(ProjectCard project) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Site visit requested for ${project.name}"),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: "OK",
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}
