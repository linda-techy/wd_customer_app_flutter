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

  @override
  void initState() { super.initState(); _initService(); }

  Future<void> _initService() async {
    final token = await AuthService.getAccessToken();
    _service = ProjectModuleService(baseUrl: ApiConfig.baseUrl, token: token);
    _loadData();
  }

  Future<void> _loadData() async {
    if (_service == null) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final items = await _service!.getBoqItems(widget.projectId);
      setState(() { _items = items; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '₹0';
    final num val = amount is num ? amount : num.tryParse(amount.toString()) ?? 0;
    if (val >= 10000000) return '₹${(val / 10000000).toStringAsFixed(2)} Cr';
    if (val >= 100000) return '₹${(val / 100000).toStringAsFixed(2)} L';
    if (val >= 1000) return '₹${(val / 1000).toStringAsFixed(1)}K';
    return '₹${val.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = _items.fold<double>(0, (sum, item) {
      final amt = item['totalAmount'] ?? item['amount'] ?? 0;
      return sum + (amt is num ? amt.toDouble() : double.tryParse(amt.toString()) ?? 0);
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(title: const Text('Bill of Quantities'), backgroundColor: const Color(0xFFD32F2F), foregroundColor: Colors.white),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text('Error: $_error'), const SizedBox(height: 16), ElevatedButton(onPressed: _loadData, child: const Text('Retry'))]))
              : _items.isEmpty
                  ? const Center(child: Text('No BoQ items available', style: TextStyle(color: Colors.grey)))
                  : Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          color: const Color(0xFFD32F2F).withOpacity(0.05),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            const Text('Total Estimated Cost', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(_formatCurrency(totalAmount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFFD32F2F))),
                          ]),
                        ),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: _loadData,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _items.length,
                              itemBuilder: (context, index) {
                                final item = _items[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Row(children: [
                                        Expanded(child: Text(item['workType'] ?? item['description'] ?? 'Item ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold))),
                                        Text(_formatCurrency(item['totalAmount'] ?? item['amount']), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD32F2F))),
                                      ]),
                                      const Divider(height: 16),
                                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                        _buildInfoChip('Qty', '${item['quantity'] ?? '-'}'),
                                        _buildInfoChip('Unit', item['unit'] ?? '-'),
                                        _buildInfoChip('Rate', _formatCurrency(item['rate'] ?? item['unitRate'])),
                                      ]),
                                      if (item['category'] != null) ...[
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                                          child: Text(item['category'], style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                        ),
                                      ],
                                    ]),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Column(children: [
      Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
      const SizedBox(height: 2),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
    ]);
  }
}
