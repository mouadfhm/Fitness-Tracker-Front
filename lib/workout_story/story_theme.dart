import 'package:flutter/material.dart';

import '../utils/app_theme.dart';
import 'models/story_palette.dart';

/// The story screens are always dark, whatever the app theme, so the editor
/// frames the story the way it will look when posted. Built on the app's
/// dark theme so buttons, dialogs and sheets behave the same.
ThemeData storyEditorTheme() {
  final base = AppTheme.dark();
  const background = Color(0xFF0B0C0E);
  const surface = Color(0xFF16181B);
  final scheme = base.colorScheme.copyWith(
    primary: StoryPalette.lime.accent,
    onPrimary: StoryPalette.lime.onAccent,
    secondary: StoryPalette.lime.accent,
    onSecondary: StoryPalette.lime.onAccent,
    surface: background,
    onSurface: Colors.white,
    onSurfaceVariant: StoryPalette.gray,
    surfaceContainerLowest: background,
    surfaceContainerLow: surface,
    surfaceContainer: surface,
    surfaceContainerHigh: const Color(0xFF1E2024),
    surfaceContainerHighest: const Color(0xFF26292E),
    outline: const Color(0xFF3A3D43),
    outlineVariant: const Color(0xFF2A2D32),
  );
  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: background,
    canvasColor: background,
    appBarTheme: base.appBarTheme.copyWith(
      backgroundColor: background,
      foregroundColor: Colors.white,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
    ),
    sliderTheme: base.sliderTheme.copyWith(
      activeTrackColor: scheme.primary,
      thumbColor: scheme.primary,
      inactiveTrackColor: scheme.outline,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? scheme.onPrimary : StoryPalette.gray,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? scheme.primary : scheme.surfaceContainerHighest,
      ),
    ),
  );
}
