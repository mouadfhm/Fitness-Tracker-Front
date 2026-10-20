import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../utils/adaptive.dart';
import '../../utils/friendly_error.dart';
import '../models/story_document.dart';
import '../models/story_templates.dart';
import '../models/story_workout_data.dart';
import '../rendering/story_exporter.dart';
import '../rendering/story_renderer.dart';
import '../services/story_export_actions.dart';
import '../services/story_photo_service.dart';
import '../story_editor_controller.dart';
import '../story_labels.dart';
import '../story_theme.dart';
import '../widgets/story_canvas.dart';
import '../widgets/story_template_grid.dart';
import '../widgets/story_tool_panels.dart';
import 'story_export_screen.dart';

String storyPhotoErrorMessage(AppLocalizations l10n, StoryPhotoError error) => switch (error) {
  StoryPhotoError.galleryDenied => l10n.storyPhotoDenied,
  StoryPhotoError.cameraDenied => l10n.storyCameraDenied,
  StoryPhotoError.unreadable => l10n.storyPhotoFailed,
};

/// The story editor: a live 9:16 canvas over a panel for the active tool
/// and a five-tool bar (photo, text, stats, style, layers).
class StoryEditorScreen extends StatefulWidget {
  const StoryEditorScreen({
    super.key,
    required this.data,
    this.templateId = StoryTemplates.defaultId,
    this.photoPicker,
    this.decodePhoto,
    this.exportActions,
  });

  final StoryWorkoutData data;
  final String templateId;

  /// Replaceable for tests; default the device gallery and camera.
  final StoryPhotoPicker? photoPicker;
  final Future<ui.Image> Function(String path)? decodePhoto;
  final StoryExportActions Function()? exportActions;

  @override
  State<StoryEditorScreen> createState() => _StoryEditorScreenState();
}

class _StoryEditorScreenState extends State<StoryEditorScreen> {
  StoryEditorController? _controller;
  StoryLabels? _labels;
  late final StoryPhotoPicker _picker = widget.photoPicker ?? DeviceStoryPhotoPicker();
  StoryRenderer? _renderer;
  bool _preview = false;
  bool _photoBusy = false;
  bool _exporting = false;

