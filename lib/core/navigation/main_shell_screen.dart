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
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          navigationShell,
          // Scrollable content sits behind the floating nav (extendBody).
          // Without this, whatever happens to rest at that scroll position
          // shows a hard-edged rectangle poking out from behind the pill.
          // Fading it into the background here makes that read as
          // intentional, the way Instagram/Spotify's floating nav bars do.
          IgnorePointer(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      backgroundColor.withValues(alpha: 0),
                      backgroundColor.withValues(alpha: 0.9),
                      backgroundColor,
                    ],
                    stops: const [0.0, 0.65, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
      ),
    );
  }
}
