// ignore_for_file: library_private_types_in_public_api

import 'package:fitness_tracker_app/screens/workout/new_workout_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

/// Distinguishes "the workout picker was dismissed with no choice made"
/// (bare null) from "Rest day was explicitly chosen" (a wrapped null).
class _WorkoutPick {
  final int? workoutId;
  const _WorkoutPick(this.workoutId);
}

class NewWorkoutCycleScreen extends StatefulWidget {
  final String? initialName;
  final String? initialDescription;
  final int? initialWeeks;
  final Set<String>? initialActiveDayKeys;
  final Map<String, int?>? initialDaysPattern;

  const NewWorkoutCycleScreen({
    super.key,
    this.initialName,
    this.initialDescription,
    this.initialWeeks,
    this.initialActiveDayKeys,
    this.initialDaysPattern,
  });

  @override
  _NewWorkoutCycleScreenState createState() => _NewWorkoutCycleScreenState();
}

class _NewWorkoutCycleScreenState extends State<NewWorkoutCycleScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController =
      TextEditingController();
  DateTime _startDate = DateTime.now();
  int _weeks = 4;
  final Map<String, int?> _daysPattern = {
    'mon': null,
    'tue': null,
    'wed': null,
    'thu': null,
    'fri': null,
    'sat': null,
    'sun': null,
  };
  Set<String> _recommendedDayKeys = {};
  final List<String> _dayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  final List<String> _dayKeys = [
    'mon',
    'tue',
    'wed',
    'thu',
    'fri',
    'sat',
    'sun',
  ];

  bool _isLoading = false;
  bool _isLoadingWorkouts = true;
  String? _errorMessage;

  List<Map<String, dynamic>> _customWorkouts = [];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName ?? '';
    _descriptionController.text = widget.initialDescription ?? '';
    _weeks = widget.initialWeeks ?? 4;
    _recommendedDayKeys = widget.initialActiveDayKeys ?? {};
    if (widget.initialDaysPattern != null) {
      _daysPattern.addAll(widget.initialDaysPattern!);
    }
    _fetchCustomWorkouts();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchCustomWorkouts() async {
    setState(() {
      _isLoadingWorkouts = true;
    });

    try {
      final List<dynamic> workouts = await _apiService.fetchWorkout();

      if (!mounted) return;
      setState(() {
        _customWorkouts = workouts
            .map((workout) => {
                  'id': workout['id'],
                  'name': workout['name'],
                  'description': workout['description'],
                })
            .toList();
        _isLoadingWorkouts = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load custom workouts: ${e.toString()}';
        _isLoadingWorkouts = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Workout Cycle',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isLoadingWorkouts)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchCustomWorkouts,
            tooltip: 'Refresh workout list',
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState(colorScheme)
          : _errorMessage != null
              ? _buildErrorState(theme, colorScheme)
              : _buildForm(theme, colorScheme),
      bottomNavigationBar: _buildBottomBar(colorScheme),
    );
  }

  Widget _buildForm(ThemeData theme, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNameSection(theme, colorScheme),
          const SizedBox(height: 24),
          _buildDescriptionSection(theme, colorScheme),
          const SizedBox(height: 24),
          _buildStartDateSection(theme, colorScheme),
          const SizedBox(height: 24),
          _buildWeeksSection(theme, colorScheme),
          const SizedBox(height: 24),
          _buildDaysPatternSection(theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildNameSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cycle Name',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'e.g. Push Pull Legs',
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        Text(
          'Give it a name so you can save and reuse this cycle later',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description (optional)',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'e.g. A 6-day split focused on strength and hypertrophy',
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildStartDateSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Start Date',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectStartDate,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(_startDate),
                  style: theme.textTheme.bodyLarge,
                ),
                Icon(Icons.calendar_today,
                    size: 20, color: colorScheme.primary),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your workout cycle will begin on this date',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildWeeksSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Number of Weeks',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _weeks.toDouble(),
                min: 1,
                max: 12,
                divisions: 11,
                activeColor: colorScheme.primary,
                inactiveColor: colorScheme.primary.withValues(alpha: 0.2),
                onChanged: (value) {
                  setState(() {
                    _weeks = value.toInt();
                  });
                },
              ),
            ),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                '$_weeks',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
        Text(
          'Your workout cycle will repeat for $_weeks weeks',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  int get _pendingRecommendedDaysCount => _recommendedDayKeys
      .where((dayKey) => _daysPattern[dayKey] == null)
      .length;

  Widget _buildDaysPatternSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Workout Schedule',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose workouts for each day of the week',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (_customWorkouts.isEmpty && !_isLoadingWorkouts)
              TextButton.icon(
                onPressed: _fetchCustomWorkouts,
                icon: Icon(Icons.refresh, size: 18, color: colorScheme.primary),
                label: Text('Refresh',
                    style: TextStyle(color: colorScheme.primary)),
              ),
          ],
        ),
        if (_recommendedDayKeys.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border:
                  Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _pendingRecommendedDaysCount > 0
                        ? 'This template suggests ${_recommendedDayKeys.length} training day(s), marked below. Pick a workout for the $_pendingRecommendedDaysCount day(s) still highlighted in orange — everything else stays a rest day unless you change it.'
                        : 'All suggested training days have a workout assigned.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),

        if (_isLoadingWorkouts)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  CircularProgressIndicator(color: colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Loading your custom workouts...',
                    style: TextStyle(color: colorScheme.onSurface),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else if (_customWorkouts.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(
                    Icons.fitness_center_outlined,
                    size: 64,
                    color: colorScheme.primary.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No custom workouts found',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create custom workouts first before setting up a workout cycle',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NewWorkoutScreen()),
                      ).then((_) => _fetchCustomWorkouts());
                    },
                    icon: Icon(Icons.add, color: colorScheme.onPrimary),
                    label: const Text('Create Workout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _dayNames.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final dayKey = _dayKeys[index];
              final dayName = _dayNames[index];
              final selectedWorkoutId = _daysPattern[dayKey];

              return Card(
                elevation: 2,
                color: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                      color: colorScheme.primary.withValues(alpha: 0.15)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          dayName.substring(0, 1),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dayName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildWorkoutDropdown(
                              theme,
                              dayKey,
                              selectedWorkoutId,
                              colorScheme,
                              isRecommended:
                                  _recommendedDayKeys.contains(dayKey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  String? _workoutNameFor(int? workoutId) {
    if (workoutId == null) return null;
    final match = _customWorkouts.firstWhere(
      (workout) => workout['id'] == workoutId,
      orElse: () => const {},
    );
    return match['name'] as String?;
  }

  /// Removes a deleted workout from every day it was assigned to, so the
  /// pattern never points at a workout that no longer exists.
  void _clearWorkoutFromAllDays(int workoutId) {
    for (final key in _daysPattern.keys.toList()) {
      if (_daysPattern[key] == workoutId) {
        _daysPattern[key] = null;
      }
    }
  }

  Future<void> _deleteWorkoutFromPicker(
    Map<String, dynamic> workout,
    void Function(void Function()) setSheetState,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout'),
        content: Text(
            'Delete "${workout['name']}"? Any day using it will become a rest day.'),
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

    if (confirmed != true) return;

    try {
      await _apiService.deleteCustomWorkout(workout['id'] as int);
      setState(() {
        _customWorkouts.removeWhere((w) => w['id'] == workout['id']);
        _clearWorkoutFromAllDays(workout['id'] as int);
      });
      setSheetState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete workout: ${e.toString()}')),
      );
    }
  }

  Future<void> _openWorkoutPicker(String dayKey, int? currentWorkoutId) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final searchController = TextEditingController();
    String query = '';

    // showModalBottomSheet<T> returns null both when the sheet is dismissed
    // without a choice and when "Rest day" (id: null) is explicitly picked,
    // so a picked value is wrapped in _WorkoutPick to tell the two apart —
    // a bare null here always means "cancelled, leave the day as it was".
    final result = await showModalBottomSheet<_WorkoutPick>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filtered = _customWorkouts
                .where((workout) => (workout['name'] as String? ?? '')
                    .toLowerCase()
                    .contains(query.trim().toLowerCase()))
                .toList();

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: TextField(
                          controller: searchController,
                          autofocus: false,
                          decoration: InputDecoration(
                            hintText: 'Search workouts',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 0),
                          ),
                          onChanged: (value) =>
                              setSheetState(() => query = value),
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.hotel),
                              title: const Text('Rest day'),
                              selected: currentWorkoutId == null,
                              onTap: () => Navigator.pop(
                                  context, const _WorkoutPick(null)),
                            ),
                            if (filtered.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  _customWorkouts.isEmpty
                                      ? 'No custom workouts yet'
                                      : 'No workouts match "$query"',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              )
                            else
                              ...filtered.map((workout) {
                                return ListTile(
                                  leading: const Icon(Icons.fitness_center),
                                  title: Text(workout['name'] ?? ''),
                                  subtitle: (workout['description'] as String?)
                                              ?.isNotEmpty ==
                                          true
                                      ? Text(
                                          workout['description'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      : null,
                                  selected: currentWorkoutId == workout['id'],
                                  onTap: () => Navigator.pop(context,
                                      _WorkoutPick(workout['id'] as int?)),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete_outline,
                                        color: colorScheme.error),
                                    tooltip: 'Delete workout',
                                    onPressed: () => _deleteWorkoutFromPicker(
                                        workout, setSheetState),
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    searchController.dispose();

    if (!mounted || result == null) return;
    setState(() {
      _daysPattern[dayKey] = result.workoutId;
    });
  }

  Widget _buildWorkoutDropdown(
    ThemeData theme,
    String dayKey,
    int? selectedWorkoutId,
    ColorScheme colorScheme, {
    bool isRecommended = false,
  }) {
    final bool showRecommendedHint =
        isRecommended && selectedWorkoutId == null;
    final Color recommendedColor = Colors.orange.shade700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showRecommendedHint)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, size: 14, color: recommendedColor),
                const SizedBox(width: 4),
                Text(
                  'Recommended training day',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: recommendedColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: showRecommendedHint
                ? recommendedColor.withValues(alpha: 0.1)
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: showRecommendedHint
                  ? recommendedColor
                  : colorScheme.primary.withValues(alpha: 0.15),
              width: showRecommendedHint ? 1.5 : 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _openWorkoutPicker(dayKey, selectedWorkoutId),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _workoutNameFor(selectedWorkoutId) ??
                          (showRecommendedHint ? 'Choose a workout' : 'Rest day'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: selectedWorkoutId != null
                            ? colorScheme.onSurface
                            : (showRecommendedHint
                                ? recommendedColor
                                : colorScheme.onSurfaceVariant),
                        fontWeight: selectedWorkoutId != null ||
                                showRecommendedHint
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: colorScheme.primary),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NewWorkoutScreen()),
            ).then((_) => _fetchCustomWorkouts());
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_circle_outline,
                    color: colorScheme.primary, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Add New Workout',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(ColorScheme colorScheme) {
    final bool hasWorkouts = _customWorkouts.isNotEmpty &&
        _nameController.text.trim().isNotEmpty &&
        _pendingRecommendedDaysCount == 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: colorScheme.primary),
              ),
              child: Text('Cancel',
                  style: TextStyle(color: colorScheme.primary)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton(
              onPressed: hasWorkouts && !_isLoadingWorkouts
                  ? _createWorkoutCycle
                  : null,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: colorScheme.primary,
                disabledBackgroundColor:
                    colorScheme.primary.withValues(alpha: 0.3),
              ),
              child: const Text('Create Cycle'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Creating your workout cycle...',
            style: TextStyle(color: colorScheme.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Error Creating Workout Cycle',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage ?? 'An unknown error occurred',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _errorMessage = null;
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _selectStartDate() async {
    final colorScheme = Theme.of(context).colorScheme;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
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

    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  void _createWorkoutCycle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(_startDate);

      await _apiService.storeWeeklyWorkouts(
        _nameController.text.trim(),
        formattedDate,
        _weeks,
        _daysPattern,
        description: _descriptionController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
}
