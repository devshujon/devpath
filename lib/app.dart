import 'package:flutter/material.dart';

import 'core/routing/app_routes.dart';
import 'core/theme/app_theme.dart';

class DevPathApp extends StatelessWidget {
  const DevPathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DevPath',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.shell,
      routes: AppRoutes.routes,
    );
  }
}
