import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../utils/app_theme.dart';
import '../utils/l10n.dart';
import '../providers/achievement_provider.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AchievementsProvider>().loadAchievements();
    });
  }

  /// Shown name of an achievement type code (the code itself stays as is).
  String _typeLabel(AppLocalizations l10n, String type) {
    switch (type) {
      case 'meals':
        return l10n.achievementTypeMeals;
      case 'streak':
        return l10n.achievementTypeStreak;
      case 'calories':
        return l10n.achievementTypeCalories;
      case 'workouts':
        return l10n.achievementTypeWorkouts;
      case 'cardio':
        return l10n.achievementTypeCardio;
      case 'progress':
        return l10n.achievementTypeProgress;
      case 'weight':
        return l10n.achievementTypeWeight;
      case 'muscle':
        return l10n.achievementTypeMuscle;
      default:
        return type.toUpperCase();
    }
  }

  void _showAchievementDetails(
    BuildContext context,
    dynamic achievement,
    bool unlocked,
    dynamic userAchievement,
  ) {
    final achievementsProvider = context.read<AchievementsProvider>();
    final Color achievementColor = achievementsProvider.getColorForType(
      achievement['type'],
    );
    final IconData achievementIcon = achievementsProvider.getIconForType(
      achievement['type'],
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        final l10n = AppLocalizations.of(context)!;

        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              // Achievement header
              Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                decoration: BoxDecoration(
                  color: unlocked
                      ? achievementColor.withValues(alpha: 0.1)
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: unlocked
                            ? achievementColor.withValues(alpha: 0.2)
                            : colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        achievementIcon,
                        color: unlocked
                            ? achievementColor
                            : colorScheme.onSurfaceVariant,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizedName(achievement),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: unlocked
                                      ? colorScheme.primary
                                          .withValues(alpha: 0.15)
                                      : colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  unlocked ? l10n.achievementUnlocked : l10n.achievementLocked,
                                  style: TextStyle(
                                    color: unlocked
                                        ? colorScheme.primary
                                        : colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _typeLabel(l10n, achievement['type']),
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.achievementDescriptionLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        localizedName(achievement, field: 'description'),
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 24),

                      Text(
                        l10n.achievementRequirementsLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colorScheme.outlineVariant),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.flag_outlined,
                              color: unlocked
                                  ? achievementColor
                                  : colorScheme.onSurfaceVariant,
                              size: 24,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.achievementTargetLabel,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    achievementsProvider.getTargetDescription(
                                      achievement['type'],
                                      achievement['target'],
                                    ),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (unlocked) ...[
                        const SizedBox(height: 24),
                        Text(
                          l10n.achievementCompletionDetailsLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color:
                                    colorScheme.primary.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                color: colorScheme.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.achievementCompletedOnLabel,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      achievementsProvider.formatDate(
                                        userAchievement['created_at'],
                                      ),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileAchievements,
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: Consumer<AchievementsProvider>(
        builder: (context, achievementsProvider, child) {
          if (achievementsProvider.isLoading) {
            return Center(
                child: CircularProgressIndicator(color: colorScheme.primary));
          }

          if (achievementsProvider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 48, color: colorScheme.error),
                    const SizedBox(height: 16),
                    Text(
                        l10n.achievementCouldNotLoad(
                            '${achievementsProvider.error}')),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          achievementsProvider.retryLoadAchievements(),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            );
          }

          if (achievementsProvider.achievements.isEmpty) {
            return Center(child: Text(l10n.achievementNoneFound));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: achievementsProvider.achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievementsProvider.achievements[index];
              final bool unlocked = achievementsProvider
                  .isAchievementUnlocked(achievement['id']);
              final Color achievementColor =
                  achievementsProvider.getColorForType(achievement['type']);

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  side: unlocked
                      ? BorderSide(color: achievementColor, width: 2)
                      : BorderSide(color: AppTheme.cardBorderColor(colorScheme)),
                ),
                child: InkWell(
                  onTap: () {
                    _showAchievementDetails(
                      context,
                      achievement,
                      unlocked,
                      unlocked
                          ? achievementsProvider
                              .userAchievements[achievement['id']]
                          : null,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: unlocked
                                  ? achievementColor.withValues(alpha: 0.2)
                                  : colorScheme.surfaceContainerHighest,
                              child: Icon(
                                unlocked
                                    ? achievementsProvider
                                        .getIconForType(achievement['type'])
                                    : Icons.lock_outline,
                                size: 36,
                                color: unlocked
                                    ? achievementColor
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (unlocked)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: colorScheme.surface,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    size: 14,
                                    color: colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          localizedName(achievement),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: unlocked
                                ? colorScheme.onSurface
                                : colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          unlocked
                              ? localizedName(achievement, field: 'description')
                              : l10n.achievementCompleteToUnlock(
                                  localizedName(achievement, field: 'description')),
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (unlocked) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: achievementColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              l10n.achievementCompletedBadge,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: achievementColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
