import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

typedef MockHandler = Future<ResponseBody> Function(RequestOptions options);

/// Minimal hand-rolled Dio adapter for tests. Register a handler per
/// (method, path) pair via [onGet]; calls without a registered handler
/// throw a [StateError]. No external mocking package needed.
///
/// Pattern mirrors the portal-app's
/// `test/test_helpers/mock_dio_adapter.dart`.
class MockDioAdapter implements HttpClientAdapter {
  final Map<String, MockHandler> _handlers = {};
  final IOHttpClientAdapter _fallback = IOHttpClientAdapter();

  void onGet(String path, MockHandler handler) {
    _handlers['GET $path'] = handler;
  }

  @override
  Future<ResponseBody> fetch(
      RequestOptions options,
      Stream<Uint8List>? requestStream,
      Future<dynamic>? cancelFuture) async {
    final key = '${options.method} ${options.path}';
    final handler = _handlers[key];
    if (handler == null) {
      throw StateError('No mock handler registered for $key');
    }
    return handler(options);
  }

  @override
  void close({bool force = false}) {
    _fallback.close(force: force);
  }
}

/// Helper to build a JSON ResponseBody for a mock handler.
ResponseBody jsonResponse(Object body, {int statusCode = 200}) {
  final bytes = utf8.encode(jsonEncode(body));
  return ResponseBody.fromBytes(
    bytes,
    statusCode,
    headers: {
      Headers.contentTypeHeader: ['application/json'],
    },
  );
}
