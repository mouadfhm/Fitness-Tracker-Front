import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../models/story_document.dart';
import '../models/story_palette.dart';
import '../story_editor_controller.dart';
import '../story_labels.dart';

/// Callbacks the panels need from the editor screen (pickers and sheets).
class StoryPanelActions {
  const StoryPanelActions({
    required this.pickPhoto,
    required this.editText,
    required this.chooseTemplate,
    required this.resetDesign,
  });

  final void Function(bool camera) pickPhoto;
  final void Function(StoryLayer layer) editText;
  final VoidCallback chooseTemplate;
  final VoidCallback resetDesign;
}

/// The controls above the toolbar for the active tool.
class StoryToolPanel extends StatelessWidget {
  const StoryToolPanel({
    super.key,
    required this.controller,
    required this.labels,
    required this.actions,
    this.photoBusy = false,
  });

  final StoryEditorController controller;
  final StoryLabels labels;
  final StoryPanelActions actions;
  final bool photoBusy;

  @override
  Widget build(BuildContext context) {
    final maxHeight = (MediaQuery.sizeOf(context).height * 0.34).clamp(150.0, 300.0);
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final child = switch (controller.tool) {
          StoryTool.photo => _PhotoPanel(controller, actions, photoBusy),
          StoryTool.text => _TextPanel(controller, actions),
          StoryTool.stats => _StatsPanel(controller, labels, actions),
          StoryTool.style => _StylePanel(controller, actions),
          StoryTool.layers => _LayersPanel(controller, labels, actions),
        };
        return AnimatedSize(
          duration: const Duration(milliseconds: 160),
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

// --------------------------------------------------------------------- shared

/// A slider that lands in the undo history once per drag.
class _UndoSlider extends StatelessWidget {
  const _UndoSlider({
    required this.controller,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.display,
  });

  final StoryEditorController controller;
  final String label;
  final double value;
  final double min;
  final double max;
  final void Function(double v) onChanged;
  final String? display;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        SizedBox(
          width: 92,
          child: Text(label, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13)),
        ),
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            label: display,
            onChangeStart: (_) => controller.beginGesture(),
            onChanged: onChanged,
            onChangeEnd: (_) => controller.endGesture(),
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            display ?? '',
            textAlign: TextAlign.end,
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _ColorDots extends StatelessWidget {
  const _ColorDots({required this.palette, required this.value, required this.onChanged});

  final StoryPalette palette;
  final StoryColorRole value;
  final ValueChanged<StoryColorRole> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    String name(StoryColorRole r) => switch (r) {
      StoryColorRole.white => l10n.storyColorWhite,
      StoryColorRole.gray => l10n.storyColorGray,
      StoryColorRole.accent => l10n.storyColorAccent,
      StoryColorRole.dark => l10n.storyColorDark,
    };
    return Wrap(
      spacing: 4,
      children: [
        for (final role in StoryColorRole.values)
          _Dot(
            color: palette.resolve(role),
            selected: role == value,
            tooltip: name(role),
            onTap: () => onChanged(role),
          ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({
    required this.color,
    required this.selected,
    required this.tooltip,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        selected: selected,
        label: tooltip,
        child: InkResponse(
          onTap: onTap,
          radius: 24,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? scheme.onSurface : scheme.outline,
                    width: selected ? 3 : 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Duplicate, order, lock and delete for the selected layer.
class _LayerActions extends StatelessWidget {
  const _LayerActions(this.controller, this.actions, this.layer);

  final StoryEditorController controller;
  final StoryPanelActions actions;
  final StoryLayer layer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final layers = controller.document.layers;
    final z = layers.indexOf(layer);
    final isBrand = layer.type == StoryLayerType.brand;
    return Wrap(
      spacing: 0,
      children: [
        if (layer.isEditableText)
          IconButton(
            tooltip: l10n.storyEditText,
            icon: const Icon(Icons.edit_outlined),
            onPressed: layer.locked ? null : () => actions.editText(layer),
          ),
        if (!isBrand)
          IconButton(
            tooltip: l10n.storyDuplicate,
            icon: const Icon(Icons.copy_outlined),
            onPressed: () => controller.duplicate(layer.id),
          ),
        IconButton(
          tooltip: l10n.storyBringForward,
          icon: const Icon(Icons.flip_to_front_outlined),
          onPressed: z < layers.length - 1 ? () => controller.bringForward(layer.id) : null,
        ),
        IconButton(
          tooltip: l10n.storySendBackward,
          icon: const Icon(Icons.flip_to_back_outlined),
          onPressed: z > 0 ? () => controller.sendBackward(layer.id) : null,
        ),
        IconButton(
          tooltip: layer.locked ? l10n.storyUnlock : l10n.storyLock,
          icon: Icon(layer.locked ? Icons.lock_outline : Icons.lock_open_outlined),
          onPressed: () => controller.toggleLock(layer.id),
        ),
        if (!isBrand)
          IconButton(
            tooltip: l10n.storyDelete,
            icon: const Icon(Icons.delete_outline),
            onPressed: () => controller.delete(layer.id),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------- photo

class _PhotoPanel extends StatelessWidget {
  const _PhotoPanel(this.controller, this.actions, this.busy);

  final StoryEditorController controller;
  final StoryPanelActions actions;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final doc = controller.document;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: [
            FilledButton.tonalIcon(
              onPressed: busy ? null : () => actions.pickPhoto(false),
              icon:
                  busy
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.photo_library_outlined),
              label: Text(controller.photo == null ? l10n.storyGallery : l10n.storyReplacePhoto),
            ),
            FilledButton.tonalIcon(
              onPressed: busy ? null : () => actions.pickPhoto(true),
              icon: const Icon(Icons.photo_camera_outlined),
              label: Text(l10n.storyCamera),
            ),
            TextButton.icon(
              onPressed:
                  controller.photo != null && !doc.photoTransform.isIdentity
                      ? controller.resetPhotoTransform
                      : null,
              icon: const Icon(Icons.center_focus_strong_outlined),
              label: Text(l10n.storyResetPhoto),
            ),
          ],
        ),
        _UndoSlider(
          controller: controller,
          label: l10n.storyDim,
          value: doc.dim,
          min: 0,
          max: 1,
          display: '${(doc.dim * 100).round()}%',
          onChanged: (v) => controller.setDim(v, live: true),
        ),
        _UndoSlider(
          controller: controller,
          label: l10n.storyGradient,
          value: doc.gradient,
          min: 0,
          max: 1,
          display: '${(doc.gradient * 100).round()}%',
          onChanged: (v) => controller.setGradient(v, live: true),
        ),
      ],
    );
  }
}

// ----------------------------------------------------------------------- text

class _TextPanel extends StatelessWidget {
  const _TextPanel(this.controller, this.actions);

  final StoryEditorController controller;
  final StoryPanelActions actions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final layer = controller.selectedLayer;
    final palette = StoryPalette.byId(controller.document.paletteId);

    final add = Wrap(
      spacing: 8,
      alignment: WrapAlignment.center,
      children: [
        ActionChip(
          avatar: const Icon(Icons.text_fields, size: 18),
          label: Text(l10n.storyAddText),
          onPressed: () => actions.editText(controller.addText(l10n.storyNewText)),
        ),
        if (controller.data.exercises.isNotEmpty)
          ActionChip(
            avatar: const Icon(Icons.format_list_bulleted, size: 18),
            label: Text(l10n.storyAddExercises),
            onPressed: controller.addExerciseHighlights,
          ),
      ],
    );

    if (layer == null || layer.type == StoryLayerType.stats) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          add,
          const SizedBox(height: 8),
          Text(
            l10n.storyTextHint,
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
          ),
        ],
      );
    }

    final s = layer.style;
    void style(StoryTextStyle Function(StoryTextStyle) f, {bool live = false}) =>
        controller.updateStyle(layer.id, f, live: live);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LayerActions(controller, actions, layer),
        if (!layer.locked) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SegmentedButton<StoryFont>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(value: StoryFont.display, label: Text(l10n.storyFontDisplay)),
                  ButtonSegment(value: StoryFont.body, label: Text(l10n.storyFontBody)),
                ],
                selected: {s.font},
                onSelectionChanged: (v) => style((t) => t.copyWith(font: v.first)),
              ),
              SegmentedButton<StoryAlign>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: StoryAlign.start,
                    icon: const Icon(Icons.format_align_left),
                    tooltip: l10n.storyAlignStart,
                  ),
                  ButtonSegment(
                    value: StoryAlign.center,
                    icon: const Icon(Icons.format_align_center),
                    tooltip: l10n.storyAlignCenter,
                  ),
                  ButtonSegment(
                    value: StoryAlign.end,
                    icon: const Icon(Icons.format_align_right),
                    tooltip: l10n.storyAlignEnd,
                  ),
                ],
                selected: {s.align},
                onSelectionChanged: (v) => style((t) => t.copyWith(align: v.first)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SegmentedButton<int>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: 400, label: Text(l10n.storyWeightRegular)),
              ButtonSegment(value: 500, label: Text(l10n.storyWeightMedium)),
              ButtonSegment(value: 700, label: Text(l10n.storyWeightBold)),
              ButtonSegment(value: 900, label: Text(l10n.storyWeightBlack)),
            ],
            selected: {s.weight},
            onSelectionChanged: (v) => style((t) => t.copyWith(weight: v.first)),
          ),
          _UndoSlider(
            controller: controller,
            label: l10n.storySize,
            value: s.fontSize,
            min: 20,
            max: layer.type == StoryLayerType.brand ? 60 : 220,
            display: s.fontSize.round().toString(),
            onChanged: (v) => style((t) => t.copyWith(fontSize: v), live: true),
          ),
          _UndoSlider(
            controller: controller,
            label: l10n.storySpacing,
            value: s.letterSpacing,
            min: -4,
            max: 20,
            display: s.letterSpacing.toStringAsFixed(0),
            onChanged: (v) => style((t) => t.copyWith(letterSpacing: v), live: true),
          ),
          Row(
            children: [
              Expanded(
                child: _ColorDots(
                  palette: palette,
                  value: s.color,
                  onChanged: (r) => style((t) => t.copyWith(color: r)),
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: Text(l10n.storyUppercase),
                selected: s.uppercase,
                onSelected: (v) => style((t) => t.copyWith(uppercase: v)),
              ),
              FilterChip(
                label: Text(l10n.storyShadow),
                selected: s.shadow,
                onSelected: (v) => style((t) => t.copyWith(shadow: v)),
              ),
            ],
          ),
        ],
        const Divider(height: 20),
        add,
      ],
    );
  }
}

