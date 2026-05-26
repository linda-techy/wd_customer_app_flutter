import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';
import 'session_manager.dart';

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

  /// Clears auth and bounces the user to login. Delegates to [SessionManager]
  /// so this (server 401/403) path and the service-layer pre-flight checks
  /// behave identically. SessionManager owns the redirect-storm guard and the
  /// user-facing "session expired" copy.
  Future<void> _forceLogout(String reason) async {
    await SessionManager.expireSession(reason: 'interceptor: $reason');
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
