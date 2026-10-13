import 'package:flutter/material.dart';

import '../../../core/platform/platform_view_gate.dart';
import '../../editor/screens/editor_screen.dart';
import '../../learning/screens/dashboard_screen.dart';
import '../../learn/screens/learn_screen.dart';
import '../../profile/screens/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _tabs = <Widget>[
    DashboardScreen(),
    LearnScreen(),
    EditorScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Android platform views (WebView) keep drawing over routes pushed
    // above [MainShell] while their widget stays in an [IndexedStack].
    // Unmount tabs while [PlatformViewGate] suspends (lesson quiz, etc.).
    final gate = PlatformViewGate.instance;
    return ListenableBuilder(
      listenable: gate,
      builder: (context, _) {
        return Scaffold(
          body: gate.isSuspended
              ? const SizedBox.shrink()
              // Only mount the active tab so no hidden subtree keeps platform
              // views alive under [IndexedStack] on Android.
              : KeyedSubtree(
                  key: ValueKey<int>(_index),
                  child: _tabs[_index],
                ),
          bottomNavigationBar: gate.isSuspended
              ? null
              : NavigationBar(
                  selectedIndex: _index,
                  onDestinationSelected: (i) => setState(() => _index = i),
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.school_outlined),
                      selectedIcon: Icon(Icons.school),
                      label: 'Learn',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.code_outlined),
                      selectedIcon: Icon(Icons.code),
                      label: 'Editor',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person),
                      label: 'Profile',
                    ),
                  ],
                ),
        );
      },
    );
  }
}
