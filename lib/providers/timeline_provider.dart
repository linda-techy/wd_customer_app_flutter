import 'package:flutter/foundation.dart';

import '../models/timeline_item.dart';
import '../services/dashboard_service.dart';

class TimelineProvider with ChangeNotifier {
  final String projectUuid;
  TimelineProvider(this.projectUuid);

  TimelineSummary? _summary;
  final Map<String, TimelinePage?> _byBucket = {'week': null, 'upcoming': null, 'completed': null};
  bool _isLoading = false;
  String? _error;

  TimelineSummary? get summary => _summary;
  TimelinePage? page(String bucket) => _byBucket[bucket];
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAll({bool force = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final summaryResp = await DashboardService.getTimelineSummary(projectUuid);
      if (summaryResp.success && summaryResp.data != null) {
        _summary = summaryResp.data;
      } else if (!summaryResp.success) {
        _error = summaryResp.error?.message ?? 'Failed to load timeline summary';
      }
      final bucketsToLoad = ['week', 'upcoming', 'completed']
          .where((b) => force || _byBucket[b] == null)
          .toList();
      if (bucketsToLoad.isNotEmpty) {
        final results = await Future.wait(
          bucketsToLoad.map((b) => DashboardService.getTimeline(projectUuid, b)),
        );
        for (var i = 0; i < bucketsToLoad.length; i++) {
          final resp = results[i];
          if (resp.success && resp.data != null) {
            _byBucket[bucketsToLoad[i]] = resp.data;
          }
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadAll(force: true);
}
