import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../widgets/auth_guard.dart';
import '../../../services/dashboard_service.dart';
import '../../../models/api_models.dart';
import '../../../route/route_constants.dart';
import '../../../components/molecules/responsive_project_card.dart';
import '../../../design_tokens/app_colors.dart';
import '../../../constants.dart';
import '../../../components/animations/hover_card.dart';
import '../../../components/animations/fade_entry.dart';
import '../../../components/animations/scale_button.dart';

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

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
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
                  "https://images.unsplash.com/photo-1503387762-592deb58ef4e?w=800",
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
                const SizedBox(height: 24),

                // Quick Actions
                FadeEntry(
                  delay: 350.ms,
                  child: SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildQuickAction(
                          context,
                          "Payments",
                          Icons.account_balance_wallet,
                          Colors.purple,
                          () => Navigator.pushNamed(context, paymentsScreenRoute),
                        ),
                        const SizedBox(width: 12),
                        _buildQuickAction(
                          context,
                          "Site Updates",
                          Icons.camera_alt,
                          Colors.blue,
                          () => Navigator.pushNamed(context, siteUpdatesScreenRoute),
                        ),
                        const SizedBox(width: 12),
                        _buildQuickAction(
                          context,
                          "Support",
                          Icons.headset_mic,
                          Colors.orange,
                          () {},
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                
                // Section Title with Action
                FadeEntry(
                  delay: 400.ms,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Your Projects",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (projects.totalProjects > 0)
                        TextButton(
                          onPressed: () {
                             // Navigate with fade
                             Navigator.pushNamed(context, projectScreenRoute);
                          },
                          child: const Text("View All"),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Project List
                _buildProjectList(projects),
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

  Widget _buildProjectList(DashboardProjectsDto projects) {
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
      children: projects.recentProjects.asMap().entries.map((entry) {
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

  Widget _buildQuickAction(
      BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return ScaleButton(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: blackColor.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
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
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: blackColor80,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
