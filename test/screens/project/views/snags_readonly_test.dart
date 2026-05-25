import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wd_cust_mobile_app/screens/project/views/snags_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const secureStorageChannel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

  setUp(() {
    // Initialize dotenv with empty content so ApiConfig.baseUrl resolves to
    // its hardcoded fallback (http://localhost:8081) instead of throwing.
    dotenv.loadFromString(isOptional: true);

    // Token present -> _initialize() builds the service and loads snags.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (call) async {
      if (call.method == 'read') return 'test-token';
      if (call.method == 'readAll') return <String, String>{};
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, null);
  });

  testWidgets('SnagsScreen has no Add FAB (read-only for customers)',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MaterialApp(
      home: SnagsScreen(projectId: 'proj-50-uuid'),
    ));
    await tester.pump(); // let initState futures schedule
    await tester.pump(const Duration(milliseconds: 50)); // setState applied

    // FAB suppression is unconditional per audit Card 4.2 (snags are
    // Portal/PM-authored; the customer app never offers a create affordance).
    expect(find.byType(FloatingActionButton), findsNothing);
  });
}
