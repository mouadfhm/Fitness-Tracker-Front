import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/adaptive.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog.adaptive(
      title: Text(l10n.workoutListImportTooltip),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.importDialogWorkoutsToCreate),
            const SizedBox(height: 8),
            for (final name in workoutNames)
              Text('• $name', style: const TextStyle(fontWeight: FontWeight.bold)),
            if (unmatchedExerciseNames.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                l10n.importDialogUnmatchedExercises,
                style: TextStyle(color: colorScheme.error),
              ),
              const SizedBox(height: 8),
              for (final name in unmatchedExerciseNames) Text('• $name'),
            ],
          ],
        ),
      ),
      actions: [
        AdaptiveDialogAction(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        AdaptiveDialogAction(isDefault: true,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.importDialogImportButton),
        ),
      ],
    );
  }
}
