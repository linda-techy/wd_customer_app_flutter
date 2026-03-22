import 'package:app_links/app_links.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'route/route_constants.dart';
import 'route/router.dart' as router;
import 'theme/app_theme.dart';
import 'services/auth_service.dart';
import 'providers/theme_provider.dart';
import 'services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register FCM background handler before runApp()
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

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

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

void _configureWeb() {
  // Web-specific configuration
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _deepLinkSub;
  Uri? _pendingDeepLink;
  String? _lastHandledResetSignature;
  bool _navigatedToResetFromDeepLink = false;
  String _initialRoute = onbordingScreenRoute;

  @override
  void initState() {
    super.initState();
    _checkInitialRoute();
    _handleInitialWebUrl();
    _initDeepLinks();
  }

  void _handleInitialWebUrl() {
    if (!kIsWeb) return;
    _queueOrHandleDeepLink(Uri.base);
  }

  void _initDeepLinks() {
    _appLinks = AppLinks();

    // Handle deep link that opened the app from cold start
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        _queueOrHandleDeepLink(uri);
      }
    }).catchError((error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[DeepLink] Failed to read initial link: $error');
      }
    });

    // Handle deep links while the app is already running
    _deepLinkSub = _appLinks.uriLinkStream.listen(
      _queueOrHandleDeepLink,
      onError: (Object error, StackTrace stackTrace) {
        if (kDebugMode) {
          debugPrint('[DeepLink] Stream error: $error');
        }
      },
    );
  }

  void _queueOrHandleDeepLink(Uri uri) {
    final routePayload = _extractResetPayload(uri);
    if (routePayload == null) return;

    _pendingDeepLink = uri;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _drainPendingDeepLink();
    });
  }

  Map<String, String>? _extractResetPayload(Uri uri) {
    final scheme = uri.scheme.toLowerCase();
    final host = uri.host.toLowerCase();
    final normalizedPath = _normalizePath(uri.path);
    final fragment = uri.fragment.startsWith('/')
        ? uri.fragment
        : '/${uri.fragment}';
    final normalizedFragmentPath = _normalizePath(Uri.parse(fragment).path);

    final supportsHttpsHost = scheme == 'https' && host == 'app.walldotbuilders.com';
    final supportsCustomScheme = scheme == 'wdcustapp';
    final supportsWebHost = kIsWeb && (scheme == 'https' || scheme == 'http');
    final looksLikeResetPath = _looksLikeResetPath(normalizedPath)
        || _looksLikeResetPath(normalizedFragmentPath)
        || host == 'reset-password'
        || host == 'reset_password';

    if (!(looksLikeResetPath && (supportsHttpsHost || supportsCustomScheme || supportsWebHost || host.isEmpty))) {
      return null;
    }

    final fragmentQuery = Uri.parse(fragment).queryParameters;
    final mergedQueryParams = <String, String>{
      ...fragmentQuery,
      ...uri.queryParameters,
    };
    final token = _readFirstNonEmpty(
      mergedQueryParams,
      const ['token', 'resetCode', 'reset_code', 'code'],
    );
    final email = _readFirstNonEmpty(
      mergedQueryParams,
      const ['email', 'userEmail', 'user_email'],
    );
    if (token == null || token.isEmpty || email == null || email.isEmpty) {
      return null;
    }

    return {'token': token, 'email': email};
  }

  String _normalizePath(String path) {
    if (path.isEmpty) return '/';
    final normalized = path.endsWith('/') && path.length > 1
        ? path.substring(0, path.length - 1)
        : path;
    return normalized.toLowerCase();
  }

  bool _looksLikeResetPath(String normalizedPath) {
    if (normalizedPath == '/reset-password' || normalizedPath == '/reset_password') {
      return true;
    }
    final segments = normalizedPath.split('/').where((s) => s.isNotEmpty).toList();
    return segments.isNotEmpty
        && (segments.last == 'reset-password' || segments.last == 'reset_password');
  }

  String? _readFirstNonEmpty(Map<String, String> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key]?.trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  void _drainPendingDeepLink() {
    final pending = _pendingDeepLink;
    if (pending == null) return;

    final payload = _extractResetPayload(pending);
    if (payload == null) {
      _pendingDeepLink = null;
      return;
    }

    final navigator = _navigatorKey.currentState;
    if (navigator == null) {
      // Navigator may be unavailable during startup; retry shortly.
      Future.delayed(const Duration(milliseconds: 100), _drainPendingDeepLink);
      return;
    }

    final signature = '${payload['email']}:${payload['token']}';
    if (signature == _lastHandledResetSignature) {
      _pendingDeepLink = null;
      return;
    }

    _pendingDeepLink = null;
    _lastHandledResetSignature = signature;
    _navigatedToResetFromDeepLink = true;
    navigator.pushNamed(
      resetPasswordScreenRoute,
      arguments: payload,
    );
  }

  Future<void> _checkInitialRoute() async {
    final hasSeenWelcome = await AuthService.hasSeenWelcome();
    if (!mounted || !hasSeenWelcome) return;
    if (_pendingDeepLink != null || _navigatedToResetFromDeepLink) return;
    setState(() {
      _initialRoute = entryPointScreenRoute;
    });
  }

  @override
  void dispose() {
    _deepLinkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      key: ValueKey<String>(_initialRoute),
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Walldot Builders',
      theme: AppTheme.lightTheme(context),
      darkTheme: AppTheme.darkTheme(context),
      themeMode: themeProvider.themeMode,
      onGenerateRoute: router.generateRoute,
      initialRoute: _initialRoute,
    );
  }
}
