import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../report_service.dart';
import '../../utils/currency_formatter.dart';

/// Generates a Financial Summary PDF covering stage payments, variation orders,
/// deductions, and totals — sourced from the raw API maps used by FinancialSummaryScreen.
class FinancialSummaryReport {
  FinancialSummaryReport._();

  static Future<void> generate({
    required String projectName,
    required Map<String, dynamic>? stages,
    required Map<String, dynamic>? variationOrders,
    required Map<String, dynamic>? deductions,
    required Map<String, dynamic>? finalAccount,
  }) async {
    final doc = ReportService.createDocument();

    doc.addPage(
      pw.MultiPage(
        pageFormat: ReportService.portraitFormat,
        header: (context) => ReportService.buildHeader(
          'Financial Summary',
          projectName: projectName,
        ),
        footer: ReportService.buildFooter,
        build: (context) => [
          // ── Payment Stages ───────────────────────────────────────────────
          if (stages != null) ...[
            _sectionTitle('Payment Stages'),
            pw.SizedBox(height: 4),
            _buildStagesTable(stages),
            pw.SizedBox(height: 12),
          ],

          // ── Variation Orders ─────────────────────────────────────────────
          if (variationOrders != null) ...[
            _sectionTitle('Variation Orders'),
            pw.SizedBox(height: 4),
            _buildVOTable(variationOrders),
            pw.SizedBox(height: 12),
          ],

          // ── Deductions ───────────────────────────────────────────────────
          if (deductions != null) ...[
            _sectionTitle('Deductions'),
            pw.SizedBox(height: 4),
            _buildDeductionsTable(deductions),
            pw.SizedBox(height: 12),
          ],

          // ── Final Account Summary ────────────────────────────────────────
          if (finalAccount != null) ...[
            _sectionTitle('Final Account Summary'),
            pw.SizedBox(height: 4),
            _buildFinalAccountTable(finalAccount),
          ],
        ],
      ),
    );

    await ReportService.sharePdf(doc, 'financial_summary.pdf');
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

  // ── Stages table ───────────────────────────────────────────────────────────

  static pw.Widget _buildStagesTable(Map<String, dynamic> data) {
    final List<dynamic> items = data['stages'] as List? ?? [];
    if (items.isEmpty) {
      return pw.Text('No stage data available.',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600));
    }

    return ReportService.buildTable(
      headers: ['Stage', 'Gross Amount', 'Retention', 'Net Amount', 'Status'],
      rows: items.map<List<String>>((s) {
        final m = s as Map<String, dynamic>;
        return [
          m['stageName']?.toString() ?? m['description']?.toString() ?? '-',
          _fmt(m['grossAmount'] ?? m['amount']),
          _fmt(m['retentionAmount'] ?? m['retention']),
          _fmt(m['netAmount'] ?? m['net']),
          m['status']?.toString() ?? '-',
        ];
      }).toList(),
      columnAlignments: [
        pw.Alignment.centerLeft,
        pw.Alignment.centerRight,
        pw.Alignment.centerRight,
        pw.Alignment.centerRight,
        pw.Alignment.center,
      ],
    );
  }

  // ── Variation Orders table ─────────────────────────────────────────────────

  static pw.Widget _buildVOTable(Map<String, dynamic> data) {
    final List<dynamic> items = data['variationOrders'] as List?
        ?? data['items'] as List?
        ?? [];
    if (items.isEmpty) {
      return pw.Text('No variation orders.',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600));
    }

    return ReportService.buildTable(
      headers: ['VO No.', 'Description', 'Amount', 'Status'],
      rows: items.map<List<String>>((vo) {
        final m = vo as Map<String, dynamic>;
        return [
          m['voNumber']?.toString() ?? m['number']?.toString() ?? '-',
          m['description']?.toString() ?? '-',
          _fmt(m['amount'] ?? m['value']),
          m['status']?.toString() ?? '-',
        ];
      }).toList(),
      columnAlignments: [
        pw.Alignment.center,
        pw.Alignment.centerLeft,
        pw.Alignment.centerRight,
        pw.Alignment.center,
      ],
    );
  }

  // ── Deductions table ───────────────────────────────────────────────────────

  static pw.Widget _buildDeductionsTable(Map<String, dynamic> data) {
    final List<dynamic> items = data['deductions'] as List?
        ?? data['items'] as List?
        ?? [];
    if (items.isEmpty) {
      return pw.Text('No deductions recorded.',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600));
    }

    return ReportService.buildTable(
      headers: ['Type', 'Description', 'Amount', 'Date'],
      rows: items.map<List<String>>((d) {
        final m = d as Map<String, dynamic>;
        return [
          m['deductionType']?.toString() ?? m['type']?.toString() ?? '-',
          m['description']?.toString() ?? '-',
          _fmt(m['amount']),
          m['date']?.toString() ?? '-',
        ];
      }).toList(),
      columnAlignments: [
        pw.Alignment.center,
        pw.Alignment.centerLeft,
        pw.Alignment.centerRight,
        pw.Alignment.center,
      ],
    );
  }

  // ── Final Account table ────────────────────────────────────────────────────

  static pw.Widget _buildFinalAccountTable(Map<String, dynamic> data) {
    final rows = <List<String>>[];

    void addRow(String label, dynamic value) {
      rows.add([label, _fmt(value)]);
    }

    // Try to extract meaningful summary fields
    (data).forEach((key, value) {
      if (value is num) {
        final label = _camelToLabel(key);
        rows.add([label, CurrencyFormatter.format(value.toDouble())]);
      }
    });

    if (rows.isEmpty) {
      return pw.Text('Final account data not available.',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600));
    }

    return ReportService.buildTable(
      headers: ['Description', 'Amount'],
      rows: rows,
      columnAlignments: [
        pw.Alignment.centerLeft,
        pw.Alignment.centerRight,
      ],
    );
  }

  static String _fmt(dynamic value) {
    if (value == null) return '-';
    final d = (value as num?)?.toDouble() ?? 0.0;
    return CurrencyFormatter.format(d);
  }

  static String _camelToLabel(String camel) {
    final result = camel.replaceAllMapped(
        RegExp(r'[A-Z]'), (m) => ' ${m.group(0)}');
    return result[0].toUpperCase() + result.substring(1);
  }
}
