import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../services/auth_service.dart';

class ThreeDDesignScreen extends StatefulWidget {
  const ThreeDDesignScreen({super.key, this.projectId});

  final String? projectId; // Support direct project ID for web refresh

  @override
  State<ThreeDDesignScreen> createState() => _ThreeDDesignScreenState();
}

class _ThreeDDesignScreenState extends State<ThreeDDesignScreen> {
  bool isLoggedIn = false;
  int selectedView = 0;
  String? projectId;

  @override
  void initState() {
    super.initState();
    projectId = widget.projectId;
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
        appBar: AppBar(
          title: const Text("3D Design"),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text("Please log in to access 3D designs"),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("3D Design"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.fullscreen),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening fullscreen view...')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing 3D design...')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // View Selector
          Container(
            padding: const EdgeInsets.all(defaultPadding),
            child: Row(
              children: [
                Expanded(
                  child: _buildViewButton("Exterior", 0, Icons.home),
                ),
                const SizedBox(width: defaultPadding / 2),
                Expanded(
                  child: _buildViewButton("Interior", 1, Icons.living),
                ),
                const SizedBox(width: defaultPadding / 2),
                Expanded(
                  child: _buildViewButton("Walkthrough", 2, Icons.view_in_ar),
                ),
              ],
            ),
          ),

          // 3D View Area
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: defaultPadding),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[100],
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    selectedView == 0
                        ? Icons.home
                        : selectedView == 1
                            ? Icons.living
                            : Icons.view_in_ar,
                    size: 80,
                    color: primaryColor.withOpacity(0.3),
                  ),
                  const SizedBox(height: defaultPadding),
                  Text(
                    selectedView == 0
                        ? "Exterior View"
                        : selectedView == 1
                            ? "Interior View"
                            : "3D Walkthrough",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedView == 0
                        ? "Building exterior and landscaping"
                        : selectedView == 1
                            ? "Interior rooms and spaces"
                            : "Interactive 3D walkthrough experience",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: defaultPadding),

                  // Control Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.rotate_left),
                        tooltip: "Rotate Left",
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.zoom_in),
                        tooltip: "Zoom In",
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.zoom_out),
                        tooltip: "Zoom Out",
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.rotate_right),
                        tooltip: "Rotate Right",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Design Details
          Container(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Design Features",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                ),
                const SizedBox(height: defaultPadding),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFeatureCard(
                          "Modern Architecture",
                          "Contemporary design with clean lines",
                          Icons.architecture),
                      _buildFeatureCard("Energy Efficient",
                          "Solar panels and smart systems", Icons.solar_power),
                      _buildFeatureCard("Smart Home",
                          "Automated lighting and security", Icons.home),
                      _buildFeatureCard("Landscaping",
                          "Beautiful gardens and outdoor spaces", Icons.park),
                    ],
                  ),
                ),

                const SizedBox(height: defaultPadding * 1.5),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Starting VR experience...')),
                          );
                        },
                        icon: const Icon(Icons.view_in_ar),
                        label: const Text("VR Experience"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: defaultPadding),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: defaultPadding),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Opening design options...')),
                          );
                        },
                        icon: const Icon(Icons.palette),
                        label: const Text("Customize"),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: defaultPadding),
                          side: BorderSide(color: primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewButton(String title, int index, IconData icon) {
    final isSelected = selectedView == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedView = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: defaultPadding / 2),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey[300]!,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, String description, IconData icon) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: defaultPadding),
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: primaryColor,
            size: 24,
          ),
          const SizedBox(height: defaultPadding / 2),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }
}
