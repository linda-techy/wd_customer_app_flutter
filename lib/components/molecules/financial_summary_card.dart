import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../utils/currency_formatter.dart';

/// Three-column financial summary card: Total Contracted | Paid | Remaining.
/// Shown only to CUSTOMER and ADMIN roles. Hidden for VIEWER/SITE_ENGINEER/etc.
///
/// Usage:
/// ```dart
/// if (['CUSTOMER', 'ADMIN', 'CUSTOMER_ADMIN'].contains(userRole) &&
///     totalAmount > 0)
///   FinancialSummaryCard(
///     totalAmount: quickStats.totalAmount,
///     pendingAmount: quickStats.pendingAmount,
///   )
/// ```
class FinancialSummaryCard extends StatelessWidget {
  /// Total contracted / invoiced amount
  final double totalAmount;

  /// Remaining (unpaid) amount
  final double pendingAmount;

  const FinancialSummaryCard({
    super.key,
    required this.totalAmount,
    required this.pendingAmount,
  });

  double get _paidAmount => (totalAmount - pendingAmount).clamp(0, double.infinity);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: blackColor.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_rounded, size: 18, color: primaryColor),
              const SizedBox(width: 8),
              Text(
                'Financial Summary',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: blackColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _FinancialColumn(
                    label: 'Contracted',
                    amount: totalAmount,
                    color: primaryColor,
                    icon: Icons.receipt_long_rounded,
                  ),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: _FinancialColumn(
                    label: 'Paid',
                    amount: _paidAmount,
                    color: successColor,
                    icon: Icons.check_circle_rounded,
                  ),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: _FinancialColumn(
                    label: 'Remaining',
                    amount: pendingAmount,
                    color: pendingAmount > 0 ? Colors.orange.shade600 : successColor,
                    icon: Icons.pending_rounded,
                  ),
                ),
              ],
            ),
          ),
          if (totalAmount > 0) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: totalAmount > 0 ? (_paidAmount / totalAmount).clamp(0.0, 1.0) : 0,
                backgroundColor: blackColor10,
                valueColor: const AlwaysStoppedAnimation<Color>(successColor),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${((_paidAmount / totalAmount) * 100).clamp(0, 100).toStringAsFixed(0)}% paid',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: blackColor60),
            ),
          ],
        ],
      ),
    );
  }
}

class _FinancialColumn extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  const _FinancialColumn({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 6),
          Text(
            CurrencyFormatter.formatShort(amount),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: blackColor60),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
