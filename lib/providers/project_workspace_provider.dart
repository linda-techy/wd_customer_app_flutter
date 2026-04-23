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
  bool _teamLoadFailed = false;

  ProjectDetails? get details => _details;
  List<TeamContact>? get team => _team;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get teamLoadFailed => _teamLoadFailed;

  Future<void> load({bool force = false}) async {
    if (_isLoading) return;
    if (!force && _details != null && _team != null) return;

    _setLoading(true);
    _error = null;
    _teamLoadFailed = false;

    try {
      // Fetch project details first; a failure here is fatal for the whole tab.
      final detailsResponse = await DashboardService.getProjectDetails(projectUuid);
      _details = detailsResponse.data;

      if (!detailsResponse.success || _details == null) {
        _error = detailsResponse.error?.message ?? 'Failed to load project details.';
        _setLoading(false);
        return;
      }

      // Fetch team separately so a team failure doesn't hide project details.
      try {
        final teamResponse = await DashboardService.getProjectTeam(projectUuid);
        if (teamResponse.success) {
          _team = teamResponse.data ?? const [];
        } else {
          _teamLoadFailed = true;
          debugPrint('ProjectWorkspaceProvider: team load failed — '
              '${teamResponse.error?.message}');
        }
      } catch (e) {
        _teamLoadFailed = true;
        debugPrint('ProjectWorkspaceProvider: team load threw: $e');
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
