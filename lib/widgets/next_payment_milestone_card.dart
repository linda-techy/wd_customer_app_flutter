import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/next_payment_milestone.dart';
import '../route/route_constants.dart';
import '../utils/currency_formatter.dart';

/// Surfaces the customer's single next-due payment stage on the project-detail
/// screen, between the [ProgressHeader] and the phase stepper.
///
/// Behaviour:
/// - `milestone == null` (service fetch failed)  → renders [SizedBox.shrink]
/// - `milestone.stage == null` (all stages PAID/ON_HOLD) → renders [SizedBox.shrink]
/// - otherwise renders a tappable [Card] that pushes [paymentsScreenRoute] on tap.
class NextPaymentMilestoneCard extends StatelessWidget {
  const NextPaymentMilestoneCard({super.key, required this.milestone});

  final NextPaymentMilestone? milestone;

  static final DateFormat _dueDateFormat = DateFormat('d MMM yyyy', 'en_IN');

  @override
  Widget build(BuildContext context) {
    final stage = milestone?.stage;
    if (stage == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final pill = _statusPillStyle(stage.status);

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.pushNamed(context, paymentsScreenRoute),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: status pill + sequence label
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: pill.bg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      stage.status,
                      style: TextStyle(
                        color: pill.fg,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Stage ${stage.stageNumber} of ${stage.totalStages}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                stage.stageName,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // Amount + % line
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    CurrencyFormatter.formatCompact(stage.netPayableAmount),
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '\u00B7 ${stage.percentOfContract.toStringAsFixed(1)}% of contract',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Bottom row: countdown + chevron
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _countdownText(stage),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: pill.fg,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _countdownText(NextPaymentStage stage) {
    final days = stage.daysUntilDue;
    if (days == null) return 'Due date pending';
    if (days == 0) return 'Due today';
    if (days > 0) {
      // Within "Due in N days" up to a couple of weeks; for further-out
      // stages fall back to the formatted absolute date so customers
      // see "Due on 15 May 2026" rather than "Due in 47 days".
      if (days <= 14) return 'Due in $days day${days == 1 ? '' : 's'}';
      if (stage.dueDate != null) return 'Due on ${_dueDateFormat.format(stage.dueDate!)}';
      return 'Due in $days days';
    }
    final overdueBy = -days;
    return 'Overdue by $overdueBy day${overdueBy == 1 ? '' : 's'}';
  }

  _PillStyle _statusPillStyle(String status) {
    switch (status) {
      case 'OVERDUE':
        return const _PillStyle(bg: Color(0xFFFFEBEE), fg: Color(0xFFC62828));
      case 'DUE':
        return const _PillStyle(bg: Color(0xFFFFF3E0), fg: Color(0xFFE65100));
      case 'INVOICED':
        return const _PillStyle(bg: Color(0xFFE3F2FD), fg: Color(0xFF1565C0));
      case 'UPCOMING':
      default:
        return const _PillStyle(bg: Color(0xFFEEEEEE), fg: Color(0xFF424242));
    }
  }
}

class _PillStyle {
  const _PillStyle({required this.bg, required this.fg});
  final Color bg;
  final Color fg;
}
