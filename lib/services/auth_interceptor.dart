import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../main.dart' show MyApp;
import '../route/route_constants.dart';
import 'auth_service.dart';

/// Dio interceptor that handles JWT token lifecycle transparently.
///
/// On every request: injects the current access token from secure storage.
/// On 401 OR 403 response: refreshes the token once, retries the original
/// request. The customer-api returns 403 (not 401) when the JWT is missing
/// or expired (Spring's Http403ForbiddenEntryPoint), so both codes are
/// treated as auth-recovery candidates.
/// On refresh failure or a second auth-rejection after retry: clears auth
/// data and navigates to the login screen via the global navigator key.
///
/// Concurrent 401/403s are coalesced: if a refresh is already in progress,
/// subsequent callers wait for the same result instead of firing parallel
/// refreshes (which would burn rate-limit tokens and race on storage).
class AuthInterceptor extends Interceptor {
  final Dio _dio;

  Completer<bool>? _refreshCompleter;

  /// Set to true once we've kicked off a logout-redirect. Prevents repeated
  /// pushReplacementNamed calls when many in-flight requests all fail at once.
  static bool _loggingOut = false;

  AuthInterceptor(this._dio);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip auth header for public endpoints (login, register, forgot/reset password)
    final path = options.path;
    if (_isPublicEndpoint(path)) {
      handler.next(options);
      return;
    }

    final token = await AuthService.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final status = err.response?.statusCode;
    if (status != 401 && status != 403) {
      handler.next(err);
      return;
    }

    // Don't retry auth endpoints themselves (prevents infinite loops)
    final path = err.requestOptions.path;
    if (_isAuthEndpoint(path)) {
      handler.next(err);
      return;
    }

    if (kDebugMode) {
      debugPrint('AuthInterceptor: $status received for $path — attempting refresh');
    }

    final refreshed = await _tryRefresh();

    if (!refreshed) {
      await _forceLogout('refresh failed after $status');
      handler.next(err);
      return;
    }

    // Retry the original request with the fresh token
    try {
      final freshToken = await AuthService.getAccessToken();
      if (freshToken == null) {
        await _forceLogout('no token after refresh');
        handler.next(err);
        return;
      }

      final opts = err.requestOptions;
      opts.headers['Authorization'] = 'Bearer $freshToken';

      if (kDebugMode) {
        debugPrint('AuthInterceptor: retrying ${opts.method} ${opts.path}');
      }

      final response = await _dio.fetch(opts);
      handler.resolve(response);
    } on DioException catch (retryErr) {
      // Still rejected after a successful refresh — token isn't the
      // problem (or refresh issued a token that's also invalid). Treat
      // this as a hard logout signal so the user isn't stuck on a screen
      // that can never load.
      final retryStatus = retryErr.response?.statusCode;
      if (retryStatus == 401 || retryStatus == 403) {
        await _forceLogout('still $retryStatus after refresh+retry');
      }
      handler.next(retryErr);
    }
  }

  Future<void> _forceLogout(String reason) async {
    if (_loggingOut) return;
    _loggingOut = true;
    if (kDebugMode) {
      debugPrint('AuthInterceptor: forcing logout — $reason');
    }
    try {
      await AuthService.clearAllAuthData();
    } catch (_) {
      // best-effort cleanup
    }
    // Navigate to login on the next frame so we don't push during a build
    // or while a Dio handler is mid-callback. Surface a friendly SnackBar
    // so the customer understands why they landed back on the login page
    // (otherwise the redirect looks like a random app glitch).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final nav = MyApp.navigatorKey.currentState;
      if (nav != null) {
        nav.pushNamedAndRemoveUntil(logInScreenRoute, (route) => false);
      }
      final messenger = MyApp.scaffoldMessengerKey.currentState;
      if (messenger != null) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(const SnackBar(
          content: Text('Your session has expired. Please log in again.'),
          duration: Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ));
      }
      _loggingOut = false;
    });
  }

  /// Coalesces concurrent refresh attempts. If a refresh is already in progress,
  /// subsequent callers wait for the same result instead of firing parallel
  /// refresh requests (which would burn rate-limit tokens and race on storage).
  Future<bool> _tryRefresh() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<bool>();

    try {
      final success = await AuthService.refreshAccessToken();
      _refreshCompleter!.complete(success);
      return success;
    } catch (e) {
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }

  bool _isPublicEndpoint(String path) {
    return path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/forgot-password') ||
        path.contains('/auth/reset-password');
  }

  bool _isAuthEndpoint(String path) {
    return path.contains('/auth/');
  }
}
