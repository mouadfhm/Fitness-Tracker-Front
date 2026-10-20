import 'dart:math' as math;
import 'dart:ui' show Rect;

import 'story_workout_data.dart';

/// The design canvas every story is laid out on, in pixels. The editor draws
/// the same composition scaled down; the export draws it at this size.
const double kStoryWidth = 1080;
const double kStoryHeight = 1920;

enum StoryLayoutKind { fullPhoto, photoPanel }

enum StoryLayerType { text, stats, brand }

/// Text colours come from a few roles rather than free colours so a palette
/// change recolours every accent at once.
enum StoryColorRole { white, gray, accent, dark }

enum StoryFont { display, body }

enum StoryAlign { start, center, end }

/// How a text, stats or brand layer looks. [fontSize] and [letterSpacing]
/// are in canvas pixels (of [kStoryWidth]).
class StoryTextStyle {
  const StoryTextStyle({
    this.font = StoryFont.display,
    this.fontSize = 64,
    this.weight = 700,
    this.align = StoryAlign.start,
    this.color = StoryColorRole.white,
    this.letterSpacing = 0,
    this.lineHeight = 1.05,
    this.uppercase = false,
    this.shadow = false,
  });

  final StoryFont font;
  final double fontSize;

  /// One of [weights].
  final int weight;
  final StoryAlign align;
  final StoryColorRole color;
  final double letterSpacing;
  final double lineHeight;
  final bool uppercase;

  /// A soft shadow under the text, for text over a photo.
  final bool shadow;

  /// The weights bundled for both story fonts.
  static const weights = [400, 500, 700, 900];

  StoryTextStyle copyWith({
    StoryFont? font,
    double? fontSize,
    int? weight,
    StoryAlign? align,
    StoryColorRole? color,
    double? letterSpacing,
    double? lineHeight,
    bool? uppercase,
    bool? shadow,
  }) => StoryTextStyle(
    font: font ?? this.font,
    fontSize: fontSize ?? this.fontSize,
    weight: weight ?? this.weight,
    align: align ?? this.align,
    color: color ?? this.color,
    letterSpacing: letterSpacing ?? this.letterSpacing,
    lineHeight: lineHeight ?? this.lineHeight,
    uppercase: uppercase ?? this.uppercase,
    shadow: shadow ?? this.shadow,
  );

  Map<String, dynamic> toJson() => {
    'font': font.name,
    'font_size': fontSize,
    'weight': weight,
    'align': align.name,
    'color': color.name,
    'letter_spacing': letterSpacing,
    'line_height': lineHeight,
    'uppercase': uppercase,
    'shadow': shadow,
  };

  factory StoryTextStyle.fromJson(Map json) => StoryTextStyle(
    font: _enum(StoryFont.values, json['font'], StoryFont.display),
    fontSize: _num(json['font_size'], 64),
    weight: _num(json['weight'], 700).round(),
    align: _enum(StoryAlign.values, json['align'], StoryAlign.start),
    color: _enum(StoryColorRole.values, json['color'], StoryColorRole.white),
    letterSpacing: _num(json['letter_spacing'], 0),
    lineHeight: _num(json['line_height'], 1.05),
    uppercase: json['uppercase'] == true,
    shadow: json['shadow'] == true,
  );
}

/// One movable element of a story. Its place is normalized to the canvas:
/// ([cx], [cy]) is its centre as a fraction of the canvas width and height,
/// [width] its box width as a fraction of the canvas width (text wraps to
/// it). [scale] and [rotation] (radians) apply around the centre. A layer's
/// place in [StoryDocument.layers] is its z-order, first at the back.
class StoryLayer {
  const StoryLayer({
    required this.id,
    required this.type,
    required this.cx,
    required this.cy,
    required this.width,
    this.rotation = 0,
    this.scale = 1,
    this.visible = true,
    this.locked = false,
    this.text = '',
    this.style = const StoryTextStyle(),
  });

  final String id;
  final StoryLayerType type;
  final double cx;
  final double cy;
  final double width;
  final double rotation;
  final double scale;
  final bool visible;
  final bool locked;

  /// The words of a text layer. Stats and brand layers draw their own.
  final String text;
  final StoryTextStyle style;

  static const double minScale = 0.25;
  static const double maxScale = 5;
  static const double minWidth = 0.12;
  static const double maxWidth = 1.2;

  bool get isEditableText => type == StoryLayerType.text;

  StoryLayer copyWith({
    String? id,
    double? cx,
    double? cy,
    double? width,
    double? rotation,
    double? scale,
    bool? visible,
    bool? locked,
    String? text,
    StoryTextStyle? style,
  }) => StoryLayer(
    id: id ?? this.id,
    type: type,
    cx: cx ?? this.cx,
    cy: cy ?? this.cy,
    width: (width ?? this.width).clamp(minWidth, maxWidth),
    rotation: rotation ?? this.rotation,
    scale: (scale ?? this.scale).clamp(minScale, maxScale),
    visible: visible ?? this.visible,
    locked: locked ?? this.locked,
    text: text ?? this.text,
    style: style ?? this.style,
  );

