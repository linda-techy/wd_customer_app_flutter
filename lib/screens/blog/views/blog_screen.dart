import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../constants.dart';
import '../../../design_tokens/app_typography.dart';
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
             Image.network(
               "https://images.unsplash.com/photo-1503387762-592deb58ef4e?w=800",
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
                     child: const Text("INSIGHTS", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                   ).animate().slideX(begin: -0.2),
                   const SizedBox(height: 12),
                   const Text(
                     "Construction\nTrends & News",
                     style: TextStyle(
                       fontFamily: grandisExtendedFont,
                       fontSize: 32,
                       fontWeight: FontWeight.bold,
                       color: Colors.white,
                       height: 1.1,
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
        'title': 'Modern Construction Techniques for 2024',
        'category': 'Industry News',
        'date': 'March 15, 2024',
        'readTime': '5 min read',
        'description': 'Discover the latest construction methods and technologies that are revolutionizing the industry.',
        'image': 'https://images.unsplash.com/photo-1581094794329-cdac82aadbcc?w=800',
      },
      {
        'title': 'Sustainable Building Materials Guide',
        'category': 'Sustainability',
        'date': 'March 12, 2024',
        'readTime': '8 min read',
        'description': 'Learn about eco-friendly materials that are both durable and environmentally responsible.',
        'image': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800',
      },
      {
        'title': 'Project Management Best Practices',
        'category': 'Management',
        'date': 'March 10, 2024',
        'readTime': '6 min read',
        'description': 'Essential tips for managing construction projects efficiently and on budget.',
        'image': 'https://images.unsplash.com/photo-1507537297725-24a1c434b6b8?w=800',
      },
      {
        'title': 'Safety Protocols on Construction Sites',
        'category': 'Safety',
        'date': 'March 8, 2024',
        'readTime': '4 min read',
        'description': 'Comprehensive guide to maintaining safety standards in construction environments.',
        'image': 'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=800',
      },
      {
        'title': 'Cost-Effective Home Renovation Ideas',
        'category': 'Renovation',
        'date': 'March 5, 2024',
        'readTime': '7 min read',
        'description': 'Smart renovation strategies that add value without breaking the bank.',
        'image': 'https://images.unsplash.com/photo-1503387762-592deb58ef4e?w=800',
      },
      {
        'title': 'Commercial Building Design Trends',
        'category': 'Design',
        'date': 'March 3, 2024',
        'readTime': '9 min read',
        'description': 'Explore the latest trends in commercial architecture and interior design.',
        'image': 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800',
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
                  child: Image.network(
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
