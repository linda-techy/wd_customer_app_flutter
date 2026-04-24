import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/timeline_item.dart';
import '../../../../providers/timeline_provider.dart';
import 'widgets/timeline_task_card.dart';

class InternalTimelineTab extends StatefulWidget {
  final String projectUuid;
  /// Optional provider override — used in tests to inject a stub.
  final TimelineProvider? provider;
  const InternalTimelineTab({super.key, required this.projectUuid, this.provider});

  @override
  State<InternalTimelineTab> createState() => _InternalTimelineTabState();
}

class _InternalTimelineTabState extends State<InternalTimelineTab> {
  late TimelineProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = widget.provider ?? TimelineProvider(widget.projectUuid);
    if (widget.provider == null) _provider.loadAll();
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider<TimelineProvider>.value(
        value: _provider,
        child: DefaultTabController(
          length: 3,
          child: Scaffold(
            body: Consumer<TimelineProvider>(builder: (ctx, p, _) {
              if (p.isLoading && p.summary == null) {
                return const Center(child: CircularProgressIndicator());
              }
              return Column(children: [
                if (p.summary != null) _Header(summary: p.summary!),
                const TabBar(tabs: [
                  Tab(text: 'Week'),
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Completed'),
                ]),
                Expanded(
                  child: TabBarView(children: [
                    _BucketView(
                        page: p.page('week'),
                        emptyMessage: 'No work scheduled this week'),
                    _BucketView(
                        page: p.page('upcoming'),
                        emptyMessage: 'Nothing upcoming yet'),
                    _BucketView(
                        page: p.page('completed'),
                        emptyMessage: 'No completed work yet'),
                  ]),
                ),
              ]);
            }),
          ),
        ),
      );
}

class _Header extends StatelessWidget {
  final TimelineSummary summary;
  const _Header({required this.summary});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Project progress: ${summary.projectProgressPercent}%',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            LinearProgressIndicator(
                value: summary.projectProgressPercent / 100.0),
            const SizedBox(height: 8),
            Row(children: [
              _stat('This week', summary.weekCount),
              _stat('Coming up', summary.upcomingCount),
              _stat('Done', summary.completedCount),
            ]),
          ]),
        ),
      );

  Widget _stat(String label, int n) => Expanded(
        child: Column(children: [
          Text('$n',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ]),
      );
}

class _BucketView extends StatelessWidget {
  final TimelinePage? page;
  final String emptyMessage;
  const _BucketView({required this.page, required this.emptyMessage});

  @override
  Widget build(BuildContext context) {
    if (page == null) return const Center(child: CircularProgressIndicator());
    if (page!.items.isEmpty) {
      return Center(
          child: Text(emptyMessage,
              style: const TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: page!.items.length,
      itemBuilder: (ctx, i) => TimelineTaskCard(item: page!.items[i]),
    );
  }
}
