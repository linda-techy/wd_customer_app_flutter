import 'package:flutter/material.dart';

/// Design token system for app colors
/// Provides consistent color palette across the application
class AppColors {
  // Brand Colors
  static const Color logoRed = Color(0xFFD32F2F);
  static const Color logoPink = Color(0xFFE91E63);
  static const Color logoBlue = Color(0xFF5C6BC0);

  // Primary & Secondary
  static const Color primary = logoRed;
  static const Color primaryDark = Color(0xFFB71C1C);
  static const Color primaryLight = Color(0xFFEF5350);
  static const Color secondary = logoBlue;
  static const Color secondaryDark = Color(0xFF3949AB);
  static const Color secondaryLight = Color(0xFF7986CB);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);

  static const Color warning = Color(0xFFFFA726);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFF57C00);

  static const Color error = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFE57373);
  static const Color errorDark = Color(0xFFC62828);

  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);
  static const Color infoDark = Color(0xFF1976D2);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Background Colors
  static const Color backgroundLight = white;
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = grey50;
  static const Color surfaceDark = Color(0xFF1E1E2E);

  // Text Colors
  static const Color textPrimary = grey900;
  static const Color textSecondary = grey700;
  static const Color textDisabled = grey400;
  static const Color textHint = grey500;

  static const Color textPrimaryDark = white;
  static const Color textSecondaryDark = grey300;
  static const Color textDisabledDark = grey600;

  // Status Colors (for project cards, etc.)
  static const Color statusActive = success;
  static const Color statusPending = warning;
  static const Color statusCompleted = grey600;
  static const Color statusCancelled = error;

  // Overview Card Colors
  static const Color projectProgressCard = Color(0xFF3949AB);
  static const Color paymentsCard = Color(0xFFD84940);
  static const Color qualityCard = Color(0xFFFFA726);

  // Get color by status
  static Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return statusActive;
      case 'PENDING':
        return statusPending;
      case 'COMPLETED':
        return statusCompleted;
      case 'CANCELLED':
        return statusCancelled;
      default:
        return info;
    }
  }

  // Get progress color by percentage
  static Color getProgressColor(double progress) {
    if (progress < 30) return error;
    if (progress < 70) return warning;
    return success;
  }

  // Phase colors (for project phase badges/steppers)
  static Color getPhaseColor(String? phaseValue) {
    if (phaseValue == null || phaseValue.isEmpty) return info;
    final p = phaseValue.trim().toUpperCase().replaceAll(' ', '_');
    switch (p) {
      case 'PLANNING':
        return info;
      case 'DESIGN':
        return secondary;
      case 'EXECUTION':
      case 'CONSTRUCTION':
        return warning;
      case 'COMPLETION':
      case 'HANDOVER':
      case 'WARRANTY':
      case 'COMPLETED':
        return success;
      case 'ON_HOLD':
        return error;
      default:
        return info;
    }
  }
}
