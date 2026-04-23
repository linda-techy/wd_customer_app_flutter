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

  _StubWorkspaceProvider(this._stubDetails, this._stubTeam)
      : super('test-uuid');

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
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ProjectDetails _makeDetails({String? designPackage}) => ProjectDetails(
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
      'renders project name, design package and team contacts with visibility-gated buttons',
      (tester) async {
        final provider = _StubWorkspaceProvider(
          _makeDetails(designPackage: 'Premium Package'),
          [_pmContact, _archContact],
        );

        await tester.pumpWidget(_buildTestApp(provider));
        await tester.pump();

        // Header card — project name visible
        expect(find.text('Test Project Alpha'), findsWidgets);

        // Key-facts / contract — design package rendered
        expect(find.text('Premium Package'), findsOneWidget);

        // Team — both names visible (may be off-screen in small test viewport)
        expect(find.text('Jane PM', skipOffstage: false), findsOneWidget);
        expect(find.text('Bob Architect', skipOffstage: false), findsOneWidget);

        // PM has phone → call button enabled (onPressed != null)
        final callButtons = tester.widgetList<IconButton>(
          find.byWidgetPredicate(
            (w) =>
                w is IconButton &&
                (w.icon as Icon?)?.icon == Icons.phone &&
                w.onPressed != null,
            skipOffstage: false,
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
            skipOffstage: false,
          ),
        );
        expect(disabledCallButtons, isNotEmpty);
      },
    );

    testWidgets(
      'shows "Not set" placeholder when design package is null',
      (tester) async {
        final provider = _StubWorkspaceProvider(
          _makeDetails(designPackage: null),
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
        final provider = _StubWorkspaceProvider(
          _makeDetails(designPackage: 'Basic'),
          const [],
        );

        await tester.pumpWidget(_buildTestApp(provider));
        await tester.pump();

        expect(
          find.text('No team contacts available yet.', skipOffstage: false),
          findsOneWidget,
        );
      },
    );
  });
}
