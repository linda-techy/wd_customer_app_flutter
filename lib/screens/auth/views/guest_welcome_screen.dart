import 'package:flutter/material.dart';

/// Marketing-optimized guest gate: no scroll, viewport-fit, focal CTA.
/// Designed for conversion: minimal friction, single clear action.
class GuestWelcomeScreen extends StatefulWidget {
  final VoidCallback onLoginPressed;

  const GuestWelcomeScreen({
    super.key,
    required this.onLoginPressed,
  });

  @override
  State<GuestWelcomeScreen> createState() => _GuestWelcomeScreenState();
}

class _GuestWelcomeScreenState extends State<GuestWelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isSmallHeight = size.height < 700;
    final isMobile = size.width < 600;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE74C3C), Color(0xFFD35400)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 20 : 48,
                    vertical: isSmallHeight ? 16 : 24,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // Top: compact hero
                      Flexible(
                        flex: 2,
                        fit: FlexFit.tight,
                        child: _buildHeader(isMobile, isSmallHeight),
                      ),
                      SizedBox(height: isSmallHeight ? 12 : 20),
                      // Middle: trust badges + stats (compact)
                      Flexible(
                        flex: 2,
                        fit: FlexFit.tight,
                        child: _buildValueSection(isMobile, isSmallHeight),
                      ),
                      SizedBox(height: isSmallHeight ? 12 : 20),
                      // Bottom: focal CTA
                      _buildCTAButton(isMobile),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile, bool isSmallHeight) {
    final iconSize = isSmallHeight ? 40.0 : (isMobile ? 48.0 : 56.0);
    final titleSize = isSmallHeight ? 22.0 : (isMobile ? 26.0 : 32.0);
    final subtitleSize = isSmallHeight ? 12.0 : (isMobile ? 13.0 : 14.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(isSmallHeight ? 12 : 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(Icons.construction, size: iconSize, color: Colors.white),
        ),
        SizedBox(height: isSmallHeight ? 12 : 16),
        Text(
          'Excellence. Transparency. Trust.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.2,
            letterSpacing: -0.3,
          ),
        ),
        SizedBox(height: isSmallHeight ? 4 : 8),
        Text(
          'A boutique collective for the top 0.1% of homeowners.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: subtitleSize,
            color: Colors.white.withOpacity(0.95),
            height: 1.3,
          ),
        ),
      ],
    );
  }

  /// Condensed value props: icon chips + stats in minimal space
  Widget _buildValueSection(bool isMobile, bool isSmallHeight) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon badges (no descriptions - saves height)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildValueChip(Icons.timeline, 'Track', isSmallHeight),
            SizedBox(width: isMobile ? 12 : 20),
            _buildValueChip(Icons.folder_rounded, 'Documents', isSmallHeight),
            SizedBox(width: isMobile ? 12 : 20),
            _buildValueChip(Icons.people_rounded, 'Collaborate', isSmallHeight),
          ],
        ),
        SizedBox(height: isSmallHeight ? 12 : 16),
        // Compact stats
        _buildStatsRow(isMobile, isSmallHeight),
      ],
    );
  }

  Widget _buildValueChip(IconData icon, String label, bool isSmall) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 10 : 14,
        vertical: isSmall ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isSmall ? 18 : 20, color: Colors.white),
          SizedBox(width: isSmall ? 4 : 6),
          Text(
            label,
            style: TextStyle(
              fontSize: isSmall ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(bool isMobile, bool isSmallHeight) {
    final valueSize = isSmallHeight ? 18.0 : (isMobile ? 20.0 : 24.0);
    final labelSize = isSmallHeight ? 9.0 : (isMobile ? 10.0 : 11.0);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallHeight ? 16 : 24,
        vertical: isSmallHeight ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat('5', 'Signature\nProjects', valueSize, labelSize),
          Container(
            width: 1,
            height: 28,
            color: Colors.white.withOpacity(0.3),
          ),
          _buildStat('100%', 'Transparency\nGuaranteed', valueSize, labelSize),
          Container(
            width: 1,
            height: 28,
            color: Colors.white.withOpacity(0.3),
          ),
          _buildStat('Top 0.1%', 'Elite\nFocus', valueSize, labelSize),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label, double valueSize, double labelSize) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: valueSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: labelSize,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildCTAButton(bool isMobile) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onLoginPressed,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Login to Continue',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 17,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFE74C3C),
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.arrow_forward_rounded, color: Color(0xFFE74C3C), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
