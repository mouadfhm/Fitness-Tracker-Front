/// Plain-language labels for values the backend stores as codes, plus small
/// shared helpers for meal times. Keeping them here means no screen ever
/// shows a raw value like `very_active` or `weight_loss`.
library;

String activityLabel(String? value) {
  switch (value?.toLowerCase()) {
    case 'sedentary':
      return 'Mostly sitting';
    case 'light':
      return 'Lightly active';
    case 'moderate':
      return 'Moderately active';
    case 'active':
      return 'Active';
    case 'very_active':
      return 'Very active';
    default:
      return value == null || value.isEmpty ? 'Not set' : _titleCase(value);
  }
}

String goalLabel(String? value) {
  switch (value) {
    case 'weight_loss':
      return 'Lose weight';
    case 'muscle_gain':
      return 'Build muscle';
    case 'maintenance':
      return 'Stay at my weight';
    default:
      return value == null || value.isEmpty ? 'Not set' : _titleCase(value);
  }
}

String genderLabel(String? value) {
  switch (value) {
    case 'male':
      return 'Male';
    case 'female':
      return 'Female';
    default:
      return value == null || value.isEmpty ? 'Not set' : _titleCase(value);
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

/// "afternoon snack" -> "Afternoon Snack", "snack" -> "Snacks".
String mealTimeLabel(String mealTime) {
  if (mealTime.toLowerCase() == 'snack') return 'Snacks';
  return _titleCase(mealTime);
}

String _titleCase(String value) => value
    .replaceAll('_', ' ')
    .split(' ')
    .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
    .join(' ');
