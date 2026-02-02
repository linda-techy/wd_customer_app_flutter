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
              // Main Content - viewport-bound, no scroll
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final maxHeight = constraints.maxHeight;
                    final padding = ResponsiveSpacing.getPadding(context);
                    return Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: maxHeight,
                          maxWidth: isDesktop ? 1000 : 600,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                ResponsiveSpacing.getHorizontalPadding(context),
                            vertical: padding * 2,
                          ),
                          child: isDesktop
                              ? _buildDesktopLayout(context)
                              : SizedBox(
                                  height: maxHeight - padding * 4,
                                  child: _buildMobileLayout(context, isTablet),
                                ),
                        ),
                      ),
                    );
                  },
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

  // Mobile/Tablet Layout - Viewport-fit, no scroll
  Widget _buildMobileLayout(BuildContext context, bool isTablet) {
    final height = MediaQuery.sizeOf(context).height;
    final isShortScreen = height < 600;
    // Slightly smaller logo on mobile to fit viewport; scale down further on very short screens
    final logoSize = isShortScreen
        ? 64.0
        : (isTablet ? 88.0 : 76.0);
    final spacing = isShortScreen ? 8.0 : (isTablet ? 16.0 : 12.0);
    final bodyFont = ResponsiveFontSize.getBody(context);
    final headlineFont = ResponsiveFontSize.getHeadline(context);
    final titleFont = ResponsiveFontSize.getTitle(context);

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        // Top: Logo + headline + tagline (fixed)
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
        SizedBox(height: spacing),
        Text(
          "WALLDOT BUILDERS",
          style: TextStyle(
            fontSize: isShortScreen ? headlineFont * 0.9 : headlineFont,
            fontWeight: FontWeight.w900,
            color: logoRed,
            letterSpacing: 2.5,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: spacing * 0.8),
        Text(
          "Building Excellence",
          style: TextStyle(
            fontSize: isShortScreen ? titleFont * 0.9 : titleFont,
            fontWeight: FontWeight.w600,
            color: blackColor80,
            letterSpacing: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: spacing),
        Text(
          "From vision to reality.",
          style: TextStyle(
            fontSize: isShortScreen ? bodyFont * 0.9 : bodyFont,
            color: blackColor60,
            letterSpacing: 0.3,
          ),
          textAlign: TextAlign.center,
        ),
        // Middle: value points in one row (flexible)
        Expanded(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMobileValueChip(
                    context,
                    icon: Icons.verified_outlined,
                    label: "Quality",
                    isTablet: isTablet,
                    isShortScreen: isShortScreen,
                  ),
                  _buildMobileValueChip(
                    context,
                    icon: Icons.engineering_outlined,
                    label: "Expert Team",
                    isTablet: isTablet,
                    isShortScreen: isShortScreen,
                  ),
                  _buildMobileValueChip(
                    context,
                    icon: Icons.workspace_premium_outlined,
                    label: "Results",
                    isTablet: isTablet,
                    isShortScreen: isShortScreen,
                  ),
                ],
              ),
            ),
          ),
        ),
        // Bottom: CTA + tagline (fixed)
        SizedBox(
          width: double.infinity,
          height: isShortScreen ? 48 : 54,
          child: ElevatedButton(
            onPressed: () async {
              await AuthService.setWelcomeSeen();
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
                    fontSize: bodyFont + 2,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 18),
              ],
            ),
          ),
        ),
        SizedBox(height: spacing),
        Text(
          "Your Vision. Our Expertise.",
          style: TextStyle(
            fontSize: isShortScreen ? bodyFont * 0.9 : bodyFont,
            color: blackColor40,
            fontStyle: FontStyle.italic,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileValueChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isTablet,
    required bool isShortScreen,
  }) {
    final size = isShortScreen ? 20.0 : (isTablet ? 24.0 : 22.0);
    final fontSize = isShortScreen
        ? ResponsiveFontSize.getBody(context) * 0.85
        : ResponsiveFontSize.getBody(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: logoRed.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: size, color: logoRed),
        ),
        SizedBox(height: isShortScreen ? 4 : 8),
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: blackColor80,
            letterSpacing: 0.2,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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

}
