/// Project lifecycle phase for customer-facing display.
/// Standardized to 5 phases matching the backend enum.
enum ProjectPhase {
  planning,
  design,
  construction,
  completed,
  onHold;

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
      case ProjectPhase.onHold:
        return 'On Hold';
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
      case ProjectPhase.onHold:
        return 'Project temporarily paused';
    }
  }

  int get order => index + 1;

  /// Parse from API string (e.g. PLANNING, DESIGN, CONSTRUCTION, COMPLETED, ON_HOLD).
  /// Also handles legacy values for backward compatibility.
  static ProjectPhase fromString(String? value) {
    if (value == null || value.trim().isEmpty) return ProjectPhase.planning;
    final normalized = value.trim().toUpperCase().replaceAll(' ', '_');
    switch (normalized) {
      case 'PLANNING':
        return ProjectPhase.planning;
      case 'DESIGN':
        return ProjectPhase.design;
      case 'EXECUTION':
      case 'CONSTRUCTION':
      case 'FOUNDATION':
      case 'FINISHING':
        return ProjectPhase.construction;
      case 'COMPLETION':
      case 'HANDOVER':
      case 'WARRANTY':
      case 'COMPLETED':
        return ProjectPhase.completed;
      case 'ON_HOLD':
        return ProjectPhase.onHold;
      default:
        return ProjectPhase.planning;
    }
  }
}
