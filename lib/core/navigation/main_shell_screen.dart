import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/navigation/app_bottom_nav_bar.dart';

/// Main Shell Screen
///
/// This screen wraps all main app screens and provides the bottom navigation bar.
/// It manages the navigation state using GoRouter's StatefulShellRoute.
class MainShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellScreen({
    super.key,
    required this.navigationShell,
  });

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
      ),
    );
  }
}
