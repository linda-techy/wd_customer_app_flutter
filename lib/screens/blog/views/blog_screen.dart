import 'package:flutter/material.dart';
import '../../../constants.dart';

class BlogScreen extends StatelessWidget {
  const BlogScreen({super.key});

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
                      "Construction Insights",
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Latest news, tips, and industry updates",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                    ),
                  ],
                ),
              ),
            ),

            // Blog Posts
            SliverPadding(
              padding: const EdgeInsets.all(defaultPadding * 1.5),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _buildBlogCard(context, index);
                  },
                  childCount: 6,
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

  Widget _buildBlogCard(BuildContext context, int index) {
    final blogData = [
      {
        'title': 'Modern Construction Techniques for 2024',
        'category': 'Industry News',
        'date': 'March 15, 2024',
        'readTime': '5 min read',
        'description':
            'Discover the latest construction methods and technologies that are revolutionizing the industry.',
        'icon': Icons.construction,
      },
      {
        'title': 'Sustainable Building Materials Guide',
        'category': 'Sustainability',
        'date': 'March 12, 2024',
        'readTime': '8 min read',
        'description':
            'Learn about eco-friendly materials that are both durable and environmentally responsible.',
        'icon': Icons.eco,
      },
      {
        'title': 'Project Management Best Practices',
        'category': 'Management',
        'date': 'March 10, 2024',
        'readTime': '6 min read',
        'description':
            'Essential tips for managing construction projects efficiently and on budget.',
        'icon': Icons.engineering,
      },
      {
        'title': 'Safety Protocols on Construction Sites',
        'category': 'Safety',
        'date': 'March 8, 2024',
        'readTime': '4 min read',
        'description':
            'Comprehensive guide to maintaining safety standards in construction environments.',
        'icon': Icons.security,
      },
      {
        'title': 'Cost-Effective Home Renovation Ideas',
        'category': 'Renovation',
        'date': 'March 5, 2024',
        'readTime': '7 min read',
        'description':
            'Smart renovation strategies that add value without breaking the bank.',
        'icon': Icons.home_repair_service,
      },
      {
        'title': 'Commercial Building Design Trends',
        'category': 'Design',
        'date': 'March 3, 2024',
        'readTime': '9 min read',
        'description':
            'Explore the latest trends in commercial architecture and interior design.',
        'icon': Icons.business,
      },
    ];

    final data = blogData[index % blogData.length];

    return Container(
      margin: const EdgeInsets.only(bottom: defaultPadding * 1.5),
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
          // Header with image placeholder
          Container(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              color: primaryColor.withOpacity(0.05),
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
                      color: primaryColor.withOpacity(0.2),
                    ),
                  ),
                ),
                // Category badge
                Positioned(
                  top: defaultPadding,
                  left: defaultPadding,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: defaultPadding,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(20),
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
                // Meta information
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      data['date'] as String,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: defaultPadding),
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      data['readTime'] as String,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: defaultPadding),

                // Title
                Text(
                  data['title'] as String,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  data['description'] as String,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                ),
                const SizedBox(height: defaultPadding),

                // Read more button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Read More",
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: primaryColor,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 20,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.share,
                          size: 20,
                          color: Colors.grey[400],
                        ),
                      ],
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
