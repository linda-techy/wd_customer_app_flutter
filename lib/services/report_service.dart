import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Shared infrastructure for all PDF reports generated client-side.
class ReportService {
  ReportService._();

  static const _pageFormat = PdfPageFormat.a4;
  static final _landscapeFormat = PdfPageFormat(
    PdfPageFormat.a4.height,
    PdfPageFormat.a4.width,
    marginAll: 24,
  );

  static PdfPageFormat get portraitFormat => _pageFormat;
  static PdfPageFormat get landscapeFormat => _landscapeFormat;

  // ── Header / Footer ─────────────────────────────────────────────────────────

  static pw.Widget buildHeader(
    String title, {
    String? subtitle,
    String? projectName,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Walldot Builders',
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#D84940'),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        if (projectName != null)
          pw.Text(
            'Project: $projectName',
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
          ),
        if (subtitle != null)
          pw.Text(
            subtitle,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
          ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Generated: ${DateTime.now().toString().split('.').first}',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
        ),
        pw.Divider(),
        pw.SizedBox(height: 8),
      ],
    );
  }

  static pw.Widget buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Text(
        'Page ${context.pageNumber} of ${context.pagesCount}',
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
      ),
    );
  }

  // ── Document factory ─────────────────────────────────────────────────────────

  static pw.Document createDocument() {
    return pw.Document(
      theme: pw.ThemeData.withFont(),
    );
  }

  // ── Table helper ─────────────────────────────────────────────────────────────

  static pw.Widget buildTable({
    required List<String> headers,
    required List<List<String>> rows,
    List<pw.Alignment>? columnAlignments,
  }) {
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: rows,
      headerStyle:
          pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
      cellStyle: const pw.TextStyle(fontSize: 8),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      cellAlignments: columnAlignments != null
          ? {
              for (var i = 0; i < columnAlignments.length; i++)
                i: columnAlignments[i]
            }
          : null,
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      cellPadding:
          const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
    );
  }

  // ── Share helper ─────────────────────────────────────────────────────────────

  static Future<void> sharePdf(pw.Document doc, String filename) async {
    final bytes = await doc.save();
    await Printing.sharePdf(bytes: bytes, filename: filename);
  }
}
