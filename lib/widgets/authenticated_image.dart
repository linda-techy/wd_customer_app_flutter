import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

/// Loads an image from an authenticated API endpoint.
///
/// Flutter web's `Image.network(headers: ...)` is rendered as an HTML `<img>`
/// tag and cannot send custom HTTP headers. This widget fetches the bytes
/// via Dio (XHR) with the bearer token attached, then displays them with
/// `Image.memory` — works on web, mobile, and desktop.
class AuthenticatedImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AuthenticatedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<AuthenticatedImage> createState() => _AuthenticatedImageState();

  /// Fetch raw bytes — useful for widgets like PhotoView that need an
  /// `ImageProvider` (wrap the result in `MemoryImage`).
  static Future<Uint8List> fetchBytes(String url) async {
    if (_cache.containsKey(url)) return _cache[url]!;
    final token = await AuthService.getAccessToken();
    final response = await Dio().get<List<int>>(
      url,
      options: Options(
        responseType: ResponseType.bytes,
        headers: {
          'Accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ),
    );
    final bytes = Uint8List.fromList(response.data ?? const <int>[]);
    _cache[url] = bytes;
    return bytes;
  }

  /// Clear the in-memory image cache (e.g. on logout).
  static void clearCache() => _cache.clear();
}

final Map<String, Uint8List> _cache = {};

class _AuthenticatedImageState extends State<AuthenticatedImage> {
  Uint8List? _bytes;
  bool _loading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(AuthenticatedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    setState(() {
      _loading = true;
      _hasError = false;
    });
    try {
      final bytes = await AuthenticatedImage.fetchBytes(widget.imageUrl);
      if (mounted) {
        setState(() {
          _bytes = bytes;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('AuthenticatedImage: failed to load ${widget.imageUrl} — $e');
      if (mounted) {
        setState(() {
          _loading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (_loading) {
      child = widget.placeholder ??
          Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey[200],
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
    } else if (_hasError || _bytes == null) {
      child = widget.errorWidget ??
          Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey[200],
            child: Icon(Icons.broken_image, color: Colors.grey[400], size: 24),
          );
    } else {
      child = Image.memory(
        _bytes!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (_, __, ___) =>
            widget.errorWidget ??
            Container(
              width: widget.width,
              height: widget.height,
              color: Colors.grey[200],
              child:
                  Icon(Icons.broken_image, color: Colors.grey[400], size: 24),
            ),
      );
    }
    if (widget.borderRadius != null) {
      return ClipRRect(borderRadius: widget.borderRadius!, child: child);
    }
    return child;
  }
}
