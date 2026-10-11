// lib/screens/workout/exercise_selection_screen.dart
// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workout_provider.dart';
import '../../models/workout.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/add_banner.dart';
import '../../utils/ad_list_helper.dart';

class ExerciseSelectionScreen extends StatefulWidget {
  const ExerciseSelectionScreen({super.key});

  @override
  _ExerciseSelectionScreenState createState() => _ExerciseSelectionScreenState();
}

class _ExerciseSelectionScreenState extends State<ExerciseSelectionScreen> {
  String _selectedBodyPart = 'All';
  Exercise? _selectedExercise;
  
  final _setsController = TextEditingController(text: '3');
  final _repsController = TextEditingController(text: '12');
  final _durationController = TextEditingController();
  final _restController = TextEditingController(text: '60');
  
  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    _durationController.dispose();
    _restController.dispose();
    super.dispose();
  }
  
  List<String> _getUniqueBodyParts(List<Exercise> exercises) {
    final bodyParts = exercises.map((e) => e.bodyPart).toSet().toList();
    bodyParts.sort();
    return ['All', ...bodyParts];
  }
  
  List<Exercise> _filterExercises(List<Exercise> exercises) {
    if (_selectedBodyPart == 'All') {
      return exercises;
    }
    return exercises.where((e) => e.bodyPart == _selectedBodyPart).toList();
  }
  
  void _addExercise() {
    if (_selectedExercise == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.exerciseSelectionPleaseSelect),
        ),
      );
      return;
    }
    
    final sets = int.tryParse(_setsController.text) ?? 0;
    final reps = int.tryParse(_repsController.text) ?? 0;
    final rest = int.tryParse(_restController.text) ?? 0;
    
    if (sets <= 0 || reps <= 0 || rest <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.exerciseSelectionInvalidValues),
        ),
      );
      return;
    }
    
    int? duration;
    if (_durationController.text.isNotEmpty) {
      duration = int.tryParse(_durationController.text);
      if (duration != null && duration <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.exerciseSelectionInvalidDuration),
          ),
        );
        return;
      }
    }
    
    final exerciseData = {
      'gym_exercise_id': _selectedExercise!.id,
      'name': _selectedExercise!.name,
      'sets': sets,
      'reps': reps,
      'duration': duration,
      'rest': rest,
    };
    
    Navigator.of(context).pop(exerciseData);
  }
  
  @override
  Widget build(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final exercises = workoutProvider.exercises;
    final filteredExercises = _filterExercises(exercises);
    final bodyParts = _getUniqueBodyParts(exercises);
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.exerciseSelectionTitle,
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      bottomNavigationBar: const AdBannerWidget(),
      body: workoutProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.exerciseSelectionFilterByBodyPart),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButton<String>(
                          value: _selectedBodyPart,
                          isExpanded: true,
                          underline: const SizedBox(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedBodyPart = newValue!;
                              _selectedExercise = null;
                            });
                          },
                          items: bodyParts
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value == 'All'
                                  ? l10n.exerciseSelectionAllBodyParts
                                  : value),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredExercises.isEmpty
                      ? Center(
                          child: Text(l10n.newWorkoutNoExercisesFound),
                        )
                      : ListView.builder(
                          itemCount: effectiveItemCount(filteredExercises.length),
                          itemBuilder: (ctx, index) => adAwareItemBuilder(
                            index,
                            (realIndex) {
                              final exercise = filteredExercises[realIndex];
                              return RadioListTile<Exercise>(
                                title: Text(exercise.name),
                                subtitle: Text(
                                  '${exercise.type} | ${exercise.bodyPart} | ${exercise.equipment}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                value: exercise,
                                groupValue: _selectedExercise,
                                onChanged: (Exercise? value) {
                                  setState(() {
                                    _selectedExercise = value;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                ),
                if (_selectedExercise != null)
                  Container(
                    color: Theme.of(context).cardColor,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedExercise!.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedExercise!.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _setsController,
                                decoration: InputDecoration(
                                  labelText: l10n.newWorkoutSetsLabel,
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _repsController,
                                decoration: InputDecoration(
                                  labelText: l10n.newWorkoutRepsLabel,
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _durationController,
                                decoration: InputDecoration(
                                  labelText: l10n.exerciseSelectionDurationLabel,
                                  hintText: l10n.exerciseSelectionOptionalHint,
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _restController,
                                decoration: InputDecoration(
                                  labelText: l10n.newWorkoutRestLabel,
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _addExercise,
                            child: Text(l10n.exerciseSelectionAddToWorkout),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

