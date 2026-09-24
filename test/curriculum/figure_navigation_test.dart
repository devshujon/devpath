import 'package:devpath/features/curriculum/widgets/figure_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('allowFigureNavigation', () {
    test('allows the offline document itself', () {
      expect(allowFigureNavigation('data:text/html;charset=utf-8,<h1>Hi</h1>'), isTrue);
      expect(allowFigureNavigation('about:blank'), isTrue);
      expect(allowFigureNavigation('ABOUT:srcdoc'), isTrue);
    });

    test('blocks remote and script navigations', () {
      expect(allowFigureNavigation('https://example.com'), isFalse);
      expect(allowFigureNavigation('http://127.0.0.1'), isFalse);
      expect(allowFigureNavigation('javascript:alert(1)'), isFalse);
      expect(allowFigureNavigation(''), isFalse);
    });
  });

  test('figure HTML shell is offline-only', () {
    final html = wrapFigureHtml('<p>Hi</p>', isDark: false);
    expect(html.contains("default-src 'none'"), isTrue);
    expect(html.contains("img-src data:"), isTrue);
    expect(html.contains('<p>Hi</p>'), isTrue);
  });
}
