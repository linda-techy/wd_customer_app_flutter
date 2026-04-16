import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/lead_models.dart';
import '../../providers/lead_provider.dart';

class EnquiryDetailScreen extends StatefulWidget {
  const EnquiryDetailScreen({super.key, required this.leadId});

  final int leadId;

  @override
  State<EnquiryDetailScreen> createState() => _EnquiryDetailScreenState();
}

class _EnquiryDetailScreenState extends State<EnquiryDetailScreen> {
  static const Color _brand = Color(0xFFD84940);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LeadProvider>().fetchLeadDetail(widget.leadId);
    });
  }

  String _formatDate(String raw) {
    if (raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw);
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dt.day} ${months[dt.month]} ${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Enquiry Details'),
        backgroundColor: _brand,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<LeadProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.selectedLead == null) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFD84940)));
          }

          final lead = provider.selectedLead;
          if (lead == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: _brand, size: 48),
                  const SizedBox(height: 12),
                  const Text('Could not load enquiry details.'),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.read<LeadProvider>().fetchLeadDetail(widget.leadId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Status stepper ────────────────────────────────────────
                _StatusStepper(
                  steps: CustomerLead.statusSteps,
                  currentStep: lead.statusStepIndex,
                ),
                const SizedBox(height: 20),

                // ── Project detail card ───────────────────────────────────
                _SectionCard(
                  title: 'Project Details',
                  icon: Icons.home_work_outlined,
                  children: [
                    if (lead.projectType.isNotEmpty)
                      _DetailRow(label: 'Project Type', value: lead.projectType),
                    if (lead.budget.isNotEmpty)
                      _DetailRow(label: 'Budget', value: lead.budget),
                    if (lead.area.isNotEmpty)
                      _DetailRow(label: 'Area', value: '${lead.area} sqft'),
                    if (lead.location.isNotEmpty)
                      _DetailRow(label: 'Location', value: lead.location),
                    if (lead.district.isNotEmpty)
                      _DetailRow(label: 'District', value: lead.district),
                    if (lead.state.isNotEmpty)
                      _DetailRow(label: 'State', value: lead.state),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Timeline card ─────────────────────────────────────────
                _SectionCard(
                  title: 'Timeline',
                  icon: Icons.schedule_outlined,
                  children: [
                    _DetailRow(label: 'Submitted', value: _formatDate(lead.createdAt)),
                    if (lead.nextFollowUp != null && lead.nextFollowUp!.isNotEmpty)
                      _DetailRow(
                        label: 'Next Follow-up',
                        value: _formatDate(lead.nextFollowUp!),
                        valueColor: Colors.blue.shade700,
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Status card ───────────────────────────────────────────
                _SectionCard(
                  title: 'Status',
                  icon: Icons.info_outline,
                  children: [
                    _DetailRow(label: 'Current Status', value: lead.status),
                    if (lead.source.isNotEmpty)
                      _DetailRow(label: 'Source', value: lead.source),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Status stepper widget ─────────────────────────────────────────────────────

class _StatusStepper extends StatelessWidget {
  const _StatusStepper({required this.steps, required this.currentStep});

  final List<String> steps;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enquiry Progress',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 16),
          // Circles row
          Row(
            children: List.generate(steps.length, (i) {
              final isDone = i < currentStep;
              final isCurrent = i == currentStep;

              Color circleColor;
              if (isDone) {
                circleColor = Colors.green;
              } else if (isCurrent) {
                circleColor = const Color(0xFFD84940);
              } else {
                circleColor = Colors.grey.shade300;
              }

              return Expanded(
                child: Row(
                  children: [
                    // Circle
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: circleColor,
                        border: isCurrent
                            ? Border.all(color: const Color(0xFFD84940), width: 2)
                            : null,
                      ),
                      child: Center(
                        child: isDone
                            ? const Icon(Icons.check, color: Colors.white, size: 14)
                            : Text(
                                '${i + 1}',
                                style: TextStyle(
                                  color: isCurrent ? Colors.white : Colors.grey.shade600,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    // Connector line (not after last)
                    if (i < steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: i < currentStep
                              ? Colors.green
                              : Colors.grey.shade300,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          // Labels row
          Row(
            children: List.generate(steps.length, (i) {
              final isCurrent = i == currentStep;
              return Expanded(
                child: Text(
                  steps[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCurrent
                        ? const Color(0xFFD84940)
                        : i < currentStep
                            ? Colors.green
                            : Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFD84940), size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
