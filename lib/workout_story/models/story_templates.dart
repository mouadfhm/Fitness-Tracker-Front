import 'dart:ui' show Rect;

import '../story_labels.dart';
import 'story_document.dart';
import 'story_workout_data.dart';

/// A curated starting design: a layout plus where its text and stats sit.
class StoryTemplate {
  const StoryTemplate({
    required this.id,
    required this.layout,
    required this.photoFrame,
    this.panelFrame,
    this.photoRadius = 0,
    this.dim = 0,
    this.gradient = 0.6,
    this.maxDefaultStats = 3,
    required this.status,
    required this.title,
    required this.date,
    required this.stats,
    required this.brand,
  });

  final String id;
  final StoryLayoutKind layout;
  final Rect photoFrame;
  final Rect? panelFrame;
  final double photoRadius;
  final double dim;
  final double gradient;
  final int maxDefaultStats;

  /// Where each standard layer goes (only position, width and style are
  /// read from these; the words come from the workout).
  final StoryLayer status;
  final StoryLayer title;
  final StoryLayer date;
  final StoryLayer stats;
  final StoryLayer brand;
}

/// Ids of the layers every template starts with. A user's own text is kept
/// under these ids when they switch templates.
abstract final class StoryLayerIds {
  static const status = 'status';
  static const title = 'title';
  static const date = 'date';
  static const stats = 'stats';
  static const brand = 'brand';

  static const standard = {status, title, date, stats, brand};
}

const _status = StoryTextStyle(
  font: StoryFont.body,
  fontSize: 34,
  weight: 700,
  color: StoryColorRole.accent,
  letterSpacing: 6,
  uppercase: true,
);
const _title = StoryTextStyle(fontSize: 136, weight: 900, lineHeight: 0.92, uppercase: true);
const _date = StoryTextStyle(
  font: StoryFont.body,
  fontSize: 34,
  weight: 500,
  color: StoryColorRole.gray,
  letterSpacing: 3,
  uppercase: true,
);
const _stats = StoryTextStyle(fontSize: 96, weight: 900, color: StoryColorRole.accent);
const _brand = StoryTextStyle(
  font: StoryFont.body,
  fontSize: 26,
  weight: 700,
  color: StoryColorRole.white,
  letterSpacing: 5,
  uppercase: true,
);

StoryLayer _l(
  String id,
  StoryLayerType type,
  double cy,
  StoryTextStyle style, {
  double cx = 0.5,
  double width = 0.86,
}) => StoryLayer(id: id, type: type, cx: cx, cy: cy, width: width, style: style);

StoryLayer _text(
  String id,
  double cy,
  StoryTextStyle style, {
  double cx = 0.5,
  double width = 0.86,
}) => _l(id, StoryLayerType.text, cy, style, cx: cx, width: width);

abstract final class StoryTemplates {
  static const defaultId = 'full_bold';

