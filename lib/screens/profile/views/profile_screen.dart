import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../components/list_tile/divider_list_tile.dart';
import '../../../constants.dart';
import '../../../route/screen_export.dart';
import '../../../services/auth_service.dart';
import '../../../components/animations/fade_entry.dart';
import '../../../components/animations/hover_card.dart';
import '../../../providers/theme_provider.dart';

import 'components/profile_card.dart';
import 'components/profile_menu_item_list_tile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? currentUser;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await AuthService.getCurrentUser();
    final loggedIn = await AuthService.isLoggedIn();
    setState(() {
      currentUser = user;
      isLoggedIn = loggedIn;
    });
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: blackColor60)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleSignOut();
              },
              child: const Text(
                'Sign Out',
                style: TextStyle(color: errorColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleSignOut() async {
    try {
      await AuthService.logoutWithApi();
      if (mounted) {
        // Navigate to entry point to maintain menu visibility
        Navigator.pushNamedAndRemoveUntil(
          context,
          entryPointScreenRoute,
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signed out successfully'),
            backgroundColor: successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign out failed: ${e.toString()}'),
            backgroundColor: errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          // Profile Card
          FadeEntry(
            delay: 100.ms,
            child: ProfileCard(
              name: isLoggedIn && currentUser != null
                  ? currentUser!.name
                  : "Guest User",
              email: isLoggedIn && currentUser != null
                  ? currentUser!.email
                  : "Please log in to access your profile",
              imageSrc: "",
              press: () {
                if (isLoggedIn) {
                  Navigator.pushNamed(context, userInfoScreenRoute);
                } else {
                  Navigator.pushNamed(context, logInScreenRoute);
                }
              },
            ),
          ),

          // Referral Banner
          FadeEntry(
            delay: 200.ms,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: defaultPadding, vertical: defaultPadding * 1.5),
              child: HoverCard(
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD84940).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.people, color: Color(0xFFD84940)),
                            ),
                            const SizedBox(width: 12),
                            const Text('Refer a Friend'),
                          ],
                        ),
                        content: const Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Know someone planning to build? Refer them to Walldot Builders!',
                              style: TextStyle(height: 1.5),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Contact our team:',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Phone: +91-9074-9548-74\nEmail: $companyEmail',
                              style: TextStyle(height: 1.6),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Close', style: TextStyle(color: Color(0xFFD84940))),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFD84940), Color(0xFFE57373)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD84940).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.people,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Refer a Friend",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Recommend us to someone building a home",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Account Section
          _buildSectionHeader("Account", 300.ms),
          
          if (isLoggedIn) ...[
            _buildAnimatedTile(
              "My Projects",
              "assets/icons/document.svg",
              () => Navigator.pushNamed(context, projectScreenRoute),
              400.ms,
            ),
            _buildAnimatedTile(
              "Floor Plans & 3D Designs",
              "assets/icons/document.svg",
              () => Navigator.pushNamed(context, floorPlanScreenRoute),
              450.ms,
            ),
            _buildAnimatedTile(
              "Site Visits & Surveillance",
              "assets/icons/Location.svg",
              () => Navigator.pushNamed(context, cctvSurveillanceScreenRoute),
              500.ms,
            ),
            _buildAnimatedTile(
              "Project Documents",
              "assets/icons/document.svg",
              () => Navigator.pushNamed(context, documentsScreenRoute),
              550.ms,
            ),
            _buildAnimatedTile(
              "Payment & Invoices",
              "assets/icons/card.svg",
              () => Navigator.pushNamed(context, paymentsScreenRoute), // Linked existing route
              600.ms,
            ),
            const SizedBox(height: defaultPadding / 2),
            _buildAnimatedTile(
              "Sign Out",
              "assets/icons/Profile.svg",
              () => _showSignOutDialog(),
              650.ms,
            ),
          ] else ...[
            _buildAnimatedTile(
              "Login",
              "assets/icons/Profile.svg",
              () => Navigator.pushNamed(context, logInScreenRoute),
              400.ms,
            ),
          ],

          const SizedBox(height: defaultPadding),

          // Appearance Section
          _buildSectionHeader("Appearance", 670.ms),

          FadeEntry(
            delay: 680.ms,
            child: _buildThemeToggleTile(),
          ),

          const SizedBox(height: defaultPadding),

          // Notifications Section
          _buildSectionHeader("Notifications", 700.ms),

          FadeEntry(
            delay: 750.ms,
            child: DividerListTileWithTrilingText(
              svgSrc: "assets/icons/Notification.svg",
              title: "Notification",
              trailingText: "Off",
              onTap: () {
                Navigator.pushNamed(context, notificationsScreenRoute);
              },
            ),
          ),
          const SizedBox(height: defaultPadding),

          // Support Section
          _buildSectionHeader("Support & Information", 850.ms),
          
          _buildAnimatedTile(
            "Request Site Visit",
            "assets/icons/Location.svg",
             () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Call +91-9074-9548-74 to schedule a visit'),
                  backgroundColor: Color(0xFFD84940),
                ),
              );
            },
            900.ms,
          ),
          _buildAnimatedTile(
            "Contact Support",
            "assets/icons/Call.svg",
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Call: +91-9074-9548-74 | Email: $companyEmail'),
                  backgroundColor: Color(0xFFD84940),
                ),
              );
            },
            950.ms,
          ),
          _buildAnimatedTile(
            "About Walldot Builders",
            "assets/icons/Info.svg",
            () {
              _showAboutDialog();
            },
            1000.ms,
          ),

          const SizedBox(height: defaultPadding * 4),
        ],
      ),
    );
  }

  Widget _buildThemeToggleTile() {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isDark ? Colors.indigo : Colors.amber).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                color: isDark ? Colors.indigo : Colors.amber.shade700,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isDark ? "Dark Mode" : "Light Mode",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isDark ? "Switch to light theme" : "Switch to dark theme",
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
            Transform.scale(
              scale: 0.85,
              child: Switch(
                value: isDark,
                onChanged: (_) => themeProvider.toggleTheme(),
                activeColor: Colors.indigo,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Duration delay) {
    return FadeEntry(
      delay: delay,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: defaultPadding, vertical: defaultPadding / 2),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTile(String text, String icon, VoidCallback onTap, Duration delay) {
    return FadeEntry(
      delay: delay,
      child: ProfileMenuListTile(
        text: text,
        svgSrc: icon,
        press: onTap,
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFD84940).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.business,
                color: Color(0xFFD84940),
              ),
            ),
            const SizedBox(width: 12),
            const Text("About Us"),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Walldot Builders",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Color(0xFFD84940),
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Kerala's Trusted Construction Partner",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 16),
              Text(
                "With 5+ premium projects and ₹10Cr+ portfolio value, we specialize in delivering high-quality residential and commercial construction projects across Kerala.",
                style: TextStyle(height: 1.5),
              ),
              SizedBox(height: 12),
              Text(
                "🏆 100% Quality Guarantee\n📍 Kerala-based operations\n🏗️ Expert team of professionals\n💯 On-time project delivery",
                style: TextStyle(height: 1.8),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Close",
              style: TextStyle(color: Color(0xFFD84940)),
            ),
          ),
        ],
      ),
    );
  }
}
