import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../constants.dart';
import '../../../services/auth_service.dart';
import '../../../services/project_module_service.dart';
import '../../../models/project_module_models.dart';
import '../../../config/api_config.dart';

class BoqScreen extends StatefulWidget {
  final String projectId;

  const BoqScreen({super.key, required this.projectId});

  @override
  State<BoqScreen> createState() => _BoqScreenState();
}

class _BoqScreenState extends State<BoqScreen> {
  bool isLoading = true;
  String? error;
  List<BoqItem> allItems = [];
  List<BoqWorkType> workTypes = [];
  BoqWorkType? selectedWorkType;
  ProjectModuleService? service;
  
  // Summary data
  double totalAmount = 0;
  Map<String, double> workTypeTotals = {};

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final token = await AuthService.getAccessToken();
    if (token != null) {
      service = ProjectModuleService(
        baseUrl: ApiConfig.baseUrl,
        token: token,
      );
      _loadData();
    } else {
      setState(() {
        error = 'Not authenticated';
        isLoading = false;
      });
    }
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // Load work types and items in parallel
      final results = await Future.wait([
        service!.getBoqWorkTypes(widget.projectId),
        service!.getBoqItems(widget.projectId),
      ]);

      final loadedWorkTypes = results[0] as List<BoqWorkType>;
      final loadedItems = results[1] as List<BoqItem>;

      // Calculate totals
      double total = 0;
      final totals = <String, double>{};
      for (final item in loadedItems) {
        total += item.amount;
        totals[item.workTypeName] = (totals[item.workTypeName] ?? 0) + item.amount;
      }

      setState(() {
        workTypes = loadedWorkTypes;
        allItems = loadedItems;
        totalAmount = total;
        workTypeTotals = totals;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load BOQ: $e';
        isLoading = false;
      });
    }
  }

  List<BoqItem> get filteredItems {
    if (selectedWorkType == null) return allItems;
    return allItems.where((item) => item.workTypeId == selectedWorkType!.id).toList();
  }

  double get filteredTotal {
    if (selectedWorkType == null) return totalAmount;
    return filteredItems.fold(0, (sum, item) => sum + item.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: blackColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Bill of Quantities",
          style: TextStyle(color: blackColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: surfaceColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: blackColor),
            onPressed: _loadData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : error != null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: errorColor),
          const SizedBox(height: 16),
          Text(error!, style: const TextStyle(color: errorColor)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (allItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.receipt_long_outlined, size: 48, color: Colors.green),
            ),
            const SizedBox(height: 16),
            const Text('No BOQ items found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text(
              'Bill of Quantities will appear here once added.',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: primaryColor,
      child: CustomScrollView(
        slivers: [
          // Summary Card
          SliverToBoxAdapter(
            child: _buildSummaryCard(),
          ),
          // Work Type Filter
          SliverToBoxAdapter(
            child: _buildWorkTypeFilter(),
          ),
          // Items List grouped by work type
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: _buildGroupedItems(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '\u20B9', decimalDigits: 2);
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade600, Colors.green.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.receipt_long, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Total Project Value',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            currencyFormat.format(filteredTotal),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${filteredItems.length} items${selectedWorkType != null ? ' in ${selectedWorkType!.name}' : ' total'}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1);
  }

  Widget _buildWorkTypeFilter() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<BoqWorkType?>(
          value: selectedWorkType,
          isExpanded: true,
          hint: const Text('All Work Types'),
          icon: const Icon(Icons.keyboard_arrow_down),
          items: [
            const DropdownMenuItem<BoqWorkType?>(
              value: null,
              child: Text('All Work Types'),
            ),
            ...workTypes.map((wt) => DropdownMenuItem<BoqWorkType?>(
              value: wt,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(child: Text(wt.name, overflow: TextOverflow.ellipsis)),
                  if (workTypeTotals[wt.name] != null)
                    Text(
                      '(${allItems.where((i) => i.workTypeId == wt.id).length})',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                ],
              ),
            )),
          ],
          onChanged: (value) {
            setState(() {
              selectedWorkType = value;
            });
          },
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms);
  }

  Widget _buildGroupedItems() {
    // Group items by work type
    final grouped = <String, List<BoqItem>>{};
    for (final item in filteredItems) {
      grouped.putIfAbsent(item.workTypeName, () => []).add(item);
    }

    final sortedKeys = grouped.keys.toList()..sort();

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final workTypeName = sortedKeys[index];
          final items = grouped[workTypeName]!;
          return _buildWorkTypeSection(workTypeName, items, index);
        },
        childCount: sortedKeys.length,
      ),
    );
  }

  Widget _buildWorkTypeSection(String workTypeName, List<BoqItem> items, int sectionIndex) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '\u20B9', decimalDigits: 0);
    final sectionTotal = items.fold<double>(0, (sum, item) => sum + item.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Container(
          margin: const EdgeInsets.only(top: 16, bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    const Icon(Icons.construction, size: 18, color: primaryColor),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        workTypeName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: primaryColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                currencyFormat.format(sectionTotal),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 200.ms, delay: (sectionIndex * 50).ms),
        // Items
        ...items.asMap().entries.map((entry) {
          return _buildBoqItemCard(entry.value, sectionIndex * 10 + entry.key);
        }),
      ],
    );
  }

  Widget _buildBoqItemCard(BoqItem item, int index) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '\u20B9', decimalDigits: 2);
    final numberFormat = NumberFormat('#,##0.##');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showItemDetails(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item code and description
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.itemCode != null && item.itemCode!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.itemCode!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      item.description,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Quantity, Unit, Rate, Amount
              Row(
                children: [
                  _buildDetailChip(
                    '${numberFormat.format(item.quantity)} ${item.unit}',
                    Icons.layers_outlined,
                    Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildDetailChip(
                    '@ ${currencyFormat.format(item.rate)}',
                    Icons.monetization_on_outlined,
                    Colors.orange,
                  ),
                  const Spacer(),
                  Text(
                    currencyFormat.format(item.amount),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              // Notes if any
              if (item.notes != null && item.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  item.notes!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms, delay: (index * 30).ms).slideX(begin: 0.05);
  }

  Widget _buildDetailChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showItemDetails(BoqItem item) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '\u20B9', decimalDigits: 2);
    final numberFormat = NumberFormat('#,##0.##');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Item Code Badge
                      if (item.itemCode != null && item.itemCode!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.itemCode!,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      // Description
                      Text(
                        item.description,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Work Type
                      Row(
                        children: [
                          Icon(Icons.category_outlined, size: 16, color: Colors.grey[500]),
                          const SizedBox(width: 6),
                          Text(
                            item.workTypeName,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Amount Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              currencyFormat.format(item.amount),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Details Grid
                      _buildDetailRow('Quantity', '${numberFormat.format(item.quantity)} ${item.unit}'),
                      _buildDetailRow('Unit Rate', currencyFormat.format(item.rate)),
                      if (item.specifications != null && item.specifications!.isNotEmpty)
                        _buildDetailRow('Specifications', item.specifications!),
                      if (item.notes != null && item.notes!.isNotEmpty)
                        _buildDetailRow('Notes', item.notes!),
                      _buildDetailRow('Created By', item.createdByName),
                      _buildDetailRow('Last Updated', DateFormat('MMM d, y').format(item.updatedAt)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
