# Beginner Mode & Onboarding Wizard Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a Simple/Advanced mode toggle to the Workout tab (defaulting to the browse-and-log screen) and replace the single-form profile setup with a 4-step guided onboarding wizard.

**Architecture:** `WorkoutRootScreen` manages mode state via SharedPreferences and renders either `WorkoutScreen` or `WorkoutCalendarScreen`, passing each an `onModeToggle` callback that drives the AppBar segmented pill. The onboarding wizard is a new `OnboardingScreen` using `PageView` with live-computed info cards; it replaces `UpdateProfileScreen` in both the registration and profile-edit flows.

**Tech Stack:** Flutter, Provider, SharedPreferences (already in pubspec), ApiService (existing)

---

## File Map

| File | Action |
|---|---|
| `lib/screens/workout_root_screen.dart` | **Create** — mode manager, renders WorkoutScreen or WorkoutCalendarScreen |
| `lib/screens/workout_screen.dart` | **Modify** — accept `onModeToggle` callback, add segmented pill to AppBar |
| `lib/screens/workout/workout_calendar_screen.dart` | **Modify** — accept `onModeToggle` callback, add segmented pill to AppBar |
| `lib/main.dart` | **Modify** — change `/workouts` route to `WorkoutRootScreen` |
| `lib/screens/onboarding_screen.dart` | **Create** — 4-step PageView wizard |
| `lib/screens/register_screen.dart` | **Modify** — navigate to `OnboardingScreen` after success |
| `lib/screens/profile_screen.dart` | **Modify** — `_goToProfileEdit` navigates to `OnboardingScreen` |
| `test/workout_root_screen_test.dart` | **Create** — widget tests for mode toggle |
| `test/onboarding_screen_test.dart` | **Create** — widget tests for wizard steps |

---

## Task 1: Add `onModeToggle` callback to WorkoutScreen

**Files:**
- Modify: `lib/screens/workout_screen.dart`
- Create: `test/workout_root_screen_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/workout_root_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fitness_tracker_app/providers/exercise_provider.dart';
import 'package:fitness_tracker_app/screens/workout_screen.dart';

Widget _wrap(Widget child) => MultiProvider(
  providers: [ChangeNotifierProvider(create: (_) => ExercisesProvider())],
  child: MaterialApp(home: child),
);

void main() {
  testWidgets('WorkoutScreen calls onModeToggle when Advanced tapped', (tester) async {
    bool toggled = false;
    await tester.pumpWidget(_wrap(
      WorkoutScreen(onModeToggle: () => toggled = true),
    ));
    await tester.pump();
    await tester.tap(find.text('Advanced'));
    expect(toggled, isTrue);
  });

  testWidgets('WorkoutScreen shows Simple as active by default', (tester) async {
    await tester.pumpWidget(_wrap(
      WorkoutScreen(onModeToggle: () {}),
    ));
    await tester.pump();
    expect(find.text('Simple'), findsOneWidget);
    expect(find.text('Advanced'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to confirm it fails**

```bash
flutter test test/workout_root_screen_test.dart
```

Expected: FAIL — `WorkoutScreen` has no `onModeToggle` parameter yet.

- [ ] **Step 3: Modify WorkoutScreen**

In `lib/screens/workout_screen.dart`, update the class signature and AppBar:

```dart
class WorkoutScreen extends StatefulWidget {
  final VoidCallback? onModeToggle;

  const WorkoutScreen({super.key, this.onModeToggle});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}
