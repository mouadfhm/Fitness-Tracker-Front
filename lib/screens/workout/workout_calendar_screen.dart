// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'package:fitness_tracker_app/utils/friendly_error.dart';

import 'package:fitness_tracker_app/screens/workout/new_workout_cycle_screen.dart';
import 'package:fitness_tracker_app/screens/workout/new_workout_screen.dart';
import 'package:fitness_tracker_app/screens/workout/saved_workout_cycles_screen.dart';
import 'package:flutter/material.dart';
import '../../utils/adaptive.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import './workout_detail_screen.dart';
import '../../utils/add_banner.dart';
import '../../services/workout_export_service.dart';
import '../../services/workout_file_io.dart';
import '../../services/workout_import_service.dart';
import 'import_confirmation_dialog.dart';
import '../../l10n/app_localizations.dart';

class WorkoutCalendarScreen extends StatefulWidget {
  final VoidCallback? onModeToggle;

  const WorkoutCalendarScreen({super.key, this.onModeToggle});

  @override
  _WorkoutCalendarScreenState createState() => _WorkoutCalendarScreenState();
}

class _WorkoutCalendarScreenState extends State<WorkoutCalendarScreen> {
  late Future<Map<String, dynamic>> _weeklyPlanFuture;
  final ApiService _apiService = ApiService();
  int _currentWeekNumber = DateTime.now().weekOfYear;

  /// One-letter day initials (M T W ... in English, L M M ... in French).
  String _dayAbbreviation(int index) {
    // 2024-01-01 was a Monday.
    return DateFormat('EEEEE', Localizations.localeOf(context).toString())
        .format(DateTime(2024, 1, 1 + index));
  }

  String _dayName(AppLocalizations l10n, int index) {
    switch (index) {
      case 0:
        return l10n.dayMonday;
      case 1:
        return l10n.dayTuesday;
      case 2:
        return l10n.dayWednesday;
      case 3:
        return l10n.dayThursday;
      case 4:
        return l10n.dayFriday;
      case 5:
        return l10n.daySaturday;
      default:
        return l10n.daySunday;
    }
  }

  final List<String> _dayKeys = [
    'mon',
    'tue',
    'wed',
    'thu',
    'fri',
    'sat',
    'sun',
  ];

  // Initialize _selectedDayIndex with current day of week (0-6, Monday-Sunday)
  int _selectedDayIndex = DateTime.now().weekday - 1;

  bool _isLoading = false;
  // Holds the friendly reason only; the localized prefix is added in build.
  String? _errorMessage;
  List<Map<String, dynamic>> _workouts = [];
  bool _hasCycle = false;

  @override
  void initState() {
    super.initState();
    _fetchWeeklyPlan();
    _fetchWorkouts(); // Fetch available workouts when the screen loads
  }

