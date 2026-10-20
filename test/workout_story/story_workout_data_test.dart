import 'package:fitness_tracker_app/workout_story/models/story_workout_data.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures.dart';

void main() {
  group('logged activity (completed)', () {
    test('maps the recorded duration, calories, date and names', () {
      final d = completedRun();
      expect(d.status, StoryWorkoutStatus.completed);
      expect(d.isPlanned, isFalse);
      expect(d.title, 'Course, 8 km/h');
      expect(d.category, 'Course à pied');
      expect(d.durationMinutes, 45);
      expect(d.durationEstimated, isFalse);
      expect(d.caloriesBurned, closeTo(415.5, 0.001));
      expect(d.caloriesEstimated, isTrue);
      // A UTC midnight timestamp stays on its calendar day.
      expect(d.date, DateTime(2026, 10, 19));
    });

    test('offers only the stats it has', () {
      expect(completedRun().availableStats, [StoryStatKind.duration, StoryStatKind.calories]);
      expect(completedRun().value(StoryStatKind.sets), isNull);
      expect(completedRun().exerciseCount, isNull);
    });

    test('hides calories that are missing or zero instead of showing 0', () {
      for (final calories in [null, 0, '0.00', 'n/a']) {
        final d = StoryWorkoutData.fromLoggedActivity(
          activity: runningActivity,
          logged: {...loggedRun, 'calories_burned': calories},
        );
        expect(d.caloriesBurned, isNull, reason: '$calories');
        expect(d.availableStats, isNot(contains(StoryStatKind.calories)));
      }
    });

    test('works from what was sent when the server echoes nothing', () {
      final d = StoryWorkoutData.fromLoggedActivity(
        activity: const {'name': 'Yoga'},
        logged: const {'duration': 30, 'workout_date': '2026-10-20'},
      );
      expect(d.title, 'Yoga');
      expect(d.category, isNull);
      expect(d.durationMinutes, 30);
      expect(d.date, DateTime(2026, 10, 20));
      expect(d.availableStats, [StoryStatKind.duration]);
    });

    test('falls back to the given title and no date', () {
      final d = StoryWorkoutData.fromLoggedActivity(
        activity: const {},
        logged: const {'duration': 0},
        fallbackTitle: 'Workout',
      );
      expect(d.title, 'Workout');
      expect(d.date, isNull);
      expect(d.durationMinutes, isNull);
      expect(d.availableStats, isEmpty);
    });
  });

  group('custom workout (planned)', () {
    test('is a plan with exercises, planned sets and reps', () {
      final d = plannedChest();
      expect(d.status, StoryWorkoutStatus.planned);
      expect(d.isPlanned, isTrue);
      expect(d.title, 'Chest Day');
      expect(d.date, isNull);
      expect(d.exercises.map((e) => e.name), [
        'Développé couché prise serrée',
        'Rope Cable Push-Down',
        'Plank',
      ]);
      expect(d.exercises.last.reps, isNull);
      expect(d.exercises.last.durationSeconds, 45);
      expect(d.exerciseCount, 3);
      expect(d.totalSets, 10);
      // Reps only count where both sets and reps are planned.
      expect(d.totalReps, 3 * 12 + 4 * 10);
    });

    test('never carries a measured result', () {
      final d = plannedChest();
      expect(d.caloriesBurned, isNull);
      expect(d.availableStats, isNot(contains(StoryStatKind.calories)));
      expect(d.durationMinutes, 38);
      expect(d.isEstimate(StoryStatKind.duration), isTrue);
    });

    test('drops the duration when there is no estimate', () {
      expect(plannedChest(minutes: null).durationMinutes, isNull);
      expect(plannedChest(minutes: 0).durationMinutes, isNull);
    });

    test('copes with a workout without exercises', () {
      final d = StoryWorkoutData.fromCustomWorkout(const {'name': '  '}, fallbackTitle: 'Plan');
      expect(d.title, 'Plan');
      expect(d.exerciseCount, isNull);
      expect(d.totalSets, isNull);
      expect(d.totalReps, isNull);
      expect(d.availableStats, isEmpty);
    });
  });
}