```

Replace the existing `AppBar` inside `build` with:

```dart
appBar: AppBar(
  title: const Text(
    'Workouts',
    style: TextStyle(fontWeight: FontWeight.bold),
  ),
  elevation: 0,
  backgroundColor: Theme.of(context).colorScheme.surface,
  foregroundColor: Theme.of(context).colorScheme.onSurface,
  actions: [
    if (onModeToggle != null)
      Padding(
        padding: const EdgeInsets.only(right: 12),
        child: _buildModeToggle(context, isSimple: true),
      ),
  ],
),
```

Add this helper method to `_WorkoutScreenState`:

```dart
Widget _buildModeToggle(BuildContext context, {required bool isSimple}) {
  final colorScheme = Theme.of(context).colorScheme;
  return Container(
    decoration: BoxDecoration(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(20),
    ),
    padding: const EdgeInsets.all(3),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _toggleSegment(context, label: 'Simple', active: isSimple, onTap: null),
        _toggleSegment(context, label: 'Advanced', active: !isSimple, onTap: widget.onModeToggle),
      ],
    ),
  );
}

Widget _toggleSegment(BuildContext context, {
  required String label,
  required bool active,
  required VoidCallback? onTap,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: active ? colorScheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
          color: active ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
        ),
      ),
    ),
  );
}
```

- [ ] **Step 4: Run test to confirm it passes**

```bash
flutter test test/workout_root_screen_test.dart
```

Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/screens/workout_screen.dart test/workout_root_screen_test.dart
git commit -m "feat: add onModeToggle callback and segmented pill to WorkoutScreen"
```

---

## Task 2: Add `onModeToggle` callback to WorkoutCalendarScreen

**Files:**
- Modify: `lib/screens/workout/workout_calendar_screen.dart`

- [ ] **Step 1: Add test for WorkoutCalendarScreen toggle**

Append to `test/workout_root_screen_test.dart`:

```dart
import 'package:fitness_tracker_app/screens/workout/workout_calendar_screen.dart';

// Add inside main():
testWidgets('WorkoutCalendarScreen calls onModeToggle when Simple tapped', (tester) async {
  bool toggled = false;
  await tester.pumpWidget(MaterialApp(
    home: WorkoutCalendarScreen(onModeToggle: () => toggled = true),
  ));
  await tester.pump();
  await tester.tap(find.text('Simple'));
  expect(toggled, isTrue);
});
```

- [ ] **Step 2: Run test to confirm it fails**

```bash
flutter test test/workout_root_screen_test.dart
```

Expected: FAIL — `WorkoutCalendarScreen` has no `onModeToggle` parameter.

- [ ] **Step 3: Modify WorkoutCalendarScreen**

In `lib/screens/workout/workout_calendar_screen.dart`, update the class signature:

```dart
class WorkoutCalendarScreen extends StatefulWidget {
  final VoidCallback? onModeToggle;

  const WorkoutCalendarScreen({super.key, this.onModeToggle});

  @override
  _WorkoutCalendarScreenState createState() => _WorkoutCalendarScreenState();
}
```

In `_WorkoutCalendarScreenState`, add the same two helper methods (`_buildModeToggle`, `_toggleSegment`) as in Task 1 but with `isSimple: false`:

```dart
Widget _buildModeToggle(BuildContext context, {required bool isSimple}) {
  final colorScheme = Theme.of(context).colorScheme;
  return Container(
    decoration: BoxDecoration(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(20),
    ),
    padding: const EdgeInsets.all(3),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _toggleSegment(context, label: 'Simple', active: isSimple, onTap: widget.onModeToggle),
        _toggleSegment(context, label: 'Advanced', active: !isSimple, onTap: null),
      ],
    ),
  );
}

Widget _toggleSegment(BuildContext context, {
  required String label,
  required bool active,
  required VoidCallback? onTap,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: active ? colorScheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
          color: active ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
        ),
      ),
    ),
  );
}
```

Find the `AppBar` in `WorkoutCalendarScreen`'s `build` method and add `actions`:

```dart
// In the Scaffold's AppBar (find the existing AppBar and add actions):
actions: [
  if (widget.onModeToggle != null)
    Padding(
      padding: const EdgeInsets.only(right: 12),
      child: _buildModeToggle(context, isSimple: false),
    ),
],
```

- [ ] **Step 4: Run tests**

```bash
flutter test test/workout_root_screen_test.dart
```

