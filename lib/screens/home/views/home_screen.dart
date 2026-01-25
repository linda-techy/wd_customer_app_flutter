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
    {'name': 'Bijeeshmon', 'location': 'Arnattukara', 'action': 'Project Completed'},
    {'name': 'Akhil Johnson', 'location': 'Poochinipadam', 'action': 'Foundation Started'},
    {'name': 'Sarah Thomas', 'location': 'Thrissur', 'action': 'Design Approved'},
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
          _currentLiveActivityIndex = (_currentLiveActivityIndex + 1) % liveActivities.length;
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
    return Scaffold(
      backgroundColor: surfaceColor, // Light grey specialized background
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Premium Hero App Bar
          _buildHeroAppBar(),

          // 2. Welcome & CTA Section
          SliverToBoxAdapter(
            child: FadeEntry(
              delay: 200.ms,
              child: _buildWelcomeSection(context),
            ),
          ),

          // 3. Stats Grid (Glassmorphism)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: FadeEntry(delay: 300.ms, child: _buildStatsGrid(context)),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 30)),

          // 4. Live Activity Ticker
          SliverToBoxAdapter(child: _buildLiveActivityTicker()),

           const SliverToBoxAdapter(child: SizedBox(height: 30)),

          // 5. Services Grid
          _buildSectionHeader("Our Services", "Comprehensive solutions for your dream project"),
          SliverPadding(
             padding: const EdgeInsets.all(20),
             sliver: SliverGrid.count(
               crossAxisCount: Responsive.isDesktop(context) ? 4 : 2,
               mainAxisSpacing: 16,
               crossAxisSpacing: 16,
               childAspectRatio: 1.1,
               children: [
                 _buildServiceCard("Residential", Icons.home_rounded, Colors.orange),
                 _buildServiceCard("Commercial", Icons.business_rounded, Colors.blue),
                 _buildServiceCard("Industrial", Icons.factory_rounded, Colors.grey),
                 _buildServiceCard("Renovation", Icons.handyman_rounded, Colors.purple),
               ],
             ),
          ),

          // 6. Featured Projects
          _buildSectionHeader("Featured Projects", "Award-winning excellence across Kerala"),
           SliverToBoxAdapter(
            child: SizedBox(
              height: 280,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                physics: const BouncingScrollPhysics(),
                children: [
                   _buildProjectCard("Modern Villa", "Residential", "https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800"),
                   _buildProjectCard("Skyline Tower", "Commercial", "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800"),
                   _buildProjectCard("Green Park", "Landscape", "https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800"),
                ],
              ),
            ),
          ),

          // 7. Referral Banner (High Conversion)
          SliverToBoxAdapter(
            child: FadeEntry(
              delay: 400.ms,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: HoverCard(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [logoRed, logoPink]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: logoRed.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Refer & Earn ₹50,000", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
                              const SizedBox(height: 8),
                              Text("Join Kerala's biggest referral program today.", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                          child: const Icon(Icons.arrow_forward, color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: ScaleButton(
        onTap: () async {
          final uri = Uri.parse("https://wa.me/919074954874");
          if (await canLaunchUrl(uri)) await launchUrl(uri);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFF25D366), shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))]),
          child: const Icon(Icons.call, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildHeroAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: true,
      backgroundColor: surfaceColor,
      elevation: 0,
       flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: "https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=1200",
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
              left: 20,
              bottom: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                     child: const Text(
                       "CRAFTING ICONIC SPACES",
                       style: TextStyle(
                         color: Colors.white,
                         fontSize: 11,
                         fontWeight: FontWeight.w800,
                         letterSpacing: 1.2,
                       ),
                     ),
                   ).animate().slideX(),
                   const SizedBox(height: 16),
                   const Text(
                    "Building Your Vision,\nDelivering Excellence",
                    style: TextStyle(
                      fontFamily: grandisExtendedFont,
                      fontSize: 32,
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
    return Padding(
      padding: const EdgeInsets.all(20),
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
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: blackColor),
                  ),
                  const Text("Welcome back to Walldot", style: TextStyle(color: blackColor60)),
                ],
              ),
              ScaleButton(
                onTap: _openContactForm,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: blackColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text("Get Free Quote", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildStatCard("25k+", "Sq.Ft.\nCrafted", Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard("100%", "On-Time\nRecord", Colors.green)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard("Zero", "Hidden\nCosts", Colors.orange)),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return HoverCard(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: blackColor.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: blackColor60, height: 1.2)),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveActivityTicker() {
    final activity = liveActivities[_currentLiveActivityIndex];
    return AnimatedSwitcher(
      duration: 500.ms,
      child: Container(
        key: ValueKey(_currentLiveActivityIndex),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: blackColor5,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: blackColor10),
        ),
        child: Row(
          children: [
            const Icon(Icons.bolt, color: Colors.amber, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: blackColor, fontSize: 13),
                  children: [
                    TextSpan(text: "${activity['name']} ", style: const TextStyle(fontWeight: FontWeight.bold)),
                    const TextSpan(text: "from "),
                    TextSpan(text: "${activity['location']}: ", style: const TextStyle(fontWeight: FontWeight.w600)),
                    TextSpan(text: "${activity['action']}", style: const TextStyle(color: successColor, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(title, style: const TextStyle(fontFamily: grandisExtendedFont, fontSize: 18, fontWeight: FontWeight.bold)),
             const SizedBox(height: 4),
             Text(subtitle, style: const TextStyle(color: blackColor60, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(String title, IconData icon, Color color) {
    return HoverCard(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: blackColor.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(String title, String type, String imageUrl) {
    return HoverCard(
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [BoxShadow(color: blackColor.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: blackColor5),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(type.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryColor)),
                    const SizedBox(height: 4),
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
      ),
    );
  }
}
