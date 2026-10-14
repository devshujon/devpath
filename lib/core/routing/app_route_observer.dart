import 'package:flutter/material.dart';

/// Global route observer for pausing platform views (WebView) when a route
/// is covered by another screen — prevents Android overlay glitches.
final RouteObserver<ModalRoute<void>> appRouteObserver =
    RouteObserver<ModalRoute<void>>();
