import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wd_cust_mobile_app/widgets/admin_reply_block.dart';

void _widenView(WidgetTester tester) {
  tester.view.physicalSize = const Size(2400, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void main() {
  group('AdminReplyBlock', () {
    testWidgets(
        'renders reply label, text, and responded date when adminResponse is non-null',
        (tester) async {
      _widenView(tester);

      await tester.pumpWidget(
        _wrap(
          const AdminReplyBlock(
            adminResponse: 'Thank you for your feedback! We will address it.',
            adminRespondedAt: null, // date tested separately below
          ),
        ),
      );
      await tester.pump();

      // Section label
      expect(find.text('Response from Walldot Builders'), findsOneWidget);
      // Reply text
      expect(
        find.text('Thank you for your feedback! We will address it.'),
        findsOneWidget,
      );
      // Agent icon is present
      expect(find.byIcon(Icons.support_agent_rounded), findsOneWidget);
    });

    testWidgets('renders responded date when adminRespondedAt is provided',
        (tester) async {
      _widenView(tester);

      await tester.pumpWidget(
        _wrap(
          AdminReplyBlock(
            adminResponse: 'Great to hear from you.',
            adminRespondedAt: DateTime(2026, 5, 20),
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('20 May 2026'), findsOneWidget);
    });

    testWidgets('renders nothing (SizedBox.shrink) when adminResponse is null',
        (tester) async {
      _widenView(tester);

      await tester.pumpWidget(
        _wrap(
          const AdminReplyBlock(
            adminResponse: null,
            adminRespondedAt: null,
          ),
        ),
      );
      await tester.pump();

      // No label or icon should appear
      expect(find.text('Response from Walldot Builders'), findsNothing);
      expect(find.byIcon(Icons.support_agent_rounded), findsNothing);

      // The widget itself should take zero layout space
      final renderBox = tester
          .renderObject<RenderBox>(find.byType(AdminReplyBlock));
      expect(renderBox.size, Size.zero);
    });

    testWidgets('renders nothing when adminResponse is empty string',
        (tester) async {
      _widenView(tester);

      await tester.pumpWidget(
        _wrap(
          const AdminReplyBlock(
            adminResponse: '',
            adminRespondedAt: null,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Response from Walldot Builders'), findsNothing);
    });
  });
}
