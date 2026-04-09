import 'dart:async';
import 'package:flutter/foundation.dart';

/// Debounces repeated calls to a function, executing it only after
/// [delay] has elapsed since the last invocation.
///
/// Typical usage — debounce search-field onChange:
/// ```dart
/// final _debouncer = Debouncer(delay: const Duration(milliseconds: 500));
///
/// TextField(
///   onChanged: (value) => _debouncer.run(() => _loadData(search: value)),
/// )
///
/// @override
/// void dispose() {
///   _debouncer.dispose();
///   super.dispose();
/// }
/// ```
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 500)});

  /// Schedule [action] to run after [delay].
  /// Cancels any pending scheduled call first.
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Cancel any pending call and release the timer.
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
