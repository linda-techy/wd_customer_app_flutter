import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import '../../models/site_report_models.dart';
import '../../services/site_report_service.dart';
import 'site_report_detail_screen.dart';

class SiteReportsScreen extends StatefulWidget {
  final int? projectId; // Optional: filter by specific project
  
  const SiteReportsScreen({super.key, this.projectId});

  @override
  State<SiteReportsScreen> createState() => _SiteReportsScreenState();
}

class _SiteReportsScreenState extends State<SiteReportsScreen> {
  final SiteReportService _siteReportService = SiteReportService();
  List<SiteReport> _reports = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isTimelineView = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final reports = await _siteReportService.getCustomerSiteReports(
        projectId: widget.projectId,
      );
      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load site reports: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Site Reports'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isTimelineView ? Icons.view_list : Icons.timeline),
            onPressed: () {
              setState(() {
                _isTimelineView = !_isTimelineView;
              });
            },
            tooltip: _isTimelineView ? 'Card View' : 'Timeline View',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadReports,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_reports.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.report_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No site reports available', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReports,
      child: _isTimelineView ? _buildTimelineView() : _buildCardList(),
    );
  }

  Widget _buildCardList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reports.length,
      itemBuilder: (context, index) {
        final report = _reports[index];
        return _buildReportCard(report);
      },
    );
  }

  Widget _buildTimelineView() {
    // Group reports by date
    final groupedReports = <DateTime, List<SiteReport>>{};
    for (final report in _reports) {
      final reportDate = DateTime.parse(report.reportDate);
      final date = DateTime(
        reportDate.year,
        reportDate.month,
        reportDate.day,
      );
      groupedReports.putIfAbsent(date, () => []).add(report);
    }

    final sortedDates = groupedReports.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final reports = groupedReports[date]!;
        return _buildDateGroup(date, reports);
      },
    );
  }

  Widget _buildDateGroup(DateTime date, List<SiteReport> reports) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final isToday = date.isAtSameMomentAs(today);
    final isYesterday = date.isAtSameMomentAs(yesterday);

    String dateLabel;
    if (isToday) {
      dateLabel = 'Today';
    } else if (isYesterday) {
      dateLabel = 'Yesterday';
    } else {
      dateLabel = DateFormat('EEEE, MMMM d, y').format(date);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: isToday ? Theme.of(context).primaryColor : Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateLabel,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isToday ? Theme.of(context).primaryColor : Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${reports.length} ${reports.length == 1 ? 'report' : 'reports'}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey[300]),
          const SizedBox(height: 12),
          // Timeline items
          ...reports.asMap().entries.map((entry) {
            final index = entry.key;
            final report = entry.value;
            final isLast = index == reports.length - 1;
            return _buildTimelineItem(report, isLast);
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(SiteReport report, bool isLast) {
    final reportDate = DateTime.parse(report.reportDate);
    final timeStr = DateFormat('h:mm a').format(reportDate);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line and dot
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: Colors.grey[300],
                    ),
                  ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 12, bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timeStr,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildTimelineCard(report),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(SiteReport report) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SiteReportDetailScreen(report: report),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      report.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildReportTypeBadge(report.reportType),
                ],
              ),
              const SizedBox(height: 8),

              // Project info
              Row(
                children: [
                  const Icon(Icons.business, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      report.projectName ?? 'Project #${report.projectId}',
                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // Description
              if (report.description != null && report.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  report.description!,
                  style: TextStyle(color: Colors.grey[800], fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Photos Preview
              if (report.photos.isNotEmpty) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: min(report.photos.length, 4),
                    itemBuilder: (context, photoIndex) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            report.photos[photoIndex].photoUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image, size: 20, color: Colors.grey),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (report.photos.length > 4)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '+${report.photos.length - 4} more photos',
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(SiteReport report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SiteReportDetailScreen(report: report),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      report.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildReportTypeBadge(report.reportType),
                ],
              ),
              const SizedBox(height: 8),
              
              // Project & Date
              Row(
                children: [
                  const Icon(Icons.business, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      report.projectName ?? 'Project #${report.projectId}',
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    report.formattedDate,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
              
              // Description
              if (report.description != null && report.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  report.description!,
                  style: TextStyle(color: Colors.grey[800], fontSize: 14),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              // Photos Preview
              if (report.photos.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.photo_library, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      '${report.photos.length} photo${report.photos.length > 1 ? 's' : ''}',
                      style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: min(report.photos.length, 5),
                    itemBuilder: (context, photoIndex) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            report.photos[photoIndex].photoUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image, color: Colors.grey),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (report.photos.length > 5)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '+${report.photos.length - 5} more',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportTypeBadge(ReportType type) {
    Color backgroundColor;
    Color textColor;
    
    switch (type) {
      case ReportType.dailyProgress:
        backgroundColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        break;
      case ReportType.qualityCheck:
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        break;
      case ReportType.safetyIncident:
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        break;
      case ReportType.materialDelivery:
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        break;
      case ReportType.siteVisitSummary:
        backgroundColor = Colors.purple.shade50;
        textColor = Colors.purple.shade700;
        break;
      case ReportType.other:
        backgroundColor = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type.label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
