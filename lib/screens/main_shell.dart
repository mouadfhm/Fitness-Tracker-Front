import 'package:flutter/material.dart';
import 'foods_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'workout_root_screen.dart';
import 'widgets/bottom_nav_bar.dart';

/// Holds the four bottom-nav tabs and keeps each one alive while another is
/// showing, so switching back lands where you left it (scroll position,
/// selected week, search text). This is how iOS tab bars behave; replacing
/// the route on every tap rebuilt the tab from scratch.
///
/// The shell draws the one [CustomBottomNavBar] under all tabs, so its
/// selection animates from tab to tab; the bar asks [MainShellScope] to
/// switch instead of pushing a route.
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index = widget.initialIndex;

  /// Tabs are built the first time they are opened, not all at start-up, so
  /// launching the app doesn't fire every tab's network calls at once.
  late final Set<int> _opened = {widget.initialIndex};

  void _select(int index) {
    if (index == _index) return;
    setState(() {
      _index = index;
      _opened.add(index);
    });
  }

  static Widget _buildTab(int index) {
    switch (index) {
      case 1:
        return const WorkoutRootScreen();
      case 2:
        return const FoodsScreen();
      case 3:
        return const ProfileScreen();
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainShellScope(
      currentIndex: _index,
      select: _select,
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            for (var i = 0; i < 4; i++)
              _opened.contains(i)
                  // Hidden tabs keep their state but stop animating.
                  ? TickerMode(enabled: i == _index, child: _buildTab(i))
                  : const SizedBox.shrink(),
          ],
        ),
        bottomNavigationBar: CustomBottomNavBar(currentIndex: _index),
      ),
    );
  }
}

class MainShellScope extends InheritedWidget {
  const MainShellScope({
    super.key,
    required this.currentIndex,
    required this.select,
    required super.child,
  });

  final int currentIndex;
  final ValueChanged<int> select;

  /// The enclosing shell, or null for a tab screen shown on its own (tests,
  /// or a route pushed outside the shell).
  static MainShellScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MainShellScope>();

  @override
  bool updateShouldNotify(MainShellScope oldWidget) =>
      currentIndex != oldWidget.currentIndex;
}
