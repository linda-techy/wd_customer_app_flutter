import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../report_service.dart';
import '../../models/api_models.dart';

/// Generates a Project Progress Summary PDF.
class ProgressReport {
  ProgressReport._();

  static final _dateFmt = DateFormat('dd MMM yyyy');

  static Future<void> generate({
    required ProjectDetails projectDetails,
    required List<ProjectPhaseModel> phases,
    required String projectName,
  }) async {
    final doc = ReportService.createDocument();

    // Overall progress: prefer progressData.overallProgress, fall back to progress field
    final overallPct =
        projectDetails.progressData?.overallProgress ?? projectDetails.progress;

    // Milestones from progressData
    final milestones = projectDetails.progressData?.milestones ?? [];

    doc.addPage(
      pw.MultiPage(
        pageFormat: ReportService.portraitFormat,
        header: (context) => ReportService.buildHeader(
          'Project Progress Summary',
          projectName: projectName,
        ),
        footer: ReportService.buildFooter,
        build: (context) => [
          // ── Project Info ──────────────────────────────────────────────────
          _sectionTitle('Project Information'),
          pw.SizedBox(height: 4),
          _buildInfoTable(projectDetails),
          pw.SizedBox(height: 16),

          // ── Overall Progress ──────────────────────────────────────────────
          _sectionTitle('Overall Progress'),
          pw.SizedBox(height: 8),
          _buildProgressBar(
            label: 'Construction Progress',
            percentage: overallPct,
          ),
          if (projectDetails.progressData != null) ...[
            pw.SizedBox(height: 6),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _statChip('Days Elapsed',
                    '${projectDetails.progressData!.daysElapsed}'),
                _statChip('Days Remaining',
                    '${projectDetails.progressData!.daysRemaining}'),
                _statChip('Status',
                    projectDetails.progressData!.progressStatus),
              ],
            ),
          ],
          pw.SizedBox(height: 16),

          // ── Phase Timeline ────────────────────────────────────────────────
          if (phases.isNotEmpty) ...[
            _sectionTitle('Phase Timeline'),
            pw.SizedBox(height: 4),
            _buildPhaseTable(phases),
            pw.SizedBox(height: 16),
          ],

          // ── Milestones ────────────────────────────────────────────────────
          if (milestones.isNotEmpty) ...[
            _sectionTitle('Milestones'),
            pw.SizedBox(height: 4),
            _buildMilestonesTable(milestones),
          ],
        ],
      ),
    );

    await ReportService.sharePdf(doc, 'progress_summary.pdf');
  }

  // ── Section title ──────────────────────────────────────────────────────────

  static pw.Widget _sectionTitle(String title) {
    return pw.Container(
      color: PdfColor.fromHex('#D84940'),
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
      ),
    );
  }

  static pw.Widget _buildInfoTable(ProjectDetails details) {
    final rows = <List<String>>[
      ['Location', details.location ?? '-'],
      ['Status', details.status ?? '-'],
      ['Phase', details.phase ?? '-'],
      ['Start Date', details.startDate ?? '-'],
      ['Expected Completion', details.endDate ?? '-'],
      if (details.responsiblePerson != null &&
          details.responsiblePerson!.isNotEmpty)
        ['Site Manager', details.responsiblePerson!],
      if (details.sqFeet != null)
        ['Area', '${details.sqFeet!.toStringAsFixed(0)} sq ft'],
    ];

    return ReportService.buildTable(
      headers: ['Field', 'Value'],
      rows: rows,
      columnAlignments: [
        pw.Alignment.centerLeft,
        pw.Alignment.centerLeft,
      ],
    );
  }

  static pw.Widget _buildProgressBar({
    required String label,
    required double percentage,
  }) {
    final clamped = percentage.clamp(0.0, 100.0);
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label,
                style:
                    pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
            pw.Text('${clamped.toStringAsFixed(1)}%',
                style:
                    pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          ],
        ),
        pw.SizedBox(height: 4),
        // Simulate a progress bar with two stacked containers
        pw.Row(
          children: [
            // Filled portion
            if (clamped > 0)
              pw.Expanded(
                flex: clamped.round(),
                child: pw.Container(
                  height: 10,
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#D84940'),
                    borderRadius: const pw.BorderRadius.only(
                      topLeft: pw.Radius.circular(5),
                      bottomLeft: pw.Radius.circular(5),
                    ),
                  ),
                ),
              ),
            // Remaining portion
            if (clamped < 100)
              pw.Expanded(
                flex: (100 - clamped).round(),
                child: pw.Container(
                  height: 10,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey300,
                    borderRadius: const pw.BorderRadius.only(
                      topRight: pw.Radius.circular(5),
                      bottomRight: pw.Radius.circular(5),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _statChip(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(label,
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
        pw.Text(value,
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  static pw.Widget _buildPhaseTable(List<ProjectPhaseModel> phases) {
    String _fmtDate(DateTime? d) =>
        d != null ? _dateFmt.format(d) : '-';

    return ReportService.buildTable(
      headers: ['Phase', 'Status', 'Planned Start', 'Planned End', 'Actual Start', 'Actual End'],
      rows: phases.map((p) {
        return [
          p.phaseName,
          p.status,
          _fmtDate(p.plannedStart),
          _fmtDate(p.plannedEnd),
          _fmtDate(p.actualStart),
          _fmtDate(p.actualEnd),
        ];
      }).toList(),
      columnAlignments: [
        pw.Alignment.centerLeft,
        pw.Alignment.center,
        pw.Alignment.center,
        pw.Alignment.center,
        pw.Alignment.center,
        pw.Alignment.center,
      ],
    );
  }

  static pw.Widget _buildMilestonesTable(List<ProgressMilestone> milestones) {
    String _fmtDate(DateTime? d) =>
        d != null ? _dateFmt.format(d) : '-';

    return ReportService.buildTable(
      headers: ['Milestone', 'Progress', 'Target Date', 'Completed Date', 'Status'],
      rows: milestones.map((m) {
        return [
          m.name,
          '${m.progressPercentage.toStringAsFixed(0)}%',
          _fmtDate(m.targetDate),
          _fmtDate(m.completedDate),
          m.status,
        ];
      }).toList(),
      columnAlignments: [
        pw.Alignment.centerLeft,
        pw.Alignment.centerRight,
        pw.Alignment.center,
        pw.Alignment.center,
        pw.Alignment.center,
      ],
    );
  }
}
