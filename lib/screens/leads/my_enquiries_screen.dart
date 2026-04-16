import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../models/lead_models.dart';
import '../../providers/lead_provider.dart';
import '../../route/route_constants.dart'; // myEnquiriesScreenRoute, leadDetailScreenRoute, newEnquiryScreenRoute

class MyEnquiriesScreen extends StatefulWidget {
  const MyEnquiriesScreen({super.key});

  @override
  State<MyEnquiriesScreen> createState() => _MyEnquiriesScreenState();
}

class _MyEnquiriesScreenState extends State<MyEnquiriesScreen> {
  static const Color _brand = Color(0xFFD84940);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LeadProvider>().fetchMyLeads();
    });
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
      case 'new_inquiry':
        return Colors.blue;
      case 'contacted':
        return Colors.orange;
      case 'qualified':
        return Colors.purple;
      case 'proposal_sent':
        return Colors.teal;
      case 'negotiation':
        return Colors.amber.shade700;
      case 'converted':
      case 'won':
        return Colors.green;
      case 'lost':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String raw) {
    if (raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Enquiries'),
        backgroundColor: _brand,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final provider = context.read<LeadProvider>();
          Navigator.pushNamed(context, newEnquiryScreenRoute)
              .then((_) => provider.fetchMyLeads());
        },
        backgroundColor: _brand,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Enquiry'),
      ),
      body: Consumer<LeadProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.leads.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFD84940)));
          }

          final leads = provider.leads;

          if (leads.isEmpty) {
            return ListView(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: _brand.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.inbox_outlined, color: _brand, size: 40),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'No enquiries yet',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Submit a new project enquiry to get started',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _brand,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            final provider = context.read<LeadProvider>();
                            Navigator.pushNamed(context, newEnquiryScreenRoute)
                                .then((_) => provider.fetchMyLeads());
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('New Project Enquiry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return RefreshIndicator(
            color: _brand,
            onRefresh: () => context.read<LeadProvider>().fetchMyLeads(),
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(defaultPadding),
              itemCount: leads.length,
              itemBuilder: (context, index) {
                final lead = leads[index];
                return _LeadCard(
                  lead: lead,
                  statusColor: _statusColor(lead.internalStatus.isNotEmpty
                      ? lead.internalStatus
                      : lead.status),
                  formattedDate: _formatDate(lead.createdAt),
                  formattedFollowUp: lead.nextFollowUp != null
                      ? _formatDate(lead.nextFollowUp!)
                      : null,
                  onTap: () {
                    final provider = context.read<LeadProvider>();
                    Navigator.pushNamed(
                      context,
                      leadDetailScreenRoute,
                      arguments: lead.id,
                    ).then((_) => provider.fetchMyLeads());
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _LeadCard extends StatelessWidget {
  const _LeadCard({
    required this.lead,
    required this.statusColor,
    required this.formattedDate,
    this.formattedFollowUp,
    required this.onTap,
  });

  final CustomerLead lead;
  final Color statusColor;
  final String formattedDate;
  final String? formattedFollowUp;
  final VoidCallback onTap;

  String get _statusLabel {
    final s = lead.internalStatus.isNotEmpty ? lead.internalStatus : lead.status;
    return s
        .split('_')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      lead.projectType.isNotEmpty ? lead.projectType : 'Project Enquiry',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      _statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (lead.district.isNotEmpty || lead.state.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 14,
                        color: Theme.of(context).textTheme.bodySmall?.color),
                    const SizedBox(width: 4),
                    Text(
                      [lead.district, lead.state]
                          .where((s) => s.isNotEmpty)
                          .join(', '),
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 13,
                      color: Theme.of(context).textTheme.bodySmall?.color),
                  const SizedBox(width: 4),
                  Text(
                    'Submitted: $formattedDate',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  if (formattedFollowUp != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.event_outlined, size: 13, color: Colors.blue.shade400),
                    const SizedBox(width: 4),
                    Text(
                      'Follow-up: $formattedFollowUp',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'View details',
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFFD84940),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFFD84940)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
