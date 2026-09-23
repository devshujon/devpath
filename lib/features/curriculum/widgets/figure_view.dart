import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/platform/platform_view_gate.dart';
import '../../../core/platform/platform_view_visibility.dart';
import '../../../core/routing/app_route_observer.dart';
import '../theme/lesson_type.dart';

/// Whether the figure WebView should be attached (Android draws platform
/// views over routes pushed on top if this stays true).
bool figureWebViewShouldShow({
  required bool routeSubscribedVisible,
  required bool routeIsCurrent,
}) =>
    platformWebViewShouldShow(
      routeSubscribedVisible: routeSubscribedVisible,
      routeIsCurrent: routeIsCurrent,
    );

/// Allow the initial offline document; block http(s) navigations.
bool allowFigureNavigation(String url) {
  final u = url.trim().toLowerCase();
  if (u.isEmpty) return false;
  return u.startsWith('data:') || u.startsWith('about:');
}

/// Offline HTML shell for a figure spec. Remote subresources are blocked
/// by CSP so diagrams never depend on the network.
String wrapFigureHtml(String spec, {required bool isDark}) {
  final fg = isDark ? '#E6E6E6' : '#1A1A1A';
  return '''
<!DOCTYPE html><html><head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
<meta http-equiv="Content-Security-Policy" content="default-src 'none'; img-src data:; style-src 'unsafe-inline';">
<style>
  html,body{margin:0;padding:8px;background:transparent;color:$fg;
    font-family:-apple-system,Roboto,'Segoe UI',sans-serif;font-size:14px;
    -webkit-text-size-adjust:100%;overflow-x:auto;max-width:100%}
  *{box-sizing:border-box;max-width:100%}
  img,svg,canvas{max-width:100%;height:auto}
</style></head><body>$spec</body></html>''';
}

/// Renders a `figure` block's HTML `spec` inside a bounded, display-only
/// WebView. Gesture recognizers are empty so the parent ListView keeps
/// scrolling over the figure (the diagram is static).
///
/// Safety:
/// - width is never allowed to exceed the parent
/// - height is clamped (80–280 on phones)
/// - JavaScript is disabled
/// - navigation away is blocked (offline, no CDN)
/// - a 5s timeout + error callback shows a graceful placeholder
class FigureHtmlView extends StatefulWidget {
  final String spec;
  final double height;

  const FigureHtmlView({super.key, required this.spec, required this.height});

  @override
  State<FigureHtmlView> createState() => _FigureHtmlViewState();
}

class _FigureHtmlViewState extends State<FigureHtmlView> with RouteAware {
  WebViewController? _controller;
  bool _loading = true;
  bool _failed = false;
  Timer? _timeout;
  bool _routeVisible = true;
  ModalRoute<void>? _route;

  @override
  void initState() {
    super.initState();
    PlatformViewGate.instance.addListener(_onGateChanged);
  }

  void _onGateChanged() {
    if (!mounted) return;
    if (_shouldShowWebView) {
      if (_controller == null && !_failed) _initController();
    } else {
      _releaseController();
    }
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != _route) {
      if (_route != null) appRouteObserver.unsubscribe(this);
      _route = route;
      if (route != null) {
        appRouteObserver.subscribe(this, route);
        _routeVisible = route.isCurrent;
      }
    }
    if (_shouldShowWebView && _controller == null && !_failed) {
      _initController();
    }
  }

  @override
  void didPushNext() {
    _routeVisible = false;
    _releaseController();
    if (mounted) setState(() {});
  }

  @override
  void didPopNext() {
    _routeVisible = true;
    if (_shouldShowWebView && _controller == null && !_failed) {
      _initController();
    }
    if (mounted) setState(() {});
  }

  void _releaseController() {
    _timeout?.cancel();
    _controller = null;
    _loading = true;
  }

  void _initController() {
    if (_controller != null) return;
    try {
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.disabled)
        ..setBackgroundColor(Colors.transparent)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (_) {
              _timeout?.cancel();
              if (mounted) setState(() => _loading = false);
            },
            onWebResourceError: (_) {
              _timeout?.cancel();
              // Do not blank a loaded figure because a blocked
              // subresource failed. Only fail when we have no document.
              if (mounted) {
                setState(() {
                  _loading = false;
                  if (_controller == null) _failed = true;
                });
              }
            },
            onNavigationRequest: (request) => allowFigureNavigation(request.url)
                ? NavigationDecision.navigate
                : NavigationDecision.prevent,
          ),
        )
        ..loadHtmlString(wrapFigureHtml(widget.spec, isDark: _isDark));
      _controller = controller;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Curriculum figure failed to start WebView: $e');
      }
      _failed = true;
      _loading = false;
    }

    _timeout = Timer(const Duration(seconds: 5), () {
      if (mounted && _loading) {
        setState(() {
          _loading = false;
          // Timeout without a finished event — keep the view if we have
          // a controller, otherwise show the placeholder.
          if (_controller == null) _failed = true;
        });
      }
    });
  }

  bool get _isDark =>
      WidgetsBinding.instance.platformDispatcher.platformBrightness ==
      Brightness.dark;

  bool get _shouldShowWebView {
    final route = ModalRoute.of(context);
    return figureWebViewShouldShow(
      routeSubscribedVisible: _routeVisible,
      routeIsCurrent: route?.isCurrent ?? true,
    );
  }

  @override
  void dispose() {
    PlatformViewGate.instance.removeListener(_onGateChanged);
    if (_route != null) appRouteObserver.unsubscribe(this);
    _releaseController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maxH = MediaQuery.sizeOf(context).height;
    final height = widget.height.clamp(80.0, maxH < 700 ? 220.0 : 280.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161A21) : const Color(0xFFF7F8FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: lessonBorder(context)),
          ),
          clipBehavior: Clip.antiAlias,
          child: _failed || _controller == null
              ? _Fallback(isDark: isDark)
              : !_shouldShowWebView
                  ? _PausedPlaceholder(isDark: isDark)
                  : Stack(
                      children: [
                        SizedBox.expand(
                          child: WebViewWidget(
                            controller: _controller!,
                            gestureRecognizers: const <
                                Factory<OneSequenceGestureRecognizer>>{},
                          ),
                        ),
                        if (_loading)
                          const Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                      ],
                    ),
        );
      },
    );
  }
}

/// Shown while another route (e.g. lesson quiz) covers the lesson. Avoids
/// Android WebView platform views drawing over the new screen.
class _PausedPlaceholder extends StatelessWidget {
  final bool isDark;
  const _PausedPlaceholder({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Figure paused while another screen is open',
      child: ColoredBox(
        color: isDark ? const Color(0xFF161A21) : const Color(0xFFF7F8FA),
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  final bool isDark;
  const _Fallback({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: isDark ? const Color(0xFF161A21) : const Color(0xFFF7F8FA),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            'Diagram unavailable offline',
            textAlign: TextAlign.center,
            style: LessonType.secondaryStyle(context),
          ),
        ),
      ),
    );
  }
}
