import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_tracker_app/services/workout_export_service.dart';

void main() {
  group('WorkoutExportService.extractCyclePattern', () {
    test('reads the first week as the repeating pattern and counts total weeks', () {
      final weeklyPlan = {
        'weeks': [
          {
            'week_start': '2026-08-10',
            'days': {
              'mon': {'workouts': [{'workout': {'id': 1, 'name': 'Push Day'}}]},
              'tue': {'workouts': []},
              'wed': {'workouts': [{'workout': {'id': 2, 'name': 'Pull Day'}}]},
              'thu': {'workouts': []},
              'fri': {'workouts': [{'workout': {'id': 1, 'name': 'Push Day'}}]},
              'sat': {'workouts': []},
              'sun': {'workouts': []},
            },
          },
          {'week_start': '2026-08-17', 'days': {}},
        ],
      };

      final pattern = WorkoutExportService.extractCyclePattern(weeklyPlan);

      expect(pattern.weeks, 2);
      expect(pattern.daysPattern, {
        'mon': 1, 'tue': null, 'wed': 2, 'thu': null, 'fri': 1, 'sat': null, 'sun': null,
      });
    });

    test('throws when the plan has no weeks', () {
      expect(
        () => WorkoutExportService.extractCyclePattern({'weeks': []}),
        throwsArgumentError,
      );
    });
  });

  group('WorkoutExportService.cycleExportJson', () {
    test('bundles the days pattern by name and dedupes referenced workouts', () {
      final json = jsonDecode(WorkoutExportService.cycleExportJson(
        weeks: 4,
        daysPatternByWorkoutId: {
          'mon': 1, 'tue': null, 'wed': 2, 'thu': null, 'fri': 1, 'sat': null, 'sun': null,
        },
        workoutDetailsById: {
          1: {
            'name': 'Push Day',
            'description': 'Chest',
            'gym_exercises': [
              {'name': 'Bench Press', 'pivot': {'sets': 3, 'reps': 10, 'duration': null, 'rest': 60}},
            ],
          },
          2: {
            'name': 'Pull Day',
            'description': 'Back',
            'gym_exercises': [
              {'name': 'Lat Pulldown', 'pivot': {'sets': 3, 'reps': 12, 'duration': null, 'rest': 60}},
            ],
          },
        },
      ));

      expect(json['type'], 'workout_cycle');
      expect(json['version'], 1);
      expect(json['weeks'], 4);
      expect(json['days_pattern'], {
        'mon': 'Push Day', 'tue': null, 'wed': 'Pull Day', 'thu': null, 'fri': 'Push Day', 'sat': null, 'sun': null,
      });
      expect(json['workouts'], hasLength(2));
      final pushDay = (json['workouts'] as List).firstWhere((w) => w['name'] == 'Push Day');
      expect(pushDay['exercises'], [
        {'name': 'Bench Press', 'sets': 3, 'reps': 10, 'duration': null, 'rest': 60},
      ]);
    });
  });
}
