import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../config/api_config.dart';
import '../../../services/auth_service.dart';
import '../../../services/project_module_service.dart';
import '../../../models/project_module_models.dart';

class CctvSurveillanceScreen extends StatefulWidget {
  const CctvSurveillanceScreen({super.key, this.projectId});

  final String? projectId;

  @override
  State<CctvSurveillanceScreen> createState() => _CctvSurveillanceScreenState();
}

class _CctvSurveillanceScreenState extends State<CctvSurveillanceScreen> {
  bool _isLoading = true;
  String? _error;
  List<CctvCamera> _cameras = [];
  int _selectedCameraIndex = 0;
  String? projectId;

  ProjectModuleService? _service;

  @override
  void initState() {
    super.initState();
    projectId = widget.projectId;
    _initialize();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (projectId == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        projectId = args['projectId']?.toString();
      }
    }
  }

  Future<void> _initialize() async {
    final token = await AuthService.getAccessToken();
    if (token != null) {
      _service = ProjectModuleService(
        baseUrl: ApiConfig.baseUrl,
        token: token,
      );
      _loadCameras();
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Please log in to access CCTV surveillance';
        });
      }
    }
  }

  Future<void> _loadCameras() async {
    if (projectId == null || _service == null) {
      setState(() {
        _isLoading = false;
        _error = projectId == null ? 'No project selected' : 'Not authenticated';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final cameras = await _service!.getCameras(projectId!);
      if (mounted) {
        setState(() {
          _cameras = cameras;
          _isLoading = false;
          _selectedCameraIndex = 0;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load cameras: ${e.toString()}';
        });
      }
    }
  }

  CctvCamera? get _selectedCamera =>
      _cameras.isNotEmpty && _selectedCameraIndex < _cameras.length
          ? _cameras[_selectedCameraIndex]
          : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CCTV Surveillance"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCameras,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: primaryColor),
            SizedBox(height: 16),
            Text('Loading cameras...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadCameras,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (_cameras.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No cameras installed',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'CCTV cameras will appear here once installed at your project site.',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final camera = _selectedCamera;

    return Column(
      children: [
        // Main Camera View
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.all(defaultPadding),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.black,
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Stack(
              children: [
                // Camera Feed (stream or snapshot placeholder)
                if (camera?.snapshotUrl != null &&
                    camera!.snapshotUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.network(
                      camera.snapshotUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (_, __, ___) => _buildCameraPlaceholder(),
                    ),
                  )
                else
                  _buildCameraPlaceholder(),

                // Camera Name & Status Overlay
                Positioned(
                  top: defaultPadding,
                  left: defaultPadding,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: camera?.isActive == true
                              ? Colors.green
                              : Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              camera?.isActive == true
                                  ? Icons.fiber_manual_record
                                  : Icons.fiber_manual_record_outlined,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              camera?.isActive == true ? "LIVE" : "OFFLINE",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          camera?.cameraName ?? 'Camera',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Stream URL Button
                if (camera?.streamUrl != null && camera!.streamUrl!.isNotEmpty)
                  Positioned(
                    bottom: defaultPadding,
                    right: defaultPadding,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.play_circle_outline,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Camera Thumbnails
        if (_cameras.length > 1) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: Row(
              children: [
                Text(
                  "All Cameras (${_cameras.length})",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                Text(
                  '${_cameras.where((c) => c.isActive).length} online',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: defaultPadding),
              itemCount: _cameras.length,
              itemBuilder: (context, index) {
                final cam = _cameras[index];
                final isSelected = _selectedCameraIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedCameraIndex = index);
                  },
                  child: Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isSelected
                          ? primaryColor.withOpacity(0.1)
                          : Colors.grey[100],
                      border: Border.all(
                        color: isSelected ? primaryColor : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          cam.isActive ? Icons.videocam : Icons.videocam_off,
                          size: 22,
                          color: isSelected
                              ? primaryColor
                              : cam.isActive
                                  ? Colors.green
                                  : Colors.grey[400],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cam.cameraName,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? primaryColor : Colors.grey[700],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],

        const SizedBox(height: 8),

        // Camera Details Card
        if (camera != null)
          Container(
            margin: const EdgeInsets.all(defaultPadding),
            padding: const EdgeInsets.all(defaultPadding),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Camera Details",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoChip(
                        Icons.location_on,
                        "Location",
                        camera.location ?? 'Not specified',
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoChip(
                        Icons.wifi,
                        "Status",
                        camera.isActive ? 'Online' : 'Offline',
                        camera.isActive ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoChip(
                        Icons.high_quality,
                        "Resolution",
                        camera.resolution ?? 'N/A',
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
                if (camera.cameraType != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.camera, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        'Type: ${camera.cameraType}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
                if (camera.installationDate != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        'Installed: ${_formatDate(camera.installationDate!)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
                if (camera.notes != null && camera.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      camera.notes!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCameraPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.videocam,
            size: 60,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          Text(
            _selectedCamera?.cameraName ?? "Camera",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _selectedCamera?.isActive == true
                ? "Live Feed"
                : "Camera Offline",
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(
      IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
