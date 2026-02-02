import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:typed_data';
import '../../../constants.dart';
import '../../../services/auth_service.dart';
import '../../../models/api_models.dart';
import '../../../models/project_module_models.dart';
import '../../../services/project_module_service.dart';
import '../../../config/api_config.dart';
import 'universal_file_viewer_screen.dart';
import 'file_test_screen.dart';
import '../../../components/animations/fade_entry.dart';
import '../../../components/animations/hover_card.dart';
import '../../../components/animations/scale_button.dart';

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
        backgroundColor: surfaceColor,
        appBar: _buildAppBar(),
        body: const Center(
          child: Text("Please log in to access project documents"),
        ),
      );
    }

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: _buildAppBar(showActions: true),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : error != null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  PreferredSizeWidget _buildAppBar({bool showActions = false}) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: blackColor),
        onPressed: () => _handleBackButton(context),
      ),
      title: const Text("Project Documents", style: TextStyle(color: blackColor, fontWeight: FontWeight.bold)),
      backgroundColor: surfaceColor,
      elevation: 0,
      centerTitle: false,
      actions: showActions
          ? [
              IconButton(
                icon: const Icon(Icons.search, color: blackColor),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: primaryColor),
                onPressed: () {},
              ),
            ]
          : [],
    );
  }

  Widget _buildContent() {
    final filteredDocs = selectedCategory == "All" 
        ? documents 
        : documents.where((d) => d.categoryName == selectedCategory).toList();

    return Column(
      children: [
        // Category Filter
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            children: [
              _buildCategoryChip("All", "All"),
              ...categories.map((cat) => _buildCategoryChip(cat.name, cat.name)),
            ],
          ),
        ),

        // Documents List
        Expanded(
          child: filteredDocs.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadDocuments,
                  color: primaryColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(defaultPadding),
                    itemCount: filteredDocs.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return FadeEntry(
                        delay: (100 + (index * 50)).ms,
                        child: _buildDocumentCard(filteredDocs[index]),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
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
            child: const Icon(Icons.folder_open_outlined, size: 48, color: primaryColor),
          ).animate().scale(duration: 500.ms),
          const SizedBox(height: 16),
          Text(
            'No documents found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Documents uploaded by the team will appear here.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: blackColor60),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: errorColor),
            const SizedBox(height: 16),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: errorColor),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadDocuments,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: const StadiumBorder(),
              ),
              child: const Text('Retry Connection'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, String category) {
    final isSelected = selectedCategory == category;
    return ScaleButton(
      onTap: () {
        setState(() {
          selectedCategory = category;
        });
      },
      child: AnimatedContainer(
        duration: 300.ms,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? primaryColor : blackColor10,
          ),
          boxShadow: isSelected 
              ? [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : blackColor60,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentCard(ProjectDocument doc) {
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
    String dateStr = 'Updated: ${doc.uploadDate.day}/${doc.uploadDate.month}/${doc.uploadDate.year}';

    return HoverCard(
      child: GestureDetector(
        onTap: () {
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
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: blackColor.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
            border: Border.all(color: blackColor10),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.filename,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                         Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: blackColor5,
                            borderRadius: BorderRadius.circular(4),
                          ),
                           child: Text(
                            doc.fileType?.toUpperCase() ?? 'FILE',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: blackColor60),
                           ),
                         ),
                        const SizedBox(width: 8),
                        Text(
                          sizeStr,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: blackColor40),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: blackColor40),
                onPressed: () => _showDownloadOption(doc),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showDownloadOption(ProjectDocument doc) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.download_rounded, color: primaryColor),
              title: const Text("Download to Device"),
              onTap: () {
                Navigator.pop(context);
                _downloadDocument(doc);
              },
            ),
             ListTile(
              leading: const Icon(Icons.share_rounded, color: blackColor),
              title: const Text("Share Document"),
              onTap: () {
                Navigator.pop(context);
                _shareDocument(doc);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleBackButton(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      if (projectId != null) {
        Navigator.of(context).pushReplacementNamed('/project_details/$projectId');
      } else {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    }
  }
  
  // existing download/share logic remains...
  Future<void> _downloadDocument(ProjectDocument doc) async {
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Starting download...'), duration: Duration(seconds: 1)),
        );
      }

      final token = await AuthService.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      final url = _resolveFileUrl(doc.downloadUrl);
      
      final dio = Dio();
      final response = await dio.get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': '*/*'
          },
        ),
      );

      if (response.statusCode == 200) {
        final bytes = Uint8List.fromList(response.data);
        await downloadFileToDevice(bytes, doc.filename);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Downloaded ${doc.filename} successfully'), 
              backgroundColor: successColor,
              action: SnackBarAction(
                label: 'View',
                textColor: Colors.white,
                onPressed: () {
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
              ),
            ),
          );
        }
      } else {
        throw Exception('Failed to download: ${response.statusCode}');
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e'), backgroundColor: errorColor),
        );
      }
    }
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
      return url;
    }
  }

  bool _isLoopbackHost(String host) {
    final normalized = host.toLowerCase();
    return normalized == 'localhost' ||
        normalized == '127.0.0.1' ||
        normalized == '0.0.0.0';
  }

  Future<void> _shareDocument(ProjectDocument doc) async {
    // existing share logic
  }
}
