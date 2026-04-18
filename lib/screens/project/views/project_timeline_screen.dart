import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../constants.dart';
import '../../../services/auth_service.dart';
import '../../../services/gantt_service.dart';
import '../../../config/api_config.dart';

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

class _GanttTask {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final double progress; // 0-100
  final String status; // completed | in-progress | not-started | overdue
  final String? assignee;

  const _GanttTask({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.progress,
    required this.status,
    this.assignee,
  });

  factory _GanttTask.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    return _GanttTask(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['taskName']?.toString() ?? 'Task',
      startDate: parseDate(json['startDate'] ?? json['plannedStartDate']),
      endDate: parseDate(json['endDate'] ?? json['plannedEndDate']),
      progress: (json['progress'] ?? json['completionPercentage'] ?? 0).toDouble(),
      status: (json['status'] ?? 'not-started').toString().toLowerCase().replaceAll('_', '-'),
      assignee: json['assignee']?.toString() ?? json['assignedTo']?.toString(),
    );
  }

  Color get barColor {
    switch (status) {
      case 'completed':
        return const Color(0xFF4CAF50); // green
      case 'in-progress':
      case 'in_progress':
        return const Color(0xFF2196F3); // blue
      case 'overdue':
        return const Color(0xFFF44336); // red
      default:
        return const Color(0xFF9E9E9E); // grey
    }
  }

  String get statusLabel {
    switch (status) {
      case 'completed':
        return 'Completed';
      case 'in-progress':
      case 'in_progress':
        return 'In Progress';
      case 'overdue':
        return 'Overdue';
      default:
        return 'Not Started';
    }
  }
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class ProjectTimelineScreen extends StatefulWidget {
  final String projectId;

  const ProjectTimelineScreen({super.key, required this.projectId});

  @override
  State<ProjectTimelineScreen> createState() => _ProjectTimelineScreenState();
}

class _ProjectTimelineScreenState extends State<ProjectTimelineScreen> {
  bool _isLoading = true;
  String? _error;

  List<_GanttTask> _tasks = [];
  DateTime? _projectStart;
  DateTime? _projectEnd;
  double _overallProgress = 0;
  int _overdueTasks = 0;

  // Layout constants
  static const double _taskNameWidth = 150.0;
  static const double _pixelsPerDay = 20.0;
  static const double _rowHeight = 52.0;
  static const double _barHeight = 28.0;
  static const double _headerHeight = 40.0;

