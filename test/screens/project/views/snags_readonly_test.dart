import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wd_cust_mobile_app/screens/project/views/snags_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const secureStorageChannel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

  setUp(() {
    // Initialize dotenv with empty content so ApiConfig.baseUrl resolves to
    // its hardcoded fallback (http://localhost:8081) instead of throwing.
    dotenv.loadFromString(isOptional: true);

    // Token present -> _initialize() proceeds to resolve the user role.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (call) async {
      if (call.method == 'read') return 'test-token';
      if (call.method == 'readAll') return <String, String>{};
      return null;
    });
    // getUserInfo() reads 'user_info' from SharedPreferences; resolve role = CUSTOMER.
    // UserInfo.fromJson reads key 'role' (confirmed in lib/models/api_models.dart).
    SharedPreferences.setMockInitialValues({
      'user_info': jsonEncode({
        'id': 1,
        'email': 'customer@test.com',
        'firstName': 'Test',
        'lastName': 'Customer',
        'role': 'CUSTOMER',
        'phone': '',
        'whatsappNumber': '',
        'address': '',
        'companyName': '',
        'gstNumber': '',
        'customerType': 'individual',
      }),
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, null);
  });

  testWidgets('SnagsScreen shows no Add (create) FAB even for CUSTOMER role',
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
    await tester.pump(const Duration(milliseconds: 50)); // role setState applied

    expect(find.byType(FloatingActionButton), findsNothing);
  });
}
