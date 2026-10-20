import 'dart:ui' as ui;

import 'package:fitness_tracker_app/l10n/app_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:fitness_tracker_app/workout_story/models/story_workout_data.dart';
import 'package:fitness_tracker_app/workout_story/story_labels.dart';

/// An activity as `/workouts/exercises` returns it (see display_names_test).
const runningActivity = {
  'id': 7,
  'name': 'Running',
  'category': 'Running',
  'display_category': 'Course à pied',
  'display_name': 'Course, 8 km/h',
  'description': 'Running, 5 mph (12 min/mile)',
  'caloriesPerKg': 8.3,
};

/// The `workout` that `/workouts/add` echoes back. Laravel sends decimal
/// columns as strings and dates as UTC timestamps.
const loggedRun = {
  'id': 41,
  'user_id': 2,
  'activity_type': 'Running, 5 mph (12 min/mile)',
  'duration': 45,
  'calories_burned': '415.50',
  'workout_date': '2026-10-19T00:00:00.000000Z',
};

/// A custom workout as `/v2/workouts/custom-workouts/{id}` returns it.
const chestWorkout = {
  'id': 1,
  'user_id': 2,
  'name': 'Chest Day',
  'description': 'Chest and triceps.',
  'gym_exercises': [
    {
      'id': 941,
      'name': 'Close-Grip Bench Press',
      'display_name': 'Développé couché prise serrée',
      'pivot': {'sets': 3, 'reps': 12, 'duration': null, 'rest': 60},
    },
    {
      'id': 2838,
      'name': 'Rope Cable Push-Down',
      'pivot': {'sets': 4, 'reps': 10, 'duration': null, 'rest': 90},
    },
    {
      'id': 12,
      'name': 'Plank',
      'pivot': {'sets': 3, 'reps': null, 'duration': 45, 'rest': 30},
    },
  ],
};

StoryLabels labelsFor([String lang = 'en']) => StoryLabels(lookupAppLocalizations(ui.Locale(lang)));

StoryWorkoutData completedRun() =>
    StoryWorkoutData.fromLoggedActivity(activity: runningActivity, logged: loggedRun);

StoryWorkoutData plannedChest({int? minutes = 38}) =>
    StoryWorkoutData.fromCustomWorkout(chestWorkout, estimatedMinutes: minutes);

/// The app gets date formats from its localization delegates; plain tests
/// load them here.
Future<void> initStoryLocales() async {
  await initializeDateFormatting('en');
  await initializeDateFormatting('fr');
}
