import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'dart:typed_data';
import '../../../constants.dart';
import '../../../services/auth_service.dart';
import '../../../models/api_models.dart';
import '../../../models/project_module_models.dart';
import '../../../services/project_module_service.dart';
import '../../../config/api_config.dart';
import 'universal_file_viewer_screen.dart';
import 'file_test_screen.dart';

// Conditional imports for file operations
import '../../../utils/file_operations_stub.dart'
    if (dart.library.io) '../../../utils/file_operations_mobile.dart'
    if (dart.library.html) '../../../utils/file_operations_web.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key, this.projectId});

  final String? projectId; // Support direct project ID for web refresh

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  bool isLoggedIn = false;
  String selectedCategory = "All";
  bool isLoading = true;
  String? error;
  List<ProjectDocument> documents = [];
  List<DocumentCategory> categories = [];
  ProjectModuleService? service;
  String? projectId;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _checkAuthStatus();
    if (isLoggedIn) {
      await _loadProjectData();
      if (projectId != null) {
        await _loadDocuments();
      }
    }
  }

  Future<void> _checkAuthStatus() async {
    final loggedIn = await AuthService.isLoggedIn();
    if (loggedIn) {
      final token = await AuthService.getAccessToken();
      if (token != null) {
        // Use ApiConfig.baseUrl for the service
        service = ProjectModuleService(
          baseUrl: ApiConfig.baseUrl,
          token: token,
        );
      }
    }
    setState(() {
      isLoggedIn = loggedIn;
    });
  }

  Future<void> _loadProjectData() async {
    // Priority 1: Direct projectId parameter (for web refresh)
    if (widget.projectId != null) {
      setState(() {
        projectId = widget.projectId;
      });
      return;
    }
    
    // Priority 2: From route arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ProjectCard) {
      setState(() {
        projectId = args.projectUuid;
      });
    }
  }

  Future<void> _loadDocuments() async {
    if (service == null || projectId == null) return;
    
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // Load categories
      final cats = await service!.getDocumentCategories(projectId!);
      
      // Load documents
      final docs = await service!.getDocuments(projectId!);
      
      setState(() {
        categories = cats;
        documents = docs;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load documents: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _handleBackButton(context),
          ),
          title: const Text("Documents"),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text("Please log in to access project documents"),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _handleBackButton(context),
        ),
        title: const Text("Documents"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Searching documents...')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Adding new document...')),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadDocuments,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Category Filter
                    Container(
                      padding: const EdgeInsets.all(defaultPadding),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildCategoryChip("All", "All"),
                            ...categories.map((cat) => _buildCategoryChip(
                                cat.name, cat.name)),
                          ],
                        ),
                      ),
                    ),

                    // Documents List
                    Expanded(
                      child: documents.isEmpty
                          ? const Center(
                              child: Text('No documents found'),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadDocuments,
                              child: ListView(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: defaultPadding),
                                children: documents
                                    .map((doc) => _buildDocumentCard(doc))
                                    .toList(),
                              ),
                            ),
                    ),
        ],
      ),
    );
  }

  void _handleBackButton(BuildContext context) {
    // Check if we can pop (there's navigation history)
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      // If no history (e.g., after refresh), navigate to project details or dashboard
      if (projectId != null) {
        // Navigate to project details
        Navigator.of(context).pushReplacementNamed(
          '/project_details/$projectId',
        );
      } else {
        // Navigate to dashboard as fallback
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    }
  }

  Widget _buildCategoryChip(String label, String category) {
    final isSelected = selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: defaultPadding / 2),
        padding:
            const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentCard(ProjectDocument doc) {
    // Filter documents based on selected category
    if (selectedCategory != "All" &&
        selectedCategory != doc.categoryName) {
      return const SizedBox.shrink();
    }

    // Determine icon and color based on file type
    IconData icon;
    Color color;
    if (doc.fileType?.toLowerCase() == 'pdf') {
      icon = Icons.picture_as_pdf;
      color = Colors.red;
    } else if (doc.fileType?.toLowerCase() == 'docx' ||
        doc.fileType?.toLowerCase() == 'doc') {
      icon = Icons.description;
      color = Colors.blue;
    } else if (doc.fileType?.toLowerCase() == 'xlsx' ||
        doc.fileType?.toLowerCase() == 'xls') {
      icon = Icons.table_chart;
      color = Colors.green;
    } else if (doc.fileType?.toLowerCase() == 'zip') {
      icon = Icons.folder_zip;
      color = Colors.orange;
    } else {
      icon = Icons.insert_drive_file;
      color = Colors.grey;
    }

    // Format file size
    String sizeStr = '';
    if (doc.fileSize != null) {
      if (doc.fileSize! < 1024) {
        sizeStr = '${doc.fileSize} B';
      } else if (doc.fileSize! < 1024 * 1024) {
        sizeStr = '${(doc.fileSize! / 1024).toStringAsFixed(1)} KB';
      } else {
        sizeStr = '${(doc.fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
      }
    }

    // Format date
    String dateStr = 'Updated on ${doc.uploadDate.day}/${doc.uploadDate.month}/${doc.uploadDate.year}';

    return GestureDetector(
      onTap: () {
        // Navigate to universal file viewer
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UniversalFileViewerScreen(
              fileUrl: doc.downloadUrl,
              filename: doc.filename,
              fileType: doc.fileType,
            ),
          ),
        );
      },
      onLongPress: () {
        // Long press to open test screen (for debugging)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FileTestScreen(
              fileUrl: doc.downloadUrl,
              filename: doc.filename,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: defaultPadding),
        padding: const EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(defaultPadding),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: defaultPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.filename,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${doc.fileType?.toUpperCase() ?? 'FILE'} • $sizeStr',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              switch (value) {
                case 'download':
                  await _downloadDocument(doc);
                  break;
                case 'share':
                  await _shareDocument(doc);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'download',
                child: Row(
                  children: [
                    Icon(Icons.download, size: 20),
                    SizedBox(width: 8),
                    Text('Download'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share, size: 20),
                    SizedBox(width: 8),
                    Text('Share'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Future<void> _downloadDocument(ProjectDocument doc) async {
    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Text('Downloading ${doc.filename}...'),
              ],
            ),
            duration: const Duration(seconds: 30),
          ),
        );
      }

      // Get auth token
      final token = await AuthService.getAccessToken();
      if (token == null) {
        throw Exception('No authentication token available');
      }

      // Download file with authentication
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 60);

      final response = await dio.get(
        doc.downloadUrl,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/pdf, application/octet-stream, */*',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Convert to Uint8List
        Uint8List bytes;
        if (response.data is Uint8List) {
          bytes = response.data;
        } else if (response.data is List<int>) {
          bytes = Uint8List.fromList(response.data);
        } else {
          throw Exception('Unexpected response data type');
        }

        // Save to device
        await downloadFileToDevice(bytes, doc.filename);

        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text('${doc.filename} downloaded successfully!'),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        throw Exception('Server returned status ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading document: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 16),
                Expanded(
                  child: Text('Failed to download: $e'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _shareDocument(ProjectDocument doc) async {
    // Share is not supported on web
    if (kIsWeb) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.info, color: Colors.white),
                SizedBox(width: 16),
                Expanded(
                  child: Text('Share is not available on web. Use download instead.'),
                ),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Text('Preparing ${doc.filename}...'),
              ],
            ),
            duration: const Duration(seconds: 30),
          ),
        );
      }

      // Get auth token
      final token = await AuthService.getAccessToken();
      if (token == null) {
        throw Exception('No authentication token available');
      }

      // Download file with authentication
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 60);

      final response = await dio.get(
        doc.downloadUrl,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/pdf, application/octet-stream, */*',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Convert to Uint8List
        Uint8List bytes;
        if (response.data is Uint8List) {
          bytes = response.data;
        } else if (response.data is List<int>) {
          bytes = Uint8List.fromList(response.data);
        } else {
          throw Exception('Unexpected response data type');
        }

        // Save to device first
        final filePath = await saveFileToDevice(bytes, doc.filename);

        // Share the file
        await shareFile(filePath, doc.filename);

        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
        }
      } else {
        throw Exception('Server returned status ${response.statusCode}');
      }
    } catch (e) {
      print('Error sharing document: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 16),
                Expanded(
                  child: Text('Failed to share: $e'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}
