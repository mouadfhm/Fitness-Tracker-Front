import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/food.dart';
import '../services/api_service.dart';
import '../services/food_cache.dart';
import '../services/locale_service.dart';
import '../utils/friendly_error.dart';

/// Parses the server's food list. Run through [compute]: ~17k foods take long
/// enough to drop frames on the UI isolate.
List<Food> parseFoodList(String body) => [
      for (final json in jsonDecode(body) as List)
        Food.fromJson(json as Map<String, dynamic>),
    ];

class FoodProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Food> _foods = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Food> get foods => _foods;

  /// True only while there is nothing to show yet: a saved list is shown at
  /// once and refreshed quietly behind it.
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  /// The app language the list was loaded in. Food names come from the
  /// server in that language, so a list from another language is stale.
  String? _loadedLanguage;
  bool get isStaleLanguage => _loadedLanguage != LocaleService.languageCode;

  /// The server's ETag for [_foods], so an unchanged list costs a 304.
  String? _etag;
  Future<void>? _fetching;

  FoodProvider() {
    fetchFoods();
  }

  /// Shows the saved list for the app language if there is one, then asks
  /// the server for changes. A call made while one runs shares it, unless
  /// the language changed meanwhile.
  Future<void> fetchFoods() async {
    while (_fetching != null) {
      await _fetching;
      if (!isStaleLanguage) return;
    }
    final fetching = _fetching = _fetchFoods();
    try {
      await fetching;
    } finally {
      _fetching = null;
    }
  }

  Future<void> _fetchFoods() async {
    final language = LocaleService.languageCode;
    if (_loadedLanguage != language) await _showSaved(language);

    _isLoading = _loadedLanguage != language;
    notifyListeners();
    try {
      final result = await _apiService.getFoods(
        etag: _loadedLanguage == language ? _etag : null,
      );
      final body = result.body;
      if (body != null) {
        _foods = await compute(parseFoodList, body);
        _etag = result.etag;
        _loadedLanguage = language;
        FoodCache.write(language, body, result.etag);
      }
      _errorMessage = '';
    } catch (e) {
      // With a saved list on screen, a failed refresh (offline, say) can
      // wait for the next one instead of hiding it behind an error.
      if (_loadedLanguage != language) {
        _errorMessage = "Couldn't load foods. ${friendlyError(e)}";
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _showSaved(String language) async {
    final saved = await FoodCache.read(language);
    if (saved == null) return;
    try {
      _foods = await compute(parseFoodList, saved.body);
      _etag = saved.etag;
      _loadedLanguage = language;
      _errorMessage = '';
      notifyListeners();
    } catch (_) {
      // An unreadable file: download the list as if there were none.
    }
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
