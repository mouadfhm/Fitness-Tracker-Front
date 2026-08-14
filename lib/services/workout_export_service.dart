import 'dart:convert';

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
}
