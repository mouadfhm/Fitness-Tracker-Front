import 'package:flutter/material.dart';
import '../foods_screen.dart';
import '../home_screen.dart';
import '../profile_screen.dart';
import '../workout_root_screen.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  static const _routes = ['/home', '/workouts', '/foods', '/profile'];
  static final _screens = <Widget Function()>[
    () => const HomeScreen(),
    () => const WorkoutRootScreen(),
    () => const FoodsScreen(),
    () => const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Labels are always visible: icon-only tabs are guesswork for people who
    // don't use many apps.
    return NavigationBar(
      selectedIndex: currentIndex,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      onDestinationSelected: (i) {
        if (i == currentIndex) return;
        // Tabs switch in place, with no transition. A named route would play
        // the platform's push animation, which on iOS slides each tab in from
        // the side as if it were a new page, against how iOS tab bars behave.
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            settings: RouteSettings(name: _routes[i]),
            pageBuilder: (_, __, ___) => _screens[i](),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.today_outlined),
          selectedIcon: Icon(Icons.today),
          label: 'Today',
        ),
        NavigationDestination(
          icon: Icon(Icons.fitness_center_outlined),
          selectedIcon: Icon(Icons.fitness_center),
          label: 'Workouts',
        ),
        NavigationDestination(
          icon: Icon(Icons.restaurant_outlined),
          selectedIcon: Icon(Icons.restaurant),
          label: 'Foods',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Me',
        ),
      ],
    );
  }
}
