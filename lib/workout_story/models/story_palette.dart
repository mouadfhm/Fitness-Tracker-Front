import 'dart:ui';

import 'story_document.dart';

/// A curated accent colour with the dark tones it is paired with. Stories
/// keep a near-black base whatever the accent.
class StoryPalette {
  const StoryPalette({
    required this.id,
    required this.accent,
    required this.onAccent,
    this.panelTop = const Color(0xFF1A1C20),
    this.panelBottom = const Color(0xFF0D0E10),
  });

  final String id;
  final Color accent;

  /// Text drawn on the accent colour.
  final Color onAccent;
  final Color panelTop;
  final Color panelBottom;

  static const Color base = Color(0xFF0D0E10);
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray = Color(0xFFB4B8BF);

  static const lime = StoryPalette(
    id: 'lime',
    accent: Color(0xFFC6F432),
    onAccent: Color(0xFF0D0E10),
  );

  static const all = <StoryPalette>[
    lime,
    StoryPalette(id: 'mint', accent: Color(0xFF3DF5B0), onAccent: Color(0xFF0D0E10)),
    StoryPalette(id: 'ice', accent: Color(0xFF7FD6FF), onAccent: Color(0xFF0D0E10)),
    StoryPalette(id: 'ember', accent: Color(0xFFFF7A33), onAccent: Color(0xFF0D0E10)),
    StoryPalette(
      id: 'mono',
      accent: Color(0xFFFFFFFF),
      onAccent: Color(0xFF0D0E10),
      panelTop: Color(0xFF1C1C1C),
      panelBottom: Color(0xFF0B0B0B),
    ),
  ];

  static StoryPalette byId(String id) => all.firstWhere((p) => p.id == id, orElse: () => lime);

  Color resolve(StoryColorRole role) => switch (role) {
    StoryColorRole.white => white,
    StoryColorRole.gray => gray,
    StoryColorRole.accent => accent,
    StoryColorRole.dark => base,
  };
}
