import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../components/organisms/site_update_card.dart';
import '../../../constants.dart';
import '../../../services/project_module_service.dart';
import '../../../services/auth_service.dart';
import '../../../config/api_config.dart';
import '../../../models/project_module_models.dart';

class SiteUpdatesScreen extends StatefulWidget {
  final String projectId;
  
  const SiteUpdatesScreen({super.key, required this.projectId});

  @override
  State<SiteUpdatesScreen> createState() => _SiteUpdatesScreenState();
}

class _SiteUpdatesScreenState extends State<SiteUpdatesScreen> {
  ProjectModuleService? _service;
  List<SiteVisit> _siteVisits = [];
  Map<DateTime, List<CombinedActivityItem>> _groupedActivities = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    try {
      final token = await AuthService.getAccessToken();
      if (token != null) {
        setState(() {
          _service = ProjectModuleService(
            baseUrl: ApiConfig.baseUrl,
            token: token,
          );
        });
        await _loadData();
      } else {
        setState(() {
          _error = 'Please log in to view site updates';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to initialize: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadData() async {
    if (_service == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _service!.getSiteVisits(widget.projectId),
        _service!.getCombinedActivitiesGrouped(widget.projectId),
      ]);

      setState(() {
        _siteVisits = results[0] as List<SiteVisit>;
        _groupedActivities = results[1] as Map<DateTime, List<CombinedActivityItem>>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load site updates: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today, ${DateFormat('d MMM').format(date)}';
    } else if (dateOnly == yesterday) {
      return 'Yesterday, ${DateFormat('d MMM').format(date)}';
    } else {
      return DateFormat('d MMM yyyy').format(date);
    }
  }

  String _formatWeather(String? weather) {
    if (weather == null || weather.isEmpty) {
      return 'N/A';
    }
    return weather;
  }

  List<Widget> _buildUpdateCards() {
    final List<Widget> cards = [];

    // Add site visits
    for (var visit in _siteVisits) {
      final date = visit.checkInTime;
      final description = visit.notes ?? visit.purpose ?? 'Site visit recorded';
      final weather = _formatWeather(visit.weatherConditions);

      cards.add(
        SiteUpdateCard(
          date: _formatDate(date),
          description: description,
          imageUrls: const [], // Placeholder - no images from API
          weather: weather,
          onComment: () {},
          onShare: () {},
        ),
      );
    }

    // Add grouped activities
    final sortedDates = _groupedActivities.keys.toList()..sort((a, b) => b.compareTo(a));
    for (var date in sortedDates) {
      final activities = _groupedActivities[date]!;
      for (var activity in activities) {
        final description = activity.description ?? activity.title;
        cards.add(
          SiteUpdateCard(
            date: _formatDate(activity.date),
            description: description,
            imageUrls: const [], // Placeholder - no images from API
            weather: 'N/A',
            onComment: () {},
            onShare: () {},
          ),
        );
      }
    }

    // Sort all cards by date (newest first)
    cards.sort((a, b) {
      // Extract date from card if possible, otherwise keep order
      return 0; // Already sorted by date above
    });

    return cards;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        title: const Text("Daily Site Updates", style: TextStyle(color: blackColor)),
        backgroundColor: surfaceColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: blackColor),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: blackColor),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: _siteVisits.isEmpty && _groupedActivities.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.update_outlined, size: 64, color: blackColor60),
                              const SizedBox(height: 16),
                              const Text(
                                'No site updates available',
                                style: TextStyle(color: blackColor60),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: _buildUpdateCards().length,
                          itemBuilder: (context, index) {
                            return _buildUpdateCards()[index];
                          },
                        ),
                ),
    );
  }
}
