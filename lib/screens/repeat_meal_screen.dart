import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../services/api_service.dart';
import '../utils/friendly_error.dart';
import '../utils/l10n.dart';
import '../utils/labels.dart';
import 'home_screen.dart';

/// One meal time on one past day: every food logged then, as the API returns
/// them (food fields plus `pivot.quantity` in grams).
class PastMeal {
  final String date;
  final List<dynamic> foods;

  const PastMeal(this.date, this.foods);

  double get calories => (MealTotals()..addFoods(foods)).calories;
}

/// Past versions of [mealTime] in [meals] (the API's meal rows), newest
/// first. A day that ate exactly the same foods and grams as a newer day is
/// left out, so a meal prepper sees their one usual meal once, not 30 times.
List<PastMeal> pastMealVersions(List<dynamic> meals, String mealTime) {
  final byDate = <String, List<dynamic>>{};
  for (final meal in meals) {
    if ((meal['meal_time'] ?? 'snack').toString().toLowerCase() != mealTime) continue;
    final date = meal['date'].toString().substring(0, 10);
    byDate.putIfAbsent(date, () => []).addAll(meal['foods'] ?? []);
  }
  final dates = byDate.keys.toList()..sort((a, b) => b.compareTo(a));
  final seen = <String>{};
  final versions = <PastMeal>[];
  for (final date in dates) {
    final foods = byDate[date]!;
    if (foods.isEmpty) continue;
    final key = (foods.map((f) => '${f['id']}:${f['pivot']['quantity']}').toList()..sort()).join(',');
    if (seen.add(key)) versions.add(PastMeal(date, foods));
  }
  return versions;
}

/// "Yesterday", or the weekday and date in the app's language.
String pastDayLabel(BuildContext context, String date) {
  final yesterday = DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 1)));
  if (date == yesterday) return AppLocalizations.of(context)!.homeYesterday;
  return DateFormat.MMMMEEEEd(Localizations.localeOf(context).toString()).format(DateTime.parse(date));
}

/// Lets the person pick one of [versions] to copy. Returns the one picked.
Future<PastMeal?> showCopyMealSheet(BuildContext context, String mealTime, List<PastMeal> versions) {
  return showModalBottomSheet<PastMeal>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      final colorScheme = Theme.of(context).colorScheme;
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            Text(l10n.copyMealSheetTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(
              l10n.copyMealSheetSubtitle(mealTimeLabel(mealTime)),
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            for (final version in versions)
              Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  title: Text(
                    pastDayLabel(context, version.date),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${version.calories.round()} kcal · ${version.foods.map((f) => localizedName(f)).join(', ')}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pop(context, version),
                ),
              ),
          ],
        ),
      );
    },
  );
}

class _Item {
  final Map<String, dynamic> food;
  final TextEditingController grams;
  bool selected = true;

  _Item(this.food)
      : grams = TextEditingController(text: _format((food['pivot']['quantity'] as num).toDouble()));

  static String _format(double grams) =>
      grams == grams.roundToDouble() ? grams.round().toString() : grams.toStringAsFixed(1);

  double get gramsValue => double.tryParse(grams.text.trim().replaceAll(',', '.')) ?? 0;

  double get kcal => (food['calories'] as num).toDouble() * gramsValue / 100;
}

/// Review screen for logging a past meal again today: every food starts
/// ticked with the grams eaten then. Pops with the confirmation message once
/// logged.
class RepeatMealScreen extends StatefulWidget {
  final String mealTime;
  final PastMeal source;

  const RepeatMealScreen({super.key, required this.mealTime, required this.source});

  @override
  State<RepeatMealScreen> createState() => _RepeatMealScreenState();
}

class _RepeatMealScreenState extends State<RepeatMealScreen> {
  static const _step = 10.0;

  late final List<_Item> _items = widget.source.foods.map((f) => _Item(Map<String, dynamic>.from(f))).toList();
  bool _saving = false;

  @override
  void dispose() {
    for (final item in _items) {
      item.grams.dispose();
    }
    super.dispose();
  }

  List<_Item> get _chosen => _items.where((i) => i.selected && i.gramsValue > 0).toList();

  void _nudge(_Item item, double delta) {
    final next = ((item.gramsValue + delta) / _step).round() * _step;
    setState(() {
      item.grams.text = _Item._format(next < _step ? _step : next);
      item.selected = true;
    });
  }

  Future<void> _log() async {
    final l10n = AppLocalizations.of(context)!;
    final chosen = _chosen;
    if (chosen.isEmpty) return;
    setState(() => _saving = true);
    try {
      // One request for the whole meal, by food id, so it is logged
      // completely or not at all.
      await ApiService().storeMealFoods(
        widget.mealTime,
        DateFormat('yyyy-MM-dd').format(DateTime.now()),
        [
          for (final item in chosen) {'food_id': item.food['id'], 'quantity': item.gramsValue},
        ],
      );
      if (!mounted) return;
      final kcal = chosen.fold(0.0, (sum, i) => sum + i.kcal);
      Navigator.pop(context, l10n.mealScanLogged(chosen.length, mealTimeLabel(widget.mealTime), kcal.round()));
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.mealScanLogFailed(friendlyError(e)))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final chosen = _chosen;
    final kcal = chosen.fold(0.0, (sum, i) => sum + i.kcal);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.repeatMealTitle(mealTimeLabel(widget.mealTime)),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              pastDayLabel(context, widget.source.date),
              style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: [
          Text(l10n.repeatMealHint, style: TextStyle(color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          for (final item in _items) _buildItem(item, l10n, colorScheme),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton(
            onPressed: _saving || chosen.isEmpty ? null : _log,
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            child: _saving
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                : Text(
                    l10n.repeatMealLogButton(chosen.length, kcal.round()),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(_Item item, AppLocalizations l10n, ColorScheme colorScheme) {
    final name = localizedName(item.food);
    final faded = !item.selected;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 6, 8, 6),
        child: Row(
          children: [
            Checkbox.adaptive(
              value: item.selected,
              onChanged: _saving ? null : (v) => setState(() => item.selected = v ?? false),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: faded ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
                      decoration: faded ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  Text(
                    '${item.kcal.round()} kcal',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: l10n.repeatMealLess,
              onPressed: _saving ? null : () => _nudge(item, -_step),
              icon: const Icon(Icons.remove_circle_outline),
            ),
            SizedBox(
              width: 72,
              child: Semantics(
                label: l10n.repeatMealGrams(name),
                child: TextField(
                controller: item.grams,
                enabled: !_saving,
                textAlign: TextAlign.center,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                decoration: InputDecoration(
                  isDense: true,
                  suffixText: 'g',
                  border: const OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() => item.selected = true),
              ),
              ),
            ),
            IconButton(
              tooltip: l10n.repeatMealMore,
              onPressed: _saving ? null : () => _nudge(item, _step),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ),
    );
  }
}
