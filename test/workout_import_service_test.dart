import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_tracker_app/services/workout_import_service.dart';

void main() {
  group('WorkoutImportService.parseWorkoutImportJson', () {
    test('parses a valid single-workout export', () {
      final decoded = WorkoutImportService.parseWorkoutImportJson(
        '{"type": "workout", "version": 1, "name": "Push Day", "description": "", "exercises": []}',
      );
      expect(decoded['type'], 'workout');
      expect(decoded['name'], 'Push Day');
    });

    test('parses a valid workout-cycle export', () {
      final decoded = WorkoutImportService.parseWorkoutImportJson(
        '{"type": "workout_cycle", "version": 1, "weeks": 4, "days_pattern": {}, "workouts": []}',
      );
      expect(decoded['type'], 'workout_cycle');
    });

    test('rejects text that is not JSON', () {
      expect(
        () => WorkoutImportService.parseWorkoutImportJson('not json'),
        throwsA(isA<WorkoutImportFormatException>()),
      );
    });

    test('rejects JSON that is not an object', () {
      expect(
        () => WorkoutImportService.parseWorkoutImportJson('[1, 2, 3]'),
        throwsA(isA<WorkoutImportFormatException>()),
      );
    });

    test('rejects JSON with an unrecognized type', () {
      expect(
        () => WorkoutImportService.parseWorkoutImportJson('{"type": "meal_plan", "version": 1}'),
        throwsA(isA<WorkoutImportFormatException>()),
      );
    });

    test('rejects a version newer than this app supports', () {
      expect(
        () => WorkoutImportService.parseWorkoutImportJson('{"type": "workout", "version": 2}'),
        throwsA(isA<WorkoutImportFormatException>()),
      );
    });

    test('rejects a workout missing a name', () {
      expect(
        () => WorkoutImportService.parseWorkoutImportJson(
          '{"type": "workout", "version": 1, "exercises": []}',
        ),
        throwsA(isA<WorkoutImportFormatException>()),
      );
    });

    test('rejects a workout cycle missing weeks', () {
      expect(
        () => WorkoutImportService.parseWorkoutImportJson(
          '{"type": "workout_cycle", "version": 1, "days_pattern": {}, "workouts": []}',
        ),
        throwsA(isA<WorkoutImportFormatException>()),
      );
    });

    test('rejects a workout cycle with days_pattern as the wrong type', () {
      expect(
        () => WorkoutImportService.parseWorkoutImportJson(
          '{"type": "workout_cycle", "version": 1, "weeks": 4, "days_pattern": [], "workouts": []}',
        ),
        throwsA(isA<WorkoutImportFormatException>()),
      );
    });
  });
}
