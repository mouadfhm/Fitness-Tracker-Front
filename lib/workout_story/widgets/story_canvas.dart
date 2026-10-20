import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../models/story_document.dart';
import '../rendering/story_renderer.dart';
import '../story_editor_controller.dart';
import 'story_painters.dart';

/// The live, editable story. Draws through [StoryRenderer] at the canvas's
/// on-screen scale, then adds the editor-only selection outline and handles.
///
/// Touches never do two things: with the photo tool, pinching and dragging
/// move only the photo; with any other tool, they move only the layer they
/// start on, so adjusting the photo can't knock text out of place.
class StoryCanvas extends StatefulWidget {
  const StoryCanvas({
    super.key,
    required this.controller,
    required this.renderer,
    this.previewMode = false,
    this.onAddPhoto,
    this.onEditText,
  });

  final StoryEditorController controller;
  final StoryRenderer renderer;
  final bool previewMode;
  final VoidCallback? onAddPhoto;
  final void Function(StoryLayer layer)? onEditText;

  @override
  State<StoryCanvas> createState() => _StoryCanvasState();
}

enum _Drag { none, photo, layer }

class _StoryCanvasState extends State<StoryCanvas> {
  static const double _handleSize = 44;

  final _canvasKey = GlobalKey();
  double _scale = 1; // widget pixels per canvas pixel

  _Drag _drag = _Drag.none;
  Offset? _downAt; // canvas pixels, where the first finger landed
  int _pointers = 0;
  Offset _focal0 = Offset.zero;
  StoryLayer? _layer0;
  PhotoTransform _photo0 = PhotoTransform.identity;

  // A handle drag in progress: the layer as it was, and the start point
  // (from the layer's centre for the rotate handle).
  StoryLayer? _handleLayer0;
  Offset? _handleStart;

  StoryEditorController get _c => widget.controller;

  Offset _toCanvas(Offset local) => local / _scale;

  // ------------------------------------------------------------ canvas gestures

  void _onPointerDown(PointerDownEvent e) {
    if (_pointers++ == 0) _downAt = _toCanvas(e.localPosition);
  }

  void _onPointerUp(PointerEvent e) {
    _pointers = math.max(0, _pointers - 1);
  }

  void _onTapUp(TapUpDetails d) {
    if (widget.previewMode || _c.tool == StoryTool.photo) return;
    final hit = widget.renderer.hitTest(_c.document, _toCanvas(d.localPosition));
    if (hit != null && hit.id == _c.selectedId && hit.isEditableText && !hit.locked) {
      widget.onEditText?.call(hit);
      return;
    }
    _c.select(hit?.id);
  }

  void _onScaleStart(ScaleStartDetails d) {
    if (widget.previewMode) return;
    _focal0 = _toCanvas(d.localFocalPoint);
    if (_c.tool == StoryTool.photo) {
      if (_c.photo == null) return;
      _drag = _Drag.photo;
      _photo0 = _c.document.photoTransform;
      _c.beginGesture();
      return;
    }
    final hit = widget.renderer.hitTest(_c.document, _downAt ?? _focal0);
    if (hit == null) return;
    _c.select(hit.id);
    if (hit.locked) return;
    _drag = _Drag.layer;
    _layer0 = hit;
    _c.beginGesture();
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    final delta = _toCanvas(d.localFocalPoint) - _focal0;
    switch (_drag) {
      case _Drag.photo:
        final frame = _c.document.photoFrameIn(kStoryWidth, kStoryHeight);
        _c.setPhotoTransform(
          PhotoTransform(
            scale: _photo0.scale * d.scale,
            dx: _photo0.dx + delta.dx / frame.width,
            dy: _photo0.dy + delta.dy / frame.height,
          ),
          live: true,
        );
      case _Drag.layer:
        final l0 = _layer0!;
        var next = l0.movedBy(delta.dx / kStoryWidth, delta.dy / kStoryHeight);
        if (d.pointerCount >= 2) {
          next = next.copyWith(scale: l0.scale * d.scale, rotation: l0.rotation + d.rotation);
        }
        _c.updateLayer(l0.id, (_) => next, live: true);
      case _Drag.none:
        break;
    }
  }

  void _onScaleEnd(ScaleEndDetails d) {
    if (_drag == _Drag.layer && _layer0 != null) {
      _c.updateLayer(
        _layer0!.id,
        (l) => l.copyWith(rotation: StoryLayer.snapRotation(l.rotation)),
        live: true,
      );
    }
    if (_drag != _Drag.none) _c.endGesture();
    _drag = _Drag.none;
    _layer0 = null;
  }

  // ------------------------------------------------------------------ handles

  Offset _globalToCanvas(Offset global) {
    final box = _canvasKey.currentContext!.findRenderObject() as RenderBox;
    return _toCanvas(box.globalToLocal(global));
  }

  /// A point on the layer's box ([fx], [fy] in -1..1 from its centre),
  /// pushed [outX]/[outY] screen pixels outside it so handles never sit on
  /// top of each other, even on a short box. In widget pixels.
  Offset _handleAt(
    StoryLayer layer,
    StoryDocument doc,
    double fx,
    double fy, {
    double outX = 0,
    double outY = 0,
  }) {
    final size = widget.renderer.layerSize(layer, doc);
    final k = _scale * layer.scale;
    final local = Offset(fx * (size.width / 2 + outX / k), fy * (size.height / 2 + outY / k));
    return StoryRenderer.fromLayerLocal(layer, local) * _scale;
  }

