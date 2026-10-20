import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:fitness_tracker_app/l10n/app_localizations.dart';
import 'package:fitness_tracker_app/workout_story/models/story_document.dart';
import 'package:fitness_tracker_app/workout_story/models/story_templates.dart';
import 'package:fitness_tracker_app/workout_story/models/story_workout_data.dart';
import 'package:fitness_tracker_app/workout_story/rendering/story_exporter.dart';
import 'package:fitness_tracker_app/workout_story/rendering/story_renderer.dart';
import 'package:fitness_tracker_app/workout_story/screens/story_editor_screen.dart';
import 'package:fitness_tracker_app/workout_story/screens/story_export_screen.dart';
import 'package:fitness_tracker_app/workout_story/screens/story_template_screen.dart';
import 'package:fitness_tracker_app/workout_story/services/story_export_actions.dart';
import 'package:fitness_tracker_app/workout_story/services/story_photo_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures.dart';

class FakePicker implements StoryPhotoPicker {
  FakePicker(this.result);

  /// A path, null (cancelled) or a [StoryPhotoException] to throw.
  Object? result;
  final picked = <StoryPhotoSource>[];
  final discarded = <String>[];

  @override
  Future<String?> pick(StoryPhotoSource source) async {
    picked.add(source);
    final r = result;
    if (r is Exception) throw r;
    return r as String?;
  }

  @override
  Future<void> discard(Iterable<String> paths) async => discarded.addAll(paths);
}

class FakeExportActions implements StoryExportActions {
  StorySaveOutcome save = StorySaveOutcome.saved;
  StoryShareOutcome shareOutcome = StoryShareOutcome.shared;
  Object? error;
  final saved = <Uint8List>[];
  final shared = <Uint8List>[];
  bool disposed = false;

  @override
  Future<StorySaveOutcome> saveToGallery(Uint8List png) async {
    if (error != null) throw error!;
    saved.add(png);
    return save;
  }

  @override
  Future<StoryShareOutcome> share(Uint8List png, {Rect? origin}) async {
    if (error != null) throw error!;
    shared.add(png);
    return shareOutcome;
  }

  @override
  Future<void> dispose() async => disposed = true;
}

Widget _app(Widget home, {Locale locale = const Locale('en')}) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

