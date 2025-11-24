import 'package:flutter/material.dart';

/// Design token system for typography
/// Provides consistent text styles across the application
class AppTypography {
  // Display styles (large headings)
  static TextStyle displayLarge(BuildContext context) {
    return Theme.of(context).textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ) ??
        const TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        );
  }

  static TextStyle displayMedium(BuildContext context) {
    return Theme.of(context).textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ) ??
        const TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w600,
        );
  }

  static TextStyle displaySmall(BuildContext context) {
    return Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ) ??
        const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w600,
        );
  }

  // Headline styles
  static TextStyle headlineLarge(BuildContext context) {
    return Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ) ??
        const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
        );
  }

  static TextStyle headlineMedium(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ) ??
        const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
        );
  }

  static TextStyle headlineSmall(BuildContext context) {
    return Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ) ??
        const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
        );
  }

  // Title styles
  static TextStyle titleLarge(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ) ??
        const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
        );
  }

  static TextStyle titleMedium(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ) ??
        const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        );
  }

  static TextStyle titleSmall(BuildContext context) {
    return Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ) ??
        const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        );
  }

  // Body styles
  static TextStyle bodyLarge(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge ??
        const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        );
  }

  static TextStyle bodyMedium(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium ??
        const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        );
  }

  static TextStyle bodySmall(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall ??
        const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        );
  }

  // Label styles (for buttons, tabs, etc.)
  static TextStyle labelLarge(BuildContext context) {
    return Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ) ??
        const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        );
  }

  static TextStyle labelMedium(BuildContext context) {
    return Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ) ??
        const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        );
  }

  static TextStyle labelSmall(BuildContext context) {
    return Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ) ??
        const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        );
  }
}
