import 'package:fitness_tracker_app/providers/food_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parseFoodList reads the compact list the server sends', () {
    const body = '[{"id":7,"display_name":"Banane","calories":89,'
        '"protein":1.1,"carbs":22.8,"fats":0.3,"is_favorite":1}]';

    final food = parseFoodList(body).single;

    expect(food.id, 7);
    expect(food.name, 'Banane');
    expect(food.calories, 89.0);
    expect(food.fats, 0.3);
    expect(food.isFavorite, 1);
  });

  test('parseFoodList still reads the older, longer list', () {
    const body = '[{"id":"3","name":"BANANAS,RAW","name_en":"Banana","name_fr":"Banane",'
        '"display_name":"Banana","calories":89.0,"protein":1.1,"carbs":22.8,'
        '"fats":0.3,"added_by":null,"meals_count":2,"is_favorite":0}]';

    final food = parseFoodList(body).single;

    expect(food.id, 3);
    expect(food.name, 'Banana');
    expect(food.isFavorite, 0);
  });
}
