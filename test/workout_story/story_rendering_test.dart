import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:fitness_tracker_app/workout_story/models/story_document.dart';
import 'package:fitness_tracker_app/workout_story/models/story_templates.dart';
import 'package:fitness_tracker_app/workout_story/models/story_workout_data.dart';
import 'package:fitness_tracker_app/workout_story/rendering/story_exporter.dart';
import 'package:fitness_tracker_app/workout_story/rendering/story_renderer.dart';
import 'package:fitness_tracker_app/workout_story/services/story_photo_service.dart';
import 'package:fitness_tracker_app/workout_story/widgets/story_painters.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures.dart';

/// A [w]×[h] image: left half red, right half blue, so crop and position
/// show up in pixels.
Future<ui.Image> _twoTone(int w, int h) {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
    Rect.fromLTWH(0, 0, w / 2, h.toDouble()),
    Paint()..color = const Color(0xFFFF0000),
  );
  canvas.drawRect(
    Rect.fromLTWH(w / 2, 0, w / 2, h.toDouble()),
    Paint()..color = const Color(0xFF0000FF),
  );
  return recorder.endRecording().toImage(w, h);
}

Future<Uint8List> _rgba(ui.Image image) async =>
    (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!.buffer.asUint8List();

Color _pixel(Uint8List rgba, int width, int x, int y) {
  final i = (y * width + x) * 4;
  return Color.fromARGB(rgba[i + 3], rgba[i], rgba[i + 1], rgba[i + 2]);
}

void main() {
  setUpAll(initStoryLocales);
  final labels = labelsFor();

  group('hit testing and geometry', () {
    final renderer = StoryRenderer(StoryRenderContext(data: completedRun(), labels: labels));
    late StoryDocument doc;
    setUpAll(() async {
      await initStoryLocales();
      doc = StoryTemplates.build('full_bold', completedRun(), labels);
    });

    test('finds the layer under a point, topmost first', () {
      final title = doc.layer(StoryLayerIds.title)!;
      final center = Offset(title.cx * kStoryWidth, title.cy * kStoryHeight);
      expect(renderer.hitTest(doc, center)?.id, StoryLayerIds.title);

      // Put a copy of the title on top: it wins.
      final copy = title.copyWith(id: 'copy');
      final stacked = doc.copyWith(layers: [...doc.layers, copy]);
      expect(renderer.hitTest(stacked, center)?.id, 'copy');

      // Empty space hits nothing.
      expect(renderer.hitTest(doc, const Offset(540, 300)), isNull);
    });

    test('respects rotation and scale', () {
      final layer = doc.layer(StoryLayerIds.title)!.copyWith(rotation: math.pi / 2, scale: 0.5);
      final rotated = doc.replaceLayer(layer);
      final size = renderer.layerSize(layer, rotated);
      final c = Offset(layer.cx * kStoryWidth, layer.cy * kStoryHeight);
      // Turned a quarter, the box's long side now runs down the canvas.
      final below = c + Offset(0, size.width * 0.5 * 0.45);
      final beside = c + Offset(size.width * 0.5 * 0.9, 0);
      expect(renderer.hitTest(rotated, below, slop: 0)?.id, StoryLayerIds.title);
      expect(renderer.hitTest(rotated, beside, slop: 0)?.id, isNot(StoryLayerIds.title));
    });

    test('local and canvas coordinates are inverses', () {
      final layer = doc.layer(StoryLayerIds.stats)!.copyWith(rotation: 0.7, scale: 1.8, cx: 0.3);
      const p = Offset(123, 456);
      final back = StoryRenderer.fromLayerLocal(layer, StoryRenderer.toLayerLocal(layer, p));
      expect(back.dx, closeTo(p.dx, 1e-6));
      expect(back.dy, closeTo(p.dy, 1e-6));
    });

    test('hidden layers, branding off and empty stats are not drawn or hit', () {
      final brand = doc.layer(StoryLayerIds.brand)!;
      expect(renderer.isDrawn(brand, doc), isTrue);
      expect(renderer.isDrawn(brand, doc.copyWith(branding: false)), isFalse);
      final hidden = doc.replaceLayer(doc.layer(StoryLayerIds.title)!.copyWith(visible: false));
      final t = doc.layer(StoryLayerIds.title)!;
      expect(
        renderer.hitTest(hidden, Offset(t.cx * kStoryWidth, t.cy * kStoryHeight))?.id,
        isNot(StoryLayerIds.title),
      );
      final noStats = doc.copyWith(
        stats: [for (final s in doc.stats) StoryStatSetting(s.kind, visible: false)],
      );
      expect(renderer.isDrawn(doc.layer(StoryLayerIds.stats)!, noStats), isFalse);
    });

    test('a wider box re-wraps text into fewer lines', () {
      final title = doc.layer(StoryLayerIds.title)!.copyWith(text: 'A long title that wraps');
      final narrow = renderer.layerSize(title.copyWith(width: 0.3), doc);
      final wide = renderer.layerSize(title.copyWith(width: 1.1), doc);
      expect(narrow.height, greaterThan(wide.height));
      expect(wide.width, closeTo(1.1 * kStoryWidth, 0.001));
    });

    test('planned stats get their caption, completed ones do not', () {
      final planned = StoryRenderer(StoryRenderContext(data: plannedChest(), labels: labels));
      final pDoc = StoryTemplates.build('full_bold', plannedChest(), labels);
      final cStats = renderer.layerSize(doc.layer(StoryLayerIds.stats)!, doc);
      final pStats = planned.layerSize(pDoc.layer(StoryLayerIds.stats)!, pDoc);
      // Same font size and one row each; the plan is taller by its caption.
      expect(pStats.height, greaterThan(cStats.height));
    });
  });

  group('export', () {
    testWidgets('is a 1080×1920 PNG', (tester) async {
      await tester.runAsync(() async {
        final doc = StoryTemplates.build('panel_bottom', completedRun(), labels);
        final png = await StoryExporter.renderPng(
          doc,
          StoryRenderContext(data: completedRun(), labels: labels),
        );
        expect(StoryExporter.pngSize(png), (1080, 1920));
        final decoded = await decodeStoryPhoto(png);
        expect((decoded.width, decoded.height), (1080, 1920));
        decoded.dispose();
      });
    });

    testWidgets('matches the editor preview pixel for pixel', (tester) async {
      await tester.runAsync(() async {
        final photo = await _twoTone(800, 600);
        final data = completedRun();
        final ctx = StoryRenderContext(data: data, labels: labels, photo: photo);
        for (final id in ['full_bold', 'card']) {
          var doc = StoryTemplates.build(id, data, labels).copyWith(
            photoPath: 'p',
            photoTransform: const PhotoTransform(scale: 1.4, dx: 0.1, dy: -0.05),
            paletteId: 'ember',
          );
          doc = doc.replaceLayer(
            doc.layer(StoryLayerIds.title)!.copyWith(rotation: 0.2, scale: 1.3),
          );

          final exported = await StoryExporter.renderImage(doc, ctx);

          // The editor's two painters, as the live canvas stacks them.
          final renderer = StoryRenderer(ctx);
          final recorder = ui.PictureRecorder();
          final canvas = Canvas(recorder);
          StoryBackgroundPainter(renderer, doc).paint(canvas, StoryRenderer.size);
          StoryLayersPainter(renderer, doc).paint(canvas, StoryRenderer.size);
          final preview = await recorder.endRecording().toImage(1080, 1920);

          expect(await _rgba(preview), await _rgba(exported), reason: id);
          preview.dispose();
          exported.dispose();
        }
        photo.dispose();
      });
    });

    testWidgets('the brand shows the app logo before the name', (tester) async {
      await tester.runAsync(() async {
        // A plain green square stands in for the logo.
        final recorder = ui.PictureRecorder();
        Canvas(recorder).drawColor(const Color(0xFF00FF00), BlendMode.src);
        final logo = await recorder.endRecording().toImage(100, 100);
        final data = completedRun();
        final doc = StoryTemplates.build('full_bold', data, labels).copyWith(dim: 0, gradient: 0);
        final brand = doc.layer(StoryLayerIds.brand)!;
        final ctx = StoryRenderContext(data: data, labels: labels, logo: logo);
        final renderer = StoryRenderer(ctx);
        final size = renderer.layerSize(brand, doc);
        final logoSide = brand.style.fontSize * 2.2;
        expect(size.height, closeTo(logoSide, 0.5));

        final image = await StoryExporter.renderImage(doc, ctx);
        final rgba = await _rgba(image);
        // Start-aligned: the logo is the box's first square.
        final left = brand.cx * kStoryWidth - size.width / 2;
        final top = brand.cy * kStoryHeight - size.height / 2;
        final at = _pixel(rgba, 1080, (left + logoSide / 2).round(), (top + logoSide / 2).round());
        expect(at, const Color(0xFF00FF00));
        image.dispose();
        logo.dispose();
      });
    });

    testWidgets('crops the photo where the transform says', (tester) async {
      await tester.runAsync(() async {
        // A landscape photo in a full 9:16 frame: only its middle shows.
        final photo = await _twoTone(1600, 900);
        final data = StoryWorkoutData.fromLoggedActivity(
          activity: const {'name': 'Run'},
          logged: const {},
        );
        final ctx = StoryRenderContext(data: data, labels: labels, photo: photo);
        final base = StoryTemplates.build(
          'full_bold',
          data,
          labels,
        ).copyWith(photoPath: 'p', dim: 0, gradient: 0, branding: false, layers: const []);

        Future<Uint8List> render(PhotoTransform t) async {
          final image = await StoryExporter.renderImage(base.copyWith(photoTransform: t), ctx);
          final bytes = await _rgba(image);
          image.dispose();
          return bytes;
        }

        final centred = await render(PhotoTransform.identity);
        expect(_pixel(centred, 1080, 100, 960), const Color(0xFFFF0000));
        expect(_pixel(centred, 1080, 980, 960), const Color(0xFF0000FF));

        // Moved right by 20% of the frame: the seam follows, 216 px over.
        final panned = await render(const PhotoTransform(dx: 0.2));
        expect(_pixel(panned, 1080, 740, 960), const Color(0xFFFF0000));
        expect(_pixel(panned, 1080, 772, 960), const Color(0xFF0000FF));

        // Panning past the edge stops where the photo still covers the frame.
        final far = await render(const PhotoTransform(dx: 50));
        final clamped = await render(
          const PhotoTransform(dx: 50).clamped(1600, 900, const Rect.fromLTWH(0, 0, 1080, 1920)),
        );
        expect(far, clamped);
        photo.dispose();
      });
    });
  });

  group('photo decoding', () {
    testWidgets('large photos are decoded smaller with the same aspect', (tester) async {
      await tester.runAsync(() async {
        final big = await _twoTone(4000, 3000);
        final png = (await big.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
        big.dispose();
        final decoded = await decodeStoryPhoto(png, maxSide: 2000);
        expect(decoded.width, 2000);
        expect(decoded.height, 1500);
        decoded.dispose();
      });
    });

    testWidgets('bytes that are not an image fail cleanly', (tester) async {
      await tester.runAsync(() async {
        await expectLater(
          decodeStoryPhoto(Uint8List.fromList(List.filled(64, 7))),
          throwsA(
            isA<StoryPhotoException>().having((e) => e.error, 'error', StoryPhotoError.unreadable),
          ),
        );
      });
    });
  });
}
