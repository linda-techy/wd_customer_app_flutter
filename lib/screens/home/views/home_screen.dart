import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

import '../../../constants.dart';
import '../../../services/auth_service.dart';
import '../../../components/walldot_logo.dart';
import '../../../utils/responsive.dart';
import '../../../design_tokens/app_colors.dart';
import '../../../design_tokens/app_typography.dart';
import '../../../components/animations/fade_entry.dart';
import '../../../components/animations/hover_card.dart';
import '../../../components/animations/scale_button.dart';
import 'home_screen.dart'; // Self import or relative imports if needed, but I'll write the full class here.

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? currentUser;
  bool isLoggedIn = false;
  int _currentLiveActivityIndex = 0;
  Timer? _liveActivityTimer;

  final List<Map<String, String>> liveActivities = [
    {
      'name': 'Bijeeshmon',
      'location': 'Arnattukara',
      'action': 'Project Completed'
    },
    {
      'name': 'Akhil Johnson',
      'location': 'Poochinipadam',
      'action': 'Foundation Started'
    },
    {
      'name': 'Sarah Thomas',
      'location': 'Thrissur',
      'action': 'Design Approved'
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _startLiveActivityTimer();
  }

  @override
  void dispose() {
    _liveActivityTimer?.cancel();
    super.dispose();
  }

  void _startLiveActivityTimer() {
    _liveActivityTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
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

  void _openContactForm() {
    // TODO: Navigate to contact or open sheets
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);
    final padding = ResponsiveSpacing.getPadding(context);
    final horizontalPadding = ResponsiveSpacing.getHorizontalPadding(context);
    final gridSpacing = ResponsiveSpacing.getGridSpacing(context);
    final featuredHeight = isDesktop ? 320.0 : (isTablet ? 280.0 : 240.0);
    final projectCardWidth = isDesktop ? 280.0 : (isTablet ? 260.0 : 240.0);
    final fabPadding = isDesktop ? 16.0 : (isTablet ? 14.0 : 12.0);
    final fabIconSize = isDesktop ? 28.0 : (isTablet ? 26.0 : 24.0);

    return Scaffold(
      backgroundColor: surfaceColor,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 1200 : double.infinity,
          ),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildHeroAppBar(context),
              SliverToBoxAdapter(
                child: FadeEntry(
                  delay: 200.ms,
                  child: _buildWelcomeSection(context),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                sliver: SliverToBoxAdapter(
                  child:
                      FadeEntry(delay: 300.ms, child: _buildStatsGrid(context)),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: padding * 2)),
              SliverToBoxAdapter(child: _buildLiveActivityTicker(context)),
              SliverToBoxAdapter(child: SizedBox(height: padding * 2)),
              _buildSectionHeader(context, "Our Services",
                  "Comprehensive solutions for your dream project"),
              SliverPadding(
                padding: EdgeInsets.all(padding),
                sliver: SliverGrid.count(
                  crossAxisCount: ResponsiveGrid.getCrossAxisCount(context),
                  mainAxisSpacing: gridSpacing,
                  crossAxisSpacing: gridSpacing,
                  childAspectRatio: isDesktop ? 1.0 : 1.1,
                  children: [
                    _buildServiceCard(context, "Residential",
                        Icons.home_rounded, Colors.orange),
                    _buildServiceCard(context, "Commercial",
                        Icons.business_rounded, Colors.blue),
                    _buildServiceCard(context, "Industrial",
                        Icons.factory_rounded, Colors.grey),
                    _buildServiceCard(context, "Renovation",
                        Icons.handyman_rounded, Colors.purple),
                  ],
                ),
              ),
              _buildSectionHeader(context, "Featured Projects",
                  "Award-winning excellence across Kerala"),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: featuredHeight,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding, vertical: padding),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildProjectCard(
                          context,
                          "Modern Villa",
                          "Residential",
                          "https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800",
                          projectCardWidth),
                      _buildProjectCard(
                          context,
                          "Skyline Tower",
                          "Commercial",
                          "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800",
                          projectCardWidth),
                      _buildProjectCard(
                          context,
                          "Green Park",
                          "Landscape",
                          "https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800",
                          projectCardWidth),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: FadeEntry(
                  delay: 400.ms,
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: HoverCard(
                      child: Container(
                        padding: EdgeInsets.all(isDesktop ? 24 : padding + 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [logoRed, logoPink]),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                                color: logoRed.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10))
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Refer & Earn ₹50,000",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          ResponsiveFontSize.getTitle(context),
                                    ),
                                  ),
                                  SizedBox(height: padding * 0.5),
                                  Text(
                                    "Join Kerala's biggest referral program today.",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize:
                                          ResponsiveFontSize.getBody(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.arrow_forward,
                                  color: Colors.white),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: padding * 6)),
            ],
          ),
        ),
      ),
      floatingActionButton: ScaleButton(
        onTap: () async {
          final uri = Uri.parse("https://wa.me/919074954874");
          if (await canLaunchUrl(uri)) await launchUrl(uri);
        },
        child: Container(
          padding: EdgeInsets.all(fabPadding),
          decoration: BoxDecoration(
            color: const Color(0xFF25D366),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: Colors.green.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Icon(Icons.call, color: Colors.white, size: fabIconSize),
        ),
      ),
    );
  }

  Widget _buildHeroAppBar(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);
    final horizontalPadding = ResponsiveSpacing.getHorizontalPadding(context);
    final padding = ResponsiveSpacing.getPadding(context);
    final expandedHeight = isDesktop ? 320.0 : (isTablet ? 280.0 : 240.0);
    final badgeFontSize = ResponsiveFontSize.getBody(context) - 3;
    final titleFontSize = ResponsiveFontSize.getHeadline(context);

    return SliverAppBar(
      expandedHeight: expandedHeight,
      floating: false,
      pinned: true,
      backgroundColor: surfaceColor,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl:
                  "https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=1200",
              fit: BoxFit.cover,
            ).animate().fadeIn(duration: 800.ms),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black12, Colors.black87],
                ),
              ),
            ),
            Positioned(
              left: horizontalPadding,
              bottom: padding * 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      "CRAFTING ICONIC SPACES",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: badgeFontSize.clamp(10.0, 12.0),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ).animate().slideX(),
                  SizedBox(height: padding),
                  Text(
                    "Building Your Vision,\nDelivering Excellence",
                    style: TextStyle(
                      fontFamily: grandisExtendedFont,
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ).animate().fadeIn().slideY(begin: 0.1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final padding = ResponsiveSpacing.getPadding(context);
    final titleSize = ResponsiveFontSize.getTitle(context);
    final bodySize = ResponsiveFontSize.getBody(context);

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hi, ${isLoggedIn ? (currentUser?.name ?? 'User') : 'Guest'}",
                    style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: blackColor),
                  ),
                  Text("Welcome back to Walldot",
                      style:
                          TextStyle(color: blackColor60, fontSize: bodySize)),
                ],
              ),
              ScaleButton(
                onTap: _openContactForm,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: padding + 4, vertical: 12),
                  decoration: BoxDecoration(
                    color: blackColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text("Get Free Quote",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: bodySize + 1)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final gridSpacing = ResponsiveSpacing.getGridSpacing(context);

    return Row(
      children: [
        Expanded(
            child: _buildStatCard(
                context, "25k+", "Sq.Ft.\nCrafted", Colors.blue)),
        SizedBox(width: gridSpacing),
        Expanded(
            child: _buildStatCard(
                context, "100%", "On-Time\nRecord", Colors.green)),
        SizedBox(width: gridSpacing),
        Expanded(
            child: _buildStatCard(
                context, "Zero", "Hidden\nCosts", Colors.orange)),
      ],
    );
  }

  Widget _buildStatCard(
      BuildContext context, String value, String label, Color color) {
    final cardPadding = ResponsiveSpacing.getCardPadding(context);
    final titleSize = ResponsiveFontSize.getTitle(context);
    final bodySize = ResponsiveFontSize.getBody(context) - 2;

    return HoverCard(
      child: Container(
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: blackColor.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w900,
                    color: color)),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: bodySize.clamp(10.0, 12.0),
                    color: blackColor60,
                    height: 1.2)),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveActivityTicker(BuildContext context) {
    final activity = liveActivities[_currentLiveActivityIndex];
    final horizontalPadding = ResponsiveSpacing.getHorizontalPadding(context);
    final padding = ResponsiveSpacing.getPadding(context);
    final bodySize = ResponsiveFontSize.getBody(context);

    return AnimatedSwitcher(
      duration: 500.ms,
      child: Container(
        key: ValueKey(_currentLiveActivityIndex),
        margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: 12),
        decoration: BoxDecoration(
          color: blackColor5,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: blackColor10),
        ),
        child: Row(
          children: [
            const Icon(Icons.bolt, color: Colors.amber, size: 20),
            SizedBox(width: padding),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(color: blackColor, fontSize: bodySize),
                  children: [
                    TextSpan(
                        text: "${activity['name']} ",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const TextSpan(text: "from "),
                    TextSpan(
                        text: "${activity['location']}: ",
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    TextSpan(
                        text: "${activity['action']}",
                        style: const TextStyle(
                            color: successColor, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, String subtitle) {
    final horizontalPadding = ResponsiveSpacing.getHorizontalPadding(context);
    final padding = ResponsiveSpacing.getPadding(context);
    final titleSize = ResponsiveFontSize.getTitle(context);
    final bodySize = ResponsiveFontSize.getBody(context);

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(horizontalPadding, padding * 0.625,
            horizontalPadding, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontFamily: grandisExtendedFont,
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: padding * 0.25),
            Text(subtitle,
                style: TextStyle(color: blackColor60, fontSize: bodySize)),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(
      BuildContext context, String title, IconData icon, Color color) {
    final bodySize = ResponsiveFontSize.getBody(context);
    final padding = ResponsiveSpacing.getPadding(context);

    return HoverCard(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: blackColor.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(padding * 0.75),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(height: padding * 0.75),
            Text(title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: bodySize)),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, String title, String type,
      String imageUrl, double width) {
    final padding = ResponsiveSpacing.getPadding(context);
    final gridSpacing = ResponsiveSpacing.getGridSpacing(context);
    final bodySize = ResponsiveFontSize.getBody(context) - 4;
    final titleSize = ResponsiveFontSize.getTitle(context) - 2;

    return HoverCard(
      child: Container(
        width: width,
        margin: EdgeInsets.only(right: gridSpacing),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: blackColor.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: blackColor5),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(type.toUpperCase(),
                      style: TextStyle(
                          fontSize: bodySize.clamp(9.0, 11.0),
                          fontWeight: FontWeight.bold,
                          color: primaryColor)),
                  SizedBox(height: padding * 0.25),
                  Text(title,
                      style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
