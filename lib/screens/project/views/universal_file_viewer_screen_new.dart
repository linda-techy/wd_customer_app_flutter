import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import '../../../services/file_viewer_service.dart';
import '../../../services/auth_service.dart';
import '../../../config/api_config.dart';
import '../../../constants.dart';

// Conditional imports for platform-specific functionality
import '../../../utils/file_operations_stub.dart'
    if (dart.library.io) '../../../utils/file_operations_mobile.dart'
    if (dart.library.html) '../../../utils/file_operations_web.dart';

/// Universal file viewer that works on Web, Android, and iOS
/// Handles authentication for all file types
class UniversalFileViewerScreen extends StatefulWidget {
  const UniversalFileViewerScreen({
    super.key,
    required this.fileUrl,
    required this.filename,
    this.fileType,
  });

  final String fileUrl;
  final String filename;
  final String? fileType;

  @override
  State<UniversalFileViewerScreen> createState() =>
      _UniversalFileViewerScreenState();
}

class _UniversalFileViewerScreenState extends State<UniversalFileViewerScreen> {
  bool _isLoading = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String? _error;
  FileType? _detectedFileType;
  Uint8List? _fileBytes; // For web and in-memory viewing
  String? _localFilePath; // For mobile file system
  late String _resolvedFileUrl;

  @override
  void initState() {
    super.initState();
    _detectFileType();
    _resolvedFileUrl = _resolveFileUrl(widget.fileUrl);
  }

  void _detectFileType() {
    setState(() {
      _detectedFileType = FileViewerService.detectFileType(
        widget.filename,
        mimeType: widget.fileType,
      );
    });
  }

  String _resolveFileUrl(String url) {
    if (url.isEmpty) return url;
    try {
      final baseUri = Uri.parse(ApiConfig.baseUrl);
      final uri = Uri.parse(url);

      if (uri.hasScheme) {
        if (_isLoopbackHost(uri.host) && baseUri.host.isNotEmpty) {
          return uri
              .replace(
                scheme: baseUri.scheme,
                host: baseUri.host,
                port: baseUri.hasPort ? baseUri.port : null,
              )
              .toString();
        }
        return uri.toString();
      }

      return baseUri.resolveUri(uri).toString();
    } catch (e) {
      print('Failed to resolve file URL $url: $e');
      return url;
    }
  }

  bool _isLoopbackHost(String host) {
    final normalized = host.toLowerCase();
    return normalized == 'localhost' ||
        normalized == '127.0.0.1' ||
        normalized == '0.0.0.0';
  }

  Future<String?> _getAuthToken() async {
    try {
      return await AuthService.getAccessToken();
    } catch (e) {
      setState(() {
        _error = 'Authentication error: $e';
      });
      return null;
    }
  }