  StoryEditorController get _c => _controller!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller == null) {
      // The words drawn on the story are fixed when it is created, in the
      // app's language at that moment.
      _labels = StoryLabels(AppLocalizations.of(context)!);
      _controller = StoryEditorController(
        data: widget.data,
        labels: _labels!,
        templateId: widget.templateId,
      );
    }
  }

  @override
  void dispose() {
    final paths = _c.photoPaths.toList();
    _c.dispose();
    _picker.discard(paths);
    super.dispose();
  }

  StoryRenderContext _renderContext() => StoryRenderContext(
    data: widget.data,
    labels: _labels!,
    photo: _c.photo,
    textDirection: Directionality.of(context),
  );

  /// One renderer per photo, so its layout cache survives edits.
  StoryRenderer _rendererNow() {
    final r = _renderer;
    if (r != null &&
        identical(r.context.photo, _c.photo) &&
        r.context.textDirection == Directionality.of(context)) {
      return r;
    }
    return _renderer = StoryRenderer(_renderContext());
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // ------------------------------------------------------------------ actions

  Future<void> _pickPhoto(bool camera) async {
    if (_photoBusy) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _photoBusy = true);
    try {
      final path = await _picker.pick(camera ? StoryPhotoSource.camera : StoryPhotoSource.gallery);
      if (path == null || !mounted) return; // cancelled
      final image = await (widget.decodePhoto ?? decodeStoryPhotoFile)(path);
      if (!mounted) {
        image.dispose();
        return;
      }
      _c.setPhoto(path, image);
    } on StoryPhotoException catch (e) {
      if (mounted) _snack(storyPhotoErrorMessage(l10n, e.error));
    } catch (e) {
      if (mounted) _snack(l10n.storyPhotoFailed);
    } finally {
      if (mounted) setState(() => _photoBusy = false);
    }
  }

  Future<void> _choosePhotoSource() async {
    final l10n = AppLocalizations.of(context)!;
    final camera = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: Text(l10n.storyGallery),
                  onTap: () => Navigator.pop(context, false),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: Text(l10n.storyCamera),
                  onTap: () => Navigator.pop(context, true),
                ),
              ],
            ),
          ),
    );
    if (camera != null) await _pickPhoto(camera);
  }

  Future<void> _editText(StoryLayer layer) async {
    final l10n = AppLocalizations.of(context)!;
    final text = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _TextEditSheet(initial: layer.text),
    );
    if (text == null || !mounted) return;
    if (_c.document.layer(layer.id) == null) return;
    _c.updateLayer(layer.id, (l) => l.copyWith(text: text));
    if (text.trim().isEmpty) _snack(l10n.storyLayerEmpty);
  }

  Future<void> _chooseTemplate() async {
    final id = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder:
          (context) => SafeArea(
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.6,
              child: StoryTemplateGrid(
                data: widget.data,
                labels: _labels!,
                photo: _c.photo,
                carry: _c.document,
                selectedId: _c.document.templateId,
                onSelected: (id) => Navigator.pop(context, id),
              ),
            ),
          ),
    );
    if (id != null) _c.applyTemplate(id);
  }

  Future<void> _confirmReset() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog.adaptive(
            title: Text(l10n.storyResetConfirmTitle),
            content: Text(l10n.storyResetConfirmBody),
            actions: [
              AdaptiveDialogAction(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              AdaptiveDialogAction(
                isDestructive: true,
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.storyReset),
              ),
            ],
          ),
    );
    if (ok == true) _c.resetDesign();
  }

  Future<bool> _confirmDiscard() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog.adaptive(
            title: Text(l10n.storyDiscardTitle),
            content: Text(l10n.storyDiscardBody),
            actions: [
              AdaptiveDialogAction(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.storyKeepEditing),
              ),
              AdaptiveDialogAction(
                isDestructive: true,
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.storyDiscard),
              ),
            ],
          ),
    );
    return ok == true;
  }

  Future<void> _export() async {
    if (_exporting) return;
    final l10n = AppLocalizations.of(context)!;
    _c.endGesture();
    setState(() => _exporting = true);
    try {
      final png = await StoryExporter.renderPng(_c.document, _renderContext());
      if (!mounted) return;
      setState(() => _exporting = false);
      final done = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder:
              (_) => StoryExportScreen(
                png: png,
                actions: widget.exportActions?.call() ?? DeviceStoryExportActions(),
              ),
        ),
      );
      if (done == true && mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) _snack(l10n.storyExportFailed(friendlyError(e)));
    } finally {
      if (mounted && _exporting) setState(() => _exporting = false);
    }
  }

  // -------------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    return Theme(data: storyEditorTheme(), child: Builder(builder: _buildScaffold));
  }

  Widget _buildScaffold(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListenableBuilder(
      listenable: _c,
      builder: (context, _) {
        // A new renderer only when the photo changes.
        final renderer = _rendererNow();
        final canvas = StoryCanvas(
          controller: _c,
          renderer: renderer,
          onAddPhoto: _choosePhotoSource,
          onEditText: _editText,
        );
        return PopScope(
          canPop: !_c.isEdited && !_preview,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            if (_preview) {
              setState(() => _preview = false);
              return;
            }
            final navigator = Navigator.of(context);
            if (await _confirmDiscard() && mounted) navigator.pop();
          },
          child: Scaffold(
            appBar:
                _preview
                    ? null
                    : AppBar(
                      leading: IconButton(
                        tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.maybePop(context),
                      ),
                      actions: [
                        IconButton(
                          tooltip: l10n.storyUndo,
                          icon: const Icon(Icons.undo),
                          onPressed: _c.canUndo ? _c.undo : null,
                        ),
                        IconButton(
                          tooltip: l10n.storyRedo,
                          icon: const Icon(Icons.redo),
                          onPressed: _c.canRedo ? _c.redo : null,
                        ),
                        IconButton(
                          tooltip: l10n.storyPreview,
                          icon: const Icon(Icons.visibility_outlined),
                          onPressed: () => setState(() => _preview = true),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 12, start: 4),
                          child: FilledButton(
                            key: const ValueKey('story-next'),
                            onPressed: _exporting ? null : _export,
                            child:
                                _exporting
                                    ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                    : Text(l10n.storyNext),
                          ),
                        ),
                      ],
                    ),
            body: SafeArea(
              child:
                  _preview
                      ? GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(() => _preview = false),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: IgnorePointer(
                                child: StoryCanvas(
                                  controller: _c,
                                  renderer: renderer,
                                  previewMode: true,
                                ),
                              ),
                            ),
                            PositionedDirectional(
                              top: 8,
                              start: 8,
                              child: FilledButton.tonalIcon(
                                onPressed: () => setState(() => _preview = false),
                                icon: const Icon(Icons.edit_outlined),
                                label: Text(l10n.storyClosePreview),
                              ),
                            ),
                          ],
                        ),
                      )
                      : Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                              child: canvas,
                            ),
                          ),
                          StoryToolPanel(
                            controller: _c,
                            labels: _labels!,
                            photoBusy: _photoBusy,
                            actions: StoryPanelActions(
                              pickPhoto: _pickPhoto,
                              editText: _editText,
                              chooseTemplate: _chooseTemplate,
                              resetDesign: _confirmReset,
                            ),
                          ),
                          StoryToolbar(controller: _c),
                        ],
                      ),
            ),
          ),
        );
      },
    );
  }
}

class _TextEditSheet extends StatefulWidget {
  const _TextEditSheet({required this.initial});

  final String initial;

  @override
  State<_TextEditSheet> createState() => _TextEditSheetState();
}

class _TextEditSheetState extends State<_TextEditSheet> {
  late final _text = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.storyEditText, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey('story-text-field'),
            controller: _text,
            autofocus: true,
            minLines: 1,
            maxLines: 6,
            maxLength: 200,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
              const SizedBox(width: 8),
              FilledButton(
                key: const ValueKey('story-text-save'),
                onPressed: () => Navigator.pop(context, _text.text),
                child: Text(l10n.storyApply),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
