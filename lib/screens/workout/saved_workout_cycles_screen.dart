// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../utils/friendly_error.dart';
import 'new_workout_cycle_screen.dart';

/// One exercise this template needs, described by muscle group rather than
/// an exact exercise name. The seeded exercise library's naming is not
/// standardized (it comes from a large public dataset with inconsistent
/// titles), so matching by `body_part` — a fixed, always-populated field —
/// is far more reliable than hoping a specific string like "Barbell Squat"
/// exists verbatim.
class _ExerciseSlot {
  final String bodyPart;
  final int sets;
  final int reps;
  final int rest;

  const _ExerciseSlot(
    this.bodyPart, {
    required this.sets,
    required this.reps,
    required this.rest,
  });
}

/// A named workout used by one or more days of a suggested cycle.
class _SuggestedWorkoutTemplate {
  final String name;
  final String description;
  final List<_ExerciseSlot> slots;

  const _SuggestedWorkoutTemplate({
    required this.name,
    required this.description,
    required this.slots,
  });
}

const _pushDay = _SuggestedWorkoutTemplate(
  name: 'Push Day',
  description: 'Chest, shoulders and triceps.',
  slots: [
    _ExerciseSlot('Chest', sets: 4, reps: 8, rest: 90),
    _ExerciseSlot('Chest', sets: 3, reps: 10, rest: 75),
    _ExerciseSlot('Shoulders', sets: 3, reps: 8, rest: 90),
    _ExerciseSlot('Triceps', sets: 3, reps: 12, rest: 60),
  ],
);

const _pullDay = _SuggestedWorkoutTemplate(
  name: 'Pull Day',
  description: 'Back and biceps.',
  slots: [
    _ExerciseSlot('Lats', sets: 4, reps: 8, rest: 90),
    _ExerciseSlot('Middle Back', sets: 4, reps: 8, rest: 90),
    _ExerciseSlot('Biceps', sets: 3, reps: 10, rest: 60),
    _ExerciseSlot('Biceps', sets: 3, reps: 12, rest: 60),
  ],
);

const _legsDay = _SuggestedWorkoutTemplate(
  name: 'Legs Day',
  description: 'Quads, hamstrings, glutes and calves.',
  slots: [
    _ExerciseSlot('Quadriceps', sets: 4, reps: 8, rest: 120),
    _ExerciseSlot('Hamstrings', sets: 3, reps: 10, rest: 90),
    _ExerciseSlot('Quadriceps', sets: 3, reps: 12, rest: 90),
    _ExerciseSlot('Glutes', sets: 3, reps: 12, rest: 60),
    _ExerciseSlot('Calves', sets: 3, reps: 12, rest: 60),
  ],
);

const _upperDay = _SuggestedWorkoutTemplate(
  name: 'Upper Day',
  description: 'Chest, back, shoulders and arms.',
  slots: [
    _ExerciseSlot('Chest', sets: 4, reps: 8, rest: 90),
    _ExerciseSlot('Middle Back', sets: 4, reps: 8, rest: 90),
    _ExerciseSlot('Shoulders', sets: 3, reps: 8, rest: 90),
    _ExerciseSlot('Biceps', sets: 3, reps: 10, rest: 60),
    _ExerciseSlot('Triceps', sets: 3, reps: 12, rest: 60),
  ],
);

const _lowerDay = _SuggestedWorkoutTemplate(
  name: 'Lower Day',
  description: 'Quads, hamstrings and glutes.',
  slots: [
    _ExerciseSlot('Quadriceps', sets: 4, reps: 8, rest: 120),
    _ExerciseSlot('Hamstrings', sets: 3, reps: 10, rest: 90),
    _ExerciseSlot('Quadriceps', sets: 3, reps: 12, rest: 90),
    _ExerciseSlot('Glutes', sets: 3, reps: 12, rest: 60),
  ],
);

