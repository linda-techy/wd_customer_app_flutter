import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';

/// Dio interceptor that handles JWT token lifecycle transparently.
///
/// On every request: injects the current access token from secure storage.
/// On 401 response: refreshes the token once, retries the original request.
/// On refresh failure: clears auth data (forces re-login on next navigation).
///
/// Concurrent 401s are coalesced: if multiple requests fail simultaneously,
/// only one refresh call is made; the others wait for it to complete.
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
    if (err.response?.statusCode != 401) {
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
      debugPrint('AuthInterceptor: 401 received for $path — attempting refresh');
    }

    final refreshed = await _tryRefresh();

    if (!refreshed) {
      if (kDebugMode) {
        debugPrint('AuthInterceptor: refresh failed — clearing auth data');
      }
      await AuthService.clearAllAuthData();
      handler.next(err);
      return;
    }

    // Retry the original request with the fresh token
    try {
      final freshToken = await AuthService.getAccessToken();
      if (freshToken == null) {
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
      handler.next(retryErr);
    }
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
