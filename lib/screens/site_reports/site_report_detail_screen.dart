import 'package:flutter/material.dart';
import '../../models/site_report_models.dart';
import '../../services/reports/site_report_pdf.dart';
import '../../widgets/authenticated_image.dart';
import 'site_report_photo_viewer.dart';

class SiteReportDetailScreen extends StatefulWidget {
  final SiteReport report;

  const SiteReportDetailScreen({super.key, required this.report});

  @override
  State<SiteReportDetailScreen> createState() => _SiteReportDetailScreenState();
}

class _SiteReportDetailScreenState extends State<SiteReportDetailScreen> {
  bool _exporting = false;

  Future<void> _exportPdf() async {
    setState(() => _exporting = true);
    try {
      await SiteReportPdf.generate(report: widget.report);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Export failed: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Site Report Details'),
        elevation: 0,
        actions: [
          if (_exporting)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            IconButton(
              icon: const Icon(Icons.download),
              tooltip: 'Export PDF',
              onPressed: _exportPdf,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              margin: EdgeInsets.zero,
              shape: const RoundedRectangleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      widget.report.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Report Type Badge
                    _buildReportTypeBadge(widget.report.reportType),

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Project Info
                    _buildInfoRow(
                      Icons.business,
                      'Project',
                      widget.report.projectName ?? 'Project #${widget.report.projectId}',
                    ),
                    const SizedBox(height: 8),

                    // Date
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Date',
                      widget.report.formattedDate,
                    ),
                    const SizedBox(height: 8),

                    // Status
                    _buildInfoRow(
                      Icons.info_outline,
                      'Status',
                      widget.report.status,
                    ),

                    // Submitted By
                    if (widget.report.submittedByName != null) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.person,
                        'Submitted By',
                        widget.report.submittedByName!,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Description Card
            if (widget.report.description != null && widget.report.description!.isNotEmpty)
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.report.description!,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[800],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Photos Section
            if (widget.report.photos.isNotEmpty)
              Card(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Photos (${widget.report.photos.length})',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(Icons.photo_library, color: Colors.blue),
                        ],
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: widget.report.photos.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SiteReportPhotoViewer(
                                    photos: widget.report.photos,
                                    initialIndex: index,
                                  ),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  AuthenticatedImage(
                                    imageUrl:
                                        widget.report.photos[index].fullUrl,
                                    fit: BoxFit.cover,
                                    errorWidget: Container(
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.broken_image,
                                          color: Colors.grey),
                                    ),
                                  ),
                                  // Tap indicator overlay
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.1),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        type.label,
        style: TextStyle(
          color: textColor,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