  /// Moved by a fraction of the canvas, kept with its centre on the canvas
  /// so it can't be lost off an edge.
  StoryLayer movedBy(double dx, double dy) =>
      copyWith(cx: (cx + dx).clamp(0.0, 1.0), cy: (cy + dy).clamp(0.0, 1.0));

  /// Rotation snapped to the nearest quarter turn when it is within about
  /// three degrees of it, so text is easy to put back straight.
  static double snapRotation(double r) {
    const quarter = math.pi / 2;
    final nearest = (r / quarter).roundToDouble() * quarter;
    return (r - nearest).abs() < 0.05 ? nearest : r;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'cx': cx,
    'cy': cy,
    'width': width,
    'rotation': rotation,
    'scale': scale,
    'visible': visible,
    'locked': locked,
    'text': text,
    'style': style.toJson(),
  };

  factory StoryLayer.fromJson(Map json) => StoryLayer(
    id: json['id'].toString(),
    type: _enum(StoryLayerType.values, json['type'], StoryLayerType.text),
    cx: _num(json['cx'], 0.5),
    cy: _num(json['cy'], 0.5),
    width: _num(json['width'], 0.8),
    rotation: _num(json['rotation'], 0),
    scale: _num(json['scale'], 1),
    visible: json['visible'] != false,
    locked: json['locked'] == true,
    text: json['text']?.toString() ?? '',
    style: json['style'] is Map ? StoryTextStyle.fromJson(json['style']) : const StoryTextStyle(),
  );
}

/// Zoom and pan of the photo inside its frame. [scale] 1 is the smallest
/// size that covers the frame ("cover"); [dx] and [dy] move the photo's
/// centre from the frame's centre, as a fraction of the frame size. Values
/// are kept inside what still covers the frame, so the photo is cropped,
/// never stretched or letterboxed.
class PhotoTransform {
  const PhotoTransform({this.scale = 1, this.dx = 0, this.dy = 0});

  final double scale;
  final double dx;
  final double dy;

  static const identity = PhotoTransform();
  static const double maxScale = 5;

  bool get isIdentity => scale == 1 && dx == 0 && dy == 0;

  /// The photo's size, in canvas pixels, when it fills [frame] at [scale].
  static (double, double) drawnSize(double imageW, double imageH, Rect frame, double scale) {
    final cover = math.max(frame.width / imageW, frame.height / imageH);
    return (imageW * cover * scale, imageH * cover * scale);
  }

  /// This transform kept to what still covers [frame] with an image of
  /// [imageW]×[imageH].
  PhotoTransform clamped(double imageW, double imageH, Rect frame) {
    final s = scale.clamp(1.0, maxScale);
    final (w, h) = drawnSize(imageW, imageH, frame, s);
    final maxDx = (w - frame.width) / 2 / frame.width;
    final maxDy = (h - frame.height) / 2 / frame.height;
    return PhotoTransform(scale: s, dx: dx.clamp(-maxDx, maxDx), dy: dy.clamp(-maxDy, maxDy));
  }

  /// Where the photo is drawn, in canvas pixels.
  Rect destination(double imageW, double imageH, Rect frame) {
    final t = clamped(imageW, imageH, frame);
    final (w, h) = drawnSize(imageW, imageH, frame, t.scale);
    final center = frame.center.translate(t.dx * frame.width, t.dy * frame.height);
    return Rect.fromCenter(center: center, width: w, height: h);
  }

  @override
  bool operator ==(Object other) =>
      other is PhotoTransform && other.scale == scale && other.dx == dx && other.dy == dy;

  @override
  int get hashCode => Object.hash(scale, dx, dy);

  Map<String, dynamic> toJson() => {'scale': scale, 'dx': dx, 'dy': dy};

  factory PhotoTransform.fromJson(Map json) => PhotoTransform(
    scale: _num(json['scale'], 1),
    dx: _num(json['dx'], 0),
    dy: _num(json['dy'], 0),
  );
}

/// A statistic and whether it is shown; the list order is the order shown.
class StoryStatSetting {
  const StoryStatSetting(this.kind, {this.visible = true});

  final StoryStatKind kind;
  final bool visible;

  Map<String, dynamic> toJson() => {'kind': kind.name, 'visible': visible};
}

/// The whole story composition: the single source of truth that the editor
/// draws, the history stores and the exporter renders. Immutable; every edit
/// makes a new document.
///
/// It holds no workout record, only what was read from it, and no image,
/// only the path of the photo the user picked. [toJson] carries a
/// [schemaVersion] so a saved draft can be read by later versions.
class StoryDocument {
  const StoryDocument({
    required this.templateId,
    required this.layout,
    required this.photoFrame,
    this.panelFrame,
    this.photoRadius = 0,
    this.photoPath,
    this.photoTransform = PhotoTransform.identity,
    this.dim = 0,
    this.gradient = 0.6,
    this.paletteId = 'lime',
    this.branding = true,
    this.stats = const [],
    this.layers = const [],
  });

  static const int schemaVersion = 1;

  final String templateId;
  final StoryLayoutKind layout;

  /// Where the photo sits, as fractions of the canvas.
  final Rect photoFrame;

