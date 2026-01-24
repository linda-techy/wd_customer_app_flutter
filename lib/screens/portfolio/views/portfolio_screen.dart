import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../constants.dart';
import '../../../design_tokens/app_colors.dart';
import '../../../design_tokens/app_typography.dart';
import '../../../components/animations/fade_entry.dart';
import '../../../components/animations/hover_card.dart';
import '../../../components/animations/scale_button.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.all(defaultPadding),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return FadeEntry(
                    delay: (100 + (index * 100)).ms,
                    child: _buildPortfolioItem(context, index),
                  );
                },
                childCount: 4,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: surfaceColor,
      elevation: 0,
       flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryColor, primaryColor.withOpacity(0.8)],
                ),
              ),
            ),
            // Decorative circles
            Positioned(
              right: -50,
              top: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
             Positioned(
              left: 20,
              bottom: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                     decoration: BoxDecoration(
                       color: Colors.white.withOpacity(0.2),
                       borderRadius: BorderRadius.circular(20),
                     ),
                     child: const Row(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         Icon(Icons.star, color: Colors.amber, size: 14),
                         SizedBox(width: 4),
                         Text(
                           "Featured Projects",
                           style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                         ),
                       ],
                     ),
                   ).animate().slideX(begin: -0.2),
                   const SizedBox(height: 12),
                  const Text(
                    "Our Portfolio",
                    style: TextStyle(
                      fontFamily: grandisExtendedFont,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ).animate().fadeIn().slideY(begin: 0.1),
                   const SizedBox(height: 4),
                    Text(
                    "Award-winning construction excellence",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                ],
              ),
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
            'A 25-story modern office complex featuring sustainable design, smart building technology, and premium amenities.',
        'features': ['25 Stories', 'LEED Certified', 'Smart Building'],
        'icon': Icons.business,
        'color': Colors.blue,
        'image': 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800',
      },
      {
        'title': 'Luxury Residential Complex',
        'category': 'Residential',
        'location': 'Exclusive Suburban Area',
        'year': '2023',
        'description':
            'Premium residential development with 50 luxury apartments, featuring high-end finishes and private balconies.',
        'features': ['50 Units', 'Luxury Finishes', 'Swimming Pool'],
        'icon': Icons.apartment,
        'color': Colors.green,
        'image': 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800',
      },
      {
        'title': 'Industrial Manufacturing',
        'category': 'Industrial',
        'location': 'Industrial Technology Park',
        'year': '2022',
        'description':
            'State-of-the-art manufacturing facility designed for efficiency and sustainability.',
        'features': ['100k sq ft', 'Automated', 'Green Certified'],
        'icon': Icons.factory,
        'color': Colors.orange,
        'image': 'https://images.unsplash.com/photo-1565008447742-97f6f38c985c?w=800',
      },
      {
        'title': 'Modern Shopping Center',
        'category': 'Commercial',
        'location': 'City Center',
        'year': '2022',
        'description':
            'Contemporary shopping center with 100+ retail spaces, entertainment venues, and dining options.',
        'features': ['100+ Stores', 'Entertainment', 'Open Air'],
        'icon': Icons.store,
        'color': Colors.purple,
        'image': 'https://images.unsplash.com/photo-1519567241046-7f570eee3d9f?w=800',
      },
    ];

    final data = portfolioData[index % portfolioData.length];
    final color = data['color'] as Color;

    return HoverCard(
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: blackColor.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Header
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    data['image'] as String,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      height: 200,
                      color: color.withOpacity(0.1),
                      child: Center(child: Icon(data['icon'] as IconData, size: 50, color: color)),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      data['year'] as String,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
                 Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      data['category'] as String,
                      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
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
                    data['title'] as String,
                    style: const TextStyle(
                      fontFamily: grandisExtendedFont,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: blackColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: blackColor40),
                      const SizedBox(width: 4),
                      Text(
                        data['location'] as String,
                        style: const TextStyle(color: blackColor60, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    data['description'] as String,
                    style: const TextStyle(color: blackColor80, height: 1.5, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (data['features'] as List<String>).map((feature) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: blackColor5,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          feature,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: blackColor60),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                   ScaleButton(
                    onTap: () {},
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: blackColor10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          "View Project Details",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primaryColor),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
