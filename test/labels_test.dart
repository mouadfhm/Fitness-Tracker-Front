import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:fitness_tracker_app/utils/friendly_error.dart';
import 'package:fitness_tracker_app/utils/labels.dart';

void main() {
  group('labels', () {
    test('show plain words instead of stored codes', () {
      expect(activityLabel('very_active'), 'Very active');
      expect(activityLabel('Moderate'), 'Moderately active');
      expect(goalLabel('weight_loss'), 'Lose weight');
      expect(goalLabel('maintenance'), 'Stay at my weight');
      expect(genderLabel('female'), 'Female');
      expect(goalLabel(null), 'Not set');
    });

    test('meal time follows the clock', () {
      expect(mealTimeForNow(DateTime(2026, 1, 1, 8)), 'breakfast');
      expect(mealTimeForNow(DateTime(2026, 1, 1, 12, 30)), 'lunch');
      expect(mealTimeForNow(DateTime(2026, 1, 1, 16)), 'snack');
      expect(mealTimeForNow(DateTime(2026, 1, 1, 19)), 'dinner');
      expect(mealTimeForNow(DateTime(2026, 1, 1, 23)), 'snack');
    });

    test('meal time labels', () {
      expect(mealTimeLabel('snack'), 'Snacks');
      expect(mealTimeLabel('afternoon snack'), 'Afternoon Snack');
    });
  });

  group('friendlyError', () {
    test('passes through messages written for users', () {
      expect(friendlyError(const UserFacingException('Wrong email or password.')),
          'Wrong email or password.');
    });

    test('explains network failures', () {
      expect(friendlyError(http.ClientException('Connection refused')),
          contains('internet connection'));
    });

    test('hides server bodies behind the fallback', () {
      expect(friendlyError(Exception('Failed to get goal: {"message":"Server Error"}')),
          'Please try again.');
      expect(friendlyError(Exception('x'), fallback: 'Nope.'), 'Nope.');
    });

    test('explains an expired session', () {
      expect(friendlyError(Exception('Session expired. Please log in again.')),
          contains('log in again'));
    });
  });

  test('intensity uses MET-like thresholds', () {
    expect(intensityLabel(2.0), 'Light'); // slow walk
    expect(intensityLabel(3.5), 'Moderate'); // brisk walk
    expect(intensityLabel(8.5), 'Vigorous'); // mountain biking
  });
}