  // Horizontal scroll controller shared between header and body
  final ScrollController _headerScrollCtrl = ScrollController();
  final ScrollController _bodyScrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _headerScrollCtrl.addListener(_syncHeaderToBody);
    _bodyScrollCtrl.addListener(_syncBodyToHeader);
    _loadData();
  }

  void _syncHeaderToBody() {
    if (_bodyScrollCtrl.hasClients &&
        _bodyScrollCtrl.offset != _headerScrollCtrl.offset) {
      _bodyScrollCtrl.jumpTo(_headerScrollCtrl.offset);
    }
  }

  void _syncBodyToHeader() {
    if (_headerScrollCtrl.hasClients &&
        _headerScrollCtrl.offset != _bodyScrollCtrl.offset) {
      _headerScrollCtrl.jumpTo(_bodyScrollCtrl.offset);
    }
  }

  @override
  void dispose() {
    _headerScrollCtrl.removeListener(_syncHeaderToBody);
    _bodyScrollCtrl.removeListener(_syncBodyToHeader);
    _headerScrollCtrl.dispose();
    _bodyScrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) {
        setState(() {
          _error = 'Not authenticated';
          _isLoading = false;
        });
        return;
      }
      final service = GanttService(baseUrl: ApiConfig.baseUrl, token: token);
      final data = await service.fetchGanttData(widget.projectId);

      if (data == null) {
        setState(() {
          _error = 'No timeline data available for this project.';
          _isLoading = false;
        });
        return;
      }

      final rawTasks = data['tasks'] as List<dynamic>? ?? [];
      final tasks = rawTasks
          .whereType<Map<String, dynamic>>()
          .map((j) => _GanttTask.fromJson(j))
          .toList();

      DateTime? start;
      DateTime? end;

      if (data['projectStartDate'] != null) {
        try {
          start = DateTime.parse(data['projectStartDate'].toString());
        } catch (_) {}
      }
      if (data['projectEndDate'] != null) {
        try {
          end = DateTime.parse(data['projectEndDate'].toString());
        } catch (_) {}
      }

      // Fall back to min/max of tasks if not provided
      if (tasks.isNotEmpty) {
        start ??= tasks.map((t) => t.startDate).reduce((a, b) => a.isBefore(b) ? a : b);
        end ??= tasks.map((t) => t.endDate).reduce((a, b) => a.isAfter(b) ? a : b);
      }

      setState(() {
        _tasks = tasks;
        _projectStart = start;
        _projectEnd = end;
        _overallProgress = (data['overallProgress'] ?? 0).toDouble();
        _overdueTasks = (data['overdueTasks'] ?? 0) as int;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load timeline: $e';
        _isLoading = false;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: blackColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Project Timeline',
          style: TextStyle(
            color: blackColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: surfaceColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: blackColor60),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : _error != null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding * 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.timeline_outlined, size: 64, color: blackColor40),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: blackColor60, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_tasks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.view_timeline_outlined, size: 64, color: blackColor40),
            SizedBox(height: 16),
            Text(
              'No tasks found for this project.',
              style: TextStyle(color: blackColor60, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildSummaryHeader(),
        const Divider(height: 1, color: blackColor10),
        Expanded(child: _buildGanttChart()),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Summary header
  // ---------------------------------------------------------------------------

  Widget _buildSummaryHeader() {
    final now = DateTime.now();
    int daysRemaining = 0;
    if (_projectEnd != null) {
      daysRemaining = _projectEnd!.difference(now).inDays;
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: 12,
      ),
      child: Row(
        children: [
          // Progress circle
          _buildProgressCircle(_overallProgress),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatChip(
                  label: 'Tasks',
                  value: '${_tasks.length}',
                  icon: Icons.task_alt,
                  color: const Color(0xFF2196F3),
                ),
                _buildStatChip(
                  label: 'Overdue',
                  value: '$_overdueTasks',
                  icon: Icons.warning_amber_rounded,
                  color: _overdueTasks > 0 ? const Color(0xFFF44336) : blackColor40,
                ),
                _buildStatChip(
                  label: daysRemaining >= 0 ? 'Days Left' : 'Days Over',
                  value: '${daysRemaining.abs()}',
                  icon: daysRemaining >= 0
                      ? Icons.calendar_today_outlined
                      : Icons.calendar_month_outlined,
                  color: daysRemaining >= 0
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFF44336),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCircle(double progress) {
    return SizedBox(
      width: 68,
      height: 68,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress / 100,
            strokeWidth: 6,
            backgroundColor: blackColor10,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 100
                  ? const Color(0xFF4CAF50)
                  : primaryColor,
            ),
          ),
          Text(
            '${progress.round()}%',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: blackColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: blackColor60),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Gantt chart
  // ---------------------------------------------------------------------------

  Widget _buildGanttChart() {
    if (_projectStart == null || _projectEnd == null) {
      return const SizedBox.shrink();
    }

    final totalDays = _projectEnd!.difference(_projectStart!).inDays + 1;
    final totalWidth = totalDays * _pixelsPerDay;
    final today = DateTime.now();

    // Today marker offset
    double? todayOffset;
    if (!today.isBefore(_projectStart!) && !today.isAfter(_projectEnd!)) {
      todayOffset = today.difference(_projectStart!).inDays * _pixelsPerDay;
    }

    return Column(
      children: [
        // Date header row
        SizedBox(
          height: _headerHeight,
          child: Row(
            children: [
              // Fixed left spacer matching task-name column
              Container(
                width: _taskNameWidth,
                color: const Color(0xFFF5F5F5),
                alignment: Alignment.center,
                child: const Text(
                  'Task',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: blackColor60,
                  ),
                ),
              ),
              const VerticalDivider(width: 1, color: blackColor10),
              Expanded(
                child: SingleChildScrollView(
                  controller: _headerScrollCtrl,
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  child: SizedBox(
                    width: totalWidth,
                    child: _buildDateHeader(totalDays),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: blackColor10),
        // Task rows
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fixed task names column
              SizedBox(
                width: _taskNameWidth,
                child: ListView.builder(
                  physics: const ClampingScrollPhysics(),
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) => _buildTaskNameCell(_tasks[index]),
                ),
              ),
              const VerticalDivider(width: 1, color: blackColor10),
              // Scrollable timeline area
              Expanded(
                child: SingleChildScrollView(
                  controller: _bodyScrollCtrl,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: totalWidth,
                    child: Stack(
                      children: [
                        // Grid lines + bars
                        ListView.builder(
                          physics: const ClampingScrollPhysics(),
                          itemCount: _tasks.length,
                          itemBuilder: (context, index) {
                            return _buildTaskBarRow(
                              _tasks[index],
                              totalWidth,
                            );
                          },
                        ),
                        // Today vertical marker
                        if (todayOffset != null)
                          Positioned(
                            left: todayOffset,
                            top: 0,
                            bottom: 0,
                            child: _buildTodayMarker(),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateHeader(int totalDays) {
    // Show month labels at month boundaries
    final months = <Widget>[];
    DateTime current = _projectStart!;

    while (!current.isAfter(_projectEnd!)) {
      final monthStart = DateTime(current.year, current.month, 1);
      final monthEnd = DateTime(current.year, current.month + 1, 0); // last day
      final clampedStart = current.isAfter(monthStart) ? current : monthStart;
      final clampedEnd = monthEnd.isAfter(_projectEnd!) ? _projectEnd! : monthEnd;
      final days = clampedEnd.difference(clampedStart).inDays + 1;
      final width = days * _pixelsPerDay;

      months.add(
        SizedBox(
          width: width,
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5),
              border: Border(right: BorderSide(color: blackColor10)),
            ),
            child: Text(
              DateFormat('MMM yyyy').format(clampedStart),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: blackColor60,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );

      // Advance to the next month
      current = DateTime(current.year, current.month + 1, 1);
    }

    return Row(children: months);
  }

  Widget _buildTaskNameCell(_GanttTask task) {
    return GestureDetector(
      onTap: () => _showTaskDetails(task),
      child: Container(
        height: _rowHeight,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: blackColor10)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: task.barColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                task.name,
                style: const TextStyle(fontSize: 12, color: blackColor),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskBarRow(_GanttTask task, double totalWidth) {
    final projectStartDate = _projectStart!;
    final startOffset = task.startDate.difference(projectStartDate).inDays;
    final duration = task.endDate.difference(task.startDate).inDays + 1;

    final left = (startOffset * _pixelsPerDay).clamp(0.0, totalWidth);
    final barWidth = (duration * _pixelsPerDay).clamp(4.0, totalWidth - left);
    final fillWidth = (barWidth * task.progress / 100).clamp(0.0, barWidth);

    return GestureDetector(
      onTap: () => _showTaskDetails(task),
      child: Container(
        height: _rowHeight,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: blackColor10)),
        ),
        child: Stack(
          children: [
            // Bar background
            Positioned(
              left: left,
              top: (_rowHeight - _barHeight) / 2,
              child: Container(
                width: barWidth,
                height: _barHeight,
                decoration: BoxDecoration(
                  color: task.barColor.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: task.barColor.withOpacity(0.5)),
                ),
                child: Stack(
                  children: [
                    // Progress fill
                    if (task.progress > 0)
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: fillWidth,
                          decoration: BoxDecoration(
                            color: task.barColor.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    // Progress label inside bar
                    if (barWidth > 40)
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${task.progress.round()}%',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: task.barColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayMarker() {
    return const IgnorePointer(
      child: SizedBox(
        width: 2,
        child: CustomPaint(
          painter: _DashedLinePainter(color: primaryColor),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Task details bottom sheet
  // ---------------------------------------------------------------------------

  void _showTaskDetails(_GanttTask task) {
    final df = DateFormat('dd MMM yyyy');
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
              defaultPadding, 12, defaultPadding, defaultPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: blackColor20,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Task name
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: task.barColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: blackColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Status chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: task.barColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  task.statusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: task.barColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: blackColor10),
              const SizedBox(height: 8),
              _detailRow(Icons.calendar_today_outlined, 'Start Date', df.format(task.startDate)),
              const SizedBox(height: 10),
              _detailRow(Icons.event_outlined, 'End Date', df.format(task.endDate)),
              const SizedBox(height: 10),
              _detailRow(Icons.timelapse_outlined, 'Duration',
                  '${task.endDate.difference(task.startDate).inDays + 1} days'),
              const SizedBox(height: 10),
              // Progress bar row
              Row(
                children: [
                  const Icon(Icons.show_chart, size: 18, color: blackColor60),
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 80,
                    child: Text('Progress', style: TextStyle(fontSize: 13, color: blackColor60)),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${task.progress.round()}%',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: blackColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: task.progress / 100,
                          backgroundColor: blackColor10,
                          valueColor: AlwaysStoppedAnimation<Color>(task.barColor),
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (task.assignee != null && task.assignee!.isNotEmpty) ...[
                const SizedBox(height: 10),
                _detailRow(Icons.person_outline, 'Assignee', task.assignee!),
              ],
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: blackColor60),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: blackColor60),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: blackColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Custom painter: dashed vertical line for "today" marker
// ---------------------------------------------------------------------------

class _DashedLinePainter extends CustomPainter {
  final Color color;

  const _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashHeight = 6.0;
    const dashSpace = 4.0;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}
