import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_tracker_app/services/navigation_service.dart';

void main() {
  group('deepLinkTarget', () {
    test('maps every route the backend sends to its named route', () {
      expect(NavigationService.deepLinkTarget('home'), '/home');
      expect(NavigationService.deepLinkTarget('workouts'), '/workouts');
      expect(NavigationService.deepLinkTarget('foods'), '/foods');
      expect(NavigationService.deepLinkTarget('profile'), '/profile');
    });

    test('falls back to home for a route the app does not know', () {
      // A backend that starts sending a new route must not strand the tap on
      // whatever screen the user happened to be on.
      expect(NavigationService.deepLinkTarget('meal_detail'), '/home');
      expect(NavigationService.deepLinkTarget('/foods'), '/home');
    });

    test('returns null when the notification names no screen', () {
      // Nothing to navigate to: the app opens normally.
      expect(NavigationService.deepLinkTarget(null), isNull);
      expect(NavigationService.deepLinkTarget(''), isNull);
    });
  });
}
