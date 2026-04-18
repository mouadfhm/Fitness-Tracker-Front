// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class NewWorkoutScreen extends StatefulWidget {
  const NewWorkoutScreen({super.key});

  @override
  _NewWorkoutScreenState createState() => _NewWorkoutScreenState();
}

class _NewWorkoutScreenState extends State<NewWorkoutScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<Map<String, dynamic>> _selectedExercises = [];
  List<Map<String, dynamic>> _gymExercises = [];

  bool _isLoading = false;
  bool _isLoadingExercises = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchGymExercises();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchGymExercises() async {
    setState(() {
      _isLoadingExercises = true;
      _errorMessage = null;
    });

    try {
      final List<dynamic> exercises = await _apiService.getGymExercises();
      setState(() {
        _gymExercises = exercises.map((exercise) {
          return {
            'id': exercise['id'],
            'name': exercise['name'],
            'description': exercise['description'],
            'body_part': exercise['body_part'],
            'equipment': exercise['equipment'],
            'level': exercise['level'],
            'type': exercise['type'],
          };
        }).toList();
        _isLoadingExercises = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load exercises: ${e.toString()}';
        _isLoadingExercises = false;
      });
    }
  }

  Future<void> _saveWorkout() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please add at least one exercise to your workout'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();

      final gymExercises = _selectedExercises.map((exercise) => {
        'gym_exercise_id': exercise['id'],
        'sets': exercise['sets'],
        'reps': exercise['reps'],
        'duration': exercise['duration'],
        'rest': exercise['rest'],
      }).toList();

      await _apiService.storeCustomWorkout(name, description, gymExercises);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _addExercise(Map<String, dynamic> exercise) {
    setState(() {
      _selectedExercises.add({
        ...exercise,
        'sets': 3,
        'reps': 12,
        'duration': null,
        'rest': 60,
      });
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _selectedExercises.removeAt(index);
    });
  }

  void _updateExerciseDetails(int index, String field, dynamic value) {
    setState(() {
      _selectedExercises[index][field] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Create New Workout',
          style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
        ),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isLoadingExercises)
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
            icon: Icon(Icons.refresh, color: colorScheme.primary),
            onPressed: _fetchGymExercises,
            tooltip: 'Refresh exercise list',
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState(colorScheme)
          : _errorMessage != null
          ? _buildErrorState(colorScheme)
          : _buildForm(theme, colorScheme),
      bottomNavigationBar: _buildBottomBar(colorScheme),
    );
  }

  Widget _buildForm(ThemeData theme, ColorScheme colorScheme) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicInfoSection(theme, colorScheme),
            const SizedBox(height: 24),
            _buildExercisesSection(theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Workout Details',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nameController,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            labelText: 'Workout Name',
            labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
            hintText: 'e.g., Upper Body Strength',
            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            prefixIcon: Icon(Icons.fitness_center, color: colorScheme.primary),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a workout name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            labelText: 'Description',
            labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
            hintText: 'Focus of this workout, target muscle groups, etc.',
            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            prefixIcon: Icon(Icons.description, color: colorScheme.primary),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a description';
            }
            return null;
          },
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildExercisesSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Exercises',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showExerciseSelector(context),
              icon: Icon(Icons.add, color: colorScheme.primary),
              label: Text('Add Exercise', style: TextStyle(color: colorScheme.primary)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Add exercises and configure sets, reps, and rest periods',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        _selectedExercises.isEmpty
            ? _buildEmptyExercisesState(theme, colorScheme)
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _selectedExercises.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final exercise = _selectedExercises[index];
                  return _buildExerciseCard(theme, colorScheme, exercise, index);
                },
              ),
      ],
    );
  }

  Widget _buildEmptyExercisesState(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(
              Icons.fitness_center_outlined,
              size: 64,
              color: colorScheme.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No exercises added yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Add exercises to create your custom workout',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(
    ThemeData theme,
    ColorScheme colorScheme,
    Map<String, dynamic> exercise,
    int index,
  ) {
    return Card(
      elevation: 2,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise['name'],
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${exercise['body_part']} • ${exercise['level']}',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: colorScheme.error),
                  onPressed: () => _removeExercise(index),
                  tooltip: 'Remove exercise',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sets',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildDropdown(
                        colorScheme,
                        value: exercise['sets'],
                        items: List.generate(10, (i) => i + 1),
                        onChanged: (value) {
                          if (value != null) _updateExerciseDetails(index, 'sets', value);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reps',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildDropdown(
                        colorScheme,
                        value: exercise['reps'],
                        items: [8, 10, 12, 15, 20],
                        onChanged: (value) {
                          if (value != null) _updateExerciseDetails(index, 'reps', value);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rest (sec)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildDropdown(
                        colorScheme,
                        value: exercise['rest'],
                        items: [30, 45, 60, 90, 120],
                        onChanged: (value) {
                          if (value != null) _updateExerciseDetails(index, 'rest', value);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
    ColorScheme colorScheme, {
    required int value,
    required List<int> items,
    required Function(int?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
        color: colorScheme.surfaceContainerHighest,
      ),
      child: DropdownButtonFormField<int>(
        value: value,
        dropdownColor: colorScheme.surfaceContainerHighest,
        style: TextStyle(color: colorScheme.onSurface),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
        items: items
            .map((i) => DropdownMenuItem(value: i, child: Text('$i')))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  void _showExerciseSelector(BuildContext context) {
    String exerciseSearchTerm = "";
    final colorScheme = Theme.of(context).colorScheme;

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
            final filteredExercises = _gymExercises.where((exercise) =>
              exercise['name'].toLowerCase().contains(exerciseSearchTerm.toLowerCase()) ||
              exercise['body_part'].toLowerCase().contains(exerciseSearchTerm.toLowerCase()) ||
              exercise['equipment'].toLowerCase().contains(exerciseSearchTerm.toLowerCase()) ||
              exercise['level'].toLowerCase().contains(exerciseSearchTerm.toLowerCase()) ||
              exercise['type'].toLowerCase().contains(exerciseSearchTerm.toLowerCase()),
            ).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Select Exercises',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.close, color: colorScheme.onSurface),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Search exercises...',
                      hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                      prefixIcon: Icon(Icons.search, color: colorScheme.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.outlineVariant),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.outlineVariant),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.primary, width: 2),
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest,
                    ),
                    onChanged: (value) {
                      setModalState(() {
                        exerciseSearchTerm = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _isLoadingExercises
                        ? Center(
                            child: CircularProgressIndicator(
                              color: colorScheme.primary,
                            ),
                          )
                        : filteredExercises.isEmpty
                        ? Center(
                            child: Text(
                              'No exercises found',
                              style: TextStyle(color: colorScheme.primary),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filteredExercises.length,
                            separatorBuilder: (context, index) =>
                                Divider(color: colorScheme.outlineVariant),
                            itemBuilder: (context, index) {
                              final exercise = filteredExercises[index];
                              final bool isAlreadyAdded = _selectedExercises
                                  .any((e) => e['id'] == exercise['id']);

                              return ListTile(
                                title: Text(
                                  exercise['name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                subtitle: Text(
                                  '${exercise['body_part']} • ${exercise['equipment']} • ${exercise['level']}',
                                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                                ),
                                trailing: isAlreadyAdded
                                    ? const Icon(Icons.check_circle, color: Colors.green)
                                    : IconButton(
                                        icon: const Icon(Icons.add_circle_outline),
                                        color: colorScheme.primary,
                                        onPressed: () {
                                          _addExercise(exercise);
                                          Navigator.pop(context);
                                        },
                                      ),
                                onTap: () {
                                  if (!isAlreadyAdded) {
                                    _addExercise(exercise);
                                    Navigator.pop(context);
                                  }
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

  Widget _buildBottomBar(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
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
              child: Text('Cancel', style: TextStyle(color: colorScheme.primary)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton(
              onPressed: _saveWorkout,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: colorScheme.primary,
              ),
              child: const Text('Save Workout'),
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
            'Saving your workout...',
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
            'Error Creating Workout',
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
}
