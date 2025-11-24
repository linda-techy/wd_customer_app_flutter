import 'package:flutter/material.dart';
import '../design_tokens/app_breakpoints.dart';

/// Responsive builder widget that builds different layouts based on screen size
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context) mobile;
  final Widget Function(BuildContext context)? tablet;
  final Widget Function(BuildContext context)? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (AppBreakpoints.isDesktop(context) && desktop != null) {
          return desktop!(context);
        }
        if (AppBreakpoints.isTablet(context) && tablet != null) {
          return tablet!(context);
        }
        return mobile(context);
      },
    );
  }
}

/// Responsive value that returns different values based on screen size
class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T? desktop;

  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  T getValue(BuildContext context) {
    if (AppBreakpoints.isDesktop(context) && desktop != null) {
      return desktop!;
    }
    if (AppBreakpoints.isTablet(context) && tablet != null) {
      return tablet!;
    }
    return mobile;
  }
}

/// Extension on BuildContext for easier responsive values
extension ResponsiveExtension on BuildContext {
  bool get isMobile => AppBreakpoints.isMobile(this);
  bool get isTablet => AppBreakpoints.isTablet(this);
  bool get isDesktop => AppBreakpoints.isDesktop(this);

  DeviceType get deviceType => AppBreakpoints.getDeviceType(this);

  int get gridColumns => AppBreakpoints.getGridColumns(this);
  double get gutterSize => AppBreakpoints.getGutterSize(this);
  double get marginSize => AppBreakpoints.getMarginSize(this);
}
