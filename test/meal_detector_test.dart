import 'package:fitness_tracker_app/services/meal_detector.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  group('FoodDetection.fromJson', () {
    test('reads a food matched to the foods table', () {
      final d = FoodDetection.fromJson({
        'label': 'Banana, raw',
        'box': {'x': 0.1, 'y': 0.2, 'width': 0.3, 'height': 0.4},
        'grams': 118,
        'confidence': 0.92,
        'food': {
          'id': 42,
          'name': 'Raw Bananas',
          'display_name': 'Banane, crue',
          'calories': 89,
          'protein': 1.1,
          'carbs': 22.8,
          'fats': 0.3,
        },
      });

      expect(d.food.id, 42);
      expect(d.food.name, 'Banane, crue');
      expect(d.food.calories, 89);
      expect(d.box, const Rect.fromLTWH(0.1, 0.2, 0.3, 0.4));
      expect(d.grams, 118);
      expect(d.isUnsure, isFalse);
    });

    test('reads a food the table lacks, with id 0 and estimated macros', () {
      final d = FoodDetection.fromJson({
        'box': {'x': 0, 'y': 0, 'width': 1, 'height': 1},
        'grams': 300,
        'confidence': 0.4,
        'food': {
          'id': 0,
          'name': 'Tajine de poulet',
          'display_name': 'Tajine de poulet',
          'calories': 150.5,
          'protein': 12,
          'carbs': 8,
          'fats': 7,
        },
      });

      expect(d.food.id, 0);
      expect(d.food.name, 'Tajine de poulet');
      expect(d.food.calories, 150.5);
      expect(d.isUnsure, isTrue);
    });
  });

  group('prepareFrame', () {
    test('turns a sideways camera picture upright', () {
      // 40x20 pixels stored landscape, tagged "rotate 90° clockwise to view".
      final sideways = img.Image(width: 40, height: 20)..exif.imageIfd.orientation = 6;

      final upright = img.decodeJpg(prepareFrame(img.encodeJpg(sideways)))!;

      expect(upright.width, 20);
      expect(upright.height, 40);
    });

    test('shrinks a large picture to 768 px on its long side', () {
      final big = img.Image(width: 1000, height: 1500);

      final small = img.decodeJpg(prepareFrame(img.encodeJpg(big)))!;

      expect(small.height, 768);
      expect(small.width, 512);
    });
  });
}
