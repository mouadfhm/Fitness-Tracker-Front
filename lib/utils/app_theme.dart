import 'package:flutter/material.dart';

/// The app's light and dark themes, in one place so every screen draws its
/// cards, app bars and backgrounds the same way.
///
/// Light mode is a plain white page with white cards set off by a thin border
/// and a soft shadow, rather than tinted cards on a tinted page: a border keeps
/// the card edge visible on any screen brightness, and text on white keeps the
/// highest contrast. Dark mode lifts cards one step above the page.
class AppTheme {
  AppTheme._();

  static const seed = Colors.teal;

  static const double cardRadius = 16;

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
    ).copyWith(
      surface: Colors.white,
      surfaceContainerLowest: Colors.white,
      // Light enough for a filled field or chip on white, dark enough to see.
      surfaceContainerLow: const Color(0xFFF5F8F8),
      surfaceContainer: const Color(0xFFEFF3F3),
      surfaceContainerHigh: const Color(0xFFE9EEEE),
      surfaceContainerHighest: const Color(0xFFE3E9E9),
      outlineVariant: const Color(0xFFDDE4E3),
    );
    return _build(scheme, cardColor: Colors.white, pageColor: Colors.white);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    );
    return _build(
      scheme,
      cardColor: scheme.surfaceContainer,
      pageColor: scheme.surface,
    );
  }

  static ThemeData _build(
    ColorScheme scheme, {
    required Color cardColor,
    required Color pageColor,
  }) {
    final isLight = scheme.brightness == Brightness.light;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: pageColor,
      cardColor: cardColor,
      cardTheme: CardThemeData(
        color: cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: isLight ? 1 : 0,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: BorderSide(color: cardBorderColor(scheme)),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: pageColor,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: scheme.shadow.withValues(alpha: 0.2),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant),
      listTileTheme: ListTileThemeData(iconColor: scheme.onSurfaceVariant),
    );
  }

  static Color cardBorderColor(ColorScheme scheme) =>
      scheme.brightness == Brightness.light
          ? scheme.outlineVariant
          : scheme.outlineVariant.withValues(alpha: 0.5);

  /// For card-like containers that can't be a [Card] (an `AnimatedContainer`,
  /// a box with a gradient), so they still match the cards around them.
  static BoxDecoration cardDecoration(
    BuildContext context, {
    double radius = cardRadius,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return BoxDecoration(
      color: color ?? theme.cardTheme.color ?? scheme.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: cardBorderColor(scheme)),
      boxShadow: scheme.brightness == Brightness.light
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
          : null,
    );
  }
}