  /// The stats panel of a photo + panel layout, as fractions of the canvas.
  final Rect? panelFrame;

  /// Corner radius of the photo frame, in canvas pixels.
  final double photoRadius;
  final String? photoPath;
  final PhotoTransform photoTransform;

  /// 0–1: a dark veil over the whole photo.
  final double dim;

  /// 0–1: strength of the dark gradient that keeps text readable.
  final double gradient;
  final String paletteId;
  final bool branding;
  final List<StoryStatSetting> stats;
  final List<StoryLayer> layers;

  List<StoryStatKind> get visibleStats => [
    for (final s in stats)
      if (s.visible) s.kind,
  ];

  StoryLayer? layer(String? id) {
    for (final l in layers) {
      if (l.id == id) return l;
    }
    return null;
  }

  Rect photoFrameIn(double w, double h) => _scaleRect(photoFrame, w, h);
  Rect? panelFrameIn(double w, double h) =>
      panelFrame == null ? null : _scaleRect(panelFrame!, w, h);

  static Rect _scaleRect(Rect r, double w, double h) =>
      Rect.fromLTWH(r.left * w, r.top * h, r.width * w, r.height * h);

  StoryDocument copyWith({
    String? templateId,
    String? photoPath,
    bool clearPhoto = false,
    PhotoTransform? photoTransform,
    double? dim,
    double? gradient,
    String? paletteId,
    bool? branding,
    List<StoryStatSetting>? stats,
    List<StoryLayer>? layers,
  }) => StoryDocument(
    templateId: templateId ?? this.templateId,
    layout: layout,
    photoFrame: photoFrame,
    panelFrame: panelFrame,
    photoRadius: photoRadius,
    photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
    photoTransform: clearPhoto ? PhotoTransform.identity : (photoTransform ?? this.photoTransform),
    dim: (dim ?? this.dim).clamp(0.0, 1.0),
    gradient: (gradient ?? this.gradient).clamp(0.0, 1.0),
    paletteId: paletteId ?? this.paletteId,
    branding: branding ?? this.branding,
    stats: stats ?? this.stats,
    layers: layers ?? this.layers,
  );

  StoryDocument replaceLayer(StoryLayer layer) =>
      copyWith(layers: [for (final l in layers) l.id == layer.id ? layer : l]);

  Map<String, dynamic> toJson() => {
    'version': schemaVersion,
    'template_id': templateId,
    'layout': layout.name,
    'photo_frame': _rectJson(photoFrame),
    'panel_frame': panelFrame == null ? null : _rectJson(panelFrame!),
    'photo_radius': photoRadius,
    'photo_path': photoPath,
    'photo_transform': photoTransform.toJson(),
    'dim': dim,
    'gradient': gradient,
    'palette_id': paletteId,
    'branding': branding,
    'stats': [for (final s in stats) s.toJson()],
    'layers': [for (final l in layers) l.toJson()],
  };

  /// Reads a document written by [toJson]. Unknown stats and fields are
  /// skipped so drafts from other versions still open.
  factory StoryDocument.fromJson(Map json) {
    final version = _num(json['version'], 1).round();
    if (version > schemaVersion) {
      throw FormatException('Story document version $version is newer than $schemaVersion');
    }
    return StoryDocument(
      templateId: json['template_id']?.toString() ?? '',
      layout: _enum(StoryLayoutKind.values, json['layout'], StoryLayoutKind.fullPhoto),
      photoFrame: _rectFrom(json['photo_frame']) ?? const Rect.fromLTWH(0, 0, 1, 1),
      panelFrame: _rectFrom(json['panel_frame']),
      photoRadius: _num(json['photo_radius'], 0),
      photoPath: json['photo_path'] as String?,
      photoTransform:
          json['photo_transform'] is Map
              ? PhotoTransform.fromJson(json['photo_transform'])
              : PhotoTransform.identity,
      dim: _num(json['dim'], 0),
      gradient: _num(json['gradient'], 0.6),
      paletteId: json['palette_id']?.toString() ?? 'lime',
      branding: json['branding'] != false,
      stats: [
        for (final s in (json['stats'] as List? ?? const []).whereType<Map>())
          if (StoryStatKind.values.any((k) => k.name == s['kind']))
            StoryStatSetting(
              StoryStatKind.values.byName(s['kind']),
              visible: s['visible'] != false,
            ),
      ],
      layers: [
        for (final l in (json['layers'] as List? ?? const []).whereType<Map>())
          StoryLayer.fromJson(l),
      ],
    );
  }

  static Map<String, double> _rectJson(Rect r) => {
    'l': r.left,
    't': r.top,
    'w': r.width,
    'h': r.height,
  };

  static Rect? _rectFrom(Object? v) =>
      v is Map
          ? Rect.fromLTWH(_num(v['l'], 0), _num(v['t'], 0), _num(v['w'], 1), _num(v['h'], 1))
          : null;
}

double _num(Object? v, double fallback) => v is num ? v.toDouble() : fallback;

T _enum<T extends Enum>(List<T> values, Object? name, T fallback) {
  for (final v in values) {
    if (v.name == name) return v;
  }
  return fallback;
}