  static final all = <StoryTemplate>[
    // Full photo, big title low on the frame over a strong gradient.
    StoryTemplate(
      id: 'full_bold',
      layout: StoryLayoutKind.fullPhoto,
      photoFrame: const Rect.fromLTWH(0, 0, 1, 1),
      dim: 0.08,
      gradient: 0.8,
      status: _text(StoryLayerIds.status, 0.585, _status),
      title: _text(StoryLayerIds.title, 0.665, _title),
      date: _text(StoryLayerIds.date, 0.745, _date),
      stats: _l(StoryLayerIds.stats, StoryLayerType.stats, 0.855, _stats),
      brand: _l(StoryLayerIds.brand, StoryLayerType.brand, 0.045, _brand),
    ),
    // Full photo, everything centred over an even veil.
    StoryTemplate(
      id: 'full_center',
      layout: StoryLayoutKind.fullPhoto,
      photoFrame: const Rect.fromLTWH(0, 0, 1, 1),
      dim: 0.4,
      gradient: 0.35,
      status: _text(StoryLayerIds.status, 0.37, _status.copyWith(align: StoryAlign.center)),
      title: _text(
        StoryLayerIds.title,
        0.45,
        _title.copyWith(align: StoryAlign.center, fontSize: 150),
      ),
      date: _text(StoryLayerIds.date, 0.535, _date.copyWith(align: StoryAlign.center)),
      stats: _l(
        StoryLayerIds.stats,
        StoryLayerType.stats,
        0.8,
        _stats.copyWith(align: StoryAlign.center),
      ),
      brand: _l(
        StoryLayerIds.brand,
        StoryLayerType.brand,
        0.95,
        _brand.copyWith(align: StoryAlign.center),
      ),
    ),
    // Full photo, the photo leads: a small title at the top, two stats low.
    StoryTemplate(
      id: 'full_minimal',
      layout: StoryLayoutKind.fullPhoto,
      photoFrame: const Rect.fromLTWH(0, 0, 1, 1),
      gradient: 0.6,
      maxDefaultStats: 2,
      status: _text(StoryLayerIds.status, 0.075, _status.copyWith(fontSize: 30)),
      title: _text(StoryLayerIds.title, 0.13, _title.copyWith(fontSize: 92, shadow: true)),
      date: _text(StoryLayerIds.date, 0.79, _date),
      stats: _l(
        StoryLayerIds.stats,
        StoryLayerType.stats,
        0.865,
        _stats.copyWith(fontSize: 84, color: StoryColorRole.white),
      ),
      brand: _l(
        StoryLayerIds.brand,
        StoryLayerType.brand,
        0.955,
        _brand.copyWith(align: StoryAlign.end),
      ),
    ),
    // Photo on top, stats panel below.
    StoryTemplate(
      id: 'panel_bottom',
      layout: StoryLayoutKind.photoPanel,
      photoFrame: const Rect.fromLTWH(0, 0, 1, 0.62),
      panelFrame: const Rect.fromLTWH(0, 0.62, 1, 0.38),
      gradient: 0.5,
      status: _text(StoryLayerIds.status, 0.665, _status),
      title: _text(StoryLayerIds.title, 0.725, _title.copyWith(fontSize: 112)),
      date: _text(StoryLayerIds.date, 0.785, _date),
      stats: _l(StoryLayerIds.stats, StoryLayerType.stats, 0.87, _stats.copyWith(fontSize: 84)),
      brand: _l(StoryLayerIds.brand, StoryLayerType.brand, 0.045, _brand),
    ),
    // Stats panel on top, photo below.
    StoryTemplate(
      id: 'panel_top',
      layout: StoryLayoutKind.photoPanel,
      photoFrame: const Rect.fromLTWH(0, 0.36, 1, 0.64),
      panelFrame: const Rect.fromLTWH(0, 0, 1, 0.36),
      gradient: 0.5,
      status: _text(StoryLayerIds.status, 0.055, _status),
      title: _text(StoryLayerIds.title, 0.115, _title.copyWith(fontSize: 112)),
      date: _text(StoryLayerIds.date, 0.175, _date),
      stats: _l(StoryLayerIds.stats, StoryLayerType.stats, 0.265, _stats.copyWith(fontSize: 84)),
      brand: _l(StoryLayerIds.brand, StoryLayerType.brand, 0.955, _brand),
    ),
    // A rounded photo card on a dark page, details underneath.
    StoryTemplate(
      id: 'card',
      layout: StoryLayoutKind.photoPanel,
      photoFrame: const Rect.fromLTWH(0.06, 0.035, 0.88, 0.6),
      panelFrame: const Rect.fromLTWH(0, 0, 1, 1),
      photoRadius: 44,
      gradient: 0.3,
      status: _text(StoryLayerIds.status, 0.68, _status),
      title: _text(StoryLayerIds.title, 0.74, _title.copyWith(fontSize: 108)),
      date: _text(StoryLayerIds.date, 0.8, _date),
      stats: _l(StoryLayerIds.stats, StoryLayerType.stats, 0.88, _stats.copyWith(fontSize: 80)),
      brand: _l(StoryLayerIds.brand, StoryLayerType.brand, 0.965, _brand),
    ),
  ];

  static StoryTemplate byId(String id) =>
      all.firstWhere((t) => t.id == id, orElse: () => all.first);

  /// The stats a new story shows: a completed workout leads with what was
  /// done (time, calories), a plan with what it contains.
  static List<StoryStatSetting> defaultStats(StoryWorkoutData data, int max) {
    final order =
        data.isPlanned
            ? const [
              StoryStatKind.exercises,
              StoryStatKind.sets,
              StoryStatKind.duration,
              StoryStatKind.reps,
              StoryStatKind.calories,
            ]
            : const [
              StoryStatKind.duration,
              StoryStatKind.calories,
              StoryStatKind.exercises,
              StoryStatKind.sets,
              StoryStatKind.reps,
            ];
    final available = [
      for (final k in order)
        if (data.value(k) != null) k,
    ];
    return [
      for (var i = 0; i < available.length; i++) StoryStatSetting(available[i], visible: i < max),
    ];
  }

  /// A fresh document for template [id] and [data].
  ///
  /// With [carry], the story being edited, the switch keeps what the user
  /// chose rather than what the template suggests: the photo (re-centred,
  /// since the frame changes), accent, branding, which stats show and in what
  /// order, the words of the standard text layers and any layers they added.
  static StoryDocument build(
    String id,
    StoryWorkoutData data,
    StoryLabels labels, {
    StoryDocument? carry,
  }) {
    final t = byId(id);
    String textOf(String layerId, String fallback) => carry?.layer(layerId)?.text ?? fallback;

    final layers = <StoryLayer>[
      t.status.copyWith(text: textOf(StoryLayerIds.status, labels.status(data))),
      t.title.copyWith(text: textOf(StoryLayerIds.title, data.title)),
      if (data.date != null || carry?.layer(StoryLayerIds.date) != null)
        t.date.copyWith(
          text: textOf(StoryLayerIds.date, data.date == null ? '' : labels.date(data.date!)),
        ),
      if (data.availableStats.isNotEmpty) t.stats,
      if (carry != null)
        for (final l in carry.layers)
          if (!StoryLayerIds.standard.contains(l.id)) l,
      t.brand,
    ];

    return StoryDocument(
      templateId: t.id,
      layout: t.layout,
      photoFrame: t.photoFrame,
      panelFrame: t.panelFrame,
      photoRadius: t.photoRadius,
      photoPath: carry?.photoPath,
      dim: t.dim,
      gradient: t.gradient,
      paletteId: carry?.paletteId ?? 'lime',
      branding: carry?.branding ?? true,
      stats: carry?.stats ?? defaultStats(data, t.maxDefaultStats),
      layers: layers,
    );
  }
}
