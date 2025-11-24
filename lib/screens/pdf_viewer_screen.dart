import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart' show XFile, Share;
import '../services/auth_service.dart';

/// PDF Viewer Screen with download and share functionality
class PdfViewerScreen extends StatefulWidget {
  final String documentUrl;
  final String documentName;
  final String? authToken;

  const PdfViewerScreen({
    super.key,
    required this.documentUrl,
    required this.documentName,
    this.authToken,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  bool isDownloading = false;
  double downloadProgress = 0.0;
  bool _isTokenLoading = true;
  String? _resolvedToken;

  @override
  void initState() {
    super.initState();
    _loadAuthToken();
  }

  Future<void> _loadAuthToken() async {
    try {
      final token =
          widget.authToken ?? await AuthService.getAccessToken();
      setState(() {
        _resolvedToken = token;
        _isTokenLoading = false;
      });
    } catch (e) {
      debugPrint('Failed to load auth token for PDF viewer: $e');
      setState(() {
        _resolvedToken = widget.authToken;
        _isTokenLoading = false;
      });
    }
  }

  Future<String?> _ensureAuthToken() async {
    if (!_isTokenLoading && _resolvedToken != null) {
      return _resolvedToken;
    }
    if (_isTokenLoading) {
      await _loadAuthToken();
      return _resolvedToken;
    }
    final token = widget.authToken ?? await AuthService.getAccessToken();
    setState(() {
      _resolvedToken = token;
    });
    return token;
  }

  @override
  Widget build(BuildContext context) {
    if (_isTokenLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.documentName,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Zoom controls
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () {
              _pdfViewerController.zoomLevel += 0.25;
            },
            tooltip: 'Zoom In',
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () {
              if (_pdfViewerController.zoomLevel > 1) {
                _pdfViewerController.zoomLevel -= 0.25;
              }
            },
            tooltip: 'Zoom Out',
          ),
          // Download button
          IconButton(
            icon: isDownloading 
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      value: downloadProgress,
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.download),
            onPressed: isDownloading ? null : _downloadFile,
            tooltip: 'Download PDF',
          ),
          // Share button
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'share') {
                _shareFile();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Share'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          // PDF Viewer with network support
          SfPdfViewer.network(
            widget.documentUrl,
            controller: _pdfViewerController,
            headers: _resolvedToken != null
                ? {'Authorization': 'Bearer $_resolvedToken'}
                : null,
            canShowScrollHead: true,
            canShowScrollStatus: true,
            canShowPaginationDialog: true,
            onDocumentLoadFailed: (details) {
              _showErrorDialog('Failed to load PDF: ${details.description}');
            },
          ),
          
          // Page indicator
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(20),
              ),
              child: PdfPageNumber(controller: _pdfViewerController),
            ),
          ),
        ],
      ),
    );
  }

  /// Download file to local storage
  Future<void> _downloadFile() async {
    setState(() {
      isDownloading = true;
      downloadProgress = 0.0;
    });

    try {
      final token = await _ensureAuthToken();

      // Get downloads directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final filePath = '${directory?.path}/${widget.documentName}';
      
      // Download with progress
      final dio = Dio();
      if (token != null) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }

      await dio.download(
        widget.documentUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              downloadProgress = received / total;
            });
          }
        },
      );

      setState(() {
        isDownloading = false;
        downloadProgress = 0.0;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloaded to: $filePath'),
            action: SnackBarAction(
              label: 'Open Folder',
              onPressed: () {
                // Open file manager (platform-specific)
              },
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isDownloading = false;
        downloadProgress = 0.0;
      });
      if (mounted) {
        _showErrorDialog('Download failed: $e');
      }
    }
  }

  /// Share file
  Future<void> _shareFile() async {
    try {
      final token = await _ensureAuthToken();

      // Download to temp directory first
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/${widget.documentName}';
      
      final dio = Dio();
      if (token != null) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }

      await dio.download(widget.documentUrl, filePath);

      // Share the file
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Check out this document: ${widget.documentName}',
      );
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Share failed: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }
}

/// Widget to show current page number
class PdfPageNumber extends StatefulWidget {
  final PdfViewerController controller;

  const PdfPageNumber({super.key, required this.controller});

  @override
  State<PdfPageNumber> createState() => _PdfPageNumberState();
}

class _PdfPageNumberState extends State<PdfPageNumber> {
  int currentPage = 1;
  int totalPages = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updatePageInfo);
  }

  void _updatePageInfo() {
    setState(() {
      currentPage = widget.controller.pageNumber;
      totalPages = widget.controller.pageCount;
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updatePageInfo);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      totalPages > 0 ? '$currentPage / $totalPages' : 'Loading...',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}


