import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

import 'models/story_document.dart';
import 'models/story_templates.dart';
import 'models/story_workout_data.dart';
import 'story_labels.dart';

enum StoryTool { photo, text, stats, style, layers }

/// Editor state for one story: the current [StoryDocument], its undo and
/// redo history, the selection and the photos loaded so far.
///
/// Every edit replaces the document. A gesture or slider drag shows its
/// in-between documents live ([beginGesture], [preview], [endGesture]) and
/// lands in the history as a single step. Only the story is changed here;
/// the workout it was made from is only read.
class StoryEditorController extends ChangeNotifier {
  StoryEditorController({
    required this.data,
    required this.labels,
    String templateId = StoryTemplates.defaultId,
  }) : _doc = StoryTemplates.build(templateId, data, labels);

  final StoryWorkoutData data;
  final StoryLabels labels;

  static const int historyLimit = 100;

  StoryDocument _doc;
  final List<StoryDocument> _undo = [];
  final List<StoryDocument> _redo = [];
  StoryDocument? _gestureStart;
  String? _selectedId;
  StoryTool _tool = StoryTool.photo;
  int _seq = 0;

  /// Decoded photos by path, kept so undoing a photo change shows the
  /// earlier photo again without decoding it twice.
  final Map<String, ui.Image> _photos = {};
  bool _disposed = false;

  StoryDocument get document => _doc;
  bool get canUndo => _undo.isNotEmpty;
  bool get canRedo => _redo.isNotEmpty;
  bool get isEdited => _undo.isNotEmpty;
  StoryTool get tool => _tool;
  String? get selectedId => _selectedId;
  StoryLayer? get selectedLayer => _doc.layer(_selectedId);
  ui.Image? get photo => _doc.photoPath == null ? null : _photos[_doc.photoPath];

  // ------------------------------------------------------------------ history

  /// Makes [next] the document, as one undoable step.
  void commit(StoryDocument next) {
    if (identical(next, _doc)) return;
    _endGestureSilently();
    _push(_doc);
    _doc = next;
    _keepSelectionValid();
    notifyListeners();
  }

  void _push(StoryDocument doc) {
    _undo.add(doc);
    if (_undo.length > historyLimit) _undo.removeAt(0);
    _redo.clear();
  }

  void beginGesture() => _gestureStart ??= _doc;

  /// Shows [next] while a gesture runs, without a history step.
  void preview(StoryDocument next) {
    _gestureStart ??= _doc;
    _doc = next;
    notifyListeners();
  }

  void endGesture() {
    if (_endGestureSilently()) notifyListeners();
  }

  bool _endGestureSilently() {
    final start = _gestureStart;
    _gestureStart = null;
    if (start == null || identical(start, _doc)) return false;
    _push(start);
    return true;
  }

  void undo() {
    _endGestureSilently();
    if (_undo.isEmpty) return;
    _redo.add(_doc);
    _doc = _undo.removeLast();
    _keepSelectionValid();
    notifyListeners();
  }

  void redo() {
    _endGestureSilently();
    if (_redo.isEmpty) return;
    _undo.add(_doc);
    _doc = _redo.removeLast();
    _keepSelectionValid();
    notifyListeners();
  }

  /// Back to the current template as it first was. The photo stays, centred.
  void resetDesign() {
    _selectedId = null;
    commit(StoryTemplates.build(_doc.templateId, data, labels).copyWith(photoPath: _doc.photoPath));
  }

  /// Switches layout, keeping the user's choices ([StoryTemplates.build]).
  void applyTemplate(String templateId) {
    if (templateId == _doc.templateId) return;
    commit(StoryTemplates.build(templateId, data, labels, carry: _doc));
  }

  // ---------------------------------------------------------------- selection

