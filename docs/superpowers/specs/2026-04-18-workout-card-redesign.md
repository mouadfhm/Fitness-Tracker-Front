# Workout Card Redesign

**Date:** 2026-04-18  
**File:** `lib/screens/workout_screen.dart`

## Goal

Replace the 2-column grid of workout cards with a single-column full-width list. Each row is more scannable, shows calorie burn, and uses a rounded-square icon chip instead of a large banner area.

## Layout Change

- **Before:** `SliverGrid` with `crossAxisCount: 2`, `childAspectRatio: 0.8`
- **After:** `SliverList` with one card per workout

## Card Structure (per row)

```
┌─────────────────────────────────────────────────┐
│  [Icon]   Name                      [●●●]        │
│  52×52    Category chip  🔥 kcal/kg  HARD        │
└─────────────────────────────────────────────────┘
```

### Left — Icon chip
- `52×52` container, `borderRadius: 14`
- Background: `categoryColor.withValues(alpha: 0.2)`
- Child: `Icon(_getCategoryIcon(category), size: 28, color: categoryColor)`

### Center — Info column
- **Name:** `fontSize: 15`, `fontWeight: bold`, `color: onSurface`, max 1 line with ellipsis
- **Meta row:** category chip + calorie burn
  - Category chip: same style as before (`categoryColor` tinted background + text)
  - Calorie burn: `"🔥 ${caloriesPerKg.toStringAsFixed(1)} kcal/kg"`, `fontSize: 12`, `color: onSurfaceVariant`

### Right — Difficulty column
- Existing `_buildDifficultyIndicator` bars (kept as-is)
- Text label below bars: `"EASY"` / `"MEDIUM"` / `"HARD"`, `fontSize: 10`, `fontWeight: w600`, `color: outlineVariant`

## Card Style (unchanged)
- `Card`, `elevation: 2`
- `RoundedRectangleBorder(borderRadius: 14, side: BorderSide(primary × 0.15, width: 1))`
- Horizontal padding: `EdgeInsets.symmetric(horizontal: 16)`, vertical margin: `8` between cards

## Data
`caloriesPerKg` comes from `workout['caloriesPerKg']` (already available — used for difficulty calculation).

## What is NOT changing
- `_getCategoryColor`, `_getCategoryIcon`, `_getCategoryColor` helper methods — unchanged
- `_buildDifficultyIndicator` — unchanged
- AppBar, search bar, category filter chips, results count row — unchanged
- Navigation on tap — unchanged
- `WorkoutDetailsScreen` destination — unchanged