Expected: PASS for all tests

- [ ] **Step 5: Commit**

```bash
git add lib/screens/workout/workout_calendar_screen.dart test/workout_root_screen_test.dart
git commit -m "feat: add onModeToggle callback and segmented pill to WorkoutCalendarScreen"
```

---

## Task 3: Create WorkoutRootScreen

**Files:**
- Create: `lib/screens/workout_root_screen.dart`

- [ ] **Step 1: Add tests for WorkoutRootScreen**

Append to `test/workout_root_screen_test.dart`:

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitness_tracker_app/screens/workout_root_screen.dart';

// Add inside main():
group('WorkoutRootScreen', () {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows Simple mode by default (no saved preference)', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(_wrap(const WorkoutRootScreen()));
    await tester.pumpAndSettle();
    // WorkoutScreen content: search field is present in simple mode
    expect(find.text('Search Exercises...'), findsOneWidget);
  });

  testWidgets('shows Advanced mode when preference is saved', (tester) async {
    SharedPreferences.setMockInitialValues({'workout_mode': 'advanced'});
    await tester.pumpWidget(_wrap(const WorkoutRootScreen()));
    await tester.pumpAndSettle();
    // WorkoutCalendarScreen is shown — it does not have the search field
    expect(find.text('Search Exercises...'), findsNothing);
  });
});
```

- [ ] **Step 2: Run test to confirm it fails**

```bash
flutter test test/workout_root_screen_test.dart
```

Expected: FAIL — `WorkoutRootScreen` does not exist.

- [ ] **Step 3: Create WorkoutRootScreen**

Create `lib/screens/workout_root_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'workout_screen.dart';
import 'workout/workout_calendar_screen.dart';

class WorkoutRootScreen extends StatefulWidget {
  const WorkoutRootScreen({super.key});

  @override
  State<WorkoutRootScreen> createState() => _WorkoutRootScreenState();
}

class _WorkoutRootScreenState extends State<WorkoutRootScreen> {
  bool _isSimple = true;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _loadMode();
  }

  Future<void> _loadMode() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString('workout_mode') ?? 'simple';
    if (mounted) {
      setState(() {
        _isSimple = mode == 'simple';
        _ready = true;
      });
    }
  }

  Future<void> _toggleMode() async {
    final prefs = await SharedPreferences.getInstance();
    final newMode = _isSimple ? 'advanced' : 'simple';
    await prefs.setString('workout_mode', newMode);
    if (mounted) setState(() => _isSimple = !_isSimple);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _isSimple
        ? WorkoutScreen(onModeToggle: _toggleMode)
        : WorkoutCalendarScreen(onModeToggle: _toggleMode);
  }
}
```

- [ ] **Step 4: Run tests**

```bash
flutter test test/workout_root_screen_test.dart
```

Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/screens/workout_root_screen.dart test/workout_root_screen_test.dart
git commit -m "feat: create WorkoutRootScreen with persisted Simple/Advanced mode toggle"
```

---

## Task 4: Wire WorkoutRootScreen into routing

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Update `/workouts` route in main.dart**

In `lib/main.dart`, add the import:

```dart
import 'screens/workout_root_screen.dart';
```

Change the `routes` map entry:

```dart
// Before:
'/workouts': (_) => const WorkoutCalendarScreen(),

// After:
'/workouts': (_) => const WorkoutRootScreen(),
```

You can also remove the `WorkoutCalendarScreen` import from main.dart if it is no longer used there (it is now used only inside `WorkoutRootScreen`).

- [ ] **Step 2: Verify app runs**

```bash
flutter analyze
```

Expected: No errors. If `WorkoutCalendarScreen` import is now unused in `main.dart`, remove it — `flutter analyze` will flag it.

- [ ] **Step 3: Commit**

```bash
git add lib/main.dart
git commit -m "feat: route /workouts to WorkoutRootScreen"
```

---

## Task 5: Create OnboardingScreen — Step 1 (Body Stats + BMI card)