// ---------------------------------------------------------------------- stats

class _StatsPanel extends StatelessWidget {
  const _StatsPanel(this.controller, this.labels, this.actions);

  final StoryEditorController controller;
  final StoryLabels labels;
  final StoryPanelActions actions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final doc = controller.document;
    final data = controller.data;
    if (doc.stats.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          l10n.storyStatsNone,
          textAlign: TextAlign.center,
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
      );
    }
    final layer =
        controller.selectedLayer?.type == StoryLayerType.stats ? controller.selectedLayer : null;
    final palette = StoryPalette.byId(doc.paletteId);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          data.isPlanned ? l10n.storyStatsHintPlanned : l10n.storyStatsHint,
          style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
        ),
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          onReorderItem: controller.reorderStat,
          children: [
            for (var i = 0; i < doc.stats.length; i++) _statTile(context, i, doc.stats[i]),
          ],
        ),
        if (!controller.hasStatsLayer)
          Center(
            child: ActionChip(
              avatar: const Icon(Icons.add, size: 18),
              label: Text(l10n.storyAddStats),
              onPressed: controller.addStatsLayer,
            ),
          ),
        if (layer != null) ...[
          const Divider(height: 16),
          _LayerActions(controller, actions, layer),
          if (!layer.locked) ...[
            _UndoSlider(
              controller: controller,
              label: l10n.storySize,
              value: layer.style.fontSize,
              min: 40,
              max: 160,
              display: layer.style.fontSize.round().toString(),
              onChanged:
                  (v) =>
                      controller.updateStyle(layer.id, (t) => t.copyWith(fontSize: v), live: true),
            ),
            Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SegmentedButton<StoryAlign>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: StoryAlign.start,
                      icon: const Icon(Icons.format_align_left),
                      tooltip: l10n.storyAlignStart,
                    ),
                    ButtonSegment(
                      value: StoryAlign.center,
                      icon: const Icon(Icons.format_align_center),
                      tooltip: l10n.storyAlignCenter,
                    ),
                    ButtonSegment(
                      value: StoryAlign.end,
                      icon: const Icon(Icons.format_align_right),
                      tooltip: l10n.storyAlignEnd,
                    ),
                  ],
                  selected: {layer.style.align},
                  onSelectionChanged:
                      (v) => controller.updateStyle(layer.id, (t) => t.copyWith(align: v.first)),
                ),
                _ColorDots(
                  palette: palette,
                  value: layer.style.color,
                  onChanged: (r) => controller.updateStyle(layer.id, (t) => t.copyWith(color: r)),
                ),
              ],
            ),
          ],
        ],
      ],
    );
  }

  Widget _statTile(BuildContext context, int index, StoryStatSetting s) {
    final l10n = AppLocalizations.of(context)!;
    final data = controller.data;
    final label = labels.statLabel(s.kind, estimate: data.isEstimate(s.kind));
    final value = labels.statValue(data, s.kind) ?? '';
    return ListTile(
      key: ValueKey('story-stat-${s.kind.name}'),
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: ReorderableDragStartListener(
        index: index,
        child: const SizedBox(width: 44, height: 44, child: Icon(Icons.drag_handle)),
      ),
      title: Text(label),
      subtitle: Text(data.isEstimate(s.kind) ? '$value · ${l10n.storyEstimate}' : value),
      trailing: Switch(value: s.visible, onChanged: (v) => controller.setStatVisible(s.kind, v)),
    );
  }
}

