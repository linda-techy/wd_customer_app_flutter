import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../constants.dart';
import '../../../services/auth_service.dart';
import '../../../services/project_module_service.dart';
import '../../../models/project_module_models.dart';
import '../../../config/api_config.dart';
import 'universal_file_viewer_screen.dart';

class GalleryScreen extends StatefulWidget {
  final String projectId;

  const GalleryScreen({super.key, required this.projectId});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  bool isLoading = true;
  String? error;
  List<GalleryImage> images = [];
  ProjectModuleService? service;
  String? _authToken;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final token = await AuthService.getAccessToken();
    if (token != null) {
      service = ProjectModuleService(
        baseUrl: ApiConfig.baseUrl,
        token: token,
      );
      setState(() {
        _authToken = token;
      });
      _loadImages();
    } else {
      setState(() {
        error = 'Not authenticated';
        isLoading = false;
      });
    }
  }

  Future<void> _loadImages() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final loadedImages = await service!.getGalleryImages(widget.projectId);
      
      // Sort by date taken (newest first)
      loadedImages.sort((a, b) => b.takenDate.compareTo(a.takenDate));

      setState(() {
        images = loadedImages;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load images: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: blackColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Project Gallery", 
          style: TextStyle(color: blackColor, fontWeight: FontWeight.bold)
        ),
        backgroundColor: surfaceColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: blackColor),
            onPressed: _loadImages,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : error != null
              ? _buildErrorState()
              : _buildGalleryGrid(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: errorColor),
          const SizedBox(height: 16),
          Text(error!, style: const TextStyle(color: errorColor)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadImages,
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryGrid() {
    if (images.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.photo_library_outlined, size: 48, color: primaryColor),
            ),
            const SizedBox(height: 16),
            const Text('No images found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text(
              'Photos uploaded by the team will appear here.',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsible grid count
        int crossAxisCount = 2; // Mobile default
        if (constraints.maxWidth > 600) crossAxisCount = 3;
        if (constraints.maxWidth > 900) crossAxisCount = 4;
        if (constraints.maxWidth > 1200) crossAxisCount = 5;

        return RefreshIndicator(
          onRefresh: _loadImages,
          color: primaryColor,
          child: GridView.builder(
            padding: const EdgeInsets.all(defaultPadding),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 1.0,
              crossAxisSpacing: defaultPadding,
              mainAxisSpacing: defaultPadding,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) {
              return _buildImageCard(context, index);
            },
          ),
        );
      },
    );
  }

  Widget _buildImageCard(BuildContext context, int index) {
    final image = images[index];
    final imageUrl = _resolveUrl(image.thumbnailPath?.isNotEmpty == true ? image.thumbnailPath! : image.imagePath);

    return GestureDetector(
      onTap: () => _openImageViewer(index),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'gallery_image_${image.id}',
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                httpHeaders: _authToken != null ? {'Authorization': 'Bearer $_authToken'} : null,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.image, color: Colors.grey)),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                ),
              ),
            ),
            // Gradient Overlay
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 50,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),
            ),
            // Date Overlay
            Positioned(
              left: 8,
              bottom: 8,
              child: Text(
                DateFormat('MMM d, y').format(image.takenDate),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms, delay: (index * 50).ms).scale(begin: const Offset(0.9, 0.9)),
    );
  }

  String _resolveUrl(String url) {
    if (url.startsWith('http')) return url;
    final baseUrl = ApiConfig.baseUrl;
    // Remove trailing slash from base if present
    final cleanBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    // Ensure leading slash on url
    final cleanUrl = url.startsWith('/') ? url : '/$url';
    return '$cleanBase$cleanUrl';
  }

  void _openImageViewer(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageViewerScreen(
          images: images,
          initialIndex: initialIndex,
          authToken: _authToken,
        ),
      ),
    );
  }
}

class ImageViewerScreen extends StatefulWidget {
  final List<GalleryImage> images;
  final int initialIndex;
  final String? authToken;

  const ImageViewerScreen({
    super.key,
    required this.images,
    required this.initialIndex,
    this.authToken,
  });

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "${_currentIndex + 1} of ${widget.images.length}",
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              final image = widget.images[_currentIndex];
              _downloadImage(image);
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showImageDetails(widget.images[_currentIndex]),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final image = widget.images[index];
          final imageUrl = _resolveUrl(image.imagePath);

          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: Hero(
                tag: 'gallery_image_${image.id}',
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  httpHeaders: widget.authToken != null 
                    ? {'Authorization': 'Bearer ${widget.authToken}'} 
                    : null,
                  placeholder: (context, url) => const CircularProgressIndicator(color: Colors.white),
                  errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.white, size: 64),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        },
      ),
      bottomSheet: _buildBottomCaption(),
    );
  }

  Widget? _buildBottomCaption() {
    final image = widget.images[_currentIndex];
    if ((image.caption == null || image.caption!.isEmpty) && 
        (image.locationTag == null || image.locationTag!.isEmpty)) {
      return null;
    }

    return Container(
      color: Colors.black.withOpacity(0.7),
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (image.caption != null && image.caption!.isNotEmpty)
            Text(
              image.caption!,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          if (image.locationTag != null && image.locationTag!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white70, size: 14),
                const SizedBox(width: 4),
                Text(
                  image.locationTag!,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showImageDetails(GalleryImage image) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Image Details', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _detailRow('Date Taken', DateFormat('MMMM d, y h:mm a').format(image.takenDate)),
            _detailRow('Uploaded By', image.uploadedByName),
            _detailRow('Uploaded On', DateFormat('MMM d, y').format(image.uploadedAt)),
            if (image.tags != null && image.tags!.isNotEmpty)
              _detailRow('Tags', image.tags!.join(', ')),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
  
  void _downloadImage(GalleryImage image) {
    // Reuse the UniversalFileViewerScreen mechanism effectively by pushing it for a split second 
    // or replicating the logic. Since I don't want to duplicate logic, 
    // I can navigate to UniversalFileViewerScreen passing the image URL, 
    // which handles download. But that's a "viewer". 
    //
    // Better: Direct navigation to UniversalFileViewerScreen with auto-download might be annoying.
    //
    // Simplest approach: Just open UniversalFileViewerScreen with the single image.
    // It has a download button.
     Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UniversalFileViewerScreen(
          fileUrl: _resolveUrl(image.imagePath),
          filename: 'image_${image.id}.jpg', // Fallback name
          fileType: 'image/jpeg',
        ),
      ),
    );
  }

  String _resolveUrl(String url) {
    if (url.startsWith('http')) return url;
    final baseUrl = ApiConfig.baseUrl;
    final cleanBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final cleanUrl = url.startsWith('/') ? url : '/$url';
    return '$cleanBase$cleanUrl';
  }
}
