import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../services/auth_service.dart';
import '../../../components/walldot_logo.dart';
import '../../../utils/responsive.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? currentUser;
  bool isLoggedIn = false;
  int _currentTestimonialIndex = 0;
  Timer? _testimonialTimer;
  int _currentLiveActivityIndex = 0;
  Timer? _liveActivityTimer;

  // Construction project images
  final List<Map<String, String>> projects = [
    {
      'name': 'Modern Villa Complex',
      'type': 'Residential',
      'image':
          'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800',
    },
    {
      'name': 'Corporate Office Tower',
      'type': 'Commercial',
      'image':
          'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800',
    },
    {
      'name': 'Luxury Apartment',
      'type': 'Residential',
      'image':
          'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800',
    },
    {
      'name': 'Industrial Warehouse',
      'type': 'Industrial',
      'image':
          'https://images.unsplash.com/photo-1590948347862-c1c4e5e0e3de?w=800',
    },
    {
      'name': 'Shopping Mall',
      'type': 'Commercial',
      'image':
          'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800',
    },
  ];

  // Customer testimonials for social proof
  final List<Map<String, dynamic>> testimonials = [
    {
      'name': 'Alex Antony',
      'location': 'Ponganamkadu, Kerala',
      'rating': 5,
      'text':
          'Our dream home turned out exactly as we imagined. The team was professional, attentive, and made the entire building process smooth and stress-free. We couldn’t be happier with the result!',
      'project': '4BHK Home'
    },
    {
      'name': 'Renoy V V',
      'location': 'Guruvayoor, Kerala',
      'rating': 5,
      'text':
          'Professional team, quality materials, and transparent pricing. Best decision for our office building.',
      'project': '3BHK Home'
    }
  ];

  // Live activity feed for social proof
  final List<Map<String, String>> liveActivities = [
    {
      'name': 'Bijeeshmon',
      'location': 'Arnattukara',
      'action': 'project completed'
    },
    {
      'name': 'Akhil johnson',
      'location': 'poochinipadam',
      'action': 'project in progress'
    }
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _startTestimonialTimer();
    _startLiveActivityTimer();
  }

  @override
  void dispose() {
    _testimonialTimer?.cancel();
    _liveActivityTimer?.cancel();
    super.dispose();
  }

  void _startTestimonialTimer() {
    _testimonialTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _currentTestimonialIndex =
              (_currentTestimonialIndex + 1) % testimonials.length;
        });
      }
    });
  }

  void _startLiveActivityTimer() {
    _liveActivityTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (mounted) {
        setState(() {
          _currentLiveActivityIndex =
              (_currentLiveActivityIndex + 1) % liveActivities.length;
        });
      }
    });
  }

  Future<void> _loadUserData() async {
    final user = await AuthService.getCurrentUser();
    final loggedIn = await AuthService.isLoggedIn();
    setState(() {
      currentUser = user;
      isLoggedIn = loggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Responsive.isDesktop(context);
    final bool isTablet = Responsive.isTablet(context);

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header with Greeting
                _buildHeader(context, isDesktop, isTablet),

                // Hero Section with Real Image
                _buildHeroSection(context, isDesktop, isTablet),

                // LIVE ACTIVITY - Social proof notification
                _buildLiveActivityBanner(context, isDesktop, isTablet),

                // Stats Section with improved numbers
                _buildStatsSection(context, isDesktop, isTablet),

                // TRUST BADGES - Certifications & Awards
                _buildTrustBadges(context, isDesktop, isTablet),

                // TESTIMONIALS - Customer reviews with ratings
                _buildTestimonialsSection(context, isDesktop, isTablet),

                // Referral Section
                _buildReferralSection(context, isDesktop, isTablet),

                // Services Section
                _buildServicesSection(context, isDesktop, isTablet),

                // Featured Projects with Real Images
                _buildFeaturedProjects(context, isDesktop, isTablet),

                // COST CALCULATOR CTA - Lead magnet
                _buildCostCalculatorCTA(context, isDesktop, isTablet),

                // Why Choose Us
                _buildWhyChooseUs(context, isDesktop, isTablet),

                // Contact CTA with functional buttons
                _buildContactCTA(context, isDesktop, isTablet),

                // Bottom padding for navigation bar
                SliverToBoxAdapter(
                  child: SizedBox(
                      height: ResponsiveSpacing.getPadding(context) * 6),
                ),
              ],
            ),
          ),
          // WHATSAPP FLOATING BUTTON - Always visible
          _buildWhatsAppButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDesktop, bool isTablet) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.all(ResponsiveSpacing.getPadding(context) * 1.5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              logoBackground,
              logoBackground.withOpacity(0.9),
              logoGreyDark.withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hi,",
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontSize: ResponsiveFontSize.getTitle(context),
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 1.2,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isLoggedIn && currentUser != null
                            ? currentUser!.name
                            : AuthService.getGreeting(),
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge
                            ?.copyWith(
                              fontSize:
                                  ResponsiveFontSize.getHeadline(context) + 4,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const WalldotLogo(
                        size: 24,
                        showText: false,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.support_agent,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: ResponsiveSpacing.getPadding(context)),
            Text(
              "Building Your Vision, Delivering Excellence",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: ResponsiveFontSize.getBody(context) + 2,
                    color: Colors.white.withOpacity(0.95),
                    fontWeight: FontWeight.w500,
                  ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(
      BuildContext context, bool isDesktop, bool isTablet) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.all(ResponsiveSpacing.getPadding(context) * 1.5),
        constraints: BoxConstraints(
          minHeight: isDesktop ? 300 : (isTablet ? 250 : 220),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: logoRed.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background construction image
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl:
                      'https://images.unsplash.com/photo-1503387762-592deb58ef4e?w=1200',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: logoRed,
                    child: const Icon(Icons.construction,
                        size: 60, color: Colors.white),
                  ),
                ),
              ),
            ),
            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      logoRed.withOpacity(0.85),
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: EdgeInsets.all(
                  ResponsiveSpacing.getCardPadding(context) * 1.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.workspace_premium,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          "Trusted by 500+ Families Across India",
                          style: TextStyle(
                            fontSize: ResponsiveFontSize.getBody(context),
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Build Your Dream Home",
                    style: TextStyle(
                      fontSize: ResponsiveFontSize.getHeadline(context),
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "With India's Most Trusted Builders",
                    style: TextStyle(
                      fontSize: ResponsiveFontSize.getTitle(context),
                      color: Colors.white.withOpacity(0.95),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  if (!isDesktop) ...[
                    // Mobile/Tablet - Single button
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: double.infinity,
                        minHeight: 44,
                        maxHeight: 48,
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _openContactForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: logoRed,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        icon: const Icon(Icons.request_quote, size: 18),
                        label: const Text(
                          "Get Free Quote",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Desktop - Side by side buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _openContactForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: logoRed,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 2,
                            ),
                            icon: const Icon(Icons.request_quote, size: 18),
                            label: const Text(
                              "Get Free Quote",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Navigate to projects
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(
                                  color: Colors.white, width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.work_outline, size: 18),
                            label: const Text(
                              "View Projects",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(
      BuildContext context, bool isDesktop, bool isTablet) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: ResponsiveSpacing.getPadding(context) * 1.5,
          vertical: ResponsiveSpacing.getPadding(context),
        ),
        padding:
            EdgeInsets.all(ResponsiveSpacing.getCardPadding(context) * 1.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: Border.all(color: Colors.grey[200]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isDesktop
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem("5+", "Premium\nProjects", Icons.business),
                  _buildDivider(),
                  _buildStatItem(
                      "100%", "Quality\nGuarantee", Icons.verified_user),
                  _buildDivider(),
                  _buildStatItem(
                      "Kerala's", "Trusted\nBuilder", Icons.location_city),
                  _buildDivider(),
                  _buildStatItem(
                      "₹10Cr+", "Projects\nValue", Icons.currency_rupee),
                ],
              )
            : Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: _buildStatItem(
                              "5+", "Premium\nProjects", Icons.business)),
                      _buildDivider(),
                      Expanded(
                          child: _buildStatItem("100%", "Quality\nGuarantee",
                              Icons.verified_user)),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Container(height: 1, color: Colors.grey[300]),
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: _buildStatItem("Kerala's", "Trusted\nBuilder",
                              Icons.location_city)),
                      _buildDivider(),
                      Expanded(
                          child: _buildStatItem("₹10Cr+", "Projects\nValue",
                              Icons.currency_rupee)),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildReferralSection(
      BuildContext context, bool isDesktop, bool isTablet) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: ResponsiveSpacing.getPadding(context) * 1.5,
          vertical: ResponsiveSpacing.getPadding(context),
        ),
        padding:
            EdgeInsets.all(ResponsiveSpacing.getCardPadding(context) * 1.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              logoRed,
              logoPink,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: logoRed.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.card_giftcard,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          "Refer & Earn ₹10K-50K*",
                          style: TextStyle(
                            fontSize: ResponsiveFontSize.getTitle(context),
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Kerala's Biggest Referral Program • Direct Bank Transfer",
                    style: TextStyle(
                      fontSize: ResponsiveFontSize.getBody(context) - 1,
                      color: Colors.white.withOpacity(0.95),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: isDesktop ? 200 : double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _openReferralWebsite();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: logoRed,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Refer a Friend",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isDesktop || isTablet) ...[
              const SizedBox(width: 20),
              const Icon(
                Icons.groups,
                size: 80,
                color: Colors.white24,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildServicesSection(
      BuildContext context, bool isDesktop, bool isTablet) {
    final crossAxisCount = ResponsiveGrid.getCrossAxisCount(context);
    final spacing = ResponsiveSpacing.getGridSpacing(context);

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveSpacing.getPadding(context) * 1.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Our Services",
              style: TextStyle(
                fontSize: ResponsiveFontSize.getTitle(context),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: ResponsiveSpacing.getPadding(context) / 2),
            Text(
              "Comprehensive construction solutions",
              style: TextStyle(
                fontSize: ResponsiveFontSize.getBody(context),
                color: blackColor60,
              ),
            ),
            SizedBox(height: ResponsiveSpacing.getPadding(context) * 1.5),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: 1.2,
              children: [
                _buildServiceCard(context, "Residential", Icons.home,
                    "Custom homes", logoRed),
                _buildServiceCard(context, "Commercial", Icons.business,
                    "Office buildings", logoGreyDark),
                _buildServiceCard(context, "Industrial", Icons.factory,
                    "Warehouses", logoGreyLight),
                _buildServiceCard(context, "Renovation", Icons.brush,
                    "Modernization", logoPink),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedProjects(
      BuildContext context, bool isDesktop, bool isTablet) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveSpacing.getPadding(context) * 1.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Featured Projects",
                  style: TextStyle(
                    fontSize: ResponsiveFontSize.getTitle(context),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "View All",
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: ResponsiveFontSize.getBody(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveSpacing.getPadding(context)),
            SizedBox(
              height: isDesktop ? 220 : 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final project = projects[index];
                  return Container(
                    width: isDesktop ? 300 : 260,
                    margin: EdgeInsets.only(
                        right: ResponsiveSpacing.getGridSpacing(context)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Project image
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: project['image']!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[300],
                                child: const Center(
                                    child: CircularProgressIndicator()),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: logoRed.withOpacity(0.1),
                                child: Icon(Icons.business,
                                    size: 50, color: logoRed),
                              ),
                            ),
                          ),
                        ),
                        // Gradient overlay
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.8),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Project info
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  project['name']!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 14,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      project['type']!,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhyChooseUs(
      BuildContext context, bool isDesktop, bool isTablet) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveSpacing.getPadding(context) * 1.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Why Choose Walldot Builders",
              style: TextStyle(
                fontSize: ResponsiveFontSize.getTitle(context),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: ResponsiveSpacing.getPadding(context)),
            _buildFeatureItem(context, Icons.verified, "Licensed & Insured",
                "Peace of mind guaranteed"),
            _buildFeatureItem(context, Icons.schedule, "On-Time Delivery",
                "Projects on schedule"),
            _buildFeatureItem(context, Icons.engineering, "Expert Team",
                "Years of experience"),
            _buildFeatureItem(
                context, Icons.eco, "Quality Materials", "Premium & lasting"),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCTA(BuildContext context, bool isDesktop, bool isTablet) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.all(ResponsiveSpacing.getPadding(context) * 1.5),
        padding: EdgeInsets.all(ResponsiveSpacing.getCardPadding(context) * 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              logoRed.withOpacity(0.05),
              logoPink.withOpacity(0.05),
            ],
          ),
          border: Border.all(color: logoRed.withOpacity(0.2), width: 1),
        ),
        child: Column(
          children: [
            Icon(Icons.contact_phone, size: 40, color: logoRed),
            SizedBox(height: ResponsiveSpacing.getPadding(context)),
            Text(
              "Ready to Start Your Project?",
              style: TextStyle(
                fontSize: ResponsiveFontSize.getTitle(context),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveSpacing.getPadding(context) / 2),
            Text(
              "Get FREE consultation & quote within 24 hours",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveFontSize.getBody(context),
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: ResponsiveSpacing.getPadding(context) * 1.5),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final Uri phoneUrl = Uri.parse('tel:+919074954874');
                      try {
                        await launchUrl(phoneUrl);
                      } catch (e) {
                        // Show error
                      }
                    },
                    icon: const Icon(Icons.phone, size: 20),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: logoRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    label: const Text(
                      "Call Now",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                SizedBox(width: ResponsiveSpacing.getPadding(context)),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final Uri emailUrl = Uri.parse(
                          'mailto:info@walldotbuilders.com?subject=Construction Inquiry');
                      try {
                        await launchUrl(emailUrl);
                      } catch (e) {
                        // Show error
                      }
                    },
                    icon: const Icon(Icons.email, size: 20),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: logoRed,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: logoRed, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    label: Text(
                      "Email Us",
                      style: TextStyle(
                        color: logoRed,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, String title, IconData icon,
      String description, Color color) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveSpacing.getCardPadding(context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveFontSize.getBody(context),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: ResponsiveFontSize.getBody(context) - 2,
                color: blackColor60,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String number, String label, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [logoRed.withOpacity(0.1), logoPink.withOpacity(0.1)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 28, color: logoRed),
        ),
        const SizedBox(height: 12),
        Text(
          number,
          style: TextStyle(
            color: logoRed,
            fontSize: ResponsiveFontSize.getTitle(context) + 2,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: logoGreyDark,
            fontSize: ResponsiveFontSize.getBody(context) - 2,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey[300],
    );
  }

  Widget _buildFeatureItem(
      BuildContext context, IconData icon, String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveSpacing.getPadding(context)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: primaryColor, size: 24),
          ),
          SizedBox(width: ResponsiveSpacing.getPadding(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveFontSize.getBody(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: ResponsiveFontSize.getBody(context) - 1,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openReferralWebsite() async {
    final Uri url = Uri.parse('https://www.walldotbuilders.com/referrals');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        // If URL launcher fails, show a message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Could not open referral page. Please visit walldotbuilders.com/referrals'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please visit: walldotbuilders.com/referrals'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _openContactForm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.request_quote, color: logoRed),
            const SizedBox(width: 12),
            const Flexible(
              child: Text(
                "Get Free Quote",
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Contact us for a free consultation and quote for your construction project.",
              ),
              const SizedBox(height: 16),
              const Text(
                "📞 Call Us:",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              SelectableText(
                "+91-9074-9548-74",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: logoRed,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "📧 Email Us:",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              SelectableText(
                "info@walldotbuilders.com",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: logoRed,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final Uri phoneUrl = Uri.parse('tel:+919074954874');
              try {
                await launchUrl(phoneUrl);
              } catch (e) {
                // Ignore error
              }
            },
            icon: const Icon(Icons.phone, size: 18),
            label: const Text("Call Now"),
          ),
        ],
      ),
    );
  }

  // NEW MARKETING SECTIONS

  Widget _buildLiveActivityBanner(
      BuildContext context, bool isDesktop, bool isTablet) {
    final activity = liveActivities[_currentLiveActivityIndex];
    return SliverToBoxAdapter(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: Container(
          key: ValueKey(_currentLiveActivityIndex),
          margin: EdgeInsets.all(ResponsiveSpacing.getPadding(context) * 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "${activity['name']} from ${activity['location']} ${activity['action']}",
                  style: TextStyle(
                    fontSize: ResponsiveFontSize.getBody(context) - 1,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[800],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.verified, size: 16, color: Colors.green[600]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrustBadges(
      BuildContext context, bool isDesktop, bool isTablet) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: ResponsiveSpacing.getPadding(context) * 1.5,
          vertical: ResponsiveSpacing.getPadding(context),
        ),
        padding:
            EdgeInsets.all(ResponsiveSpacing.getCardPadding(context) * 1.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[50],
        ),
        child: Column(
          children: [
            Text(
              "Certified & Trusted",
              style: TextStyle(
                fontSize: ResponsiveFontSize.getTitle(context) - 2,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: ResponsiveSpacing.getPadding(context)),
            Wrap(
              spacing: 20,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _buildTrustBadge("Licensed Builder", Icons.verified_user),
                _buildTrustBadge("Insured", Icons.security),
                _buildTrustBadge("ISO Certified", Icons.workspace_premium),
                _buildTrustBadge("RERA Approved", Icons.approval),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustBadge(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: logoRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: logoRed.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: logoRed),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: logoRed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialsSection(
      BuildContext context, bool isDesktop, bool isTablet) {
    final testimonial = testimonials[_currentTestimonialIndex];
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: ResponsiveSpacing.getPadding(context) * 1.5,
          vertical: ResponsiveSpacing.getPadding(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "What Our Clients Say",
              style: TextStyle(
                fontSize: ResponsiveFontSize.getTitle(context),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: ResponsiveSpacing.getPadding(context)),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Container(
                key: ValueKey(_currentTestimonialIndex),
                padding: EdgeInsets.all(
                    ResponsiveSpacing.getCardPadding(context) * 1.5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[200]!),
                  boxShadow: [
                    BoxShadow(
                      color: logoRed.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: logoRed.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.person, color: logoRed, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                testimonial['name'],
                                style: TextStyle(
                                  fontSize: ResponsiveFontSize.getBody(context),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                "${testimonial['location']} • ${testimonial['project']}",
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveFontSize.getBody(context) - 2,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: List.generate(
                            testimonial['rating'],
                            (index) => Icon(Icons.star,
                                color: Colors.amber[700], size: 18),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '"${testimonial['text']}"',
                      style: TextStyle(
                        fontSize: ResponsiveFontSize.getBody(context),
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: ResponsiveSpacing.getPadding(context) / 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                testimonials.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentTestimonialIndex == index
                        ? logoRed
                        : Colors.grey[300],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostCalculatorCTA(
      BuildContext context, bool isDesktop, bool isTablet) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: ResponsiveSpacing.getPadding(context) * 1.5,
          vertical: ResponsiveSpacing.getPadding(context),
        ),
        padding:
            EdgeInsets.all(ResponsiveSpacing.getCardPadding(context) * 1.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A1A2E),
              const Color(0xFF16213E),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.calculate, size: 48, color: Colors.white),
            SizedBox(height: ResponsiveSpacing.getPadding(context)),
            Text(
              "Get Instant Cost Estimate",
              style: TextStyle(
                fontSize: ResponsiveFontSize.getTitle(context),
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveSpacing.getPadding(context) / 2),
            Text(
              "Use our FREE calculator to estimate your project cost",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveFontSize.getBody(context),
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            SizedBox(height: ResponsiveSpacing.getPadding(context) * 1.5),
            SizedBox(
              width: isDesktop ? 250 : double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Open cost calculator
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cost calculator coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward, size: 20),
                style: ElevatedButton.styleFrom(
                  backgroundColor: logoRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                label: const Text(
                  "Calculate Now - FREE",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhatsAppButton(BuildContext context) {
    return Positioned(
      bottom: 90,
      right: 20,
      child: FloatingActionButton(
        onPressed: () async {
          final Uri whatsappUrl = Uri.parse(
              'https://wa.me/919074954874?text=Hi, I want to know more about your construction services');
          try {
            await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('WhatsApp not available'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        backgroundColor: const Color(0xFF25D366),
        elevation: 8,
        child: const Icon(Icons.chat, color: Colors.white, size: 28),
      ),
    );
  }
}
