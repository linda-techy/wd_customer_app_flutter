import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../design_tokens/app_colors.dart';
import '../../../../constants.dart';
import '../../../../components/animations/hover_card.dart';
import '../../../../components/animations/fade_entry.dart';
import '../../../../components/animations/scale_button.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Data
    final totalAmount = 50000.0;
    final paidAmount = 35000.0;
    final dueAmount = 15000.0;
    final progress = paidAmount / totalAmount;

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        title: const Text("Payments & Invoices", style: TextStyle(color: blackColor)),
        backgroundColor: surfaceColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: blackColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Donut Chart / Summary Card
            FadeEntry(
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
                            value: progress,
                            color: successColor,
                            strokeWidth: 8,
                            strokeCap: StrokeCap.round,
                          ).animate().listen(duration: 1000.ms, (val) {}), // Just trigger
                          Center(
                            child: Text(
                              "${(progress * 100).toInt()}%",
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
                          _buildSummaryRow("Total Contract", "\$${totalAmount.toInt()}", Colors.white60),
                          const SizedBox(height: 12),
                          _buildSummaryRow("Paid So Far", "\$${paidAmount.toInt()}", successColor),
                          const SizedBox(height: 12),
                          _buildSummaryRow("Due Amount", "\$${dueAmount.toInt()}", errorColor),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Invoices List
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Payment History",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            _buildInvoiceItem(
              title: "Foundation Phase",
              date: "Oct 24, 2023",
              amount: "\$15,000",
              status: "PAID",
              index: 0,
            ),
            _buildInvoiceItem(
              title: "Structure Level 1",
              date: "Nov 15, 2023",
              amount: "\$20,000",
              status: "PAID",
              index: 1,
            ),
            _buildInvoiceItem(
              title: "Plumbing Rough-in",
              date: "Dec 10, 2023",
              amount: "\$15,000",
              status: "DUE",
              index: 2,
            ),
             _buildInvoiceItem(
              title: "Finishing Works",
              date: "Jan 20, 2024",
              amount: "\$10,000",
              status: "UPCOMING",
              index: 3,
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

  Widget _buildInvoiceItem({
    required String title,
    required String date,
    required String amount,
    required String status,
    required int index,
  }) {
    Color statusColor;
    IconData icon;
    
    switch (status) {
      case "PAID":
        statusColor = successColor;
        icon = Icons.check_circle;
        break;
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
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(date, style: const TextStyle(color: blackColor60, fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        status,
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
}
