import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exercise_provider.dart';
import '../providers/profile_provider.dart';
import '../l10n/app_localizations.dart';
import 'workout_details_screen.dart';
import '../utils/add_banner.dart';
import '../utils/labels.dart';
import '../utils/l10n.dart';
import '../utils/ad_list_helper.dart';

class WorkoutScreen extends StatefulWidget {
  final VoidCallback? onModeToggle;

  const WorkoutScreen({super.key, this.onModeToggle});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {

  @override
  void initState() {
    super.initState();
    // Ensure workouts are fetched after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExercisesProvider>(context, listen: false).refreshWorkouts();
      // Weight is needed for "kcal per hour"; load it if we don't have it yet.
      try {
        final profile = Provider.of<ProfileProvider>(context, listen: false);
        if (profile.profileData == null && !profile.isLoading) profile.fetchProfile();
      } on ProviderNotFoundException {
        // Not provided in some tests; the list falls back to per-kg wording.
      }
    });
  }

  // Helper methods for dynamic styling

  Color _getCategoryColor(String category) {
    final String cat = category.toLowerCase();

    // Strength and weight training
    if (cat.contains('strength') ||
        cat.contains('weight') ||
        cat.contains('gym')) {
      return Colors.blue.shade700;
    }
    // Cardio activities
    else if (cat.contains('cardio') ||
        cat.contains('run') ||
        cat.contains('jog')) {
      return Colors.red.shade600;
    }
    // Flexibility activities
    else if (cat.contains('flex') ||
        cat.contains('stretch') ||
        cat.contains('yoga')) {
      return Colors.purple.shade600;
    }
    // Ball sports
    else if (cat.contains('basketball') ||
        cat.contains('football') ||
        cat.contains('soccer') ||
        cat.contains('tennis') ||
        cat.contains('volleyball') ||
        cat.contains('baseball')) {
      return Colors.orange.shade600;
    }
    // Cycling activities
    else if (cat.contains('cycling') ||
        cat.contains('bike') ||
        cat.contains('biking')) {
      return Colors.green.shade600;
    }
    // Water sports
    else if (cat.contains('swim') ||
        cat.contains('water') ||
        cat.contains('diving')) {
      return Colors.lightBlue.shade600;
    }
    // Combat sports
    else if (cat.contains('boxing') ||
        cat.contains('martial') ||
        cat.contains('fight') ||
        cat.contains('karate') ||
        cat.contains('judo') ||
        cat.contains('mma')) {
      return Colors.red.shade800;
    }
    // Precision sports
    else if (cat.contains('golf') ||
        cat.contains('archery') ||
        cat.contains('shooting')) {
      return Colors.teal.shade600;
    }
    // Winter sports
    else if (cat.contains('ski') ||
        cat.contains('snow') ||
        cat.contains('ice') ||
        cat.contains('hockey') ||
        cat.contains('skating')) {
      return Colors.blue.shade300;
    }
    // Racket sports (not already covered by ball sports)
    else if (cat.contains('badminton') ||
        cat.contains('squash') ||
        cat.contains('racket')) {
      return Colors.yellow.shade800;
    }
    // Outdoor activities
    else if (cat.contains('hike') ||
        cat.contains('climb') ||
        cat.contains('trail') ||
        cat.contains('trek') ||
        cat.contains('mountain')) {
      return Colors.brown.shade600;
    }
    // Default case - generate a color based on hash
    else {
      final int hash = cat.hashCode.abs();
      return Color.fromARGB(
        255,
        (hash % 150) + 50,
        ((hash ~/ 10) % 150) + 50,
        ((hash ~/ 100) % 150) + 50,
      );
    }
  }

  IconData _getCategoryIcon(String category) {
    final String cat = category.toLowerCase();

    // Strength and weight training
    if (cat.contains('strength') ||
        cat.contains('weight') ||
        cat.contains('gym')) {
      return Icons.fitness_center;
    }
    // Running activities
    else if (cat.contains('run') ||
        cat.contains('jog') ||
        cat.contains('marathon')) {
      return Icons.directions_run;
    }
    // General cardio
    else if (cat.contains('cardio') ||
        cat.contains('hiit') ||
        cat.contains('aerobic')) {
      return Icons.favorite;
    }
    // Flexibility activities
    else if (cat.contains('flex') ||
        cat.contains('yoga') ||
        cat.contains('stretch')) {
      return Icons.accessibility_new;
    }
    // Basketball
    else if (cat.contains('basketball')) {
      return Icons.sports_basketball;
    }
    // Football/Soccer
    else if (cat.contains('football') || cat.contains('soccer')) {
      return Icons.sports_soccer;
    }
    // Tennis
    else if (cat.contains('tennis')) {
      return Icons.sports_tennis;
    }
    // Baseball
    else if (cat.contains('baseball')) {
      return Icons.sports_baseball;
    }
    // Volleyball
    else if (cat.contains('volleyball')) {
      return Icons.sports_volleyball;
    }
    // Golf
    else if (cat.contains('golf')) {
      return Icons.sports_golf;
    }
    // Cycling
    else if (cat.contains('cycling') ||
        cat.contains('bike') ||
        cat.contains('biking')) {
      return Icons.pedal_bike;
    }
    // Swimming
    else if (cat.contains('swim') || cat.contains('pool')) {
      return Icons.pool;
    }
    // Combat sports
    else if (cat.contains('boxing') ||
        cat.contains('martial') ||
        cat.contains('karate') ||
        cat.contains('judo') ||
        cat.contains('mma') ||
        cat.contains('fight')) {
      return Icons.sports_martial_arts;
    }
    // Winter sports
    else if (cat.contains('ski') ||
        cat.contains('snow') ||
        cat.contains('ice')) {
      return Icons.snowboarding;
    }
    // Hockey
    else if (cat.contains('hockey')) {
      return Icons.sports_hockey;
    }
    // Climbing/Hiking
    else if (cat.contains('climb') ||
        cat.contains('hike') ||
        cat.contains('trek')) {
      return Icons.terrain;
    }
    // Generic sports
    else if (cat.contains('sport')) {
      return Icons.sports;
    }
    // Handball
    else if (cat.contains('handball')) {
      return Icons.sports_handball;
    }
    // Rugby
    else if (cat.contains('rugby')) {
      return Icons.sports_rugby;
    }
    // Bodyweight exercises
    else if (cat.contains('body') || cat.contains('calisthenics')) {
      return Icons.person;
    }
    // Racket sports (not already covered)
    else if (cat.contains('badminton') ||
        cat.contains('squash') ||
        cat.contains('racket')) {
      return Icons.sports_tennis;
    }
    else if (cat.contains('stair') ) {
      return Icons.stairs;
    }
    // Default
    else {
      return Icons.fitness_center;
    }
  }

  Widget _buildModeToggle(BuildContext context, {required bool isSimple}) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleSegment(context,
              label: l10n.workoutModeSimple,
              semanticsLabel: l10n.workoutModeSimpleSemantics,
              active: isSimple,
              onTap: null),
          _toggleSegment(context,
              label: l10n.workoutModeAdvanced,
              semanticsLabel: l10n.workoutModeAdvancedSemantics,
              active: !isSimple,
              onTap: widget.onModeToggle),
        ],
      ),
    );
  }

  Widget _toggleSegment(BuildContext context, {
    required String label,
    required String semanticsLabel,
    required bool active,
    required VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: active,
      label: semanticsLabel,
      excludeSemantics: true,
      child: GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: active ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      ),
    );
  }

  /// The user's weight in kg, if their profile is loaded.
  double? _userWeight(BuildContext context) {
    try {
      final w = Provider.of<ProfileProvider>(context).profileData?['weight'];
      return w is num && w > 0 ? w.toDouble() : null;
    } on ProviderNotFoundException {
      return null;
    }
  }

  /// 1 = light, 2 = moderate, 3 = vigorous; same thresholds as
  /// [intensityLabel], whose text is translated so can't be compared.
  int _intensityLevel(num caloriesPerKg) =>
      caloriesPerKg >= 6 ? 3 : caloriesPerKg >= 3 ? 2 : 1;

  Color _intensityColor(int level) {
    switch (level) {
      case 1:
        return Colors.green.shade700;
      case 2:
        return Colors.orange.shade800;
      default:
        return Colors.red.shade700;
    }
  }

  Widget _buildDifficultyIndicator(int level) {
    final color = _intensityColor(level);

    return Row(
      children: List.generate(3, (index) {
        return Container(
          width: 5,
          height: index < 2 ? 8 : 12,
          margin: const EdgeInsets.only(left: 2),
          decoration: BoxDecoration(
            color: index < level ? color : Theme.of(context).colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.workoutTitle,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          if (widget.onModeToggle != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _buildModeToggle(context, isSimple: true),
            ),
        ],
      ),
      body: SafeArea(
        child: Consumer<ExercisesProvider>(
          builder: (context, provider, child) {
            final colorScheme = Theme.of(context).colorScheme;
            return CustomScrollView(
              slivers: [
                // Search bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            l10n.workoutSimpleIntro,
                            style: TextStyle(fontSize: 15, color: colorScheme.onSurfaceVariant),
                          ),
                        ),
                        TextField(
                      onChanged: provider.updateSearchQuery,
                      decoration: InputDecoration(
                        hintText: l10n.workoutSearchActivitiesHint,
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                      ],
                    ),
                  ),
                ),

                // Category filters – dynamically generated from provider.categories
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: provider.categories.length,
                        itemBuilder: (context, index) {
                          final category = provider.categories[index];
                          final isSelected =
                              provider.selectedCategory == category;

                          return GestureDetector(
                            onTap: () {
                              provider.updateCategory(category);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? colorScheme.primary
                                      : colorScheme.outlineVariant,
                                ),
                              ),
                              child: Text(
                                category == 'All'
                                    ? l10n.workoutCategoryAll
                                    : provider.categoryLabel(category),
                                style: TextStyle(
                                  color: isSelected
                                      ? colorScheme.onPrimary
                                      : colorScheme.onSurfaceVariant,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Results count
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          provider.isLoading
                              ? l10n.workoutLoading
                              : l10n.workoutActivitiesCount(
                                  provider.filteredWorkouts.length),
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          provider.selectedCategory == 'All'
                              ? l10n.workoutAllCategories
                              : provider.selectedCategory,
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Workouts list
                provider.isLoading
                    ? const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : provider.errorMessage != null
                    ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: colorScheme.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.workoutActivitiesLoadError,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                provider.errorMessage!,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: provider.fetchWorkouts,
                              icon: const Icon(Icons.refresh),
                              label: Text(l10n.workoutTryAgain),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: colorScheme.onPrimary,
                                backgroundColor: colorScheme.primary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    : provider.filteredWorkouts.isEmpty
                    ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.fitness_center,
                              size: 56,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              provider.searchQuery.isEmpty
                                  ? l10n.workoutNoActivitiesAvailable
                                  : l10n.workoutNoActivitiesMatchSearch,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (provider.searchQuery.isNotEmpty ||
                                provider.selectedCategory != 'All')
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: TextButton.icon(
                                  onPressed: () {
                                    provider.updateSearchQuery('');
                                    provider.updateCategory('All');
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: Text(l10n.workoutClearFilters),
                                  style: TextButton.styleFrom(
                                    foregroundColor: colorScheme.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    )
                    : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => adAwareItemBuilder(
                            index,
                            (realIndex) {
                            final workout = provider.filteredWorkouts[realIndex];
                            // The backend's display_name is the activity in
                            // the app's language.
                            final description = workout['display_name'] ??
                                workout['description'] ??
                                l10n.workoutNoDescription;
                            // Colour and icon are picked from the English
                            // name; only the shown text is translated.
                            final String? name = workout['name'];
                            final categoryKey = name ?? 'Other';
                            final category = name == null
                                ? l10n.workoutCategoryOther
                                : localizedName(workout);
                            final caloriesPerKg =
                                (workout['caloriesPerKg'] as num).toDouble();
                            // Calorie burn per kg is really an intensity
                            // measure, so label it as that, not "difficulty".
                            final difficulty = intensityLabel(caloriesPerKg);
                            final level = _intensityLevel(caloriesPerKg);
                            final weight = _userWeight(context);
                            final Color categoryColor =
                                _getCategoryColor(categoryKey);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          WorkoutDetailsScreen(workout: workout),
                                    ),
                                  );
                                },
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Row(
                                      children: [
                                        // Icon chip
                                        Container(
                                          width: 52,
                                          height: 52,
                                          decoration: BoxDecoration(
                                            color: categoryColor
                                                .withValues(alpha: 0.2),
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          child: Icon(
                                            _getCategoryIcon(categoryKey),
                                            size: 28,
                                            color: categoryColor,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        // Info column
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                description,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 5),
                                              Row(
                                                children: [
                                                  Flexible(
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 3),
                                                      decoration: BoxDecoration(
                                                        color: categoryColor
                                                            .withValues(
                                                                alpha: 0.15),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                6),
                                                      ),
                                                      child: Text(
                                                        category,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: categoryColor,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Icon(
                                                    Icons.local_fire_department,
                                                    size: 13,
                                                    color: colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                                  const SizedBox(width: 2),
                                                  Flexible(
                                                    child: Text(
                                                      weight != null
                                                          ? l10n.workoutKcalPerHour(
                                                              (caloriesPerKg * weight).round())
                                                          : l10n.workoutKcalPerHourPerKg(
                                                              caloriesPerKg.toStringAsFixed(1)),
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: colorScheme
                                                            .onSurfaceVariant,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Difficulty column
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            _buildDifficultyIndicator(
                                                level),
                                            const SizedBox(height: 4),
                                            Text(
                                              difficulty,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: _intensityColor(level),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                            }),
                          childCount: effectiveItemCount(provider.filteredWorkouts.length),
                        ),
                      ),
                    ),
              ],
            );
          },
        ),
      ),

      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
