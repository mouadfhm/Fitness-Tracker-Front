# Workout Card Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the 2-column workout card grid with a single-column full-width list where each row shows an icon chip, workout name, category, calorie burn, and difficulty.

**Architecture:** Single file change in `lib/screens/workout_screen.dart`. The `SliverGrid` is replaced with a `SliverList`. The card widget is rebuilt as a horizontal `Row` with three zones: left icon chip, center info column, right difficulty column. All existing helper methods (`_getCategoryColor`, `_getCategoryIcon`, `_buildDifficultyIndicator`) are reused unchanged.

**Tech Stack:** Flutter, Material 3, `provider` package

---

## Files

| Action | Path | Responsibility |
|--------|------|----------------|
| Modify | `lib/screens/workout_screen.dart` | Replace grid with list, new card row widget |

---

### Task 1: Replace SliverGrid with SliverList row cards

**Files:**
- Modify: `lib/screens/workout_screen.dart` (the `SliverPadding` block containing `SliverGrid`, roughly lines 552–691)

- [ ] **Step 1: Locate the SliverGrid block**

Open `lib/screens/workout_screen.dart`. Find the `SliverPadding` that wraps the `SliverGrid` — it starts with:
```dart
: SliverPadding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    sliver: SliverGrid(
```

- [ ] **Step 2: Replace the entire SliverPadding block**

Replace the full `SliverPadding(...SliverGrid(...))` block (everything from `: SliverPadding(` through the closing `),` that ends that branch) with:

```dart
: SliverPadding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    sliver: SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final workout = provider.filteredWorkouts[index];
          final description = workout['description'] ?? 'No Description';
          final category = workout['name'] ?? 'Other';
          final caloriesPerKg =
              (workout['caloriesPerKg'] as num).toDouble();
          final difficulty = caloriesPerKg > 2
              ? 'Hard'
              : caloriesPerKg > 1
                  ? 'Medium'
                  : 'Easy';
          final Color categoryColor = _getCategoryColor(category);

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        WorkoutDetailsScreen(workout: workout),
                  ),
                );
              },
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: colorScheme.primary.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      // Icon chip
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          _getCategoryIcon(category),
                          size: 28,
                          color: categoryColor,
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Info column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              description,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: categoryColor
                                        .withValues(alpha: 0.15),
                                    borderRadius:
                                        BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: categoryColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.local_fire_department,
                                  size: 13,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${caloriesPerKg.toStringAsFixed(1)} kcal/kg',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Difficulty column
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildDifficultyIndicator(difficulty),
                          const SizedBox(height: 4),
                          Text(
                            difficulty.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        childCount: provider.filteredWorkouts.length,
      ),
    ),
  ),
```

- [ ] **Step 3: Run flutter analyze**

```bash
flutter analyze lib/screens/workout_screen.dart
```

Expected: `No issues found!`

If you see `'SliverGridDelegateWithFixedCrossAxisCount' isn't used`, that import/reference was removed with the grid — verify the build passes regardless since it's not a separate import.

- [ ] **Step 4: Commit**

```bash
git add lib/screens/workout_screen.dart
git commit -m "feat: redesign workout cards as horizontal list rows"
```
