import 'dart:async';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../../models/project_module_models.dart';

class CctvPlayerScreen extends StatefulWidget {
  final CctvCamera camera;
  const CctvPlayerScreen({super.key, required this.camera});

  @override
  State<CctvPlayerScreen> createState() => _CctvPlayerScreenState();
}

class _CctvPlayerScreenState extends State<CctvPlayerScreen> {
  late final Player _player;
  late final VideoController _controller;
  bool _hasError = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _controller = VideoController(_player);
    _startStream();
  }

  Future<void> _startStream() async {
    setState(() { _hasError = false; _isLoading = true; });
    try {
      _player.stream.error.listen((error) {
        if (mounted) setState(() { _hasError = true; _isLoading = false; });
      });
      _player.stream.playing.listen((playing) {
        if (playing && mounted) setState(() => _isLoading = false);
      });

      await _player.open(Media(widget.camera.streamUrl!));

      // Timeout fallback — if still loading after 10s, show error
      Future.delayed(const Duration(seconds: 10), () {
        if (_isLoading && mounted) {
          setState(() { _hasError = true; _isLoading = false; });
        }
      });
    } catch (e) {
      if (mounted) setState(() { _hasError = true; _isLoading = false; });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.camera.cameraName),
        elevation: 0,
        actions: [
          if (widget.camera.resolution != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.camera.resolution!,
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Video player
          if (!_hasError)
            Center(child: Video(controller: _controller)),

          // Loading state
          if (_isLoading && !_hasError)
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text('Connecting to stream...', style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),

          // Error / fallback state
          if (_hasError && !_isLoading)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.camera.snapshotUrl != null && widget.camera.snapshotUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.camera.snapshotUrl!,
                        height: 250,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.videocam_off, size: 64, color: Colors.white54),
                      ),
                    )
                  else
                    const Icon(Icons.videocam_off, size: 64, color: Colors.white54),
                  const SizedBox(height: 16),
                  const Text('Live stream unavailable', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Protocol: ${widget.camera.streamProtocol ?? "Unknown"}',
                      style: const TextStyle(color: Colors.white38, fontSize: 13)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _startStream,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white24, foregroundColor: Colors.white),
                  ),
                ],
              ),
            ),

          // Camera info overlay
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
              child: Text(
                '${widget.camera.location ?? ""} ${widget.camera.provider != null ? "| ${widget.camera.provider}" : ""}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
