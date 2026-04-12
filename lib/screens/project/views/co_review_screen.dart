import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/customer_boq_service.dart';
import '../../../design_tokens/app_colors.dart';

class CoReviewScreen extends StatefulWidget {
  final String projectId;

  const CoReviewScreen({super.key, required this.projectId});

  @override
  State<CoReviewScreen> createState() => _CoReviewScreenState();
}

class _CoReviewScreenState extends State<CoReviewScreen>
    with SingleTickerProviderStateMixin {
  final _currency = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

  CustomerBoqService? _service;
  late TabController _tabController;

  List<CustomerChangeOrder> _pending = [];
  List<CustomerChangeOrder> _all = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _init();
  }

  @override
  void dispose() {
    _tabController.dispose();
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
        _service!.getPendingReview(widget.projectId),
        _service!.getChangeOrders(widget.projectId),
      ]);
      if (mounted) {
        setState(() {
          _pending = results[0] as List<CustomerChangeOrder>;
          _all = results[1] as List<CustomerChangeOrder>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; _error = e.toString(); });
      }
    }
  }

  Future<void> _approve(CustomerChangeOrder co) async {
    final confirmed = await _showConfirmDialog(
      title: 'Approve Change Order',
      message:
          'Are you sure you want to approve "${co.title}"?\n\n'
          'This will ${co.isReduction ? "reduce" : "increase"} your project value by '
          '${_currency.format(co.netAmountInclGst)} (incl. GST).',
      confirmLabel: 'Approve',
      confirmColor: AppColors.success,
    );
    if (!confirmed) return;

    try {
      await _service!.approve(widget.projectId, co.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Change order approved')));
        _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to approve: $e')));
      }
    }
  }

  Future<void> _reject(CustomerChangeOrder co) async {
    final reason = await _showRejectDialog(co.title);
    if (reason == null) return;

    try {
      await _service!.reject(widget.projectId, co.id, reason);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Change order rejected')));
        _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to reject: $e')));
      }
    }
  }

  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: confirmColor),
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(confirmLabel),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<String?> _showRejectDialog(String coTitle) async {
    final controller = TextEditingController();
    return await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Change Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rejecting: $coTitle',
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: 'Reason for rejection *',
                border: OutlineInputBorder(),
                hintText: 'Please explain why you are rejecting this change order',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: const Text('Cancel')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              Navigator.pop(ctx, text);
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showDetail(CustomerChangeOrder co) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _CoDetailSheet(
        co: co,
        currency: _currency,
        onApprove: co.isPendingReview
            ? () { Navigator.pop(context); _approve(co); }
            : null,
        onReject: co.isPendingReview
            ? () { Navigator.pop(context); _reject(co); }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Orders'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Pending Review'),
                  if (!_isLoading && _pending.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('${_pending.length}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10)),
                    ),
                  ]
                ],
              ),
            ),
            const Tab(text: 'All'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorView(message: _error!, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _CoList(
                        cos: _pending,
                        currency: _currency,
                        emptyMessage: 'No change orders pending your review.',
                        onTap: _showDetail,
                        onApprove: _approve,
                        onReject: _reject,
                      ),
                      _CoList(
                        cos: _all,
                        currency: _currency,
                        emptyMessage: 'No change orders found.',
                        onTap: _showDetail,
                      ),
                    ],
                  ),
                ),
    );
  }
}

// ─── Widgets ─────────────────────────────────────────────────────────────────

class _CoList extends StatelessWidget {
  final List<CustomerChangeOrder> cos;
  final NumberFormat currency;
  final String emptyMessage;
  final void Function(CustomerChangeOrder) onTap;
  final void Function(CustomerChangeOrder)? onApprove;
  final void Function(CustomerChangeOrder)? onReject;

  const _CoList({
    required this.cos,
    required this.currency,
    required this.emptyMessage,
    required this.onTap,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    if (cos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(emptyMessage, textAlign: TextAlign.center),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cos.length,
      itemBuilder: (_, i) => _CoCard(
        co: cos[i],
        currency: currency,
        onTap: () => onTap(cos[i]),
        onApprove: onApprove != null ? () => onApprove!(cos[i]) : null,
        onReject: onReject != null ? () => onReject!(cos[i]) : null,
      ),
    );
  }
}

class _CoCard extends StatelessWidget {
  final CustomerChangeOrder co;
  final NumberFormat currency;
  final VoidCallback onTap;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const _CoCard({
    required this.co,
    required this.currency,
    required this.onTap,
    this.onApprove,
    this.onReject,
  });

