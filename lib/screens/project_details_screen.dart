import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/project_module_models.dart';
import '../services/project_module_service.dart';
import '../config/api_config.dart';
import '../services/auth_service.dart';
import 'pdf_viewer_screen.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final int projectId;
  final String projectName;

  const ProjectDetailsScreen({
    Key? key,
    required this.projectId,
    required this.projectName,
  }) : super(key: key);

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ProjectModuleService _service;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 11, vsync: this);
    _initializeService();
  }

  Future<void> _initializeService() async {
    // Get access token from AuthService
    final token = await AuthService.getAccessToken();
    // Initialize service with production API URL
    _service = ProjectModuleService(
      baseUrl: ApiConfig.baseUrl,
      token: token,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectName),
        elevation: 2,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                tabs: const [
                  Tab(icon: Icon(Icons.folder), text: 'Documents'),
                  Tab(icon: Icon(Icons.fact_check), text: 'Quality'),
                  Tab(icon: Icon(Icons.timeline), text: 'Activity'),
                  Tab(icon: Icon(Icons.photo_library), text: 'Gallery'),
                  Tab(icon: Icon(Icons.visibility), text: 'Observations'),
                  Tab(icon: Icon(Icons.help_outline), text: 'Queries'),
                  Tab(icon: Icon(Icons.videocam), text: 'CCTV'),
                  Tab(icon: Icon(Icons.vrpano), text: '360° View'),
                  Tab(icon: Icon(Icons.location_on), text: 'Site Visits'),
                  Tab(icon: Icon(Icons.feedback), text: 'Feedback'),
                  Tab(icon: Icon(Icons.receipt_long), text: 'BoQ'),
                ],
              ),
              Container(
                height: 20,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade700, Colors.blue.shade900],
                  ),
                ),
                child: Center(
                  child: Text(
                    '← Swipe tabs left/right to see all 11 modules →',
                    style: TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          DocumentsTab(projectId: widget.projectId, service: _service),
          QualityCheckTab(projectId: widget.projectId, service: _service),
          ActivityFeedTab(projectId: widget.projectId, service: _service),
          GalleryTab(projectId: widget.projectId, service: _service),
          ObservationsTab(projectId: widget.projectId, service: _service),
          QueriesTab(projectId: widget.projectId, service: _service),
          CctvTab(projectId: widget.projectId, service: _service),
          View360Tab(projectId: widget.projectId, service: _service),
          SiteVisitsTab(projectId: widget.projectId, service: _service),
          FeedbackTab(projectId: widget.projectId, service: _service),
          BoqTab(projectId: widget.projectId, service: _service),
        ],
      ),
    );
  }
}

// ===== DOCUMENTS TAB =====
class DocumentsTab extends StatefulWidget {
  final int projectId;
  final ProjectModuleService service;

  const DocumentsTab({Key? key, required this.projectId, required this.service})
      : super(key: key);

  @override
  State<DocumentsTab> createState() => _DocumentsTabState();
}

