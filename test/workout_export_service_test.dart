import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_tracker_app/services/workout_export_service.dart';

void main() {
  group('WorkoutExportService.workoutExportJson', () {
    test('serializes a workout with its exercises to the export schema', () {
      final workout = {
        'id': 1,
        'name': 'Push Day',
        'description': 'Chest, shoulders, triceps',
        'gym_exercises': [
          {
            'name': 'Bench Press',
            'body_part': 'chest',
            'pivot': {'sets': 3, 'reps': 10, 'duration': null, 'rest': 60},
          },
          {
            'name': 'Plank',
            'body_part': 'core',
            'pivot': {'sets': 3, 'reps': null, 'duration': 30, 'rest': 30},
          },
        ],
      };

      final json = jsonDecode(WorkoutExportService.workoutExportJson(workout));

      expect(json['type'], 'workout');
      expect(json['version'], 1);
      expect(json['name'], 'Push Day');
      expect(json['description'], 'Chest, shoulders, triceps');
      expect(json['exercises'], [
        {'name': 'Bench Press', 'sets': 3, 'reps': 10, 'duration': null, 'rest': 60},
        {'name': 'Plank', 'sets': 3, 'reps': null, 'duration': 30, 'rest': 30},
      ]);
    });

    test('exports a workout with no exercises as an empty list', () {
      final workout = {'id': 2, 'name': 'Empty', 'description': '', 'gym_exercises': []};
      final json = jsonDecode(WorkoutExportService.workoutExportJson(workout));
      expect(json['exercises'], isEmpty);
    });
  });

  group('WorkoutExportService.suggestExportFilename', () {
    test('lowercases and underscores a workout name', () {
      expect(WorkoutExportService.suggestExportFilename('Push Day'), 'push_day.json');
    });

    test('strips punctuation', () {
      expect(WorkoutExportService.suggestExportFilename('Arms & Abs!'), 'arms_abs.json');
    });

    test('falls back to a default name when nothing sanitizes cleanly', () {
      expect(WorkoutExportService.suggestExportFilename('!!!'), 'workout.json');
    });
  });
}