// ---------------------------------------------------------------------- style

class _StylePanel extends StatelessWidget {
  const _StylePanel(this.controller, this.actions);

  final StoryEditorController controller;
  final StoryPanelActions actions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final doc = controller.document;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.storyAccent, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13)),
        Wrap(
          children: [
            for (final p in StoryPalette.all)
              _Dot(
                color: p.accent,
                selected: p.id == doc.paletteId,
                tooltip: p.id,
                onTap: () => controller.setPalette(p.id),
              ),
          ],
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.storyBranding),
          value: doc.branding,
          onChanged: controller.setBranding,
        ),
        Wrap(
          spacing: 8,
          alignment: WrapAlignment.center,
          children: [
            FilledButton.tonalIcon(
              onPressed: actions.chooseTemplate,
              icon: const Icon(Icons.dashboard_customize_outlined),
              label: Text(l10n.storyChangeLayout),
            ),
            TextButton.icon(
              onPressed: actions.resetDesign,
              icon: const Icon(Icons.restart_alt),
              label: Text(l10n.storyResetDesign),
            ),
          ],
        ),
      ],
    );
  }
}

// --------------------------------------------------------------------- layers

class _LayersPanel extends StatelessWidget {
  const _LayersPanel(this.controller, this.labels, this.actions);