**Files:**
- Create: `lib/screens/onboarding_screen.dart`
- Create: `test/onboarding_screen_test.dart`

- [ ] **Step 1: Write failing tests**

Create `test/onboarding_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_tracker_app/screens/onboarding_screen.dart';

Widget _wrap(Widget child) => MaterialApp(home: child);

void main() {
  group('OnboardingScreen Step 1', () {
    testWidgets('shows progress bar with 4 segments', (tester) async {
      await tester.pumpWidget(_wrap(const OnboardingScreen()));
      // 4 segments rendered by checking the step label text
      expect(find.text('Your body stats'), findsOneWidget);
    });

    testWidgets('BMI card shows 0.0 when fields are empty', (tester) async {
      await tester.pumpWidget(_wrap(const OnboardingScreen()));
      expect(find.textContaining('BMI'), findsOneWidget);
    });

    testWidgets('BMI card updates when weight and height are entered', (tester) async {
      await tester.pumpWidget(_wrap(const OnboardingScreen()));
      await tester.enterText(find.byKey(const Key('weight_field')), '70');
      await tester.enterText(find.byKey(const Key('height_field')), '175');
      await tester.pump();
      // BMI = 70 / (1.75^2) = 22.86, shown as "22.9" or similar
      expect(find.textContaining('22.'), findsOneWidget);
    });

    testWidgets('Next button advances to step 2', (tester) async {
      await tester.pumpWidget(_wrap(const OnboardingScreen()));
      await tester.enterText(find.byKey(const Key('age_field')), '25');
      await tester.enterText(find.byKey(const Key('weight_field')), '70');
      await tester.enterText(find.byKey(const Key('height_field')), '175');
      await tester.pump();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text("What's your gender?"), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run test to confirm it fails**

```bash
flutter test test/onboarding_screen_test.dart
```

Expected: FAIL — `OnboardingScreen` does not exist.

- [ ] **Step 3: Create OnboardingScreen with Step 1**

Create `lib/screens/onboarding_screen.dart`:

```dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final bool isEditing;

  const OnboardingScreen({
    super.key,
    this.initialData = const {},
    this.isEditing = false,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  String _gender = 'male';
  String _activityLevel = 'Moderate';
  String _fitnessGoal = 'weight_loss';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData.isNotEmpty) {
      _ageController.text = widget.initialData['age']?.toString() ?? '';
      _weightController.text = widget.initialData['weight']?.toString() ?? '';
      _heightController.text = widget.initialData['height']?.toString() ?? '';
      final validGenders = ['male', 'female'];
      final validActivities = ['sedentary', 'light', 'Moderate', 'active', 'very_active'];
      final validGoals = ['weight_loss', 'muscle_gain', 'maintenance'];
      final g = widget.initialData['gender'];
      final a = widget.initialData['activity_level'];
      final go = widget.initialData['fitness_goal'];
      if (validGenders.contains(g)) _gender = g;
      if (validActivities.contains(a)) _activityLevel = a;
      if (validGoals.contains(go)) _fitnessGoal = go;
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  double get _bmi {
    final w = double.tryParse(_weightController.text) ?? 0;
    final h = double.tryParse(_heightController.text) ?? 0;
    if (h <= 0 || w <= 0) return 0;
    return w / ((h / 100) * (h / 100));
  }

  double get _bmr {
    final w = double.tryParse(_weightController.text) ?? 0;
    final h = double.tryParse(_heightController.text) ?? 0;
    final a = double.tryParse(_ageController.text) ?? 0;
    if (w <= 0 || h <= 0 || a <= 0) return 0;
    return _gender == 'male'
        ? (10 * w) + (6.25 * h) - (5 * a) + 5
        : (10 * w) + (6.25 * h) - (5 * a) - 161;
  }

  double get _activityMultiplier {
    const map = {
      'sedentary': 1.2,
      'light': 1.375,
      'Moderate': 1.55,
      'active': 1.725,
      'very_active': 1.9,
    };
    return map[_activityLevel] ?? 1.55;
  }

  double get _tdee => _bmr * _activityMultiplier;

  double get _dailyTarget {
    switch (_fitnessGoal) {
      case 'weight_loss':
        return _tdee - 500;
      case 'muscle_gain':
        return _tdee + 300;
      default:
        return _tdee;
    }
  }

  void _nextPage() => _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

  void _prevPage() => _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      await ApiService().updateProfile({
        'age': int.tryParse(_ageController.text.trim()),
        'weight': double.tryParse(_weightController.text.trim()),
        'height': double.tryParse(_heightController.text.trim()),
        'gender': _gender,
        'activity_level': _activityLevel,
        'fitness_goal': _fitnessGoal,
      });
      if (!mounted) return;
      if (widget.isEditing) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save profile. Please try again.',
            style: TextStyle(color: Theme.of(context).colorScheme.onError),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: List.generate(4, (i) => Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
            decoration: BoxDecoration(
              color: i <= _currentPage
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        )),
      ),
    );
  }

  Widget _buildStep1() {
    return _buildStepShell(
      title: 'Your body stats',
      subtitle: 'We use these to calculate your daily calorie needs',
      infoCard: _buildBmiCard(),
      content: Column(
        children: [
          _buildNumberField(
            key: const Key('age_field'),
            controller: _ageController,
            label: 'Age',
            hint: 'e.g. 25',
            icon: Icons.cake_outlined,
          ),
          const SizedBox(height: 12),
          _buildNumberField(
            key: const Key('weight_field'),
            controller: _weightController,
            label: 'Weight (kg)',
            hint: 'e.g. 70',
            icon: Icons.monitor_weight_outlined,
          ),
          const SizedBox(height: 12),
          _buildNumberField(
            key: const Key('height_field'),
            controller: _heightController,
            label: 'Height (cm)',
            hint: 'e.g. 175',
            icon: Icons.height,
          ),
        ],
      ),
      onNext: () {
        final age = int.tryParse(_ageController.text.trim());
        final weight = double.tryParse(_weightController.text.trim());
        final height = double.tryParse(_heightController.text.trim());
        if (age == null || age <= 0 || age > 120 ||
            weight == null || weight <= 0 || weight > 500 ||
            height == null || height <= 0 || height > 300) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter valid age, weight, and height')),
          );
          return;
        }
        _nextPage();
      },
    );
  }

  Widget _buildBmiCard() {
    final bmi = _bmi;
    String label;
    Color color;
    if (bmi <= 0) {
      label = 'Enter your stats';
      color = Theme.of(context).colorScheme.outlineVariant;
    } else if (bmi < 18.5) {
      label = 'Underweight';
      color = Colors.amber;
    } else if (bmi < 25) {
      label = 'Healthy Range';
      color = Colors.green;
    } else if (bmi < 30) {
      label = 'Overweight';
      color = Colors.orange;
    } else {
      label = 'Obese';
      color = Colors.red;
    }

    return _buildInfoCard(
      gradient: [
        Theme.of(context).colorScheme.primaryContainer,
        Theme.of(context).colorScheme.secondaryContainer,
      ],
      child: Column(
        children: [
          Text('BMI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onPrimaryContainer)),
          const SizedBox(height: 4),
          Text(
            bmi > 0 ? bmi.toStringAsFixed(1) : '—',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(label,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
          ),
        ],
      ),
    );
  }

  // Steps 2-4 are added in the next task; placeholders keep the PageView valid
  Widget _buildStep2() => _buildStep2Body();
  Widget _buildStep3() => _buildStep3Body();
  Widget _buildStep4() => _buildStep4Body();
  Widget _buildStep2Body() => const SizedBox.shrink();
  Widget _buildStep3Body() => const SizedBox.shrink();
  Widget _buildStep4Body() => const SizedBox.shrink();

  Widget _buildStepShell({
    required String title,
    required String subtitle,
    required Widget infoCard,
    required Widget content,
    required VoidCallback onNext,
    VoidCallback? onBack,
    bool isFinal = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 20),
          infoCard,
          const SizedBox(height: 20),
          content,
          const SizedBox(height: 28),
          Row(
            children: [
              if (onBack != null) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: onBack,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFinal ? Colors.green : colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading && isFinal
                      ? SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: colorScheme.onPrimary),
                        )
                      : Text(isFinal ? "Let's Go!" : 'Next',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required List<Color> gradient, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [child]),
    );
  }

  Widget _buildNumberField({
    required Key key,
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      key: key,
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildSelectCard({
    required String value,
    required String currentValue,
    required String label,
    required String description,
    required String emoji,
    required VoidCallback onTap,
  }) {
    final isSelected = value == currentValue;
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer : colorScheme.surface,
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? colorScheme.primary : colorScheme.onSurface)),
                  Text(description,
                      style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: colorScheme.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests**

```bash
flutter test test/onboarding_screen_test.dart
```

Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/screens/onboarding_screen.dart test/onboarding_screen_test.dart
git commit -m "feat: create OnboardingScreen with Step 1 (body stats + BMI card)"
```

---

## Task 6: Add Steps 2–4 to OnboardingScreen

**Files:**
- Modify: `lib/screens/onboarding_screen.dart`

- [ ] **Step 1: Add tests for steps 2–4**

Append to `test/onboarding_screen_test.dart`:

```dart
  group('OnboardingScreen Steps 2-4', () {
    Future<void> _advanceToStep2(WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const OnboardingScreen()));
      await tester.enterText(find.byKey(const Key('age_field')), '25');
      await tester.enterText(find.byKey(const Key('weight_field')), '70');
      await tester.enterText(find.byKey(const Key('height_field')), '175');
      await tester.pump();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }

    testWidgets('Step 2 shows gender options', (tester) async {
      await _advanceToStep2(tester);
      expect(find.text("What's your gender?"), findsOneWidget);
      expect(find.text('Male'), findsOneWidget);
      expect(find.text('Female'), findsOneWidget);
    });

    testWidgets('Tapping Female selects it', (tester) async {
      await _advanceToStep2(tester);
      await tester.tap(find.text('Female'));
      await tester.pump();
      // Female card is now selected — check it's highlighted by finding its check icon
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('Step 3 shows activity options', (tester) async {
      await _advanceToStep2(tester);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('How active are you?'), findsOneWidget);
      expect(find.text('Sedentary'), findsOneWidget);
      expect(find.text('Moderate'), findsOneWidget);
    });

    testWidgets('Step 4 shows goal options', (tester) async {
      await _advanceToStep2(tester);
      await tester.tap(find.text('Next')); await tester.pumpAndSettle();
      await tester.tap(find.text('Next')); await tester.pumpAndSettle();
      expect(find.text("What's your goal?"), findsOneWidget);
      expect(find.text('Lose Weight'), findsOneWidget);
      expect(find.text('Build Muscle'), findsOneWidget);
      expect(find.text('Stay Fit'), findsOneWidget);
    });
  });
```

- [ ] **Step 2: Run test to confirm it fails**

```bash
flutter test test/onboarding_screen_test.dart
```

Expected: FAIL — steps 2–4 are currently empty `SizedBox.shrink()` placeholders.

- [ ] **Step 3: Implement steps 2–4 in OnboardingScreen**

In `lib/screens/onboarding_screen.dart`, replace the three placeholder methods with:

```dart
Widget _buildStep2() => _buildStep2Body();
Widget _buildStep3() => _buildStep3Body();
Widget _buildStep4() => _buildStep4Body();

Widget _buildStep2Body() {
  final bmr = _bmr;
  return _buildStepShell(
    title: "What's your gender?",
    subtitle: 'Affects your metabolic rate calculation',
    infoCard: _buildInfoCard(
      gradient: [const Color(0xFFFEF3C7), const Color(0xFFFDE68A)],
      child: Column(children: [
        const Text('Estimated Daily Calories at Rest',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF92400E))),
        const SizedBox(height: 4),
        Text(
          bmr > 0 ? '${bmr.toStringAsFixed(0)} kcal' : '—',
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF78350F)),
        ),
        const Text('Basal Metabolic Rate',
            style: TextStyle(fontSize: 11, color: Color(0xFF92400E))),
      ]),
    ),
    content: Column(children: [
      _buildSelectCard(
        value: 'male', currentValue: _gender, label: 'Male',
        description: 'Higher BMR on average', emoji: '👨',
        onTap: () => setState(() => _gender = 'male'),
      ),
      _buildSelectCard(
        value: 'female', currentValue: _gender, label: 'Female',
        description: 'Lower BMR on average', emoji: '👩',
        onTap: () => setState(() => _gender = 'female'),
      ),
    ]),
    onBack: _prevPage,
    onNext: _nextPage,
  );
}

