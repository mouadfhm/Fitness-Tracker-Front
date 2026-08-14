// ignore_for_file: library_private_types_in_public_api

import 'package:fitness_tracker_app/screens/workout/edit_workout_screen.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/workout_export_service.dart';
import '../../services/workout_file_io.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final int workoutId;

  const WorkoutDetailScreen({super.key, required this.workoutId});

  @override
  _WorkoutDetailScreenState createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  late Future<Map<String, dynamic>> _workoutFuture;
  final ApiService _apiService = ApiService();
  bool _isLoadingWorkouts = true;

  @override
  void initState() {
    super.initState();
    _fetchWorkoutDetails();
  }

  void _fetchWorkoutDetails() {
    setState(() {
      _workoutFuture = _apiService.fetchCustomWorkout(widget.workoutId);
      _isLoadingWorkouts = false;
    });
  }

  Future<void> _exportWorkout() async {
    try {
      final workout = await _workoutFuture;
      final json = WorkoutExportService.workoutExportJson(workout);
      final filename = WorkoutExportService.suggestExportFilename(workout['name'] as String);
      final saved = await WorkoutFileIO.saveJsonFile(
        suggestedFileName: filename,
        contents: json,
      );
      if (!mounted || !saved) return;
      _showSnack('Workout exported successfully');
    } catch (e) {
      if (!mounted) return;
      _showSnack('Failed to export workout: $e', isError: true);
    }
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Workout Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
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
            onPressed: _fetchWorkoutDetails,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _workoutFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchWorkoutDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No workout details available'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchWorkoutDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          final workout = snapshot.data!;
          final exercises = workout['gym_exercises'] as List<dynamic>;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              workout['name'],
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.ios_share, color: colorScheme.primary),
                            tooltip: 'Export workout',
                            onPressed: _exportWorkout,
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: colorScheme.primary),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditWorkoutScreen(
                                    workoutId: widget.workoutId,
                                  ),
                                ),
                              );
                              _fetchWorkoutDetails();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        workout['description'] ?? 'No description available',
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        children: [
                          Chip(
                            label: Text('${exercises.length} Exercises'),
                            backgroundColor:
                                colorScheme.primary.withValues(alpha: 0.1),
                            labelStyle: TextStyle(color: colorScheme.primary),
                          ),
                          Chip(
                            label: Text(_calculateTotalTime(exercises)),
                            backgroundColor:
                                colorScheme.primary.withValues(alpha: 0.1),
                            labelStyle: TextStyle(color: colorScheme.primary),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      Text(
                        'Exercises',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final exercise = exercises[index];
                    final pivot = exercise['pivot'];
                    return ExerciseCard(
                      exercise: exercise,
                      sets: pivot['sets'],
                      reps: pivot['reps'],
                      duration: pivot['duration'],
                      rest: pivot['rest'],
                    );
                  },
                  childCount: exercises.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
    );
  }

  String _calculateTotalTime(List<dynamic> exercises) {
    int totalTimeInSeconds = 0;

    for (var exercise in exercises) {
      final pivot = exercise['pivot'];
      final sets = pivot['sets'] as int;
      final rest = pivot['rest'] as int;

      int repsTime = 0;
      if (pivot['reps'] != null) {
        repsTime = (pivot['reps'] as int) * 3 * sets;
      } else if (pivot['duration'] != null) {
        repsTime = (pivot['duration'] as int) * sets;
      }

      int restTime = rest * (sets - 1);
      totalTimeInSeconds += repsTime + restTime;
    }

    totalTimeInSeconds += (exercises.length - 1) * 5 * 60;
    int minutes = totalTimeInSeconds ~/ 60;
    return '$minutes min';
  }
}

class ExerciseCard extends StatelessWidget {
  final Map<String, dynamic> exercise;
  final int sets;
  final int? reps;
  final int? duration;
  final int rest;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.sets,
    required this.reps,
    required this.duration,
    required this.rest,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.15)),
      ),
      child: ExpansionTile(
        title: Text(
          exercise['name'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${exercise['body_part']} • ${exercise['type']}',
              style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                _buildDetailChip(colorScheme, Icons.replay, '$sets sets'),
                if (reps != null)
                  _buildDetailChip(colorScheme, Icons.fitness_center, '$reps reps')
                else if (duration != null)
                  _buildDetailChip(colorScheme, Icons.timer, '${duration}s'),
                _buildDetailChip(colorScheme, Icons.hourglass_bottom, '${rest}s rest'),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Description:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  exercise['description'] ?? 'No description available',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Equipment: ${exercise['equipment']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      'Level: ${exercise['level']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip(ColorScheme colorScheme, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