  /// Handle below the box: drag to scale and rotate around the centre.
  Widget _rotateHandle(StoryLayer layer, Offset at) {
    return _handle(
      at: at,
      icon: Icons.open_in_full,
      label: 'resize-rotate',
      onStart: (g) {
        final l0 = _handleLayer0 = _c.selectedLayer!;
        _handleStart = _globalToCanvas(g) - Offset(l0.cx * kStoryWidth, l0.cy * kStoryHeight);
        _c.beginGesture();
      },
      onUpdate: (g) {
        final l0 = _handleLayer0, v0 = _handleStart;
        if (l0 == null || v0 == null) return;
        final v = _globalToCanvas(g) - Offset(l0.cx * kStoryWidth, l0.cy * kStoryHeight);
        if (v0.distance < 1 || v.distance < 1) return;
        _c.updateLayer(
          l0.id,
          (l) => l.copyWith(
            scale: l0.scale * v.distance / v0.distance,
            rotation: StoryLayer.snapRotation(l0.rotation + v.direction - v0.direction),
          ),
          live: true,
        );
      },
      onEnd: _endHandle,
    );
  }

  void _endHandle() {
    _handleLayer0 = null;
    _handleStart = null;
    _c.endGesture();
  }

  /// Right-edge handle: drag to make the box wider or narrower, rewrapping
  /// its text.
  Widget _widthHandle(StoryLayer layer, Offset at) {
    return _handle(
      at: at,
      icon: Icons.width_normal_outlined,
      label: 'width',
      onStart: (g) {
        _handleLayer0 = _c.selectedLayer!;
        _handleStart = _globalToCanvas(g);
        _c.beginGesture();
      },
      onUpdate: (g) {
        final l0 = _handleLayer0, p0 = _handleStart;
        if (l0 == null || p0 == null) return;
        final d = _globalToCanvas(g) - p0;
        // Along the layer's own x axis, so it works when rotated.
        final along = d.dx * math.cos(l0.rotation) + d.dy * math.sin(l0.rotation);
        _c.updateLayer(
          l0.id,
          (l) => l.copyWith(width: l0.width + 2 * along / (l0.scale * kStoryWidth)),
          live: true,
        );
      },
      onEnd: _endHandle,
    );
  }

  Widget _handle({
    required Offset at,
    required IconData icon,
    required String label,
    required void Function(Offset global) onStart,
    required void Function(Offset global) onUpdate,
    required VoidCallback onEnd,
  }) {
    final accent = Theme.of(context).colorScheme.primary;
    return Positioned(
      left: at.dx - _handleSize / 2,
      top: at.dy - _handleSize / 2,
      width: _handleSize,
      height: _handleSize,
      child: GestureDetector(
        key: ValueKey('story-handle-$label'),
        behavior: HitTestBehavior.opaque,
        onPanStart: (d) => onStart(d.globalPosition),
        onPanUpdate: (d) => onUpdate(d.globalPosition),
        onPanEnd: (_) => onEnd(),
        onPanCancel: onEnd,
        child: Center(
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            child: Icon(icon, size: 15, color: Colors.black),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _scale = math.min(constraints.maxWidth / kStoryWidth, constraints.maxHeight / kStoryHeight);
        final w = kStoryWidth * _scale, h = kStoryHeight * _scale;
        return Center(
          child: SizedBox(
            width: w,
            height: h,
            child: ListenableBuilder(
              listenable: _c,
              builder: (context, _) => _buildCanvas(context, Size(w, h)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCanvas(BuildContext context, Size size) {
    final doc = _c.document;
    final selected = widget.previewMode || _c.tool == StoryTool.photo ? null : _c.selectedLayer;
    final showSelection = selected != null && widget.renderer.isDrawn(selected, doc);
    final corners =
        showSelection
            ? [for (final p in widget.renderer.corners(selected, doc)) p * _scale]
            : const <Offset>[];
    final accent = Theme.of(context).colorScheme.primary;
    final l10n = AppLocalizations.of(context)!;
    final frame = doc.photoFrameIn(size.width, size.height);

    // Only the story is clipped to the canvas; handles may stick out of it
    // so they stay reachable at the edges.
    return Stack(
      key: _canvasKey,
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.previewMode ? 0 : 12),
            child: Stack(
              children: [
                Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(painter: StoryBackgroundPainter(widget.renderer, doc)),
                  ),
                ),
                Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(painter: StoryLayersPainter(widget.renderer, doc)),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: Listener(
            onPointerDown: _onPointerDown,
            onPointerUp: _onPointerUp,
            onPointerCancel: _onPointerUp,
            child: GestureDetector(
              key: const ValueKey('story-canvas-gestures'),
              behavior: HitTestBehavior.opaque,
              onTapUp: _onTapUp,
              onScaleStart: _onScaleStart,
              onScaleUpdate: _onScaleUpdate,
              onScaleEnd: _onScaleEnd,
              child: CustomPaint(
                painter: StorySelectionPainter(
                  corners: corners,
                  color: accent,
                  locked: selected?.locked ?? false,
                ),
              ),
            ),
          ),
        ),
        if (!widget.previewMode && _c.photo == null && widget.onAddPhoto != null)
          Positioned.fromRect(
            rect: frame,
            child: Center(
              child: FilledButton.icon(
                onPressed: widget.onAddPhoto,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(l10n.storyAddPhoto),
              ),
            ),
          ),
        if (!widget.previewMode && _c.tool == StoryTool.photo && _c.photo != null)
          Positioned(
            left: 0,
            right: 0,
            top: 12,
            child: IgnorePointer(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    l10n.storyPhotoHint,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),
          ),
        if (showSelection && !selected.locked) ...[
          if (selected.type != StoryLayerType.brand)
            _widthHandle(selected, _handleAt(selected, doc, 1, 0, outX: 20)),
          _rotateHandle(selected, _handleAt(selected, doc, 0, 1, outY: 30)),
        ],
      ],
    );
  }
}
