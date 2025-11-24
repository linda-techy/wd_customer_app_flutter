import 'package:flutter/material.dart';
import '../../../components/list_tile/divider_list_tile.dart';
import '../../../constants.dart';
import '../../../route/screen_export.dart';
import '../../../services/auth_service.dart';

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
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleSignOut();
              },
              child: const Text(
                'Sign Out',
                style: TextStyle(color: errorColor),
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
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          // Profile Card
          ProfileCard(
            name: isLoggedIn && currentUser != null
                ? currentUser!.name
                : "Guest User",
            email: isLoggedIn && currentUser != null
                ? currentUser!.email
                : "Please log in to access your profile",
            imageSrc: isLoggedIn && currentUser != null
                ? "https://i.imgur.com/IXnwbLk.png"
                : "https://i.imgur.com/placeholder.png",
            press: () {
              if (isLoggedIn) {
                Navigator.pushNamed(context, userInfoScreenRoute);
              } else {
                Navigator.pushNamed(context, logInScreenRoute);
              }
            },
          ),

          // Construction Referral Banner
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding, vertical: defaultPadding * 1.5),
            child: GestureDetector(
              onTap: () {
                // TODO: Navigate to referral page
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Referral program coming soon')),
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.card_giftcard,
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
                            "Refer & Earn ₹10K-50K",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Kerala's biggest referral rewards",
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

          // Account Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: Text(
              "Account",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          const SizedBox(height: defaultPadding / 2),

          if (isLoggedIn) ...[
            // Show these options only when logged in
            ProfileMenuListTile(
              text: "My Projects",
              svgSrc: "assets/icons/document.svg",
              press: () {
                Navigator.pushNamed(context, projectScreenRoute);
              },
            ),
            ProfileMenuListTile(
              text: "Floor Plans & 3D Designs",
              svgSrc: "assets/icons/document.svg",
              press: () {
                Navigator.pushNamed(context, floorPlanScreenRoute);
              },
            ),
            ProfileMenuListTile(
              text: "Site Visits & Surveillance",
              svgSrc: "assets/icons/Location.svg",
              press: () {
                Navigator.pushNamed(context, cctvSurveillanceScreenRoute);
              },
            ),
            ProfileMenuListTile(
              text: "Project Documents",
              svgSrc: "assets/icons/document.svg",
              press: () {
                Navigator.pushNamed(context, documentsScreenRoute);
              },
            ),
            ProfileMenuListTile(
              text: "Payment & Invoices",
              svgSrc: "assets/icons/card.svg",
              press: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payment tracking coming soon'),
                    backgroundColor: Color(0xFFD84940),
                  ),
                );
              },
            ),
            const SizedBox(height: defaultPadding / 2),
            // Sign Out Option
            ProfileMenuListTile(
              text: "Sign Out",
              svgSrc: "assets/icons/Profile.svg",
              press: () {
                _showSignOutDialog();
              },
            ),
          ] else ...[
            // Show login option when not logged in
            ProfileMenuListTile(
              text: "Login",
              svgSrc: "assets/icons/Profile.svg",
              press: () {
                Navigator.pushNamed(context, logInScreenRoute);
              },
            ),
            ProfileMenuListTile(
              text: "Sign Up",
              svgSrc: "assets/icons/Profile.svg",
              press: () {
                Navigator.pushNamed(context, signUpScreenRoute);
              },
            ),
          ],

          const SizedBox(height: defaultPadding),

          // Personalization Section
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding, vertical: defaultPadding / 2),
            child: Text(
              "Personalization",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          DividerListTileWithTrilingText(
            svgSrc: "assets/icons/Notification.svg",
            title: "Notification",
            trailingText: "Off",
            onTap: () {
              Navigator.pushNamed(context, notificationsScreenRoute);
            },
          ),
          DividerListTileWithTrilingText(
            svgSrc: "assets/icons/Theme.svg",
            title: "Theme",
            trailingText: "Light",
            onTap: () {
              Navigator.pushNamed(context, preferencesScreenRoute);
            },
          ),
          const SizedBox(height: defaultPadding),

          // Support Section
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding, vertical: defaultPadding / 2),
            child: Text(
              "Support & Information",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ProfileMenuListTile(
            text: "Request Site Visit",
            svgSrc: "assets/icons/Location.svg",
            press: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Call +91-9074-9548-74 to schedule a visit'),
                  backgroundColor: Color(0xFFD84940),
                  duration: Duration(seconds: 3),
                ),
              );
            },
          ),
          ProfileMenuListTile(
            text: "Get Free Quote",
            svgSrc: "assets/icons/document.svg",
            press: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Call +91-9074-9548-74 for free consultation'),
                  backgroundColor: Color(0xFFD84940),
                  duration: Duration(seconds: 3),
                ),
              );
            },
          ),
          ProfileMenuListTile(
            text: "Contact Support",
            svgSrc: "assets/icons/Call.svg",
            press: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Call: +91-9074-9548-74 | Email: info@walldotbuilders.com'),
                  backgroundColor: Color(0xFFD84940),
                  duration: Duration(seconds: 4),
                ),
              );
            },
          ),
          ProfileMenuListTile(
            text: "About Walldot Builders",
            svgSrc: "assets/icons/Info.svg",
            press: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD84940).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
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
            },
          ),

          // Logout Section (only when logged in)
          if (isLoggedIn) ...[
            const SizedBox(height: defaultPadding),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: defaultPadding, vertical: defaultPadding / 2),
              child: Text(
                "Account",
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            ProfileMenuListTile(
              text: "Logout",
              svgSrc: "assets/icons/Logout.svg",
              press: () async {
                await AuthService.logout();
                setState(() {
                  isLoggedIn = false;
                  currentUser = null;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logged out successfully'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],

          const SizedBox(height: defaultPadding * 4),
        ],
      ),
    );
  }
}
