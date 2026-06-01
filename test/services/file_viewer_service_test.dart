import 'package:flutter_test/flutter_test.dart';
import 'package:wd_cust_mobile_app/services/file_viewer_service.dart';

void main() {
  group('FileViewerService.detectFileType — by extension', () {
    test('pdf', () {
      expect(FileViewerService.detectFileType('doc.pdf'), FileType.pdf);
    });

    test('images (jpg/jpeg/png/gif/webp/bmp/svg)', () {
      for (final f in [
        'a.jpg',
        'a.jpeg',
        'a.png',
        'a.gif',
        'a.webp',
        'a.bmp',
        'a.svg',
      ]) {
        expect(FileViewerService.detectFileType(f), FileType.image,
            reason: f);
      }
    });

    test('word (doc/docx/odt/rtf)', () {
      for (final f in ['a.doc', 'a.docx', 'a.odt', 'a.rtf']) {
        expect(FileViewerService.detectFileType(f), FileType.word, reason: f);
      }
    });

    test('excel (xls/xlsx/ods)', () {
      for (final f in ['a.xls', 'a.xlsx', 'a.ods']) {
        expect(FileViewerService.detectFileType(f), FileType.excel, reason: f);
      }
    });

    test('csv', () {
      expect(FileViewerService.detectFileType('data.csv'), FileType.csv);
    });

    test('powerpoint (ppt/pptx/odp)', () {
      for (final f in ['a.ppt', 'a.pptx', 'a.odp']) {
        expect(FileViewerService.detectFileType(f), FileType.powerpoint,
            reason: f);
      }
    });

    test('text (txt/md/log/json/xml)', () {
      for (final f in ['a.txt', 'a.md', 'a.log', 'a.json', 'a.xml']) {
        expect(FileViewerService.detectFileType(f), FileType.text, reason: f);
      }
    });

    test('video (mp4/avi/mov/mkv/flv/wmv)', () {
      for (final f in ['a.mp4', 'a.avi', 'a.mov', 'a.mkv', 'a.flv', 'a.wmv']) {
        expect(FileViewerService.detectFileType(f), FileType.video, reason: f);
      }
    });

    test('audio (mp3/wav/ogg/aac/m4a)', () {
      for (final f in ['a.mp3', 'a.wav', 'a.ogg', 'a.aac', 'a.m4a']) {
        expect(FileViewerService.detectFileType(f), FileType.audio, reason: f);
      }
    });

    test('unknown extension falls through to other', () {
      expect(FileViewerService.detectFileType('a.zip'), FileType.other);
    });

    test('extension match is case-insensitive', () {
      expect(FileViewerService.detectFileType('PHOTO.PNG'), FileType.image);
      expect(FileViewerService.detectFileType('REPORT.PDF'), FileType.pdf);
    });

    test('filename with no extension uses whole string as extension', () {
      // split('.').last on "README" => "README" => not in any list => other
      expect(FileViewerService.detectFileType('README'), FileType.other);
    });
  });

  group('FileViewerService.detectFileType — by mimeType fallback', () {
    // Use an unknown extension so the extension branch falls through to MIME.
    test('pdf mime', () {
      expect(
        FileViewerService.detectFileType('blob.bin',
            mimeType: 'application/pdf'),
        FileType.pdf,
      );
    });

    test('image mime', () {
      expect(
        FileViewerService.detectFileType('blob.bin', mimeType: 'image/jpeg'),
        FileType.image,
      );
    });

    test('word mime variants (msword / document)', () {
      expect(
        FileViewerService.detectFileType('blob.bin', mimeType: 'application/msword'),
        FileType.word,
      );
      expect(
        FileViewerService.detectFileType('blob.bin',
            mimeType:
                'application/vnd.openxmlformats-officedocument.wordprocessingml.document'),
        FileType.word,
      );
    });

    test('excel mime', () {
      // NB: the real OOXML mime contains "-officedocument", which the service
      // matches as word FIRST (word checks `document` before excel). Use mimes
      // that contain "excel"/"spreadsheet" but not "document".
      expect(
        FileViewerService.detectFileType('blob.bin',
            mimeType: 'application/vnd.ms-excel'),
        FileType.excel,
      );
      expect(
        FileViewerService.detectFileType('blob.bin',
            mimeType: 'application/x-spreadsheet'),
        FileType.excel,
      );
    });

    test('csv mime', () {
      expect(
        FileViewerService.detectFileType('blob.bin', mimeType: 'text/csv'),
        FileType.csv,
      );
    });

    test('powerpoint mime', () {
      // Same caveat: real OOXML presentation mime contains "-officedocument"
      // -> matches word first. Use mimes with "powerpoint"/"presentation" but
      // not "document".
      expect(
        FileViewerService.detectFileType('blob.bin',
            mimeType: 'application/vnd.ms-powerpoint'),
        FileType.powerpoint,
      );
      expect(
        FileViewerService.detectFileType('blob.bin',
            mimeType: 'application/x-presentation'),
        FileType.powerpoint,
      );
    });

    test('text mime', () {
      expect(
        FileViewerService.detectFileType('blob.bin', mimeType: 'text/plain'),
        FileType.text,
      );
    });

    test('video mime', () {
      expect(
        FileViewerService.detectFileType('blob.bin', mimeType: 'video/mp4'),
        FileType.video,
      );
    });

    test('audio mime', () {
      expect(
        FileViewerService.detectFileType('blob.bin', mimeType: 'audio/mpeg'),
        FileType.audio,
      );
    });

    test('unrecognized mime returns other', () {
      expect(
        FileViewerService.detectFileType('blob.bin',
            mimeType: 'application/octet-stream'),
        FileType.other,
      );
    });

    test('extension wins over mimeType when both present', () {
      // .png is a known image extension; mime says pdf but extension is checked first.
      expect(
        FileViewerService.detectFileType('a.png', mimeType: 'application/pdf'),
        FileType.image,
      );
    });
  });

  group('FileViewerService.getMimeType', () {
    test('common types map correctly', () {
      expect(FileViewerService.getMimeType('a.pdf'), 'application/pdf');
      expect(FileViewerService.getMimeType('a.png'), 'image/png');
      expect(FileViewerService.getMimeType('a.jpg'), 'image/jpeg');
      expect(FileViewerService.getMimeType('a.txt'), 'text/plain');
      expect(FileViewerService.getMimeType('a.json'), 'application/json');
      expect(FileViewerService.getMimeType('a.mp4'), 'video/mp4');
    });

    test('unknown extension returns null', () {
      expect(FileViewerService.getMimeType('a.unknownext'), isNull);
    });
  });

  group('FileViewerService.canViewInApp & getFileIcon', () {
    test('canViewInApp true for pdf/image/text/csv, false otherwise', () {
      expect(FileViewerService.canViewInApp(FileType.pdf), isTrue);
      expect(FileViewerService.canViewInApp(FileType.image), isTrue);
      expect(FileViewerService.canViewInApp(FileType.text), isTrue);
      expect(FileViewerService.canViewInApp(FileType.csv), isTrue);
      expect(FileViewerService.canViewInApp(FileType.word), isFalse);
      expect(FileViewerService.canViewInApp(FileType.video), isFalse);
    });

    test('getFileIcon returns a non-empty glyph for every FileType', () {
      for (final t in FileType.values) {
        expect(FileViewerService.getFileIcon(t), isNotEmpty, reason: '$t');
      }
    });
  });
}
