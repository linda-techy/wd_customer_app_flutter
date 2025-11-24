import 'package:flutter/material.dart';

/// Responsive breakpoints for the application
/// Follows Material Design 3 responsive layout guidelines
class AppBreakpoints {
  // Breakpoint values (in dp/logical pixels)
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1440;
  static const double largeDesktop = 1920;

  // Check device type
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < desktop;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktop;
  }

  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= largeDesktop;
  }

  // Get device type enum
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobile) return DeviceType.mobile;
    if (width < desktop) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  // Grid columns based on device
  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) return 4;
    if (isTablet(context)) return 8;
    return 12;
  }

  // Gutter size based on device
  static double getGutterSize(BuildContext context) {
    if (isMobile(context)) return 16;
    if (isTablet(context)) return 24;
    return 32;
  }

  // Margin size based on device
  static double getMarginSize(BuildContext context) {
    if (isMobile(context)) return 16;
    if (isTablet(context)) return 24;
    return 40;
  }
}

/// Device type enum
enum DeviceType {
  mobile,
  tablet,
  desktop,
}
