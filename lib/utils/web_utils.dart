import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Utility class for web-specific functionality
class WebUtils {
  /// Check if running on web platform
  static bool get isWeb => kIsWeb;

  /// Create a web-safe SVG widget with proper error handling
  static Widget createSvgIcon(
    String assetPath, {
    double? height,
    double? width,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    if (isWeb) {
      return SvgPicture.asset(
        assetPath,
        height: height,
        width: width,
        colorFilter:
            color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
        fit: fit,
        placeholderBuilder: (context) => Container(
          height: height ?? 24,
          width: width ?? 24,
          color: Colors.grey[300],
        ),
      );
    } else {
      return SvgPicture.asset(
        assetPath,
        height: height,
        width: width,
        colorFilter:
            color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
        fit: fit,
      );
    }
  }

  /// Create a web-safe image widget
  static Widget createImage(
    String imagePath, {
    double? height,
    double? width,
    BoxFit fit = BoxFit.cover,
  }) {
    if (isWeb) {
      return Image.asset(
        imagePath,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height,
            width: width,
            color: Colors.grey[300],
            child: const Icon(Icons.error, color: Colors.grey),
          );
        },
      );
    } else {
      return Image.asset(
        imagePath,
        height: height,
        width: width,
        fit: fit,
      );
    }
  }
}
