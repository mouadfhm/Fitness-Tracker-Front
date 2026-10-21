import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import '../models/story_document.dart';
import '../models/story_palette.dart';
import '../models/story_workout_data.dart';
import '../story_labels.dart';

/// Everything besides the document that a story needs to be drawn.
class StoryRenderContext {
  const StoryRenderContext({
    required this.data,
    required this.labels,
    this.photo,
    this.logo,
    this.textDirection = TextDirection.ltr,
  });

  final StoryWorkoutData data;
  final StoryLabels labels;

  /// The decoded photo for the document's photo path, if one is loaded.
  final ui.Image? photo;

  /// The app logo drawn before the app name (see [loadStoryLogo]); a dot in
  /// the accent colour stands in until it has loaded.
  final ui.Image? logo;
  final TextDirection textDirection;
}

/// Draws a [StoryDocument] on a [kStoryWidth]×[kStoryHeight] canvas. The
/// editor's live canvas, the template thumbnails and the exported PNG all
/// paint through this one class (scaled by the caller), so text wrapping,
/// fonts, crop and layer order are the same everywhere. It draws no editor
/// UI: selection outlines and handles are drawn by the editor on top.
class StoryRenderer {
  StoryRenderer(this.context);

  final StoryRenderContext context;

  static const Size size = Size(kStoryWidth, kStoryHeight);
  static const _displayFamily = 'BarlowCondensed';
  static const _bodyFamily = 'Barlow';

  /// Laid-out text per layer object. Layers are immutable, so an identical
  /// object always lays out the same; the stats key also covers the
  /// document-level inputs that change them.
  final Expando<_Laid> _cache = Expando();

  void paint(Canvas canvas, StoryDocument doc) {
    paintBackground(canvas, doc);
    paintLayers(canvas, doc);
  }

  // ---------------------------------------------------------------- background

