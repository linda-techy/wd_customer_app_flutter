import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../constants.dart';
import '../../../../components/animations/hover_card.dart';
import '../../../../components/animations/fade_entry.dart';
import '../../../../services/payment_service.dart';
import '../../../../models/payment_models.dart';
import 'package:intl/intl.dart';

class PaymentsScreen extends StatefulWidget {
  final int? projectId;       // DB id for payment schedule queries
  final String? projectUuid;  // UUID for invoice queries

  const PaymentsScreen({super.key, this.projectId, this.projectUuid});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PaymentService _paymentService = PaymentService();
  bool _isLoading = true;
  String? _errorMessage;
  List<PaymentSchedule> _schedules = [];
  List<CustomerInvoice> _invoices = [];
  PaymentSummary? _summary;

  @override
  void initState() {
    super.initState();
    // Show invoices tab only when a project UUID is available
    _tabController = TabController(
      length: widget.projectUuid != null ? 2 : 1,
      vsync: this,
    );
    _loadPayments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPayments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load schedules and invoices concurrently
      final futures = <Future>[
        _paymentService.getCustomerPayments(projectId: widget.projectId),
        if (widget.projectUuid != null)
          _paymentService.getProjectInvoices(projectUuid: widget.projectUuid!),
      ];
      final results = await Future.wait(futures);

      final schedules = results[0] as List<PaymentSchedule>;
      final invoices = widget.projectUuid != null
          ? results[1] as List<CustomerInvoice>
          : <CustomerInvoice>[];

      setState(() {
        _schedules = schedules;
        _invoices = invoices;
        _summary = _paymentService.calculateSummary(schedules);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load payments: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasTabs = widget.projectUuid != null;
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        title: Text(
          widget.projectId != null ? "Project Payments" : "Payments & Invoices",
          style: const TextStyle(color: blackColor),
        ),
        backgroundColor: surfaceColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: blackColor),
        bottom: hasTabs
            ? TabBar(
                controller: _tabController,
                labelColor: primaryColor,
                unselectedLabelColor: blackColor60,
                indicatorColor: primaryColor,
                indicatorWeight: 3,
                tabs: const [
                  Tab(icon: Icon(Icons.schedule_rounded, size: 18), text: 'Schedule'),
                  Tab(icon: Icon(Icons.receipt_long_rounded, size: 18), text: 'Invoices'),
                ],
              )
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 60, color: errorColor),
                      const SizedBox(height: 16),
                      Text(_errorMessage!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPayments,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : hasTabs
                  ? TabBarView(
                      controller: _tabController,
                      children: [
                        _buildScheduleTab(),
                        _buildInvoicesTab(),
                      ],
                    )
                  : _buildScheduleTab(),
    );
  }

  Widget _buildScheduleTab() {
    return _schedules.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined, size: 60, color: blackColor40),
                SizedBox(height: 16),
                Text('No payment schedules found'),
              ],
            ),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Summary Card
                if (_summary != null) _buildSummaryCard(_summary!),
                const SizedBox(height: 32),

                // Payment History
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Payment Schedule",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 16),

                // Payment Items
                ..._schedules.asMap().entries.map((entry) {
                  return _buildPaymentItem(entry.value, entry.key);
                }),
              ],
            ),
          );
  }

  Widget _buildInvoicesTab() {
    if (_invoices.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_outlined, size: 60, color: blackColor40),
            SizedBox(height: 16),
            Text('No invoices found', style: TextStyle(color: blackColor60)),
            SizedBox(height: 8),
            Text('Invoices will appear here once issued by your project team.',
                textAlign: TextAlign.center,
                style: TextStyle(color: blackColor40, fontSize: 13)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _invoices.length,
      itemBuilder: (context, index) => _buildInvoiceItem(_invoices[index], index),
    );
  }

  Widget _buildInvoiceItem(CustomerInvoice invoice, int index) {
    final Color statusColor = invoice.isPaid
        ? successColor
        : invoice.isOverdue
            ? errorColor
            : invoice.isCancelled
                ? blackColor40
                : primaryColor;
    final String statusLabel = invoice.isPaid
        ? 'PAID'
        : invoice.isOverdue
            ? 'OVERDUE'
            : invoice.isCancelled
                ? 'CANCELLED'
                : 'ISSUED';

    return FadeEntry(
      delay: Duration(milliseconds: 100 * index),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: HoverCard(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: blackColor.withOpacity(0.05)),
              boxShadow: [
                BoxShadow(
                  color: blackColor.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.receipt_long_rounded, color: statusColor, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(invoice.invoiceNumber,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(
                        invoice.dueDate != null
                            ? 'Due: ${DateFormat('MMM dd, yyyy').format(invoice.dueDate!)}'
                            : 'Date: ${DateFormat('MMM dd, yyyy').format(invoice.invoiceDate)}',
                        style: const TextStyle(color: blackColor60, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('₹${_formatAmount(invoice.totalAmount)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(statusLabel,
                          style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(PaymentSummary summary) {
    return FadeEntry(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [blackColor, Color(0xFF2C2C35)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: blackColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            // Donut Chart
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: 1.0,
                    color: Colors.white.withOpacity(0.1),
                    strokeWidth: 8,
                  ),
                  CircularProgressIndicator(
                    value: summary.progress,
                    color: successColor,
                    strokeWidth: 8,
                    strokeCap: StrokeCap.round,
                  ).animate().scale(),
                  Center(
                    child: Text(
                      "${(summary.progress * 100).toInt()}%",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            // Stats
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryRow("Total Contract", "₹${_formatAmount(summary.totalAmount)}", Colors.white60),
                  const SizedBox(height: 12),
                  _buildSummaryRow("Paid So Far", "₹${_formatAmount(summary.paidAmount)}", successColor),
                  const SizedBox(height: 12),
                  _buildSummaryRow("Due Amount", "₹${_formatAmount(summary.dueAmount)}", errorColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildPaymentItem(PaymentSchedule schedule, int index) {
    Color statusColor;
    IconData icon;
    
    switch (schedule.status) {
      case "PAID":
        statusColor = successColor;
        icon = Icons.check_circle;
        break;
      case "OVERDUE":
      case "DUE":
        statusColor = errorColor;
        icon = Icons.warning_amber_rounded;
        break;
      default:
        statusColor = blackColor40;
        icon = Icons.schedule;
    }

    return FadeEntry(
      delay: (200 * index).ms,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: HoverCard(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: blackColor.withOpacity(0.05)),
              boxShadow: [
                BoxShadow(
                  color: blackColor.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: statusColor, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(schedule.description, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(
                        schedule.dueDate != null ? _formatDate(schedule.dueDate!) : 'No due date',
                        style: const TextStyle(color: blackColor60, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("₹${_formatAmount(schedule.amount)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        schedule.status,
                        style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    final formatter = NumberFormat("#,##,##0.00", "en_IN");
    return formatter.format(amount);
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
