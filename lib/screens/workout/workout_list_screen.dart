// ignore_for_file: library_private_types_in_public_api

import 'package:fitness_tracker_app/screens/workout/new_workout_screen.dart';
import 'package:fitness_tracker_app/screens/workout/workout_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../services/workout_file_io.dart';
import '../../services/workout_import_service.dart';
import '../../utils/add_banner.dart';
import '../../utils/ad_list_helper.dart';
import 'import_confirmation_dialog.dart';

class WorkoutManagementScreen extends StatefulWidget {
  const WorkoutManagementScreen({super.key});

  @override
  _WorkoutManagementScreenState createState() => _WorkoutManagementScreenState();
}

class _WorkoutManagementScreenState extends State<WorkoutManagementScreen> {
  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> _workouts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchWorkouts();
  }

  Future<void> _fetchWorkouts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<dynamic> workouts = await _apiService.fetchWorkout();
      setState(() {
        _workouts = workouts.map((workout) => workout as Map<String, dynamic>).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load workouts: ${e.toString()}';
        _isLoading = false;
      });
    }
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
      _showSnack(e.message, isError: true);
      _fetchWorkouts();
    } catch (e) {
      _showSnack('Failed to import workout program: $e', isError: true);
      _fetchWorkouts();
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
    _showSnack('Workout "${workoutJson['name']}" imported successfully');
    _fetchWorkouts();
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

    if (!mounted) return;
    final startDate = await _pickCycleStartDate();
    if (startDate == null) return;

    final daysPatternByName = cycleJson['days_pattern'] as Map<String, dynamic>;
    final daysPatternByNewId =
        WorkoutImportService.remapDaysPatternToIds(daysPatternByName, nameToNewId);

    await _apiService.storeWeeklyWorkouts(
      DateFormat('yyyy-MM-dd').format(startDate),
      cycleJson['weeks'] as int,
      daysPatternByNewId,
    );

    if (!mounted) return;
    _showSnack('Workout cycle imported successfully');
    _fetchWorkouts();
  }

  Future<DateTime?> _pickCycleStartDate() {
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
  }

  void _showSnack(String message, {bool isError = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: isError ? colorScheme.onError : colorScheme.onPrimary),
        ),
        backgroundColor: isError ? colorScheme.error : colorScheme.primary,
      ),
    );
  }

  Future<void> _deleteWorkout(int workoutId) async {
    try {
      await _apiService.deleteCustomWorkout(workoutId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Workout deleted successfully',
                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        _fetchWorkouts();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete workout: ${e.toString()}',
                style: TextStyle(color: Theme.of(context).colorScheme.onError)),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _navigateToCreateWorkout() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewWorkoutScreen()),
    );
    if (result == true) {
      _fetchWorkouts();
    }
  }

  void _navigateToWorkoutDetails(Map<String, dynamic> workout) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutDetailScreen(workoutId: workout['id']),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Workout Management', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload_outlined),
            onPressed: _importWorkoutProgram,
            tooltip: 'Import workout program',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchWorkouts,
            tooltip: 'Refresh workouts',
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState(colorScheme)
          : _errorMessage != null
          ? _buildErrorState(colorScheme)
          : _buildWorkoutsList(theme, colorScheme),
      bottomNavigationBar: const AdBannerWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateWorkout,
        backgroundColor: colorScheme.primary,
        child: Icon(Icons.add, color: colorScheme.onPrimary),
      ),
    );
  }

  Widget _buildWorkoutsList(ThemeData theme, ColorScheme colorScheme) {
    if (_workouts.isEmpty) {
      return _buildEmptyState(theme, colorScheme);
    }

    return RefreshIndicator(
      onRefresh: _fetchWorkouts,
      color: colorScheme.primary,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: effectiveItemCount(_workouts.length),
        separatorBuilder: (context, index) =>
            isAdIndex(index) || isAdIndex(index + 1)
                ? const SizedBox.shrink()
                : const SizedBox(height: 12),
        itemBuilder: (context, index) => adAwareItemBuilder(
          index,
          (realIndex) => _buildWorkoutCard(theme, colorScheme, _workouts[realIndex]),
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(ThemeData theme, ColorScheme colorScheme, Map<String, dynamic> workout) {
    return Card(
      elevation: 2,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.15)),
      ),
      child: InkWell(
        onTap: () => _navigateToWorkoutDetails(workout),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout['name'] ?? 'Unnamed Workout',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      workout['description'] ?? 'No description',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: colorScheme.error),
                onPressed: () => _deleteWorkout(workout['id']),
                tooltip: 'Delete workout',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center_outlined,
            size: 64,
            color: colorScheme.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Workouts Yet',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first workout to get started',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _navigateToCreateWorkout,
            icon: Icon(Icons.add, color: colorScheme.onPrimary),
            label: const Text('Create New Workout'),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
            'Loading workouts...',
            style: TextStyle(color: colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Error Loading Workouts',
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
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchWorkouts,
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
}
