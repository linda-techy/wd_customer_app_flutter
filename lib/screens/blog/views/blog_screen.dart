import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../constants.dart';
import '../../../components/animations/fade_entry.dart';
import '../../../components/animations/hover_card.dart';
import '../../../components/animations/scale_button.dart';
import '../../../services/content_service.dart';
import '../../../models/content_models.dart';

class BlogScreen extends StatefulWidget {
  const BlogScreen({super.key});

  @override
  State<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> {
  List<BlogPost> _blogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBlogs();
  }

  Future<void> _loadBlogs() async {
    setState(() => _isLoading = true);
    try {
      final result = await ContentService.getBlogs();
      if (mounted) {
        setState(() {
          _blogs = (result['content'] as List<BlogPost>?) ?? [];
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: primaryColor)),
            )
          else if (_blogs.isEmpty)
            const SliverFillRemaining(
              child: Center(child: Text('No blog posts yet')),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(defaultPadding),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return FadeEntry(
                      delay: (100 + (index * 100)).ms,
                      child: _buildBlogCard(context, _blogs[index]),
                    );
                  },
                  childCount: _blogs.length,
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
                    child: const Text(
                      "KERALA & INDIA",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
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

  Widget _buildBlogCard(BuildContext context, BlogPost blog) {
    return HoverCard(
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, 'blog_details/${blog.slug}'),
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
              if (blog.imageUrl != null && blog.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: CachedNetworkImage(
                    imageUrl: blog.imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, size: 48),
                    ),
                  ),
                )
              else
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Container(
                    height: 120,
                    color: primaryColor.withOpacity(0.1),
                    child: const Center(child: Icon(Icons.article_outlined, size: 48, color: primaryColor)),
                  ),
                ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (blog.author.isNotEmpty) ...[
                          Text(
                            blog.author,
                            style: const TextStyle(color: blackColor40, fontSize: 12),
                          ),
                          const SizedBox(width: 8),
                          const CircleAvatar(radius: 2, backgroundColor: blackColor40),
                          const SizedBox(width: 8),
                        ],
                        if (blog.publishedAt != null)
                          Text(
                            blog.publishedAt!.split('T').first,
                            style: const TextStyle(color: blackColor40, fontSize: 12),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      blog.title,
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
                      blog.excerpt,
                      style: const TextStyle(
                        color: blackColor60,
                        height: 1.5,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ScaleButton(
                      onTap: () => Navigator.pushNamed(context, 'blog_details/${blog.slug}'),
                      child: const Row(
                        children: [
                          Text(
                            "Read Article",
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 16, color: primaryColor),
                        ],
                      ),
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
}