class _DocumentsTabState extends State<DocumentsTab> {
  List<DocumentCategory>? categories;
  List<ProjectDocument>? documents;
  DocumentCategory? selectedCategory;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final cats = await widget.service.getDocumentCategories(widget.projectId);
      final docs = await widget.service.getDocuments(widget.projectId);
      setState(() {
        categories = cats;
        documents = docs;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading documents: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Category chips
        if (categories != null)
          Container(
            height: 60,
            padding: const EdgeInsets.all(8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories!.length,
              itemBuilder: (context, index) {
                final category = categories![index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(category.name),
                    selected: selectedCategory?.id == category.id,
                    onSelected: (selected) async {
                      setState(() {
                        selectedCategory = selected ? category : null;
                        isLoading = true;
                      });
                      final docs = await widget.service.getDocuments(
                        widget.projectId,
                        categoryId: selectedCategory?.id,
                      );
                      setState(() {
                        documents = docs;
                        isLoading = false;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        // Documents list
        Expanded(
          child: documents == null || documents!.isEmpty
              ? const Center(child: Text('No documents found'))
              : ListView.builder(
                  itemCount: documents!.length,
                  itemBuilder: (context, index) {
                    final doc = documents![index];
                    final isPdf = doc.fileType?.contains('pdf') ?? false;
                    final isImage = doc.fileType?.startsWith('image/') ?? false;
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isPdf ? Colors.red.shade100 : Colors.blue.shade100,
                          child: Icon(
                            isPdf ? Icons.picture_as_pdf : 
                            isImage ? Icons.image : Icons.insert_drive_file,
                            color: isPdf ? Colors.red : Colors.blue,
                          ),
                        ),
                        title: Text(
                          doc.filename,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(doc.categoryName, style: TextStyle(color: Colors.grey[600])),
                            const SizedBox(height: 2),
                            Text(
                              '${doc.uploadedByName} • ${_formatDate(doc.uploadDate)}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                            ),
                            if (doc.fileSize != null)
                              Text(
                                _formatFileSize(doc.fileSize!),
                                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                              ),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isPdf)
                              IconButton(
                                icon: const Icon(Icons.visibility, color: Colors.blue),
                                tooltip: 'View PDF',
                                onPressed: () => _viewPdf(context, doc),
                              ),
                            IconButton(
                              icon: const Icon(Icons.download, color: Colors.green),
                              tooltip: 'Download',
                              onPressed: () => _downloadFile(doc),
                            ),
                          ],
                        ),
                        onTap: isPdf ? () => _viewPdf(context, doc) : null,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  void _viewPdf(BuildContext context, ProjectDocument doc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerScreen(
          documentUrl: doc.downloadUrl,
          documentName: doc.filename,
        ),
      ),
    );
  }

  Future<void> _downloadFile(ProjectDocument doc) async {
    try {
      final uri = Uri.parse(doc.downloadUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cannot open download link')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading file: $e')),
        );
      }
    }
  }
}

// ===== QUALITY CHECK TAB =====
class QualityCheckTab extends StatefulWidget {
  final int projectId;
  final ProjectModuleService service;

  const QualityCheckTab({Key? key, required this.projectId, required this.service})
      : super(key: key);

  @override
  State<QualityCheckTab> createState() => _QualityCheckTabState();
}

class _QualityCheckTabState extends State<QualityCheckTab>
    with SingleTickerProviderStateMixin {
  late TabController _subTabController;
  List<QualityCheck>? activeChecks;
  List<QualityCheck>? resolvedChecks;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final active = await widget.service.getQualityChecks(widget.projectId, status: 'ACTIVE');
      final resolved = await widget.service.getQualityChecks(widget.projectId, status: 'RESOLVED');
      setState(() {
        activeChecks = active;
        resolvedChecks = resolved;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _subTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        TabBar(
          controller: _subTabController,
          labelColor: Colors.blue,
          tabs: const [
            Tab(text: '✅ Active'),
            Tab(text: '🟩 Resolved'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _subTabController,
            children: [
              _buildChecksList(activeChecks, true),
              _buildChecksList(resolvedChecks, false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChecksList(List<QualityCheck>? checks, bool isActive) {
    if (checks == null || checks.isEmpty) {
      return const Center(child: Text('No checks found'));
    }

    return ListView.builder(
      itemCount: checks.length,
      itemBuilder: (context, index) {
        final check = checks[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text(check.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (check.description != null) Text(check.description!),
                Text('Priority: ${check.priority}'),
                if (check.sopReference != null) Text('SOP: ${check.sopReference}'),
              ],
            ),
            trailing: Chip(
              label: Text(check.priority),
              backgroundColor: _getPriorityColor(check.priority),
            ),
            onTap: () {
              // Show details dialog
            },
          ),
        );
      },
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'CRITICAL':
        return Colors.red;
      case 'HIGH':
        return Colors.orange;
      case 'MEDIUM':
        return Colors.yellow;
      default:
        return Colors.green;
    }
  }
}

// ===== ACTIVITY FEED TAB =====
class ActivityFeedTab extends StatefulWidget {
  final int projectId;
  final ProjectModuleService service;

  const ActivityFeedTab({Key? key, required this.projectId, required this.service})
      : super(key: key);

  @override
  State<ActivityFeedTab> createState() => _ActivityFeedTabState();
}

class _ActivityFeedTabState extends State<ActivityFeedTab> {
  List<ActivityFeed>? activities;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await widget.service.getActivities(widget.projectId);
      setState(() {
        activities = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (activities == null || activities!.isEmpty) {
      return const Center(child: Text('No activities found'));
    }

    return ListView.builder(
      itemCount: activities!.length,
      itemBuilder: (context, index) {
        final activity = activities![index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getColorFromName(activity.activityTypeColor),
              child: Icon(Icons.info, color: Colors.white),
            ),
            title: Text(activity.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (activity.description != null) Text(activity.description!),
                Text('${activity.createdByName} • ${_formatDateTime(activity.createdAt)}'),
              ],
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to referenced item
            },
          ),
        );
      },
    );
  }

  Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'red':
        return Colors.red;
      case 'purple':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}

// ===== GALLERY TAB =====
class GalleryTab extends StatefulWidget {
  final int projectId;
  final ProjectModuleService service;

  const GalleryTab({Key? key, required this.projectId, required this.service})
      : super(key: key);

  @override
  State<GalleryTab> createState() => _GalleryTabState();
}

class _GalleryTabState extends State<GalleryTab> {
  List<GalleryImage>? images;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await widget.service.getGalleryImages(widget.projectId);
      setState(() {
        images = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (images == null || images!.isEmpty) {
      return const Center(child: Text('No images found'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: images!.length,
      itemBuilder: (context, index) {
        final image = images![index];
        return GestureDetector(
          onTap: () {
            // Show full image
          },
          child: Card(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // TODO: Replace with actual image
                Container(color: Colors.grey[300]),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.black54,
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      image.takenDate.toString().split(' ')[0],
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ===== OBSERVATIONS TAB =====
class ObservationsTab extends StatefulWidget {
  final int projectId;
  final ProjectModuleService service;

  const ObservationsTab({Key? key, required this.projectId, required this.service})
      : super(key: key);

  @override
  State<ObservationsTab> createState() => _ObservationsTabState();
}

class _ObservationsTabState extends State<ObservationsTab>
    with SingleTickerProviderStateMixin {
  late TabController _subTabController;
  List<Observation>? activeObs;
  List<Observation>? resolvedObs;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final active = await widget.service.getObservations(widget.projectId, status: 'ACTIVE');
      final resolved = await widget.service.getObservations(widget.projectId, status: 'RESOLVED');
      setState(() {
        activeObs = active;
        resolvedObs = resolved;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading observations: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _subTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        TabBar(
          controller: _subTabController,
          labelColor: Colors.orange,
          tabs: const [
            Tab(text: 'Active Observations'),
            Tab(text: 'Resolved Observations'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _subTabController,
            children: [
              _buildObsList(activeObs, true),
              _buildObsList(resolvedObs, false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildObsList(List<Observation>? observations, bool isActive) {
    if (observations == null || observations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.visibility_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              isActive ? 'No active observations' : 'No resolved observations',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: observations.length,
      itemBuilder: (context, index) {
        final obs = observations[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getPriorityColor(obs.priority),
              child: Icon(
                isActive ? Icons.warning : Icons.check_circle,
                color: Colors.white,
              ),
            ),
            title: Text(obs.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(obs.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.person, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(obs.reportedByName, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    const SizedBox(width: 16),
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(_formatDate(obs.reportedDate), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
                if (obs.location != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(obs.location!, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ],
              ],
            ),
            trailing: Chip(
              label: Text(obs.priority, style: const TextStyle(fontSize: 10)),
              backgroundColor: _getPriorityColor(obs.priority),
            ),
            isThreeLine: true,
            onTap: () => _showObservationDetails(obs, isActive),
          ),
        );
      },
    );
  }

  void _showObservationDetails(Observation obs, bool isActive) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(obs.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(obs.description),
              const SizedBox(height: 12),
              Text('Priority: ${obs.priority}'),
              Text('Reported by: ${obs.reportedByName}'),
              if (obs.reportedByRoleName != null) Text('Role: ${obs.reportedByRoleName}'),
              if (obs.location != null) Text('Location: ${obs.location}'),
              if (!isActive && obs.resolutionNotes != null) ...[
                const SizedBox(height: 12),
                Text('Resolution:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(obs.resolutionNotes!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'HIGH':
        return Colors.red;
      case 'MEDIUM':
        return Colors.orange;
      case 'LOW':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// ===== QUERIES TAB =====
class QueriesTab extends StatefulWidget {
  final int projectId;
  final ProjectModuleService service;

  const QueriesTab({Key? key, required this.projectId, required this.service})
      : super(key: key);

  @override
  State<QueriesTab> createState() => _QueriesTabState();
}

class _QueriesTabState extends State<QueriesTab>
    with SingleTickerProviderStateMixin {
  late TabController _subTabController;
  List<ProjectQuery>? activeQueries;
  List<ProjectQuery>? resolvedQueries;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final active = await widget.service.getQueries(widget.projectId, status: 'ACTIVE');
      final resolved = await widget.service.getQueries(widget.projectId, status: 'RESOLVED');
      setState(() {
        activeQueries = active;
        resolvedQueries = resolved;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _subTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        TabBar(
          controller: _subTabController,
          labelColor: Colors.blue,
          tabs: const [
            Tab(text: 'Active Queries'),
            Tab(text: 'Resolved Queries'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _subTabController,
            children: [
              _buildQueryList(activeQueries, true),
              _buildQueryList(resolvedQueries, false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQueryList(List<ProjectQuery>? queries, bool isActive) {
    if (queries == null || queries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.help_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              isActive ? 'No active queries' : 'No resolved queries',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: queries.length,
      itemBuilder: (context, index) {
        final query = queries[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: _getPriorityColor(query.priority),
              child: const Icon(Icons.question_answer, color: Colors.white),
            ),
            title: Text(query.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Raised by: ${query.raisedByName}'),
                Text('Date: ${_formatDate(query.raisedDate)}'),
                if (query.category != null) Text('Category: ${query.category}'),
              ],
            ),
            trailing: Chip(
              label: Text(query.priority, style: const TextStyle(fontSize: 10)),
              backgroundColor: _getPriorityColor(query.priority),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Query:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(query.description),
                    if (!isActive && query.resolution != null) ...[
                      const SizedBox(height: 12),
                      Text('Resolution:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(query.resolution!),
                      if (query.resolvedByName != null) ...[
                        const SizedBox(height: 8),
                        Text('Resolved by: ${query.resolvedByName}'),
                        Text('Resolved on: ${_formatDate(query.resolvedDate!)}'),
                      ],
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'URGENT':
        return Colors.red;
      case 'HIGH':
        return Colors.orange;
      case 'MEDIUM':
        return Colors.yellow;
      case 'LOW':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// ===== CCTV TAB =====
class CctvTab extends StatefulWidget {
  final int projectId;
  final ProjectModuleService service;

  const CctvTab({Key? key, required this.projectId, required this.service})
      : super(key: key);

  @override
  State<CctvTab> createState() => _CctvTabState();
}

class _CctvTabState extends State<CctvTab> {
  List<CctvCamera>? cameras;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await widget.service.getCameras(widget.projectId);
      setState(() {
        cameras = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (cameras == null || cameras!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Not Installed',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              'No CCTV cameras installed for this project',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    final installedCameras = cameras!.where((c) => c.isInstalled).toList();

    if (installedCameras.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Not Installed',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              'Cameras configured but not yet installed',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: installedCameras.length,
      itemBuilder: (context, index) {
        final camera = installedCameras[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: camera.isActive ? Colors.green : Colors.red,
                  child: Icon(
                    camera.isActive ? Icons.videocam : Icons.videocam_off,
                    color: Colors.white,
                  ),
                ),
                title: Text(camera.cameraName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (camera.location != null) Text('Location: ${camera.location}'),
                    if (camera.resolution != null) Text('Resolution: ${camera.resolution}'),
                    Text('Status: ${camera.isActive ? "Active" : "Inactive"}'),
                  ],
                ),
                trailing: Icon(
                  camera.isActive ? Icons.circle : Icons.circle_outlined,
                  color: camera.isActive ? Colors.green : Colors.red,
                ),
              ),
              if (camera.streamUrl != null)
                Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.black,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_circle_outline, size: 64, color: Colors.white),
                        const SizedBox(height: 8),
                        Text(
                          'Live Stream',
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        TextButton(
                          onPressed: () {
                            // TODO: Implement video player
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Stream URL: ${camera.streamUrl}')),
                            );
                          },
                          child: const Text('View Stream', style: TextStyle(color: Colors.blue)),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

// ===== 360° VIEW TAB =====
class View360Tab extends StatefulWidget {
  final int projectId;
  final ProjectModuleService service;

  const View360Tab({Key? key, required this.projectId, required this.service})
      : super(key: key);

  @override
  State<View360Tab> createState() => _View360TabState();
}

class _View360TabState extends State<View360Tab> {
  List<View360>? views;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await widget.service.get360Views(widget.projectId);
      setState(() {
        views = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (views == null || views!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.vrpano, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No 360° Views Available',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: views!.length,
      itemBuilder: (context, index) {
        final view = views![index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (view.thumbnailUrl != null)
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // TODO: Load actual thumbnail
                      Icon(Icons.vrpano, size: 80, color: Colors.grey[600]),
                      Center(
                        child: Icon(
                          Icons.play_circle_outline,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      view.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    if (view.description != null) Text(view.description!),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(view.location ?? 'No location'),
                        const Spacer(),
                        Icon(Icons.remove_red_eye, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text('${view.viewCount} views'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          // Increment view count
                          await widget.service.increment360ViewCount(widget.projectId, view.id);
                          // TODO: Open 360 viewer
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Opening 360° view: ${view.viewUrl}')),
                          );
                        },
                        icon: const Icon(Icons.vrpano),
                        label: const Text('View 360°'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ===== SITE VISITS TAB =====
class SiteVisitsTab extends StatefulWidget {
  final int projectId;
  final ProjectModuleService service;

  const SiteVisitsTab({Key? key, required this.projectId, required this.service})
      : super(key: key);

  @override
  State<SiteVisitsTab> createState() => _SiteVisitsTabState();
}

class _SiteVisitsTabState extends State<SiteVisitsTab> {
  List<SiteVisit>? visits;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await widget.service.getSiteVisits(widget.projectId);
      setState(() {
        visits = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (visits == null || visits!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No site visits recorded',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: visits!.length,
      itemBuilder: (context, index) {
        final visit = visits![index];
        final duration = visit.checkOutTime != null
            ? visit.checkOutTime!.difference(visit.checkInTime)
            : Duration.zero;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: visit.checkOutTime != null ? Colors.green : Colors.orange,
              child: Icon(
                visit.checkOutTime != null ? Icons.check : Icons.access_time,
                color: Colors.white,
              ),
            ),
            title: Text(visit.visitorName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (visit.visitorRoleName != null) Text(visit.visitorRoleName!),
                Text('Check-in: ${_formatDateTime(visit.checkInTime)}'),
                if (visit.checkOutTime != null) ...[
                  Text('Check-out: ${_formatDateTime(visit.checkOutTime!)}'),
                  Text('Duration: ${duration.inHours}h ${duration.inMinutes % 60}m'),
                ] else
                  Text('Currently on site', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (visit.purpose != null) ...[
                      Text('Purpose:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(visit.purpose!),
                      const SizedBox(height: 8),
                    ],
                    if (visit.location != null) ...[
                      Text('Location: ${visit.location}'),
                      const SizedBox(height: 8),
                    ],
                    if (visit.weatherConditions != null) ...[
                      Text('Weather: ${visit.weatherConditions}'),
                      const SizedBox(height: 8),
                    ],
                    if (visit.notes != null) ...[
                      Text('Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(visit.notes!),
                      const SizedBox(height: 8),
                    ],
                    if (visit.findings != null) ...[
                      Text('Findings:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(visit.findings!),
                      const SizedBox(height: 8),
                    ],
                    if (visit.attendees != null && visit.attendees!.isNotEmpty) ...[
                      Text('Attendees:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ...visit.attendees!.map((a) => Text('• $a')),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// ===== FEEDBACK TAB =====
class FeedbackTab extends StatefulWidget {
  final int projectId;
  final ProjectModuleService service;

  const FeedbackTab({Key? key, required this.projectId, required this.service})
      : super(key: key);

  @override
  State<FeedbackTab> createState() => _FeedbackTabState();
}

class _FeedbackTabState extends State<FeedbackTab> {
  List<FeedbackForm>? forms;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await widget.service.getFeedbackForms(widget.projectId);
      setState(() {
        forms = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (forms == null || forms!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.feedback_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No feedback forms available',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: forms!.length,
      itemBuilder: (context, index) {
        final form = forms![index];
        final isCompleted = form.isCompleted ?? false;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isCompleted ? Colors.green : Colors.blue,
              child: Icon(
                isCompleted ? Icons.check_circle : Icons.rate_review,
                color: Colors.white,
              ),
            ),
            title: Text(form.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (form.description != null) Text(form.description!, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(
                  isCompleted ? 'Completed ✓' : 'Pending',
                  style: TextStyle(
                    color: isCompleted ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            trailing: isCompleted
                ? const Icon(Icons.check_circle, color: Colors.green)
                : ElevatedButton(
                    onPressed: () => _showFeedbackDialog(form),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Take Survey'),
                  ),
            onTap: isCompleted ? null : () => _showFeedbackDialog(form),
          ),
        );
      },
    );
  }

  void _showFeedbackDialog(FeedbackForm form) {
    int rating = 3;
    final commentsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(form.title),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (form.description != null) ...[
                    Text(form.description!),
                    const SizedBox(height: 16),
                  ],
                  Text('Rating:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            rating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  Text('Comments:', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextField(
                    controller: commentsController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Enter your feedback here...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await widget.service.submitFeedback(
                  widget.projectId,
                  form.id,
                  rating: rating,
                  comments: commentsController.text,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Feedback submitted successfully!')),
                );
                _loadData(); // Refresh the list
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

// ===== BOQ TAB =====
class BoqTab extends StatefulWidget {
  final int projectId;
  final ProjectModuleService service;

  const BoqTab({Key? key, required this.projectId, required this.service})
      : super(key: key);

  @override
  State<BoqTab> createState() => _BoqTabState();
}

class _BoqTabState extends State<BoqTab> {
  List<BoqItem>? items;
  List<BoqWorkType>? workTypes;
  BoqWorkType? selectedWorkType;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final itemsData = await widget.service.getBoqItems(widget.projectId);
      final typesData = await widget.service.getBoqWorkTypes(widget.projectId);
      setState(() {
        items = itemsData;
        workTypes = typesData;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (items == null || items!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No BoQ items available',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Group items by work type
    final groupedItems = <String, List<BoqItem>>{};
    for (var item in items!) {
      if (!groupedItems.containsKey(item.workTypeName)) {
        groupedItems[item.workTypeName] = [];
      }
      groupedItems[item.workTypeName]!.add(item);
    }

    // Calculate totals
    final grandTotal = items!.fold<double>(0, (sum, item) => sum + item.amount);

    return Column(
      children: [
        // Summary card
        Card(
          margin: const EdgeInsets.all(8),
          color: Colors.blue[50],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Items', style: TextStyle(color: Colors.grey[700])),
                    Text(
                      '${items!.length}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Grand Total', style: TextStyle(color: Colors.grey[700])),
                    Text(
                      '₹ ${grandTotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Work type filter
        if (workTypes != null && workTypes!.isNotEmpty)
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: workTypes!.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: const Text('All'),
                      selected: selectedWorkType == null,
                      onSelected: (selected) {
                        setState(() {
                          selectedWorkType = null;
                        });
                      },
                    ),
                  );
                }
                final workType = workTypes![index - 1];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(workType.name),
                    selected: selectedWorkType?.id == workType.id,
                    onSelected: (selected) {
                      setState(() {
                        selectedWorkType = selected ? workType : null;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        // Items list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: groupedItems.keys.length,
            itemBuilder: (context, index) {
              final workTypeName = groupedItems.keys.elementAt(index);
              final workTypeItems = groupedItems[workTypeName]!;
              
              // Filter if work type selected
              if (selectedWorkType != null && workTypeName != selectedWorkType!.name) {
                return const SizedBox.shrink();
              }

              final subtotal = workTypeItems.fold<double>(0, (sum, item) => sum + item.amount);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ExpansionTile(
                  title: Text(
                    workTypeName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${workTypeItems.length} items • ₹ ${subtotal.toStringAsFixed(2)}'),
                  children: workTypeItems.map((item) {
                    return ListTile(
                      dense: true,
                      title: Text(item.description),
                      subtitle: Text('${item.quantity} ${item.unit} @ ₹${item.rate}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹ ${item.amount.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          if (item.itemCode != null)
                            Text(
                              item.itemCode!,
                              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

