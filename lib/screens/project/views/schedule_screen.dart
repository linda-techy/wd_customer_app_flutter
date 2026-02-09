import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../config/api_config.dart';
import '../../../services/auth_service.dart';
import '../../../services/project_module_service.dart';
import '../../../services/dashboard_service.dart';
import '../../../models/project_module_models.dart' hide ApiResponse;
import '../../../models/api_models.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key, this.projectId});

  final String? projectId;

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  bool _isLoading = true;
  String? _error;
  String? projectId;

  ProjectDetails? _projectDetails;
  List<BoqWorkType> _workTypes = [];
  Map<int, List<BoqItem>> _boqByWorkType = {};
  int _selectedWorkTypeIndex = 0;

  ProjectModuleService? _moduleService;

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
      _moduleService = ProjectModuleService(
        baseUrl: ApiConfig.baseUrl,
        token: token,
      );
      _loadData();
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Please log in to view the schedule';
        });
      }
    }
  }

  Future<void> _loadData() async {
    if (projectId == null || _moduleService == null) {
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
      // Load project details and BOQ work types in parallel
      final results = await Future.wait([
        DashboardService.getProjectDetails(projectId!),
        _moduleService!.getBoqWorkTypes(projectId!),
        _moduleService!.getBoqItems(projectId!),
      ]);

      final projectDetailsResponse = results[0] as ApiResponse<ProjectDetails>;
      final projectDetails = projectDetailsResponse.data;
      final workTypes = results[1] as List<BoqWorkType>;
      final allBoqItems = results[2] as List<BoqItem>;

      // Group BOQ items by work type
      final boqByWorkType = <int, List<BoqItem>>{};
      for (final item in allBoqItems) {
        boqByWorkType.putIfAbsent(item.workTypeId, () => []).add(item);
      }

      if (mounted) {
        setState(() {
          _projectDetails = projectDetails;
          _workTypes = workTypes;
          _boqByWorkType = boqByWorkType;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load schedule data: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Project Schedule"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
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
            Text('Loading schedule...'),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
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

    return RefreshIndicator(
      onRefresh: _loadData,
      color: primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Progress Card
            _buildOverallProgressCard(),
            const SizedBox(height: defaultPadding * 1.5),

            // Work Phases
            if (_workTypes.isNotEmpty) ...[
              Text(
                "Work Phases",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
              ),
              const SizedBox(height: defaultPadding),
              _buildWorkTypeSelector(),
              const SizedBox(height: defaultPadding * 1.5),
              _buildPhaseDetailsCard(),
              const SizedBox(height: defaultPadding * 1.5),
            ],

            // Timeline
            Text(
              "Work Breakdown",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
            ),
            const SizedBox(height: defaultPadding),

            if (_workTypes.isEmpty)
              _buildEmptyState()
            else
              ..._buildWorkTypeTimeline(),

            const SizedBox(height: defaultPadding * 1.5),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallProgressCard() {
    final project = _projectDetails;
    final progress = project?.progress ?? 0;
    final phase = project?.phase ?? 'N/A';
    final status = project?.status ?? 'Active';

    return Container(
      padding: const EdgeInsets.all(defaultPadding * 1.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Overall Progress",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: defaultPadding),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${progress.toStringAsFixed(0)}%",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "Completed",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      phase,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text(
                      "Current Phase",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: defaultPadding),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (project?.startDate != null)
                Text(
                  "Start: ${project!.startDate}",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              if (project?.endDate != null)
                Text(
                  "Target: ${project!.endDate}",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkTypeSelector() {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
      Colors.deepOrange,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_workTypes.length, (index) {
          final wt = _workTypes[index];
          final isSelected = _selectedWorkTypeIndex == index;
          final color = colors[index % colors.length];
          final itemCount = _boqByWorkType[wt.id]?.length ?? 0;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedWorkTypeIndex = index);
            },
            child: Container(
              width: 130,
              margin: const EdgeInsets.only(right: defaultPadding),
              padding: const EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color : Colors.grey[300]!,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : [],
              ),
              child: Column(
                children: [
                  Icon(
                    _getWorkTypeIcon(wt.name),
                    color: isSelected ? Colors.white : color,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    wt.name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$itemCount items',
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : Colors.grey[500],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPhaseDetailsCard() {
    if (_workTypes.isEmpty) return const SizedBox.shrink();

    final wt = _workTypes[_selectedWorkTypeIndex];
    final items = _boqByWorkType[wt.id] ?? [];
    final totalAmount =
        items.fold<double>(0, (sum, item) => sum + item.amount);

    return Container(
      padding: const EdgeInsets.all(defaultPadding * 1.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  wt.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${items.length} items',
                  style: const TextStyle(
                    color: primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (wt.description != null) ...[
            const SizedBox(height: 8),
            Text(
              wt.description!,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
          const SizedBox(height: defaultPadding),

          // Summary Row
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Total Items',
                  '${items.length}',
                  Icons.list_alt,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Total Amount',
                  _formatCurrency(totalAmount),
                  Icons.account_balance_wallet,
                  Colors.green,
                ),
              ),
            ],
          ),

          if (items.isNotEmpty) ...[
            const SizedBox(height: defaultPadding),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'BOQ Items',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            ...items.take(5).map((item) => _buildBoqItemRow(item)),
            if (items.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '+ ${items.length - 5} more items',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
      String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.grey[500], fontSize: 11),
            ),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBoqItemRow(BoqItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              item.description,
              style: const TextStyle(fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${item.quantity} ${item.unit}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              _formatCurrency(item.amount),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildWorkTypeTimeline() {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.amber,
    ];

    return List.generate(_workTypes.length, (index) {
      final wt = _workTypes[index];
      final items = _boqByWorkType[wt.id] ?? [];
      final color = colors[index % colors.length];
      final isLast = index == _workTypes.length - 1;

      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline connector
            SizedBox(
              width: 40,
              child: Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: items.isNotEmpty ? color : Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: Colors.grey[300],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: defaultPadding),
                padding: const EdgeInsets.all(defaultPadding),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getWorkTypeIcon(wt.name),
                          color: color,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            wt.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${items.length} items',
                            style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (wt.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        wt.description!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                    if (items.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Total: ${_formatCurrency(items.fold<double>(0, (s, i) => s + i.amount))}',
                        style: TextStyle(
                          color: color,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.event_note, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No schedule data available',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Work phases and BOQ items will appear here once added to the project.',
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getWorkTypeIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('foundation') || lower.contains('earth')) {
      return Icons.foundation;
    }
    if (lower.contains('structure') || lower.contains('rcc') || lower.contains('concrete')) {
      return Icons.construction;
    }
    if (lower.contains('electric') || lower.contains('wiring')) {
      return Icons.electric_bolt;
    }
    if (lower.contains('plumb') || lower.contains('water') || lower.contains('sanitary')) {
      return Icons.plumbing;
    }
    if (lower.contains('finish') || lower.contains('paint') || lower.contains('interior')) {
      return Icons.brush;
    }
    if (lower.contains('masonry') || lower.contains('brick') || lower.contains('wall')) {
      return Icons.view_in_ar;
    }
    if (lower.contains('roof') || lower.contains('waterproof')) {
      return Icons.roofing;
    }
    if (lower.contains('floor') || lower.contains('tile')) {
      return Icons.grid_on;
    }
    if (lower.contains('door') || lower.contains('window') || lower.contains('wood')) {
      return Icons.door_front_door;
    }
    if (lower.contains('hvac') || lower.contains('air') || lower.contains('ventil')) {
      return Icons.air;
    }
    if (lower.contains('landscape') || lower.contains('garden') || lower.contains('external')) {
      return Icons.park;
    }
    return Icons.build;
  }

  String _formatCurrency(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(2)} Cr';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(2)} L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}
