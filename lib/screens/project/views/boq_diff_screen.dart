import 'package:flutter/material.dart';
import '../../../models/boq_diff_models.dart';
import '../../../services/boq_diff_service.dart';
import '../../../utils/currency_formatter.dart';

class BoqDiffScreen extends StatefulWidget {
  final String projectId;

  const BoqDiffScreen({super.key, required this.projectId});

  @override
  State<BoqDiffScreen> createState() => _BoqDiffScreenState();
}

class _BoqDiffScreenState extends State<BoqDiffScreen> {
  static const _primaryColor = Color(0xFFD32F2F);

  bool _loadingRevisions = true;
  bool _loadingDiff = false;
  String? _error;

  List<BoqRevision> _revisions = [];
  BoqRevision? _fromRevision;
  BoqRevision? _toRevision;
  BoqDiffResult? _diffResult;

  @override
  void initState() {
    super.initState();
    _loadRevisions();
  }

  Future<void> _loadRevisions() async {
    setState(() {
      _loadingRevisions = true;
      _error = null;
    });
    try {
      final revs = await BoqDiffService.getRevisions(widget.projectId);
      setState(() {
        _revisions = revs;
        _loadingRevisions = false;
        // Default selection: second-to-last and last
        if (revs.length >= 2) {
          _fromRevision = revs[revs.length - 2];
          _toRevision = revs[revs.length - 1];
        } else if (revs.length == 1) {
          _toRevision = revs.first;
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loadingRevisions = false;
      });
    }
  }

  Future<void> _compare() async {
    if (_fromRevision == null || _toRevision == null) return;
    if (_fromRevision!.id == _toRevision!.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select two different revisions')),
      );
      return;
    }
    setState(() {
      _loadingDiff = true;
      _diffResult = null;
      _error = null;
    });
    try {
      final result = await BoqDiffService.getDiff(
        widget.projectId,
        _fromRevision!.id,
        _toRevision!.id,
      );
      setState(() {
        _diffResult = result;
        _loadingDiff = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loadingDiff = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Compare Revisions'),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _loadingRevisions
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _revisions.isEmpty
              ? _buildError()
              : _revisions.isEmpty
                  ? const Center(
                      child: Text('No BOQ revisions found',
                          style: TextStyle(color: Colors.grey)))
                  : Column(
                      children: [
                        _buildSelectors(),
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(_error!,
                                style: const TextStyle(color: Colors.red)),
                          ),
                        Expanded(child: _buildBody()),
                      ],
                    ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Error: $_error'),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadRevisions, child: const Text('Retry')),
        ],
      ),
    );
  }

  // ── Revision selectors ───────────────────────────────────────────────────

