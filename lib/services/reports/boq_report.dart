import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../report_service.dart';
import '../../utils/currency_formatter.dart';
import '../../models/project_module_models.dart';

/// Generates a landscape BOQ scope PDF grouped by work type.
///
/// Customer view: lists scope (item code + description + status) only.
/// Quantity, unit, rate, and line-item amount are intentionally omitted —
/// contractor BoQ pricing is commercially sensitive and the customer approves
/// on the document-level total (passed in via [totalAmount] from BoqSummary).
class BoqReport {
  BoqReport._();

  static Future<void> generate({
    required String projectName,
    required String revisionInfo,
    required List<BoqItem> boqItems,
    double? totalAmount,
  }) async {
    final doc = ReportService.createDocument();

    // Group items by work type
    final Map<String, List<BoqItem>> grouped = {};
    for (final item in boqItems) {
      final key =
          item.workTypeName.isNotEmpty ? item.workTypeName : (item.categoryName ?? 'General Work');
      grouped.putIfAbsent(key, () => []).add(item);
    }

    final List<pw.Widget> content = [];

    for (final entry in grouped.entries) {
      // Group header row
      content.add(
        pw.Container(
          color: PdfColors.grey100,
          padding:
              const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                entry.key,
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#D84940'),
                ),
              ),
              pw.Text(
                '${entry.value.length} item${entry.value.length == 1 ? '' : 's'}',
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
      content.add(pw.SizedBox(height: 2));

      // Items table for this group — scope only, no pricing breakdown
      content.add(
        ReportService.buildTable(
          headers: ['Item Code', 'Description', 'Status'],
          rows: entry.value.map((item) {
            return [
              item.itemCode ?? '',
              item.description,
              item.status ?? '',
            ];
          }).toList(),
          columnAlignments: [
            pw.Alignment.centerLeft,
            pw.Alignment.centerLeft,
            pw.Alignment.center,
          ],
        ),
      );
      content.add(pw.SizedBox(height: 8));
    }

    // Document-level total (customer-approved value) — sourced from BoqSummary,
    // not summed client-side from redacted per-item amounts.
    if (totalAmount != null) {
      content.add(pw.Divider(thickness: 1));
      content.add(
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Text(
              'Total Project Cost: ${CurrencyFormatter.format(totalAmount)}',
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#D84940'),
              ),
            ),
          ],
        ),
      );
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: ReportService.landscapeFormat,
        header: (context) => ReportService.buildHeader(
          'BOQ Summary',
          projectName: projectName,
          subtitle: revisionInfo,
        ),
        footer: ReportService.buildFooter,
        build: (context) => content,
      ),
    );

    await ReportService.sharePdf(doc, 'boq_summary.pdf');
  }
}
