import 'package:fitness_tracker_app/models/food.dart';
import 'package:fitness_tracker_app/providers/exercise_provider.dart';
import 'package:fitness_tracker_app/services/locale_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => LocaleService.languageCode = 'en');

  test('a scanned product is named by its name in the app language and its brand', () {
    final product = {
      'product_name': 'Hazelnut spread',
      'product_name_fr': 'Pâte à tartiner (noisettes)',
      'brands': 'Nutella®, Ferrero',
      '_keywords': ['nutella', 'pate', 'tartiner'],
    };
    expect(scannedFoodName(product), 'Hazelnut spread, Nutella');

    LocaleService.languageCode = 'fr';
    expect(scannedFoodName(product), 'Pâte à tartiner noisettes, Nutella');
  });

  test('a scanned product without a name falls back to its brand, then Unknown', () {
    expect(scannedFoodName({'brands': 'Pace'}), 'Pace');
    expect(scannedFoodName({'product_name': 'Pace picante sauce', 'brands': 'Pace'}), 'Pace picante sauce');
    expect(scannedFoodName({}), 'Unknown');
  });

  test('activities are grouped by category, or by their name on older servers', () {
    final activity = {
      'name': 'Running',
      'category': 'Running and athletics',
      'display_category': 'Course et athlétisme',
      'display_name': 'Course à 8 km à l\'heure',
    };
    expect(ExercisesProvider.categoryOf(activity), 'Running and athletics');
    expect(ExercisesProvider.categoryLabelOf(activity), 'Course et athlétisme');

    final old = {'name': 'Running', 'display_name': 'Course'};
    expect(ExercisesProvider.categoryOf(old), 'Running');
    expect(ExercisesProvider.categoryLabelOf(old), 'Course');
  });
}
