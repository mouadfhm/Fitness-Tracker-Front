import 'package:fitness_tracker_app/workout_story/models/story_document.dart';
import 'package:fitness_tracker_app/workout_story/models/story_templates.dart';
import 'package:fitness_tracker_app/workout_story/models/story_workout_data.dart';
import 'package:fitness_tracker_app/workout_story/story_editor_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures.dart';

void main() {
  setUpAll(initStoryLocales);
  late StoryEditorController c;

  setUp(() {
    c = StoryEditorController(data: plannedChest(), labels: labelsFor(), templateId: 'full_bold');
  });
  tearDown(() => c.dispose());

  List<String> ids() => [for (final l in c.document.layers) l.id];

  group('undo, redo and reset', () {
    test('each edit is one step, undone and redone in order', () {
      final original = c.document;
      expect(c.canUndo, isFalse);
      c.setPalette('mint');
      c.setBranding(false);
      expect(c.document.paletteId, 'mint');
      expect(c.document.branding, isFalse);

      c.undo();
      expect(c.document.branding, isTrue);
      expect(c.document.paletteId, 'mint');
      c.undo();
      expect(identical(c.document, original), isTrue);
      expect(c.canUndo, isFalse);

      c.redo();
      c.redo();
      expect(c.document.paletteId, 'mint');
      expect(c.document.branding, isFalse);
      expect(c.canRedo, isFalse);
    });

    test('a new edit clears redo', () {
      c.setPalette('mint');
      c.undo();
      expect(c.canRedo, isTrue);
      c.setPalette('ice');
      expect(c.canRedo, isFalse);
    });

    test('a drag shows live and lands as a single step', () {
      final before = c.document.layer(StoryLayerIds.title)!;
      c.beginGesture();
      for (var i = 1; i <= 10; i++) {
        c.updateLayer(StoryLayerIds.title, (l) => before.movedBy(i * 0.01, 0), live: true);
      }
      expect(c.document.layer(StoryLayerIds.title)!.cx, closeTo(before.cx + 0.1, 1e-9));
      c.endGesture();
      c.undo();
      expect(c.document.layer(StoryLayerIds.title)!.cx, before.cx);
      expect(c.canUndo, isFalse);
    });

    test('a gesture that changed nothing adds no step', () {
      c.beginGesture();
      c.endGesture();
      expect(c.canUndo, isFalse);
    });

    test('slider drags are one step too', () {
      c.beginGesture();
      for (final v in [0.1, 0.2, 0.5]) {
        c.setDim(v, live: true);
      }
      c.endGesture();
      expect(c.document.dim, 0.5);
      c.undo();
      expect(c.document.dim, StoryTemplates.byId('full_bold').dim);
    });

    test('reset goes back to the template, keeps the photo, and is undoable', () {
      final original = c.document.toJson();
      c.addText('Hello');
      c.setPalette('ember');
      c.updateLayer(StoryLayerIds.title, (l) => l.copyWith(text: 'Edited', rotation: 0.4));
      c.resetDesign();
      expect(c.document.toJson(), original);
      expect(c.selectedId, isNull);
      c.undo();
      expect(c.document.layer(StoryLayerIds.title)!.text, 'Edited');
    });

    test('history is capped', () {
      for (var i = 0; i < StoryEditorController.historyLimit + 20; i++) {
        c.setDim((i % 10) / 10 + 0.01);
      }
      var steps = 0;
      while (c.canUndo) {
        c.undo();
        steps++;
      }
      expect(steps, StoryEditorController.historyLimit);
    });
  });

  group('layers', () {
    test('add, duplicate and delete keep the brand on top and select the new layer', () {
      final added = c.addText('Hi');
      expect(c.selectedId, added.id);
      expect(c.document.layers.last.type, StoryLayerType.brand);
      expect(ids()[ids().length - 2], added.id);

      final copy = c.duplicate(added.id)!;
      expect(copy.id, isNot(added.id));
      expect(copy.text, 'Hi');
      expect(copy.cx, closeTo(added.cx + 0.03, 1e-9));
      expect(ids().indexOf(copy.id), ids().indexOf(added.id) + 1);
      expect(c.selectedId, copy.id);

      c.delete(copy.id);
      expect(c.document.layer(copy.id), isNull);
      expect(c.selectedId, isNull);
    });

    test('the brand is switched off, not deleted or duplicated', () {
      c.delete(StoryLayerIds.brand);
      expect(c.document.layer(StoryLayerIds.brand), isNotNull);
      expect(c.duplicate(StoryLayerIds.brand), isNull);
      expect(c.canUndo, isFalse);
    });

    test('reorder, bring forward and send backward change z-order', () {
      final start = ids();
      c.bringForward(StoryLayerIds.status);
      expect(ids().indexOf(StoryLayerIds.status), start.indexOf(StoryLayerIds.status) + 1);
      c.sendBackward(StoryLayerIds.status);
      expect(ids(), start);
      c.reorderLayer(0, start.length - 1);
      expect(ids().last, start.first);
      c.undo();
      expect(ids(), start);
      // Out of range is a no-op.
      c.sendBackward(start.first);
      expect(ids(), start);
    });

    test('lock and visibility toggle and undo', () {
      c.toggleLock(StoryLayerIds.title);
      expect(c.document.layer(StoryLayerIds.title)!.locked, isTrue);
      c.toggleVisible(StoryLayerIds.title);
      expect(c.document.layer(StoryLayerIds.title)!.visible, isFalse);
      c.undo();
      c.undo();
      final t = c.document.layer(StoryLayerIds.title)!;
      expect(t.locked || !t.visible, isFalse);
    });

    test('exercise highlights list the plan', () {
      final l = c.addExerciseHighlights()!;
      expect(l.text.split('\n'), [
        'Développé couché prise serrée  ·  3 × 12',
        'Rope Cable Push-Down  ·  4 × 10',
        'Plank  ·  3 × 45 s',
      ]);
    });

    test('a deleted stats block can be put back', () {
      c.delete(StoryLayerIds.stats);
      expect(c.hasStatsLayer, isFalse);
      c.addStatsLayer();
      expect(c.hasStatsLayer, isTrue);
    });

    test('undo drops a selection whose layer no longer exists', () {
      final l = c.addText('x');
      expect(c.selectedId, l.id);
      c.undo();
      expect(c.selectedId, isNull);
    });
  });

  group('stats', () {
    test('toggle and reorder', () {
      c.setStatVisible(StoryStatKind.reps, true);
      expect(c.document.visibleStats, contains(StoryStatKind.reps));
      final kinds = [for (final s in c.document.stats) s.kind];
      c.reorderStat(kinds.length - 1, 0);
      expect(c.document.stats.first.kind, kinds.last);
      c.setStatVisible(StoryStatKind.exercises, false);
      expect(c.document.visibleStats, isNot(contains(StoryStatKind.exercises)));
      c.undo();
      c.undo();
      c.undo();
      expect([for (final s in c.document.stats) s.kind], kinds);
    });
  });

  group('templates', () {
    test('switching is one undoable step', () {
      c.applyTemplate('card');
      expect(c.document.templateId, 'card');
      expect(c.document.layout, StoryLayoutKind.photoPanel);
      c.undo();
      expect(c.document.templateId, 'full_bold');
      c.applyTemplate('full_bold');
      expect(c.canRedo, isTrue); // same template: nothing happened
    });

    test('the photo tool clears the selection; stats selects the stats block', () {
      c.setTool(StoryTool.text);
      c.select(StoryLayerIds.title);
      c.setTool(StoryTool.photo);
      expect(c.selectedId, isNull);
      c.setTool(StoryTool.stats);
      expect(c.selectedLayer?.type, StoryLayerType.stats);
    });
  });

  test('editing never touches the workout data', () {
    final data = c.data;
    c.addText('x');
    c.setStatVisible(StoryStatKind.sets, false);
    c.applyTemplate('panel_top');
    expect(identical(c.data, data), isTrue);
    expect(data.totalSets, 10);
    expect(data.title, 'Chest Day');
  });
}
