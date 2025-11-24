import 'package:flutter/material.dart';
import '../../../constants.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(defaultPadding * 1.5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor,
                      primaryColor.withOpacity(0.9),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Portfolio",
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Our award-winning construction projects",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                    ),
                  ],
                ),
              ),
            ),

            // Portfolio Items
            SliverPadding(
              padding: const EdgeInsets.all(defaultPadding * 1.5),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _buildPortfolioItem(context, index);
                  },
                  childCount: 4,
                ),
              ),
            ),

            // Bottom padding for navigation bar
            const SliverToBoxAdapter(
              child: SizedBox(height: defaultPadding * 4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortfolioItem(BuildContext context, int index) {
    final portfolioData = [
      {
        'title': 'Skyline Office Tower',
        'category': 'Commercial',
        'location': 'Downtown Business District',
        'year': '2023',
        'description':
            'A 25-story modern office complex featuring sustainable design, smart building technology, and premium amenities. This LEED-certified building includes rooftop gardens, energy-efficient systems, and state-of-the-art conference facilities.',
        'features': [
          '25 Stories',
          'LEED Certified',
          'Smart Building',
          'Rooftop Garden'
        ],
        'icon': Icons.business,
        'color': Colors.blue,
      },
      {
        'title': 'Luxury Residential Complex',
        'category': 'Residential',
        'location': 'Exclusive Suburban Area',
        'year': '2023',
        'description':
            'Premium residential development with 50 luxury apartments, featuring high-end finishes, private balconies, and community amenities including swimming pool, fitness center, and landscaped gardens.',
        'features': [
          '50 Units',
          'Luxury Finishes',
          'Swimming Pool',
          'Fitness Center'
        ],
        'icon': Icons.apartment,
        'color': Colors.green,
      },
      {
        'title': 'Industrial Manufacturing Facility',
        'category': 'Industrial',
        'location': 'Industrial Technology Park',
        'year': '2022',
        'description':
            'State-of-the-art manufacturing facility designed for efficiency and sustainability. Features advanced automation systems, energy-efficient lighting, and environmentally responsible waste management.',
        'features': [
          '100,000 sq ft',
          'Automated Systems',
          'Energy Efficient',
          'Green Certified'
        ],
        'icon': Icons.factory,
        'color': Colors.orange,
      },
      {
        'title': 'Modern Shopping Center',
        'category': 'Commercial',
        'location': 'City Center',
        'year': '2022',
        'description':
            'Contemporary shopping center with 100+ retail spaces, entertainment venues, and dining options. Features open-air design, sustainable materials, and smart parking systems.',
        'features': [
          '100+ Stores',
          'Entertainment Venues',
          'Smart Parking',
          'Open Air Design'
        ],
        'icon': Icons.store,
        'color': Colors.purple,
      },
    ];

    final data = portfolioData[index % portfolioData.length];

    return Container(
      margin: const EdgeInsets.only(bottom: defaultPadding * 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Image/Icon
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              color: (data['color'] as Color).withOpacity(0.05),
            ),
            child: Stack(
              children: [
                // Background icon
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: Icon(
                      data['icon'] as IconData,
                      size: 60,
                      color: (data['color'] as Color).withOpacity(0.2),
                    ),
                  ),
                ),
                // Project info overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(defaultPadding),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(12),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: (data['color'] as Color),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                data['category'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              data['year'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data['title'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data['location'] as String,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                Text(
                  data['description'] as String,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: defaultPadding),

                // Features
                Text(
                  "Key Features",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                ),
                const SizedBox(height: defaultPadding / 2),
                Wrap(
                  spacing: defaultPadding / 2,
                  runSpacing: defaultPadding / 2,
                  children: (data['features'] as List<String>).map((feature) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: defaultPadding / 2,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: (data['color'] as Color).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: (data['color'] as Color).withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        feature,
                        style: TextStyle(
                          color: (data['color'] as Color),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: defaultPadding),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.visibility, size: 18),
                        label: const Text("View Details"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: defaultPadding / 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: defaultPadding / 2),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.share, size: 18),
                        label: const Text("Share"),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: defaultPadding / 2),
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
}
