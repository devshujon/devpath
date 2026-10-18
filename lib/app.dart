import 'package:flutter/material.dart';

import 'core/routing/app_route_observer.dart';
import 'core/routing/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/external_open/services/android_open_file_bridge.dart';
import 'features/external_open/services/external_open_coordinator.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class DevPathApp extends StatefulWidget {
  const DevPathApp({super.key});

  @override
  State<DevPathApp> createState() => _DevPathAppState();
}

class _DevPathAppState extends State<DevPathApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ExternalOpenCoordinator.instance.attachNavigator(rootNavigatorKey);
    AndroidOpenFileBridge.installPlatformHandler(
      () => ExternalOpenCoordinator.instance.checkForPendingOpen(force: true),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ExternalOpenCoordinator.instance.checkForPendingOpen();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ExternalOpenCoordinator.instance.checkForPendingOpen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DevPath',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      navigatorKey: rootNavigatorKey,
      initialRoute: AppRoutes.shell,
      routes: AppRoutes.routes,
      navigatorObservers: [appRouteObserver],
    );
  }
}
