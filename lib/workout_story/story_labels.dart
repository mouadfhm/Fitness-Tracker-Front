import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import 'models/story_workout_data.dart';

/// The words drawn on a story, in the app's language. Built once per editor
/// so the preview and the exported image use the same strings.
class StoryLabels {
  StoryLabels(this.l10n) : _number = NumberFormat.decimalPattern(l10n.localeName);

  final AppLocalizations l10n;
  final NumberFormat _number;

  String get localeName => l10n.localeName;
  String get planCaption => l10n.storyPlanCaption;
  String get brand => l10n.storyBrand;

  String statLabel(StoryStatKind kind, {bool estimate = false}) => switch (kind) {
    StoryStatKind.duration => estimate ? l10n.storyStatDurationEstimated : l10n.storyStatDuration,
    StoryStatKind.calories => l10n.storyStatCalories,
    StoryStatKind.exercises => l10n.storyStatExercises,
    StoryStatKind.sets => l10n.storyStatSets,
    StoryStatKind.reps => l10n.storyStatReps,
  };

  /// [kind]'s value for [data], or null when the workout has none.
  String? statValue(StoryWorkoutData data, StoryStatKind kind) {
    final v = data.value(kind);
    if (v == null) return null;
    return switch (kind) {
      StoryStatKind.duration => duration(v.round()),
      _ => _number.format(v.round()),
    };
  }

  String duration(int minutes) {
    if (minutes < 60) return l10n.storyMinutes(minutes);
    final m = (minutes % 60).toString().padLeft(2, '0');
    return l10n.storyHoursMinutes(minutes ~/ 60, m);
  }

  String date(DateTime d) => DateFormat.yMMMMd(localeName).format(d);

  String status(StoryWorkoutData data) =>
      data.isPlanned ? l10n.storyStatusPlanned : l10n.storyStatusCompleted;

  /// One line per exercise, with its planned sets and reps where known, up
  /// to [max] lines.
  String exerciseLines(StoryWorkoutData data, {int max = 5}) {
    final lines = <String>[];
    for (final e in data.exercises.take(max)) {
      final detail =
          (e.sets != null && e.reps != null)
              ? l10n.storyExerciseSetsReps(e.sets!, e.reps!)
              : (e.sets != null && e.durationSeconds != null)
              ? l10n.storyExerciseSetsSeconds(e.sets!, e.durationSeconds!)
              : null;
      lines.add(detail == null ? e.name : '${e.name}  ·  $detail');
    }
    final more = data.exercises.length - max;
    if (more > 0) lines.add(l10n.storyMoreExercises(more));
    return lines.join('\n');
  }
}
