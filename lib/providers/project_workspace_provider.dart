import 'package:flutter/foundation.dart';

import '../models/api_models.dart';
import '../models/team_contact.dart';
import '../services/dashboard_service.dart';

/// Holds project details + team contacts for a single workspace session.
///
/// Lazy-loaded on first [load] call; tabs read from this provider instead of
/// fetching independently. Call [refresh] to force a reload (e.g. pull-to-refresh).
class ProjectWorkspaceProvider with ChangeNotifier {
  final String projectUuid;

  ProjectWorkspaceProvider(this.projectUuid);

  ProjectDetails? _details;
  List<TeamContact>? _team;
  bool _isLoading = false;
  String? _error;

  ProjectDetails? get details => _details;
  List<TeamContact>? get team => _team;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load({bool force = false}) async {
    if (_isLoading) return;
    if (!force && _details != null && _team != null) return;

    _setLoading(true);
    _error = null;

    try {
      final results = await Future.wait([
        DashboardService.getProjectDetails(projectUuid),
        DashboardService.getProjectTeam(projectUuid),
      ]);

      final detailsResponse = results[0] as ApiResponse<ProjectDetails>;
      final teamResponse = results[1] as ApiResponse<List<TeamContact>>;

      _details = detailsResponse.data;
      _team = teamResponse.data;

      if (!detailsResponse.success || _details == null) {
        _error = detailsResponse.error?.message ?? 'Failed to load project details.';
      } else if (!teamResponse.success || _team == null) {
        _error = teamResponse.error?.message ?? 'Failed to load team contacts.';
        // Keep _details so callers can still render the header.
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('ProjectWorkspaceProvider.load error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() => load(force: true);

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
