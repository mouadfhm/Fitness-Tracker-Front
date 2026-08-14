import 'dart:convert';

class CyclePattern {
  final int weeks;
  final Map<String, int?> daysPattern;

  CyclePattern({required this.weeks, required this.daysPattern});
}

class WorkoutExportService {
  static const int schemaVersion = 1;
  static const List<String> dayKeys = [
    'mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun',
  ];

  static String workoutExportJson(Map<String, dynamic> workout) {
    final export = {
      'type': 'workout',
      'version': schemaVersion,
      'name': workout['name'],
      'description': workout['description'],
      'exercises': _exportExercises(workout),
    };

    return const JsonEncoder.withIndent('  ').convert(export);
  }

  static List<Map<String, dynamic>> _exportExercises(Map<String, dynamic> workout) {
    final gymExercises = workout['gym_exercises'] as List<dynamic>? ?? [];
    return gymExercises
        .map((e) => _exerciseExportMap(e as Map<String, dynamic>))
        .toList();
  }

  static Map<String, dynamic> _exerciseExportMap(Map<String, dynamic> exercise) {
    final pivot = exercise['pivot'] as Map<String, dynamic>? ?? {};
    return {
      'name': exercise['name'],
      'sets': pivot['sets'],
      'reps': pivot['reps'],
      'duration': pivot['duration'],
      'rest': pivot['rest'],
    };
  }

  static String suggestExportFilename(String workoutName) {
    final sanitized = workoutName
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return '${sanitized.isEmpty ? 'workout' : sanitized}.json';
  }

  static CyclePattern extractCyclePattern(Map<String, dynamic> weeklyPlan) {
    final weeksList = weeklyPlan['weeks'] as List<dynamic>? ?? [];
    if (weeksList.isEmpty) {
      throw ArgumentError('weeklyPlan has no weeks to export');
    }

    final firstWeekDays = weeksList.first['days'] as Map<String, dynamic>? ?? {};
    final pattern = <String, int?>{};

    for (final dayKey in dayKeys) {
      final dayData = firstWeekDays[dayKey] as Map<String, dynamic>?;
      final dayWorkouts = dayData?['workouts'] as List<dynamic>? ?? [];
      if (dayWorkouts.isEmpty) {
        pattern[dayKey] = null;
        continue;
      }
      final workout = dayWorkouts.first['workout'] as Map<String, dynamic>;
      pattern[dayKey] = workout['id'] as int;
    }

    return CyclePattern(weeks: weeksList.length, daysPattern: pattern);
  }

  static String cycleExportJson({
    required int weeks,
    required Map<String, int?> daysPatternByWorkoutId,
    required Map<int, Map<String, dynamic>> workoutDetailsById,
  }) {
    final namedPattern = {
      for (final entry in daysPatternByWorkoutId.entries)
        entry.key: entry.value == null
            ? null
            : workoutDetailsById[entry.value]!['name'],
    };

    final export = {
      'type': 'workout_cycle',
      'version': schemaVersion,
      'weeks': weeks,
      'days_pattern': namedPattern,
      'workouts': workoutDetailsById.values
          .map((w) => {
                'name': w['name'],
                'description': w['description'],
                'exercises': _exportExercises(w),
              })
          .toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(export);
  }
}
