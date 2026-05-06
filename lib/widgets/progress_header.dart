import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expected_handover_model.dart';
import '../models/project_models.dart';
import '../constants.dart';
import '../utils/responsive.dart';

class ProgressHeader extends StatelessWidget {
  final Project project;
  final bool showBreakdown;

  /// Optional expected-handover summary. When non-null the widget renders an
  /// extra row below the progress bar — see {@code _buildHandoverRow}.
  final ExpectedHandover? handover;

  /// Test seam for "today". Defaults to {@code DateTime.now()} so production
  /// code never needs to think about it.
  final DateTime? now;

  const ProgressHeader({
    super.key,
    required this.project,
    this.showBreakdown = true,
    this.handover,
    this.now,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveSpacing.getCardPadding(context) * 1.5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            logoRed,
            logoPink,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: logoRed.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project name and progress percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  project.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: ResponsiveFontSize.getTitle(context) + 2,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${project.progress.toInt()}%',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: ResponsiveFontSize.getTitle(context),
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Overall Progress',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Text(
                    '${project.progress.toInt()}% Complete',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: project.progress / 100,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 8,
                ),
              ),
            ],
          ),
          if (handover != null) ...[
            const SizedBox(height: 12),
            _buildHandoverRow(context),
          ],
          if (showBreakdown) ...[
            const SizedBox(height: 20),
            // Progress breakdown
            _buildProgressBreakdown(context, project.details.progressBreakdown),
          ],
        ],
      ),
    );
  }

  // ─── Expected handover row (S2 PR4) ──────────────────────────────────────

  Widget _buildHandoverRow(BuildContext context) {
    final h = handover!;
    final fmt = DateFormat('d MMM yyyy');
    final today = now ?? DateTime.now();

    // State 1 — no projectFinishDate (CPM not run / no tasks scheduled).
    if (h.projectFinishDate == null) {
      return Text(
        'Schedule not yet approved',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.85),
              fontStyle: FontStyle.italic,
            ),
      );
    }

    // State 4 — active material delay AND baseline date is earlier.
    if (h.hasMaterialDelay &&
        h.baselineFinishDate != null &&
        h.baselineFinishDate!.isBefore(h.projectFinishDate!)) {
      final baselineWeeks = _weeksBetween(today, h.baselineFinishDate!);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Expected handover: ', style: _labelStyle(context)),
              Text(
                fmt.format(h.baselineFinishDate!),
                style: _labelStyle(context)
                    .copyWith(decoration: TextDecoration.lineThrough),
              ),
              Text('  →  ', style: _labelStyle(context)),
              Text(
                fmt.format(h.projectFinishDate!),
                style: _labelStyle(context).copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '(was $baselineWeeks weeks, now ${h.weeksRemaining ?? "—"} weeks)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.85),
                ),
          ),
        ],
      );
    }

    // States 2 & 3 — on-track / minor delay: single date plus weeks.
    final weeksLabel =
        h.weeksRemaining != null ? '(in ${h.weeksRemaining} weeks)' : '';
    return Text(
      'Expected handover: ${fmt.format(h.projectFinishDate!)}  $weeksLabel'
          .trim(),
      style: _labelStyle(context),
    );
  }

  TextStyle _labelStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          );

  /// Mon-Sat working days / 5, rounded — mirrors backend WorkingDayCalculator.
  int _weeksBetween(DateTime from, DateTime to) {
    final int sign = to.isBefore(from) ? -1 : 1;
    DateTime cursor = sign > 0 ? from : to;
    final DateTime end = sign > 0 ? to : from;
    int days = 0;
    while (cursor.isBefore(end)) {
      if (cursor.weekday != DateTime.sunday) days++;
      cursor = cursor.add(const Duration(days: 1));
    }
    return (sign * days / 5.0).round();
  }

  Widget _buildProgressBreakdown(
      BuildContext context, Map<String, double> breakdown) {
    final bool isDesktop = Responsive.isDesktop(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress Breakdown',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        if (isDesktop)
          Row(
            children: breakdown.entries.map((entry) {
              return Expanded(
                child: _buildBreakdownItem(
                  context,
                  entry.key,
                  entry.value,
                ),
              );
            }).toList(),
          )
        else
          Column(
            children: breakdown.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildBreakdownItem(
                  context,
                  entry.key,
                  entry.value,
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildBreakdownItem(
      BuildContext context, String phase, double progress) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                phase,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                '${progress.toInt()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class CircularProgressHeader extends StatelessWidget {
  final Project project;
  final double size;

  const CircularProgressHeader({
    super.key,
    required this.project,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveSpacing.getCardPadding(context) * 1.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Circular progress
          SizedBox(
            width: size,
            height: size,
            child: Stack(
              children: [
                // Background circle
                const CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 8,
                  backgroundColor: Color(0xFFEEEEEE),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                ),
                // Progress circle
                CircularProgressIndicator(
                  value: project.progress / 100,
                  strokeWidth: 8,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getProgressColor(project.progress),
                  ),
                ),
                // Center text
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${project.progress.toInt()}%',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: _getProgressColor(project.progress),
                            ),
                      ),
                      Text(
                        'Complete',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Project name
          Text(
            project.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Location
          Text(
            project.location,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 30) return Colors.red;
    if (progress < 70) return Colors.orange;
    return Colors.green;
  }
}
