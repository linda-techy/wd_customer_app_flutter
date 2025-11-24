import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  // Screen size breakpoints
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 650 &&
      MediaQuery.of(context).size.width < 1100;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    // If width is more than 1100 then it's desktop
    if (size.width >= 1100) {
      return desktop;
    }
    // If width is between 650 and 1100 then it's tablet
    else if (size.width >= 650 && tablet != null) {
      return tablet!;
    }
    // Otherwise it's mobile
    else {
      return mobile;
    }
  }
}

// Responsive value helper
class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T desktop;

  ResponsiveValue({
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  T getValue(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return desktop;
    } else if (Responsive.isTablet(context) && tablet != null) {
      return tablet!;
    } else {
      return mobile;
    }
  }
}

// Padding and spacing helpers
class ResponsiveSpacing {
  static double getPadding(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return 32.0;
    } else if (Responsive.isTablet(context)) {
      return 24.0;
    } else {
      return 16.0;
    }
  }

  static double getHorizontalPadding(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return 80.0;
    } else if (Responsive.isTablet(context)) {
      return 40.0;
    } else {
      return 16.0;
    }
  }

  static double getCardPadding(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return 24.0;
    } else if (Responsive.isTablet(context)) {
      return 20.0;
    } else {
      return 16.0;
    }
  }

  static double getGridSpacing(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return 24.0;
    } else if (Responsive.isTablet(context)) {
      return 16.0;
    } else {
      return 12.0;
    }
  }
}

// Grid columns helper
class ResponsiveGrid {
  static int getCrossAxisCount(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return 4;
    } else if (Responsive.isTablet(context)) {
      return 3;
    } else {
      return 2;
    }
  }

  static int getListCrossAxisCount(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return 3;
    } else if (Responsive.isTablet(context)) {
      return 2;
    } else {
      return 1;
    }
  }
}

// Font size helpers
class ResponsiveFontSize {
  static double getHeadline(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return 32.0;
    } else if (Responsive.isTablet(context)) {
      return 28.0;
    } else {
      return 24.0;
    }
  }

  static double getTitle(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return 24.0;
    } else if (Responsive.isTablet(context)) {
      return 20.0;
    } else {
      return 18.0;
    }
  }

  static double getBody(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return 16.0;
    } else if (Responsive.isTablet(context)) {
      return 15.0;
    } else {
      return 14.0;
    }
  }
}

// Max width constraint for centered content on large screens
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ??
              (Responsive.isDesktop(context) ? 1200 : double.infinity),
        ),
        child: child,
      ),
    );
  }
}
