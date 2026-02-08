// Web-specific configuration for deployment
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class WebConfig {
  static void initialize() {
    // Set up web-specific configurations
    _setupViewport();
    _setupMetaTags();
  }

  static void _setupViewport() {
    // Ensure proper viewport configuration
    final viewport = html.document.querySelector('meta[name="viewport"]');
    if (viewport == null) {
      final meta = html.MetaElement()
        ..name = 'viewport'
        ..content =
            'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
      html.document.head?.append(meta);
    }
  }

  static void _setupMetaTags() {
    // Add any additional meta tags needed for web deployment
    final meta = html.MetaElement()
      ..name = 'theme-color'
      ..content = '#0175C2';
    html.document.head?.append(meta);
  }
}
