import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../report_service.dart';
import '../../utils/currency_formatter.dart';
import '../../models/payment_models.dart';

/// Generates a Payment Schedule PDF with a summary row.
class PaymentReport {
  PaymentReport._();

  static Future<void> generate({
    required String projectName,
    required List<PaymentSchedule> schedules,
  }) async {
    final doc = ReportService.createDocument();

    final rows = schedules.map((s) {
      return [
        s.description,
        CurrencyFormatter.format(s.amount),
        s.status,
        s.dueDate ?? '-',
        s.paidDate ?? '-',
      ];
    }).toList();

    // Totals
    final totalAmount =
        schedules.fold<double>(0, (sum, s) => sum + s.amount);
    final paidAmount =
        schedules.fold<double>(0, (sum, s) => sum + s.paidAmount);
    final dueAmount = totalAmount - paidAmount;

    doc.addPage(
      pw.MultiPage(
        pageFormat: ReportService.portraitFormat,
        header: (context) => ReportService.buildHeader(
          'Payment Schedule',
          projectName: projectName,
        ),
        footer: ReportService.buildFooter,
        build: (context) => [
          ReportService.buildTable(
            headers: ['Stage', 'Amount', 'Status', 'Due Date', 'Paid Date'],
            rows: rows,
            columnAlignments: [
              pw.Alignment.centerLeft,
              pw.Alignment.centerRight,
              pw.Alignment.center,
              pw.Alignment.center,
              pw.Alignment.center,
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Divider(thickness: 1),
          pw.SizedBox(height: 6),
          _buildSummaryRow('Total Contract Value', CurrencyFormatter.format(totalAmount)),
          pw.SizedBox(height: 4),
          _buildSummaryRow('Amount Paid', CurrencyFormatter.format(paidAmount),
              color: PdfColors.green700),
          pw.SizedBox(height: 4),
          _buildSummaryRow('Amount Due', CurrencyFormatter.format(dueAmount),
              color: dueAmount > 0 ? PdfColors.red700 : PdfColors.green700),
        ],
      ),
    );

    await ReportService.sharePdf(doc, 'payment_schedule.pdf');
  }

  static pw.Widget _buildSummaryRow(String label, String value,
      {PdfColor color = PdfColors.black}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label,
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        pw.Text(value,
            style: pw.TextStyle(
                fontSize: 10, fontWeight: pw.FontWeight.bold, color: color)),
      ],
    );
  }
}
