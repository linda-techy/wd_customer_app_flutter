import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../report_service.dart';
import '../../utils/currency_formatter.dart';
import '../../models/project_module_models.dart';

/// Generates a landscape BOQ Summary PDF grouped by work type.
class BoqReport {
  BoqReport._();

  static Future<void> generate({
    required String projectName,
    required String revisionInfo,
    required List<BoqItem> boqItems,
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

    double grandTotal = 0.0;

    for (final entry in grouped.entries) {
      final groupTotal =
          entry.value.fold<double>(0, (s, i) => s + i.amount);
      grandTotal += groupTotal;

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
                'Subtotal: ${CurrencyFormatter.format(groupTotal)}',
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

      // Items table for this group
      content.add(
        ReportService.buildTable(
          headers: ['Item Code', 'Description', 'Unit', 'Qty', 'Rate', 'Amount'],
          rows: entry.value.map((item) {
            return [
              item.itemCode ?? '',
              item.description,
              item.unit,
              item.quantity == item.quantity.truncateToDouble()
                  ? item.quantity.toInt().toString()
                  : item.quantity.toStringAsFixed(2),
              CurrencyFormatter.format(item.rate),
              CurrencyFormatter.format(item.amount),
            ];
          }).toList(),
          columnAlignments: [
            pw.Alignment.centerLeft,
            pw.Alignment.centerLeft,
            pw.Alignment.center,
            pw.Alignment.centerRight,
            pw.Alignment.centerRight,
            pw.Alignment.centerRight,
          ],
        ),
      );
      content.add(pw.SizedBox(height: 8));
    }

    // Grand total row
    content.add(pw.Divider(thickness: 1));
    content.add(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Text(
            'Grand Total: ${CurrencyFormatter.format(grandTotal)}',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#D84940'),
            ),
          ),
        ],
      ),
    );

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
