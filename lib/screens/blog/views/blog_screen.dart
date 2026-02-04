import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../constants.dart';
import '../../../components/animations/fade_entry.dart';
import '../../../components/animations/hover_card.dart';
import '../../../components/animations/scale_button.dart';

class BlogScreen extends StatelessWidget {
  const BlogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverPadding(
            padding: const EdgeInsets.all(defaultPadding),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return FadeEntry(
                    delay: (100 + (index * 100)).ms,
                    child: _buildBlogCard(context, index),
                  );
                },
                childCount: 6,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
  
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 220,
      floating: false,
      pinned: true,
      backgroundColor: surfaceColor,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
           fit: StackFit.expand,
           children: [
             Image.asset(
               "assets/construction/hero_indian.png",
               fit: BoxFit.cover,
             ).animate().fadeIn(duration: 800.ms),
             Container(
               color: Colors.black.withOpacity(0.6),
             ),
             Positioned(
               bottom: 30,
               left: 20,
               right: 20,
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                     decoration: BoxDecoration(
                       color: primaryColor,
                       borderRadius: BorderRadius.circular(20),
                     ),
                     child: const Text("KERALA & INDIA", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                   ).animate().slideX(begin: -0.2),
                   const SizedBox(height: 12),
                   const Text(
                     "Construction Insights\nനിർമ്മാണ ട്രെൻഡ്സ് ആൻഡ് ടിപ്സ്",
                     style: TextStyle(
                       fontFamily: grandisExtendedFont,
                       fontSize: 28,
                       fontWeight: FontWeight.bold,
                       color: Colors.white,
                       height: 1.15,
                     ),
                   ).animate().fadeIn().slideY(begin: 0.1),
                 ],
               ),
             ),
           ],
        ),
      ),
    );
  }

  Widget _buildBlogCard(BuildContext context, int index) {
    final blogData = [
      {
        'title': 'Kerala-Style Home Design: Traditional Nalukettu to Modern',
        'category': 'Kerala Homes',
        'date': '15 മാർച് 2025',
        'readTime': '6 min read',
        'description': 'From nalukettu and sloping roofs to contemporary Kerala villas—design ideas and cost per sq ft that suit Kerala climate and culture.',
        'image': 'assets/construction/residential_indian.png',
        'isAsset': true,
      },
      {
        'title': 'Monsoon-Proofing Your Building in Kerala',
        'category': 'Kerala Tips',
        'date': '12 മാർച് 2025',
        'readTime': '5 min read',
        'description': 'Waterproofing, drainage, and material choices that stand up to heavy rains—essential for every builder and homeowner in Kerala.',
        'image': 'assets/construction/construction_site.jpg',
        'isAsset': true,
      },
      {
        'title': 'Construction Cost in Kerala & India 2025: Per Sq Ft Guide',
        'category': 'Cost & Budget',
        'date': '10 മാർച് 2025',
        'readTime': '8 min read',
        'description': 'Latest rates for residential and commercial construction across Kerala and major Indian cities. Plan your budget with real numbers.',
        'image': 'assets/construction/hero_indian.png',
        'isAsset': true,
      },
      {
        'title': 'RERA & Building Rules in Kerala: What You Must Know',
        'category': 'Regulations',
        'date': '8 മാർച് 2025',
        'readTime': '7 min read',
        'description': 'RERA registration, local body approvals, and Kerala building rules—stay compliant and avoid delays and penalties.',
        'image': 'assets/construction/commercial_indian.png',
        'isAsset': true,
      },
      {
        'title': 'Eco-Friendly Materials Popular in South India',
        'category': 'Sustainability',
        'date': '5 മാർച് 2025',
        'readTime': '6 min read',
        'description': 'Laterite, bamboo, recycled aggregates, and low-carbon options that work well in Kerala and Tamil Nadu climates.',
        'image': 'assets/construction/landscape_indian.png',
        'isAsset': true,
      },
      {
        'title': 'Commercial Construction Trends in Kerala',
        'category': 'Commercial',
        'date': '3 മാർച് 2025',
        'readTime': '5 min read',
        'description': 'Office spaces, retail, and mixed-use projects—trends and best practices for developers and investors in Kerala.',
        'image': 'assets/construction/commercial_project.jpg',
        'isAsset': true,
      },
    ];

    final data = blogData[index % blogData.length];

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
                  child: (data['isAsset'] == true)
                      ? Image.asset(
                          data['image'] as String,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          data['image'] as String,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      data['category'] as String,
                      style: const TextStyle(
                        color: blackColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
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
                  Row(
                    children: [
                      Text(
                        data['date'] as String,
                        style: const TextStyle(color: blackColor40, fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      const CircleAvatar(radius: 2, backgroundColor: blackColor40),
                      const SizedBox(width: 8),
                      Text(
                        data['readTime'] as String,
                        style: const TextStyle(color: blackColor40, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    data['title'] as String,
                    style: const TextStyle(
                      fontFamily: grandisExtendedFont,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: blackColor,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data['description'] as String,
                    style: const TextStyle(
                      color: blackColor60,
                      height: 1.5,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ScaleButton(
                    onTap: () {},
                    child: Row(
                      children: [
                        const Text(
                          "Read Article",
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 16, color: primaryColor),
                      ],
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