  void setTool(StoryTool tool) {
    if (_tool == tool) return;
    _tool = tool;
    // The photo tool moves the photo only, so nothing stays selected.
    if (tool == StoryTool.photo) _selectedId = null;
    if (tool == StoryTool.stats) {
      final stats = _doc.layers.where((l) => l.type == StoryLayerType.stats);
      if (stats.isNotEmpty && selectedLayer?.type != StoryLayerType.stats) {
        _selectedId = stats.last.id;
      }
    }
    notifyListeners();
  }

  void select(String? id) {
    if (_selectedId == id) return;
    _selectedId = _doc.layer(id) == null ? null : id;
    if (_selectedId != null && _tool == StoryTool.photo) {
      _tool = selectedLayer!.type == StoryLayerType.stats ? StoryTool.stats : StoryTool.text;
    }
    notifyListeners();
  }

  void _keepSelectionValid() {
    if (_doc.layer(_selectedId) == null) _selectedId = null;
  }

  // ------------------------------------------------------------------- layers

  String _newId(String prefix) => '${prefix}_${DateTime.now().microsecondsSinceEpoch}_${_seq++}';

  void updateLayer(String id, StoryLayer Function(StoryLayer) change, {bool live = false}) {
    final layer = _doc.layer(id);
    if (layer == null) return;
    final next = _doc.replaceLayer(change(layer));
    live ? preview(next) : commit(next);
  }

  void updateStyle(
    String id,
    StoryTextStyle Function(StoryTextStyle) change, {
    bool live = false,
  }) => updateLayer(id, (l) => l.copyWith(style: change(l.style)), live: live);

  /// Adds a text layer in the middle of the story, selected, below the
  /// branding.
  StoryLayer addText(String text, {StoryTextStyle? style, double cy = 0.5}) {
    final layer = StoryLayer(
      id: _newId('text'),
      type: StoryLayerType.text,
      cx: 0.5,
      cy: cy,
      width: 0.8,
      text: text,
      style:
          style ??
          const StoryTextStyle(fontSize: 72, weight: 700, align: StoryAlign.center, shadow: true),
    );
    final layers = [..._doc.layers];
    final brand = layers.indexWhere((l) => l.type == StoryLayerType.brand);
    layers.insert(brand == -1 ? layers.length : brand, layer);
    _selectedId = layer.id;
    commit(_doc.copyWith(layers: layers));
    return layer;
  }

  /// Adds the workout's exercises (with planned sets and reps) as a text
  /// layer, or null when the workout lists none.
  StoryLayer? addExerciseHighlights() {
    if (data.exercises.isEmpty) return null;
    return addText(
      labels.exerciseLines(data),
      cy: 0.32,
      style: const StoryTextStyle(
        font: StoryFont.body,
        fontSize: 40,
        weight: 500,
        lineHeight: 1.35,
        shadow: true,
      ),
    );
  }

  bool get hasStatsLayer => _doc.layers.any((l) => l.type == StoryLayerType.stats);

  /// Puts a stats block back after it was deleted.
  StoryLayer? addStatsLayer() {
    if (data.availableStats.isEmpty) return null;
    final layer = StoryLayer(
      id: _newId('stats'),
      type: StoryLayerType.stats,
      cx: 0.5,
      cy: 0.85,
      width: 0.86,
      style: const StoryTextStyle(fontSize: 88, weight: 900, color: StoryColorRole.accent),
    );
    final layers = [..._doc.layers];
    final brand = layers.indexWhere((l) => l.type == StoryLayerType.brand);
    layers.insert(brand == -1 ? layers.length : brand, layer);
    _selectedId = layer.id;
    commit(_doc.copyWith(layers: layers));
    return layer;
  }

  StoryLayer? duplicate(String id) {
    final layer = _doc.layer(id);
    if (layer == null || layer.type == StoryLayerType.brand) return null;
    final copy = layer.copyWith(id: _newId(layer.type.name), locked: false).movedBy(0.03, 0.03);
    final layers = [..._doc.layers];
    layers.insert(layers.indexWhere((l) => l.id == id) + 1, copy);
    _selectedId = copy.id;
    commit(_doc.copyWith(layers: layers));
    return copy;
  }

