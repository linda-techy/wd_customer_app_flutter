import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:wd_cust_mobile_app/models/api_models.dart';
import 'package:wd_cust_mobile_app/models/team_contact.dart';
import 'package:wd_cust_mobile_app/providers/project_workspace_provider.dart';
import 'package:wd_cust_mobile_app/screens/project/views/workspace/project_info_tab.dart';

// ---------------------------------------------------------------------------
// Stub provider — subclasses ProjectWorkspaceProvider so the widget tree
// satisfies context.watch<ProjectWorkspaceProvider>() without hitting the
// network. The load() is a no-op; getters return pre-seeded data.
// ---------------------------------------------------------------------------
class _StubWorkspaceProvider extends ProjectWorkspaceProvider {
  final ProjectDetails? _stubDetails;
  final List<TeamContact>? _stubTeam;
  final bool _stubTeamLoadFailed;

  _StubWorkspaceProvider(
    this._stubDetails,
    this._stubTeam, {
    bool teamLoadFailed = false,
  })  : _stubTeamLoadFailed = teamLoadFailed,
        super('test-uuid');

  @override
  Future<void> load({bool force = false}) async {} // no-op

  @override
  Future<void> refresh() async {} // no-op

  @override
  ProjectDetails? get details => _stubDetails;

  @override
  List<TeamContact>? get team => _stubTeam;

  @override
  bool get isLoading => false;

  @override
  String? get error => null;

  @override
  bool get teamLoadFailed => _stubTeamLoadFailed;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ProjectDetails _makeDetails({
  String? contractValueDisplay,
  String? designPackage,
}) =>
    ProjectDetails(
      id: 1,
      projectUuid: 'test-uuid',
      name: 'Test Project Alpha',
      code: 'TPA-001',
      location: '123 Main St, Springfield',
      status: 'IN_PROGRESS',
      progress: 0.45,
      phase: 'Construction',
      projectType: 'Residential',
      designPackage: designPackage,
      contractValueDisplay: contractValueDisplay,
      startDate: '2025-01-15',
      endDate: '2025-12-31',
      sqFeet: 2500.0,
    );

const _pmContact = TeamContact(
  userId: 1,
  name: 'Jane PM',
  designation: 'Project Manager',
  role: 'PM',
  phone: '+1-555-0100',
  email: 'jane@example.com',
);

const _archContact = TeamContact(
  userId: 2,
  name: 'Bob Architect',
  designation: 'Lead Architect',
  role: 'ARCHITECT',
  // no phone, no email — buttons should be disabled
);

Widget _buildTestApp(_StubWorkspaceProvider provider) {
  return ChangeNotifierProvider<ProjectWorkspaceProvider>.value(
    value: provider,
    child: const MaterialApp(
      home: Scaffold(body: ProjectInfoTab()),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ProjectInfoTab', () {
    testWidgets(
      'renders project name, contract value and team contacts with visibility-gated buttons',
      (tester) async {
        // Use a tall surface so the ListView renders all cards including Team.
        tester.view.physicalSize = const Size(800, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final provider = _StubWorkspaceProvider(
          _makeDetails(contractValueDisplay: '₹1.20 Cr', designPackage: 'Premium Package'),
          [_pmContact, _archContact],
        );

        await tester.pumpWidget(_buildTestApp(provider));
        await tester.pump();

        // Header card — project name visible
        expect(find.text('Test Project Alpha'), findsWidgets);

        // Contract card — INR-formatted value rendered as headline
        expect(find.text('₹1.20 Cr'), findsOneWidget);

        // Team — both names visible
        expect(find.text('Jane PM'), findsOneWidget);
        expect(find.text('Bob Architect'), findsOneWidget);

        // PM has phone → call button enabled (onPressed != null)
        final callButtons = tester.widgetList<IconButton>(
          find.byWidgetPredicate(
            (w) =>
                w is IconButton &&
                (w.icon as Icon?)?.icon == Icons.phone &&
                w.onPressed != null,
          ),
        );
        expect(callButtons, isNotEmpty);

        // Architect has no phone → at least one disabled call button
        final disabledCallButtons = tester.widgetList<IconButton>(
          find.byWidgetPredicate(
            (w) =>
                w is IconButton &&
                (w.icon as Icon?)?.icon == Icons.phone &&
                w.onPressed == null,
          ),
        );
        expect(disabledCallButtons, isNotEmpty);
      },
    );

    testWidgets(
      'shows "Not set" placeholder when contract value is null',
      (tester) async {
        final provider = _StubWorkspaceProvider(
          _makeDetails(contractValueDisplay: null),
          const [],
        );

        await tester.pumpWidget(_buildTestApp(provider));
        await tester.pump();

        expect(find.text('Not set'), findsWidgets);
      },
    );

    testWidgets(
      'shows "No team contacts available yet" placeholder for empty team',
      (tester) async {
        tester.view.physicalSize = const Size(800, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final provider = _StubWorkspaceProvider(
          _makeDetails(contractValueDisplay: '₹50.00 L', designPackage: 'Basic'),
          const [],
        );

        await tester.pumpWidget(_buildTestApp(provider));
        await tester.pump();

        expect(
          find.text('No team contacts available yet.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'shows team-load-failure message when teamLoadFailed is true, even when details loaded',
      (tester) async {
        tester.view.physicalSize = const Size(800, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final provider = _StubWorkspaceProvider(
          _makeDetails(contractValueDisplay: '₹1.20 Cr'),
          null, // team never loaded
          teamLoadFailed: true,
        );

        await tester.pumpWidget(_buildTestApp(provider));
        await tester.pump();

        // Project header still renders (details loaded successfully)
        expect(find.text('Test Project Alpha'), findsWidgets);

        // Team card shows the failure copy, not the empty-state copy
        expect(
          find.text('Couldn\'t load team contacts. Pull down to refresh.'),
          findsOneWidget,
        );
        expect(find.text('No team contacts available yet.'), findsNothing);
      },
    );
  });
}
