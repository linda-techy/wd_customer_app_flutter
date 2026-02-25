import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'route/route_constants.dart';
import 'route/router.dart' as router;
import 'theme/app_theme.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env based on APP_ENV (--dart-define=APP_ENV=staging|production)
  const appEnv = String.fromEnvironment('APP_ENV', defaultValue: '');
  if (appEnv == 'staging') {
    await dotenv.load(fileName: 'assets/env/.env', overrideWithFiles: ['assets/env/.env.staging']);
  } else if (appEnv == 'production') {
    await dotenv.load(fileName: 'assets/env/.env', overrideWithFiles: ['assets/env/.env.production']);
  } else {
    await dotenv.load(fileName: 'assets/env/.env');
  }

  // Web-specific initialization
  if (kIsWeb) {
    _configureWeb();
  }

  runApp(const MyApp());
}

void _configureWeb() {
  // Web-specific configuration
  // This helps with web deployment issues
}

// Thanks for using our template. You are using the free version of the template.
// Full template: https://theflutterway.gumroad.com/l/fluttershop

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late final AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() {
    _appLinks = AppLinks();

    // Handle deep link that opened the app from cold start
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    });

    // Handle deep links while the app is already running
    _appLinks.uriLinkStream.listen(_handleDeepLink);
  }

  void _handleDeepLink(Uri uri) {
    if (uri.path == '/reset-password' &&
        (uri.host == 'app.walldotbuilders.com' || uri.host.isEmpty)) {
      final token = uri.queryParameters['token'];
      final email = uri.queryParameters['email'];
      if (token != null && token.isNotEmpty && email != null && email.isNotEmpty) {
        _navigatorKey.currentState?.pushNamed(
          resetPasswordScreenRoute,
          arguments: {'token': token, 'email': email},
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Walldot Builders',
      theme: AppTheme.lightTheme(context),
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