  final StoryEditorController controller;
  final StoryLabels labels;
  final StoryPanelActions actions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final layers = controller.document.layers;
    final n = layers.length;
    final selected = controller.selectedLayer;

    String title(StoryLayer l) => switch (l.type) {
      StoryLayerType.stats => l10n.storyLayerStats,
      StoryLayerType.brand => l10n.storyLayerBrand,
      StoryLayerType.text =>
        l.text.trim().isEmpty ? l10n.storyLayerEmpty : l.text.trim().split('\n').first,
    };
    IconData icon(StoryLayer l) => switch (l.type) {
      StoryLayerType.stats => Icons.bar_chart,
      StoryLayerType.brand => Icons.verified_outlined,
      StoryLayerType.text => Icons.text_fields,
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (selected != null) _LayerActions(controller, actions, selected),
        // Front-most first, like most editors; the document stores back first.
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          onReorderItem: (from, to) => controller.reorderLayer(n - 1 - from, n - 1 - to),
          children: [
            for (var i = 0; i < n; i++)
              Builder(
                key: ValueKey('story-layer-${layers[n - 1 - i].id}'),
                builder: (context) {
                  final l = layers[n - 1 - i];
                  final isSelected = l.id == selected?.id;
                  final hiddenByBranding =
                      l.type == StoryLayerType.brand && !controller.document.branding;
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    selected: isSelected,
                    selectedColor: scheme.primary,
                    leading: ReorderableDragStartListener(
                      index: i,
                      child: SizedBox(width: 44, height: 44, child: Icon(icon(l))),
                    ),
                    title: Text(
                      title(l),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: (l.visible && !hiddenByBranding) ? null : scheme.onSurfaceVariant,
                      ),
                    ),
                    onTap: () => controller.select(l.id),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: l.visible ? l10n.storyHide : l10n.storyShow,
                          icon: Icon(
                            l.visible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => controller.toggleVisible(l.id),
                        ),
                        IconButton(
                          tooltip: l.locked ? l10n.storyUnlock : l10n.storyLock,
                          icon: Icon(l.locked ? Icons.lock_outline : Icons.lock_open_outlined),
                          onPressed: () => controller.toggleLock(l.id),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ],
    );
  }
}

/// The tool switcher under the panel.
class StoryToolbar extends StatelessWidget {
  const StoryToolbar({super.key, required this.controller});

  final StoryEditorController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListenableBuilder(
      listenable: controller,
      builder:
          (context, _) => NavigationBar(
            height: 64,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            selectedIndex: controller.tool.index,
            onDestinationSelected: (i) => controller.setTool(StoryTool.values[i]),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.photo_outlined),
                label: l10n.storyToolPhoto,
              ),
              NavigationDestination(icon: const Icon(Icons.title), label: l10n.storyToolText),
              NavigationDestination(
                icon: const Icon(Icons.bar_chart_outlined),
                label: l10n.storyToolStats,
              ),
              NavigationDestination(
                icon: const Icon(Icons.palette_outlined),
                label: l10n.storyToolStyle,
              ),
              NavigationDestination(
                icon: const Icon(Icons.layers_outlined),
                label: l10n.storyToolLayers,
              ),
            ],
          ),
    );
  }
}
