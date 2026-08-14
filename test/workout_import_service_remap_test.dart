import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_tracker_app/services/workout_import_service.dart';

void main() {
  group('WorkoutImportService.remapDaysPatternToIds', () {
    test('maps workout names to their newly-created ids', () {
      final result = WorkoutImportService.remapDaysPatternToIds(
        {'mon': 'Push Day', 'tue': null, 'wed': 'Pull Day'},
        {'Push Day': 101, 'Pull Day': 102},
      );

      expect(result, {'mon': 101, 'tue': null, 'wed': 102});
    });

    test('leaves a day null when its workout name has no new id', () {
      final result = WorkoutImportService.remapDaysPatternToIds(
        {'mon': 'Missing Workout'},
        {},
      );

      expect(result, {'mon': null});
    });
  });
}
