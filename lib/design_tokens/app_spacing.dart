/// Design token system for spacing
/// Provides consistent spacing scale across the application
class AppSpacing {
  // Base spacing scale (8dp grid system)
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // Component-specific spacing
  static const double cardPadding = md;
  static const double cardMargin = sm;
  static const double buttonPadding = md;
  static const double inputPadding = md;
  static const double sectionSpacing = lg;
  static const double pageMargin = md;

  // Grid gutters (responsive)
  static const double mobileGutter = md;
  static const double tabletGutter = lg;
  static const double desktopGutter = xl;

  // Touch target minimum (accessibility)
  static const double minTouchTarget = 48.0;
  static const double minTouchTargetMobile = 48.0;
  static const double minTouchTargetTablet = 56.0;

  // Border radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusFull = 9999.0;

  // Elevation (for shadows)
  static const double elevation1 = 2.0;
  static const double elevation2 = 4.0;
  static const double elevation3 = 8.0;
  static const double elevation4 = 16.0;
}
