// Models for BOQ revision side-by-side diff feature.

class BoqRevision {
  final int id;
  final int? revisionNumber;
  final String status;
  final String? createdAt;
  final double? totalValueExGst;
  final double? totalValueInclGst;

  const BoqRevision({
    required this.id,
    this.revisionNumber,
    required this.status,
    this.createdAt,
    this.totalValueExGst,
    this.totalValueInclGst,
  });

  factory BoqRevision.fromJson(Map<String, dynamic> j) => BoqRevision(
        id: (j['id'] as num).toInt(),
        revisionNumber: (j['revisionNumber'] as num?)?.toInt(),
        status: j['status']?.toString() ?? '',
        createdAt: j['createdAt']?.toString(),
        totalValueExGst: _d(j['totalValueExGst']),
        totalValueInclGst: _d(j['totalValueInclGst']),
      );

  String get displayLabel {
    final rev = revisionNumber != null ? 'Rev $revisionNumber' : 'Doc #$id';
    final s = _statusLabel(status);
    return '$rev — $s';
  }

  String _statusLabel(String s) {
    switch (s.toUpperCase()) {
      case 'APPROVED':
        return 'Approved';
      case 'DRAFT':
        return 'Draft';
      case 'PENDING_APPROVAL':
        return 'Pending';
      case 'REJECTED':
        return 'Rejected';
      default:
        return s;
    }
  }
}

class BoqDiffResult {
  final List<BoqDiffItem> added;
  final List<BoqDiffItem> removed;
  final List<BoqDiffModifiedItem> modified;
  final BoqDiffSummary summary;

  const BoqDiffResult({
    required this.added,
    required this.removed,
    required this.modified,
    required this.summary,
  });

  factory BoqDiffResult.fromJson(Map<String, dynamic> j) => BoqDiffResult(
        added: _parseItems(j['added']),
        removed: _parseItems(j['removed']),
        modified: _parseModified(j['modified']),
        summary: BoqDiffSummary.fromJson(j['summary'] as Map<String, dynamic>),
      );

  bool get isEmpty => added.isEmpty && removed.isEmpty && modified.isEmpty;
}

class BoqDiffItem {
  final String? itemCode;
  final String description;
  final double? quantity;
  final String? unit;
  final double? rate;
  final double? amount;

  const BoqDiffItem({
    this.itemCode,
    required this.description,
    this.quantity,
    this.unit,
    this.rate,
    this.amount,
  });

  factory BoqDiffItem.fromJson(Map<String, dynamic> j) => BoqDiffItem(
        itemCode: j['itemCode']?.toString(),
        description: j['description']?.toString() ?? '',
        quantity: _d(j['quantity']),
        unit: j['unit']?.toString(),
        rate: _d(j['rate']),
        amount: _d(j['amount']),
      );
}

class BoqDiffModifiedItem {
  final String itemCode;
  final String description;
  final Map<String, BoqDiffChange> changes;

  const BoqDiffModifiedItem({
    required this.itemCode,
    required this.description,
    required this.changes,
  });

  factory BoqDiffModifiedItem.fromJson(Map<String, dynamic> j) {
    final rawChanges = j['changes'] as Map<String, dynamic>? ?? {};
    final changes = rawChanges.map(
      (key, value) => MapEntry(
        key,
        BoqDiffChange.fromJson(value as Map<String, dynamic>),
      ),
    );
    return BoqDiffModifiedItem(
      itemCode: j['itemCode']?.toString() ?? '',
      description: j['description']?.toString() ?? '',
      changes: changes,
    );
  }
}

class BoqDiffChange {
  final dynamic oldValue;
  final dynamic newValue;

  const BoqDiffChange({required this.oldValue, required this.newValue});

  factory BoqDiffChange.fromJson(Map<String, dynamic> j) => BoqDiffChange(
        oldValue: j['oldValue'],
        newValue: j['newValue'],
      );
}

class BoqDiffSummary {
  final double oldTotal;
  final double newTotal;
  final double delta;
  final int addedCount;
  final int removedCount;
  final int modifiedCount;
  final int? fromRevision;
  final int? toRevision;

  const BoqDiffSummary({
    required this.oldTotal,
    required this.newTotal,
    required this.delta,
    required this.addedCount,
    required this.removedCount,
    required this.modifiedCount,
    this.fromRevision,
    this.toRevision,
  });

  factory BoqDiffSummary.fromJson(Map<String, dynamic> j) => BoqDiffSummary(
        oldTotal: _d(j['oldTotal']),
        newTotal: _d(j['newTotal']),
        delta: _d(j['delta']),
        addedCount: (j['addedCount'] as num?)?.toInt() ?? 0,
        removedCount: (j['removedCount'] as num?)?.toInt() ?? 0,
        modifiedCount: (j['modifiedCount'] as num?)?.toInt() ?? 0,
        fromRevision: (j['fromRevision'] as num?)?.toInt(),
        toRevision: (j['toRevision'] as num?)?.toInt(),
      );

  int get totalChanges => addedCount + removedCount + modifiedCount;
}

// ── Helpers ──────────────────────────────────────────────────────────────────

List<BoqDiffItem> _parseItems(dynamic raw) {
  if (raw == null) return [];
  return (raw as List)
      .map((j) => BoqDiffItem.fromJson(j as Map<String, dynamic>))
      .toList();
}

List<BoqDiffModifiedItem> _parseModified(dynamic raw) {
  if (raw == null) return [];
  return (raw as List)
      .map((j) => BoqDiffModifiedItem.fromJson(j as Map<String, dynamic>))
      .toList();
}

double _d(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0.0;
}