  void delete(String id) {
    final layer = _doc.layer(id);
    // Branding is turned off, not deleted (see [setBranding]).
    if (layer == null || layer.type == StoryLayerType.brand) return;
    if (_selectedId == id) _selectedId = null;
    commit(
      _doc.copyWith(
        layers: [
          for (final l in _doc.layers)
            if (l.id != id) l,
        ],
      ),
    );
  }

  /// Moves a layer from z-position [from] to [to] (0 is the back).
  void reorderLayer(int from, int to) {
    final layers = [..._doc.layers];
    if (from < 0 || from >= layers.length) return;
    to = to.clamp(0, layers.length - 1);
    if (from == to) return;
    layers.insert(to, layers.removeAt(from));
    commit(_doc.copyWith(layers: layers));
  }

  void bringForward(String id) {
    final i = _doc.layers.indexWhere((l) => l.id == id);
    if (i != -1) reorderLayer(i, i + 1);
  }

  void sendBackward(String id) {
    final i = _doc.layers.indexWhere((l) => l.id == id);
    if (i != -1) reorderLayer(i, i - 1);
  }

  void toggleLock(String id) => updateLayer(id, (l) => l.copyWith(locked: !l.locked));

  void toggleVisible(String id) => updateLayer(id, (l) => l.copyWith(visible: !l.visible));

  // -------------------------------------------------------------------- stats

  void setStatVisible(StoryStatKind kind, bool visible) => commit(
    _doc.copyWith(
      stats: [
        for (final s in _doc.stats) s.kind == kind ? StoryStatSetting(kind, visible: visible) : s,
      ],
    ),
  );

  /// Moves a stat from [from] to [to] in the shown order.
  void reorderStat(int from, int to) {
    final stats = [..._doc.stats];
    if (from < 0 || from >= stats.length) return;
    to = to.clamp(0, stats.length - 1);
    if (from == to) return;
    stats.insert(to, stats.removeAt(from));
    commit(_doc.copyWith(stats: stats));
  }

  // -------------------------------------------------------------------- style

  void setPalette(String id) {
    if (id != _doc.paletteId) commit(_doc.copyWith(paletteId: id));
  }

  void setBranding(bool on) {
    if (on != _doc.branding) commit(_doc.copyWith(branding: on));
  }

  void setDim(double v, {bool live = false}) =>
      live ? preview(_doc.copyWith(dim: v)) : commit(_doc.copyWith(dim: v));

  void setGradient(double v, {bool live = false}) =>
      live ? preview(_doc.copyWith(gradient: v)) : commit(_doc.copyWith(gradient: v));

  // -------------------------------------------------------------------- photo

  /// Uses [image], decoded from [path], as the story photo, centred.
  void setPhoto(String path, ui.Image image) {
    if (_disposed) {
      image.dispose();
      return;
    }
    final old = _photos[path];
    if (old != null && !identical(old, image)) old.dispose();
    _photos[path] = image;
    commit(_doc.copyWith(photoPath: path, photoTransform: PhotoTransform.identity));
  }

  void setPhotoTransform(PhotoTransform t, {bool live = false}) {
    final image = photo;
    final frame = _doc.photoFrameIn(kStoryWidth, kStoryHeight);
    final clamped =
        image == null ? t : t.clamped(image.width.toDouble(), image.height.toDouble(), frame);
    final next = _doc.copyWith(photoTransform: clamped);
    live ? preview(next) : commit(next);
  }

  void resetPhotoTransform() {
    if (!_doc.photoTransform.isIdentity) {
      commit(_doc.copyWith(photoTransform: PhotoTransform.identity));
    }
  }

  /// Paths of every photo picked in this editor, for cleanup.
  Iterable<String> get photoPaths => _photos.keys;

  @override
  void dispose() {
    _disposed = true;
    for (final image in _photos.values) {
      image.dispose();
    }
    _photos.clear();
    super.dispose();
  }
}
