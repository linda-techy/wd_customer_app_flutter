import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../route/screen_export.dart';
import '../../../services/auth_service.dart';
import '../../../components/walldot_logo.dart';
import '../../../utils/responsive.dart';

class OnbordingScrenn extends StatefulWidget {
  const OnbordingScrenn({super.key});

  @override
  State<OnbordingScrenn> createState() => _OnbordingScrennState();
}

class _OnbordingScrennState extends State<OnbordingScrenn>
    with TickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 1400);

  late final AnimationController _controller;
  late final Animation<double> _logoAnim;
  late final Animation<double> _headlineAnim;
  late final Animation<double> _taglineAnim;
  late final Animation<double> _storyAnim;
  late final Animation<double> _chip1Anim;
  late final Animation<double> _chip2Anim;
  late final Animation<double> _chip3Anim;
  late final Animation<double> _ctaAnim;
  late final Animation<double> _footerAnim;
  late final Animation<double> _skipAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration);
    const curve = Curves.easeOutCubic;
    const logoCurve = Curves.easeOutBack;
    _logoAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.22, curve: logoCurve),
      ),
    );
    _headlineAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.08, 0.28, curve: curve),
      ),
    );
    _taglineAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.14, 0.34, curve: curve),
      ),
    );
    _storyAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.20, 0.42, curve: curve),
      ),
    );
    _chip1Anim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.28, 0.50, curve: curve),
      ),
    );
    _chip2Anim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.36, 0.58, curve: curve),
      ),
    );
    _chip3Anim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.44, 0.66, curve: curve),
      ),
    );
    _ctaAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.52, 0.78, curve: curve),
      ),
    );
    _footerAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.60, 0.84, curve: curve),
      ),
    );
    _skipAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.18, curve: curve),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _slideFade(Animation<double> anim, Widget child) {
    return AnimatedBuilder(
      animation: anim,
      builder: (context, child) {
        return Opacity(
          opacity: anim.value,
          child: Transform.translate(
            offset: Offset(0, (1 - anim.value) * 20),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _scaleFade(Animation<double> anim, Widget child) {
    return AnimatedBuilder(
      animation: anim,
      builder: (context, child) {
        final scale = 0.85 + 0.15 * anim.value;
        return Opacity(
          opacity: anim.value,
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Responsive.isDesktop(context);
    final bool isTablet = Responsive.isTablet(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Color(0xFFFAFAFA),
              Color(0xFFF5F5F5),
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
                              ? _slideFade(_logoAnim, _buildDesktopLayout(context))
                              : SizedBox(
                                  height: maxHeight - padding * 4,
                                  child: _buildMobileLayout(
                                    context,
                                    isTablet,
                                    logoAnim: _logoAnim,
                                    headlineAnim: _headlineAnim,
                                    taglineAnim: _taglineAnim,
                                    storyAnim: _storyAnim,
                                    chip1Anim: _chip1Anim,
                                    chip2Anim: _chip2Anim,
                                    chip3Anim: _chip3Anim,
                                    ctaAnim: _ctaAnim,
                                    footerAnim: _footerAnim,
                                  ),
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
                child: _slideFade(
                  _skipAnim,
                  TextButton(
                  onPressed: () async {
                    debugPrint('Onboarding: Skip button clicked');
                    await AuthService.setWelcomeSeen();
                    if (!context.mounted) return;
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
              const Text(
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

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
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
              const Text(
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
                    debugPrint(
                        'Onboarding: Start Building button clicked (Desktop)');
                    await AuthService.setWelcomeSeen();
                    if (!context.mounted) return;
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
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Start Building",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
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

  // Mobile/Tablet Layout - Viewport-fit, no scroll, with staggered transitions
  Widget _buildMobileLayout(
    BuildContext context,
    bool isTablet, {
    required Animation<double> logoAnim,
    required Animation<double> headlineAnim,
    required Animation<double> taglineAnim,
    required Animation<double> storyAnim,
    required Animation<double> chip1Anim,
    required Animation<double> chip2Anim,
    required Animation<double> chip3Anim,
    required Animation<double> ctaAnim,
    required Animation<double> footerAnim,
  }) {
    final height = MediaQuery.sizeOf(context).height;
    final isShortScreen = height < 600;
    final logoSize =
        isShortScreen ? 64.0 : (isTablet ? 88.0 : 76.0);
    final spacing = isShortScreen ? 8.0 : (isTablet ? 16.0 : 12.0);
    final bodyFont = ResponsiveFontSize.getBody(context);
    final headlineFont = ResponsiveFontSize.getHeadline(context);
    final titleFont = ResponsiveFontSize.getTitle(context);

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        _scaleFade(
          logoAnim,
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
        ),
        SizedBox(height: spacing),
        _slideFade(
          headlineAnim,
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
        ),
        SizedBox(height: spacing * 0.8),
        _slideFade(
          taglineAnim,
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
        ),
        SizedBox(height: spacing),
        _slideFade(
          storyAnim,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 20),
            child: Text(
              "Each dot represents a construction phase. The connections show our commitment to seamless building—from planning to completion.",
              style: TextStyle(
                fontSize: isShortScreen ? bodyFont * 0.85 : bodyFont,
                color: blackColor60,
                height: 1.4,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _slideFade(
                    chip1Anim,
                    _buildMobileValueChip(
                      context,
                      icon: Icons.verified_outlined,
                      title: "Trusted Quality",
                      subtitle: "Premium craftsmanship",
                      isTablet: isTablet,
                      isShortScreen: isShortScreen,
                    ),
                  ),
                  _slideFade(
                    chip2Anim,
                    _buildMobileValueChip(
                      context,
                      icon: Icons.engineering_outlined,
                      title: "Expert Team",
                      subtitle: "Industry leaders",
                      isTablet: isTablet,
                      isShortScreen: isShortScreen,
                    ),
                  ),
                  _slideFade(
                    chip3Anim,
                    _buildMobileValueChip(
                      context,
                      icon: Icons.workspace_premium_outlined,
                      title: "Proven Results",
                      subtitle: "Track record",
                      isTablet: isTablet,
                      isShortScreen: isShortScreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _slideFade(
          ctaAnim,
          SizedBox(
            width: double.infinity,
            height: isShortScreen ? 48 : 54,
            child: ElevatedButton(
              onPressed: () async {
                await AuthService.setWelcomeSeen();
                if (!context.mounted) return;
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
        ),
        SizedBox(height: spacing),
        _slideFade(
          footerAnim,
          Text(
            "Your Vision. Our Expertise.",
            style: TextStyle(
              fontSize: isShortScreen ? bodyFont * 0.9 : bodyFont,
              color: blackColor40,
              fontStyle: FontStyle.italic,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileValueChip(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isTablet,
    required bool isShortScreen,
  }) {
    final size = isShortScreen ? 20.0 : (isTablet ? 24.0 : 22.0);
    final titleFontSize = isShortScreen
        ? ResponsiveFontSize.getBody(context) * 0.85
        : ResponsiveFontSize.getBody(context);
    final subtitleFontSize = isShortScreen
        ? ResponsiveFontSize.getBody(context) * 0.75
        : ResponsiveFontSize.getBody(context) - 1;

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
          title,
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.w700,
            color: blackColor,
            letterSpacing: 0.2,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: isShortScreen ? 2 : 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: subtitleFontSize,
            fontWeight: FontWeight.w400,
            color: blackColor60,
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
