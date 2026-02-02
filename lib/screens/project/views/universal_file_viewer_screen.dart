import 'dart:convert';
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

// Conditional imports for web HTML rendering
import '../../../utils/web_pdf_viewer_stub.dart'
    if (dart.library.html) '../../../utils/web_pdf_viewer.dart';

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
  String? _authToken;
  Future<String?>? _authTokenFuture;

  @override
  void initState() {
    super.initState();
    _detectFileType();
    _resolvedFileUrl = _resolveFileUrl(widget.fileUrl);
    _authTokenFuture = _loadAuthToken();
  }

  void _detectFileType() {
    setState(() {
      _detectedFileType = FileViewerService.detectFileType(
        widget.filename,
        mimeType: widget.fileType,
      );
    });
  }

  Future<String?> _loadAuthToken() async {
    try {
      final token = await AuthService.getAccessToken();
      setState(() {
        _authToken = token;
      });
      return token;
    } catch (e) {
      setState(() {
        _error = 'Authentication error: $e';
      });
      return null;
    }
  }

  Future<String?> _ensureAuthToken() async {
    if (_authToken != null) return _authToken;
    if (_authTokenFuture != null) {
      _authToken = await _authTokenFuture;
      return _authToken;
    }
    _authTokenFuture = _loadAuthToken();
    _authToken = await _authTokenFuture;
    return _authToken;
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

  Future<void> _loadFileForViewing() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _downloadProgress = 0.0;
    });

    try {
      final token = await _ensureAuthToken();
      if (token == null) {
        throw Exception('No authentication token available');
      }

      print('=== LOADING FILE ===');
      print('URL: $_resolvedFileUrl');
      print('Token: ${token.substring(0, 20)}...');
      print('Filename: ${widget.filename}');

      final dio = Dio();

      // Add timeout and better error handling
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 60);

      // Follow redirects
      dio.options.followRedirects = true;
      dio.options.maxRedirects = 5;

      final response = await dio.get(
        _resolvedFileUrl,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/pdf, application/octet-stream, */*',
          },
          validateStatus: (status) {
            print('Response status: $status');
            return status != null && status < 500;
          },
        ),
        onReceiveProgress: (received, total) {
          if (total != -1 && mounted) {
            setState(() {
              _downloadProgress = received / total;
            });
            print(
                'Download progress: ${(received / total * 100).toStringAsFixed(1)}%');
          }
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Content-Type: ${response.headers.value('content-type')}');
      print('Content-Length: ${response.headers.value('content-length')}');
      print('Response data type: ${response.data.runtimeType}');
      print('Response data length: ${response.data?.length ?? 0}');

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authentication failed. Please log in again.');
      }

      if (response.statusCode != 200) {
        // Try to read error message if it's text
        String errorMsg = 'Server returned status ${response.statusCode}';
        if (response.data != null) {
          try {
            final errorText = String.fromCharCodes(response.data);
            print('Error response body: $errorText');

            // Try to parse JSON error
            if (errorText.trim().startsWith('{')) {
              errorMsg = errorText;
            }
          } catch (e) {
            print('Could not decode error response');
          }
        }
        throw Exception(errorMsg);
      }

      if (response.data == null || response.data.isEmpty) {
        throw Exception('Received empty response from server');
      }

      // Convert to Uint8List
      Uint8List bytes;
      if (response.data is Uint8List) {
        bytes = response.data;
      } else if (response.data is List<int>) {
        bytes = Uint8List.fromList(response.data);
      } else {
        throw Exception(
            'Unexpected response data type: ${response.data.runtimeType}');
      }

      print('Converted to bytes: ${bytes.length}');

      // Verify file type by checking header
      if (bytes.length > 4) {
        final header = String.fromCharCodes(bytes.sublist(0, 4));
        print('File header: $header');

        // Also check first 20 bytes for debugging
        final first20 = bytes.length >= 20
            ? String.fromCharCodes(bytes.sublist(0, 20))
            : String.fromCharCodes(bytes);
        print('First 20 bytes: $first20');

        // Check if it's HTML error page
        if (header.toLowerCase().contains('<!do') ||
            header.toLowerCase().contains('<htm')) {
          print('ERROR: Received HTML instead of file!');
          final htmlContent = String.fromCharCodes(
              bytes.length > 1000 ? bytes.sublist(0, 1000) : bytes);
          print('HTML content preview: $htmlContent');
          throw Exception(
              'Server returned HTML error page instead of file. Check authentication and URL.');
        }

        // For PDFs, verify header
        if (_detectedFileType == FileType.pdf && header != '%PDF') {
          print('WARNING: File does not appear to be a valid PDF');
          print('Expected: %PDF, Got: $header');
          // Don't throw, let the PDF viewer handle it
        } else if (_detectedFileType == FileType.pdf) {
          print('✓ Valid PDF header detected');
        }
      } else {
        throw Exception('File too small to be valid: ${bytes.length} bytes');
      }

      if (kIsWeb) {
        // On web, keep in memory
        setState(() {
          _fileBytes = bytes;
          _isLoading = false;
        });
        print('✓ File loaded successfully (web): ${bytes.length} bytes');
      } else {
        // On mobile, save to file system
        final filePath = await saveFileToDevice(bytes, widget.filename);
        setState(() {
          _localFilePath = filePath;
          _fileBytes = bytes; // Also keep in memory as fallback
          _isLoading = false;
        });
        print('✓ File loaded successfully (mobile): $filePath');
      }
    } on DioException catch (e, stackTrace) {
      print('ERROR: DioException - ${e.type}');
      print('Message: ${e.message}');
      print('Response: ${e.response?.data}');
      print('Stack trace: $stackTrace');

      String errorMsg = 'Failed to load file';
      if (e.type == DioExceptionType.connectionTimeout) {
        errorMsg = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMsg = 'Download timeout. The file may be too large.';
      } else if (e.type == DioExceptionType.badResponse) {
        errorMsg = 'Server error: ${e.response?.statusCode}';
        if (e.response?.data != null) {
          try {
            final errorText = String.fromCharCodes(e.response!.data);
            errorMsg += '\n$errorText';
          } catch (_) {}
        }
      } else if (e.message != null) {
        errorMsg = e.message!;
      }

      setState(() {
        _error = errorMsg;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      print('ERROR loading file: $e');
      print('Stack trace: $stackTrace');
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
      // If we already have the bytes, just download them
      if (_fileBytes != null) {
        print(
            'Using cached file bytes for download: ${_fileBytes!.length} bytes');
        await downloadFileToDevice(_fileBytes!, widget.filename);

        setState(() {
          _isDownloading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File downloaded successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      final token = await _ensureAuthToken();
      if (token == null) {
        throw Exception('No authentication token available');
      }

      print('=== DOWNLOADING FILE ===');
      print('URL: $_resolvedFileUrl');

      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 60);
      dio.options.followRedirects = true;
      dio.options.maxRedirects = 5;

      final response = await dio.get(
        _resolvedFileUrl,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/pdf, application/octet-stream, */*',
          },
        ),
        onReceiveProgress: (received, total) {
          if (total != -1 && mounted) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned status ${response.statusCode}');
      }

      // Convert to Uint8List
      Uint8List bytes;
      if (response.data is Uint8List) {
        bytes = response.data;
      } else if (response.data is List<int>) {
        bytes = Uint8List.fromList(response.data);
      } else {
        throw Exception(
            'Unexpected response data type: ${response.data.runtimeType}');
      }

      print('Downloaded ${bytes.length} bytes');

      await downloadFileToDevice(bytes, widget.filename);

      // Cache the bytes for future use
      setState(() {
        _fileBytes = bytes;
        _isDownloading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File downloaded successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } on DioException catch (e, stackTrace) {
      print('ERROR: DioException - ${e.type}');
      print('Message: ${e.message}');
      print('Response: ${e.response?.data}');
      print('Stack trace: $stackTrace');

      String errorMsg = 'Download failed';
      if (e.type == DioExceptionType.connectionTimeout) {
        errorMsg = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMsg = 'Download timeout. The file may be too large.';
      } else if (e.type == DioExceptionType.badResponse) {
        errorMsg = 'Server error: ${e.response?.statusCode}';
      } else if (e.message != null) {
        errorMsg = e.message!;
      }

      setState(() {
        _isDownloading = false;
        _error = errorMsg;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('ERROR downloading file: $e');
      print('Stack trace: $stackTrace');

      setState(() {
        _isDownloading = false;
        _error = 'Download failed: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
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

    // PDFs stream directly; trigger background preload for download/sharing
    if (_detectedFileType == FileType.pdf) {
      if (_fileBytes == null && !_isLoading) {
        _loadFileForViewing();
      }
      return _buildPdfViewer();
    }

    // Other file types need bytes before viewing
    if (_fileBytes == null && _localFilePath == null) {
      if (!_isLoading) {
        _loadFileForViewing();
      }
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
      case FileType.csv:
        return _buildCsvViewer();
      case FileType.word:
      case FileType.excel:
      case FileType.powerpoint:
        return _buildOfficeDocumentViewer();
      default:
        return _buildUnsupportedFileView();
    }
  }

  Widget _buildPdfViewer() {
    // For PDFs, we MUST download the bytes first with authentication
    // SfPdfViewer.network doesn't handle auth headers reliably
    if (_fileBytes != null) {
      print('=== PDF VIEWER ===');
      print('Loading PDF from memory: ${_fileBytes!.length} bytes');

      // Debug: Check first few bytes
      if (_fileBytes!.length >= 10) {
        final preview = String.fromCharCodes(_fileBytes!.sublist(0, 10));
        print('PDF bytes preview: $preview');
      }

      // On web, use iframe to embed PDF (browser's native viewer)
      if (kIsWeb) {
        return _buildWebPdfViewer();
      }

      // On mobile, use Syncfusion PDF viewer
      return SfPdfViewer.memory(
        _fileBytes!,
        canShowScrollHead: true,
        canShowScrollStatus: true,
        enableDoubleTapZooming: true,
        onDocumentLoaded: (details) {
          print(
              '✓ PDF loaded successfully: ${details.document.pages.count} pages');
        },
        onDocumentLoadFailed: (details) {
          print('✗ PDF load failed: ${details.description}');
          print('Error details: ${details.error}');

          setState(() {
            _error = 'Failed to load PDF: ${details.description}\n\n'
                'This could be due to:\n'
                '• Corrupted PDF file\n'
                '• Invalid PDF format\n'
                '• Server returned wrong content\n\n'
                'File size: ${_fileBytes!.length} bytes\n'
                'Error: ${details.error}';
          });
        },
      );
    }

    // If bytes not loaded yet, show loading
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading PDF...'),
        ],
      ),
    );
  }

  Widget _buildWebPdfViewer() {
    // Create a blob URL from the PDF bytes and embed in iframe
    print('Building web PDF viewer with ${_fileBytes!.length} bytes');
    return buildWebPdfViewer(_fileBytes!, widget.filename);
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
      future: _ensureAuthToken(),
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
      final text = utf8.decode(_fileBytes!, allowMalformed: true);
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

  Widget _buildCsvViewer() {
    if (_fileBytes == null) {
      return const Center(child: Text('Unable to load CSV file'));
    }

    try {
      final content = utf8.decode(_fileBytes!, allowMalformed: true);
      
      // Simple CSV parser: separate lines, then split by comma
      // Note: This is a basic implementation. Complex CSVs (quoted values with newlines) 
      // might need a dedicated CSV package.
      final List<List<String>> rows = content
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) => line.split(',').map((e) => e.trim()).toList())
          .toList();

      if (rows.isEmpty) {
        return const Center(child: Text('CSV file is empty'));
      }

      // Assume first row is header if it exists
      final headers = rows.first;
      final dataRows = rows.skip(1).toList();

      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: headers.map((header) => DataColumn(
              label: Text(
                header, 
                style: const TextStyle(fontWeight: FontWeight.bold)
              ),
            )).toList(),
            rows: dataRows.map((row) {
              // Ensure row has same number of cells as headers
              final cells = [...row];
              while (cells.length < headers.length) {
                cells.add('');
              }
              while (cells.length > headers.length) {
                cells.removeLast();
              }
              
              return DataRow(
                cells: cells.map((cell) => DataCell(Text(cell))).toList(),
              );
            }).toList(),
          ),
        ),
      );
    } catch (e) {
      print('Error parsing CSV: $e');
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(height: 8),
              Text('Error parsing CSV: $e'),
              const SizedBox(height: 8),
              const Text('Try downloading the file to view externally.')
            ],
          ),
        ),
      );
    }
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
