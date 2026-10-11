import 'package:flutter/material.dart';
import '../models/food.dart';
import '../services/api_service.dart';
import '../services/locale_service.dart';
import '../utils/friendly_error.dart';

class FoodProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Food> _foods = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Food> get foods => _foods;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  /// The app language the list was loaded in. Food names come from the
  /// server in that language, so a list from another language is stale.
  String? _loadedLanguage;
  bool get isStaleLanguage => _loadedLanguage != LocaleService.languageCode;

  FoodProvider() {
    fetchFoods();
  }

  Future<void> fetchFoods() async {
    _isLoading = true;
    notifyListeners();
    final language = LocaleService.languageCode;
    try {
      final data = await _apiService.getFoods();
      _foods = data.map((json) => Food.fromJson(json)).toList();
      _errorMessage = '';
      _loadedLanguage = language;
    } catch (e) {
      _errorMessage = "Couldn't load foods. ${friendlyError(e)}";
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshFoods() async {
    await fetchFoods();
  }

  // Optionally, implement a method to add a food to the list.
  Future<void> addFood(Food newFood) async {
    _apiService.addFood(
      newFood.name,
      newFood.calories,
      newFood.protein,
      newFood.carbs,
      newFood.fats,
    );
    refreshFoods();
    notifyListeners();
  }
}
