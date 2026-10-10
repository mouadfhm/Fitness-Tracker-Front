import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/app_theme.dart';
import '../main_shell.dart';

/// The four-tab bar: a floating rounded bar with a pill that slides to the
/// selected tab, whose icon fills in and lifts slightly.
///
/// [MainShell] draws one bar for all tabs, so the pill animates from the old
/// tab to the new one instead of jumping.
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  static const _duration = Duration(milliseconds: 380);

  void _onTap(BuildContext context, int i) {
    if (i == currentIndex) return;
    HapticFeedback.selectionClick();
    final shell = MainShellScope.maybeOf(context);
    if (shell != null) {
      shell.select(i);
      return;
    }
    // Outside the shell (a tab screen shown on its own): open the shell
    // on that tab, in place and without a transition.
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => MainShell(initialIndex: i),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = scheme.brightness == Brightness.light;

    // Labels are always visible: icon-only tabs are guesswork for people who
    // don't use many apps.
    final items = [
      (Icons.today_outlined, Icons.today, l10n.navToday),
      (Icons.fitness_center_outlined, Icons.fitness_center, l10n.navWorkouts),
      (Icons.restaurant_outlined, Icons.restaurant, l10n.navFoods),
      (Icons.person_outline, Icons.person, l10n.navMe),
    ];

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: isLight ? Colors.white : scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.cardBorderColor(scheme)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isLight ? 0.08 : 0.3),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / items.length;
              return Stack(
                children: [
                  // The sliding pill behind the selected tab.
                  AnimatedPositioned(
                    duration: _duration,
                    curve: Curves.easeOutBack,
                    left: itemWidth * currentIndex + 6,
                    top: 6,
                    bottom: 6,
                    width: itemWidth - 12,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      for (var i = 0; i < items.length; i++)
                        Expanded(
                          child: _NavItem(
                            icon: items[i].$1,
                            selectedIcon: items[i].$2,
                            label: items[i].$3,
                            selected: i == currentIndex,
                            onTap: () => _onTap(context, i),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        containedInkWell: true,
        highlightShape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSlide(
              duration: CustomBottomNavBar._duration,
              curve: Curves.easeOutBack,
              offset: selected ? const Offset(0, -0.08) : Offset.zero,
              child: AnimatedScale(
                duration: CustomBottomNavBar._duration,
                curve: Curves.easeOutBack,
                scale: selected ? 1.12 : 1.0,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Icon(
                    selected ? selectedIcon : icon,
                    key: ValueKey(selected),
                    color: color,
                    size: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: theme.textTheme.labelMedium!.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
