import 'package:fitness_tracker_app/providers/food_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class FoodDetailsScreen extends StatefulWidget {
  final Food food;
  const FoodDetailsScreen({super.key, required this.food});

  @override
  State<FoodDetailsScreen> createState() => _FoodDetailsScreenState();
}

class _FoodDetailsScreenState extends State<FoodDetailsScreen> {
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _customMealTimeController =
      TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isStoringMeal = false;
  bool _isTogglingFavorite = false;
  String? _storeMealMessage;
  String? _selectedTime;
  bool _isCustomMealTime = false;
  DateTime _selectedDate = DateTime.now();
  bool _isFavorite = false;

  final List<String> _predefinedMealTimes = [
    "Breakfast",
    "Lunch",
    "Dinner",
    "Snack",
    "Morning Snack",
    "Afternoon Snack",
    "Evening Snack",
    "Pre-workout",
    "Post-workout",
    "Custom"
  ];

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.food.isFavorite == 1;
  }

  Future<void> _selectDate(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: colorScheme.primary,
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

  void _storeMeal() async {
    final name = widget.food.name.trim();
    final quantityText = _quantityController.text.trim();
    if (quantityText.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please enter a quantity")));
      return;
    }

    String? mealTime;
    if (_isCustomMealTime) {
      mealTime = _customMealTimeController.text.trim();
      if (mealTime.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please enter a meal time")));
        return;
      }
    } else {
      mealTime = _selectedTime;
      if (mealTime == null || mealTime.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please select a meal time")));
        return;
      }
    }

    final double? quantity = double.tryParse(quantityText);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter a valid quantity")));
      return;
    }

    final mealTimeValue = mealTime.toLowerCase();
    final mealDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    setState(() {
      _isStoringMeal = true;
      _storeMealMessage = null;
    });

    try {
      await _apiService.storeMeal(name, quantity, mealTimeValue, mealDate);
      if (!mounted) return;
      setState(() {
        _storeMealMessage = "Meal stored successfully!";
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _storeMealMessage = "Error: ${error.toString()}";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isStoringMeal = false;
        });
      }
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
        _showFeedback("Removed from favorites");
      } else {
        await _apiService.addFavoriteFood(widget.food.id);
        _showFeedback("Added to favorites");
      }
      if (!mounted) return;
      Provider.of<FoodProvider>(context, listen: false).refreshFoods();
      setState(() {
        _isFavorite = !_isFavorite;
      });
    } catch (error) {
      _showFeedback(
        "Error updating favorites: ${error.toString()}",
        isError: true,
      );
    } finally {
      setState(() {
        _isTogglingFavorite = false;
      });
    }
  }

  void _showFeedback(String message, {bool isError = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
        action: isError
            ? SnackBarAction(
                label: 'Retry',
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.food.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
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
            tooltip:
                _isFavorite ? 'Remove from favorites' : 'Add to favorites',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nutrition Facts Card
              Card(
                elevation: 2,
                color: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                      color: colorScheme.primary.withValues(alpha: 0.15)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Nutrition Facts",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 20),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          double spacing = constraints.maxWidth * 0.05;
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _nutritionItem(
                                    Icons.local_fire_department,
                                    "Calories",
                                    "${widget.food.calories}",
                                    Colors.red.shade400,
                                    colorScheme.onSurfaceVariant,
                                  ),
                                  SizedBox(width: spacing),
                                  _nutritionItem(
                                    Icons.fitness_center,
                                    "Protein",
                                    "${widget.food.protein}g",
                                    Colors.blue.shade400,
                                    colorScheme.onSurfaceVariant,
                                  ),
                                ],
                              ),
                              SizedBox(height: spacing),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _nutritionItem(
                                    Icons.grain,
                                    "Carbs",
                                    "${widget.food.carbs}g",
                                    Colors.green.shade400,
                                    colorScheme.onSurfaceVariant,
                                  ),
                                  SizedBox(width: spacing),
                                  _nutritionItem(
                                    Icons.water_drop,
                                    "Fats",
                                    "${widget.food.fats}g",
                                    Colors.orange.shade400,
                                    colorScheme.onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Add to Meal Card
              Card(
                elevation: 2,
                color: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                      color: colorScheme.primary.withValues(alpha: 0.15)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Add to Meal Plan",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Date Picker
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: colorScheme.outlineVariant),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('EEE, MMM d, yyyy')
                                    .format(_selectedDate),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Icon(Icons.calendar_today,
                                  color: colorScheme.onSurfaceVariant),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Meal Time Selection
                      if (!_isCustomMealTime)
                        DropdownButtonFormField<String>(
                          value: _selectedTime,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: colorScheme.outlineVariant),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: colorScheme.outlineVariant),
                            ),
                            prefixIcon: Icon(Icons.access_time,
                                color: colorScheme.onSurfaceVariant),
                            hintText: "Select Meal Time",
                            hintStyle: TextStyle(
                                color: colorScheme.onSurfaceVariant),
                          ),
                          style: TextStyle(color: colorScheme.onSurface),
                          dropdownColor: colorScheme.surface,
                          items: _predefinedMealTimes.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedTime = value;
                              _isCustomMealTime = value == "Custom";
                            });
                          },
                        ),

                      // Custom Meal Time Input
                      if (_isCustomMealTime)
                        Column(
                          children: [
                            TextField(
                              controller: _customMealTimeController,
                              style: TextStyle(color: colorScheme.onSurface),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: colorScheme.surfaceContainerHighest,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 16,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: colorScheme.outlineVariant),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: colorScheme.outlineVariant),
                                ),
                                prefixIcon: Icon(Icons.access_time,
                                    color: colorScheme.onSurfaceVariant),
                                hintText: "Enter Custom Meal Time",
                                hintStyle: TextStyle(
                                    color: colorScheme.onSurfaceVariant),
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.close,
                                      color: colorScheme.onSurfaceVariant),
                                  onPressed: () {
                                    setState(() {
                                      _isCustomMealTime = false;
                                      _selectedTime = null;
                                      _customMealTimeController.clear();
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Examples: Mid-morning, Late-night, Second Breakfast, etc.",
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 16),

                      // Quantity Input
                      TextField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: colorScheme.onSurface),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: colorScheme.outlineVariant),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: colorScheme.outlineVariant),
                          ),
                          prefixIcon: Icon(Icons.scale,
                              color: colorScheme.onSurfaceVariant),
                          hintText: "Quantity (grams)",
                          hintStyle:
                              TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Add to Meal Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isStoringMeal ? null : _storeMeal,
                          style: ElevatedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 15),
                            foregroundColor: colorScheme.onPrimary,
                            backgroundColor: colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          child: _isStoringMeal
                              ? CircularProgressIndicator(
                                  color: colorScheme.onPrimary)
                              : const Text(
                                  "Add to Meal",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      // Error/Success Message
                      if (_storeMealMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _storeMealMessage!.startsWith("Error")
                                  ? colorScheme.errorContainer
                                  : colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _storeMealMessage!,
                              style: TextStyle(
                                fontSize: 16,
                                color: _storeMealMessage!.startsWith("Error")
                                    ? colorScheme.onErrorContainer
                                    : colorScheme.onPrimaryContainer,
                              ),
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
                  Text(label,
                      style: TextStyle(fontSize: 14, color: labelColor)),
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
