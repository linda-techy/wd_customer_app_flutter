import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../models/support_models.dart';
import '../../../services/support_service.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen>
    with SingleTickerProviderStateMixin {
  static const Color _brand = primaryColor;

  late TabController _tabController;

  // ── My Tickets tab state ──────────────────────────────────────────────────
  List<SupportTicket> _tickets = [];
  bool _ticketsLoading = false;
  String? _ticketsError;
  String _statusFilter = 'ALL';

  static const List<String> _statusOptions = [
    'ALL',
    'OPEN',
    'IN_PROGRESS',
    'RESOLVED',
    'CLOSED',
  ];

  // ── New Ticket tab state ──────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  String _category = 'GENERAL';
  String _priority = 'MEDIUM';
  final _subjectCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  bool _isSubmitting = false;

  static const List<String> _categories = [
    'GENERAL',
    'BILLING',
    'PROJECT_QUALITY',
    'DOCUMENTS',
    'TECHNICAL',
    'OTHER',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTickets();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _subjectCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTickets() async {
    setState(() {
      _ticketsLoading = true;
      _ticketsError = null;
    });
    try {
      final result = await SupportService.getMyTickets();
      final content = result['content'] as List<SupportTicket>? ?? [];
      if (mounted) {
        setState(() {
          _tickets = content;
          _ticketsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _ticketsError = e.toString();
          _ticketsLoading = false;
        });
      }
    }
  }

  List<SupportTicket> get _filteredTickets {
    if (_statusFilter == 'ALL') return _tickets;
    return _tickets.where((t) => t.status == _statusFilter).toList();
  }

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final ticket = await SupportService.createTicket(
        subject: _subjectCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        category: _category,
        priority: _priority,
      );

      if (!mounted) return;

      if (ticket != null) {
        // Clear form
        _subjectCtrl.clear();
        _descriptionCtrl.clear();
        setState(() {
          _category = 'GENERAL';
          _priority = 'MEDIUM';
        });

        // Navigate to ticket detail
        Navigator.pushNamed(context, 'ticket_detail/${ticket.id}');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create ticket. Please try again.'),
            backgroundColor: errorColor,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: errorColor),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: surfaceColor,
        appBar: AppBar(
          title: const Text('Help & Support'),
          backgroundColor: _brand,
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: 'My Tickets'),
              Tab(text: 'New Ticket'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildTicketsTab(),
            _buildNewTicketTab(),
          ],
        ),
      ),
    );
  }

  // ── My Tickets Tab ────────────────────────────────────────────────────────

  Widget _buildTicketsTab() {
    return Column(
      children: [
        // Filter bar
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: defaultPadding, vertical: 8),
          child: Row(
            children: [
              const Text('Filter: ',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _statusFilter,
                    isExpanded: true,
                    items: _statusOptions
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s.replaceAll('_', ' ')),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _statusFilter = v ?? 'ALL'),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _ticketsLoading
              ? const Center(
                  child: CircularProgressIndicator(color: _brand))
              : _ticketsError != null
                  ? _buildErrorState(_ticketsError!, _loadTickets)
                  : RefreshIndicator(
                      color: _brand,
                      onRefresh: _loadTickets,
                      child: _filteredTickets.isEmpty
                          ? _buildEmptyState()
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics()),
                              padding: const EdgeInsets.all(defaultPadding),
                              itemCount: _filteredTickets.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, i) =>
                                  _buildTicketCard(_filteredTickets[i]),
                            ),
                    ),
        ),
      ],
    );
  }

  Widget _buildTicketCard(SupportTicket ticket) {
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, 'ticket_detail/${ticket.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.withOpacity(0.15)),
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
                Expanded(
                  child: Text(
                    ticket.ticketNumber.isNotEmpty
                        ? ticket.ticketNumber
                        : '#${ticket.id}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                _buildStatusBadge(ticket.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              ticket.subject,
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _brand.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    ticket.category.replaceAll('_', ' '),
                    style: const TextStyle(
                        fontSize: 11,
                        color: _brand,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatRelative(ticket.updatedAt),
                  style: const TextStyle(
                      fontSize: 11, color: blackColor60),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'OPEN':
        color = Colors.blue;
        break;
      case 'IN_PROGRESS':
        color = Colors.orange;
        break;
      case 'RESOLVED':
        color = successColor;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: const [
        SizedBox(height: 80),
        Center(
          child: Column(
            children: [
              Icon(Icons.inbox_outlined, size: 56, color: blackColor40),
              SizedBox(height: 16),
              Text(
                'No tickets yet.',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: blackColor60),
              ),
              SizedBox(height: 6),
              Text(
                'Create one to get help.',
                style: TextStyle(color: blackColor60),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: errorColor),
          const SizedBox(height: 12),
          Text(error,
              style: const TextStyle(color: blackColor60),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: _brand),
            onPressed: onRetry,
            child: const Text('Retry',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── New Ticket Tab ────────────────────────────────────────────────────────

  Widget _buildNewTicketTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(defaultPadding),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category dropdown
            DropdownButtonFormField<String>(
              value: _category,
              decoration: _inputDecoration('Category', Icons.category_outlined),
              items: _categories
                  .map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(c.replaceAll('_', ' '))))
                  .toList(),
              onChanged: (v) => setState(() => _category = v ?? 'GENERAL'),
            ),
            const SizedBox(height: 16),

            // Subject
            TextFormField(
              controller: _subjectCtrl,
              decoration: _inputDecoration('Subject *', Icons.subject_outlined),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Subject is required'
                  : null,
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionCtrl,
              maxLines: 5,
              decoration:
                  _inputDecoration('Description *', Icons.description_outlined),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Description is required'
                  : null,
            ),
            const SizedBox(height: 20),

            // Priority
            const Text('Priority',
                style:
                    TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            Row(
              children: ['LOW', 'MEDIUM', 'HIGH'].map((p) {
                return Expanded(
                  child: RadioListTile<String>(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(p,
                        style: const TextStyle(fontSize: 13)),
                    value: p,
                    groupValue: _priority,
                    activeColor: _brand,
                    onChanged: (v) =>
                        setState(() => _priority = v ?? 'MEDIUM'),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brand,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                ),
                onPressed: _isSubmitting ? null : _submitTicket,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Submit Ticket',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: _brand, size: 20),
      filled: true,
      fillColor: Theme.of(context).cardTheme.color ?? Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _brand, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _formatRelative(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inDays >= 1) return '${diff.inDays}d ago';
      if (diff.inHours >= 1) return '${diff.inHours}h ago';
      if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
      return 'Just now';
    } catch (_) {
      return '';
    }
  }
}
