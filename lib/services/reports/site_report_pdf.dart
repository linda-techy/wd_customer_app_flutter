import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../report_service.dart';
import '../../models/site_report_models.dart';

/// Generates a Site Report PDF.
/// Photos are not embedded (requires async network download); the photo count
/// is shown instead, and embedding can be added in a future enhancement.
class SiteReportPdf {
  SiteReportPdf._();

  static Future<void> generate({
    required SiteReport report,
  }) async {
    final doc = ReportService.createDocument();

    doc.addPage(
      pw.MultiPage(
        pageFormat: ReportService.portraitFormat,
        header: (context) => ReportService.buildHeader(
          'Site Report',
          projectName: report.projectName ?? 'Project #${report.projectId}',
        ),
        footer: ReportService.buildFooter,
        build: (context) => [
          // ── Report Meta ────────────────────────────────────────────────────
          _buildMetaTable(report),
          pw.SizedBox(height: 16),

          // ── Description ────────────────────────────────────────────────────
          if (report.description != null &&
              report.description!.trim().isNotEmpty) ...[
            _sectionTitle('Description'),
            pw.SizedBox(height: 6),
            pw.Text(
              report.description!,
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.black),
            ),
            pw.SizedBox(height: 16),
          ],

          // ── Photos ─────────────────────────────────────────────────────────
          _sectionTitle('Photos'),
          pw.SizedBox(height: 6),
          pw.Text(
            report.photos.isEmpty
                ? 'No photos attached to this report.'
                : '${report.photos.length} photo${report.photos.length == 1 ? '' : 's'} attached '
                    '(open the app to view photos).',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
        ],
      ),
    );

    final filename =
        'site_report_${report.id ?? report.reportDate.toIso8601String().split('T').first}.pdf';
    await ReportService.sharePdf(doc, filename);
  }

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

  static pw.Widget _buildMetaTable(SiteReport report) {
    final rows = <List<String>>[
      ['Title', report.title],
      ['Report Type', report.reportType.label],
      ['Date', report.formattedDate],
      ['Status', report.status],
      if (report.submittedByName != null)
        ['Submitted By', report.submittedByName!],
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
}
