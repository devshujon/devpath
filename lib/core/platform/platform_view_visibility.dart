import 'platform_view_gate.dart';

/// Shared rule for when embedded WebViews may attach to the view hierarchy.
bool platformWebViewShouldShow({
  required bool routeSubscribedVisible,
  required bool routeIsCurrent,
}) {
  if (PlatformViewGate.instance.isSuspended) return false;
  return routeSubscribedVisible && routeIsCurrent;
}
