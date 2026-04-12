import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/customer_boq_service.dart';
import '../../../design_tokens/app_colors.dart';

class PaymentScheduleScreen extends StatefulWidget {
  final String projectId;

  const PaymentScheduleScreen({super.key, required this.projectId});

  @override
  State<PaymentScheduleScreen> createState() => _PaymentScheduleScreenState();
}

class _PaymentScheduleScreenState extends State<PaymentScheduleScreen> {
  final _currency = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
  final _pct = NumberFormat.percentPattern()..maximumFractionDigits = 1;

  CustomerBoqService? _service;
  PaymentScheduleResult? _result;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _service = await CustomerBoqService.create();
    await _load();
  }

  Future<void> _load() async {
    if (_service == null) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final result =
          await _service!.getPaymentSchedule(widget.projectId);
      if (mounted) setState(() { _result = result; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; _error = e.toString(); });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Schedule'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorView(message: _error!, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (_result != null) ...[
                        _SummaryCard(
                            result: _result!, currency: _currency),
                        const SizedBox(height: 16),
                      ],
                      if (_result == null || _result!.stages.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text(
                              'No payment schedule yet.\nThe schedule will be available once you approve the BOQ.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      else
                        ..._result!.stages.map((s) => _StageCard(
                              stage: s,
                              currency: _currency,
                              pct: _pct,
                            )),
                    ],
                  ),
                ),
    );
  }
}

// ─── Widgets ─────────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final PaymentScheduleResult result;
  final NumberFormat currency;

  const _SummaryCard({required this.result, required this.currency});

  @override
  Widget build(BuildContext context) {
    final paid = result.totalPaid;
    final total = result.totalContractValue;
    final progress = total > 0 ? (paid / total).clamp(0.0, 1.0) : 0.0;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payment Overview',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _SummaryRow('Contract Value',
                currency.format(result.totalContractValue),
                bold: true),
            _SummaryRow(
                'Total Paid', currency.format(result.totalPaid),
                color: AppColors.success),
            _SummaryRow('Outstanding',
                currency.format(result.totalOutstanding),
                color: result.totalOutstanding > 0
                    ? AppColors.error
                    : AppColors.success),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppColors.grey200,
                valueColor: AlwaysStoppedAnimation<Color>(
                    progress >= 1.0
                        ? AppColors.success
                        : AppColors.primary),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${(progress * 100).toStringAsFixed(0)}% paid '
              '(${result.stageCount} stages)',
              style: TextStyle(
                  color: AppColors.grey600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? color;

  const _SummaryRow(this.label, this.value,
      {this.bold = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: AppColors.grey600, fontSize: 13)),
          Text(value,
              style: TextStyle(
                  fontWeight:
                      bold ? FontWeight.bold : FontWeight.normal,
                  color: color,
                  fontSize: 13)),
        ],
      ),
    );
  }
}

class _StageCard extends StatelessWidget {
  final CustomerPaymentStage stage;
  final NumberFormat currency;
  final NumberFormat pct;

  const _StageCard({
    required this.stage,
    required this.currency,
    required this.pct,
  });

  Color _statusColor() {
    switch (stage.status) {
      case 'PAID':
        return AppColors.success;
      case 'INVOICED':
        return AppColors.info;
      case 'DUE':
        return AppColors.warning;
      case 'OVERDUE':
        return AppColors.error;
      case 'ON_HOLD':
        return Colors.purple;
      default:
        return AppColors.grey500;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();
    final df = DateFormat('dd MMM yyyy');
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary,
                  child: Text('${stage.stageNumber}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(stage.stageName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)),
                      if (stage.milestoneDescription != null)
                        Text(stage.milestoneDescription!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color),
                  ),
                  child: Text(stage.status,
                      style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _DetailRow('Stage %', pct.format(stage.stagePercentage)),
            _DetailRow('Amount (excl. GST)',
                currency.format(stage.stageAmountExGst)),
            _DetailRow('GST', currency.format(stage.gstAmount)),
            _DetailRow('Gross Payable',
                currency.format(stage.stageAmountInclGst),
                bold: true),
            if (stage.appliedCreditAmount > 0)
              _DetailRow('Credit Applied',
                  '- ${currency.format(stage.appliedCreditAmount)}',
                  color: AppColors.info),
            _DetailRow(
              'Net Payable',
              currency.format(stage.netPayableAmount),
              bold: true,
              color: stage.status == 'PAID' ? AppColors.success : null,
            ),
            if (stage.dueDate != null)
              _DetailRow(
                  'Due Date', df.format(stage.dueDate!)),
            if (stage.paidAt != null)
              _DetailRow('Paid On', df.format(stage.paidAt!),
                  color: AppColors.success),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? color;

  const _DetailRow(this.label, this.value,
      {this.bold = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: AppColors.grey600, fontSize: 13)),
          Text(value,
              style: TextStyle(
                  fontWeight:
                      bold ? FontWeight.bold : FontWeight.normal,
                  color: color,
                  fontSize: 13)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
}