  Future<void> _loadFileForViewing() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _downloadProgress = 0.0;
    });

    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('No authentication token available');
      }

      final dio = Dio();
      final response = await dio.get(
        _resolvedFileUrl,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Authorization': 'Bearer $token'},
        ),
        onReceiveProgress: (received, total) {
          if (total != -1 && mounted) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      final bytes = Uint8List.fromList(response.data);

      if (kIsWeb) {
        // On web, keep in memory
        setState(() {
          _fileBytes = bytes;
          _isLoading = false;
        });
      } else {
        // On mobile, save to file system
        final filePath = await saveFileToDevice(bytes, widget.filename);
        setState(() {
          _localFilePath = filePath;
          _fileBytes = bytes; // Also keep in memory as fallback
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load file: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadFile() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _error = null;
    });

    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('No authentication token available');
      }

      final dio = Dio();
      final response = await dio.get(
        _resolvedFileUrl,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Authorization': 'Bearer $token'},
        ),
        onReceiveProgress: (received, total) {
          if (total != -1 && mounted) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      final bytes = Uint8List.fromList(response.data);
      await downloadFileToDevice(bytes, widget.filename);

      setState(() {
        _isDownloading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File downloaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _error = 'Download failed: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareFile() async {
    if (_fileBytes == null && _localFilePath == null) {
      await _loadFileForViewing();
    }

    if (_localFilePath != null) {
      await shareFile(_localFilePath!, widget.filename);
    } else if (_fileBytes != null) {
      // For web or if file path not available, save first then share
      final path = await saveFileToDevice(_fileBytes!, widget.filename);
      await shareFile(path, widget.filename);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.filename,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (!kIsWeb && _detectedFileType != null)
            IconButton(
              icon: const Icon(Icons.open_in_new),
              tooltip: 'Open with external app',
              onPressed: () async {
                if (_localFilePath != null) {
                  await openWithExternalApp(_localFilePath!);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please wait for file to load first'),
                    ),
                  );
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Download',
            onPressed: _downloadFile,
          ),
          if (!kIsWeb)
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Share',
              onPressed: _shareFile,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading || _isDownloading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(value: _downloadProgress),
            const SizedBox(height: 16),
            Text(
              _isLoading
                  ? 'Loading... ${(_downloadProgress * 100).toStringAsFixed(0)}%'
                  : 'Downloading... ${(_downloadProgress * 100).toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _error = null;
                  });
                  _loadFileForViewing();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_detectedFileType == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // If file not loaded yet, load it
    if (_fileBytes == null && _localFilePath == null) {
      _loadFileForViewing();
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Preparing file...'),
          ],
        ),
      );
    }

    switch (_detectedFileType!) {
      case FileType.pdf:
        return _buildPdfViewer();
      case FileType.image:
        return _buildImageViewer();
      case FileType.text:
        return _buildTextViewer();
      case FileType.word:
      case FileType.excel:
      case FileType.powerpoint:
        return _buildOfficeDocumentViewer();
      default:
        return _buildUnsupportedFileView();
    }
  }

  Widget _buildPdfViewer() {
    if (_fileBytes != null) {
      return SfPdfViewer.memory(
        _fileBytes!,
        onDocumentLoadFailed: (details) {
          setState(() {
            _error = 'Failed to load PDF: ${details.error}';
          });
        },
      );
    }

    return const Center(
      child: Text('Unable to load PDF'),
    );
  }

  Widget _buildImageViewer() {
    if (_fileBytes != null) {
      return InteractiveViewer(
        child: Center(
          child: Image.memory(
            _fileBytes!,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Failed to load image: $error'),
                ],
              );
            },
          ),
        ),
      );
    }

    // Fallback to network image with auth headers
    return FutureBuilder<String?>(
      future: _getAuthToken(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return InteractiveViewer(
          child: Center(
            child: CachedNetworkImage(
              imageUrl: _resolvedFileUrl,
              httpHeaders: {'Authorization': 'Bearer ${snapshot.data}'},
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Failed to load image: $error'),
                  ],
                );
              },
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextViewer() {
    if (_fileBytes != null) {
      final text = String.fromCharCodes(_fileBytes!);
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SelectableText(
          text,
          style: const TextStyle(fontFamily: 'monospace'),
        ),
      );
    }

    return const Center(child: Text('Unable to load text file'));
  }

  Widget _buildOfficeDocumentViewer() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getFileIcon(),
              size: 100,
              color: _getFileColor(),
            ),
            const SizedBox(height: 24),
            Text(
              widget.filename,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              kIsWeb
                  ? 'Office documents can be downloaded and opened locally.'
                  : 'This file will be opened with an external app.',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (kIsWeb)
              ElevatedButton.icon(
                onPressed: _downloadFile,
                icon: const Icon(Icons.download),
                label: const Text('Download File'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: () async {
                  if (_localFilePath != null) {
                    await openWithExternalApp(_localFilePath!);
                  } else {
                    await _loadFileForViewing();
                    if (_localFilePath != null) {
                      await openWithExternalApp(_localFilePath!);
                    }
                  }
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open with External App'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnsupportedFileView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insert_drive_file,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              widget.filename,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'This file type cannot be previewed.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _downloadFile,
              icon: const Icon(Icons.download),
              label: const Text('Download File'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon() {
    switch (_detectedFileType!) {
      case FileType.word:
        return Icons.description;
      case FileType.excel:
        return Icons.table_chart;
      case FileType.powerpoint:
        return Icons.slideshow;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor() {
    switch (_detectedFileType!) {
      case FileType.word:
        return Colors.blue;
      case FileType.excel:
        return Colors.green;
      case FileType.powerpoint:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
