import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wd_cust_mobile_app/models/timeline_item.dart';
import 'package:wd_cust_mobile_app/providers/timeline_provider.dart';
import 'package:wd_cust_mobile_app/screens/project/views/workspace/internal_timeline_tab.dart';

class _StubTimelineProvider extends TimelineProvider {
  final TimelineSummary? _stubSummary;
  final Map<String, TimelinePage?> _stubBuckets;

  _StubTimelineProvider({TimelineSummary? summary, Map<String, TimelinePage?>? buckets})
      : _stubSummary = summary,
        _stubBuckets = buckets ?? {'week': null, 'upcoming': null, 'completed': null},
        super('test-uuid');

  @override
  TimelineSummary? get summary => _stubSummary;
  @override
  TimelinePage? page(String bucket) => _stubBuckets[bucket];
  @override
  bool get isLoading => false;
  @override
  Future<void> loadAll({bool force = false}) async {}
}

TimelinePage _emptyPage() => const TimelinePage(
    items: [],
    totalElements: 0,
    totalPages: 0,
    page: 0,
    size: 20,
    projectProgressPercent: 0);

TimelinePage _pageWith(List<TimelineItem> items) => TimelinePage(
    items: items,
    totalElements: items.length,
    totalPages: 1,
    page: 0,
    size: 20,
    projectProgressPercent: 50);

void main() {
  testWidgets('renders 3 tabs with empty state copy', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    addTearDown(tester.view.resetPhysicalSize);

    final provider = _StubTimelineProvider(
      summary: const TimelineSummary(
          weekCount: 0,
          upcomingCount: 0,
          completedCount: 0,
          projectProgressPercent: 0),
      buckets: {
        'week': _emptyPage(),
        'upcoming': _emptyPage(),
        'completed': _emptyPage()
      },
    );

    await tester.pumpWidget(MaterialApp(
      home: InternalTimelineTab(projectUuid: 'test-uuid', provider: provider),
    ));
    await tester.pump();

    expect(find.text('Week'), findsOneWidget);
    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('No work scheduled this week'), findsOneWidget);
  });

  testWidgets('renders task card with progress bar and status label',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    addTearDown(tester.view.resetPhysicalSize);

    const task = TimelineItem(
      taskId: 1,
      title: 'Brick masonry up to roof',
      milestoneName: 'Walls',
      progressPercent: 65,
      status: 'IN_PROGRESS',
      statusLabel: 'ON_TRACK',
    );
    final provider = _StubTimelineProvider(
      summary: const TimelineSummary(
          weekCount: 1,
          upcomingCount: 0,
          completedCount: 0,
          projectProgressPercent: 50),
      buckets: {
        'week': _pageWith([task]),
        'upcoming': _emptyPage(),
        'completed': _emptyPage()
      },
    );

    await tester.pumpWidget(MaterialApp(
      home: InternalTimelineTab(projectUuid: 'test-uuid', provider: provider),
    ));
    await tester.pump();

    expect(find.text('Brick masonry up to roof'), findsOneWidget);
    expect(find.text('Walls'), findsOneWidget);
    expect(find.text('On track'), findsOneWidget);
  });

  testWidgets('renders header with project progress', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    addTearDown(tester.view.resetPhysicalSize);

    final provider = _StubTimelineProvider(
      summary: const TimelineSummary(
          weekCount: 5,
          upcomingCount: 12,
          completedCount: 18,
          projectProgressPercent: 42),
      buckets: {
        'week': _emptyPage(),
        'upcoming': _emptyPage(),
        'completed': _emptyPage()
      },
    );

    await tester.pumpWidget(MaterialApp(
      home: InternalTimelineTab(projectUuid: 'test-uuid', provider: provider),
    ));
    await tester.pump();

    expect(find.text('Project progress: 42%'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
  });
}