void _phone(WidgetTester tester, {Size size = const Size(390, 844)}) {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Future<Uint8List> _testPng(WidgetTester tester) async =>
    (await tester.runAsync(() async {
      final data = completedRun();
      final labels = labelsFor();
      return StoryExporter.renderPng(
        StoryTemplates.build('full_bold', data, labels),
        StoryRenderContext(data: data, labels: labels),
      );
    }))!;

void main() {
  setUpAll(initStoryLocales);

  group('editor', () {
    Future<FakePicker> pumpEditor(
      WidgetTester tester, {
      Object? pick,
      StoryWorkoutData? data,
      FakeExportActions? actions,
      Locale? locale,
    }) async {
      _phone(tester);
      final picker = FakePicker(pick);
      late ui.Image image;
      await tester.runAsync(() async => image = await createTestImage(width: 40, height: 30));
      await tester.pumpWidget(
        _app(
          StoryEditorScreen(
            data: data ?? completedRun(),
            photoPicker: picker,
            decodePhoto: (_) async => image,
            exportActions: () => actions ?? FakeExportActions(),
          ),
          locale: locale ?? const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();
      return picker;
    }

    testWidgets('shows the canvas, five tools and an add-photo prompt', (tester) async {
      await pumpEditor(tester);
      for (final tool in ['Photo', 'Text', 'Stats', 'Style', 'Layers']) {
        expect(find.text(tool), findsOneWidget);
      }
      expect(find.text('Add photo'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a cancelled pick changes nothing and says nothing', (tester) async {
      final picker = await pumpEditor(tester, pick: null);
      await tester.tap(find.text('Gallery'));
      await tester.pumpAndSettle();
      expect(picker.picked, [StoryPhotoSource.gallery]);
      expect(find.byType(SnackBar), findsNothing);
      expect(find.text('Add photo'), findsOneWidget);
      expect(
        tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.undo)).onPressed,
        isNull,
      );
    });

    testWidgets('denied photo access is explained', (tester) async {
      await pumpEditor(tester, pick: const StoryPhotoException(StoryPhotoError.galleryDenied));
      await tester.tap(find.text('Gallery'));
      await tester.pumpAndSettle();
      expect(find.text('Allow photo access in Settings to choose a photo.'), findsOneWidget);
    });

    testWidgets('a picked photo replaces the prompt and can be undone', (tester) async {
      final picker = await pumpEditor(tester, pick: '/tmp/photo.jpg');
      await tester.tap(find.text('Camera'));
      await tester.pumpAndSettle();
      expect(picker.picked, [StoryPhotoSource.camera]);
      expect(find.text('Add photo'), findsNothing);
      expect(find.text('Replace'), findsOneWidget);

      await tester.tap(find.byTooltip('Undo'));
      await tester.pumpAndSettle();
      expect(find.text('Add photo'), findsOneWidget);
    });

    testWidgets('stats can be switched off from the stats tool', (tester) async {
      await pumpEditor(tester);
      await tester.tap(find.text('Stats'));
      await tester.pumpAndSettle();
      expect(find.text('Duration'), findsOneWidget);
      expect(find.text('kcal (est.)'), findsOneWidget);
      // Calories are labelled as an estimate in the list too.
      expect(find.textContaining('estimate'), findsOneWidget);
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();
      expect(tester.widget<Switch>(find.byType(Switch).first).value, isFalse);
    });

    testWidgets('dragging a layer moves it; the photo tool leaves it alone', (tester) async {
      await pumpEditor(tester);
      final canvas = find.byKey(const ValueKey('story-canvas-gestures'));
      final box = tester.getRect(canvas);
      final scale = box.width / kStoryWidth;
      final t = StoryTemplates.byId('full_bold').title;
      final titleAt = box.topLeft + Offset(t.cx * kStoryWidth, t.cy * kStoryHeight) * scale;

      // Photo tool (the default): the drag goes to the photo, of which there
      // is none, and the title stays.
      await tester.dragFrom(titleAt, const Offset(0, -80));
      await tester.pumpAndSettle();
      expect(
        tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.undo)).onPressed,
        isNull,
      );

      await tester.tap(find.text('Text'));
      await tester.pumpAndSettle();
      await tester.dragFrom(titleAt, const Offset(0, -80));
      await tester.pumpAndSettle();
      // One drag, one undo step.
      expect(
        tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.undo)).onPressed,
        isNotNull,
      );
      // The selected title now has handles.
      expect(find.byKey(const ValueKey('story-handle-resize-rotate')), findsOneWidget);
    });

    testWidgets('preview hides the editing UI', (tester) async {
      await pumpEditor(tester);
      await tester.tap(find.byTooltip('Preview'));
      await tester.pumpAndSettle();
      expect(find.text('Photo'), findsNothing);
      expect(find.text('Add photo'), findsNothing);
      expect(find.text('Back to editing'), findsOneWidget);
      await tester.tap(find.text('Back to editing'));
      await tester.pumpAndSettle();
      expect(find.text('Photo'), findsOneWidget);
    });

    testWidgets('fits a small phone and long French labels', (tester) async {
      await pumpEditor(tester, data: plannedChest(), locale: const Locale('fr'));
      _phone(tester, size: const Size(320, 568));
      await tester.pumpAndSettle();
      for (final tool in ['Photo', 'Texte', 'Stats', 'Style', 'Calques']) {
        await tester.tap(find.text(tool));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: tool);
      }
    });

    testWidgets('Next renders the story and opens the export screen', (tester) async {
      final actions = FakeExportActions();
      await pumpEditor(tester, actions: actions);
      await tester.tap(find.byKey(const ValueKey('story-next')));
      // The image is rendered off-screen, on the real clock.
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 500)));
      await tester.pumpAndSettle();
      expect(find.byType(StoryExportScreen), findsOneWidget);
      final shown = tester.widget<StoryExportScreen>(find.byType(StoryExportScreen)).png;
      expect(StoryExporter.pngSize(shown), (1080, 1920));

      // Done closes the editor too.
      await tester.tap(find.byKey(const ValueKey('story-done')));
      await tester.pumpAndSettle();
      expect(find.byType(StoryEditorScreen), findsNothing);
      expect(actions.disposed, isTrue);
    });

    testWidgets('leaving with changes asks first; discarding cleans up photos', (tester) async {
      _phone(tester);
      final picker = FakePicker('/tmp/photo.jpg');
      late ui.Image image;
      await tester.runAsync(() async => image = await createTestImage(width: 40, height: 30));
      await tester.pumpWidget(
        _app(
          Builder(
            builder:
                (context) => Scaffold(
                  body: TextButton(
                    onPressed:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => StoryEditorScreen(
                                  data: completedRun(),
                                  photoPicker: picker,
                                  decodePhoto: (_) async => image,
                                ),
                          ),
                        ),
                    child: const Text('open'),
                  ),
                ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Gallery'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('Discard this story?'), findsOneWidget);
      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();
      expect(find.byType(StoryEditorScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();
      expect(find.byType(StoryEditorScreen), findsNothing);
      expect(picker.discarded, ['/tmp/photo.jpg']);
    });
  });

  group('template screen', () {
    testWidgets('lists every preset and opens the editor on the one tapped', (tester) async {
      _phone(tester);
      await tester.pumpWidget(
        _app(StoryTemplateScreen(data: plannedChest(), photoPicker: FakePicker(null))),
      );
      await tester.pumpAndSettle();
      expect(find.text('Choose a layout'), findsOneWidget);
      expect(find.text('Card'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('story-template-card')));
      await tester.pumpAndSettle();
      expect(find.byType(StoryEditorScreen), findsOneWidget);
      expect(tester.widget<StoryEditorScreen>(find.byType(StoryEditorScreen)).templateId, 'card');
    });
  });

  group('export screen', () {
    Future<FakeExportActions> pumpExport(WidgetTester tester, FakeExportActions actions) async {
      _phone(tester);
      final png = await _testPng(tester);
      await tester.pumpWidget(_app(StoryExportScreen(png: png, actions: actions)));
      await tester.pumpAndSettle();
      return actions;
    }

    testWidgets('saves to the gallery and says so', (tester) async {
      final actions = await pumpExport(tester, FakeExportActions());
      await tester.tap(find.byKey(const ValueKey('story-save')));
      await tester.pumpAndSettle();
      expect(actions.saved.single.length, greaterThan(0));
      expect(find.text('Saved to your gallery'), findsOneWidget);
    });

    testWidgets('explains a denied gallery permission', (tester) async {
      final actions = await pumpExport(tester, FakeExportActions()..save = StorySaveOutcome.denied);
      await tester.tap(find.byKey(const ValueKey('story-save')));
      await tester.pumpAndSettle();
      expect(find.text('Allow photo access in Settings to save your story.'), findsOneWidget);
      expect(actions.saved, hasLength(1));
    });

    testWidgets('a failed save shows an error, not a crash', (tester) async {
      await pumpExport(tester, FakeExportActions()..error = Exception('disk'));
      await tester.tap(find.byKey(const ValueKey('story-save')));
      await tester.pumpAndSettle();
      expect(find.textContaining("Couldn't save the image."), findsOneWidget);
    });

    testWidgets('a dismissed share sheet is quiet', (tester) async {
      final actions = await pumpExport(
        tester,
        FakeExportActions()..shareOutcome = StoryShareOutcome.dismissed,
      );
      await tester.tap(find.text('Share'));
      await tester.pumpAndSettle();
      expect(actions.shared, hasLength(1));
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('an unavailable share sheet is explained', (tester) async {
      final actions = await pumpExport(
        tester,
        FakeExportActions()..shareOutcome = StoryShareOutcome.unavailable,
      );
      await tester.tap(find.text('Share'));
      await tester.pumpAndSettle();
      expect(find.text("Sharing isn't available on this device."), findsOneWidget);
      expect(actions.shared, hasLength(1));
    });

    testWidgets('a failed share shows an error', (tester) async {
      await pumpExport(tester, FakeExportActions()..error = Exception('boom'));
      await tester.tap(find.text('Share'));
      await tester.pumpAndSettle();
      expect(find.textContaining("Couldn't share the image."), findsOneWidget);
    });

    testWidgets('cleans up its temporary files when closed', (tester) async {
      final actions = await pumpExport(tester, FakeExportActions());
      await tester.pumpWidget(_app(const SizedBox()));
      expect(actions.disposed, isTrue);
    });
  });
}