Widget _buildStep3Body() {
  final tdee = _tdee;
  final activities = [
    ('sedentary', '🛋️', 'Sedentary', 'Desk job, little to no exercise'),
    ('light', '🚶', 'Light', 'Light exercise 1–3 days/week'),
    ('Moderate', '🏃', 'Moderate', 'Exercise 3–5 days/week'),
    ('active', '⚡', 'Active', 'Hard exercise 6–7 days/week'),
    ('very_active', '🔥', 'Very Active', 'Physical job or 2× daily training'),
  ];
  return _buildStepShell(
    title: 'How active are you?',
    subtitle: 'Pick what describes a typical week for you',
    infoCard: _buildInfoCard(
      gradient: [const Color(0xFFDCFCE7), const Color(0xFFBBF7D0)],
      child: Column(children: [
        const Text('Total Daily Energy Expenditure',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF166534))),
        const SizedBox(height: 4),
        Text(
          tdee > 0 ? '${tdee.toStringAsFixed(0)} kcal/day' : '—',
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
        ),
        Text('×${_activityMultiplier.toStringAsFixed(2)} activity multiplier',
            style: const TextStyle(fontSize: 11, color: Color(0xFF166534))),
      ]),
    ),
    content: Column(
      children: activities.map((a) => _buildSelectCard(
        value: a.$1, currentValue: _activityLevel,
        label: a.$3, description: a.$4, emoji: a.$2,
        onTap: () => setState(() => _activityLevel = a.$1),
      )).toList(),
    ),
    onBack: _prevPage,
    onNext: _nextPage,
  );
}

