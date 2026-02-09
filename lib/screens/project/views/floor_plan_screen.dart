import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../constants.dart';
import '../../../services/auth_service.dart';
import '../../../services/project_module_service.dart';
import '../../../config/api_config.dart';
import '../../../models/project_module_models.dart';
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
  ProjectModuleService? _service;
  List<GalleryImage> _floorPlanImages = [];
  bool _isLoading = true;
  String? _error;
  
  final List<String> floors = ["Ground Floor", "First Floor", "Second Floor"];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final loggedIn = await AuthService.isLoggedIn();
    if (loggedIn) {
      final token = await AuthService.getAccessToken();
      if (token != null) {
        _service = ProjectModuleService(baseUrl: ApiConfig.baseUrl, token: token);
        await _loadFloorPlans();
      }
    }
    setState(() {
      isLoggedIn = loggedIn;
      _isLoading = false;
    });
  }

  Future<void> _loadFloorPlans() async {
    if (_service == null || widget.projectId == null) return;
    try {
      // Fetch gallery images - floor plans are typically in the gallery
      final images = await _service!.getGalleryImages(widget.projectId!);
      // Filter for floor plan related images by caption/description
      final floorPlans = images.where((img) {
        final caption = (img.caption ?? '').toLowerCase();
        return caption.contains('floor') || caption.contains('plan') || caption.contains('layout');
      }).toList();
      setState(() {
        _floorPlanImages = floorPlans.isNotEmpty ? floorPlans : images.take(3).toList();
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
        actions: [
          if (_floorPlanImages.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Chip(
                label: Text('${_floorPlanImages.length} plan${_floorPlanImages.length == 1 ? '' : 's'}',
                    style: const TextStyle(fontSize: 12)),
                backgroundColor: primaryColor.withOpacity(0.1),
              ),
            ),
        ],
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
                      // Content - show floor plan image if available
                      if (_floorPlanImages.isNotEmpty && selectedFloor < _floorPlanImages.length)
                        Positioned.fill(
                          child: Image.network(
                            '${ApiConfig.baseUrl}${_floorPlanImages[selectedFloor].imagePath}',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => _buildPlaceholderContent(),
                          ),
                        )
                      else
                        _buildPlaceholderContent(),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Floor Selector - Floating Bottom
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
                  children: List.generate(
                    _floorPlanImages.isNotEmpty ? _floorPlanImages.length : floors.length,
                    (index) {
                      final isSelected = selectedFloor == index;
                      final label = _floorPlanImages.isNotEmpty && index < _floorPlanImages.length
                          ? _floorPlanImages[index].caption ?? 'Floor ${index + 1}'
                          : floors[index < floors.length ? index : 0];
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
                            label.length > 12 ? '${label.substring(0, 12)}...' : label,
                            style: TextStyle(
                              color: isSelected ? blackColor : Colors.white60,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
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
                  _buildToolButton(Icons.add, "Zoom In", () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Use pinch gesture to zoom in'), duration: Duration(seconds: 1)),
                    );
                  }),
                  const SizedBox(height: 8),
                  _buildToolButton(Icons.remove, "Zoom Out", () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Use pinch gesture to zoom out'), duration: Duration(seconds: 1)),
                    );
                  }),
                  const SizedBox(height: 8),
                  _buildToolButton(Icons.refresh, "Refresh", () {
                    setState(() => _isLoading = true);
                    _loadFloorPlans().then((_) => setState(() => _isLoading = false));
                  }),
                  const SizedBox(height: 8),
                  const Divider(height: 16),
                  _buildToolButton(Icons.info_outline, "Details", _showDetailsSheet),
                ],
              ),
            ),
          ).animate().slide(begin: const Offset(1, 0), curve: Curves.easeOutBack, duration: 800.ms),
        ],
      ),
    );
  }

  Widget _buildPlaceholderContent() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.map_outlined, size: 80, color: primaryColor.withOpacity(0.2)),
          const SizedBox(height: 20),
          Text(
            selectedFloor < floors.length ? floors[selectedFloor] : 'Floor ${selectedFloor + 1}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: blackColor.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _floorPlanImages.isEmpty
                ? 'No floor plans uploaded yet'
                : 'Pinch to zoom \u2022 Drag to pan',
            style: TextStyle(
              fontSize: 13,
              color: blackColor.withOpacity(0.3),
            ),
          ),
        ],
      ),
    ).animate(key: ValueKey(selectedFloor)).fadeIn(duration: 400.ms);
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
                    selectedFloor < floors.length ? floors[selectedFloor] : 'Floor ${selectedFloor + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Project #${widget.projectId ?? 'N/A'}",
                      style: const TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 18, color: primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _floorPlanImages.isEmpty
                            ? 'Floor plan images will appear here once uploaded by your contractor.'
                            : '${_floorPlanImages.length} floor plan image${_floorPlanImages.length == 1 ? '' : 's'} available. Use pinch to zoom and drag to pan.',
                        style: TextStyle(color: blackColor.withOpacity(0.6), fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text('Note: ${ _error}', style: const TextStyle(fontSize: 12, color: Colors.orange)),
              ],
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
                  child: const Text("Close"),
                ),
              ),
            ],
          ),
        ),
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
