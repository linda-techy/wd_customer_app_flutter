// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

/// Web implementation for PDF operations
/// Opens PDF in a new browser tab

void openPdfInNewTab(Uint8List bytes) {
  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.window.open(url, '_blank'); // ignore: unsafe_html - opening a local blob URL for PDF download
  html.Url.revokeObjectUrl(url);
}