  void paintBackground(Canvas canvas, StoryDocument doc) {
    final palette = StoryPalette.byId(doc.paletteId);
    final full = Offset.zero & size;
    canvas.drawRect(full, Paint()..color = StoryPalette.base);

    final panel = doc.panelFrameIn(size.width, size.height);
    if (panel != null) {
      canvas.drawRect(
        panel,
        Paint()
          ..shader = ui.Gradient.linear(panel.topCenter, panel.bottomCenter, [
            palette.panelTop,
            palette.panelBottom,
          ]),
      );
    }

    final frame = doc.photoFrameIn(size.width, size.height);
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(frame, Radius.circular(doc.photoRadius)));
    final photo = context.photo;
    if (photo != null) {
      final w = photo.width.toDouble(), h = photo.height.toDouble();
      canvas.drawImageRect(
        photo,
        Rect.fromLTWH(0, 0, w, h),
        doc.photoTransform.destination(w, h, frame),
        Paint()..filterQuality = FilterQuality.high,
      );
    } else {
      // No photo yet: a quiet charcoal fill keeps the layout readable.
      canvas.drawRect(
        frame,
        Paint()
          ..shader = ui.Gradient.linear(frame.topLeft, frame.bottomRight, const [
            Color(0xFF2A2D33),
            Color(0xFF131417),
          ]),
      );
    }
    if (doc.dim > 0) {
      canvas.drawRect(
        frame,
        Paint()..color = const Color(0xFF000000).withValues(alpha: doc.dim * 0.75),
      );
    }
    _paintGradient(canvas, doc, frame, panel, palette);
    canvas.restore();
  }

  void _paintGradient(
    Canvas canvas,
    StoryDocument doc,
    Rect frame,
    Rect? panel,
    StoryPalette palette,
  ) {
    final g = doc.gradient;
    if (g <= 0) return;
    const black = Color(0xFF000000);
    void fade(Offset from, Offset to, Color color, double alpha) {
      // The band spans the frame's width between the two heights.
      final rect = Rect.fromLTRB(
        frame.left,
        math.min(from.dy, to.dy),
        frame.right,
        math.max(from.dy, to.dy),
      );
      canvas.drawRect(
        rect.intersect(frame),
        Paint()
          ..shader = ui.Gradient.linear(from, to, [
            color.withValues(alpha: 0),
            color.withValues(alpha: alpha.clamp(0.0, 1.0)),
          ]),
      );
    }

    if (doc.layout == StoryLayoutKind.fullPhoto || panel == null || panel.contains(frame.center)) {
      // Readability at the bottom, a lighter touch at the top.
      fade(
        Offset(frame.center.dx, frame.top + frame.height * 0.3),
        frame.bottomCenter,
        black,
        0.95 * g,
      );
      fade(
        Offset(frame.center.dx, frame.top + frame.height * 0.2),
        frame.topCenter,
        black,
        0.55 * g,
      );
    } else if (panel.top >= frame.center.dy) {
      // Panel below: melt the photo's bottom edge into it.
      fade(
        Offset(frame.center.dx, frame.bottom - frame.height * 0.4),
        frame.bottomCenter,
        palette.panelTop,
        g,
      );
      fade(
        Offset(frame.center.dx, frame.top + frame.height * 0.18),
        frame.topCenter,
        black,
        0.5 * g,
      );
    } else {
      fade(
        Offset(frame.center.dx, frame.top + frame.height * 0.4),
        frame.topCenter,
        palette.panelBottom,
        g,
      );
      fade(
        Offset(frame.center.dx, frame.bottom - frame.height * 0.22),
        frame.bottomCenter,
        black,
        0.6 * g,
      );
    }
  }

  // -------------------------------------------------------------------- layers

  void paintLayers(Canvas canvas, StoryDocument doc) {
    for (final layer in doc.layers) {
      if (!isDrawn(layer, doc)) continue;
      final laid = _layout(layer, doc);
      canvas.save();
      canvas.translate(layer.cx * size.width, layer.cy * size.height);
      canvas.rotate(layer.rotation);
      canvas.scale(layer.scale);
      canvas.translate(-laid.size.width / 2, -laid.size.height / 2);
      laid.paint(canvas);
      canvas.restore();
    }
  }

  /// Whether [layer] shows in the image (hidden layers, branding turned off
  /// and stats with nothing to show are skipped).
  bool isDrawn(StoryLayer layer, StoryDocument doc) {
    if (!layer.visible) return false;
    if (layer.type == StoryLayerType.brand && !doc.branding) return false;
    if (layer.type == StoryLayerType.stats && _statItems(doc).isEmpty) return false;
    return true;
  }

  /// The layer's box before its scale and rotation, in canvas pixels.
  Size layerSize(StoryLayer layer, StoryDocument doc) => _layout(layer, doc).size;

  /// The topmost drawn layer under [point] (canvas pixels), or null.
  /// [slop] widens each box a little so thin text is easy to grab.
  StoryLayer? hitTest(StoryDocument doc, Offset point, {double slop = 24}) {
    for (final layer in doc.layers.reversed) {
      if (!isDrawn(layer, doc)) continue;
      final s = layerSize(layer, doc);
      final local = toLayerLocal(layer, point);
      final pad = slop / layer.scale;
      if (local.dx.abs() <= s.width / 2 + pad && local.dy.abs() <= s.height / 2 + pad) {
        return layer;
      }
    }
    return null;
  }

  /// [point] (canvas pixels) in the layer's own unscaled, unrotated frame,
  /// centred on the layer.
  static Offset toLayerLocal(StoryLayer layer, Offset point) {
    final d = point - Offset(layer.cx * size.width, layer.cy * size.height);
    final c = math.cos(-layer.rotation), s = math.sin(-layer.rotation);
    return Offset(d.dx * c - d.dy * s, d.dx * s + d.dy * c) / layer.scale;
  }

  /// A point in the layer's local frame back on the canvas.
  static Offset fromLayerLocal(StoryLayer layer, Offset local) {
    final p = local * layer.scale;
    final c = math.cos(layer.rotation), s = math.sin(layer.rotation);
    return Offset(p.dx * c - p.dy * s, p.dx * s + p.dy * c) +
        Offset(layer.cx * size.width, layer.cy * size.height);
  }

  /// The four corners of the layer on the canvas: top-left, top-right,
  /// bottom-right, bottom-left.
  List<Offset> corners(StoryLayer layer, StoryDocument doc) {
    final s = layerSize(layer, doc);
    final hw = s.width / 2, hh = s.height / 2;
    return [
      for (final p in [Offset(-hw, -hh), Offset(hw, -hh), Offset(hw, hh), Offset(-hw, hh)])
        fromLayerLocal(layer, p),
    ];
  }

  // -------------------------------------------------------------------- layout

  _Laid _layout(StoryLayer layer, StoryDocument doc) {
    final key = (doc.paletteId, doc.stats, context.labels.localeName);
    final cached = _cache[layer];
    if (cached != null && cached.key == key) return cached;
    final palette = StoryPalette.byId(doc.paletteId);
    final laid = switch (layer.type) {
      StoryLayerType.text => _layoutText(layer, palette),
      StoryLayerType.stats => _layoutStats(layer, doc, palette),
      StoryLayerType.brand => _layoutBrand(layer, palette),
    }..key = key;
    _cache[layer] = laid;
    return laid;
  }

  TextStyle _style(StoryTextStyle s, Color color, {double? fontSize}) => TextStyle(
    fontFamily: s.font == StoryFont.display ? _displayFamily : _bodyFamily,
    fontSize: fontSize ?? s.fontSize,
    fontWeight: _weight(s.weight),
    letterSpacing: s.letterSpacing,
    height: s.lineHeight,
    color: color,
    shadows:
        s.shadow
            ? const [Shadow(color: Color(0x73000000), blurRadius: 18, offset: Offset(0, 4))]
            : null,
  );

  static FontWeight _weight(int w) =>
      FontWeight.values[((w / 100).round() - 1).clamp(0, FontWeight.values.length - 1)];

  TextAlign _align(StoryAlign a) => switch (a) {
    StoryAlign.start => TextAlign.start,
    StoryAlign.center => TextAlign.center,
    StoryAlign.end => TextAlign.end,
  };

  TextPainter _painter(
    String text,
    TextStyle style,
    TextAlign align,
    double width, {
    int? maxLines,
  }) {
    final p = TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: align,
      textDirection: context.textDirection,
      maxLines: maxLines,
      ellipsis: maxLines == null ? null : '…',
    );
    p.layout(minWidth: width, maxWidth: width);
    return p;
  }

  String _caseOf(String text, StoryTextStyle s) => s.uppercase ? text.toUpperCase() : text;

  _Laid _layoutText(StoryLayer layer, StoryPalette palette) {
    final width = layer.width * size.width;
    final s = layer.style;
    final p = _painter(
      _caseOf(layer.text, s),
      _style(s, palette.resolve(s.color)),
      _align(s.align),
      width,
    );
    // An empty layer keeps one line's height so it can still be tapped.
    final h = math.max(p.height, s.fontSize * s.lineHeight);
    return _Laid(Size(width, h), (c) => p.paint(c, Offset.zero));
  }

  _Laid _layoutBrand(StoryLayer layer, StoryPalette palette) {
    final width = layer.width * size.width;
    final s = layer.style;
    final logo = context.logo;
    if (logo == null) {
      final p = TextPainter(
        text: TextSpan(
          children: [
            TextSpan(text: '● ', style: _style(s, palette.accent)),
            TextSpan(
              text: _caseOf(context.labels.brand, s),
              style: _style(s, palette.resolve(s.color)),
            ),
          ],
        ),
        textAlign: _align(s.align),
        textDirection: context.textDirection,
        maxLines: 1,
      )..layout(minWidth: width, maxWidth: width);
      return _Laid(Size(width, p.height), (c) => p.paint(c, Offset.zero));
    }

    // The logo sits before the name, a little taller than its capitals.
    final logoHeight = s.fontSize * 2.2;
    final logoWidth = logoHeight * logo.width / logo.height;
    final gap = s.fontSize * 0.5;
    final p = TextPainter(
      text: TextSpan(
        text: _caseOf(context.labels.brand, s),
        style: _style(s, palette.resolve(s.color)),
      ),
      textDirection: context.textDirection,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: math.max(0, width - logoWidth - gap));
    final height = math.max(logoHeight, p.height);
    final total = logoWidth + gap + p.width;
    final rtl = context.textDirection == TextDirection.rtl;
    final left = switch (s.align) {
      StoryAlign.center => (width - total) / 2,
      StoryAlign.start => rtl ? width - total : 0.0,
      StoryAlign.end => rtl ? 0.0 : width - total,
    };
    final logoLeft = rtl ? left + total - logoWidth : left;
    final textLeft = rtl ? left : left + logoWidth + gap;
    return _Laid(Size(width, height), (c) {
      c.drawImageRect(
        logo,
        Rect.fromLTWH(0, 0, logo.width.toDouble(), logo.height.toDouble()),
        Rect.fromLTWH(logoLeft, (height - logoHeight) / 2, logoWidth, logoHeight),
        Paint()..filterQuality = FilterQuality.medium,
      );
      p.paint(c, Offset(textLeft, (height - p.height) / 2));
    });
  }

  List<(String, String)> _statItems(StoryDocument doc) {
    final data = context.data;
    final labels = context.labels;
    return [
      for (final kind in doc.visibleStats)
        if (labels.statValue(data, kind) case final value?)
          (value, labels.statLabel(kind, estimate: data.isEstimate(kind))),
    ];
  }

  /// The stats block: up to three columns of a big value over a small label,
  /// with a "the plan" caption above for planned workouts so their numbers
  /// never read as results.
  _Laid _layoutStats(StoryLayer layer, StoryDocument doc, StoryPalette palette) {
    final width = layer.width * size.width;
    final s = layer.style;
    final items = _statItems(doc);
    if (items.isEmpty) return _Laid(Size(width, s.fontSize), (_) {});

    final align = _align(s.align);
    final columns = math.min(items.length, 3);
    final cellW = width / columns;
    final labelStyle = StoryTextStyle(
      font: StoryFont.body,
      fontSize: s.fontSize * 0.27,
      weight: 700,
      letterSpacing: s.fontSize * 0.03,
      lineHeight: 1.15,
      uppercase: true,
      shadow: s.shadow,
    );
    final ops = <void Function(Canvas)>[];
    var y = 0.0;

    if (context.data.isPlanned) {
      final caption = _painter(
        _caseOf(context.labels.planCaption, labelStyle),
        _style(labelStyle, palette.accent),
        align,
        width,
        maxLines: 1,
      );
      final top = y;
      ops.add((c) => caption.paint(c, Offset(0, top)));
      y += caption.height + s.fontSize * 0.12;
    }

    final cellGap = s.fontSize * 0.08;
    for (var row = 0; row * columns < items.length; row++) {
      final rowItems = items.skip(row * columns).take(columns).toList();
      var rowH = 0.0;
      final rowOps = <(TextPainter, TextPainter, double)>[];
      for (var i = 0; i < rowItems.length; i++) {
        final (value, label) = rowItems[i];
        // A long value shrinks to its cell instead of wrapping.
        var fontSize = s.fontSize;
        final probe = TextPainter(
          text: TextSpan(text: value, style: _style(s, palette.resolve(s.color))),
          textDirection: context.textDirection,
          maxLines: 1,
        )..layout();
        final room = cellW - cellGap;
        if (probe.width > room && probe.width > 0) fontSize *= room / probe.width;
        final v = _painter(
          value,
          _style(s.copyWith(lineHeight: 1), palette.resolve(s.color), fontSize: fontSize),
          align,
          room,
          maxLines: 1,
        );
        final l = _painter(
          _caseOf(label, labelStyle),
          _style(labelStyle, StoryPalette.gray),
          align,
          room,
          maxLines: 2,
        );
        final x =
            context.textDirection == TextDirection.rtl
                ? width - (i + 1) * cellW + cellGap / 2
                : i * cellW + cellGap / 2;
        rowOps.add((v, l, x));
        rowH = math.max(rowH, v.height + s.fontSize * 0.06 + l.height);
      }
      final top = y;
      final valueH = rowOps.fold<double>(0, (m, e) => math.max(m, e.$1.height));
      for (final (v, l, x) in rowOps) {
        ops.add((c) {
          v.paint(c, Offset(x, top + valueH - v.height));
          l.paint(c, Offset(x, top + valueH + s.fontSize * 0.06));
        });
      }
      y += rowH + s.fontSize * 0.25;
    }
    y -= s.fontSize * 0.25;
    return _Laid(Size(width, y), (c) {
      for (final op in ops) {
        op(c);
      }
    });
  }
}

class _Laid {
  _Laid(this.size, this.paint);

  final Size size;
  final void Function(Canvas) paint;
  Object? key;
}
