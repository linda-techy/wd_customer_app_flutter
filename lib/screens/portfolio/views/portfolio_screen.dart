import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../constants.dart';
import '../../../components/animations/fade_entry.dart';
import '../../../components/animations/hover_card.dart';
import '../../../components/animations/scale_button.dart';
import '../../../services/content_service.dart';
import '../../../models/content_models.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  List<PortfolioItem> _portfolioItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPortfolio();
  }

  Future<void> _loadPortfolio() async {
    setState(() => _isLoading = true);
    try {
      final result = await ContentService.getPortfolio();
      if (mounted) {
        setState(() {
          _portfolioItems = (result['content'] as List<PortfolioItem>?) ?? [];
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
          _buildSliverAppBar(context),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: primaryColor)),
            )
          else if (_portfolioItems.isEmpty)
            const SliverFillRemaining(
              child: Center(child: Text('No portfolio items yet')),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(defaultPadding),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return FadeEntry(
                      delay: (100 + (index * 100)).ms,
                      child: _buildPortfolioItem(context, _portfolioItems[index]),
                    );
                  },
                  childCount: _portfolioItems.length,
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

  Widget _buildPortfolioItem(BuildContext context, PortfolioItem item) {
    return HoverCard(
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, 'portfolio_details/${item.slug}'),
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
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: _buildPortfolioImage(item),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontFamily: grandisExtendedFont,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: blackColor,
                      ),
                    ),
                    if (item.location != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: blackColor40),
                          const SizedBox(width: 4),
                          Text(
                            item.location!,
                            style: const TextStyle(color: blackColor60, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                    if (item.description != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        item.description!,
                        style: const TextStyle(color: blackColor80, height: 1.5, fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (item.projectType != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: blackColor5,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.projectType!,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: blackColor60),
                            ),
                          ),
                        if (item.completionDate != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: blackColor5,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.completionDate!,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: blackColor60),
                            ),
                          ),
                        if (item.areaSqft != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: blackColor5,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${item.areaSqft} sq ft',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: blackColor60),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ScaleButton(
                      onTap: () => Navigator.pushNamed(context, 'portfolio_details/${item.slug}'),
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
      ),
    );
  }

  Widget _buildPortfolioImage(PortfolioItem item) {
    final imageUrl = item.coverImageUrl ?? (item.imageUrls.isNotEmpty ? item.imageUrls.first : null);
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
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
      );
    }
    return Container(
      height: 120,
      color: primaryColor.withOpacity(0.1),
      child: const Center(child: Icon(Icons.business, size: 48, color: primaryColor)),
    );
  }
}
