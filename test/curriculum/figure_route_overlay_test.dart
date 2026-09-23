import 'package:devpath/core/platform/platform_view_gate.dart';
import 'package:devpath/core/platform/platform_view_visibility.dart';
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

  test('platform gate suspends all web views', () {
    PlatformViewGate.instance.suspend();
    addTearDown(PlatformViewGate.instance.resume);
    expect(
      platformWebViewShouldShow(
        routeSubscribedVisible: true,
        routeIsCurrent: true,
      ),
      isFalse,
    );
  });
}
