import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../route/screen_export.dart';
import '../../../services/auth_service.dart';
import '../../../components/walldot_logo.dart';
import '../../../utils/responsive.dart';

class OnbordingScrenn extends StatelessWidget {
  const OnbordingScrenn({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Responsive.isDesktop(context);
    final bool isTablet = Responsive.isTablet(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              const Color(0xFFFAFAFA),
              const Color(0xFFF5F5F5),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Main Content
              Center(
                child: SingleChildScrollView(
                  child: ResponsiveContainer(
                    maxWidth: isDesktop ? 1000 : 600,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            ResponsiveSpacing.getHorizontalPadding(context),
                        vertical: ResponsiveSpacing.getPadding(context) * 2,
                      ),
                      child: isDesktop
                          ? _buildDesktopLayout(context)
                          : _buildMobileLayout(context, isTablet),
                    ),
                  ),
                ),
              ),

              // Skip Button - Top Right
              Positioned(
                top: ResponsiveSpacing.getPadding(context),
                right: ResponsiveSpacing.getPadding(context),
                child: TextButton(
                  onPressed: () async {
                    print('Onboarding: Skip button clicked');
                    await AuthService.setWelcomeSeen();
                    // Navigate to entry shell and force Home tab (preserve login state)
                    Navigator.pushReplacementNamed(
                      context,
                      entryPointScreenRoute,
                      arguments: {'forceHome': true},
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  child: Text(
                    "Skip",
                    style: TextStyle(
                      color: blackColor60,
                      fontSize: ResponsiveFontSize.getBody(context),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Desktop Layout - Side by Side
  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left Side - Logo & Brand Story
        Expanded(
          flex: 5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with Animation
              Hero(
                tag: 'walldot_logo',
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: logoRed.withOpacity(0.15),
                        blurRadius: 40,
                        spreadRadius: 10,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const WalldotLogo(
                    size: 140,
                    showText: false,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Brand Story
              Text(
                "Building Excellence",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: logoRed,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Each dot represents a phase. The connections show our commitment to seamless construction—from vision to reality.",
                  style: TextStyle(
                    fontSize: 16,
                    color: blackColor60,
                    height: 1.6,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 60),

        // Right Side - Welcome & CTA
        Expanded(
          flex: 5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "WALLDOT BUILDERS",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: logoRed,
                  letterSpacing: 3.0,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 24),

              // Quick Value Points
              _buildValuePoint(context, "✓ Trusted Quality & Craftsmanship"),
              const SizedBox(height: 12),
              _buildValuePoint(context, "✓ Expert Team of Industry Leaders"),
              const SizedBox(height: 12),
              _buildValuePoint(context, "✓ Proven Results & Track Record"),

              const SizedBox(height: 40),

              // CTA Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    print(
                        'Onboarding: Start Building button clicked (Desktop)');
                    await AuthService.setWelcomeSeen();
                    // Navigate to entry shell and force Home tab (preserve login state)
                    Navigator.pushReplacementNamed(
                      context,
                      entryPointScreenRoute,
                      arguments: {'forceHome': true},
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: logoRed,
                    foregroundColor: Colors.white,
                    elevation: 6,
                    shadowColor: logoRed.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Start Building",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                "Your Vision. Our Expertise.",
                style: TextStyle(
                  fontSize: 16,
                  color: blackColor40,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Mobile/Tablet Layout - Compact Single Column
  Widget _buildMobileLayout(BuildContext context, bool isTablet) {
    final logoSize = isTablet ? 110.0 : 90.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo with Animation
        Hero(
          tag: 'walldot_logo',
          child: Container(
            padding: EdgeInsets.all(logoSize * 0.2),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: logoRed.withOpacity(0.15),
                  blurRadius: 30,
                  spreadRadius: 8,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: WalldotLogo(
              size: logoSize,
              showText: false,
            ),
          ),
        ),

        SizedBox(height: isTablet ? 32 : 24),

        // Company Name
        Text(
          "WALLDOT BUILDERS",
          style: TextStyle(
            fontSize: ResponsiveFontSize.getHeadline(context),
            fontWeight: FontWeight.w900,
            color: logoRed,
            letterSpacing: 2.5,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: isTablet ? 16 : 12),

        // Tagline
        Text(
          "Building Excellence",
          style: TextStyle(
            fontSize: ResponsiveFontSize.getTitle(context),
            fontWeight: FontWeight.w600,
            color: blackColor80,
            letterSpacing: 1.2,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: isTablet ? 24 : 20),

        // Brand Story - Compact
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 20),
          child: Container(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: blackColor.withOpacity(0.06),
                  blurRadius: 15,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(
                color: logoRed.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            child: Text(
              "Each dot represents a construction phase. The connections show our commitment to seamless building—from planning to completion.",
              style: TextStyle(
                fontSize: ResponsiveFontSize.getBody(context),
                color: blackColor60,
                height: 1.5,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        SizedBox(height: isTablet ? 24 : 20),

        // Value Points - Better Design
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 10),
          child: Column(
            children: [
              _buildMobileValueCard(
                context,
                icon: Icons.verified_outlined,
                title: "Trusted Quality",
                subtitle: "Premium craftsmanship",
                isTablet: isTablet,
              ),
              SizedBox(height: isTablet ? 12 : 10),
              _buildMobileValueCard(
                context,
                icon: Icons.engineering_outlined,
                title: "Expert Team",
                subtitle: "Industry leaders",
                isTablet: isTablet,
              ),
              SizedBox(height: isTablet ? 12 : 10),
              _buildMobileValueCard(
                context,
                icon: Icons.workspace_premium_outlined,
                title: "Proven Results",
                subtitle: "Track record",
                isTablet: isTablet,
              ),
            ],
          ),
        ),

        SizedBox(height: isTablet ? 32 : 24),

        // CTA Button
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () async {
              print('Onboarding: Start Building button clicked (Mobile)');
              await AuthService.setWelcomeSeen();
              // Navigate to entry shell and force Home tab (preserve login state)
              Navigator.pushReplacementNamed(
                context,
                entryPointScreenRoute,
                arguments: {'forceHome': true},
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: logoRed,
              foregroundColor: Colors.white,
              elevation: 6,
              shadowColor: logoRed.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Start Building",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: ResponsiveFontSize.getBody(context) + 2,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 18),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Secondary text
        Text(
          "Your Vision. Our Expertise.",
          style: TextStyle(
            fontSize: ResponsiveFontSize.getBody(context),
            color: blackColor40,
            fontStyle: FontStyle.italic,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildValuePoint(BuildContext context, String text) {
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: ResponsiveFontSize.getBody(context),
            color: blackColor80,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileValueCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isTablet,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 20 : 16,
        vertical: isTablet ? 16 : 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: logoRed.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon Circle
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: logoRed.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: isTablet ? 24 : 22,
              color: logoRed,
            ),
          ),
          SizedBox(width: isTablet ? 16 : 14),
          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveFontSize.getBody(context) + 1,
                    fontWeight: FontWeight.w700,
                    color: blackColor,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: ResponsiveFontSize.getBody(context) - 1,
                    color: blackColor60,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
