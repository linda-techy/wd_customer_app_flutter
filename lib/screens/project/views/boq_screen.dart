import 'package:flutter/material.dart';
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
  ProjectModuleService? _service;
  List<dynamic> _items = [];
  bool _isLoading = true;
  String? _error;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _initService();
  }

  Future<void> _initService() async {
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
      final items = await _service!.getBoqItems(widget.projectId);
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<dynamic> get _filteredItems {
    if (_selectedStatus == null) return _items;
    return _items.where((item) => item['status'] == _selectedStatus).toList();
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '₹0';
    final num val = amount is num ? amount : num.tryParse(amount.toString()) ?? 0;
    if (val >= 10000000) return '₹${(val / 10000000).toStringAsFixed(2)} Cr';
    if (val >= 100000) return '₹${(val / 100000).toStringAsFixed(2)} L';
    if (val >= 1000) return '₹${(val / 1000).toStringAsFixed(1)}K';
    return '₹${val.toStringAsFixed(0)}';
  }

  double _getDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toUpperCase()) {
      case 'DRAFT':
        color = Colors.grey;
        break;
      case 'APPROVED':
        color = Colors.blue;
        break;
      case 'LOCKED':
        color = Colors.orange;
        break;
      case 'COMPLETED':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildProgressBar(String label, double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.w500),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
          ],
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPlanned = _filteredItems.fold<double>(0, (sum, item) {
      final amt = item['totalAmount'] ?? item['amount'] ?? 0;
      return sum + _getDouble(amt);
    });

    final totalExecuted = _filteredItems.fold<double>(0, (sum, item) {
      final amt = item['totalExecutedAmount'] ?? 0;
      return sum + _getDouble(amt);
    });

    final totalBilled = _filteredItems.fold<double>(0, (sum, item) {
      final amt = item['totalBilledAmount'] ?? 0;
      return sum + _getDouble(amt);
    });

    final overallExecPct =
        totalPlanned > 0 ? (totalExecuted / totalPlanned * 100) : 0.0;
    final overallBillPct =
        totalExecuted > 0 ? (totalBilled / totalExecuted * 100) : 0.0;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Bill of Quantities'),
        backgroundColor: const Color(0xFFD32F2F),
        foregroundColor: Colors.white,
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
                          onPressed: _loadData, child: const Text('Retry'))
                    ],
                  ),
                )
              : _items.isEmpty
                  ? const Center(
                      child: Text('No BoQ items available',
                          style: TextStyle(color: Colors.grey)))
                  : Column(
                      children: [
                        // Enhanced Summary Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFD32F2F),
                                const Color(0xFFD32F2F).withOpacity(0.8)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Financial Summary',
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${_filteredItems.length} items',
                                      style: const TextStyle(
                                          color: Colors.white70, fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildSummaryRow('Planned',
                                  _formatCurrency(totalPlanned), Colors.white),
                              const SizedBox(height: 4),
                              _buildSummaryRow(
                                  'Executed',
                                  _formatCurrency(totalExecuted),
                                  Colors.orangeAccent),
                              const SizedBox(height: 4),
                              _buildSummaryRow('Billed',
                                  _formatCurrency(totalBilled), Colors.greenAccent),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildPercentageBadge(
                                        'Execution', overallExecPct, Colors.orange),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildPercentageBadge(
                                        'Billing', overallBillPct, Colors.green),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Status Filter
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildFilterChip('All', _selectedStatus == null,
                                    () {
                                  setState(() => _selectedStatus = null);
                                }),
                                _buildFilterChip('Draft',
                                    _selectedStatus == 'DRAFT', () {
                                  setState(() => _selectedStatus = 'DRAFT');
                                }),
                                _buildFilterChip('Approved',
                                    _selectedStatus == 'APPROVED', () {
                                  setState(() => _selectedStatus = 'APPROVED');
                                }),
                                _buildFilterChip('Locked',
                                    _selectedStatus == 'LOCKED', () {
                                  setState(() => _selectedStatus = 'LOCKED');
                                }),
                                _buildFilterChip('Completed',
                                    _selectedStatus == 'COMPLETED', () {
                                  setState(() => _selectedStatus = 'COMPLETED');
                                }),
                              ],
                            ),
                          ),
                        ),
                        // Items List
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: _loadData,
                            child: _filteredItems.isEmpty
                                ? const Center(
                                    child: Text('No items for selected filter',
                                        style: TextStyle(color: Colors.grey)))
                                : ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: _filteredItems.length,
                                    itemBuilder: (context, index) {
                                      final item = _filteredItems[index];
                                      return _buildEnhancedItemCard(item);
                                    },
                                  ),
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildSummaryRow(String label, String amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(color: color.withOpacity(0.9), fontSize: 12)),
        Text(amount,
            style: TextStyle(
                color: color, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildPercentageBadge(String label, double percentage, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 10)),
          const SizedBox(height: 3),
          Text('${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                  color: color, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
      String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: const Color(0xFFD32F2F),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildEnhancedItemCard(dynamic item) {
    final status = item['status']?.toString() ?? 'DRAFT';
    final itemCode = item['itemCode']?.toString();
    final description = item['description']?.toString() ??
        item['workType']?.toString() ??
        'Item';
    final workTypeName = item['workTypeName']?.toString();
    final categoryName = item['categoryName']?.toString();
    final quantity = _getDouble(item['quantity']);
    final unit = item['unit']?.toString() ?? '';
    final rate = _getDouble(item['rate'] ?? item['unitRate']);
    final totalAmount = _getDouble(item['totalAmount'] ?? item['amount']);
    final executedQty = _getDouble(item['executedQuantity']);
    final billedQty = _getDouble(item['billedQuantity']);
    final execPct = _getDouble(item['executionPercentage']);
    final billPct = _getDouble(item['billingPercentage']);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(description,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      if (itemCode != null) ...[
                        const SizedBox(height: 3),
                        Text('Code: $itemCode',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade600)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusBadge(status),
              ],
            ),
            if (categoryName != null || workTypeName != null) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: [
                  if (categoryName != null)
                    _buildInfoBadge(categoryName, Icons.category),
                  if (workTypeName != null)
                    _buildInfoBadge(workTypeName, Icons.work),
                ],
              ),
            ],
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoChip('Qty', '$quantity $unit'),
                _buildInfoChip('Rate', _formatCurrency(rate)),
                _buildInfoChip('Amount', _formatCurrency(totalAmount)),
              ],
            ),
            // Progress Bars
            if (executedQty > 0 || billedQty > 0) ...[
              const SizedBox(height: 12),
              _buildProgressBar('Executed', execPct, Colors.orange),
              const SizedBox(height: 8),
              _buildProgressBar('Billed', billPct, Colors.green),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(label,
              style:
                  TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ],
      ),
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
