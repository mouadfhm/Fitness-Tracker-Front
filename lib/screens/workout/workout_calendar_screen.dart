// ignore_for_file: library_private_types_in_public_api

import 'package:fitness_tracker_app/screens/workout/new_workout_cycle_screen.dart';
import 'package:fitness_tracker_app/screens/workout/new_workout_screen.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import './workout_detail_screen.dart';
import '../widgets/bottom_nav_bar.dart';

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
  final List<String> _dayAbbreviations = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
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

  // Initialize _selectedDayIndex with current day of week (0-6, Monday-Sunday)
  int _selectedDayIndex = DateTime.now().weekday - 1;

  final int _currentIndex = 1;
  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _workouts = [];

  @override
  void initState() {
    super.initState();
    _fetchWeeklyPlan();
    _fetchWorkouts(); // Fetch available workouts when the screen loads
  }

  void _fetchWeeklyPlan() {
    if (mounted) {
      setState(() {
        _weeklyPlanFuture = _apiService.fetchWeeklyWorkouts();
      });
    }
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
          _errorMessage = 'Failed to load workouts: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildModeToggle(BuildContext context, {required bool isSimple}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleSegment(context, label: 'Simple', active: isSimple, onTap: widget.onModeToggle),
          _toggleSegment(context, label: 'Advanced', active: !isSimple, onTap: null),
        ],
      ),
    );
  }

  Widget _toggleSegment(BuildContext context, {
    required String label,
    required bool active,
    required VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: active ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: active ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
          ),
        ),
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
          'My Workouts',
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchWeeklyPlan,
            tooltip: 'Refresh workout plan',
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
            return _buildErrorState(snapshot.error.toString());
          } else if (!snapshot.hasData || snapshot.data == null) {
            return _buildEmptyState('No workout plan available');
          }

          final weeklyPlan = snapshot.data!;

          if (!weeklyPlan.containsKey('weeks') || weeklyPlan['weeks'] == null) {
            return _buildEmptyState('No workout plan available');
          }

          final weeksList = weeklyPlan['weeks'] as List<dynamic>?;

          if (weeksList == null || weeksList.isEmpty) {
            return _buildEmptyState('No workout plan available');
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
            return _buildEmptyState(
              'No workout plan for week $_currentWeekNumber',
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
      bottomNavigationBar: CustomBottomNavBar(currentIndex: _currentIndex),
    );
  }

  Widget _buildWeekNavigation(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.05),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
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
                'Week $_currentWeekNumber',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              Text(
                DateTime.now().year.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          IconButton(
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
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                width: 48,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _dayAbbreviations[index],
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
    final selectedDayKey = _dayKeys[_selectedDayIndex];
    final selectedDayName = _dayNames[_selectedDayIndex];
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
                'No workouts for $selectedDayName',
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
                label: const Text('Add Workout'),
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
                  'Workouts for $selectedDayName',
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
                  tooltip: 'Add more workouts',
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
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Add Workout',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
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
                    label: const Text('Create New Workout'),
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
                      hintText: 'Search workouts...',
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
                    'Available Workouts',
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
                              _errorMessage!,
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
                                  'No matching workouts found',
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
                                  'No workouts available',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: colorScheme.primary.withValues(alpha: 0.7),
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Create your first workout',
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
            content: Text('Failed to add workout: ${e.toString()}'),
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
    final workoutData = workout['workout'];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
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
                    label: const Text('Details'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      visualDensity: VisualDensity.compact,
                      foregroundColor: colorScheme.primary,
                      side: BorderSide(color: colorScheme.primary),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _deleteScheduleWorkout(workout['id']),
                    tooltip: 'Remove exercise',
                  ),
                ],
              ),
            ],
          ),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Error loading workouts',
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

  Widget _buildEmptyState(String message) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: colorScheme.primary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _currentWeekNumber--;
                  });
                },
                icon: Icon(Icons.arrow_back, color: colorScheme.onPrimary),
                label: const Text('Previous Week'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _currentWeekNumber++;
                  });
                },
                icon: Icon(Icons.arrow_forward, color: colorScheme.onPrimary),
                label: const Text('Next Week'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NewWorkoutCycleScreen(),
                ),
              );
            },
            icon: Icon(Icons.add, color: colorScheme.onPrimary),
            label: const Text('Create Workout Plan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
          ),
        ],
      ),
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
