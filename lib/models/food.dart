import '../services/locale_service.dart';
import '../utils/l10n.dart';

class Food {
  final int id;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final int isFavorite;

  Food({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.isFavorite = 0,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    // Check if the JSON contains nutriments (Open Food Facts API format)
    if (json.containsKey('nutriments')) {
      final nutriments = json['nutriments'] ?? {};
      return Food(
        id: json['id'] is int
            ? json['id'] as int
            : int.tryParse(json['id'].toString()) ?? 0,
        name: scannedFoodName(json),
        calories: nutriments['energy-kcal_100g'] is num
            ? (nutriments['energy-kcal_100g'] as num).toDouble()
            : double.tryParse(nutriments['energy-kcal_100g']?.toString() ?? '') ?? 0.0,
        protein: nutriments['proteins_100g'] is num
            ? (nutriments['proteins_100g'] as num).toDouble()
            : double.tryParse(nutriments['proteins_100g']?.toString() ?? '') ?? 0.0,
        carbs: nutriments['carbohydrates_100g'] is num
            ? (nutriments['carbohydrates_100g'] as num).toDouble()
            : double.tryParse(nutriments['carbohydrates_100g']?.toString() ?? '') ?? 0.0,
        fats: nutriments['fat_100g'] is num
            ? (nutriments['fat_100g'] as num).toDouble()
            : double.tryParse(nutriments['fat_100g']?.toString() ?? '') ?? 0.0,
      );
    } else {
      // Otherwise, assume the JSON is from your local foods table
      return Food(
        id: json['id'] is int
            ? json['id'] as int
            : int.tryParse(json['id'].toString()) ?? 0,
        name: localizedName(json, fallback: 'Unknown'),
        calories: (json['calories'] as num).toDouble(),
        protein: (json['protein'] as num).toDouble(),
        carbs: (json['carbs'] as num).toDouble(),
        fats: (json['fats'] as num).toDouble(),
        isFavorite: json['is_favorite'] ?? 0,
      );
    }
  }
}

/// A readable name for an Open Food Facts product: its name in the app's
/// language (or its default name), then the brand when the name doesn't
/// already say it, e.g. "Pâte à tartiner, Nutella". Symbols such as
/// brackets, slashes or "®" are dropped.
String scannedFoodName(Map<String, dynamic> product) {
  final lang = LocaleService.languageCode;
  String? pick(List<String> keys) {
    for (final key in keys) {
      final value = product[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  final name = pick([
    'product_name_$lang',
    'product_name',
    'generic_name_$lang',
    'generic_name',
  ]);
  final brand = product['brands']?.toString().split(',').first.trim();
  final hasBrand = brand != null && brand.isNotEmpty;

  var result = name ?? (hasBrand ? brand : '');
  if (name != null && hasBrand && !name.toLowerCase().contains(brand.toLowerCase())) {
    result = '$name, $brand';
  }
  result = result
      .replaceAll(RegExp(r"[^\p{L}\p{N} ,'\-]", unicode: true), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll(RegExp(r'\s+,'), ',')
      .trim();
  return result.isEmpty ? 'Unknown' : result;
}
