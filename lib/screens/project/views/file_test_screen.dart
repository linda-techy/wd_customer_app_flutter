import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:typed_data';
import '../../../services/auth_service.dart';
import '../../../constants.dart';

/// Debug screen to test file download with detailed logging
class FileTestScreen extends StatefulWidget {
  const FileTestScreen({
    super.key,
    required this.fileUrl,
    required this.filename,
  });

  final String fileUrl;
  final String filename;

  @override
  State<FileTestScreen> createState() => _FileTestScreenState();
}

class _FileTestScreenState extends State<FileTestScreen> {
  final List<String> _logs = [];
  bool _isLoading = false;
  Uint8List? _fileBytes;
  String? _error;

  @override
  void initState() {
    super.initState();
    _addLog('Initialized with URL: ${widget.fileUrl}');
    _addLog('Filename: ${widget.filename}');
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('[${DateTime.now().toString().split('.')[0]}] $message');
    });
    print(message);
  }

  Future<void> _testDownload() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _fileBytes = null;
      _logs.clear();
    });

    try {
      _addLog('=== STARTING FILE DOWNLOAD TEST ===');
      
      // Step 1: Get auth token
      _addLog('Step 1: Getting auth token...');
      final token = await AuthService.getAccessToken();
      if (token == null) {
        throw Exception('No auth token available');
      }
      _addLog('✓ Got token: ${token.substring(0, 20)}...');

      // Step 2: Create Dio instance
      _addLog('Step 2: Creating HTTP client...');
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 60);
      dio.options.followRedirects = true;
      dio.options.maxRedirects = 5;
      _addLog('✓ HTTP client configured');

      // Step 3: Make request
      _addLog('Step 3: Making request to: ${widget.fileUrl}');
      _addLog('Headers: Authorization: Bearer [token]');
      _addLog('Accept: application/pdf, application/octet-stream, */*');
      
      final response = await dio.get(
        widget.fileUrl,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/pdf, application/octet-stream, */*',
          },
          validateStatus: (status) => status != null && status < 600,
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(1);
            _addLog('Progress: $progress% ($received / $total bytes)');
          }
        },
      );

      // Step 4: Check response
      _addLog('Step 4: Analyzing response...');
      _addLog('Status Code: ${response.statusCode}');
      _addLog('Status Message: ${response.statusMessage}');
      _addLog('Content-Type: ${response.headers.value('content-type')}');
      _addLog('Content-Length: ${response.headers.value('content-length')}');
      _addLog('Data Type: ${response.data.runtimeType}');
      _addLog('Data Length: ${response.data?.length ?? 0}');

      if (response.statusCode != 200) {
        _addLog('✗ ERROR: Non-200 status code');
        
        // Try to read error body
        if (response.data != null) {
          try {
            final errorText = String.fromCharCodes(response.data);
            _addLog('Error Body: $errorText');
          } catch (e) {
            _addLog('Could not decode error body');
          }
        }
        
        throw Exception('HTTP ${response.statusCode}: ${response.statusMessage}');
      }

      // Step 5: Convert to bytes
      _addLog('Step 5: Converting to bytes...');
      Uint8List bytes;
      if (response.data is Uint8List) {
        bytes = response.data;
        _addLog('✓ Data is already Uint8List');
      } else if (response.data is List<int>) {
        bytes = Uint8List.fromList(response.data);
        _addLog('✓ Converted List<int> to Uint8List');
      } else {
        throw Exception('Unexpected data type: ${response.data.runtimeType}');
      }
      
      _addLog('✓ Bytes length: ${bytes.length}');

      // Step 6: Verify file header
      _addLog('Step 6: Verifying file header...');
      if (bytes.length > 4) {
        final header = String.fromCharCodes(bytes.sublist(0, 4));
        _addLog('File header: $header');

        if (bytes.length >= 20) {
          final first20 = String.fromCharCodes(bytes.sublist(0, 20));
          _addLog('First 20 bytes: $first20');
        }

        // Check for HTML error page
        if (header.toLowerCase().contains('<!do') ||
            header.toLowerCase().contains('<htm')) {
          _addLog('✗ ERROR: Received HTML instead of file!');
          final htmlPreview = String.fromCharCodes(
              bytes.length > 500 ? bytes.sublist(0, 500) : bytes);
          _addLog('HTML Preview: $htmlPreview');
          throw Exception('Server returned HTML error page');
        }

        // Check for PDF
        if (widget.filename.toLowerCase().endsWith('.pdf')) {
          if (header == '%PDF') {
            _addLog('✓ Valid PDF header detected');
          } else {
            _addLog('⚠ WARNING: Expected PDF header, got: $header');
          }
        } else {
          _addLog('✓ File header looks valid');
        }
      } else {
        throw Exception('File too small: ${bytes.length} bytes');
      }

      // Success!
      _addLog('=== SUCCESS ===');
      _addLog('File downloaded successfully!');
      _addLog('Total size: ${bytes.length} bytes (${(bytes.length / 1024).toStringAsFixed(2)} KB)');
      
      setState(() {
        _fileBytes = bytes;
        _isLoading = false;
      });

    } on DioException catch (e) {
      _addLog('=== DIO EXCEPTION ===');
      _addLog('Type: ${e.type}');
      _addLog('Message: ${e.message}');
      
      if (e.response != null) {
        _addLog('Response Status: ${e.response!.statusCode}');
        _addLog('Response Headers: ${e.response!.headers}');
        
        if (e.response!.data != null) {
          try {
            final errorText = String.fromCharCodes(e.response!.data);
            _addLog('Response Body: $errorText');
          } catch (_) {
            _addLog('Could not decode response body');
          }
        }
      }
      
      setState(() {
        _error = 'DioException: ${e.type} - ${e.message}';
        _isLoading = false;
      });
      
    } catch (e, stackTrace) {
      _addLog('=== EXCEPTION ===');
      _addLog('Error: $e');
      _addLog('Stack Trace: $stackTrace');
      
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Download Test'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Test button
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testDownload,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.play_arrow),
                  label: Text(_isLoading ? 'Testing...' : 'Start Test'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_fileBytes != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Success! Downloaded ${_fileBytes!.length} bytes',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Logs
          Expanded(
            child: Container(
              color: Colors.black,
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  final log = _logs[index];
                  Color textColor = Colors.white;
                  
                  if (log.contains('✓')) {
                    textColor = Colors.green;
                  } else if (log.contains('✗') || log.contains('ERROR')) {
                    textColor = Colors.red;
                  } else if (log.contains('⚠') || log.contains('WARNING')) {
                    textColor = Colors.orange;
                  } else if (log.contains('===')) {
                    textColor = Colors.cyan;
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: SelectableText(
                      log,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: textColor,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

