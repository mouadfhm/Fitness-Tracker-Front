import 'dart:ui';

import 'package:fitness_tracker_app/workout_story/models/story_document.dart';
import 'package:fitness_tracker_app/workout_story/models/story_templates.dart';
import 'package:fitness_tracker_app/workout_story/models/story_workout_data.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures.dart';

void main() {
  setUpAll(initStoryLocales);
  final labels = labelsFor();

  test('there are presets for both layouts', () {
    final layouts = StoryTemplates.all.map((t) => t.layout).toSet();
    expect(layouts, StoryLayoutKind.values.toSet());
    expect(StoryTemplates.all.length, greaterThanOrEqualTo(6));
    expect(StoryTemplates.all.map((t) => t.id).toSet().length, StoryTemplates.all.length);
  });

  test('every preset keeps its frames and layers on the 9:16 canvas', () {
    const canvas = Rect.fromLTWH(0, 0, 1, 1);
    for (final t in StoryTemplates.all) {
      expect(canvas.intersect(t.photoFrame), t.photoFrame, reason: t.id);
      if (t.panelFrame != null) expect(canvas.intersect(t.panelFrame!), t.panelFrame);
      final doc = StoryTemplates.build(t.id, completedRun(), labels);
      for (final l in doc.layers) {
        expect(l.cx, inInclusiveRange(0, 1), reason: '${t.id}/${l.id}');
        expect(l.cy, inInclusiveRange(0, 1), reason: '${t.id}/${l.id}');
      }
    }
  });

  test('a completed workout says so and leads with what was done', () {
    final doc = StoryTemplates.build('full_bold', completedRun(), labels);
    expect(doc.layer(StoryLayerIds.status)!.text, 'Workout complete');
    expect(doc.layer(StoryLayerIds.title)!.text, 'Course, 8 km/h');
    expect(doc.layer(StoryLayerIds.date)!.text, 'October 19, 2026');
    expect(doc.visibleStats, [StoryStatKind.duration, StoryStatKind.calories]);
    // Its z-order: text and stats under the brand.
    expect(doc.layers.last.type, StoryLayerType.brand);
  });

  test('a plan is labelled as planned, has no date and shows plan numbers', () {
    final doc = StoryTemplates.build('panel_bottom', plannedChest(), labels);
    expect(doc.layer(StoryLayerIds.status)!.text, 'Planned workout');
    expect(doc.layer(StoryLayerIds.date), isNull);
    expect(doc.visibleStats, [StoryStatKind.exercises, StoryStatKind.sets, StoryStatKind.duration]);
    // Reps are available but off by default.
    expect(doc.stats.map((s) => s.kind), contains(StoryStatKind.reps));
  });

  test('French stories use French words', () {
    final doc = StoryTemplates.build('full_bold', completedRun(), labelsFor('fr'));
    expect(doc.layer(StoryLayerIds.status)!.text, 'Séance terminée');
    expect(doc.layer(StoryLayerIds.date)!.text, '19 octobre 2026');
  });

  test('the minimal preset starts with fewer stats', () {
    final doc = StoryTemplates.build('full_minimal', plannedChest(), labels);
    expect(doc.visibleStats.length, 2);
  });

  test('a workout with no stats gets no stats layer', () {
    final data = StoryWorkoutData.fromLoggedActivity(
      activity: const {'name': 'Walk'},
      logged: const {'duration': 0},
    );
    final doc = StoryTemplates.build('full_bold', data, labels);
    expect(doc.layers.where((l) => l.type == StoryLayerType.stats), isEmpty);
  });

  group('switching templates', () {
    test('keeps photo, accent, branding, stats, edited words and added layers', () {
      final data = completedRun();
      var doc = StoryTemplates.build('full_bold', data, labels);
      const extra = StoryLayer(
        id: 'text_1',
        type: StoryLayerType.text,
        cx: 0.2,
        cy: 0.3,
        width: 0.5,
        text: 'PR!',
      );
      doc = doc
          .copyWith(
            photoPath: '/tmp/p.jpg',
            photoTransform: const PhotoTransform(scale: 2, dx: 0.1),
            paletteId: 'ice',
            branding: false,
            stats: [
              const StoryStatSetting(StoryStatKind.calories),
              const StoryStatSetting(StoryStatKind.duration, visible: false),
            ],
            layers: [...doc.layers, extra],
          )
          .replaceLayer(doc.layer(StoryLayerIds.title)!.copyWith(text: 'Morning run'));

      final next = StoryTemplates.build('panel_top', data, labels, carry: doc);
      expect(next.templateId, 'panel_top');
      expect(next.layout, StoryLayoutKind.photoPanel);
      expect(next.panelFrame, isNotNull);
      expect(next.photoPath, '/tmp/p.jpg');
      // The frame changed, so the photo is re-centred.
      expect(next.photoTransform.isIdentity, isTrue);
      expect(next.paletteId, 'ice');
      expect(next.branding, isFalse);
      expect(next.visibleStats, [StoryStatKind.calories]);
      expect(next.layer(StoryLayerIds.title)!.text, 'Morning run');
      // But the title takes the new template's place.
      final t = StoryTemplates.byId('panel_top');
      expect(next.layer(StoryLayerIds.title)!.cy, t.title.cy);
      expect(next.layer('text_1')!.text, 'PR!');
      expect(next.layers.last.type, StoryLayerType.brand);
    });
  });
}