  Color _statusColor() {
    switch (co.status) {
      case 'APPROVED':
        return AppColors.success;
      case 'COMPLETED':
      case 'CLOSED':
        return AppColors.successDark;
      case 'REJECTED':
        return AppColors.error;
      case 'CUSTOMER_REVIEW':
        return AppColors.warning;
      case 'SUBMITTED':
        return AppColors.info;
      case 'IN_PROGRESS':
        return AppColors.warning;
      default:
        return AppColors.grey500;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(co.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: color),
                    ),
                    child: Text(co.status.replaceAll('_', ' '),
                        style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(co.referenceNumber,
                  style: TextStyle(
                      color: AppColors.grey600, fontSize: 12)),
              const SizedBox(height: 6),
              Row(
                children: [
                  _TypeBadge(coType: co.coType),
                  const Spacer(),
                  Text(
                    co.isReduction
                        ? '- ${currency.format(co.netAmountInclGst)}'
                        : '+ ${currency.format(co.netAmountInclGst)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: co.isReduction
                          ? AppColors.warning
                          : AppColors.success,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              if (co.isPendingReview && onApprove != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                        ),
                        onPressed: onReject,
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success),
                        onPressed: onApprove,
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Approve'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String coType;
  const _TypeBadge({required this.coType});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.grey200,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(coType.replaceAll('_', ' '),
          style: const TextStyle(color: AppColors.grey700, fontSize: 10)),
    );
  }
}

class _CoDetailSheet extends StatelessWidget {
  final CustomerChangeOrder co;
  final NumberFormat currency;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const _CoDetailSheet({
    required this.co,
    required this.currency,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd MMM yyyy');
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (_, controller) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          controller: controller,
          children: [
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(co.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                _TypeBadge(coType: co.coType),
              ],
            ),
            const SizedBox(height: 4),
            Text(co.referenceNumber,
                style: const TextStyle(
                    color: AppColors.grey600, fontSize: 12)),
            const SizedBox(height: 16),
            if (co.description != null) ...[
              const Text('Description',
                  style: TextStyle(
                      color: AppColors.grey600,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(co.description!,
                  style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 12),
            ],
            if (co.justification != null) ...[
              const Text('Justification',
                  style: TextStyle(
                      color: AppColors.grey600,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(co.justification!,
                  style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 12),
            ],
            const Divider(),
            _DetailRow('Amount (excl. GST)',
                currency.format(co.netAmountExGst)),
            _DetailRow('GST', currency.format(co.gstAmount)),
            _DetailRow(
              co.isReduction ? 'Total Reduction' : 'Total Addition',
              (co.isReduction ? '- ' : '+ ') +
                  currency.format(co.netAmountInclGst),
              bold: true,
              color: co.isReduction ? AppColors.warning : AppColors.success,
            ),
            if (co.createdAt != null) ...[
              const Divider(),
              _DetailRow('Created', df.format(co.createdAt!)),
              if (co.submittedAt != null)
                _DetailRow('Submitted', df.format(co.submittedAt!)),
            ],
            if (co.rejectionReason != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.error.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline,
                        size: 16, color: AppColors.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Rejection reason: ${co.rejectionReason}',
                        style: const TextStyle(
                            color: AppColors.error, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            if (co.isPendingReview) ...[
              const Text(
                'Your decision on this change order will affect the project scope and value.',
                style: TextStyle(
                    color: AppColors.grey600,
                    fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (onReject != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(
                              color: AppColors.error),
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: onReject,
                        icon: const Icon(Icons.close),
                        label: const Text('Reject'),
                      ),
                    ),
                  if (onApprove != null && onReject != null)
                    const SizedBox(width: 12),
                  if (onApprove != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: onApprove,
                        icon: const Icon(Icons.check),
                        label: const Text('Approve'),
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 16),
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
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
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