  Widget _buildSelectors() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'From',
                  value: _fromRevision,
                  onChanged: (v) => setState(() {
                    _fromRevision = v;
                    _diffResult = null;
                  }),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.arrow_forward, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  label: 'To',
                  value: _toRevision,
                  onChanged: (v) => setState(() {
                    _toRevision = v;
                    _diffResult = null;
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            icon: _loadingDiff
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.compare_arrows, size: 18),
            label: const Text('Compare'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed:
                _loadingDiff || _fromRevision == null || _toRevision == null
                    ? null
                    : _compare,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required BoqRevision? value,
    required ValueChanged<BoqRevision?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade50,
          ),
          child: DropdownButton<BoqRevision>(
            isExpanded: true,
            underline: const SizedBox(),
            value: value,
            hint: const Text('Select', style: TextStyle(fontSize: 13)),
            items: _revisions.map((r) {
              return DropdownMenuItem(
                value: r,
                child: Text(r.displayLabel,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  // ── Diff body ────────────────────────────────────────────────────────────

  Widget _buildBody() {
    if (_loadingDiff) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_diffResult == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.compare_arrows, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('Select two revisions and tap Compare',
                style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
    }
    if (_diffResult!.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline,
                size: 56, color: Colors.green.shade300),
            const SizedBox(height: 12),
            const Text('No differences found between the selected revisions',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    final diff = _diffResult!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _buildSummaryCard(diff.summary),
        if (diff.added.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSectionHeader('Added Items', diff.added.length, Colors.green),
          ...diff.added.map((item) => _buildAddedCard(item)),
        ],
        if (diff.removed.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSectionHeader('Removed Items', diff.removed.length, Colors.red),
          ...diff.removed.map((item) => _buildRemovedCard(item)),
        ],
        if (diff.modified.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSectionHeader(
              'Modified Items', diff.modified.length, Colors.amber.shade700),
          ...diff.modified.map((item) => _buildModifiedCard(item)),
        ],
      ],
    );
  }

  // ── Summary card ─────────────────────────────────────────────────────────

  Widget _buildSummaryCard(BoqDiffSummary s) {
    final isIncrease = s.delta >= 0;
    final deltaColor = isIncrease ? Colors.red.shade700 : Colors.green.shade700;
    final deltaLabel = isIncrease
        ? '+${CurrencyFormatter.format(s.delta)}'
        : CurrencyFormatter.format(s.delta);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Comparison Summary',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _summaryCell(
                    'Old Total',
                    CurrencyFormatter.format(s.oldTotal),
                    Colors.grey.shade700,
                  ),
                ),
                const Icon(Icons.arrow_forward,
                    color: Colors.grey, size: 18),
                Expanded(
                  child: _summaryCell(
                    'New Total',
                    CurrencyFormatter.format(s.newTotal),
                    Colors.grey.shade700,
                  ),
                ),
                Expanded(
                  child: _summaryCell('Change', deltaLabel, deltaColor,
                      bold: true),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _countChip('${s.addedCount} Added', Colors.green),
                _countChip('${s.removedCount} Removed', Colors.red),
                _countChip('${s.modifiedCount} Modified', Colors.amber.shade700),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCell(String label, String value, Color color,
      {bool bold = false}) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        const SizedBox(height: 3),
        Text(value,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: bold ? FontWeight.bold : FontWeight.w500)),
      ],
    );
  }

  Widget _countChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  // ── Section headers ──────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text('$title ($count)',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14, color: color)),
        ],
      ),
    );
  }

  // ── Added item card ──────────────────────────────────────────────────────

  Widget _buildAddedCard(BoqDiffItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.green.shade200),
      ),
      color: Colors.green.shade50,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('NEW',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.description,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  if (item.itemCode != null) ...[
                    const SizedBox(height: 3),
                    Text(item.itemCode!,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade600)),
                  ],
                  const SizedBox(height: 6),
                  _itemMetaRow(item),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Removed item card ────────────────────────────────────────────────────

  Widget _buildRemovedCard(BoqDiffItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.red.shade200),
      ),
      color: Colors.red.shade50,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.shade700,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('REMOVED',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.description,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.red.shade900,
                          decoration: TextDecoration.lineThrough)),
                  if (item.itemCode != null) ...[
                    const SizedBox(height: 3),
                    Text(item.itemCode!,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade600)),
                  ],
                  const SizedBox(height: 6),
                  _itemMetaRow(item),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Modified item card ───────────────────────────────────────────────────

  Widget _buildModifiedCard(BoqDiffModifiedItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.amber.shade300),
      ),
      color: Colors.amber.shade50,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade700,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('MODIFIED',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(item.description,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ],
            ),
            if (item.itemCode.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(item.itemCode,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            ],
            const SizedBox(height: 8),
            ...item.changes.entries.map((e) => _buildChangeRow(e.key, e.value)),
          ],
        ),
      ),
    );
  }

  Widget _buildChangeRow(String field, BoqDiffChange change) {
    final fieldLabel = _fieldLabel(field);
    final oldStr = _formatValue(field, change.oldValue);
    final newStr = _formatValue(field, change.newValue);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(fieldLabel,
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500)),
          ),
          Text(oldStr,
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.red.shade700,
                  decoration: TextDecoration.lineThrough)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Icon(Icons.arrow_forward, size: 13, color: Colors.grey),
          ),
          Text(newStr,
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ── Shared helpers ───────────────────────────────────────────────────────

  Widget _itemMetaRow(BoqDiffItem item) {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        if (item.quantity != null)
          _metaChip('Qty: ${_formatQty(item.quantity!, item.unit)}'),
        if (item.rate != null)
          _metaChip('Rate: ${CurrencyFormatter.format(item.rate!)}'),
        if (item.amount != null)
          _metaChip('Total: ${CurrencyFormatter.format(item.amount!)}'),
      ],
    );
  }

  Widget _metaChip(String label) {
    return Text(label,
        style: TextStyle(fontSize: 11, color: Colors.grey.shade700));
  }

  String _formatQty(double qty, String? unit) {
    final q = qty == qty.truncateToDouble()
        ? qty.toInt().toString()
        : qty.toStringAsFixed(2);
    return unit != null && unit.isNotEmpty ? '$q $unit' : q;
  }

  String _fieldLabel(String field) {
    switch (field) {
      case 'quantity':
        return 'Quantity';
      case 'rate':
        return 'Rate';
      case 'description':
        return 'Description';
      default:
        return field;
    }
  }

  String _formatValue(String field, dynamic value) {
    if (value == null) return '—';
    if (field == 'rate' || field == 'amount') {
      final d = double.tryParse(value.toString()) ?? 0.0;
      return CurrencyFormatter.format(d);
    }
    if (field == 'quantity') {
      final d = double.tryParse(value.toString());
      if (d == null) return value.toString();
      return d == d.truncateToDouble()
          ? d.toInt().toString()
          : d.toStringAsFixed(2);
    }
    return value.toString();
  }
}
