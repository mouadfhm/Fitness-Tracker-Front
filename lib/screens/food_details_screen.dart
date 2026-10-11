import 'package:fitness_tracker_app/providers/food_provider.dart';
import 'package:flutter/material.dart';
import '../utils/adaptive.dart';
import 'package:provider/provider.dart';
import '../models/food.dart';
import '../services/api_service.dart';
import '../utils/friendly_error.dart';
import '../utils/labels.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';

class FoodDetailsScreen extends StatefulWidget {
  final Food food;

  /// Meal to log into (e.g. "lunch"). Defaults to the meal that fits the
  /// current time of day.
  final String? initialMealTime;

  const FoodDetailsScreen({super.key, required this.food, this.initialMealTime});

  @override
  State<FoodDetailsScreen> createState() => _FoodDetailsScreenState();
}

class _FoodDetailsScreenState extends State<FoodDetailsScreen> {
  static const _quickAmounts = [50, 100, 150, 200];

  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _customMealTimeController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isStoringMeal = false;
  bool _isTogglingFavorite = false;
  /// Built at display time so it follows the current language.
  String Function(AppLocalizations l10n)? _errorMessage;
  late String _mealTime;
  bool _isCustomMealTime = false;
  DateTime _selectedDate = DateTime.now();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.food.isFavorite == 1;
    final initial = (widget.initialMealTime ?? mealTimeForNow()).toLowerCase();
    if (mainMealTimes.contains(initial)) {
      _mealTime = initial;
    } else {
      _mealTime = 'custom';
      _isCustomMealTime = true;
      _customMealTimeController.text = initial;
    }
    _quantityController.text = '100';
  }

  double? get _grams => double.tryParse(_quantityController.text.trim().replaceAll(',', '.'));

  bool get _isToday => DateUtils.isSameDay(_selectedDate, DateTime.now());

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showAdaptiveDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _storeMeal() async {
    final name = widget.food.name.trim();

    final mealTime = _isCustomMealTime ? _customMealTimeController.text.trim() : _mealTime;
    if (mealTime.isEmpty) {
      setState(() => _errorMessage = (l10n) => l10n.foodDetailsMealNameRequired);
      return;
    }

    final quantity = _grams;
    if (quantity == null || quantity <= 0) {
      setState(() => _errorMessage = (l10n) => l10n.foodDetailsGramsRequired);
      return;
    }

    final mealDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    setState(() {
      _isStoringMeal = true;
      _errorMessage = null;
    });

    try {
      await _apiService.storeMeal(name, quantity, mealTime.toLowerCase(), mealDate);
      if (!mounted) return;
      final kcal = (widget.food.calories * quantity / 100).round();
      Navigator.pop(
        context,
        AppLocalizations.of(context)!.foodDetailsAddedSnack(
          quantity.round(),
          name,
          mealTimeLabel(mealTime.toLowerCase()),
          kcal,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      final message = friendlyError(error);
      setState(() => _errorMessage = (l10n) => l10n.foodDetailsAddFailed(message));
    } finally {
      if (mounted) setState(() => _isStoringMeal = false);
    }
  }

  Future<void> toggleFavoriteFood() async {
    if (_isTogglingFavorite) return;

    setState(() {
      _isTogglingFavorite = true;
    });

    try {
      if (_isFavorite) {
        await _apiService.removeFavoriteFood(widget.food.id);
        if (!mounted) return;
        _showFeedback(AppLocalizations.of(context)!.foodDetailsRemovedFromFavorites);
      } else {
        await _apiService.addFavoriteFood(widget.food.id);
        if (!mounted) return;
        _showFeedback(AppLocalizations.of(context)!.foodDetailsAddedToFavorites);
      }
      if (!mounted) return;
      Provider.of<FoodProvider>(context, listen: false).refreshFoods();
      setState(() {
        _isFavorite = !_isFavorite;
      });
    } catch (error) {
      if (!mounted) return;
      _showFeedback(
        AppLocalizations.of(context)!.foodDetailsFavoritesFailed(friendlyError(error)),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isTogglingFavorite = false;
        });
      }
    }
  }

  void _showFeedback(String message, {bool isError = false}) {
    if (!mounted) return;
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
        action: isError
            ? SnackBarAction(
                label: AppLocalizations.of(context)!.retry,
                textColor: colorScheme.onError,
                onPressed: toggleFavoriteFood,
              )
            : null,
      ),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _customMealTimeController.dispose();
    super.dispose();
  }

  String _fmt(double v) => v == v.roundToDouble() ? '${v.round()}' : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final food = widget.food;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        centerTitle: true,
        actions: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: _isTogglingFavorite
                  ? SizedBox(
                      key: const ValueKey('loading'),
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.error,
                      ),
                    )
                  : Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      key: ValueKey(_isFavorite),
                      color: colorScheme.error,
                    ),
            ),
            onPressed: _isTogglingFavorite ? null : toggleFavoriteFood,
            tooltip: _isFavorite ? l10n.foodDetailsRemoveFromFavoritesTooltip : l10n.foodDetailsAddToFavoritesTooltip,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAddCard(colorScheme),
            const SizedBox(height: 16),
            // Nutrition Facts Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.foodDetailsNutritionPer100g,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _nutritionItem(Icons.local_fire_department, l10n.homeMacroCalories,
                            "${_fmt(food.calories)} kcal", Colors.red.shade400, colorScheme.onSurfaceVariant),
                        const SizedBox(width: 12),
                        _nutritionItem(Icons.fitness_center, l10n.homeMacroProtein, "${_fmt(food.protein)} g",
                            Colors.blue.shade400, colorScheme.onSurfaceVariant),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _nutritionItem(Icons.grain, l10n.homeMacroCarbs, "${_fmt(food.carbs)} g",
                            Colors.green.shade400, colorScheme.onSurfaceVariant),
                        const SizedBox(width: 12),
                        _nutritionItem(Icons.water_drop, l10n.homeMacroFat, "${_fmt(food.fats)} g",
                            Colors.orange.shade400, colorScheme.onSurfaceVariant),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCard(ColorScheme colorScheme) {
    final grams = _grams;
    final food = widget.food;
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.foodDetailsHowMuch,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _quantityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                labelText: l10n.foodDetailsAmountLabel,
                suffixText: l10n.foodDetailsGramsSuffix,
                prefixIcon: const Icon(Icons.scale),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _quickAmounts.map((g) {
                return ChoiceChip(
                  showCheckmark: false,
                  label: Text('$g g'),
                  selected: grams == g.toDouble(),
                  onSelected: (_) => setState(() => _quantityController.text = '$g'),
                );
              }).toList(),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.foodDetailsPortionHint,
              style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            // Live total so people see what they're about to log.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                grams == null || grams <= 0
                    ? l10n.foodDetailsEnterAmountForCalories
                    : l10n.foodDetailsLiveTotal(
                        _fmt(grams),
                        (food.calories * grams / 100).round(),
                        _fmt(food.protein * grams / 100),
                        _fmt(food.carbs * grams / 100),
                        _fmt(food.fats * grams / 100),
                      ),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colorScheme.onPrimaryContainer),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.foodDetailsWhichMeal,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                ...mainMealTimes.map((m) => ChoiceChip(
                      label: Text(m == 'snack' ? l10n.foodDetailsSnackChip : mealTimeLabel(m)),
                      selected: !_isCustomMealTime && _mealTime == m,
                      onSelected: (_) => setState(() {
                        _mealTime = m;
                        _isCustomMealTime = false;
                      }),
                    )),
                ChoiceChip(
                  label: Text(l10n.foodDetailsOtherMeal),
                  selected: _isCustomMealTime,
                  onSelected: (_) => setState(() {
                    _mealTime = 'custom';
                    _isCustomMealTime = true;
                  }),
                ),
              ],
            ),
            if (_isCustomMealTime) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _customMealTimeController,
                decoration: InputDecoration(
                  labelText: l10n.foodDetailsMealNameLabel,
                  hintText: l10n.foodDetailsMealNameHint,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.event, size: 20, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isToday
                        ? l10n.homeToday
                        : DateFormat.MMMMEEEEd(Localizations.localeOf(context).toString()).format(_selectedDate),
                    style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
                  ),
                ),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: Text(l10n.foodDetailsChangeDate),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isStoringMeal ? null : _storeMeal,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isStoringMeal
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onPrimary),
                      )
                    : Text(
                        _isCustomMealTime ? l10n.foodDetailsAddToMealButton : l10n.foodDetailsAddToButton(mealTimeLabel(_mealTime)),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _errorMessage!(l10n),
                    style: TextStyle(fontSize: 15, color: colorScheme.onErrorContainer),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _nutritionItem(
    IconData icon,
    String label,
    String value,
    Color color,
    Color labelColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 14, color: labelColor)),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
