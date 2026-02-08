import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';

import '../../../constants.dart';
import '../../../services/auth_service.dart';
import '../../../utils/responsive.dart';
import '../../../components/animations/fade_entry.dart';
import '../../../components/animations/hover_card.dart';
import '../../../components/animations/scale_button.dart';

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
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ContactQuoteSheet(
        onSubmitted: () {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quote request received. We\'ll contact you soon.'),
              backgroundColor: successColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);
    final padding = ResponsiveSpacing.getPadding(context);
    final horizontalPadding = ResponsiveSpacing.getHorizontalPadding(context);
    final gridSpacing = ResponsiveSpacing.getGridSpacing(context);
    final featuredHeight = isDesktop ? 360.0 : (isTablet ? 320.0 : 280.0);
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
                    _buildServiceCard(context, "Luxury Living",
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
                          "assets/construction/residential_indian.png",
                          projectCardWidth),
                      _buildProjectCard(
                          context,
                          "Skyline Tower",
                          "Commercial",
                          "assets/construction/commercial_indian.png",
                          projectCardWidth),
                      _buildProjectCard(
                          context,
                          "Green Park",
                          "Landscape",
                          "assets/construction/landscape_indian.png",
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
                          gradient: const LinearGradient(colors: [logoRed, logoPink]),
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
                              padding: const EdgeInsets.all(12),
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
          child: Icon(
            FontAwesomeIcons.whatsapp,
            color: Colors.white,
            size: fabIconSize,
          ),
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
            Image.asset(
              "assets/construction/hero_indian.png",
              fit: BoxFit.cover,
            ).animate().fadeIn(duration: 800.ms),
            Container(
              decoration: const BoxDecoration(
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
                    "Designed for the Few.\nCrafted to Perfection.",
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hi, ${isLoggedIn ? (currentUser?.name ?? 'User') : 'Guest'}",
                      style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                          color: blackColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text("Welcome back to Walldot",
                        style:
                            TextStyle(color: blackColor60, fontSize: bodySize),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 16),
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
                context, "5", "Signature\nProjects", Colors.blue)),
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
              child: imageUrl.startsWith('http')
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: blackColor5),
                    )
                  : Image.asset(
                      imageUrl,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),
            Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(type.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: bodySize.clamp(9.0, 11.0),
                          fontWeight: FontWeight.bold,
                          color: primaryColor)),
                  SizedBox(height: padding * 0.25),
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

class _ContactQuoteSheet extends StatefulWidget {
  final VoidCallback? onSubmitted;

  const _ContactQuoteSheet({this.onSubmitted});

  @override
  State<_ContactQuoteSheet> createState() => _ContactQuoteSheetState();
}

class _ContactQuoteSheetState extends State<_ContactQuoteSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final message = _messageController.text.trim();
    final body = 'Name: $name\nEmail: $email\nPhone: $phone\n\nMessage:\n$message';
    final uri = Uri(
      scheme: 'mailto',
      path: companyEmail,
      query: _encodeQueryParameters({
        'subject': 'Free Quote Request - $name',
        'body': body,
      }),
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
    setState(() => _isSubmitting = false);
    widget.onSubmitted?.call();
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    return Container(
      decoration: const BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: 16 + padding.bottom,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: blackColor20,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Get Free Quote',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: blackColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Share your details and we\'ll get back to you.',
                style: TextStyle(fontSize: 14, color: blackColor60),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Your name',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'your@email.com',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter your email';
                  if (!v.contains('@')) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  hintText: '+91 98765 43210',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter your phone' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'Message / Project details',
                  hintText: 'Tell us about your project...',
                  border: OutlineInputBorder(),
                  filled: true,
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Submit Quote Request'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
