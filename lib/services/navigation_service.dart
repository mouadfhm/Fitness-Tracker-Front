import 'package:flutter/material.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// The `route` values the backend puts in a notification's data block,
  /// mapped to the named routes registered in main.dart.
  static const Map<String, String> _deepLinkRoutes = {
    'home': '/home',
    'workouts': '/workouts',
    'foods': '/foods',
    'profile': '/profile',
  };

  /// Named route a tapped notification should open, or null when it names no
  /// screen and the app should just open where it was. An unrecognised value
  /// falls back to home rather than dropping the tap.
  static String? deepLinkTarget(String? route) {
    if (route == null || route.isEmpty) return null;

    return _deepLinkRoutes[route] ?? _deepLinkRoutes['home'];
  }
}
