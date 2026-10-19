import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import '../models/food.dart';
import 'api_service.dart';
import 'locale_service.dart';

/// One food seen in a camera frame.
class FoodDetection {
  /// What was seen, matched to a food in the foods table (macros per 100 g).
  final Food food;

  /// Where it is in the frame, as fractions of the frame's width and height
  /// (0..1), so it maps onto the preview whatever its size on screen.
  final Rect box;

  /// Estimated portion in grams.
  final double grams;

  /// How sure the detector is, 0..1. Below [unsureBelow] the app marks the
  /// item so the person checks it.
  final double confidence;

  static const unsureBelow = 0.6;

  const FoodDetection({
    required this.food,
    required this.box,
    required this.grams,
    required this.confidence,
  });

  bool get isUnsure => confidence < unsureBelow;

  /// One item of the `POST /meals/scan` answer. A food the foods table
  /// doesn't have comes with id 0 and estimated macros per 100 g.
  factory FoodDetection.fromJson(Map<String, dynamic> json) {
    double number(Object? v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
    final box = (json['box'] as Map?) ?? const {};
    return FoodDetection(
      food: Food.fromJson(Map<String, dynamic>.from(json['food'] as Map)),
      box: Rect.fromLTWH(
        number(box['x']),
        number(box['y']),
        number(box['width']),
        number(box['height']),
      ),
      grams: number(json['grams']),
      confidence: number(json['confidence']),
    );
  }
}

/// Finds the foods in one camera frame.
abstract class MealDetector {
  Future<List<FoodDetection>> detect(Uint8List jpeg);
}

/// The backend's meal scanner: the frame goes to `POST /meals/scan`, where a
/// vision model (Claude Haiku) names each food, where it is and its portion,
/// and each one is matched to the foods table.
class ApiMealDetector implements MealDetector {
  final ApiService _api;

  ApiMealDetector([ApiService? api]) : _api = api ?? ApiService();

  @override
  Future<List<FoodDetection>> detect(Uint8List jpeg) async {
    final upright = await compute(prepareFrame, jpeg);
    final foods = await _api.scanMeal(upright);
    return [
      for (final item in foods.whereType<Map<String, dynamic>>())
        FoodDetection.fromJson(item),
    ];
  }
}

/// Turns a camera JPEG upright and shrinks it to at most 768 px on its long
/// side. Phone cameras often save the picture sideways with an orientation
/// tag, which the model would ignore, putting every box in the wrong place;
/// a smaller frame also uploads faster and costs fewer image tokens.
///
/// Runs in a background isolate (see [compute]).
Uint8List prepareFrame(Uint8List jpeg) {
  final decoded = img.decodeJpg(jpeg);
  if (decoded == null) return jpeg;
  var frame = img.bakeOrientation(decoded);
  const maxSide = 768;
  if (frame.width > maxSide || frame.height > maxSide) {
    frame = frame.width >= frame.height
        ? img.copyResize(frame, width: maxSide)
        : img.copyResize(frame, height: maxSide);
  }
  return img.encodeJpg(frame, quality: 80);
}

/// Answers with sample detections, for previews and screenshots without a
/// server: the foods appear over a few frames and the portions wobble a
/// little, the way live estimates settle while the camera moves. The
/// positions fit the sample fruit photo used for the screenshots.
class DemoMealDetector implements MealDetector {
  int _frame = 0;

  static String _name(String en, String fr) =>
      LocaleService.languageCode == 'fr' ? fr : en;

  static Food get _orange => Food(id: -1, name: _name('Orange', 'Orange'), calories: 47, protein: 0.9, carbs: 11.8, fats: 0.1);
  static Food get _kiwi => Food(id: -2, name: _name('Kiwi', 'Kiwi'), calories: 61, protein: 1.1, carbs: 14.7, fats: 0.5);
  static Food get _lemon => Food(id: -3, name: _name('Lemon', 'Citron'), calories: 29, protein: 1.1, carbs: 9.3, fats: 0.3);
  static Food get _lime => Food(id: -4, name: _name('Lime', 'Citron vert'), calories: 30, protein: 0.7, carbs: 10.5, fats: 0.2);
  static Food get _banana => Food(id: -5, name: _name('Banana', 'Banane'), calories: 89, protein: 1.1, carbs: 22.8, fats: 0.3);

  /// Foods the prototype's picker offers for "change" and "add".
  static List<Food> get sampleFoods => [
        _orange,
        _kiwi,
        _lemon,
        _lime,
        _banana,
        Food(id: -6, name: _name('Apple', 'Pomme'), calories: 52, protein: 0.3, carbs: 13.8, fats: 0.2),
        Food(id: -7, name: _name('Grapefruit', 'Pamplemousse'), calories: 42, protein: 0.8, carbs: 10.7, fats: 0.1),
        Food(id: -8, name: _name('Greek yogurt', 'Yaourt grec'), calories: 97, protein: 9, carbs: 3.9, fats: 5),
        Food(id: -9, name: _name('Granola', 'Granola'), calories: 471, protein: 10, carbs: 64, fats: 20),
        Food(id: -10, name: _name('Honey', 'Miel'), calories: 304, protein: 0.3, carbs: 82, fats: 0),
        Food(id: -11, name: _name('Almonds', 'Amandes'), calories: 579, protein: 21, carbs: 22, fats: 50),
        Food(id: -12, name: _name('Red cabbage', 'Chou rouge'), calories: 31, protein: 1.4, carbs: 7.4, fats: 0.2),
      ];

  @override
  Future<List<FoodDetection>> detect(Uint8List jpeg) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    final f = _frame++;
    // Small, repeatable wobble so the numbers visibly settle.
    double wobble(double grams, int seed) =>
        (grams + ((f * 7 + seed * 13) % 9 - 4) * (f < 3 ? 2.0 : 0.5)).roundToDouble();

    return [
      FoodDetection(
        food: _orange,
        box: const Rect.fromLTWH(0.16, 0.10, 0.50, 0.86),
        grams: wobble(130, 1),
        confidence: 0.94,
      ),
      if (f >= 1)
        FoodDetection(
          food: _kiwi,
          box: const Rect.fromLTWH(0.0, 0.60, 0.21, 0.40),
          grams: wobble(70, 2),
          confidence: 0.88,
        ),
      if (f >= 1)
        FoodDetection(
          food: _lemon,
          box: const Rect.fromLTWH(0.63, 0.52, 0.37, 0.48),
          grams: wobble(60, 3),
          confidence: 0.81,
        ),
      if (f >= 2)
        FoodDetection(
          food: _lime,
          box: const Rect.fromLTWH(0.63, 0.25, 0.36, 0.36),
          grams: wobble(65, 4),
          confidence: 0.52,
        ),
      if (f >= 2)
        FoodDetection(
          food: _banana,
          box: const Rect.fromLTWH(0.0, 0.20, 0.25, 0.40),
          grams: wobble(110, 5),
          confidence: 0.77,
        ),
    ];
  }
}
