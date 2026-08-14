import 'dart:convert';

class WorkoutImportFormatException implements Exception {
  final String message;
  WorkoutImportFormatException(this.message);

  @override
  String toString() => message;
}

class ExerciseMatchResult {
  final List<Map<String, dynamic>> matchedGymExercises;
  final List<String> unmatchedNames;

  ExerciseMatchResult({
    required this.matchedGymExercises,
    required this.unmatchedNames,
  });
}

class WorkoutImportService {
  static const int supportedVersion = 1;

  static Map<String, dynamic> parseWorkoutImportJson(String jsonString) {
    dynamic decoded;
    try {
      decoded = jsonDecode(jsonString);
    } on FormatException {
      throw WorkoutImportFormatException('That file is not valid JSON.');
    }

    if (decoded is! Map<String, dynamic>) {
      throw WorkoutImportFormatException('That file is not a workout program export.');
    }

    final type = decoded['type'];
    if (type != 'workout' && type != 'workout_cycle') {
      throw WorkoutImportFormatException('That file is not a workout program export.');
    }

    if (decoded['version'] != supportedVersion) {
      throw WorkoutImportFormatException(
        'This file was exported by a version of the app this import cannot read.',
      );
    }

    return decoded;
  }

  static ExerciseMatchResult matchWorkoutExercises(
    Map<String, dynamic> workoutJson,
    List<Map<String, dynamic>> catalog,
  ) {
    final nameToId = {
      for (final exercise in catalog)
        (exercise['name'] as String).toLowerCase(): exercise['id'] as int,
    };

    final matched = <Map<String, dynamic>>[];
    final unmatched = <String>[];

    final exercises = workoutJson['exercises'] as List<dynamic>? ?? [];
    for (final raw in exercises) {
      final exercise = raw as Map<String, dynamic>;
      final name = exercise['name'] as String;
      final id = nameToId[name.toLowerCase()];
      if (id == null) {
        unmatched.add(name);
        continue;
      }
      matched.add({
        'gym_exercise_id': id,
        'sets': exercise['sets'],
        'reps': exercise['reps'],
        'duration': exercise['duration'],
        'rest': exercise['rest'],
      });
    }

    return ExerciseMatchResult(matchedGymExercises: matched, unmatchedNames: unmatched);
  }
}
