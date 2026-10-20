import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../models/story_workout_data.dart';
import '../services/story_export_actions.dart';
import '../services/story_photo_service.dart';
import '../story_labels.dart';
import '../story_theme.dart';
import '../widgets/story_template_grid.dart';
import 'story_editor_screen.dart';

/// Where "Create story" starts: pick a layout, then edit it.
class StoryTemplateScreen extends StatelessWidget {
  const StoryTemplateScreen({
    super.key,
    required this.data,
    this.photoPicker,
    this.decodePhoto,
    this.exportActions,
  });

  final StoryWorkoutData data;
  final StoryPhotoPicker? photoPicker;
  final Future<ui.Image> Function(String path)? decodePhoto;
  final StoryExportActions Function()? exportActions;

  /// Opens the story flow for [data].
  static Future<void> open(BuildContext context, StoryWorkoutData data) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => StoryTemplateScreen(data: data)));

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: storyEditorTheme(),
      child: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          final scheme = Theme.of(context).colorScheme;
          return Scaffold(
            appBar: AppBar(title: Text(l10n.storyCreate)),
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.storyChooseLayout,
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.storyChooseLayoutHint,
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: StoryTemplateGrid(
                      data: data,
                      labels: StoryLabels(l10n),
                      onSelected:
                          (id) => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => StoryEditorScreen(
                                    data: data,
                                    templateId: id,
                                    photoPicker: photoPicker,
                                    decodePhoto: decodePhoto,
                                    exportActions: exportActions,
                                  ),
                            ),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
