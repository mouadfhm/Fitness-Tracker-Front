import 'dart:math' as math;
import 'dart:ui';

import 'package:fitness_tracker_app/workout_story/models/story_document.dart';
import 'package:fitness_tracker_app/workout_story/models/story_templates.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures.dart';

void main() {
  setUpAll(initStoryLocales);
  group('PhotoTransform', () {
    const frame = Rect.fromLTWH(0, 0, kStoryWidth, kStoryHeight);

    test('a landscape photo covers the 9:16 frame without distortion', () {
      final dst = PhotoTransform.identity.destination(4000, 3000, frame);
      expect(dst.height, closeTo(kStoryHeight, 0.001));
      expect(dst.width, closeTo(kStoryHeight * 4 / 3, 0.001));
      expect(dst.width / dst.height, closeTo(4000 / 3000, 1e-9));
      expect(dst.center, frame.center);
      expect(dst.left <= frame.left && dst.right >= frame.right, isTrue);
    });

    test('a portrait photo covers the frame by its width', () {
      final dst = PhotoTransform.identity.destination(1000, 3000, frame);
      expect(dst.width, closeTo(kStoryWidth, 0.001));
      expect(dst.height, closeTo(3240, 0.001));
    });

    test('pan is kept to what still covers the frame', () {
      final t = const PhotoTransform(dx: 5, dy: -5).clamped(4000, 3000, frame);
      final dst = t.destination(4000, 3000, frame);
      expect(dst.left, closeTo(frame.left, 0.001)); // pushed right as far as it goes
      expect(dst.top, closeTo(frame.top, 0.001));
      expect(t.dy, 0); // no vertical overflow at scale 1
    });

    test('zoom is between cover and the maximum', () {
      expect(const PhotoTransform(scale: 0.3).clamped(100, 100, frame).scale, 1);
      expect(
        const PhotoTransform(scale: 99).clamped(100, 100, frame).scale,
        PhotoTransform.maxScale,
      );
      final zoomed = const PhotoTransform(scale: 2, dy: 0.2).clamped(1080, 1920, frame);
      expect(zoomed.dy, closeTo(0.2, 1e-9)); // within the 50% overflow at 2x
      final dst = zoomed.destination(1080, 1920, frame);
      expect(dst.width, closeTo(2160, 0.001));
      expect(dst.top <= 0 && dst.bottom >= kStoryHeight, isTrue);
    });

    test('works in a frame that is not the whole canvas', () {
      const panelPhoto = Rect.fromLTWH(0, 0, kStoryWidth, kStoryHeight * 0.62);
      final dst = const PhotoTransform(dx: -1).destination(1080, 1920, panelPhoto);
      expect(dst.right, closeTo(panelPhoto.right, 0.001));
      expect(dst.top <= panelPhoto.top && dst.bottom >= panelPhoto.bottom, isTrue);
    });
  });

  group('StoryLayer', () {
    const layer = StoryLayer(id: 'a', type: StoryLayerType.text, cx: 0.5, cy: 0.5, width: 0.8);

    test('moves in normalized units and stays on the canvas', () {
      final moved = layer.movedBy(0.1, -0.2);
      expect(moved.cx, closeTo(0.6, 1e-9));
      expect(moved.cy, closeTo(0.3, 1e-9));
      final far = layer.movedBy(3, -3);
      expect(far.cx, 1);
      expect(far.cy, 0);
    });

    test('scale and width are clamped', () {
      expect(layer.copyWith(scale: 100).scale, StoryLayer.maxScale);
      expect(layer.copyWith(scale: 0).scale, StoryLayer.minScale);
      expect(layer.copyWith(width: 0).width, StoryLayer.minWidth);
    });

    test('rotation snaps back to straight near quarter turns only', () {
      expect(StoryLayer.snapRotation(0.03), 0);
      expect(StoryLayer.snapRotation(math.pi / 2 - 0.02), math.pi / 2);
      expect(StoryLayer.snapRotation(0.3), 0.3);
    });
  });

  group('StoryDocument JSON', () {
    test('round-trips every field with a schema version', () {
      final doc = StoryTemplates.build('card', plannedChest(), labelsFor()).copyWith(
        photoPath: '/tmp/p.jpg',
        photoTransform: const PhotoTransform(scale: 1.5, dx: 0.1, dy: -0.05),
        dim: 0.3,
        paletteId: 'ember',
        branding: false,
      );
      final json = doc.toJson();
      expect(json['version'], StoryDocument.schemaVersion);
      final back = StoryDocument.fromJson(json);
      expect(back.toJson(), json);
    });

    test('skips stats it does not know and refuses newer documents', () {
      final json = StoryTemplates.build('full_bold', completedRun(), labelsFor()).toJson();
      json['stats'] = [
        {'kind': 'heart_rate', 'visible': true},
        ...json['stats'] as List,
      ];
      expect(StoryDocument.fromJson(json).stats.length, 2);
      expect(() => StoryDocument.fromJson({...json, 'version': 99}), throwsFormatException);
    });
  });
}
