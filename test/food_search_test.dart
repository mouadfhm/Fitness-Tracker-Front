import 'package:fitness_tracker_app/utils/food_search.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('matches every word in any order', () {
    const name = 'Chicken (Broilers Or Fryers, Breast, Meat Only, Cooked)';
    expect(foodMatchesQuery(name, 'chicken breast'), isTrue);
    expect(foodMatchesQuery(name, 'breast chicken'), isTrue);
    expect(foodMatchesQuery(name, 'chicken thigh'), isFalse);
    expect(foodMatchesQuery(name, ''), isTrue);
  });

  test('plain foods come before baby food and partial matches', () {
    final names = [
      'Fruit Babyfood (Bananas&pnappl, Str)',
      'Banana Chips',
      'Plantains, Raw (banana family)',
      'Bananas (Raw)',
    ];
    expect(searchFoods(names, 'banana', (n) => n), [
      'Banana Chips',
      'Bananas (Raw)',
      'Plantains, Raw (banana family)',
      'Fruit Babyfood (Bananas&pnappl, Str)',
    ]);
  });

  test('baby food is not pushed down when searched for', () {
    expect(foodSearchRank('Fruit Babyfood (Pears, Str)', 'baby'), lessThan(3));
  });
}