const _fullBodyDay = _SuggestedWorkoutTemplate(
  name: 'Full Body Day',
  description: 'A few exercises that work your whole body.',
  slots: [
    _ExerciseSlot('Quadriceps', sets: 3, reps: 8, rest: 90),
    _ExerciseSlot('Chest', sets: 3, reps: 8, rest: 90),
    _ExerciseSlot('Middle Back', sets: 3, reps: 8, rest: 90),
    _ExerciseSlot('Shoulders', sets: 3, reps: 8, rest: 90),
  ],
);

class _SuggestedCycle {
  final String name;
  final String description;
  final int weeks;
  final bool beginnerFriendly;

  /// Day key -> the workout template for that day. Days absent from this map
  /// are rest days. Multiple keys may point at the same template instance
  /// (e.g. every "Legs" day) so only one workout gets created for it.
  final Map<String, _SuggestedWorkoutTemplate> dayTemplates;

  const _SuggestedCycle({
    required this.name,
    required this.description,
    required this.weeks,
    required this.dayTemplates,
    this.beginnerFriendly = false,
  });
}

// Ordered easiest first: the first card is what a beginner sees.
const List<_SuggestedCycle> _suggestedCycles = [
  _SuggestedCycle(
    name: 'Full Body',
    description:
        'Whole body, 3 days a week with rest days in between. The best place to start.',
    weeks: 8,
    beginnerFriendly: true,
    dayTemplates: {
      'mon': _fullBodyDay,
      'wed': _fullBodyDay,
      'fri': _fullBodyDay,
    },
  ),
  _SuggestedCycle(
    name: 'Upper / Lower',
    description:
        'Upper body one day, legs the next. Try it once 3 days feels easy.',
    weeks: 6,
    dayTemplates: {
      'mon': _upperDay,
      'tue': _lowerDay,
      'thu': _upperDay,
      'fri': _lowerDay,
    },
  ),
  _SuggestedCycle(
    name: 'Push Pull Legs',
    description:
        'Different muscles each day. For people who already train often.',
    weeks: 6,
    dayTemplates: {
      'mon': _pushDay,
      'tue': _pullDay,
      'wed': _legsDay,
      'thu': _pushDay,
      'fri': _pullDay,
      'sat': _legsDay,
    },
  ),
];

class SavedWorkoutCyclesScreen extends StatefulWidget {
  const SavedWorkoutCyclesScreen({super.key});

  @override
  _SavedWorkoutCyclesScreenState createState() =>
      _SavedWorkoutCyclesScreenState();
}

