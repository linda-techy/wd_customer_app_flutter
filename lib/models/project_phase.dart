/// Project lifecycle phase for customer-facing display.
/// Normalizes API values (DESIGN, PLANNING, EXECUTION, COMPLETION, HANDOVER,
/// WARRANTY, CONSTRUCTION, COMPLETED) into four clear phases.
enum ProjectPhase {
  planning,
  design,
  construction,
  completed;

  String get displayName {
    switch (this) {
      case ProjectPhase.planning:
        return 'Planning';
      case ProjectPhase.design:
        return 'Design';
      case ProjectPhase.construction:
        return 'Construction';
      case ProjectPhase.completed:
        return 'Completed';
    }
  }

  String get shortDescription {
    switch (this) {
      case ProjectPhase.planning:
        return 'Budget, timeline & preparation';
      case ProjectPhase.design:
        return 'Plans, approvals & design package';
      case ProjectPhase.construction:
        return 'Work in progress on site';
      case ProjectPhase.completed:
        return 'Handover & warranty';
    }
  }

  int get order => index + 1;

  /// Parse from API string (e.g. PLANNING, DESIGN, EXECUTION, COMPLETION, CONSTRUCTION, COMPLETED).
  static ProjectPhase fromString(String? value) {
    if (value == null || value.trim().isEmpty) return ProjectPhase.planning;
    final upper = value.trim().toUpperCase();
    switch (upper) {
      case 'PLANNING':
        return ProjectPhase.planning;
      case 'DESIGN':
        return ProjectPhase.design;
      case 'EXECUTION':
      case 'CONSTRUCTION':
        return ProjectPhase.construction;
      case 'COMPLETION':
      case 'HANDOVER':
      case 'WARRANTY':
      case 'COMPLETED':
        return ProjectPhase.completed;
      default:
        return ProjectPhase.planning;
    }
  }
}
