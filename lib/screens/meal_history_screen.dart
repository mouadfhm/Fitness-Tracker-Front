import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'home_screen.dart' show MealTotals;
import 'meal_detail_screen.dart';
import '../utils/labels.dart';
import '../l10n/app_localizations.dart';

/// Past days' meals. Home only shows today; older days live here so the main
/// screen stays focused on what someone is doing right now.
class MealHistoryScreen extends StatelessWidget {
  final List<dynamic> meals;

  const MealHistoryScreen({super.key, required this.meals});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    // date -> meal time -> foods
    final byDate = <String, Map<String, List<dynamic>>>{};
    for (final meal in meals) {
      final date = meal['date'].toString().substring(0, 10);
      final mealTime = (meal['meal_time'] ?? 'snack').toString().toLowerCase();
      byDate
          .putIfAbsent(date, () => {})
          .putIfAbsent(mealTime, () => [])
          .addAll(meal['foods'] ?? []);
    }
    final dates = byDate.keys.toList()..sort((a, b) => b.compareTo(a));
    final yesterday = DateFormat('yyyy-MM-dd')
        .format(DateTime.now().subtract(const Duration(days: 1)));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.mealHistoryTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: dates.isEmpty
          ? Center(
              child: Text(
                l10n.mealHistoryEmpty,
                style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: dates.length,
              itemBuilder: (context, index) {
                final date = dates[index];
                final mealsForDay = byDate[date]!;
                final dayTotals = MealTotals();
                mealsForDay.values.forEach(dayTotals.addFoods);
                final title = date == yesterday
                    ? l10n.homeYesterday
                    : DateFormat.MMMMEEEEd(locale).format(DateTime.parse(date));
                final mealTimes = [
                  ...mainMealTimes.where(mealsForDay.containsKey),
                  ...mealsForDay.keys.where((m) => !mainMealTimes.contains(m)).toList()..sort(),
                ];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  clipBehavior: Clip.antiAlias,
                  child: ExpansionTile(
                    shape: const Border(),
                    title: Text(
                      title,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(l10n.mealHistoryKcalEaten(dayTotals.calories.round())),
                    children: mealTimes.map((mealTime) {
                      final foods = mealsForDay[mealTime]!;
                      final totals = MealTotals()..addFoods(foods);
                      return ListTile(
                        title: Text(mealTimeLabel(mealTime)),
                        subtitle: Text(
                          '${totals.calories.round()} kcal · '
                          '${foods.map((f) => f['name']).join(', ')}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MealDetailScreen(mealTime: mealTime, foods: foods),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
    );
  }
}