class _SavedWorkoutCyclesScreenState extends State<SavedWorkoutCyclesScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _plansFuture;
  String? _creatingSuggestionName;
  Object? _reusingPlanId;

  final List<String> _dayLabels = const [
    'mon',
    'tue',
    'wed',
    'thu',
    'fri',
    'sat',
    'sun',
  ];

  @override
  void initState() {
    super.initState();
    _plansFuture = _apiService.fetchSavedCyclePlans();
  }

  void _refresh() {
    setState(() {
      _plansFuture = _apiService.fetchSavedCyclePlans();
    });
  }

  int _activeDaysCount(Map<String, dynamic> daysPattern) {
    return _dayLabels.where((day) => daysPattern[day] != null).length;
  }

  Future<void> _reusePlan(Map<String, dynamic> plan) async {
    if (_reusingPlanId != null) return;

    final colorScheme = Theme.of(context).colorScheme;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: colorScheme.primary,
              brightness: Theme.of(context).brightness,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null || !mounted) return;

    setState(() {
      _reusingPlanId = plan['id'];
    });

    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      await _apiService.reuseCyclePlan(plan['id'], formattedDate);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${plan['name'] ?? 'Cycle'}" scheduled')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _reusingPlanId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Couldn't start this plan. ${friendlyError(e)}")),
      );
    }
  }

  Future<void> _deletePlan(Map<String, dynamic> plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete saved plan'),
        content: Text(
            'Delete "${plan['name'] ?? 'this plan'}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _apiService.deleteCyclePlan(plan['id']);
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Couldn't delete this plan. ${friendlyError(e)}")),
      );
    }
  }

  /// Fills each of the template's slots with a real, unused exercise from
  /// the catalog whose body_part matches, preferring shorter/plainer names
  /// (the catalog's naming is inconsistent — e.g. "Barbell Squat" vs
  /// "Squat Jumps On BOSU Ball" — and a shorter name is more likely to be
  /// the plain, foundational version of the lift). Slots with no matching
  /// exercise left are simply dropped rather than failing the whole
  /// workout.
  List<Map<String, dynamic>> _pickExercisesForTemplate(
    _SuggestedWorkoutTemplate template,
    List<Map<String, dynamic>> catalog,
  ) {
    final byBodyPart = <String, List<Map<String, dynamic>>>{};
    for (final exercise in catalog) {
      final bodyPart = (exercise['body_part'] as String?)?.trim();
      final type = (exercise['type'] as String?)?.trim();
      if (bodyPart == null || bodyPart.isEmpty) continue;
      if (type != null && type != 'Strength') continue;
      byBodyPart.putIfAbsent(bodyPart, () => []).add(exercise);
    }
    for (final list in byBodyPart.values) {
      list.sort((a, b) =>
          ((a['name'] as String?)?.length ?? 999)
              .compareTo((b['name'] as String?)?.length ?? 999));
    }

    final usedIds = <dynamic>{};
    final picked = <Map<String, dynamic>>[];

    for (final slot in template.slots) {
      final candidates = byBodyPart[slot.bodyPart] ?? const [];
      final chosen = candidates.firstWhere(
        (exercise) => !usedIds.contains(exercise['id']),
        orElse: () => const {},
      );

      if (chosen.isEmpty) continue;

      usedIds.add(chosen['id']);
      picked.add({
        'gym_exercise_id': chosen['id'],
        'sets': slot.sets,
        'reps': slot.reps,
        'duration': null,
        'rest': slot.rest,
      });
    }

    return picked;
  }

  Future<void> _useSuggestion(_SuggestedCycle suggestion) async {
    setState(() {
      _creatingSuggestionName = suggestion.name;
    });

    Map<String, int?> daysPattern = {};
    Set<String> stillNeedsWorkout = {};

    try {
      final catalog = (await _apiService.getGymExercises())
          .cast<Map<String, dynamic>>();

      // A user who already applied this suggestion before has "Push Day"
      // etc. sitting in their custom workouts already; reuse those instead
      // of creating identically-named duplicates on every re-click.
      final existingWorkouts =
          (await _apiService.fetchWorkout()).cast<Map<String, dynamic>>();
      final existingIdByName = <String, int>{
        for (final workout in existingWorkouts)
          if (workout['name'] is String && workout['id'] is int)
            (workout['name'] as String).trim().toLowerCase():
                workout['id'] as int,
      };

      // Every distinct template this cycle uses, in a stable order, so we
      // create one workout per template rather than one per day.
      final templates = <_SuggestedWorkoutTemplate>[];
      for (final template in suggestion.dayTemplates.values) {
        if (!templates.any((t) => identical(t, template))) {
          templates.add(template);
        }
      }

      final workoutIdByTemplate = <_SuggestedWorkoutTemplate, int>{};

      for (final template in templates) {
        final existingId = existingIdByName[template.name.toLowerCase()];
        if (existingId != null) {
          workoutIdByTemplate[template] = existingId;
          continue;
        }

        final exercises = _pickExercisesForTemplate(template, catalog);

        // A template we could not fill a single slot for is skipped rather
        // than saved as an empty workout; its days fall back to
        // "recommended, pick your own" below.
        if (exercises.isEmpty) {
          continue;
        }

        final createdWorkout = await _apiService.storeCustomWorkout(
          template.name,
          template.description,
          exercises,
        );
        workoutIdByTemplate[template] = createdWorkout['id'] as int;
      }

      for (final entry in suggestion.dayTemplates.entries) {
        final workoutId = workoutIdByTemplate[entry.value];
        daysPattern[entry.key] = workoutId;
        if (workoutId == null) {
          stillNeedsWorkout.add(entry.key);
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not set up workouts automatically (${friendlyError(e)}) '
            'Pick a workout for each highlighted day instead.',
          ),
        ),
      );
      // Fall back to the old behaviour: every day is just marked
      // recommended, and the user assigns their own workouts.
      daysPattern = {};
      stillNeedsWorkout = suggestion.dayTemplates.keys.toSet();
    }

    if (!mounted) return;

    setState(() {
      _creatingSuggestionName = null;
    });

    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => NewWorkoutCycleScreen(
          initialName: suggestion.name,
          initialDescription: suggestion.description,
          initialWeeks: suggestion.weeks,
          initialDaysPattern: daysPattern,
          initialActiveDayKeys: stillNeedsWorkout,
        ),
      ),
    );

    if (created == true) {
      _refresh();
    }
  }

  Widget _buildSuggestedCycles(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ready-made plans',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pick one and we\'ll fill in the exercises for each training day. Not sure? Start with Full Body.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 170,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _suggestedCycles.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final suggestion = _suggestedCycles[index];
                final isCreating = _creatingSuggestionName == suggestion.name;
                final isBusy = _creatingSuggestionName != null;

                return SizedBox(
                  width: 220,
                  child: Card(
                    elevation: 1,
                    color: colorScheme.primary.withValues(alpha: 0.06),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                          color: colorScheme.primary.withValues(alpha: 0.2)),
                    ),
                    child: Stack(
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap:
                              isBusy ? null : () => _useSuggestion(suggestion),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        suggestion.name,
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (suggestion.beginnerFriendly) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: colorScheme.tertiaryContainer,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'Beginner',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.onTertiaryContainer,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Expanded(
                                  child: Text(
                                    suggestion.description,
                                    style: theme.textTheme.bodySmall,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '${suggestion.dayTemplates.length} days a week · ${suggestion.weeks} weeks',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isCreating)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: colorScheme.surface
                                    .withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Setting up workouts…',
                                    style: theme.textTheme.bodySmall,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Workout plans',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _plansFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  "Couldn't load your plans. ${friendlyError(snapshot.error!)}",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colorScheme.error),
                ),
              ),
            );
          }

          final plans = snapshot.data ?? [];

          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildSuggestedCycles(theme, colorScheme),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    'Your saved plans',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                if (plans.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.bookmark_border,
                          size: 56,
                          color: colorScheme.primary.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No saved plans yet',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Every plan you create is saved here so you can reuse it later.',
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: plans.map((rawPlan) {
                        final plan = rawPlan as Map<String, dynamic>;
                        final daysPattern =
                            (plan['days_pattern'] as Map<String, dynamic>?) ??
                                {};
                        final activeDays = _activeDaysCount(daysPattern);
                        final name = (plan['name'] as String?)?.trim();
                        final description =
                            (plan['description'] as String?)?.trim();

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Card(
                            elevation: 2,
                            color: colorScheme.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                  color: colorScheme.primary
                                      .withValues(alpha: 0.15)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          (name == null || name.isEmpty)
                                              ? 'Unnamed plan'
                                              : name,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete_outline,
                                            color: colorScheme.error),
                                        tooltip: 'Delete',
                                        onPressed: () => _deletePlan(plan),
                                      ),
                                    ],
                                  ),
                                  if (description != null &&
                                      description.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      description,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                  const SizedBox(height: 4),
                                  Text(
                                    '${plan['weeks']} week${plan['weeks'] == 1 ? '' : 's'} · $activeDays workout day${activeDays == 1 ? '' : 's'}/week',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: FilledButton.icon(
                                      onPressed: _reusingPlanId == null
                                          ? () => _reusePlan(plan)
                                          : null,
                                      icon: _reusingPlanId == plan['id']
                                          ? SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: colorScheme.onPrimary,
                                              ),
                                            )
                                          : const Icon(Icons.replay),
                                      label: const Text('Reuse'),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: colorScheme.primary,
                                        foregroundColor:
                                            colorScheme.onPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
