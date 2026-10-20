import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../models/story_document.dart';
import '../models/story_templates.dart';
import '../models/story_workout_data.dart';
import '../rendering/story_renderer.dart';
import '../story_labels.dart';
import 'story_painters.dart';

String storyTemplateName(AppLocalizations l10n, String id) => switch (id) {
  'full_bold' => l10n.storyTemplateBold,
  'full_center' => l10n.storyTemplateCentered,
  'full_minimal' => l10n.storyTemplateMinimal,
  'panel_bottom' => l10n.storyTemplatePanelBottom,
  'panel_top' => l10n.storyTemplatePanelTop,
  'card' => l10n.storyTemplateCard,
  _ => id,
};

String storyLayoutName(AppLocalizations l10n, StoryLayoutKind kind) => switch (kind) {
  StoryLayoutKind.fullPhoto => l10n.storyLayoutFullPhoto,
  StoryLayoutKind.photoPanel => l10n.storyLayoutPhotoPanel,
};

/// Every template drawn with the real workout (and the photo, once there is
/// one), through the same renderer as the editor.
class StoryTemplateGrid extends StatelessWidget {
  const StoryTemplateGrid({
    super.key,
    required this.data,
    required this.labels,
    required this.onSelected,
    this.photo,
    this.carry,
    this.selectedId,
    this.shrinkWrap = false,
  });

  final StoryWorkoutData data;
  final StoryLabels labels;
  final ui.Image? photo;
  final StoryDocument? carry;
  final String? selectedId;
  final ValueChanged<String> onSelected;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final renderer = StoryRenderer(
      StoryRenderContext(
        data: data,
        labels: labels,
        photo: photo,
        textDirection: Directionality.of(context),
      ),
    );
    final width = MediaQuery.sizeOf(context).width;
    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: width > 600 ? 4 : 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 12,
        childAspectRatio: 9 / 16 * 0.82,
      ),
      itemCount: StoryTemplates.all.length,
      itemBuilder: (context, i) {
        final t = StoryTemplates.all[i];
        final doc = StoryTemplates.build(t.id, data, labels, carry: carry);
        final selected = t.id == selectedId;
        return Semantics(
          button: true,
          selected: selected,
          label: '${storyTemplateName(l10n, t.id)}, ${storyLayoutName(l10n, t.layout)}',
          child: InkWell(
            key: ValueKey('story-template-${t.id}'),
            borderRadius: BorderRadius.circular(12),
            onTap: () => onSelected(t.id),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 9 / 16,
                      child: DecoratedBox(
                        position: DecorationPosition.foreground,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected ? scheme.primary : scheme.outlineVariant,
                            width: selected ? 2.5 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CustomPaint(painter: StoryPainter(renderer, doc)),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  storyTemplateName(l10n, t.id),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: selected ? scheme.primary : scheme.onSurface,
                  ),
                ),
                Text(
                  storyLayoutName(l10n, t.layout),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
