import 'package:devpath/features/curriculum/widgets/figure_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('figure WebView hidden when route is covered', () {
    expect(
      figureWebViewShouldShow(
        routeSubscribedVisible: false,
        routeIsCurrent: true,
      ),
      isFalse,
    );
    expect(
      figureWebViewShouldShow(
        routeSubscribedVisible: true,
        routeIsCurrent: false,
      ),
      isFalse,
    );
    expect(
      figureWebViewShouldShow(
        routeSubscribedVisible: true,
        routeIsCurrent: true,
      ),
      isTrue,
    );
  });
}