  void _openSavedCycles() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SavedWorkoutCyclesScreen(),
      ),
    );
    // Starting a ready-made plan happens inside that screen and doesn't
    // always report back, so refresh whenever we return.
    if (mounted) _fetchWeeklyPlan();
  }

  void _fetchWeeklyPlan() {
    if (mounted) {
      setState(() {
        _weeklyPlanFuture = _apiService.fetchWeeklyWorkouts();
      });
      _weeklyPlanFuture.then((plan) {
        if (!mounted) return;
        final weeksList = plan['weeks'] as List<dynamic>?;
        setState(() {
          _hasCycle = weeksList != null && weeksList.isNotEmpty;
        });
      }).catchError((_) {
        if (!mounted) return;
        setState(() {
          _hasCycle = false;
        });
      });
    }
  }

  Future<void> _exportCycle() async {
    try {
      final weeklyPlan = await _weeklyPlanFuture;
      final weeksList = weeklyPlan['weeks'] as List<dynamic>?;
      if (weeksList == null || weeksList.isEmpty) {
        if (!mounted) return;
        _showSnack(AppLocalizations.of(context)!.workoutCalendarNoExportPlan);
        return;
      }

      final pattern = WorkoutExportService.extractCyclePattern(weeklyPlan);
      final uniqueIds = pattern.daysPattern.values.whereType<int>().toSet();

      final detailsById = <int, Map<String, dynamic>>{};
      for (final id in uniqueIds) {
        detailsById[id] = await _apiService.fetchCustomWorkout(id);
      }

      final json = WorkoutExportService.cycleExportJson(
        weeks: pattern.weeks,
        daysPatternByWorkoutId: pattern.daysPattern,
        workoutDetailsById: detailsById,
      );

      final saved = await WorkoutFileIO.saveJsonFile(
        suggestedFileName: 'workout_cycle.json',
        contents: json,
      );

      if (!mounted || !saved) return;
      _showSnack(AppLocalizations.of(context)!.workoutCalendarExportedPlan);
    } catch (e) {
      if (!mounted) return;
      _showSnack(
        AppLocalizations.of(context)!.workoutCalendarExportPlanFailed(friendlyError(e)),
        isError: true,
      );
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : colorScheme.primary,
      ),
    );
  }

  Future<void> _importWorkoutProgram() async {
    try {
      final contents = await WorkoutFileIO.pickJsonFileContents();
      if (contents == null) return;

      final decoded = WorkoutImportService.parseWorkoutImportJson(contents);
      final catalog =
          (await _apiService.getGymExercises()).cast<Map<String, dynamic>>();

      if (decoded['type'] == 'workout') {
        await _importSingleWorkout(decoded, catalog);
      } else {
        await _importWorkoutCycle(decoded, catalog);
      }
    } on WorkoutImportFormatException catch (e) {
      if (!mounted) return;
      _showSnack(e.message, isError: true);
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      _showSnack(
        l10n.workoutCalendarImportPlanFailed(
          friendlyError(e, fallback: l10n.workoutCalendarImportFileHint),
        ),
        isError: true,
      );
    }
  }

  Future<void> _importSingleWorkout(
    Map<String, dynamic> workoutJson,
    List<Map<String, dynamic>> catalog,
  ) async {
    final match = WorkoutImportService.matchWorkoutExercises(workoutJson, catalog);

    if (!mounted) return;
    final confirmed = await ImportConfirmationDialog.show(
      context,
      workoutNames: [workoutJson['name'] as String],
      unmatchedExerciseNames: match.unmatchedNames,
    );
    if (!confirmed) return;

    await _apiService.storeCustomWorkout(
      workoutJson['name'] as String,
      workoutJson['description'] as String? ?? '',
      match.matchedGymExercises,
    );

    if (!mounted) return;
    _showSnack(AppLocalizations.of(context)!
        .workoutListSingleImportedSuccess(workoutJson['name'] as String));
    await _fetchWorkouts();
  }

  Future<void> _importWorkoutCycle(
    Map<String, dynamic> cycleJson,
    List<Map<String, dynamic>> catalog,
  ) async {
    final workoutsJson =
        (cycleJson['workouts'] as List<dynamic>).cast<Map<String, dynamic>>();

    final matches = <String, ExerciseMatchResult>{};
    final allUnmatched = <String>{};
    for (final workoutJson in workoutsJson) {
      final match = WorkoutImportService.matchWorkoutExercises(workoutJson, catalog);
      matches[workoutJson['name'] as String] = match;
      allUnmatched.addAll(match.unmatchedNames);
    }

    if (!mounted) return;
    final confirmed = await ImportConfirmationDialog.show(
      context,
      workoutNames: workoutsJson.map((w) => w['name'] as String).toList(),
      unmatchedExerciseNames: allUnmatched.toList(),
    );
    if (!confirmed) return;

    if (!mounted) return;
    final startDate = await _pickCycleStartDate();
    if (startDate == null) return;

    final nameToNewId = <String, int>{};
    for (final workoutJson in workoutsJson) {
      final name = workoutJson['name'] as String;
      final created = await _apiService.storeCustomWorkout(
        name,
        workoutJson['description'] as String? ?? '',
        matches[name]!.matchedGymExercises,
      );
      nameToNewId[name] = created['id'] as int;
    }

    final daysPatternByName = cycleJson['days_pattern'] as Map<String, dynamic>;
    final daysPatternByNewId =
        WorkoutImportService.remapDaysPatternToIds(daysPatternByName, nameToNewId);

    await _apiService.storeWeeklyWorkouts(
      (cycleJson['name'] as String?) ?? 'Imported Cycle',
      DateFormat('yyyy-MM-dd').format(startDate),
      cycleJson['weeks'] as int,
      daysPatternByNewId,
    );

    if (!mounted) return;
    _showSnack(AppLocalizations.of(context)!.workoutCalendarImportedPlan);
    await _fetchWorkouts();
    _fetchWeeklyPlan();
  }

  Future<DateTime?> _pickCycleStartDate() {
    return showAdaptiveDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
  }

  void _deleteScheduleWorkout(int scheduleWorkoutId) async {
    await _apiService.deleteScheduleWorkout(scheduleWorkoutId);
    if (mounted) {
      _fetchWeeklyPlan();
    }
  }

  Future<void> _fetchWorkouts() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<dynamic> workouts = await _apiService.fetchWorkout();
      if (mounted) {
        setState(() {
          _workouts =
              workouts
                  .map((workout) => workout as Map<String, dynamic>)
                  .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = friendlyError(e);
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildModeToggle(BuildContext context, {required bool isSimple}) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleSegment(
            context,
            label: l10n.workoutModeSimple,
            semanticsLabel: l10n.workoutCalendarSimpleModeSemantics,
            active: isSimple,
            onTap: widget.onModeToggle,
          ),
          _toggleSegment(
            context,
            label: l10n.workoutModeAdvanced,
            semanticsLabel: l10n.workoutCalendarAdvancedModeSemantics,
            active: !isSimple,
            onTap: null,
          ),
        ],
      ),
    );
  }

  Widget _toggleSegment(BuildContext context, {
    required String label,
    required String semanticsLabel,
    required bool active,
    required VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: active,
      label: semanticsLabel,
      excludeSemantics: true,
      child: GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: active ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.workoutCalendarTitle,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        actions: [
          if (widget.onModeToggle != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: _buildModeToggle(context, isSimple: false),
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: l10n.workoutCalendarOptionsTooltip,
            onSelected: (value) {
              if (value == 'export') {
                _exportCycle();
              } else if (value == 'import') {
                _importWorkoutProgram();
              } else if (value == 'saved') {
                _openSavedCycles();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'saved',
                child: Row(
                  children: [
                    const Icon(Icons.bookmark_border, size: 20),
                    const SizedBox(width: 12),
                    Text(l10n.workoutCalendarReadyMadePlans),
                  ],
                ),
              ),
              if (_hasCycle)
                PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      const Icon(Icons.ios_share, size: 20),
                      const SizedBox(width: 12),
                      Text(l10n.workoutCalendarExportMyPlan),
                    ],
                  ),
                ),
              PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    const Icon(Icons.file_upload_outlined, size: 20),
                    const SizedBox(width: 12),
                    Text(l10n.workoutCalendarImportPlan),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      body: FutureBuilder<Map<String, dynamic>>(
        future: _weeklyPlanFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          } else if (snapshot.hasError) {
            return _buildErrorState(
                l10n.workoutCalendarLoadPlanFailed(friendlyError(snapshot.error!)));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return _buildEmptyState(l10n.workoutCalendarNoPlanYet);
          }

          final weeklyPlan = snapshot.data!;

          if (!weeklyPlan.containsKey('weeks') || weeklyPlan['weeks'] == null) {
            return _buildEmptyState(l10n.workoutCalendarNoPlanYet);
          }

          final weeksList = weeklyPlan['weeks'] as List<dynamic>?;

          if (weeksList == null || weeksList.isEmpty) {
            return _buildEmptyState(l10n.workoutCalendarNoPlanYet);
          }

          Map<String, dynamic>? currentWeekData;

          for (final week in weeksList) {
            final weekStart = DateTime.parse(week['week_start']);
            if (weekStart.weekOfYear == _currentWeekNumber) {
              currentWeekData = week['days'];
              break;
            }
          }

          if (currentWeekData == null) {
            // The plan exists but not this week (e.g. it starts next
            // Monday): point to the nearest planned week instead of
            // suggesting a brand-new plan.
            DateTime? nextWeekStart;
            for (final week in weeksList) {
              final start = DateTime.parse(week['week_start']);
              if (start.isAfter(_shownMonday) &&
                  (nextWeekStart == null || start.isBefore(nextWeekStart))) {
                nextWeekStart = start;
              }
            }
            return _buildEmptyState(
              l10n.workoutCalendarNothingPlannedThisWeek,
              showWeekNavigation: true,
              nextPlannedWeek: nextWeekStart,
            );
          }

          return Column(
            children: [
              _buildWeekNavigation(theme),
              _buildDaysSelector(theme, currentWeekData),
              Divider(
                height: 1,
                color: colorScheme.outlineVariant,
              ),
              _buildWorkoutsList(theme, currentWeekData),
            ],
          );
        },
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }

  Widget _buildWeekNavigation(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.05),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            tooltip: l10n.workoutCalendarPreviousWeek,
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            style: IconButton.styleFrom(
              foregroundColor: colorScheme.primary,
              backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: colorScheme.primary.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.all(12),
            ),
            onPressed: () {
              setState(() {
                _currentWeekNumber--;
              });
            },
          ),
          Column(
            children: [
              Text(
                _weekRangeLabel(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              Text(
                _relativeWeekLabel(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          IconButton(
            tooltip: l10n.workoutCalendarNextWeek,
            icon: const Icon(Icons.arrow_forward_ios, size: 18),
            style: IconButton.styleFrom(
              foregroundColor: colorScheme.primary,
              backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: colorScheme.primary.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.all(12),
            ),
            onPressed: () {
              setState(() {
                _currentWeekNumber++;
              });
            },
          ),
        ],
      ),
    );
  }

  /// Monday of the week being shown. Week numbers come from [weekOfYear], so
  /// step from this week's Monday rather than re-deriving ISO dates.
  DateTime get _shownMonday {
    final now = DateTime.now();
    final thisMonday = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    final offset = _currentWeekNumber - now.weekOfYear;
    return DateTime(thisMonday.year, thisMonday.month, thisMonday.day + 7 * offset);
  }

  /// "Oct 5 – Oct 11" — people think in dates, not week numbers.
  String _weekRangeLabel() {
    final monday = _shownMonday;
    final sunday = DateTime(monday.year, monday.month, monday.day + 6);
    final fmt = DateFormat.MMMd(Localizations.localeOf(context).toString());
    return '${fmt.format(monday)} – ${fmt.format(sunday)}';
  }

  String _relativeWeekLabel() {
    final l10n = AppLocalizations.of(context)!;
    final offset = _currentWeekNumber - DateTime.now().weekOfYear;
    if (offset == 0) return l10n.workoutCalendarThisWeek;
    if (offset == 1) return l10n.workoutCalendarNextWeekRelative;
    if (offset == -1) return l10n.workoutCalendarLastWeek;
    return _shownMonday.year.toString();
  }

  Widget _buildDaysSelector(ThemeData theme, Map<String, dynamic> weekData) {
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary.withValues(alpha: 0.05), Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: List.generate(7, (index) {
            final dayKey = _dayKeys[index];
            final dayData = weekData[dayKey] as Map<String, dynamic>?;
            final workouts = dayData?['workouts'] as List<dynamic>? ?? [];
            final hasWorkout = workouts.isNotEmpty;
            final isSelected = index == _selectedDayIndex;
            final isToday =
                index == (DateTime.now().weekday - 1) &&
                _currentWeekNumber == DateTime.now().weekOfYear;

            final backgroundColor = isSelected
                ? colorScheme.primary.withValues(alpha: 0.8)
                : isToday
                    ? colorScheme.primary.withValues(alpha: 0.2)
                    : colorScheme.surfaceContainerHighest;

            final textColor = isSelected
                ? colorScheme.onPrimary
                : (isToday ? colorScheme.primary : colorScheme.onSurfaceVariant);

            final dotColor = hasWorkout
                ? (isSelected ? colorScheme.onPrimary : colorScheme.primary)
                : Colors.transparent;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDayIndex = index;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: isToday && !isSelected
                      ? Border.all(color: colorScheme.primary, width: 2)
                      : null,
                ),
                width: 48,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _dayAbbreviation(index),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: textColor,
                        fontWeight:
                            isToday || isSelected ? FontWeight.bold : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: dotColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildWorkoutsList(ThemeData theme, Map<String, dynamic> weekData) {
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final selectedDayKey = _dayKeys[_selectedDayIndex];
    final selectedDayName = _dayName(l10n, _selectedDayIndex);
    final dayData = weekData[selectedDayKey] as Map<String, dynamic>?;
    final workouts = dayData?['workouts'] as List<dynamic>? ?? [];

    if (workouts.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.fitness_center_outlined,
                size: 64,
                color: colorScheme.primary.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.workoutCalendarNoWorkoutsForDay(selectedDayName),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  _showWorkoutSelectionDialog(selectedDayKey);
                },
                icon: Icon(
                  Icons.add,
                  color: colorScheme.onPrimary,
                ),
                label: Text(l10n.workoutCalendarAddWorkoutButton),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(left: 20, top: 16, bottom: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary.withValues(alpha: 0.05), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.workoutCalendarWorkoutsForDay(selectedDayName),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle, color: colorScheme.primary),
                  onPressed: () {
                    _showWorkoutSelectionDialog(selectedDayKey);
                  },
                  tooltip: l10n.workoutCalendarAddMoreTooltip,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: workouts.length,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemBuilder: (context, index) {
                final workout = workouts[index];
                return _buildWorkoutCard(theme, workout);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showWorkoutSelectionDialog(String dayKey) async {
    if (_workouts.isEmpty && !_isLoading) {
      await _fetchWorkouts();
    }

    if (!mounted) return;

    // Local state — avoids stale results between modal openings
    var filteredWorkouts = List<Map<String, dynamic>>.from(_workouts);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final l10n = AppLocalizations.of(context)!;
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        l10n.workoutCalendarAddWorkoutButton,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NewWorkoutScreen(),
                        ),
                      ).then((_) {
                        _fetchWorkouts();
                      });
                    },
                    icon: Icon(Icons.add, color: colorScheme.onPrimary),
                    label: Text(l10n.workoutListCreateNewWorkout),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      hintText: l10n.workoutCalendarSearchWorkoutsHint,
                      hintStyle: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.outlineVariant,
                        ),
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest,
                    ),
                    style: TextStyle(
                      color: colorScheme.onSurface,
                    ),
                    onChanged: (value) {
                      setModalState(() {
                        if (value.isEmpty) {
                          filteredWorkouts = List.from(_workouts);
                        } else {
                          filteredWorkouts = _workouts.where((workout) {
                            final name =
                                (workout['name'] as String).toLowerCase();
                            final description = workout['description'] != null
                                ? (workout['description'] as String)
                                    .toLowerCase()
                                : '';
                            final searchLower = value.toLowerCase();
                            return name.contains(searchLower) ||
                                description.contains(searchLower);
                          }).toList();
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.workoutCalendarAvailableWorkouts,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: colorScheme.primary,
                            ),
                          )
                        : _errorMessage != null
                        ? Center(
                            child: Text(
                              l10n.workoutCalendarLoadWorkoutsFailed(_errorMessage!),
                              style: TextStyle(
                                color: colorScheme.error,
                              ),
                            ),
                          )
                        : filteredWorkouts.isEmpty && _workouts.isNotEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: colorScheme.primary.withValues(alpha: 0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  l10n.workoutCalendarNoMatchingWorkouts,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: colorScheme.primary.withValues(alpha: 0.7),
                                      ),
                                ),
                              ],
                            ),
                          )
                        : _workouts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.fitness_center_outlined,
                                  size: 64,
                                  color: colorScheme.primary.withValues(alpha: 0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  l10n.workoutNoneAvailable,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: colorScheme.primary.withValues(alpha: 0.7),
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.workoutCalendarCreateFirstWorkout,
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: filteredWorkouts.length,
                            separatorBuilder: (context, index) => Divider(
                              color: colorScheme.outlineVariant,
                            ),
                            itemBuilder: (context, index) {
                              final workout = filteredWorkouts[index];
                              return ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: _getWorkoutColor(
                                      workout['name'] as String,
                                      colorScheme,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    _getWorkoutIcon(
                                      workout['name'] as String,
                                    ),
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  workout['name'] as String,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                subtitle: workout['description'] != null
                                    ? Text(
                                        workout['description'] as String,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      )
                                    : null,
                                trailing: IconButton(
                                  tooltip: l10n.workoutCalendarAddToDayTooltip,
                                  icon: const Icon(Icons.add_circle_outline),
                                  color: colorScheme.primary,
                                  onPressed: () {
                                    _addWorkoutToDay(workout, dayKey);
                                    Navigator.pop(context);
                                  },
                                ),
                                onTap: () {
                                  _addWorkoutToDay(workout, dayKey);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _addWorkoutToDay(
    Map<String, dynamic> workout,
    String dayKey,
  ) async {
    try {
      final now = DateTime.now();
      final currentWeek = DateTime.now().weekOfYear;
      final weekDifference = _currentWeekNumber - currentWeek;
      final firstDayOfCurrentWeek = now.subtract(
        Duration(days: now.weekday - 1),
      );
      final firstDayOfSelectedWeek = firstDayOfCurrentWeek.add(
        Duration(days: 7 * weekDifference),
      );
      final dayOffset = _dayKeys.indexOf(dayKey);
      final selectedDate = firstDayOfSelectedWeek.add(
        Duration(days: dayOffset),
      );
      final dateString =
          "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

      await _apiService.storeScheduleWorkout(workout['id'], dateString);

      if (mounted) {
        _fetchWeeklyPlan();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!
                .workoutCalendarAddWorkoutFailed(friendlyError(e))),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildWorkoutCard(ThemeData theme, dynamic workout) {
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final workoutData = workout['workout'];

    if (workoutData is! Map || workoutData['name'] is! String) {
      debugPrint('MALFORMED_WORKOUT_ENTRY: ${jsonEncode(workout)}');
      return _buildMalformedWorkoutCard(theme, workout);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  WorkoutDetailScreen(workoutId: workoutData['id']),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getWorkoutColor(
                        workoutData['name'] as String,
                        colorScheme,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getWorkoutIcon(workoutData['name'] as String),
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workoutData['name'],
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (workoutData['description'] != null &&
                            workoutData['description'].isNotEmpty)
                          Text(
                            workoutData['description'],
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WorkoutDetailScreen(
                            workoutId: workoutData['id'],
                          ),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.info_outline,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    label: Text(l10n.workoutCalendarDetailsButton),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      foregroundColor: colorScheme.primary,
                      side: BorderSide(color: colorScheme.primary),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _deleteScheduleWorkout(workout['id']),
                    tooltip: l10n.workoutCalendarRemoveExerciseTooltip,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMalformedWorkoutCard(ThemeData theme, dynamic workout) {
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: colorScheme.errorContainer.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colorScheme.error.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: colorScheme.error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.workoutCalendarMalformedEntry,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: colorScheme.error),
              onPressed: () => _deleteScheduleWorkout(workout['id']),
              tooltip: l10n.workoutCalendarRemoveEntryTooltip,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getWorkoutIcon(String workoutName) {
    final name = workoutName.toLowerCase();
    if (name.contains('cardio') || name.contains('run')) {
      return Icons.directions_run;
    } else if (name.contains('yoga') || name.contains('stretch')) {
      return Icons.self_improvement;
    } else if (name.contains('chest') || name.contains('push')) {
      return Icons.fitness_center;
    } else if (name.contains('leg')) {
      return Icons.accessibility_new;
    } else {
      return Icons.fitness_center;
    }
  }

  Color _getWorkoutColor(String workoutName, ColorScheme colorScheme) {
    final name = workoutName.toLowerCase();
    if (name.contains('cardio') || name.contains('run')) {
      return Colors.orange;
    } else if (name.contains('back') || name.contains('pull')) {
      return Colors.green;
    } else if (name.contains('chest') || name.contains('push')) {
      return Colors.blue;
    } else if (name.contains('leg')) {
      return Colors.purple;
    } else {
      return colorScheme.primary;
    }
  }

  Widget _buildErrorState(String error) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: colorScheme.error),
          const SizedBox(height: 16),
          Text(
            l10n.workoutLoadError,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchWeeklyPlan,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.workoutTryAgain),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    String message, {
    bool showWeekNavigation = false,
    DateTime? nextPlannedWeek,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        if (showWeekNavigation) _buildWeekNavigation(theme),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 56,
                color: colorScheme.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (nextPlannedWeek != null) ...[
                Text(
                  l10n.workoutCalendarPlanStartsWeekOf(
                    DateFormat.MMMMd(Localizations.localeOf(context).toString())
                        .format(nextPlannedWeek),
                  ),
                  style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => setState(() => _currentWeekNumber = nextPlannedWeek.weekOfYear),
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(l10n.workoutCalendarShowThatWeek),
                ),
              ] else ...[
              // One clear starting point for beginners instead of a wall of
              // equally weighted buttons.
              Card(
                elevation: 0,
                color: colorScheme.primaryContainer,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.workoutCalendarNewToWorkingOut,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.workoutCalendarReadyMadePitch,
                        style: TextStyle(fontSize: 15, color: colorScheme.onPrimaryContainer),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _openSavedCycles,
                          icon: const Icon(Icons.play_arrow),
                          label: Text(l10n.workoutCalendarChooseReadyMadePlan),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NewWorkoutCycleScreen(),
                    ),
                  ).then((_) => _fetchWeeklyPlan());
                },
                icon: const Icon(Icons.edit_calendar),
                label: Text(l10n.workoutCalendarBuildOwnPlan),
              ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// Extension to get week of year
extension DateTimeExtension on DateTime {
  int get weekOfYear {
    final firstDayOfYear = DateTime(year, 1, 1);
    final dayOfYear = difference(firstDayOfYear).inDays;
    return ((dayOfYear - weekday + 10) / 7).floor();
  }
}
