import 'dart:typed_data';
import 'dart:ui' as ui;

import '../models/story_document.dart';
import 'story_renderer.dart';

/// Renders a story off-screen at exactly [kStoryWidth]×[kStoryHeight]
/// pixels, through the same [StoryRenderer] the editor draws with. Nothing
/// on screen is captured, so no editor UI can end up in the image.
abstract final class StoryExporter {
  static const int width = 1080;
  static const int height = 1920;

  static Future<ui.Image> renderImage(StoryDocument doc, StoryRenderContext context) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, kStoryWidth, kStoryHeight));
    StoryRenderer(context).paint(canvas, doc);
    final picture = recorder.endRecording();
    try {
      return await picture.toImage(width, height);
    } finally {
      picture.dispose();
    }
  }

  /// The story as PNG bytes.
  static Future<Uint8List> renderPng(StoryDocument doc, StoryRenderContext context) async {
    final image = await renderImage(doc, context);
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) throw StateError('PNG encoding returned no data');
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    } finally {
      image.dispose();
    }
  }

  /// Width and height read from a PNG's IHDR chunk.
  static (int, int)? pngSize(Uint8List png) {
    const signature = [137, 80, 78, 71, 13, 10, 26, 10];
    if (png.length < 24) return null;
    for (var i = 0; i < signature.length; i++) {
      if (png[i] != signature[i]) return null;
    }
    final view = ByteData.sublistView(png);
    return (view.getUint32(16), view.getUint32(20));
  }
}
