import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../constants.dart';
import '../../../services/content_service.dart';
import '../../../models/content_models.dart';

class BlogDetailScreen extends StatefulWidget {
  final String slug;
  const BlogDetailScreen({super.key, required this.slug});

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  BlogPost? _blog;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBlog();
  }

  Future<void> _loadBlog() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final blog = await ContentService.getBlogBySlug(widget.slug);
      if (mounted) {
        setState(() {
          _blog = blog;
          _isLoading = false;
          if (blog == null) _errorMessage = 'Blog post not found';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _errorMessage = 'Failed to load blog'; _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(title: Text(_blog?.title ?? 'Blog'), backgroundColor: Colors.transparent, elevation: 0),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_blog!.imageUrl != null && _blog!.imageUrl!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CachedNetworkImage(
                            imageUrl: _blog!.imageUrl!,
                            width: double.infinity,
                            height: 220,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              height: 220,
                              color: Colors.grey[200],
                              child: const Center(child: CircularProgressIndicator()),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              height: 220,
                              color: Colors.grey[200],
                              child: const Icon(Icons.image_not_supported, size: 48),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        _blog!.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(children: [
                        if (_blog!.author.isNotEmpty) ...[
                          const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(_blog!.author, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          const SizedBox(width: 16),
                        ],
                        if (_blog!.publishedAt != null) ...[
                          const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(_blog!.publishedAt!.split('T').first, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ]),
                      const Divider(height: 32),
                      if (_blog!.content != null)
                        SelectableText(_blog!.content!, style: const TextStyle(fontSize: 15, height: 1.7)),
                    ],
                  ),
                ),
    );
  }
}
