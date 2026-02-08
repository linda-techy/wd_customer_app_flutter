import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../constants.dart';
import '../../../services/auth_service.dart';
import '../../../components/animations/scale_button.dart';

class ThreeDDesignScreen extends StatefulWidget {
  const ThreeDDesignScreen({super.key, this.projectId});

  final String? projectId;

  @override
  State<ThreeDDesignScreen> createState() => _ThreeDDesignScreenState();
}

class _ThreeDDesignScreenState extends State<ThreeDDesignScreen> {
  bool isLoggedIn = false;
  int selectedView = 0;
  
  // Simulated 3D views
  final List<Map<String, dynamic>> views = [
    {"name": "Exterior", "icon": Icons.home_outlined},
    {"name": "Interior", "icon": Icons.chair_outlined},
    {"name": "Walkthrough", "icon": Icons.directions_walk},
    {"name": "Bird's Eye", "icon": Icons.flight_takeoff},
  ];

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final loggedIn = await AuthService.isLoggedIn();
    setState(() {
      isLoggedIn = loggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text("3D Design"), backgroundColor: surfaceColor),
        body: const Center(child: Text("Please log in to access 3D designs")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black, // Dark background for cinema feel
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("3D Virtual Tour", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.fullscreen, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 3D Viewport Placeholder
          InteractiveViewer(
             minScale: 0.5,
            maxScale: 2.0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    Color(0xFF2C3E50),
                    Colors.black,
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      views[selectedView]['icon'], 
                      size: 100, 
                      color: Colors.white.withOpacity(0.2)
                    ).animate(key: ValueKey(selectedView))
                    .scale(duration: 600.ms, curve: Curves.easeOutBack)
                    .fadeIn(),
                    const SizedBox(height: 20),
                    Text(
                      "${views[selectedView]['name']} View",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ).animate(key: ValueKey(selectedView)).fadeIn(delay: 200.ms),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Drag to Rotate • Pinch to Zoom",
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // View Selector - Floating Bottom
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(views.length, (index) {
                        final isSelected = selectedView == index;
                        return GestureDetector(
                          onTap: () => setState(() => selectedView = index),
                          child: AnimatedContainer(
                            duration: 300.ms,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? primaryColor : Colors.transparent,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  views[index]['icon'],
                                  color: isSelected ? Colors.white : Colors.white70,
                                  size: 18,
                                ),
                                if (isSelected) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    views[index]['name'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ).animate().slide(begin: const Offset(0, 1), curve: Curves.easeOutBack, duration: 600.ms),

          // Side Tools
          Positioned(
            top: 120,
            right: 20,
            child: Column(
              children: [
                _buildSideButton(Icons.layers, "Layers", () {}),
                const SizedBox(height: 12),
                _buildSideButton(Icons.wb_sunny, "Lighting", () {}),
                const SizedBox(height: 12),
                _buildSideButton(Icons.straighten, "Measure", () {}),
                const SizedBox(height: 12),
                _buildSideButton(Icons.info_outline, "Info", _showInfoSheet),
              ],
            ).animate().slide(begin: const Offset(1, 0), curve: Curves.easeOutBack, duration: 800.ms),
          ),
        ],
      ),
    );
  }

  Widget _buildSideButton(IconData icon, String tooltip, VoidCallback onTap) {
    return ScaleButton(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  void _showInfoSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Modern Villa Design",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Version 2.4 • Updated yesterday",
              style: TextStyle(color: blackColor.withOpacity(0.6)),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildInfoStat("Area", "2,500 sq ft"),
                _buildInfoStat("Style", "Modern"),
                _buildInfoStat("Est. Cost", "\$150k"),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Close Details"),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoStat(String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: blackColor10),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: blackColor60)),
             const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
