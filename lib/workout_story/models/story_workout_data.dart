import '../../providers/exercise_provider.dart';
import '../../utils/l10n.dart';

/// Whether the story is about a workout the user did or one they plan to do.
/// A planned workout is never shown as done: its numbers are the plan's.
enum StoryWorkoutStatus { completed, planned }

/// The statistics a story can show. Each one is only offered when the
/// workout actually has a value for it ([StoryWorkoutData.value]).
enum StoryStatKind { duration, calories, exercises, sets, reps }

class StoryExercise {
  const StoryExercise({required this.name, this.sets, this.reps, this.durationSeconds});

  final String name;
  final int? sets;
  final int? reps;

  /// Seconds per set, for timed exercises (the plan's `duration`).
  final int? durationSeconds;
}

/// The workout facts a story is built from, read once from the app's own
/// workout data. Missing values stay null so they are hidden rather than
/// shown as zero.
class StoryWorkoutData {
  const StoryWorkoutData({
    required this.title,
    required this.status,
    this.date,
    this.durationMinutes,
    this.durationEstimated = false,
    this.caloriesBurned,
    this.caloriesEstimated = true,
    this.category,
    this.exercises = const [],
  });

  final String title;
  final StoryWorkoutStatus status;

  /// The day the workout was logged for. Plans have no date.
  final DateTime? date;
  final int? durationMinutes;

  /// True when [durationMinutes] is the app's estimate for a plan rather than
  /// the time the user entered.
  final bool durationEstimated;
  final double? caloriesBurned;

  /// The backend works calories out from the activity and the user's weight;
  /// nothing measures them, so they are labelled as an estimate.
  final bool caloriesEstimated;
  final String? category;
  final List<StoryExercise> exercises;

  bool get isPlanned => status == StoryWorkoutStatus.planned;

  int? get exerciseCount => exercises.isEmpty ? null : exercises.length;

  int? get totalSets {
    final known = exercises.where((e) => e.sets != null);
    if (known.isEmpty) return null;
    return known.fold<int>(0, (sum, e) => sum + e.sets!);
  }

  int? get totalReps {
    final known = exercises.where((e) => e.sets != null && e.reps != null);
    if (known.isEmpty) return null;
    return known.fold<int>(0, (sum, e) => sum + e.sets! * e.reps!);
  }

  /// The value of [kind], or null when this workout has none.
  num? value(StoryStatKind kind) => switch (kind) {
    StoryStatKind.duration => durationMinutes,
    StoryStatKind.calories => caloriesBurned,
    StoryStatKind.exercises => exerciseCount,
    StoryStatKind.sets => totalSets,
    StoryStatKind.reps => totalReps,
  };

  bool isEstimate(StoryStatKind kind) => switch (kind) {
    StoryStatKind.duration => durationEstimated,
    StoryStatKind.calories => caloriesEstimated,
    _ => false,
  };

  List<StoryStatKind> get availableStats =>
      StoryStatKind.values.where((k) => value(k) != null).toList();

  /// A workout the user just logged in simple mode: [activity] is the
  /// activity from `/workouts/exercises`, [logged] the `workout` the backend
  /// returned from `/workouts/add` (activity_type, duration, calories_burned,
  /// workout_date).
  factory StoryWorkoutData.fromLoggedActivity({
    required Map activity,
    required Map logged,
    String fallbackTitle = '',
  }) {
    final calories = _positiveDouble(logged['calories_burned']);
    final category = ExercisesProvider.categoryLabelOf(activity);
    final title = localizedName(activity, fallback: fallbackTitle);
    return StoryWorkoutData(
      title: title,
      status: StoryWorkoutStatus.completed,
      date: _dateOnly(logged['workout_date']),
      durationMinutes: _positiveDouble(logged['duration'])?.round(),
      caloriesBurned: calories,
      category: category == title ? null : category,
    );
  }

  /// A custom workout from `/v2/workouts/custom-workouts/{id}`: a plan, with
  /// its exercises and their planned sets and reps. [estimatedMinutes] is the
  /// estimate the workout screen already shows, if any.
  factory StoryWorkoutData.fromCustomWorkout(
    Map workout, {
    int? estimatedMinutes,
    String fallbackTitle = '',
  }) {
    final raw = workout['gym_exercises'];
    final exercises = <StoryExercise>[
      if (raw is List)
        for (final e in raw.whereType<Map>())
          StoryExercise(
            name: localizedName(e),
            sets: _positiveInt((e['pivot'] as Map?)?['sets']),
            reps: _positiveInt((e['pivot'] as Map?)?['reps']),
            durationSeconds: _positiveInt((e['pivot'] as Map?)?['duration']),
          ),
    ];
    final name = workout['name']?.toString().trim() ?? '';
    return StoryWorkoutData(
      title: name.isEmpty ? fallbackTitle : name,
      status: StoryWorkoutStatus.planned,
      durationMinutes: (estimatedMinutes != null && estimatedMinutes > 0) ? estimatedMinutes : null,
      durationEstimated: true,
      exercises: exercises,
    );
  }

  static double? _positiveDouble(Object? v) {
    final n = v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '');
    return (n != null && n.isFinite && n > 0) ? n : null;
  }

  static int? _positiveInt(Object? v) => _positiveDouble(v)?.round();

  /// `workout_date` is a calendar day; read only its yyyy-MM-dd part so a
  /// UTC timestamp can't move it to the day before.
  static DateTime? _dateOnly(Object? v) {
    final s = v?.toString() ?? '';
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(s);
    if (m == null) return null;
    return DateTime(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));
  }
}
