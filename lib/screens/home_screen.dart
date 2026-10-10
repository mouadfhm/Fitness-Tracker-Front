import 'package:flutter/material.dart';
import '../utils/adaptive.dart';
import 'main_shell.dart';
import 'package:intl/intl.dart';
import 'meal_detail_screen.dart';
import 'meal_history_screen.dart';
import 'foods_screen.dart';
import '../services/api_service.dart';
import '../utils/add_banner.dart';
import '../utils/friendly_error.dart';
import '../utils/labels.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/notification_prompt_card.dart';

/// Totals for a list of meal foods. Food values are stored per 100 g and the
/// pivot holds the grams eaten.
class MealTotals {
  double calories = 0;
  double protein = 0;
  double carbs = 0;
  double fat = 0;

  void addFoods(Iterable<dynamic> foods) {
    for (final food in foods) {
      final grams = (food['pivot']['quantity'] as num).toDouble();
      calories += (food['calories'] as num).toDouble() * grams / 100;
      protein += (food['protein'] as num).toDouble() * grams / 100;
      carbs += (food['carbs'] as num).toDouble() * grams / 100;
      fat += (food['fats'] as num).toDouble() * grams / 100;
    }
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final int _currentIndex = 0;

  Map<String, dynamic>? _goalMacros;
  List<dynamic> _todayMeals = [];
  List<dynamic> _pastMeals = [];
  double _caloriesBurned = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  /// The shell's selected tab the last time this screen looked, or null
  /// outside the shell.
  int? _shellTab;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The shell keeps this tab alive while others show, so meals or workouts
    // logged elsewhere would otherwise not appear until a restart. Reload
    // quietly each time Today comes back into view.
    final tab = MainShellScope.maybeOf(context)?.currentIndex;
    if (tab == _currentIndex && _shellTab != null && _shellTab != _currentIndex) {
      _fetchData();
    }
    _shellTab = tab;
  }

  String get _todayKey => DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<void> _fetchData() async {
    try {
      final goal = await _apiService.getGoal();
      final meals = await _apiService.getMeals();
      double burned = 0;
      try {
        burned = await _apiService.getCalories(_todayKey);
      } catch (_) {
        // Burned calories are a nice-to-have; never block Home on them.
      }

      final today = <dynamic>[];
      final past = <dynamic>[];
      for (final meal in meals) {
        final date = meal['date'].toString().substring(0, 10);
        (date == _todayKey ? today : past).add(meal);
      }

      if (!mounted) return;
      setState(() {
        _goalMacros = goal['macros'] is Map<String, dynamic> ? goal['macros'] : null;
        _todayMeals = today;
        _pastMeals = past;
        _caloriesBurned = burned;
        _errorMessage = null;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = friendlyError(error);
        _isLoading = false;
      });
    }
  }

  /// Foods logged today, grouped by meal time (lower-case).
  Map<String, List<dynamic>> get _todayFoodsByMeal {
    final grouped = <String, List<dynamic>>{};
    for (final meal in _todayMeals) {
      final mealTime = (meal['meal_time'] ?? 'snack').toString().toLowerCase();
      grouped.putIfAbsent(mealTime, () => []).addAll(meal['foods'] ?? []);
    }
    return grouped;
  }

