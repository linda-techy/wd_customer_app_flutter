import 'dart:math';
import 'package:flutter/material.dart';
import '../../../models/project_module_models.dart';
import '../../../services/project_module_service.dart';
import '../../../services/auth_service.dart';
import '../../../config/api_config.dart';

class BoqScreen extends StatefulWidget {
  final String projectId;
  const BoqScreen({super.key, required this.projectId});
  @override
  State<BoqScreen> createState() => _BoqScreenState();
}

class _BoqScreenState extends State<BoqScreen> {
  static const _boqAllowedRoles = ['CUSTOMER', 'ADMIN', 'CUSTOMER_ADMIN', 'ARCHITECT', 'INTERIOR_DESIGNER'];
  static const _primaryColor = Color(0xFFD32F2F);

  ProjectModuleService? _service;
  List<BoqItem> _items = [];
  BoqSummary? _summary; // backend-provided summary (CUSTOMER/CUSTOMER_ADMIN only)
  bool _isLoading = true;
  String? _error;
  String? _selectedStatus;
  final Set<String> _expandedGroups = {};
  bool _detailMode = false;

  // Approval state
  String _approvalStatus = 'PENDING'; // PENDING | APPROVED | CHANGE_REQUESTED
  bool _submittingApproval = false;
  bool _canSubmitApproval = false; // only CUSTOMER / CUSTOMER_ADMIN

  @override
  void initState() {
    super.initState();
    _initService();
  }

