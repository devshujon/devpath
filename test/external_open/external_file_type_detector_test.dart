import 'package:devpath/features/external_open/models/external_file_kind.dart';
import 'package:devpath/features/external_open/services/external_file_type_detector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExternalFileTypeDetector', () {
    test('detects HTML from mime and extension', () {
      expect(
        ExternalFileTypeDetector.detect(
          mimeType: 'text/html',
          displayName: null,
          uriString: null,
        ),
        ExternalFileKind.html,
      );
      expect(
        ExternalFileTypeDetector.detect(
          mimeType: 'application/octet-stream',
          displayName: 'page.htm',
          uriString: null,
        ),
        ExternalFileKind.html,
      );
    });

    test('detects CSS, JS, JSON, XML', () {
      expect(
        ExternalFileTypeDetector.detect(
          mimeType: 'text/css',
          displayName: 'a.css',
          uriString: null,
        ),
        ExternalFileKind.css,
      );
      expect(
        ExternalFileTypeDetector.detect(
          mimeType: 'application/javascript',
          displayName: 'app.js',
          uriString: null,
        ),
        ExternalFileKind.javascript,
      );
      expect(
        ExternalFileTypeDetector.detect(
          mimeType: 'application/json',
          displayName: 'data.json',
          uriString: null,
        ),
        ExternalFileKind.json,
      );
      expect(
        ExternalFileTypeDetector.detect(
          mimeType: 'text/xml',
          displayName: 'feed.xml',
          uriString: null,
        ),
        ExternalFileKind.xml,
      );
    });

    test('unsupported when mime and extension unknown', () {
      expect(
        ExternalFileTypeDetector.detect(
          mimeType: 'image/png',
          displayName: 'photo.png',
          uriString: null,
        ),
        ExternalFileKind.unsupported,
      );
    });
  });
}
