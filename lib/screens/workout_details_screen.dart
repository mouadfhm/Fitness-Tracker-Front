import 'package:flutter/material.dart';
import '../utils/adaptive.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fitness_tracker_app/providers/profile_provider.dart';
import 'package:fitness_tracker_app/utils/friendly_error.dart';
import '../utils/l10n.dart';
import '../l10n/app_localizations.dart';

class WorkoutDetailsScreen extends StatefulWidget {
  final dynamic workout;

  const WorkoutDetailsScreen({super.key, required this.workout});

  @override
  State<WorkoutDetailsScreen> createState() => _WorkoutDetailsScreenState();
}

class _WorkoutDetailsScreenState extends State<WorkoutDetailsScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _durationController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isAddingWorkout = false;
  // Outcome of the last "I did this" tap; the message is built in build() so
  // it follows the current language.
  int? _loggedMinutes;
  String? _addWorkoutError;
  bool get _hasAddWorkoutResult => _loggedMinutes != null || _addWorkoutError != null;
  bool get _addWorkoutFailed => _addWorkoutError != null;
  final ApiService apiService = ApiService();

  // Helper methods for dynamic styling - bringing over from WorkoutScreen
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
    // Other sports categories from WorkoutScreen
    else if (cat.contains('baseball')) {
      return Icons.sports_baseball;
    } else if (cat.contains('volleyball')) {
      return Icons.sports_volleyball;
    } else if (cat.contains('golf')) {
      return Icons.sports_golf;
    } else if (cat.contains('cycling') ||
        cat.contains('bike') ||
        cat.contains('biking')) {
      return Icons.pedal_bike;
    } else if (cat.contains('swim') || cat.contains('pool')) {
      return Icons.pool;
    } else if (cat.contains('boxing') ||
        cat.contains('martial') ||
        cat.contains('karate') ||
        cat.contains('judo') ||
        cat.contains('mma') ||
        cat.contains('fight')) {
      return Icons.sports_martial_arts;
    }
    // Default
    else {
      return Icons.fitness_center;
    }
  }

  /// Effort level code ('Light', 'Moderate', 'Vigorous') from kcal per kg per
  /// hour, same thresholds as intensityLabel() in utils/labels.dart. Kept as a fixed code because
  /// the colors and the indicator key off it; [_intensityDisplay] gives the
  /// text shown on screen.
  String _intensityCode(num caloriesPerKgPerHour) {
    if (caloriesPerKgPerHour >= 6) return 'Vigorous';
    if (caloriesPerKgPerHour >= 3) return 'Moderate';
    return 'Light';
  }

  /// Localized display name for an effort level code.
  String _intensityDisplay(AppLocalizations l10n, String code) {
    switch (code) {
      case 'Vigorous':
        return l10n.workoutDetailsIntensityVigorous;
      case 'Moderate':
        return l10n.workoutDetailsIntensityModerate;
      case 'Light':
        return l10n.workoutDetailsIntensityLight;
      default:
        return code;
    }
  }

  Widget _buildDifficultyIndicator(String difficulty) {
    Color color;
    int level;

    switch (difficulty.toLowerCase()) {
      case 'light':
      case 'easy':
      case 'beginner':
        color = Colors.green;
        level = 1;
        break;
      case 'moderate':
      case 'medium':
      case 'intermediate':
        color = Colors.orange;
        level = 2;
        break;
      case 'vigorous':
      case 'hard':
      case 'advanced':
      case 'expert':
        color = Colors.red;
        level = 3;
        break;
      default:
        color = Colors.grey;
        level = 1;
    }

    return Row(
      children: List.generate(3, (index) {
        return Container(
          width: 5,
          height: index < 2 ? 8 : 12,
          margin: const EdgeInsets.only(left: 2),
          decoration: BoxDecoration(
            color: index < level ? color : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showAdaptiveDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Theme.of(context).colorScheme.primary,
              brightness: Theme.of(context).brightness,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addWorkout() async {
    // Sent to the backend as the logged workout's name, so it stays English.
    final workoutName = widget.workout['description'] ?? 'Unknown Workout';
    final durationText = _durationController.text.trim();

    final int? duration = int.tryParse(durationText);
    if (duration == null || duration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.workoutDetailsEnterMinutes)),
      );
      return;
    }

    final workoutDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

    setState(() {
      _isAddingWorkout = true;
      _loggedMinutes = null;
      _addWorkoutError = null;
    });

    try {
      await _apiService.storeWorkout(workoutName, duration, workoutDate);
      if (!mounted) return;
      setState(() {
        _loggedMinutes = duration;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _addWorkoutError = friendlyError(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isAddingWorkout = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeName = Localizations.localeOf(context).toString();
    final name = localizedName(widget.workout, fallback: l10n.workoutDetailsNoName);
    final description = widget.workout['display_name'] ?? widget.workout['description'] ?? l10n.workoutNoDescription;
    final category = widget.workout['display_category'] as String? ??
        localizedName(widget.workout, fallback: l10n.workoutDetailsUncategorized);
    final difficulty =
        _intensityCode(widget.workout['caloriesPerKg'] as num);
    final difficultyText = _intensityDisplay(l10n, difficulty);
    final String? addWorkoutMessage = _addWorkoutFailed
        ? l10n.workoutDetailsLogFailed(_addWorkoutError!)
        : _loggedMinutes != null
            ? l10n.workoutDetailsLoggedSuccess(_loggedMinutes!)
            : null;

    // Colour and icon are picked from the English name; only the shown text
    // is translated.
    final String iconKey = widget.workout['name'] as String? ?? category;
    final Color categoryColor = _getCategoryColor(iconKey);
    final IconData categoryIcon = _getCategoryIcon(iconKey);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final weight = profileProvider.profileData?['weight'] ?? 0;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with workout icon and colors
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: categoryColor,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                color: categoryColor,
                child: Center(
                  child: Icon(
                    categoryIcon,
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(
                        difficultyText,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _buildDifficultyIndicator(difficulty),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Workout Detail Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // About This Workout Section
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: categoryColor,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                l10n.workoutDetailsAboutActivity,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: categoryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Category badge
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: categoryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      categoryIcon,
                                      size: 16,
                                      color: categoryColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      category,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: categoryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Description
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 16,
                              color: colorScheme.onSurface,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Stats Row
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(
                                  Icons.local_fire_department,
                                  l10n.workoutDetailsIntensity,
                                  difficultyText,
                                  difficulty == 'Light'
                                      ? Colors.green.shade700
                                      : difficulty == 'Moderate'
                                      ? Colors.orange.shade800
                                      : Colors.red.shade700,
                                ),
                                _buildStatItem(
                                  Icons.flash_on,
                                  l10n.workoutDetailsBurnsAbout,
                                  weight > 0
                                      ? l10n.workoutDetailsKcalPerHour((widget.workout['caloriesPerKg'] * weight).toStringAsFixed(0))
                                      : "—",
                                  colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Schedule Workout Section
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: categoryColor,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                l10n.workoutDetailsLogActivity,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: categoryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Date Picker
                          GestureDetector(
                            onTap: () => _selectDate(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: colorScheme.outlineVariant),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.event, color: categoryColor),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.workoutDetailsWhenTapToChange,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateUtils.isSameDay(_selectedDate, DateTime.now())
                                            ? l10n.homeToday
                                            : DateFormat.yMMMEd(localeName).format(_selectedDate),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: colorScheme.outlineVariant,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Duration Input
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: colorScheme.outlineVariant),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.timer, color: categoryColor),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextField(
                                    controller: _durationController,
                                    keyboardType: TextInputType.number,
                                    onChanged: (_) => setState(() {}),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: l10n.workoutDetailsHowManyMinutes,
                                      hintStyle: TextStyle(
                                        color: colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.normal,
                                      ),
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [15, 30, 45, 60].map((m) {
                              return ChoiceChip(
                                showCheckmark: false,
                                label: Text(l10n.workoutDetailScreenMinutes(m)),
                                selected: _durationController.text.trim() == '$m',
                                onSelected: (_) => setState(() => _durationController.text = '$m'),
                              );
                            }).toList(),
                          ),
                          if (weight > 0 && (int.tryParse(_durationController.text.trim()) ?? 0) > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                l10n.workoutDetailsAboutKcalBurned(((widget.workout['caloriesPerKg'] as num) * weight * (int.parse(_durationController.text.trim())) / 60).round()),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),

                          // "I did this" button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isAddingWorkout ? null : _addWorkout,
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: categoryColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child:
                                  _isAddingWorkout
                                      ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : Text(
                                        l10n.workoutDetailsIDidThis,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                            ),
                          ),

                          // Success/Error Message
                          if (_hasAddWorkoutResult && addWorkoutMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color:
                                      _addWorkoutFailed
                                          ? colorScheme.errorContainer
                                          : colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color:
                                        _addWorkoutFailed
                                            ? colorScheme.error.withValues(alpha: 0.4)
                                            : colorScheme.primary.withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _addWorkoutFailed
                                          ? Icons.error
                                          : Icons.check_circle,
                                      color:
                                          _addWorkoutFailed
                                              ? colorScheme.error
                                              : colorScheme.primary,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        addWorkoutMessage,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color:
                                              _addWorkoutFailed
                                                  ? colorScheme.onErrorContainer
                                                  : colorScheme.onPrimaryContainer,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