Widget _buildStep4Body() {
  final target = _dailyTarget;
  final tdee = _tdee;
  final goals = [
    ('weight_loss', '🔥', 'Lose Weight', '500 kcal daily deficit'),
    ('muscle_gain', '💪', 'Build Muscle', '+300 kcal daily surplus'),
    ('maintenance', '⚖️', 'Stay Fit', 'Maintain current weight'),
  ];
  final offset = _fitnessGoal == 'weight_loss' ? '−500' : _fitnessGoal == 'muscle_gain' ? '+300' : '±0';
  return _buildStepShell(
    title: "What's your goal?",
    subtitle: "We'll adjust your daily target accordingly",
    infoCard: _buildInfoCard(
      gradient: [const Color(0xFFFEE2E2), const Color(0xFFFECACA)],
      child: Column(children: [
        const Text('Your Daily Calorie Target',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF991B1B))),
        const SizedBox(height: 4),
        Text(
          target > 0 ? '${target.toStringAsFixed(0)} kcal' : '—',
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
        ),
        if (tdee > 0)
          Text('$offset kcal from your TDEE',
              style: const TextStyle(fontSize: 11, color: Color(0xFF991B1B))),
      ]),
    ),
    content: Column(
      children: goals.map((g) => _buildSelectCard(
        value: g.$1, currentValue: _fitnessGoal,
        label: g.$3, description: g.$4, emoji: g.$2,
        onTap: () => setState(() => _fitnessGoal = g.$1),
      )).toList(),
    ),
    onBack: _prevPage,
    onNext: _submit,
    isFinal: true,
  );
}
```

- [ ] **Step 4: Run tests**

```bash
flutter test test/onboarding_screen_test.dart
```

Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/screens/onboarding_screen.dart test/onboarding_screen_test.dart
git commit -m "feat: complete OnboardingScreen with steps 2-4 (gender, activity, goal)"
```