  Future<void> _initService() async {
    final userInfo = await AuthService.getUserInfo();
    final role = userInfo?.role ?? 'VIEWER';
    if (!_boqAllowedRoles.contains(role)) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('BoQ is not available for your role')),
        );
      }
      return;
    }
    _canSubmitApproval =
        role == 'CUSTOMER' || role == 'CUSTOMER_ADMIN';
    final token = await AuthService.getAccessToken();
    _service = ProjectModuleService(baseUrl: ApiConfig.baseUrl, token: token);
    _loadData();
  }

  Future<void> _loadData() async {
    if (_service == null) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _service!.getBoqItems(widget.projectId),
        if (_canSubmitApproval) _service!.getBoqSummary(widget.projectId),
        if (_canSubmitApproval) _service!.getBoqApprovalStatus(widget.projectId),
      ]);
      final items = results[0] as List<BoqItem>;
      BoqSummary? summary;
      if (_canSubmitApproval && results.length > 1) {
        summary = results[1] as BoqSummary;
        final approvalData = results[2] as Map<String, String>;
        _approvalStatus = approvalData['status'] ?? 'PENDING';
      }
      setState(() {
        _items = items;
        _summary = summary;
        _expandedGroups.clear();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<BoqItem> get _filteredItems {
    if (_selectedStatus == null) return _items;
    return _items
        .where((item) =>
            item.status?.toUpperCase() == _selectedStatus!.toUpperCase())
        .toList();
  }

  /// Base-scope items only (BASE / EXCLUSION grouping)
  Map<String, List<BoqItem>> get _groupedBaseItems {
    final map = <String, List<BoqItem>>{};
    for (final item in _filteredItems.where((i) => !i.isAddon && !i.isExclusion)) {
      final key = item.workTypeName.isNotEmpty
          ? item.workTypeName
          : (item.categoryName ?? 'General Work');
      map.putIfAbsent(key, () => []).add(item);
    }
    return map;
  }

  /// Add-on / optional items only
  List<BoqItem> get _addonItems =>
      _filteredItems.where((i) => i.isAddon).toList();


  // Total project cost across all items (not filtered) — for sticky bar + distribution.
  // Uses backend-provided summary when available (avoids double-precision accumulation).
  double get _totalAllItems =>
      _summary?.totalPlannedAmount ?? _items.fold<double>(0, (s, i) => s + i.amount);

  String _formatCurrency(double amount) {
    if (amount >= 10000000) return '₹${(amount / 10000000).toStringAsFixed(2)} Cr';
    if (amount >= 100000) return '₹${(amount / 100000).toStringAsFixed(2)} L';
    if (amount >= 1000) return '₹${(amount / 1000).toStringAsFixed(1)}K';
    return '₹${amount.toStringAsFixed(0)}';
  }

  String _formatQuantity(double qty, String unit) {
    final qtyStr = qty == qty.truncateToDouble()
        ? qty.toInt().toString()
        : qty.toStringAsFixed(2);
    return unit.isEmpty || RegExp(r'^\d+$').hasMatch(unit)
        ? qtyStr
        : '$qtyStr $unit';
  }

  // ── Approval actions ──────────────────────────────────────────────────────

  Future<void> _showApproveDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Approve BOQ'),
        content: const Text(
            'By approving, you confirm that you have reviewed the Bill of Quantities '
            'and agree to proceed with the listed scope and costs.\n\n'
            'This does not constitute a payment commitment.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Approve', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _submitApproval('APPROVED', null);
    }
  }

  Future<void> _showRequestChangesDialog() async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Request Changes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Describe the changes you would like made to the BOQ:'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'e.g. Please upgrade tiles in master bedroom to premium grade',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              Navigator.pop(ctx, true);
            },
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true && controller.text.trim().isNotEmpty) {
      await _submitApproval('CHANGE_REQUESTED', controller.text.trim());
    }
  }

  Future<void> _submitApproval(String status, String? message) async {
    if (_service == null) return;
    setState(() => _submittingApproval = true);
    try {
      await _service!.submitBoqApproval(widget.projectId,
          status: status, message: message);
      setState(() => _approvalStatus = status);
      if (mounted) {
        final isApproved = status == 'APPROVED';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isApproved
              ? 'BOQ approved successfully'
              : 'Change request submitted'),
          backgroundColor: isApproved ? Colors.green : _primaryColor,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to submit: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _submittingApproval = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Use backend-provided summary for financial roles; fall back to fold for others.
    final totalPlanned = _summary?.totalPlannedAmount ??
        _filteredItems.fold<double>(0, (s, i) => s + i.amount);
    final totalExecuted = _summary?.totalExecutedAmount ??
        _filteredItems.fold<double>(0, (s, i) => s + i.totalExecutedAmount);
    final totalBilled = _summary?.totalBilledAmount ??
        _filteredItems.fold<double>(0, (s, i) => s + i.totalBilledAmount);
    final overallExecPct = _summary?.executionPercentage ??
        (totalPlanned > 0 ? (totalExecuted / totalPlanned * 100) : 0.0);
    final overallBillPct = _summary?.billingPercentage ??
        (totalExecuted > 0 ? (totalBilled / totalExecuted * 100) : 0.0);
    final costToComplete = _summary?.costToComplete ?? (totalPlanned - totalExecuted);
    final itemCount = _summary?.totalItems ?? _filteredItems.length;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      bottomNavigationBar: _buildStickyBar(),
      appBar: AppBar(
        title: const Text('Bill of Quantities'),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                          onPressed: _loadData, child: const Text('Retry')),
                    ],
                  ),
                )
              : _items.isEmpty
                  ? const Center(
                      child: Text('No BoQ items available',
                          style: TextStyle(color: Colors.grey)))
                  : Column(
                      children: [
                        _buildSummaryCard(
                          itemCount: itemCount,
                          totalPlanned: totalPlanned,
                          totalExecuted: totalExecuted,
                          totalBilled: totalBilled,
                          overallExecPct: overallExecPct,
                          overallBillPct: overallBillPct,
                          costToComplete: costToComplete,
                        ),
                        _buildFilterRow(),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: _loadData,
                            child: _filteredItems.isEmpty
                                ? const Center(
                                    child: Text('No items for selected filter',
                                        style: TextStyle(color: Colors.grey)))
                                : _buildGroupedList(),
                          ),
                        ),
                      ],
                    ),
    );
  }

  // ── Summary Card ──────────────────────────────────────────────────────────

  Widget _buildSummaryCard({
    required int itemCount,
    required double totalPlanned,
    required double totalExecuted,
    required double totalBilled,
    required double overallExecPct,
    required double overallBillPct,
    required double costToComplete,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryColor, _primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Project Budget Overview',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildSummaryRow('Planned Budget', _formatCurrency(totalPlanned), Colors.white),
          const SizedBox(height: 6),
          _buildSummaryRow('Work Executed', _formatCurrency(totalExecuted), Colors.orangeAccent),
          const SizedBox(height: 3),
          _buildSummaryProgressBar(overallExecPct, Colors.orange),
          const SizedBox(height: 8),
          _buildSummaryRow('Amount Billed', _formatCurrency(totalBilled), Colors.greenAccent),
          const SizedBox(height: 3),
          _buildSummaryProgressBar(overallBillPct, Colors.green),
          if (totalExecuted > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(
                'Cost to Complete', _formatCurrency(costToComplete), Colors.amberAccent),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: color.withOpacity(0.9), fontSize: 12)),
        Text(amount,
            style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildSummaryProgressBar(double percentage, Color color) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('${percentage.toStringAsFixed(1)}%',
            style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }

  // ── Filter Row ────────────────────────────────────────────────────────────

  Widget _buildFilterRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', _selectedStatus == null,
                () => setState(() => _selectedStatus = null)),
            _buildFilterChip('Confirmed', _selectedStatus == 'APPROVED',
                () => setState(() => _selectedStatus = 'APPROVED')),
            _buildFilterChip('In Progress', _selectedStatus == 'LOCKED',
                () => setState(() => _selectedStatus = 'LOCKED')),
            _buildFilterChip('Completed', _selectedStatus == 'COMPLETED',
                () => setState(() => _selectedStatus = 'COMPLETED')),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              icon: Icon(
                  _detailMode ? Icons.visibility_off_outlined : Icons.list_alt_outlined,
                  size: 14),
              label: Text(_detailMode ? 'Standard' : 'Detailed',
                  style: const TextStyle(fontSize: 11)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                side: BorderSide(color: Colors.grey.shade400),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => setState(() => _detailMode = !_detailMode),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: _primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
      ),
    );
  }

  // ── Grouped Expandable List ───────────────────────────────────────────────

  Widget _buildGroupedList() {
    final grouped = _groupedBaseItems;
    final addons = _addonItems;
    final totalCost = _totalAllItems;

    // Find subtotal of most expensive base group for highlighting
    final maxSubtotal = grouped.values
        .map((g) => g.fold<double>(0, (s, i) => s + i.amount))
        .fold(0.0, max);

    final List<Widget> rows = [];

    // ── Base scope groups ──────────────────────────────────────────────────
    for (final entry in grouped.entries) {
      final subtotal = entry.value.fold<double>(0, (s, i) => s + i.amount);
      rows.add(_buildGroupHeader(
        entry.key,
        entry.value,
        subtotal: subtotal,
        totalCost: totalCost,
        isTopSection: subtotal > 0 && subtotal == maxSubtotal,
      ));
      if (_expandedGroups.contains(entry.key)) {
        for (final item in entry.value) {
          rows.add(_buildItemCard(item));
        }
      }
    }

    // ── Add-ons / optional upgrades section ───────────────────────────────
    if (addons.isNotEmpty) {
      const addonKey = '__addons__';
      final addonSubtotal = addons.fold<double>(0, (s, i) => s + i.amount);
      rows.add(const SizedBox(height: 8));
      rows.add(_buildAddonSectionHeader(addonSubtotal, addonKey));
      if (_expandedGroups.contains(addonKey)) {
        for (final item in addons) {
          rows.add(_buildItemCard(item));
        }
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      children: rows,
    );
  }

  Widget _buildAddonSectionHeader(double subtotal, String key) {
    final isExpanded = _expandedGroups.contains(key);
    return GestureDetector(
      onTap: () => setState(() {
        if (isExpanded) {
          _expandedGroups.remove(key);
        } else {
          _expandedGroups.add(key);
        }
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6, top: 4),
        decoration: BoxDecoration(
          color: Colors.purple.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.purple.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                color: Colors.purple.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Icon(Icons.add_circle_outline, size: 16, color: Colors.purple.shade600),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Optional Add-ons & Upgrades',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.purple.shade700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.purple.shade300),
                ),
                child: Text(
                  '+${_formatCurrency(subtotal)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupHeader(String groupName, List<BoqItem> items,
      {required double subtotal,
      required double totalCost,
      required bool isTopSection}) {
    final isExpanded = _expandedGroups.contains(groupName);
    final count = items.length;
    final sectionPct = totalCost > 0 ? subtotal / totalCost : 0.0;
    final barColor = isTopSection ? Colors.amber.shade600 : _primaryColor;

    return GestureDetector(
      onTap: () => setState(() {
        if (isExpanded) {
          _expandedGroups.remove(groupName);
        } else {
          _expandedGroups.add(groupName);
        }
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6, top: 4),
        decoration: BoxDecoration(
          color: isTopSection
              ? Colors.amber.shade50
              : _primaryColor.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: isTopSection
                  ? Colors.amber.shade300
                  : _primaryColor.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_right,
                    color: barColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(groupName,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: barColor)),
                        ),
                        if (isTopSection)
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.amber.shade400),
                            ),
                            child: Text('Largest',
                                style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber.shade800)),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(_formatCurrency(subtotal),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: barColor)),
                      Text('$count ${count == 1 ? 'item' : 'items'}',
                          style: TextStyle(
                              fontSize: 10, color: Colors.grey.shade600)),
                    ],
                  ),
                ],
              ),
            ),
            // Cost distribution bar + %
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: sectionPct.clamp(0.0, 1.0),
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            barColor.withOpacity(0.6)),
                        minHeight: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('${(sectionPct * 100).toStringAsFixed(0)}% of total',
                      style: TextStyle(
                          fontSize: 9, color: Colors.grey.shade500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Item Card ─────────────────────────────────────────────────────────────

  Widget _buildItemCard(BoqItem item) {
    final s = item.status?.toUpperCase() ?? '';
    final showProgress = item.executedQuantity > 0 ||
        item.billedQuantity > 0 ||
        s == 'LOCKED' ||
        s == 'COMPLETED';
    final hasSpecs =
        item.specifications != null && item.specifications!.trim().isNotEmpty;
    final hasNotes = item.notes != null && item.notes!.trim().isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(item.description,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                const SizedBox(width: 8),
                if (item.isAddon)
                  Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.purple.shade300),
                    ),
                    child: Text(
                      item.itemKind == 'OPTIONAL' ? 'OPTIONAL' : 'ADD-ON',
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade700),
                    ),
                  ),
                _buildStatusBadge(item.status),
              ],
            ),
            if (hasSpecs) ...[
              const SizedBox(height: 6),
              Text(item.specifications!,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis),
            ],
            if (_detailMode) ...[
              if (item.itemCode != null) ...[
                const SizedBox(height: 4),
                Row(children: [
                  Icon(Icons.tag, size: 12, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Text(item.itemCode!,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade500)),
                ]),
              ],
              if (hasNotes) ...[
                const SizedBox(height: 4),
                Text(item.notes!,
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic)),
              ],
            ],
            const Divider(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoChip(
                    'Quantity', _formatQuantity(item.quantity, item.unit)),
                _buildInfoChip('Total Cost', _formatCurrency(item.amount)),
              ],
            ),
            if (showProgress) ...[
              const SizedBox(height: 12),
              _buildProgressBar('Executed', item.executionPercentage, Colors.orange),
              const SizedBox(height: 8),
              _buildProgressBar('Billed', item.billingPercentage, Colors.green),
            ],
          ],
        ),
      ),
    );
  }

  // ── Sticky Bottom Bar (Total + Approval CTAs) ─────────────────────────────

  Widget? _buildStickyBar() {
    if (_items.isEmpty) return null;
    final totalCost = _totalAllItems;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, -2))
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // If summary has add-ons, break down base + addons
            if (_summary != null && _summary!.hasAddons) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Base Scope',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                  Text(_formatCurrency(_summary!.baseScopeAmount),
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Add-ons / Upgrades',
                      style: TextStyle(fontSize: 12, color: Colors.purple.shade600)),
                  Text('+${_formatCurrency(_summary!.addonAmount)}',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.purple.shade600,
                          fontWeight: FontWeight.w600)),
                ],
              ),
              const Divider(height: 10),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Project Cost',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(_formatCurrency(totalCost),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _primaryColor)),
              ],
            ),
            if (_canSubmitApproval) ...[
              const SizedBox(height: 8),
              _buildApprovalSection(),
            ],
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalSection() {
    if (_approvalStatus == 'APPROVED') {
      return _buildApprovalBadge(
          icon: Icons.check_circle,
          label: 'BOQ Approved',
          color: Colors.green);
    }
    if (_approvalStatus == 'CHANGE_REQUESTED') {
      return _buildApprovalBadge(
          icon: Icons.sync,
          label: 'Changes Requested',
          color: Colors.orange);
    }
    // PENDING — show action buttons
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.edit_note, size: 16),
            label: const Text('Request Changes', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              foregroundColor: _primaryColor,
              side: const BorderSide(color: _primaryColor),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            onPressed: _submittingApproval ? null : _showRequestChangesDialog,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.check, size: 16),
            label: _submittingApproval
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('Approve BOQ', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            onPressed: _submittingApproval ? null : _showApproveDialog,
          ),
        ),
      ],
    );
  }

  Widget _buildApprovalBadge(
      {required IconData icon, required String label, required Color color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }

  // ── Shared widgets ────────────────────────────────────────────────────────

  Widget _buildStatusBadge(String? status) {
    final s = status?.toUpperCase() ?? '';
    Color color;
    String label;
    switch (s) {
      case 'APPROVED':
        color = Colors.blue;
        label = 'Confirmed';
        break;
      case 'LOCKED':
        color = Colors.orange;
        label = 'In Progress';
        break;
      case 'COMPLETED':
        color = Colors.green;
        label = 'Completed';
        break;
      default:
        color = Colors.grey;
        label = 'Pending';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _buildProgressBar(String label, double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 11, color: color, fontWeight: FontWeight.w500)),
            Text('${percentage.toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
          ],
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (percentage / 100).clamp(0.0, 1.0),
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }
}
