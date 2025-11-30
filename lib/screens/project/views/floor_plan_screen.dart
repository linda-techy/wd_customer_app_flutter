import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../services/auth_service.dart';

class FloorPlanScreen extends StatefulWidget {
  const FloorPlanScreen({super.key, this.projectId});

  final String? projectId; // Support direct project ID for web refresh

  @override
  State<FloorPlanScreen> createState() => _FloorPlanScreenState();
}

class _FloorPlanScreenState extends State<FloorPlanScreen> {
  bool isLoggedIn = false;
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
          title: const Text("Floor Plan"),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text("Please log in to access floor plans"),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Floor Plan"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Downloading floor plan...')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing floor plan...')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Floor Plan Image Placeholder
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[100],
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map,
                    size: 80,
                    color: primaryColor.withOpacity(0.3),
                  ),
                  const SizedBox(height: defaultPadding),
                  Text(
                    "Floor Plan View",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Interactive floor plan will be displayed here",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: defaultPadding * 1.5),

            // Floor Plan Details
            Text(
              "Floor Plan Details",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
            ),
            const SizedBox(height: defaultPadding),

            _buildDetailCard(
              "Ground Floor",
              "Main entrance, living area, kitchen, dining room",
              Icons.home,
              Colors.blue,
            ),
            _buildDetailCard(
              "First Floor",
              "Bedrooms, bathrooms, study room",
              Icons.bed,
              Colors.green,
            ),
            _buildDetailCard(
              "Second Floor",
              "Master bedroom, balcony, storage",
              Icons.king_bed,
              Colors.orange,
            ),

            const SizedBox(height: defaultPadding * 1.5),

            // Specifications
            Text(
              "Specifications",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
            ),
            const SizedBox(height: defaultPadding),

            Container(
              padding: const EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  _buildSpecificationRow("Total Area", "2,500 sq ft"),
                  _buildSpecificationRow("Bedrooms", "4"),
                  _buildSpecificationRow("Bathrooms", "3"),
                  _buildSpecificationRow("Parking", "2 cars"),
                  _buildSpecificationRow("Floor Height", "10 ft"),
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
                        const SnackBar(content: Text('Opening 3D view...')),
                      );
                    },
                    icon: const Icon(Icons.view_in_ar),
                    label: const Text("3D View"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: defaultPadding),
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
                            content: Text('Opening measurements...')),
                      );
                    },
                    icon: const Icon(Icons.straighten),
                    label: const Text("Measurements"),
                    style: OutlinedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: defaultPadding),
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
    );
  }

  Widget _buildDetailCard(
      String title, String description, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: defaultPadding),
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(defaultPadding),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: defaultPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
