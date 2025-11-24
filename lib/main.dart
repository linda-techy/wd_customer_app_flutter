import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'route/route_constants.dart';
import 'route/router.dart' as router;
import 'theme/app_theme.dart';
import 'services/auth_service.dart';

void main() {
  // Web-specific initialization
  if (kIsWeb) {
    // Configure web-specific settings
    _configureWeb();
  }

  runApp(const MyApp());
}

void _configureWeb() {
  // Web-specific configuration
  // This helps with web deployment issues
}

// Thanks for using our template. You are using the free version of the template.
// 🔗 Full template: https://theflutterway.gumroad.com/l/fluttershop

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Walldot Builders',
      theme: AppTheme.lightTheme(context),
      // Dark theme is inclided in the Full template
      themeMode: ThemeMode.light,
      onGenerateRoute: router.generateRoute,
      home: const InitialScreen(),
    );
  }
}

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  String _initialRoute = onbordingScreenRoute;

  @override
  void initState() {
    super.initState();
    _checkInitialRoute();
  }

  Future<void> _checkInitialRoute() async {
    final hasSeenWelcome = await AuthService.hasSeenWelcome();
    if (hasSeenWelcome) {
      setState(() {
        _initialRoute = entryPointScreenRoute;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Walldot Builders',
      theme: AppTheme.lightTheme(context),
      themeMode: ThemeMode.light,
      onGenerateRoute: router.generateRoute,
      initialRoute: _initialRoute,
    );
  }
}
