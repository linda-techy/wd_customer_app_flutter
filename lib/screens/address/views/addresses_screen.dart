import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../constants.dart';
import '../../../utils/responsive.dart';
import '../../../components/animations/fade_entry.dart';
import '../../../components/animations/hover_card.dart';
import '../../../components/animations/scale_button.dart';

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
      backgroundColor: surfaceColor,
      appBar: AppBar(
        title: const Text("Job Sites", style: TextStyle(color: blackColor, fontWeight: FontWeight.bold)),
        backgroundColor: surfaceColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: blackColor),
        actions: [
          IconButton(
            onPressed: _showAddJobSiteDialog,
            icon: const Icon(Icons.add_circle, color: primaryColor),
            tooltip: 'Add New Job Site',
          ),
        ],
      ),
      body: Stack(
        children: [
          jobSites.isEmpty ? _buildEmptyState() : _buildJobSitesList(),
          
          // Floating Map Button
          Positioned(
            bottom: defaultPadding * 2,
            right: defaultPadding,
            child: ScaleButton(
              onTap: () {
                 ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Map View coming soon')),
                  );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: blackColor,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: blackColor.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.map, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "View on Map",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).animate().slide(begin: const Offset(0, 1), curve: Curves.easeOutBack, duration: 600.ms),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: FadeEntry(
        delay: 200.ms,
        child: Padding(
          padding: EdgeInsets.all(ResponsiveSpacing.getPadding(context) * 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_city_rounded,
                  size: 60,
                  color: primaryColor,
                ),
              ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 24),
              Text(
                "No Job Sites Yet",
                style: TextStyle(
                  fontSize: ResponsiveFontSize.getTitle(context),
                  fontWeight: FontWeight.bold,
                  color: blackColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Add your construction project locations to track progress and manage site visits",
                style: TextStyle(
                  fontSize: ResponsiveFontSize.getBody(context),
                  color: blackColor60,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ScaleButton(
                onTap: _showAddJobSiteDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        "Add First Job Site",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobSitesList() {
    return ListView.builder(
      padding: const EdgeInsets.only(
          left: defaultPadding,
          right: defaultPadding,
          top: defaultPadding,
          bottom: defaultPadding * 6), // Space for floating button
      itemCount: jobSites.length,
      itemBuilder: (context, index) {
        final site = jobSites[index];
        return FadeEntry(
          delay: (100 * index).ms,
          child: _buildJobSiteCard(site, index),
        );
      },
    );
  }

  Widget _buildJobSiteCard(Map<String, dynamic> site, int index) {
    Color statusColor;
    IconData statusIcon;

    switch (site['status']) {
      case 'Active':
        statusColor = successColor;
        statusIcon = Icons.engineering;
        break;
      case 'Planning':
        statusColor = warningColor;
        statusIcon = Icons.architecture;
        break;
      case 'Completed':
        statusColor = Colors.blue;
        statusIcon = Icons.verified;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: HoverCard(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: blackColor.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: blackColor.withOpacity(0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with image
              Stack(
                children: [
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      image: DecorationImage(
                        image: NetworkImage(site['image']),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.business, size: 14, color: blackColor),
                          const SizedBox(width: 4),
                          Text(
                            site['type'].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10, 
                              fontWeight: FontWeight.w900,
                              color: blackColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(statusIcon, size: 12, color: Colors.white),
                          const SizedBox(width: 6),
                          if (site['status'] == 'Active')
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(right: 6),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ).animate(onPlay: (c) => c.repeat()).fade(duration: 800.ms),
                          Text(
                            site['status'],
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      site['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: blackColor,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined, size: 18, color: blackColor60),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            site['address'],
                            style: const TextStyle(
                              fontSize: 14,
                              color: blackColor60,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ScaleButton(
                            onTap: () => _showSiteDetails(site),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: blackColor10),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Text(
                                  "View Details",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: blackColor,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ScaleButton(
                            onTap: () => _requestSiteVisit(site),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: blackColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Text(
                                  "Request Visit",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
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
        ),
      ),
    );
  }

  void _showAddJobSiteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.add_location_alt, color: primaryColor),
            SizedBox(width: 12),
            Text("Add New Job Site"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Contact our team to add a new job site:"),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor.withOpacity(0.1)),
              ),
              child: const Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.phone, size: 20, color: primaryColor),
                      SizedBox(width: 12),
                      Text(
                        "+91-9074-9548-74",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                   SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.email, size: 20, color: primaryColor),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          companyEmail,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
             const SizedBox(height: 20),
            const Text(
              "We'll serve you set up site tracking surveillance and project management for your new location.",
              style: TextStyle(fontSize: 13, color: blackColor60, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: blackColor60)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Call action
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Call Now", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSiteDetails(Map<String, dynamic> site) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
             const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.location_city, color: primaryColor),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              site['name'],
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Text(
                              site['type'],
                              style: const TextStyle(color: blackColor60, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 48),
                   _buildDetailRow("Status", site['status'], isStatus: true),
                  _buildDetailRow("Address", site['address']),
                  _buildDetailRow("Contact", site['contact']),
                  _buildDetailRow("Coordinates",
                      "${site['coordinates']['lat']}, ${site['coordinates']['lng']}"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: blackColor60,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: isStatus 
            ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontSize: 14,
                ),
              ),
            )
            : Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: blackColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _requestSiteVisit(Map<String, dynamic> site) {
    final phone = site['contact']?.toString().replaceAll(' ', '') ?? '';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Site visit requested for ${site['name']}"),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: "Call Now",
          textColor: Colors.white,
          onPressed: () async {
            if (phone.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No contact number available')),
              );
              return;
            }
            final uri = Uri(scheme: 'tel', path: phone);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Cannot call $phone')),
                );
              }
            }
          },
        ),
      ),
    );
  }
}
