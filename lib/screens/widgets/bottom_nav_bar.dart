import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  static const _routes = ['/home', '/workouts', '/foods', '/profile'];
  static const _icons = [
    Icons.home,
    Icons.fitness_center,
    Icons.restaurant,
    Icons.person,
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BottomAppBar(
      color: colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(4, (i) {
          final isSelected = i == currentIndex;
          return IconButton(
            icon: Icon(
              _icons[i],
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            onPressed: isSelected
                ? null
                : () => Navigator.of(context).pushReplacementNamed(_routes[i]),
          );
        }),
      ),
    );
  }
}
