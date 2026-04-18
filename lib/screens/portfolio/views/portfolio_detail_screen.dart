import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../constants.dart';
import '../../../services/content_service.dart';
import '../../../models/content_models.dart';

class PortfolioDetailScreen extends StatefulWidget {
  final String slug;
  const PortfolioDetailScreen({super.key, required this.slug});
  @override
  State<PortfolioDetailScreen> createState() => _PortfolioDetailScreenState();
}

class _PortfolioDetailScreenState extends State<PortfolioDetailScreen> {
  PortfolioItem? _item;
  bool _isLoading = true;
  String? _errorMessage;
  int _currentImageIndex = 0;

  @override
  void initState() { super.initState(); _loadItem(); }

  Future<void> _loadItem() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final item = await ContentService.getPortfolioBySlug(widget.slug);
      if (mounted) setState(() { _item = item; _isLoading = false; if (item == null) _errorMessage = 'Portfolio item not found'; });
    } catch (e) {
      if (mounted) setState(() { _errorMessage = 'Failed to load'; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(title: Text(_item?.title ?? 'Portfolio'), backgroundColor: Colors.transparent, elevation: 0),
      body: _isLoading ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : _errorMessage != null ? Center(child: Text(_errorMessage!))
          : SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (_item!.imageUrls.isNotEmpty)
                SizedBox(height: 280, child: PageView.builder(
                  itemCount: _item!.imageUrls.length,
                  onPageChanged: (i) => setState(() => _currentImageIndex = i),
                  itemBuilder: (context, index) => CachedNetworkImage(
                    imageUrl: _item!.imageUrls[index],
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: Colors.grey[200]),
                    errorWidget: (_, __, ___) => Container(color: Colors.grey[200], child: const Icon(Icons.image_not_supported, size: 48)),
                  ),
                ))
              else if (_item!.coverImageUrl != null)
                CachedNetworkImage(imageUrl: _item!.coverImageUrl!, width: double.infinity, height: 280, fit: BoxFit.cover),
              if (_item!.imageUrls.length > 1)
                Padding(padding: const EdgeInsets.only(top: 8), child: Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_item!.imageUrls.length, (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentImageIndex == i ? 10 : 6,
                    height: _currentImageIndex == i ? 10 : 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == i ? primaryColor : Colors.grey[400],
                    ),
                  )))),
              Padding(padding: const EdgeInsets.all(defaultPadding), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_item!.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  if (_item!.projectType != null) Chip(label: Text(_item!.projectType!), backgroundColor: primaryColor.withOpacity(0.1)),
                  if (_item!.location != null) Chip(avatar: const Icon(Icons.location_on, size: 16), label: Text(_item!.location!)),
                  if (_item!.areaSqft != null) Chip(label: Text('${_item!.areaSqft} sq ft')),
                  if (_item!.completionDate != null) Chip(avatar: const Icon(Icons.calendar_today, size: 16), label: Text(_item!.completionDate!)),
                ]),
                if (_item!.description != null) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(_item!.description!, style: const TextStyle(fontSize: 15, height: 1.7)),
                ],
              ])),
            ])),
    );
  }
}
