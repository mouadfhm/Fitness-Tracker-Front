import 'package:flutter/material.dart';

import '../models/story_document.dart';
import '../rendering/story_renderer.dart';

/// The photo, veil, gradient and panel, scaled to the widget. Kept apart
/// from the layers so dragging text doesn't redraw the photo.
class StoryBackgroundPainter extends CustomPainter {
  StoryBackgroundPainter(this.renderer, this.doc);

  final StoryRenderer renderer;
  final StoryDocument doc;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / kStoryWidth);
    renderer.paintBackground(canvas, doc);
  }

  @override
  bool shouldRepaint(StoryBackgroundPainter old) =>
      !identical(old.renderer.context.photo, renderer.context.photo) ||
      old.doc.templateId != doc.templateId ||
      old.doc.photoPath != doc.photoPath ||
      old.doc.photoTransform != doc.photoTransform ||
      old.doc.dim != doc.dim ||
      old.doc.gradient != doc.gradient ||
      old.doc.paletteId != doc.paletteId;
}

/// The text, stats and brand layers, scaled to the widget.
class StoryLayersPainter extends CustomPainter {
  StoryLayersPainter(this.renderer, this.doc);

  final StoryRenderer renderer;
  final StoryDocument doc;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / kStoryWidth);
    renderer.paintLayers(canvas, doc);
  }

  @override
  bool shouldRepaint(StoryLayersPainter old) =>
      !identical(old.renderer, renderer) ||
      !identical(old.doc.layers, doc.layers) ||
      !identical(old.doc.stats, doc.stats) ||
      old.doc.paletteId != doc.paletteId ||
      old.doc.branding != doc.branding;
}

/// The whole story, for thumbnails.
class StoryPainter extends CustomPainter {
  StoryPainter(this.renderer, this.doc);

  final StoryRenderer renderer;
  final StoryDocument doc;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    canvas.scale(size.width / kStoryWidth);
    renderer.paint(canvas, doc);
  }

  @override
  bool shouldRepaint(StoryPainter old) =>
      !identical(old.renderer, renderer) || !identical(old.doc, doc);
}

/// The outline around the selected layer. Editor only: never part of the
/// exported image.
class StorySelectionPainter extends CustomPainter {
  StorySelectionPainter({required this.corners, required this.color, this.locked = false});

  /// Corners in widget pixels.
  final List<Offset> corners;
  final Color color;
  final bool locked;

  @override
  void paint(Canvas canvas, Size size) {
    if (corners.length != 4) return;
    final path = Path()..addPolygon(corners, true);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = Colors.black.withValues(alpha: 0.35),
    );
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = locked ? Colors.white70 : color;
    if (!locked) {
      canvas.drawPath(path, paint);
      return;
    }
    // Dashed when locked.
    for (final metric in path.computeMetrics()) {
      for (double d = 0; d < metric.length; d += 10) {
        canvas.drawPath(metric.extractPath(d, d + 5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(StorySelectionPainter old) =>
      old.color != color || old.locked != locked || !_same(old.corners, corners);

  static bool _same(List<Offset> a, List<Offset> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
