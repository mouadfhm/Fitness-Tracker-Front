# Beginner Mode & Onboarding Wizard — Design Spec

**Date:** 2026-04-17

---

## Overview

Two independent improvements:

1. **Workout screen mode toggle** — make the simple browse-and-log `WorkoutScreen` the default for all users, with a persistent toggle to switch to the existing advanced `WorkoutCalendarScreen`.
2. **Onboarding wizard** — replace the single-form `UpdateProfileScreen` with a 4-step wizard that uses tap-to-select cards and live info preview cards instead of dropdowns.

---

## Feature 1: Workout Screen Mode Toggle

### Problem

The bottom nav's Workout tab currently routes directly to `WorkoutCalendarScreen` (the advanced system: custom workouts, cycles, scheduling). The simpler `WorkoutScreen` (browse exercises, pick one, log duration) exists but is not reachable from the main nav. Non-advanced users have no easy entry point.

### Solution

Introduce a `WorkoutRootScreen` that wraps both views in an `IndexedStack`. A segmented pill toggle in the AppBar switches between Simple and Advanced mode. The selected mode is saved to `SharedPreferences` and defaults to Simple on a fresh install.

### Architecture

- **New file:** `lib/screens/workout_root_screen.dart`
  - Reads `workout_mode` from `SharedPreferences` (`'simple'` | `'advanced'`)
  - Renders an `IndexedStack` with index 0 = `WorkoutScreen` body, index 1 = `WorkoutCalendarScreen` body
  - AppBar contains the segmented pill toggle; tapping writes the new value to `SharedPreferences` and calls `setState`
- **Bottom nav change:** `BottomNavBar` Workout tab (index 1) routes to `WorkoutRootScreen` instead of `WorkoutCalendarScreen`
- **WorkoutScreen & WorkoutCalendarScreen:** No changes to their internal logic — they are embedded as children, not navigated to directly from the root

### Toggle UI

- Segmented pill in AppBar top-right: `[ Simple | Advanced ]`
- Active segment: filled with `colorScheme.primary`, white text
- Inactive segment: transparent background, `onSurfaceVariant` text
- Default on fresh install: **Simple**

### Persistence

```dart
// Read
final prefs = await SharedPreferences.getInstance();
final mode = prefs.getString('workout_mode') ?? 'simple';

// Write on toggle
await prefs.setString('workout_mode', newMode);
```

---

## Feature 2: Onboarding Wizard

### Problem

After registration, users land on `UpdateProfileScreen` — a single long form with text fields for age/weight/height and three raw dropdowns (gender, activity level, fitness goal). There are no explanations, no illustrations, and no sense of progress. Non-technical users are confused by terms like `very_active` and `weight_loss`.

### Solution

Replace `UpdateProfileScreen` with a new `OnboardingScreen` that uses a `PageView` to present 4 focused steps. Each step shows:
- A **progress bar** (4 segments, fills as user advances)
- A **live info preview card** that reacts to the user's input
- Either **text fields** (for numeric data) or **tap-to-select cards** (for categorical choices)

### Steps

#### Step 1 — Body Stats
Fields: Age (int), Weight (kg, double), Height (cm, double)

Info card: Shows live BMI calculation with a colour-coded label:
- < 18.5 → "Underweight" (amber)
- 18.5–24.9 → "Healthy Range" (green)
- 25–29.9 → "Overweight" (orange)
- ≥ 30 → "Obese" (red)

Instruction copy: *"We use these to calculate your daily calorie needs."*

#### Step 2 — Gender
Options: Male 👨, Female 👩 (tap-to-select cards)

Info card: Shows estimated BMR (Basal Metabolic Rate) using Mifflin-St Jeor formula, labelled "Estimated daily calories at rest".

Instruction copy: *"Affects your metabolic rate calculation."*

#### Step 3 — Activity Level
Options (tap-to-select cards with plain-English descriptions):
- 🛋️ **Sedentary** — "Desk job, little to no exercise"
- 🚶 **Light** — "Light exercise 1–3 days/week"
- 🏃 **Moderate** — "Exercise 3–5 days/week"
- ⚡ **Active** — "Hard exercise 6–7 days/week"
- 🔥 **Very Active** — "Physical job or 2× daily training"

Info card: Shows TDEE (Total Daily Energy Expenditure) = BMR × activity multiplier, labelled "Your total daily calorie burn".

Instruction copy: *"Pick what describes a typical week for you."*

#### Step 4 — Fitness Goal
Options (tap-to-select cards):
- 🔥 **Lose Weight** — "500 kcal daily deficit"
- 💪 **Build Muscle** — "+300 kcal daily surplus"
- ⚖️ **Stay Fit** — "Maintain current weight"

Info card: Shows adjusted daily calorie target = TDEE ± goal offset, labelled "Your daily calorie target".

Final button: "🎉 Let's Go!" — submits to API and navigates to `HomeScreen`.

Instruction copy: *"We'll adjust your daily target accordingly."*

### Architecture

- **New file:** `lib/screens/onboarding_screen.dart`
  - `StatefulWidget` with `PageController`
  - State holds: `age`, `weight`, `height`, `gender`, `activityLevel`, `fitnessGoal`
  - Computed getters: `bmi`, `bmr`, `tdee`, `dailyTarget`
  - Each page is a private `_StepN` widget that calls back on value change
  - `_buildProgressBar()` — 4-segment linear row
  - `_buildInfoCard()` per step — updates on `setState`
- **Register flow:** `RegisterScreen` → on success → `OnboardingScreen` (replaces `UpdateProfileScreen`)
- **Profile edit:** `ProfileScreen` "Edit Profile" button → `OnboardingScreen` pre-populated with current profile data
- **API call:** Single `ApiService.updateProfile()` call on final step submit (same as before)

### Calculations (client-side, for preview only)

```dart
double get bmi => weight / ((height / 100) * (height / 100));

double get bmr => gender == 'male'
    ? (10 * weight) + (6.25 * height) - (5 * age) + 5
    : (10 * weight) + (6.25 * height) - (5 * age) - 161;

double get tdee => bmr * _activityMultiplier(activityLevel);

double get dailyTarget {
  switch (fitnessGoal) {
    case 'weight_loss': return tdee - 500;
    case 'muscle_gain': return tdee + 300;
    default: return tdee;
  }
}
```

These are display-only — the backend calculates authoritative values using the submitted profile.

---

## Files Changed

| File | Change |
|---|---|
| `lib/screens/workout_root_screen.dart` | **New** — IndexedStack wrapper with mode toggle |
| `lib/screens/widgets/bottom_nav_bar.dart` | Route Workout tab to `WorkoutRootScreen` |
| `lib/screens/onboarding_screen.dart` | **New** — 4-step PageView wizard |
| `lib/screens/register_screen.dart` | Navigate to `OnboardingScreen` after success |
| `lib/screens/profile_screen.dart` | "Edit Profile" → `OnboardingScreen` (pre-populated) |
| `lib/screens/update_profile_screen.dart` | No longer used from register/edit flows (keep for now, do not delete) |

---

## Out of Scope

- Backend changes — API contract unchanged
- Any changes to Advanced workout features (WorkoutCalendarScreen, custom workouts, cycles)
- Animations between onboarding steps (plain `PageView` scroll is sufficient)
