# Code Review, Optimization & Design Sync

**Date:** 2026-04-16  
**Scope:** Full codebase — design unification, bug fixes, code quality  
**Approach:** Design-first (theme system → bugs → code quality)

---

## 1. Design System

### 1.1 Teal Seed Color — Single Source of Truth

Replace the current default Material 3 seed in `main.dart` with `Colors.teal`. Both `ThemeData` (light) and `ThemeData.dark()` receive:

```dart
colorScheme: ColorScheme.fromSeed(
  seedColor: Colors.teal,
  brightness: Brightness.light, // or Brightness.dark
)
```

No screen hard-codes a color. All screens reference `colorScheme.primary`, `colorScheme.surface`, `colorScheme.onSurface`, etc.

### 1.2 Scaffold Background

- **Light mode:** `scaffoldBackgroundColor: const Color(0xFFE0F2F1)` (lightest teal Material swatch)
- **Dark mode:** Default dark surface — no tint override needed

### 1.3 Card Standard

All cards across all screens use:

```dart
Card(
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14),
    side: BorderSide(
      color: colorScheme.primary.withOpacity(0.15),
      width: 1,
    ),
  ),
)
```

No screen defines its own card shape or elevation. Per-screen card customizations are removed.

### 1.4 AppBar Standard

All AppBars across all screens use:

```dart
AppBar(
  elevation: 0,
  backgroundColor: colorScheme.surface,
  foregroundColor: colorScheme.onSurface,
)
```

### 1.5 Auth Screens — Theme-Aware

`login_screen.dart` and `register_screen.dart` are made fully theme-aware:

- Remove hardcoded `backgroundColor: Colors.white`
- Remove hardcoded `Colors.blue.shade700` button colors → `colorScheme.primary`
- Remove hardcoded `foregroundColor: Colors.black` → `colorScheme.onSurface`
- Remove hardcoded `TextStyle(color: Color.fromARGB(255, 60, 60, 60))` → `colorScheme.onSurface`
- Password visibility icon: remove hardcoded `Colors.black` / `Colors.grey` → `colorScheme.onSurfaceVariant`

### 1.6 Workout Calendar — Replace Custom Color System

`workout_calendar_screen.dart` maintains its own parallel color system using `Colors.tealAccent`, `Colors.blueGrey`, `Color(0xFF1E1E1E)`, `Color(0xFF303030)`, etc., with six `late Color` fields initialized in `build()`. Replace entirely with `colorScheme.*` tokens. Remove all six `late Color` fields from the class.

### 1.7 Macro Nutrition Colors — Unchanged

Red (calories), blue (protein), green (carbs), orange (fat) are semantic colors that communicate meaning. They remain, continuing the existing brightness-adaptive pattern from `home_screen.dart`.

---

## 2. Bug Fixes

### 2.1 HomeScreen Logout Pops Itself

**File:** `lib/screens/home_screen.dart`  
**Problem:** `_showLogoutConfirmation()` is preceded by `Navigator.of(context).pop()`. Since `HomeScreen` is the root screen, this pops the screen before the dialog opens.  
**Fix:** Remove the `Navigator.of(context).pop()` call in the logout `IconButton.onPressed`.

### 2.2 ProfileScreen Logout Leaves Orphaned Routes

**File:** `lib/screens/profile_screen.dart`  
**Problem:** `_logout()` uses `Navigator.pushReplacement` — replaces only the top screen, leaving the rest of the nav stack intact.  
**Fix:** Replace with `Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false)`.

### 2.3 `context` Used After Async Gap Without `mounted` Check

**Files:** `lib/screens/login_screen.dart`, `lib/screens/register_screen.dart`  
**Problem:** Both files suppress `use_build_context_synchronously` via `ignore_for_file` instead of fixing the root cause.  
**Fix:** Add `if (!mounted) return;` after each `await` call before any `context` usage. Remove `// ignore_for_file` comments.

### 2.4 Dead Variable from `deleteAccount()`

