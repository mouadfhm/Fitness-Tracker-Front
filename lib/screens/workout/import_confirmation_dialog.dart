import 'package:flutter/material.dart';

class ImportConfirmationDialog extends StatelessWidget {
  final List<String> workoutNames;
  final List<String> unmatchedExerciseNames;

  const ImportConfirmationDialog({
    super.key,
    required this.workoutNames,
    required this.unmatchedExerciseNames,
  });

  static Future<bool> show(
    BuildContext context, {
    required List<String> workoutNames,
    required List<String> unmatchedExerciseNames,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ImportConfirmationDialog(
        workoutNames: workoutNames,
        unmatchedExerciseNames: unmatchedExerciseNames,
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Import workout program'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('The following workouts will be created:'),
            const SizedBox(height: 8),
            for (final name in workoutNames)
              Text('• $name', style: const TextStyle(fontWeight: FontWeight.bold)),
            if (unmatchedExerciseNames.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                "These exercises weren't found and will be skipped:",
                style: TextStyle(color: colorScheme.error),
              ),
              const SizedBox(height: 8),
              for (final name in unmatchedExerciseNames) Text('• $name'),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Import'),
        ),
      ],
    );
  }
}
