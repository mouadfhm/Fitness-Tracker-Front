// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import 'new_workout_cycle_screen.dart';

class _SuggestedCycle {
  final String name;
  final String description;
  final int weeks;
  final Set<String> activeDayKeys;

  const _SuggestedCycle({
    required this.name,
    required this.description,
    required this.weeks,
    required this.activeDayKeys,
  });
}

const List<_SuggestedCycle> _suggestedCycles = [
  _SuggestedCycle(
    name: 'Push Pull Legs',
    description:
        'A classic 6-day split hitting push, pull, and leg muscle groups twice per week.',
    weeks: 6,
    activeDayKeys: {'mon', 'tue', 'wed', 'thu', 'fri', 'sat'},
  ),
  _SuggestedCycle(
    name: 'Upper / Lower Split',
    description:
        'A balanced 4-day split alternating upper and lower body sessions, great for strength.',
    weeks: 6,
    activeDayKeys: {'mon', 'tue', 'thu', 'fri'},
  ),
  _SuggestedCycle(
    name: 'Full Body',
    description:
        'Train your whole body 3 times a week with a day of rest in between — ideal for beginners.',
    weeks: 8,
    activeDayKeys: {'mon', 'wed', 'fri'},
  ),
];

class SavedWorkoutCyclesScreen extends StatefulWidget {
  const SavedWorkoutCyclesScreen({super.key});

  @override
  _SavedWorkoutCyclesScreenState createState() =>
      _SavedWorkoutCyclesScreenState();
}

class _SavedWorkoutCyclesScreenState extends State<SavedWorkoutCyclesScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _plansFuture;

  final List<String> _dayLabels = const [
    'mon',
    'tue',
    'wed',
    'thu',
    'fri',
    'sat',
    'sun',
  ];

  @override
  void initState() {
    super.initState();
    _plansFuture = _apiService.fetchSavedCyclePlans();
  }

  void _refresh() {
    setState(() {
      _plansFuture = _apiService.fetchSavedCyclePlans();
    });
  }

  int _activeDaysCount(Map<String, dynamic> daysPattern) {
    return _dayLabels.where((day) => daysPattern[day] != null).length;
  }

  Future<void> _reusePlan(Map<String, dynamic> plan) async {
    final colorScheme = Theme.of(context).colorScheme;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: colorScheme.primary,
              brightness: Theme.of(context).brightness,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null || !mounted) return;

    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      await _apiService.reuseCyclePlan(plan['id'], formattedDate);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${plan['name'] ?? 'Cycle'}" scheduled')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reuse cycle: ${e.toString()}')),
      );
    }
  }

  Future<void> _deletePlan(Map<String, dynamic> plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Saved Cycle'),
        content: Text(
            'Delete "${plan['name'] ?? 'this cycle'}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _apiService.deleteCyclePlan(plan['id']);
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete cycle: ${e.toString()}')),
      );
    }
  }

  Future<void> _useSuggestion(_SuggestedCycle suggestion) async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => NewWorkoutCycleScreen(
          initialName: suggestion.name,
          initialDescription: suggestion.description,
          initialWeeks: suggestion.weeks,
          initialActiveDayKeys: suggestion.activeDayKeys,
        ),
      ),
    );

    if (created == true) {
      _refresh();
    }
  }

  Widget _buildSuggestedCycles(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suggested Cycles',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Quick-start templates — pick one and choose your own workouts for each day.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _suggestedCycles.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final suggestion = _suggestedCycles[index];
                return SizedBox(
                  width: 220,
                  child: Card(
                    elevation: 1,
                    color: colorScheme.primary.withValues(alpha: 0.06),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                          color: colorScheme.primary.withValues(alpha: 0.2)),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => _useSuggestion(suggestion),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              suggestion.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Expanded(
                              child: Text(
                                suggestion.description,
                                style: theme.textTheme.bodySmall,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${suggestion.weeks} weeks · ${suggestion.activeDayKeys.length} days/week',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Saved Workout Cycles',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _plansFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'Failed to load saved cycles: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colorScheme.error),
                ),
              ),
            );
          }

          final plans = snapshot.data ?? [];

          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildSuggestedCycles(theme, colorScheme),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    'Your Saved Cycles',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                if (plans.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.bookmark_border,
                          size: 56,
                          color: colorScheme.primary.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No saved workout cycles yet',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Every cycle you create is automatically saved here so you can reuse it later.',
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: plans.map((rawPlan) {
                        final plan = rawPlan as Map<String, dynamic>;
                        final daysPattern =
                            (plan['days_pattern'] as Map<String, dynamic>?) ??
                                {};
                        final activeDays = _activeDaysCount(daysPattern);
                        final name = (plan['name'] as String?)?.trim();
                        final description =
                            (plan['description'] as String?)?.trim();

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Card(
                            elevation: 2,
                            color: colorScheme.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                  color: colorScheme.primary
                                      .withValues(alpha: 0.15)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          (name == null || name.isEmpty)
                                              ? 'Unnamed Cycle'
                                              : name,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete_outline,
                                            color: colorScheme.error),
                                        tooltip: 'Delete',
                                        onPressed: () => _deletePlan(plan),
                                      ),
                                    ],
                                  ),
                                  if (description != null &&
                                      description.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      description,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                  const SizedBox(height: 4),
                                  Text(
                                    '${plan['weeks']} week${plan['weeks'] == 1 ? '' : 's'} · $activeDays workout day${activeDays == 1 ? '' : 's'}/week',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: FilledButton.icon(
                                      onPressed: () => _reusePlan(plan),
                                      icon: const Icon(Icons.replay),
                                      label: const Text('Reuse'),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: colorScheme.primary,
                                        foregroundColor:
                                            colorScheme.onPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
