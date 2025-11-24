import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../utils/responsive.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  // Sample job sites for construction projects
  final List<Map<String, dynamic>> jobSites = [
    {
      'name': 'Villa Project - Kochi',
      'address': 'Panampilly Nagar, Kochi, Kerala 682036',
      'type': 'Residential',
      'status': 'Active',
      'contact': '+91 98765 43210',
      'coordinates': {'lat': 9.9674, 'lng': 76.3166},
      'image':
          'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=400',
    },
    {
      'name': 'Office Complex - Thiruvananthapuram',
      'address': 'Technopark, Thiruvananthapuram, Kerala 695581',
      'type': 'Commercial',
      'status': 'Planning',
      'contact': '+91 98765 43211',
      'coordinates': {'lat': 8.5081, 'lng': 76.9566},
      'image':
          'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=400',
    },
    {
      'name': 'Industrial Unit - Kozhikode',
      'address': 'Industrial Area, Kozhikode, Kerala 673001',
      'type': 'Industrial',
      'status': 'Completed',
      'contact': '+91 98765 43212',
      'coordinates': {'lat': 11.2588, 'lng': 75.7804},
      'image':
          'https://images.unsplash.com/photo-1590948347862-c1c4e5e0e3de?w=400',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Job Sites"),
        backgroundColor: logoRed,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              _showAddJobSiteDialog();
            },
            icon: const Icon(Icons.add_location_alt),
            tooltip: 'Add New Job Site',
          ),
        ],
      ),
      body: jobSites.isEmpty ? _buildEmptyState() : _buildJobSitesList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddJobSiteDialog();
        },
        backgroundColor: logoRed,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_location_alt),
        label: const Text("Add Job Site"),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveSpacing.getPadding(context) * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: logoRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.location_city_outlined,
                size: 80,
                color: logoRed,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "No Job Sites Yet",
              style: TextStyle(
                fontSize: ResponsiveFontSize.getTitle(context),
                fontWeight: FontWeight.w700,
                color: logoGreyDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Add your construction project locations to track progress and manage site visits",
              style: TextStyle(
                fontSize: ResponsiveFontSize.getBody(context),
                color: logoGreyDark.withOpacity(0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                _showAddJobSiteDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: logoRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.add_location_alt),
              label: const Text("Add First Job Site"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobSitesList() {
    return ListView.builder(
      padding: EdgeInsets.all(ResponsiveSpacing.getPadding(context)),
      itemCount: jobSites.length,
      itemBuilder: (context, index) {
        final site = jobSites[index];
        return _buildJobSiteCard(site, index);
      },
    );
  }

  Widget _buildJobSiteCard(Map<String, dynamic> site, int index) {
    Color statusColor;
    IconData statusIcon;

    switch (site['status']) {
      case 'Active':
        statusColor = Colors.green;
        statusIcon = Icons.construction;
        break;
      case 'Planning':
        statusColor = Colors.orange;
        statusIcon = Icons.assignment;
        break;
      case 'Completed':
        statusColor = Colors.blue;
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: logoRed.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with image and status
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              image: DecorationImage(
                image: NetworkImage(site['image']),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                // Status badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          site['status'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Type badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      site['type'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  site['name'],
                  style: TextStyle(
                    fontSize: ResponsiveFontSize.getBody(context) + 2,
                    fontWeight: FontWeight.w700,
                    color: logoGreyDark,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: logoRed,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        site['address'],
                        style: TextStyle(
                          fontSize: ResponsiveFontSize.getBody(context) - 1,
                          color: logoGreyDark.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.phone,
                      size: 16,
                      color: logoRed,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      site['contact'],
                      style: TextStyle(
                        fontSize: ResponsiveFontSize.getBody(context) - 1,
                        color: logoGreyDark.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showSiteDetails(site);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: logoRed,
                          side: const BorderSide(color: logoRed),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.info_outline, size: 16),
                        label: const Text("Details"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _requestSiteVisit(site);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: logoRed,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.visibility, size: 16),
                        label: const Text("Visit"),
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

  void _showAddJobSiteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.add_location_alt, color: logoRed),
            SizedBox(width: 12),
            Text("Add New Job Site"),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Contact our team to add a new job site:"),
              SizedBox(height: 16),
              Text(
                "📞 Call: +91-9074-9548-74",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "📧 Email: info@walldotbuilders.com",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12),
              Text(
                "We'll help you set up site tracking, surveillance, and project management for your new location.",
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showSiteDetails(Map<String, dynamic> site) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.location_city, color: logoRed),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                site['name'],
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow("Status", site['status']),
              _buildDetailRow("Type", site['type']),
              _buildDetailRow("Address", site['address']),
              _buildDetailRow("Contact", site['contact']),
              _buildDetailRow("Coordinates",
                  "${site['coordinates']['lat']}, ${site['coordinates']['lng']}"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _requestSiteVisit(Map<String, dynamic> site) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Site visit requested for ${site['name']}"),
        backgroundColor: logoRed,
        action: SnackBarAction(
          label: "Call Now",
          textColor: Colors.white,
          onPressed: () {
            // TODO: Implement phone call
          },
        ),
      ),
    );
  }
}
