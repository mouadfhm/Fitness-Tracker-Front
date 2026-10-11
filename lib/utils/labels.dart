/// Plain-language labels for values the backend stores as codes, plus small
/// shared helpers for meal times. Keeping them here means no screen ever
/// shows a raw value like `very_active` or `weight_loss`.
library;

import 'l10n.dart';

String activityLabel(String? value) {
  final l = appL10n;
  switch (value?.toLowerCase()) {
    case 'sedentary':
      return l.labelActivitySedentary;
    case 'light':
      return l.labelActivityLight;
    case 'moderate':
      return l.labelActivityModerate;
    case 'active':
      return l.labelActivityActive;
    case 'very_active':
      return l.labelActivityVeryActive;
    default:
      return value == null || value.isEmpty ? l.labelNotSet : _titleCase(value);
  }
}

String goalLabel(String? value) {
  final l = appL10n;
  switch (value) {
    case 'weight_loss':
      return l.labelGoalWeightLoss;
    case 'muscle_gain':
      return l.labelGoalMuscleGain;
    case 'maintenance':
      return l.labelGoalMaintenance;
    default:
      return value == null || value.isEmpty ? l.labelNotSet : _titleCase(value);
  }
}

String genderLabel(String? value) {
  final l = appL10n;
  switch (value) {
    case 'male':
      return l.labelGenderMale;
    case 'female':
      return l.labelGenderFemale;
    default:
      return value == null || value.isEmpty ? l.labelNotSet : _titleCase(value);
  }
}

/// The four meal slots shown everywhere. Values are what the backend stores.
const List<String> mainMealTimes = ['breakfast', 'lunch', 'dinner', 'snack'];

/// Picks the meal someone is most likely logging right now.
String mealTimeForNow([DateTime? now]) {
  final t = now ?? DateTime.now();
  final minutes = t.hour * 60 + t.minute;
  if (minutes >= 5 * 60 && minutes < 11 * 60) return 'breakfast';
  if (minutes >= 11 * 60 && minutes < 15 * 60) return 'lunch';
  if (minutes >= 17 * 60 && minutes < 22 * 60) return 'dinner';
  return 'snack';
}

/// "snack" -> "Snacks", the main meals in the app's language, anything else
/// title-cased ("afternoon snack" -> "Afternoon Snack").
String mealTimeLabel(String mealTime) {
  final l = appL10n;
  switch (mealTime.toLowerCase()) {
    case 'breakfast':
      return l.labelMealBreakfast;
    case 'lunch':
      return l.labelMealLunch;
    case 'dinner':
      return l.labelMealDinner;
    case 'snack':
      return l.labelMealSnacks;
  }
  return _titleCase(mealTime);
}

String _titleCase(String value) => value
    .replaceAll('_', ' ')
    .split(' ')
    .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
    .join(' ');

/// Effort level for an activity from its kcal per kg per hour, which is about
/// the same as its MET value (walking ≈ 3.5, running ≈ 10).
String intensityLabel(num caloriesPerKgPerHour) {
  final l = appL10n;
  if (caloriesPerKgPerHour >= 6) return l.labelIntensityVigorous;
  if (caloriesPerKgPerHour >= 3) return l.labelIntensityModerate;
  return l.labelIntensityLight;
}