**File:** `lib/screens/settings_screen.dart`  
**Problem:** `final data = await _apiService.deleteAccount()` — `deleteAccount()` returns `void`, so `data` is always `null` and unused.  
**Fix:** Change to `await _apiService.deleteAccount();`

### 2.5 Scanned Food Card Never Cleared

**File:** `lib/screens/foods_screen.dart`  
**Problem:** After scanning a barcode and navigating to `FoodDetailsScreen`, returning to `FoodsScreen` still shows the scanned food card. `_scannedFood` is never reset.  
**Fix:** In the `.then((_) { })` callback after `Navigator.push` to `FoodDetailsScreen`, call `setState(() { _scannedFood = null; })`.

### 2.6 `_filteredWorkouts` Leaks Between Modal Sessions

**File:** `lib/screens/workout/workout_calendar_screen.dart`  
**Problem:** `_filteredWorkouts` is a class-level field used as modal-local state. If the modal is opened, a search is performed, the modal is closed, then reopened — the previous filtered list is still present.  
**Fix:** Remove `_filteredWorkouts` from the class. Declare it as a local variable inside the `StatefulBuilder` builder function.

---

## 3. Code Quality

### 3.1 Navigation Duplication Eliminated

**Problem:** `_onNavBarTap` with the identical 4-route list is copy-pasted in `HomeScreen`, `WorkoutCalendarScreen`, `FoodsScreen`, and `ProfileScreen`.  
**Fix:** Move navigation logic into `CustomBottomNavBar` (`lib/screens/widgets/bottom_nav_bar.dart`). The widget accepts `currentIndex` and `BuildContext` and owns the `pushReplacement` logic. Each screen passes only its index.

### 3.2 Shared `AppTextField` Widget

**Problem:** `_buildTextField` is duplicated between `login_screen.dart` and `register_screen.dart`.  
**Fix:** Extract to `lib/screens/widgets/app_text_field.dart`. Both auth screens import and use it.

### 3.3 Dead Code Removed

| Location | Dead code |
|---|---|
| `profile_screen.dart` | `_loadSettings()` — body is `setState(() {})` with no logic. Remove method and its `initState` call. |
| `profile_screen.dart` | `_launchPrivacyPolicy()` — body fully commented out. Remove method and the "Privacy" quick-action button. |
| `settings_screen.dart` | `final data =` assignment (covered in §2.4) |

### 3.4 `mounted` Check in `_goToNewFood`

**File:** `lib/screens/foods_screen.dart`  
**Problem:** `Provider.of<FoodProvider>(context, listen: false).refreshFoods()` is called after `await Navigator.push` without a `mounted` guard.  
**Fix:** Add `if (!mounted) return;` before the `Provider.of` call.

### 3.5 `debugPrint` Removed from Production Paths

| File | Line |
|---|---|
| `foods_screen.dart` | Barcode scan result print |
| `workout_calendar_screen.dart` | `debugPrint(workouts.toString())` |
| `workout_calendar_screen.dart` | `debugPrint('Failed to load workouts: ...')` — replace with proper error state (already stored in `_errorMessage`) |

### 3.6 Filename Convention

`lib/utils/addBanner.dart` → `lib/utils/add_banner.dart` (Dart convention: `snake_case` filenames).

---

## Implementation Order

1. **Theme system** — update `main.dart` seed color and scaffold background
2. **Shared widgets** — `AppTextField`, update `CustomBottomNavBar` with nav logic
3. **Auth screens** — apply theme tokens, add `mounted` checks, remove suppression comments
4. **Home screen** — fix logout pop bug, apply AppBar/card standards
5. **Profile screen** — fix logout nav stack, remove dead methods, apply standards
6. **Foods screen** — fix `_scannedFood` clear, `mounted` guard, remove `debugPrint`, apply standards
7. **Workout calendar screen** — replace custom color system with `colorScheme`, fix `_filteredWorkouts` leak, remove `debugPrint`
8. **Settings screen** — fix dead variable, apply AppBar standard
9. **Filename rename** — `addBanner.dart` → `add_banner.dart`
