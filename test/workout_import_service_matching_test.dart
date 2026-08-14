import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_tracker_app/services/workout_import_service.dart';

void main() {
  group('WorkoutImportService.matchWorkoutExercises', () {
    final catalog = [
      {'id': 10, 'name': 'Bench Press'},
      {'id': 11, 'name': 'Squat'},
    ];

    test('resolves exercises to gym_exercise_id by case-insensitive name', () {
      final result = WorkoutImportService.matchWorkoutExercises({
        'exercises': [
          {'name': 'bench press', 'sets': 3, 'reps': 10, 'duration': null, 'rest': 60},
        ],
      }, catalog);

      expect(result.matchedGymExercises, [
        {'gym_exercise_id': 10, 'sets': 3, 'reps': 10, 'duration': null, 'rest': 60},
      ]);
      expect(result.unmatchedNames, isEmpty);
    });

    test('collects names with no catalog match without throwing', () {
      final result = WorkoutImportService.matchWorkoutExercises({
        'exercises': [
          {'name': 'Bench Press', 'sets': 3, 'reps': 10, 'duration': null, 'rest': 60},
          {'name': 'Nonexistent Move', 'sets': 3, 'reps': 10, 'duration': null, 'rest': 60},
        ],
      }, catalog);

      expect(result.matchedGymExercises, hasLength(1));
      expect(result.unmatchedNames, ['Nonexistent Move']);
    });

    test('handles a workout with no exercises', () {
      final result = WorkoutImportService.matchWorkoutExercises({'exercises': []}, catalog);
      expect(result.matchedGymExercises, isEmpty);
      expect(result.unmatchedNames, isEmpty);
    });
  });
}
