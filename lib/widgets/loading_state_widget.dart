import 'package:flutter/material.dart';
import '../constants.dart';

/// Reusable loading state widget — a centered spinner with an optional label.
/// Use instead of ad-hoc `Center(child: CircularProgressIndicator())` patterns.
///
/// Usage:
/// ```dart
/// if (_isLoading) return const LoadingStateWidget();
/// if (_isLoading) return const LoadingStateWidget(label: 'Loading reports…');
/// ```
class LoadingStateWidget extends StatelessWidget {
  final String? label;
  final Color color;

  const LoadingStateWidget({
    super.key,
    this.label,
    this.color = primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: color, strokeWidth: 3),
          if (label != null) ...[
            const SizedBox(height: 16),
            Text(
              label!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: blackColor60),
            ),
          ],
        ],
      ),
    );
  }
}