  Future<void> _addFood(String mealTime) async {
    final added = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => FoodsScreen(addToMeal: mealTime)),
    );
    if (!mounted) return;
    if (added != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(added)));
    }
    _fetchData();
  }

  Future<void> _openMeal(String mealTime, List<dynamic> foods) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MealDetailScreen(mealTime: mealTime, foods: foods),
      ),
    );
    if (mounted) _fetchData();
  }

  void _showNutrientHelp() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text('What do these mean?'),
        content: const Text(
          'Calories (kcal) measure the energy in food. Eating about your daily '
          'goal helps you reach your target weight.\n\n'
          'Protein, carbs and fat are the three nutrients that give food its '
          'calories. Protein helps build and repair muscle, carbs give you '
          'energy, and fat supports your body in many ways.\n\n'
          "You don't need to hit every number exactly. Focus on calories "
          'first, then try to get enough protein.',
        ),
        actions: [
          AdaptiveDialogAction(isDefault: true, onPressed: () => Navigator.pop(context), child: const Text('Got it')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Today', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              DateFormat('EEEE, MMMM d').format(DateTime.now()),
              style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'What do these numbers mean?',
            onPressed: _showNutrientHelp,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : _errorMessage != null
              ? _buildError(colorScheme)
              : RefreshIndicator(
                  color: colorScheme.primary,
                  onRefresh: _fetchData,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildCalorieSummary(colorScheme),
                      const SizedBox(height: 24),
                      Text(
                        'Your meals',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._buildMealCards(colorScheme),
                      const NotificationPromptCard(),
                      const SizedBox(height: 8),
                      if (_pastMeals.isNotEmpty)
                        OutlinedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MealHistoryScreen(meals: _pastMeals),
                            ),
                          ).then((_) => _fetchData()),
                          icon: const Icon(Icons.history),
                          label: const Text('See past days'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                    ],
                  ),
                ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AdBannerWidget(),
          CustomBottomNavBar(currentIndex: _currentIndex),
        ],
      ),
    );
  }

  Widget _buildError(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, color: colorScheme.error, size: 48),
            const SizedBox(height: 16),
            Text(
              "We couldn't load today's data",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                setState(() => _isLoading = true);
                _fetchData();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieSummary(ColorScheme colorScheme) {
    final totals = MealTotals();
    for (final meal in _todayMeals) {
      totals.addFoods(meal['foods'] ?? []);
    }
    final goal = (_goalMacros?['calories'] as num?)?.toDouble() ?? 0;
    final eaten = totals.calories;
    final left = goal - eaten;
    final isOver = goal > 0 && left < 0;
    final progress = goal > 0 ? (eaten / goal).clamp(0.0, 1.0) : 0.0;
    final ringColor = isOver ? colorScheme.error : colorScheme.primary;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Semantics(
              label: goal <= 0
                  ? '${eaten.round()} calories eaten today'
                  : isOver
                      ? '${(-left).round()} calories over your goal today'
                      : '${left.round()} calories left today',
              excludeSemantics: true,
              child: SizedBox(
                width: 170,
                height: 170,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 14,
                        strokeCap: StrokeCap.round,
                        color: ringColor,
                        backgroundColor: ringColor.withValues(alpha: 0.15),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          goal <= 0 ? '${eaten.round()}' : '${left.abs().round()}',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: isOver ? colorScheme.error : colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          goal <= 0
                              ? 'kcal eaten'
                              : isOver
                                  ? 'kcal over'
                                  : 'kcal left',
                          style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (goal > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _summaryFigure('Goal', goal, colorScheme),
                  _summaryFigure('Eaten', eaten, colorScheme),
                  _summaryFigure('Exercise', _caloriesBurned, colorScheme),
                ],
              )
            else
              Text(
                'Finish your profile on the Me tab to get a daily calorie goal.',
                style: TextStyle(fontSize: 15, color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            if (goal > 0 && _caloriesBurned > 0) ...[
              const SizedBox(height: 8),
              Text(
                "Today's exercise is already added to your goal.",
                style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
            if (_goalMacros != null) ...[
              const SizedBox(height: 20),
              _nutrientBar('Protein', totals.protein,
                  (_goalMacros!['protein'] as num?)?.toDouble() ?? 0, Colors.blue, colorScheme),
              _nutrientBar('Carbs', totals.carbs,
                  (_goalMacros!['carbs'] as num?)?.toDouble() ?? 0, Colors.green, colorScheme),
              _nutrientBar('Fat', totals.fat,
                  (_goalMacros!['fats'] as num?)?.toDouble() ?? 0, Colors.orange, colorScheme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _summaryFigure(String label, double value, ColorScheme colorScheme) {
    return Column(
      children: [
        Text(
          '${value.round()}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        Text(
          '$label (kcal)',
          style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _nutrientBar(
    String label,
    double eaten,
    double goal,
    MaterialColor color,
    ColorScheme colorScheme,
  ) {
    final isDark = colorScheme.brightness == Brightness.dark;
    final barColor = isDark ? color.shade300 : color.shade700;
    final progress = goal > 0 ? (eaten / goal).clamp(0.0, 1.0) : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                goal > 0 ? '${eaten.round()} of ${goal.round()} g' : '${eaten.round()} g',
                style: TextStyle(fontSize: 15, color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            color: barColor,
            backgroundColor: barColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMealCards(ColorScheme colorScheme) {
    final byMeal = _todayFoodsByMeal;
    // Always offer the four main meals, then any other meal names the person
    // has used today (e.g. "pre-workout").
    final mealTimes = [
      ...mainMealTimes,
      ...byMeal.keys.where((m) => !mainMealTimes.contains(m)).toList()..sort(),
    ];

    return mealTimes.map((mealTime) {
      final foods = byMeal[mealTime] ?? [];
      final totals = MealTotals()..addFoods(foods);
      final names = foods.map((f) => f['name'].toString()).toList();
      final summary = names.isEmpty
          ? 'Nothing added yet'
          : names.length <= 3
              ? names.join(', ')
              : '${names.take(3).join(', ')} and ${names.length - 3} more';

      return Card(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: foods.isEmpty ? () => _addFood(mealTime) : () => _openMeal(mealTime, foods),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            mealTimeLabel(mealTime),
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          if (foods.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              '${totals.calories.round()} kcal',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Semantics(
                  label: 'Add food to ${mealTimeLabel(mealTime)}',
                  excludeSemantics: true,
                  button: true,
                  child: FilledButton.tonalIcon(
                    onPressed: () => _addFood(mealTime),
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}
