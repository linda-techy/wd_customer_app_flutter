import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../constants.dart';
import '../../../services/auth_service.dart';
import '../../../components/animations/scale_button.dart';

class FloorPlanScreen extends StatefulWidget {
  const FloorPlanScreen({super.key, this.projectId});

  final String? projectId;

  @override
  State<FloorPlanScreen> createState() => _FloorPlanScreenState();
}

class _FloorPlanScreenState extends State<FloorPlanScreen> {
  bool isLoggedIn = false;
  int selectedFloor = 0;
  
  final List<String> floors = ["Ground Floor", "First Floor", "Second Floor"];

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
        appBar: AppBar(title: const Text("Floor Plan"), backgroundColor: surfaceColor),
        body: const Center(child: Text("Please log in to access floor plans")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Floor Plan", style: TextStyle(color: blackColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white.withOpacity(0.8),
        iconTheme: const IconThemeData(color: blackColor),
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Main Interactive Area
          InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Stack(
                    children: [
                      // Grid Pattern
                       CustomPaint(
                        painter: GridPainter(),
                        size: Size.infinite,
                      ),
                      // Content Placeholder
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.map_outlined, size: 80, color: primaryColor.withOpacity(0.2)),
                            const SizedBox(height: 20),
                            Text(
                              floors[selectedFloor],
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: blackColor.withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                      ).animate(key: ValueKey(selectedFloor)).fadeIn(duration: 400.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Floating Controls - Bottom Center
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: blackColor.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: blackColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(floors.length, (index) {
                    final isSelected = selectedFloor == index;
                    return GestureDetector(
                      onTap: () => setState(() => selectedFloor = index),
                      child: AnimatedContainer(
                        duration: 300.ms,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          "Floor ${index + 1}",
                          style: TextStyle(
                            color: isSelected ? blackColor : Colors.white60,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ).animate().slide(begin: const Offset(0, 1), curve: Curves.easeOutBack, duration: 600.ms),

          // Side Vertical Toolbar
          Positioned(
            right: 20,
            top: 120,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: blackColor.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildToolButton(Icons.add, "Zoom In", () {}),
                  const SizedBox(height: 8),
                  _buildToolButton(Icons.remove, "Zoom Out", () {}),
                  const SizedBox(height: 8),
                  _buildToolButton(Icons.refresh, "Reset", () {}),
                  const SizedBox(height: 8),
                  const Divider(height: 16),
                  _buildToolButton(Icons.info_outline, "Details", () {
                    _showDetailsSheet();
                  }),
                ],
              ),
            ),
          ).animate().slide(begin: const Offset(1, 0), curve: Curves.easeOutBack, duration: 800.ms),
        ],
      ),
    );
  }

  Widget _buildToolButton(IconData icon, String tooltip, VoidCallback onTap) {
    return ScaleButton(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: blackColor, size: 24),
      ),
    );
  }

  void _showDetailsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.2,
        maxChildSize: 0.7,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    floors[selectedFloor],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "2,500 sq ft",
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text(
                "Features a spacious open-plan living area, modern kitchen with island, and direct access to the garden patio. Includes a guest bedroom and study.",
                style: TextStyle(color: blackColor.withOpacity(0.6), height: 1.5),
              ),
              const SizedBox(height: 24),
              const Text("Rooms", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildRoomChip("Living Room", "24x18"),
                  _buildRoomChip("Kitchen", "16x14"),
                  _buildRoomChip("Dining", "14x12"),
                  _buildRoomChip("Guest Bed", "12x12"),
                  _buildRoomChip("Study", "10x10"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoomChip(String name, String size) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.meeting_room_outlined, color: blackColor.withOpacity(0.6)),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(size, style: TextStyle(fontSize: 12, color: blackColor.withOpacity(0.5))),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..strokeWidth = 1;

    const gridSize = 40.0;

    for (var x = 0.0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (var y = 0.0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
