import 'dart:typed_data';

/// Stub implementation for PDF web operations
/// This is used on non-web platforms

void openPdfInNewTab(Uint8List bytes) {
  throw UnsupportedError('Opening PDF in new tab is only supported on web');
}

