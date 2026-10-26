import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_tracker_app/l10n/app_localizations.dart';
import 'package:fitness_tracker_app/screens/repeat_meal_screen.dart';

Map<String, dynamic> food(int id, String name, num kcal, num grams) => {
      'id': id,
      'name': name,
      'calories': kcal,
      'protein': 0,
      'carbs': 0,
      'fats': 0,
      'pivot': {'meal_id': 1, 'id': id * 10, 'quantity': grams},
    };

Map<String, dynamic> meal(String date, String mealTime, List<Map<String, dynamic>> foods) =>
    {'date': '${date}T00:00:00.000000Z', 'meal_time': mealTime, 'foods': foods};

void main() {
  group('pastMealVersions', () {
    test('joins the rows of one day and keeps each different meal once, newest first', () {
      final meals = [
        // Logged food by food, the way single foods are saved.
        meal('2026-10-25', 'breakfast', [food(1, 'Oats', 389, 60)]),
        meal('2026-10-25', 'breakfast', [food(2, 'Banana', 89, 120)]),
        // The same breakfast in the other order: not shown again.
        meal('2026-10-24', 'breakfast', [food(2, 'Banana', 89, 120), food(1, 'Oats', 389, 60)]),
        // Different grams: a version of its own.
        meal('2026-10-23', 'breakfast', [food(1, 'Oats', 389, 80)]),
        meal('2026-10-25', 'lunch', [food(3, 'Rice', 130, 200)]),
      ];

      final versions = pastMealVersions(meals, 'breakfast');

      expect(versions.map((v) => v.date), ['2026-10-25', '2026-10-23']);
      expect(versions.first.foods.map((f) => f['id']), [1, 2]);
      expect(versions.first.calories.round(), 340);
    });

    test('custom meal names match in lower case', () {
      final versions = pastMealVersions([
        meal('2026-10-25', 'Pre-workout', [food(1, 'Oats', 389, 60)]),
      ], 'pre-workout');
      expect(versions, hasLength(1));
    });
  });

  testWidgets('review screen totals only the ticked foods and steps grams by 10', (tester) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: RepeatMealScreen(
        mealTime: 'breakfast',
        source: PastMeal('2026-10-25', [food(1, 'Oats', 400, 50), food(2, 'Banana', 100, 100)]),
      ),
    ));

    expect(find.text('Add 2 foods · 300 kcal'), findsOneWidget);

    await tester.tap(find.byType(Checkbox).last);
    await tester.pump();
    expect(find.text('Add 1 food · 200 kcal'), findsOneWidget);

    await tester.tap(find.byTooltip('More').first);
    await tester.pump();
    expect(find.text('60'), findsOneWidget);
    expect(find.text('Add 1 food · 240 kcal'), findsOneWidget);
  });
}
