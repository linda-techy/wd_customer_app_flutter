import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/customer_boq_service.dart';
import '../../../design_tokens/app_colors.dart';

/// Shows the customer their full financial picture:
///   Stage payments (with retention) → Variation Orders → Deductions → Final Account
class FinancialSummaryScreen extends StatefulWidget {
  final String projectId; // UUID

  const FinancialSummaryScreen({super.key, required this.projectId});

  @override
  State<FinancialSummaryScreen> createState() => _FinancialSummaryScreenState();
}

class _FinancialSummaryScreenState extends State<FinancialSummaryScreen>
    with SingleTickerProviderStateMixin {
  final _currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
  CustomerBoqService? _service;
  late TabController _tabs;

  Map<String, dynamic>? _stages;
  Map<String, dynamic>? _variationOrders;
  Map<String, dynamic>? _deductions;
  Map<String, dynamic>? _finalAccount;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _init();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    _service = await CustomerBoqService.create();
    await _load();
  }

  Future<void> _load() async {
    if (_service == null) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final results = await Future.wait([
        _service!.getFinancialStages(widget.projectId),
        _service!.getFinancialVOs(widget.projectId),
        _service!.getFinancialDeductions(widget.projectId),
        _service!.getFinancialFinalAccount(widget.projectId),
      ]);
      if (!mounted) return;
      setState(() {
        _stages        = results[0] as Map<String, dynamic>?;
        _variationOrders = results[1] as Map<String, dynamic>?;
        _deductions    = results[2] as Map<String, dynamic>?;
        _finalAccount  = results[3] as Map<String, dynamic>?;
        _isLoading     = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Financial Summary', style: TextStyle(fontSize: 16)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Stages'),
            Tab(text: 'Var. Orders'),
            Tab(text: 'Deductions'),
            Tab(text: 'Final Account'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : TabBarView(
                  controller: _tabs,
                  children: [
                    _buildStagesTab(),
                    _buildVOsTab(),
                    _buildDeductionsTab(),
                    _buildFinalAccountTab(),
                  ],
                ),
    );
  }

  Widget _buildError() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 52, color: Colors.red),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );

  // ---- Stages tab ----

  Widget _buildStagesTab() {
    final List stages = _stages?['stages'] as List? ?? [];
    if (stages.isEmpty) {
      return const Center(child: Text('No stages found.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: stages.length,
      itemBuilder: (_, i) => _stageCard(stages[i] as Map<String, dynamic>),
    );
  }

  Widget _stageCard(Map<String, dynamic> s) {
    final status = s['status'] as String? ?? '';
    final statusColor = _stageStatusColor(status);
    final certified = s['certifiedAt'] != null;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: statusColor.withOpacity(0.15),
                  child: Text('${s['stageNumber']}',
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(s['stageName'] as String? ?? '',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                ),
                _statusChip(status, statusColor),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _amountItem('Payable',
                      _currency.format(s['netPayableAmount'] ?? 0))),
                Expanded(
                  child: _amountItem('Paid',
                      _currency.format(s['paidAmount'] ?? 0),
                      color: AppColors.success)),
                if ((s['retentionHeld'] as num?)?.toDouble() != null &&
                    (s['retentionHeld'] as num).toDouble() > 0)
                  Expanded(
                    child: _amountItem(
                        'Retention',
                        _currency.format(s['retentionHeld'] ?? 0),
                        color: AppColors.warning),
                  ),
              ],
            ),
            if (certified)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    Icon(Icons.verified_outlined,
                        size: 14, color: AppColors.success),
                    const SizedBox(width: 4),
                    Text(
                        'Certified by ${s['certifiedBy'] ?? '—'} on '
                        '${(s['certifiedAt'] as String?)?.substring(0, 10) ?? '—'}',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppColors.success)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---- VOs tab ----

  Widget _buildVOsTab() {
    final List vos = _variationOrders?['variationOrders'] as List? ?? [];
    if (vos.isEmpty) {
      return const Center(child: Text('No variation orders.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: vos.length,
      itemBuilder: (_, i) => _voCard(vos[i] as Map<String, dynamic>),
    );
  }

  Widget _voCard(Map<String, dynamic> vo) {
    final status = vo['status'] as String? ?? '';
    final ps = vo['paymentSchedule'] as Map<String, dynamic>?;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vo['referenceNumber'] as String? ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.grey)),
                      Text(vo['title'] as String? ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                    ],
                  ),
                ),
                _statusChip(status, _voStatusColor(status)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _amountItem(
                      'Amount',
                      _currency.format(
                          vo['approvedCost'] ?? vo['netAmountInclGst'] ?? 0))),
                if (vo['voCategory'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(vo['voCategory'] as String,
                        style: const TextStyle(
                            fontSize: 10,
                            color: Colors.teal,
                            fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
            if (ps != null) ...[
              const Divider(height: 16),
              _paymentScheduleRow(ps),
            ],
          ],
        ),
      ),
    );
  }

  Widget _paymentScheduleRow(Map<String, dynamic> ps) => Row(
        children: [
          Expanded(
              child: _trancheChip(
                  'Adv ${ps['advancePct']}%',
                  _currency.format(ps['advanceAmount'] ?? 0),
                  ps['advanceStatus'] as String? ?? 'PENDING')),
          const SizedBox(width: 6),
          Expanded(
              child: _trancheChip(
                  'Prg ${ps['progressPct']}%',
                  _currency.format(ps['progressAmount'] ?? 0),
                  ps['progressStatus'] as String? ?? 'PENDING')),
          const SizedBox(width: 6),
          Expanded(
              child: _trancheChip(
                  'Cmp ${ps['completionPct']}%',
                  _currency.format(ps['completionAmount'] ?? 0),
                  ps['completionStatus'] as String? ?? 'PENDING')),
        ],
      );

  Widget _trancheChip(String label, String amount, String status) {
    final color = status == 'PAID'
        ? AppColors.success
        : status == 'INVOICED'
            ? AppColors.warning
            : Colors.grey;
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: color)),
        Text(amount,
            style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ---- Deductions tab ----

  Widget _buildDeductionsTab() {
    final List deds = _deductions?['deductions'] as List? ?? [];
    final totalRequested =
        _deductions?['totalRequestedAmount'] as num? ?? 0;
    final totalAccepted =
        _deductions?['totalAcceptedAmount'] as num? ?? 0;

    return Column(
      children: [
        if (deds.isNotEmpty)
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _summaryItem('Requested',
                    _currency.format(totalRequested), Colors.orange),
                const SizedBox(width: 24),
                _summaryItem('Accepted',
                    _currency.format(totalAccepted), Colors.green),
              ],
            ),
          ),
        Expanded(
          child: deds.isEmpty
              ? const Center(child: Text('No deductions.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: deds.length,
                  itemBuilder: (_, i) =>
                      _deductionCard(deds[i] as Map<String, dynamic>),
                ),
        ),
      ],
    );
  }

  Widget _deductionCard(Map<String, dynamic> d) {
    final decision = d['decision'] as String? ?? 'PENDING';
    final decColor = _decisionColor(decision);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(d['itemDescription'] as String? ?? '',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ),
                _statusChip(decision, decColor),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _amountItem('Requested',
                    _currency.format(d['requestedAmount'] ?? 0)),
                if (d['acceptedAmount'] != null)
                  _amountItem('Accepted',
                      _currency.format(d['acceptedAmount']!),
                      color: AppColors.success),
              ],
            ),
            if (d['settledInFinalAccount'] == true)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 14, color: Colors.green),
                    SizedBox(width: 4),
                    Text('Settled in Final Account',
                        style:
                            TextStyle(fontSize: 11, color: Colors.green)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---- Final Account tab ----

  Widget _buildFinalAccountTab() {
    final fa = _finalAccount?['finalAccount'] as Map<String, dynamic>?;
    if (fa == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.account_balance_outlined,
                  size: 56, color: Colors.grey),
              SizedBox(height: 12),
              Text(
                  'Final account not yet prepared.\nYou will be notified when it is ready.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
        ),
      );
    }
    final status = fa['status'] as String? ?? '';
    final statusColor = _voStatusColor(status);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: statusColor.withOpacity(0.4)),
            ),
            child: Text(status,
                style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          ),
        ),
        const SizedBox(height: 16),
        _faCard('Contract Summary', [
          _faRow('Base Contract Value',
              _currency.format(fa['baseContractValue'] ?? 0)),
          _faRow('+ Additions',
              _currency.format(fa['totalAdditions'] ?? 0),
              color: AppColors.success),
          _faRow('− Deductions',
              _currency.format(fa['totalAcceptedDeductions'] ?? 0),
              color: AppColors.error),
          _faRow('Net Revised Value',
              _currency.format(fa['netRevisedContractValue'] ?? 0),
              bold: true),
        ]),
        const SizedBox(height: 12),
        _faCard('Payment Status', [
          _faRow('Received to Date',
              _currency.format(fa['totalReceivedToDate'] ?? 0)),
          _faRow('Retention Held',
              _currency.format(fa['totalRetentionHeld'] ?? 0),
              color: AppColors.warning),
          _faRow('Balance Payable',
              _currency.format(fa['balancePayable'] ?? 0),
              bold: true,
              color: (fa['balancePayable'] as num?)?.toDouble() == 0
                  ? AppColors.success
                  : AppColors.error),
        ]),
        const SizedBox(height: 12),
        _faCard('DLP & Retention', [
          _faRow('DLP Start', fa['dlpStartDate'] as String? ?? '—'),
          _faRow('DLP End', fa['dlpEndDate'] as String? ?? '—'),
          _faRow('Retention Released',
              fa['retentionReleased'] == true ? 'Yes' : 'No',
              color: fa['retentionReleased'] == true
                  ? AppColors.success
                  : AppColors.warning),
        ]),
      ],
    );
  }

  // ---- Helpers ----

  Widget _faCard(String title, List<Widget> rows) => Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              const Divider(height: 12),
              ...rows,
            ],
          ),
        ),
      );

  Widget _faRow(String label, String value,
      {bool bold = false, Color? color}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Expanded(
                child: Text(label,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 13))),
            Text(value,
                style: TextStyle(
                    fontWeight:
                        bold ? FontWeight.bold : FontWeight.normal,
                    color: color ?? Colors.black87,
                    fontSize: 13)),
          ],
        ),
      );

  Widget _amountItem(String label, String amount, {Color? color}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600])),
          Text(amount,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color ?? Colors.black87,
                  fontSize: 13)),
        ],
      );

  Widget _summaryItem(String label, String value, Color color) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white60, fontSize: 11)),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
        ],
      );

  Widget _statusChip(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label,
            style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600)),
      );

  Color _stageStatusColor(String status) => switch (status) {
        'PAID'     => AppColors.success,
        'INVOICED' => AppColors.warning,
        'DUE'      => AppColors.warning,
        'OVERDUE'  => AppColors.error,
        _          => Colors.grey,
      };

  Color _voStatusColor(String status) => switch (status) {
        'APPROVED'   => AppColors.success,
        'REJECTED'   => AppColors.error,
        'SUBMITTED'  => AppColors.warning,
        'AGREED'     => AppColors.success,
        'DISPUTED'   => AppColors.error,
        _            => Colors.grey,
      };

  Color _decisionColor(String decision) => switch (decision) {
        'ACCEPTABLE'           => AppColors.success,
        'PARTIALLY_ACCEPTABLE' => Colors.teal,
        'REJECTED'             => AppColors.error,
        _                      => AppColors.warning,
      };
}
