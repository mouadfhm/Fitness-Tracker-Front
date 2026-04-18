// ignore_for_file: library_private_types_in_public_api

import 'package:fitness_tracker_app/screens/workout/new_workout_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class NewWorkoutCycleScreen extends StatefulWidget {
  const NewWorkoutCycleScreen({super.key});

  @override
  _NewWorkoutCycleScreenState createState() => _NewWorkoutCycleScreenState();
}

class _NewWorkoutCycleScreenState extends State<NewWorkoutCycleScreen> {
  final ApiService _apiService = ApiService();
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
    _fetchCustomWorkouts();
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
          _buildStartDateSection(theme, colorScheme),
          const SizedBox(height: 24),
          _buildWeeksSection(theme, colorScheme),
          const SizedBox(height: 24),
          _buildDaysPatternSection(theme, colorScheme),
        ],
      ),
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
                                theme, dayKey, selectedWorkoutId, colorScheme),
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

  Widget _buildWorkoutDropdown(
    ThemeData theme,
    String dayKey,
    int? selectedWorkoutId,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.15)),
          ),
          child: DropdownButton<int?>(
            value: selectedWorkoutId,
            hint: Text(
              'Rest day',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            underline: const SizedBox(),
            isExpanded: true,
            dropdownColor: colorScheme.surface,
            icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
            items: [
              DropdownMenuItem<int?>(
                value: null,
                child: Text('Rest day',
                    style: TextStyle(color: colorScheme.onSurface)),
              ),
              ..._customWorkouts.map((workout) {
                return DropdownMenuItem<int?>(
                  value: workout['id'],
                  child: Text(
                    workout['name'],
                    style: TextStyle(color: colorScheme.onSurface),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }),
            ],
            selectedItemBuilder: (BuildContext context) {
              return [
                DropdownMenuItem<String>(
                  value: 'Rest day',
                  child: Text(
                    'Rest day',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ..._customWorkouts.map((workout) {
                  return DropdownMenuItem<String>(
                    value: workout['name'],
                    child: Text(
                      workout['name'],
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }),
              ];
            },
            onChanged: (newValue) {
              setState(() {
                _daysPattern[dayKey] = newValue;
              });
            },
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
    final bool hasWorkouts = _customWorkouts.isNotEmpty;

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
        formattedDate,
        _weeks,
        _daysPattern,
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
