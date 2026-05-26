import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../main.dart' show MyApp;
import '../route/route_constants.dart';
import 'auth_service.dart';

/// Centralised "the session is over — send the user to login" handler.
///
/// Two code paths can determine that the customer's session is no longer
/// usable, and BOTH funnel through here so the behaviour is identical:
///
///  1. [AuthInterceptor] — a real server 401/403 that survives a token refresh.
///  2. Service-layer pre-flight checks (e.g. [DashboardService]) — when no
///     valid access token can be produced before a request is even sent.
///
/// Before this existed, path (2) only returned an error string, so the screen
/// showed a "Retry" button that could never succeed (re-running the same
/// no-token check) — leaving the customer stuck. Routing both paths here
/// guarantees a redirect to login instead.
///
/// Copy note: customers don't know what a "token" is, so the user-facing
/// message says "session expired", never "token".
class SessionManager {
  SessionManager._();

  /// User-facing copy for an expired/absent session. Deliberately jargon-free
  /// (no "token").
  static const String sessionExpiredMessage = 'Session expired. Please log in again.';

  /// Guards against redirect storms: when many in-flight requests fail at
  /// once, only the first triggers the navigation; the rest no-op until the
  /// post-frame callback completes.
  static bool _redirecting = false;

  /// Clears auth data and navigates to the login screen (wiping the back
  /// stack), surfacing [sessionExpiredMessage] via a SnackBar. Safe to call
  /// from anywhere — uses the global navigator/messenger keys and defers
  /// navigation to the next frame so it never runs mid-build or inside a Dio
  /// handler callback.
  static Future<void> expireSession({String reason = ''}) async {
    if (_redirecting) return;
    _redirecting = true;

    if (kDebugMode) {
      debugPrint('SessionManager: expiring session — $reason');
    }

    try {
      await AuthService.clearAllAuthData();
    } catch (_) {
      // best-effort cleanup
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final nav = MyApp.navigatorKey.currentState;
      if (nav != null) {
        nav.pushNamedAndRemoveUntil(logInScreenRoute, (route) => false);
      }
      final messenger = MyApp.scaffoldMessengerKey.currentState;
      if (messenger != null) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(const SnackBar(
          content: Text(sessionExpiredMessage),
          duration: Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ));
      }
      _redirecting = false;
    });
  }
}