---

## Task 7: Wire RegisterScreen → OnboardingScreen

**Files:**
- Modify: `lib/screens/register_screen.dart`

- [ ] **Step 1: Update RegisterScreen navigation**

In `lib/screens/register_screen.dart`, add the import:

```dart
import 'onboarding_screen.dart';
```

Remove the `update_profile_screen.dart` import.

Replace the `Navigator.pushReplacement` call inside `_register()` with:

```dart
Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (_) => const OnboardingScreen(),
  ),
);
```

- [ ] **Step 2: Verify**

```bash
flutter analyze
```

Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add lib/screens/register_screen.dart
git commit -m "feat: navigate to OnboardingScreen after registration"
```

---

## Task 8: Wire ProfileScreen → OnboardingScreen

**Files:**
- Modify: `lib/screens/profile_screen.dart`

- [ ] **Step 1: Update ProfileScreen edit navigation**

In `lib/screens/profile_screen.dart`, add the import:

```dart
import 'onboarding_screen.dart';
```

Replace the `_goToProfileEdit` method:

```dart
void _goToProfileEdit(Map<String, dynamic> profileData) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => OnboardingScreen(
        initialData: profileData,
        isEditing: true,
      ),
    ),
  );
}
```

- [ ] **Step 2: Verify**

```bash
flutter analyze
```

Expected: No errors. The `update_profile_screen.dart` import can remain in `profile_screen.dart` if it is still imported elsewhere; remove it only if the analyzer flags it as unused.

- [ ] **Step 3: Run all tests**

```bash
flutter test
```

Expected: All tests pass.

- [ ] **Step 4: Final commit**

```bash
git add lib/screens/profile_screen.dart
git commit -m "feat: profile edit opens OnboardingScreen pre-populated with current data"
```

---

## Self-Review

**Spec coverage check:**
- ✅ Workout screen mode toggle — Tasks 1–4
- ✅ Simple mode default via SharedPreferences — Task 3
- ✅ Segmented pill in AppBar — Tasks 1 & 2
- ✅ Both WorkoutScreen and WorkoutCalendarScreen get the toggle — Tasks 1 & 2
- ✅ 4-step onboarding wizard with PageView — Tasks 5 & 6
- ✅ Live BMI card, BMR card, TDEE card, daily target card — Tasks 5 & 6
- ✅ Tap-to-select cards (gender, activity, goal) — Task 6
- ✅ Plain-English activity descriptions — Task 6
- ✅ Register flow → OnboardingScreen — Task 7
- ✅ Profile edit → OnboardingScreen pre-populated — Task 8
- ✅ `isEditing` flag routes back to ProfileScreen instead of HomeScreen — Task 5

**Placeholder scan:** No TBDs or incomplete code blocks found.

**Type consistency:**
- `_buildModeToggle` / `_toggleSegment` defined identically in Tasks 1 and 2 — consistent.
- `_buildStep2Body`, `_buildStep3Body`, `_buildStep4Body` defined as placeholders in Task 5, replaced fully in Task 6 — consistent.
- `_buildStepShell`, `_buildInfoCard`, `_buildSelectCard`, `_buildNumberField` all defined in Task 5, used in Tasks 5 and 6 — consistent.
- `OnboardingScreen(initialData, isEditing)` defined in Task 5, called correctly in Tasks 7 and 8 — consistent.
