# Workout Program Export/Import Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let a user export a custom workout or a full workout cycle (weekly plan) to a JSON file, and import a JSON file back in, entirely on-device — no backend changes.

**Architecture:** Two new pure, dependency-free service classes (`WorkoutExportService`, `WorkoutImportService`) hold all JSON-shaping and exercise-name-matching logic and are fully unit tested. A thin `WorkoutFileIO` wrapper around the `file_picker` plugin handles the actual save/open dialogs and is not unit tested (matches this codebase's existing convention — `ApiService`/`WorkoutService` network calls aren't unit tested either; only pure logic is). Three existing screens get new toolbar actions that glue the pure services to the IO wrapper and to `ApiService`.

**Tech Stack:** Flutter/Dart, `flutter_test` (no mocking library in this project — tests use plain data, following `test/navigation_service_test.dart`), `file_picker` (new dependency), existing `ApiService`.

## Global Constraints

- File format field values are exact and case-sensitive: `type` is `"workout"` or `"workout_cycle"`; `version` is the integer `1`.
- Day-pattern keys are exactly `mon, tue, wed, thu, fri, sat, sun` (matches `_dayKeys` in `new_workout_cycle_screen.dart` and `workout_calendar_screen.dart`).
- No backend/API changes — everything reads/writes through the existing `ApiService` endpoints already used by the app.
- Follow the codebase's existing convention on these screens of passing workout/exercise data as raw `Map<String, dynamic>` (as `ApiService` returns), not the unused `Workout`/`Exercise` model classes in `lib/models/workout.dart`.
- New dependency: `file_picker: ^8.1.3` in `pubspec.yaml`.
- New pure logic files are unit tested with plain `flutter_test` (no mocks); thin IO wrappers around `file_picker`/`ApiService` are not unit tested, matching how `ApiService` itself is untested in this codebase — verify those manually via `flutter analyze` and a manual run.

---

### Task 1: Add the `file_picker` dependency

**Files:**
- Modify: `pubspec.yaml`

**Interfaces:**
- Produces: the `file_picker` package, available to all later tasks via `import 'package:file_picker/file_picker.dart';`.

- [ ] **Step 1: Add the dependency**

In `pubspec.yaml`, add this line inside the existing `dependencies:` block (after the `flutter_timezone` line, before the Cupertino Icons comment):

```yaml
  file_picker: ^8.1.3  # For export/import of workout program JSON files
```

- [ ] **Step 2: Fetch the package**

Run: `flutter pub get`
Expected: completes with no errors, `pubspec.lock` updated to include `file_picker` and its transitive dependencies.

- [ ] **Step 3: Verify the project still analyzes cleanly**

Run: `flutter analyze`
Expected: no new errors (pre-existing warnings, if any, are unrelated and unaffected).

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: add file_picker dependency for workout export/import"
```

---

### Task 2: `WorkoutExportService` — single workout export

**Files:**
- Create: `lib/services/workout_export_service.dart`
- Test: `test/workout_export_service_test.dart`

**Interfaces:**
- Produces: `WorkoutExportService.workoutExportJson(Map<String, dynamic> workout) -> String` and `WorkoutExportService.suggestExportFilename(String workoutName) -> String`, both static, pure, no I/O. `workout` is shaped like the value `ApiService.fetchCustomWorkout` resolves to: `{'name': ..., 'description': ..., 'gym_exercises': [{'name': ..., 'pivot': {'sets': ..., 'reps': ..., 'duration': ..., 'rest': ...}}, ...]}` (this is the exact shape `workout_detail_screen.dart` already consumes).

- [ ] **Step 1: Write the failing tests**

Create `test/workout_export_service_test.dart`:

```dart
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_tracker_app/services/workout_export_service.dart';

void main() {
  group('WorkoutExportService.workoutExportJson', () {
    test('serializes a workout with its exercises to the export schema', () {
      final workout = {
        'id': 1,
        'name': 'Push Day',
        'description': 'Chest, shoulders, triceps',
        'gym_exercises': [
          {
            'name': 'Bench Press',
            'body_part': 'chest',
            'pivot': {'sets': 3, 'reps': 10, 'duration': null, 'rest': 60},
          },
          {
            'name': 'Plank',
            'body_part': 'core',
            'pivot': {'sets': 3, 'reps': null, 'duration': 30, 'rest': 30},
          },
        ],
      };

      final json = jsonDecode(WorkoutExportService.workoutExportJson(workout));

      expect(json['type'], 'workout');
      expect(json['version'], 1);
      expect(json['name'], 'Push Day');
      expect(json['description'], 'Chest, shoulders, triceps');
      expect(json['exercises'], [
        {'name': 'Bench Press', 'sets': 3, 'reps': 10, 'duration': null, 'rest': 60},
        {'name': 'Plank', 'sets': 3, 'reps': null, 'duration': 30, 'rest': 30},
      ]);
    });

    test('exports a workout with no exercises as an empty list', () {
      final workout = {'id': 2, 'name': 'Empty', 'description': '', 'gym_exercises': []};
      final json = jsonDecode(WorkoutExportService.workoutExportJson(workout));
      expect(json['exercises'], isEmpty);
    });
  });

  group('WorkoutExportService.suggestExportFilename', () {
    test('lowercases and underscores a workout name', () {
      expect(WorkoutExportService.suggestExportFilename('Push Day'), 'push_day.json');
    });

    test('strips punctuation', () {
      expect(WorkoutExportService.suggestExportFilename('Arms & Abs!'), 'arms_abs.json');
    });

    test('falls back to a default name when nothing sanitizes cleanly', () {
      expect(WorkoutExportService.suggestExportFilename('!!!'), 'workout.json');
    });
  });
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `flutter test test/workout_export_service_test.dart`
Expected: FAIL — `lib/services/workout_export_service.dart` does not exist yet.

- [ ] **Step 3: Write the implementation**

Create `lib/services/workout_export_service.dart`:

```dart
import 'dart:convert';

class WorkoutExportService {
  static const int schemaVersion = 1;
  static const List<String> dayKeys = [
    'mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun',
  ];

  static String workoutExportJson(Map<String, dynamic> workout) {
    final export = {
      'type': 'workout',
      'version': schemaVersion,
      'name': workout['name'],
      'description': workout['description'],
      'exercises': _exportExercises(workout),
    };

    return const JsonEncoder.withIndent('  ').convert(export);
  }

  static List<Map<String, dynamic>> _exportExercises(Map<String, dynamic> workout) {
    final gymExercises = workout['gym_exercises'] as List<dynamic>? ?? [];
    return gymExercises
        .map((e) => _exerciseExportMap(e as Map<String, dynamic>))
        .toList();
  }

  static Map<String, dynamic> _exerciseExportMap(Map<String, dynamic> exercise) {
    final pivot = exercise['pivot'] as Map<String, dynamic>? ?? {};
    return {
      'name': exercise['name'],
      'sets': pivot['sets'],
      'reps': pivot['reps'],
      'duration': pivot['duration'],
      'rest': pivot['rest'],
    };
  }

  static String suggestExportFilename(String workoutName) {
    final sanitized = workoutName
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return '${sanitized.isEmpty ? 'workout' : sanitized}.json';
  }
}
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `flutter test test/workout_export_service_test.dart`
Expected: PASS (5 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/services/workout_export_service.dart test/workout_export_service_test.dart
git commit -m "feat: add pure JSON export for a single custom workout"
```

---

### Task 3: `WorkoutExportService` — workout cycle export

**Files:**
- Modify: `lib/services/workout_export_service.dart`
- Test: `test/workout_export_service_cycle_test.dart`

**Interfaces:**
- Consumes: `WorkoutExportService._exerciseExportMap` (from Task 2, same file).
- Produces:
  - `WorkoutExportService.extractCyclePattern(Map<String, dynamic> weeklyPlan) -> CyclePattern`, where `CyclePattern` is a new class with `final int weeks;` and `final Map<String, int?> daysPattern;` (day key → workout id or null). `weeklyPlan` is shaped like what `ApiService.fetchWeeklyWorkouts()` resolves to: `{'weeks': [{'week_start': '2026-08-10', 'days': {'mon': {'workouts': [{'workout': {'id': 1, 'name': 'Push Day'}}]}, 'tue': {'workouts': []}, ...}}, ...]}` (this exact shape is already parsed in `workout_calendar_screen.dart`).
  - `WorkoutExportService.cycleExportJson({required int weeks, required Map<String, int?> daysPatternByWorkoutId, required Map<int, Map<String, dynamic>> workoutDetailsById}) -> String`. Each value in `workoutDetailsById` is a full workout detail map shaped like Task 2's `workout` parameter.
- Throws `ArgumentError` from `extractCyclePattern` when `weeklyPlan['weeks']` is empty or missing.

- [ ] **Step 1: Write the failing tests**

Create `test/workout_export_service_cycle_test.dart`:

```dart
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_tracker_app/services/workout_export_service.dart';

void main() {
  group('WorkoutExportService.extractCyclePattern', () {
    test('reads the first week as the repeating pattern and counts total weeks', () {
      final weeklyPlan = {
        'weeks': [
          {
            'week_start': '2026-08-10',
            'days': {
              'mon': {'workouts': [{'workout': {'id': 1, 'name': 'Push Day'}}]},
              'tue': {'workouts': []},
              'wed': {'workouts': [{'workout': {'id': 2, 'name': 'Pull Day'}}]},
              'thu': {'workouts': []},
              'fri': {'workouts': [{'workout': {'id': 1, 'name': 'Push Day'}}]},
              'sat': {'workouts': []},
              'sun': {'workouts': []},
            },
          },
          {'week_start': '2026-08-17', 'days': {}},
        ],
      };

      final pattern = WorkoutExportService.extractCyclePattern(weeklyPlan);

      expect(pattern.weeks, 2);
      expect(pattern.daysPattern, {
        'mon': 1, 'tue': null, 'wed': 2, 'thu': null, 'fri': 1, 'sat': null, 'sun': null,
      });
    });

    test('throws when the plan has no weeks', () {
      expect(
        () => WorkoutExportService.extractCyclePattern({'weeks': []}),
        throwsArgumentError,
      );
    });
  });

  group('WorkoutExportService.cycleExportJson', () {
    test('bundles the days pattern by name and dedupes referenced workouts', () {
      final json = jsonDecode(WorkoutExportService.cycleExportJson(
        weeks: 4,
        daysPatternByWorkoutId: {
          'mon': 1, 'tue': null, 'wed': 2, 'thu': null, 'fri': 1, 'sat': null, 'sun': null,
        },
        workoutDetailsById: {
          1: {
            'name': 'Push Day',
            'description': 'Chest',
            'gym_exercises': [
              {'name': 'Bench Press', 'pivot': {'sets': 3, 'reps': 10, 'duration': null, 'rest': 60}},
            ],
          },
          2: {
            'name': 'Pull Day',
            'description': 'Back',
            'gym_exercises': [
              {'name': 'Lat Pulldown', 'pivot': {'sets': 3, 'reps': 12, 'duration': null, 'rest': 60}},
            ],
          },
        },
      ));

      expect(json['type'], 'workout_cycle');
      expect(json['version'], 1);
      expect(json['weeks'], 4);
      expect(json['days_pattern'], {
        'mon': 'Push Day', 'tue': null, 'wed': 'Pull Day', 'thu': null, 'fri': 'Push Day', 'sat': null, 'sun': null,
      });
      expect(json['workouts'], hasLength(2));
      final pushDay = (json['workouts'] as List).firstWhere((w) => w['name'] == 'Push Day');
      expect(pushDay['exercises'], [
        {'name': 'Bench Press', 'sets': 3, 'reps': 10, 'duration': null, 'rest': 60},
      ]);
    });
  });
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `flutter test test/workout_export_service_cycle_test.dart`
Expected: FAIL — `extractCyclePattern`/`cycleExportJson` are not defined.

- [ ] **Step 3: Write the implementation**

Add to `lib/services/workout_export_service.dart` (inside the `WorkoutExportService` class, and one new top-level class):

```dart
class CyclePattern {
  final int weeks;
  final Map<String, int?> daysPattern;

  CyclePattern({required this.weeks, required this.daysPattern});
}
```

Add these two static methods inside `WorkoutExportService`:

```dart
  static CyclePattern extractCyclePattern(Map<String, dynamic> weeklyPlan) {
    final weeksList = weeklyPlan['weeks'] as List<dynamic>? ?? [];
    if (weeksList.isEmpty) {
      throw ArgumentError('weeklyPlan has no weeks to export');
    }

    final firstWeekDays = weeksList.first['days'] as Map<String, dynamic>? ?? {};
    final pattern = <String, int?>{};

    for (final dayKey in dayKeys) {
      final dayData = firstWeekDays[dayKey] as Map<String, dynamic>?;
      final dayWorkouts = dayData?['workouts'] as List<dynamic>? ?? [];
      if (dayWorkouts.isEmpty) {
        pattern[dayKey] = null;
        continue;
      }
      final workout = dayWorkouts.first['workout'] as Map<String, dynamic>;
      pattern[dayKey] = workout['id'] as int;
    }

    return CyclePattern(weeks: weeksList.length, daysPattern: pattern);
  }

  static String cycleExportJson({
    required int weeks,
    required Map<String, int?> daysPatternByWorkoutId,
    required Map<int, Map<String, dynamic>> workoutDetailsById,
  }) {
    final namedPattern = {
      for (final entry in daysPatternByWorkoutId.entries)
        entry.key: entry.value == null
            ? null
            : workoutDetailsById[entry.value]!['name'],
    };

    final export = {
      'type': 'workout_cycle',
      'version': schemaVersion,
      'weeks': weeks,
      'days_pattern': namedPattern,
      'workouts': workoutDetailsById.values
          .map((w) => {
                'name': w['name'],
                'description': w['description'],
                'exercises': _exportExercises(w),
              })
          .toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(export);
  }
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `flutter test test/workout_export_service_cycle_test.dart test/workout_export_service_test.dart`
Expected: PASS (all tests in both files)

- [ ] **Step 5: Commit**

```bash
git add lib/services/workout_export_service.dart test/workout_export_service_cycle_test.dart
git commit -m "feat: add pure JSON export for workout cycles"
```

---

### Task 4: `WorkoutImportService` — file parsing and validation

**Files:**
- Create: `lib/services/workout_import_service.dart`
- Test: `test/workout_import_service_test.dart`

**Interfaces:**
- Produces:
  - `class WorkoutImportFormatException implements Exception` with `final String message;` and a `toString()` returning `message`.
  - `WorkoutImportService.parseWorkoutImportJson(String jsonString) -> Map<String, dynamic>`, static, pure. Throws `WorkoutImportFormatException` for invalid JSON, wrong/missing `type`, or unsupported `version`.
  - `WorkoutImportService.supportedVersion` — `static const int`, value `1`.

- [ ] **Step 1: Write the failing tests**

Create `test/workout_import_service_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_tracker_app/services/workout_import_service.dart';

void main() {
  group('WorkoutImportService.parseWorkoutImportJson', () {
    test('parses a valid single-workout export', () {
      final decoded = WorkoutImportService.parseWorkoutImportJson(
        '{"type": "workout", "version": 1, "name": "Push Day", "description": "", "exercises": []}',
      );
      expect(decoded['type'], 'workout');
      expect(decoded['name'], 'Push Day');
    });

    test('parses a valid workout-cycle export', () {
      final decoded = WorkoutImportService.parseWorkoutImportJson(
        '{"type": "workout_cycle", "version": 1, "weeks": 4, "days_pattern": {}, "workouts": []}',
      );
      expect(decoded['type'], 'workout_cycle');
    });

    test('rejects text that is not JSON', () {
      expect(
        () => WorkoutImportService.parseWorkoutImportJson('not json'),
        throwsA(isA<WorkoutImportFormatException>()),
      );
    });

    test('rejects JSON that is not an object', () {
      expect(
        () => WorkoutImportService.parseWorkoutImportJson('[1, 2, 3]'),
        throwsA(isA<WorkoutImportFormatException>()),
      );
    });

    test('rejects JSON with an unrecognized type', () {
      expect(
        () => WorkoutImportService.parseWorkoutImportJson('{"type": "meal_plan", "version": 1}'),
        throwsA(isA<WorkoutImportFormatException>()),
      );
    });

    test('rejects a version newer than this app supports', () {
      expect(
        () => WorkoutImportService.parseWorkoutImportJson('{"type": "workout", "version": 2}'),
        throwsA(isA<WorkoutImportFormatException>()),
      );
    });
  });
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `flutter test test/workout_import_service_test.dart`
Expected: FAIL — `lib/services/workout_import_service.dart` does not exist yet.

- [ ] **Step 3: Write the implementation**

Create `lib/services/workout_import_service.dart`:

```dart
import 'dart:convert';

class WorkoutImportFormatException implements Exception {
  final String message;
  WorkoutImportFormatException(this.message);

  @override
  String toString() => message;
}

class WorkoutImportService {
  static const int supportedVersion = 1;

  static Map<String, dynamic> parseWorkoutImportJson(String jsonString) {
    dynamic decoded;
    try {
      decoded = jsonDecode(jsonString);
    } on FormatException {
      throw WorkoutImportFormatException('That file is not valid JSON.');
    }

    if (decoded is! Map<String, dynamic>) {
      throw WorkoutImportFormatException('That file is not a workout program export.');
    }

    final type = decoded['type'];
    if (type != 'workout' && type != 'workout_cycle') {
      throw WorkoutImportFormatException('That file is not a workout program export.');
    }

    if (decoded['version'] != supportedVersion) {
      throw WorkoutImportFormatException(
        'This file was exported by a version of the app this import cannot read.',
      );
    }

    return decoded;
  }
}
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `flutter test test/workout_import_service_test.dart`
Expected: PASS (6 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/services/workout_import_service.dart test/workout_import_service_test.dart
git commit -m "feat: add workout import file parsing and validation"
```

---

### Task 5: `WorkoutImportService` — exercise name matching

**Files:**
- Modify: `lib/services/workout_import_service.dart`
- Test: `test/workout_import_service_matching_test.dart`

**Interfaces:**
- Consumes: nothing new from prior tasks (standalone logic in the same file).
- Produces:
  - `class ExerciseMatchResult` with `final List<Map<String, dynamic>> matchedGymExercises;` (each shaped `{'gym_exercise_id': int, 'sets': ..., 'reps': ..., 'duration': ..., 'rest': ...}` — the exact shape `ApiService.storeCustomWorkout`'s `gymExercises` parameter expects) and `final List<String> unmatchedNames;`.
  - `WorkoutImportService.matchWorkoutExercises(Map<String, dynamic> workoutJson, List<Map<String, dynamic>> catalog) -> ExerciseMatchResult`, static, pure. `workoutJson['exercises']` is a list shaped like the Task 2 export schema's `exercises` field. `catalog` is shaped like `ApiService.getGymExercises()`'s resolved list (each item has `'id'` and `'name'`).

- [ ] **Step 1: Write the failing tests**

Create `test/workout_import_service_matching_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_tracker_app/services/workout_import_service.dart';

void main() {
  group('WorkoutImportService.matchWorkoutExercises', () {
    final catalog = [
      {'id': 10, 'name': 'Bench Press'},
      {'id': 11, 'name': 'Squat'},
    ];

    test('resolves exercises to gym_exercise_id by case-insensitive name', () {
      final result = WorkoutImportService.matchWorkoutExercises({
        'exercises': [
          {'name': 'bench press', 'sets': 3, 'reps': 10, 'duration': null, 'rest': 60},
        ],
      }, catalog);

      expect(result.matchedGymExercises, [
        {'gym_exercise_id': 10, 'sets': 3, 'reps': 10, 'duration': null, 'rest': 60},
      ]);
      expect(result.unmatchedNames, isEmpty);
    });

    test('collects names with no catalog match without throwing', () {
      final result = WorkoutImportService.matchWorkoutExercises({
        'exercises': [
          {'name': 'Bench Press', 'sets': 3, 'reps': 10, 'duration': null, 'rest': 60},
          {'name': 'Nonexistent Move', 'sets': 3, 'reps': 10, 'duration': null, 'rest': 60},
        ],
      }, catalog);

      expect(result.matchedGymExercises, hasLength(1));
      expect(result.unmatchedNames, ['Nonexistent Move']);
    });

    test('handles a workout with no exercises', () {
      final result = WorkoutImportService.matchWorkoutExercises({'exercises': []}, catalog);
      expect(result.matchedGymExercises, isEmpty);
      expect(result.unmatchedNames, isEmpty);
    });
  });
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `flutter test test/workout_import_service_matching_test.dart`
Expected: FAIL — `matchWorkoutExercises`/`ExerciseMatchResult` are not defined.

- [ ] **Step 3: Write the implementation**

Add to `lib/services/workout_import_service.dart` (new top-level class, plus one new static method inside `WorkoutImportService`):

```dart
class ExerciseMatchResult {
  final List<Map<String, dynamic>> matchedGymExercises;
  final List<String> unmatchedNames;

  ExerciseMatchResult({
    required this.matchedGymExercises,
    required this.unmatchedNames,
  });
}
```

```dart
  static ExerciseMatchResult matchWorkoutExercises(
    Map<String, dynamic> workoutJson,
    List<Map<String, dynamic>> catalog,
  ) {
    final nameToId = {
      for (final exercise in catalog)
        (exercise['name'] as String).toLowerCase(): exercise['id'] as int,
    };

    final matched = <Map<String, dynamic>>[];
    final unmatched = <String>[];

    final exercises = workoutJson['exercises'] as List<dynamic>? ?? [];
    for (final raw in exercises) {
      final exercise = raw as Map<String, dynamic>;
      final name = exercise['name'] as String;
      final id = nameToId[name.toLowerCase()];
      if (id == null) {
        unmatched.add(name);
        continue;
      }
      matched.add({
        'gym_exercise_id': id,
        'sets': exercise['sets'],
        'reps': exercise['reps'],
        'duration': exercise['duration'],
        'rest': exercise['rest'],
      });
    }

    return ExerciseMatchResult(matchedGymExercises: matched, unmatchedNames: unmatched);
  }
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `flutter test test/workout_import_service_matching_test.dart`
Expected: PASS (3 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/services/workout_import_service.dart test/workout_import_service_matching_test.dart
git commit -m "feat: match imported exercises to the user's catalog by name"
```

---

### Task 6: `WorkoutImportService` — remap a cycle's days pattern to new workout ids

**Files:**
- Modify: `lib/services/workout_import_service.dart`
- Test: `test/workout_import_service_remap_test.dart`

**Interfaces:**
- Produces: `WorkoutImportService.remapDaysPatternToIds(Map<String, dynamic> daysPatternByName, Map<String, int> nameToNewId) -> Map<String, int?>`, static, pure. Input `daysPatternByName` is shaped like the Task 3 export schema's `days_pattern` field (day key → workout name or null). Output is shaped exactly like `ApiService.storeWeeklyWorkouts`'s `daysPattern` parameter (`Map<String, int?>`, day key → newly-created workout id or null).

- [ ] **Step 1: Write the failing tests**

Create `test/workout_import_service_remap_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_tracker_app/services/workout_import_service.dart';

void main() {
  group('WorkoutImportService.remapDaysPatternToIds', () {
    test('maps workout names to their newly-created ids', () {
      final result = WorkoutImportService.remapDaysPatternToIds(
        {'mon': 'Push Day', 'tue': null, 'wed': 'Pull Day'},
        {'Push Day': 101, 'Pull Day': 102},
      );

      expect(result, {'mon': 101, 'tue': null, 'wed': 102});
    });

    test('leaves a day null when its workout name has no new id', () {
      final result = WorkoutImportService.remapDaysPatternToIds(
        {'mon': 'Missing Workout'},
        {},
      );

      expect(result, {'mon': null});
    });
  });
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `flutter test test/workout_import_service_remap_test.dart`
Expected: FAIL — `remapDaysPatternToIds` is not defined.

- [ ] **Step 3: Write the implementation**

Add this static method inside `WorkoutImportService` in `lib/services/workout_import_service.dart`:

```dart
  static Map<String, int?> remapDaysPatternToIds(
    Map<String, dynamic> daysPatternByName,
    Map<String, int> nameToNewId,
  ) {
    return {
      for (final entry in daysPatternByName.entries)
        entry.key: entry.value == null ? null : nameToNewId[entry.value as String],
    };
  }
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `flutter test test/workout_import_service_remap_test.dart`
Expected: PASS (2 tests)

- [ ] **Step 5: Run the full service test suite together**

Run: `flutter test test/workout_export_service_test.dart test/workout_export_service_cycle_test.dart test/workout_import_service_test.dart test/workout_import_service_matching_test.dart test/workout_import_service_remap_test.dart`
Expected: PASS (all tests, all five files)

- [ ] **Step 6: Commit**

```bash
git add lib/services/workout_import_service.dart test/workout_import_service_remap_test.dart
git commit -m "feat: remap an imported cycle's days pattern to new workout ids"
```

---

### Task 7: `WorkoutFileIO` — file_picker wrapper

**Files:**
- Create: `lib/services/workout_file_io.dart`

**Interfaces:**
- Consumes: `file_picker` (Task 1).
- Produces:
  - `WorkoutFileIO.saveJsonFile({required String suggestedFileName, required String contents}) -> Future<bool>` — opens the platform save dialog, writes `contents` as UTF-8 to the chosen location, returns `true` if the user completed the save and `false` if they cancelled.
  - `WorkoutFileIO.pickJsonFileContents() -> Future<String?>` — opens the platform open-file dialog filtered to `.json`, returns the file's contents as a UTF-8 string, or `null` if the user cancelled.

This class is a thin IO wrapper (like `ApiService`'s HTTP calls) and is not unit tested — `file_picker`'s platform channels aren't available in the `flutter_test` environment. Verify it manually in Task 8/9/11 by running the app.

- [ ] **Step 1: Write the implementation**

Create `lib/services/workout_file_io.dart`:

```dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

class WorkoutFileIO {
  static Future<bool> saveJsonFile({
    required String suggestedFileName,
    required String contents,
  }) async {
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Save workout program',
      fileName: suggestedFileName,
      type: FileType.custom,
      allowedExtensions: ['json'],
      bytes: Uint8List.fromList(utf8.encode(contents)),
    );
    return path != null;
  }

  static Future<String?> pickJsonFileContents() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Import workout program',
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes != null) {
      return utf8.decode(bytes);
    }

    final path = file.path;
    if (path == null) return null;
    return File(path).readAsString();
  }
}
```

- [ ] **Step 2: Verify the project analyzes cleanly**

Run: `flutter analyze`
Expected: no new errors.

- [ ] **Step 3: Commit**

```bash
git add lib/services/workout_file_io.dart
git commit -m "feat: add file_picker wrapper for workout program save/open"
```

---

### Task 8: Export a single workout from `workout_detail_screen.dart`

**Files:**
- Modify: `lib/screens/workout/workout_detail_screen.dart:1-152` (imports, and the `Row` at lines 124-152 containing the workout name and Edit button)

**Interfaces:**
- Consumes: `WorkoutExportService.workoutExportJson`, `WorkoutExportService.suggestExportFilename` (Task 2), `WorkoutFileIO.saveJsonFile` (Task 7).

- [ ] **Step 1: Add imports**

At the top of `lib/screens/workout/workout_detail_screen.dart`, add:

```dart
import '../../services/workout_export_service.dart';
import '../../services/workout_file_io.dart';
```

- [ ] **Step 2: Add an export handler and a snackbar helper**

Inside `_WorkoutDetailScreenState`, add these two methods (near `_fetchWorkoutDetails`):

```dart
  Future<void> _exportWorkout() async {
    try {
      final workout = await _workoutFuture;
      final json = WorkoutExportService.workoutExportJson(workout);
      final filename = WorkoutExportService.suggestExportFilename(workout['name'] as String);
      final saved = await WorkoutFileIO.saveJsonFile(
        suggestedFileName: filename,
        contents: json,
      );
      if (!mounted || !saved) return;
      _showSnack('Workout exported successfully');
    } catch (e) {
      if (!mounted) return;
      _showSnack('Failed to export workout: $e', isError: true);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: isError ? colorScheme.onError : colorScheme.onPrimary),
        ),
        backgroundColor: isError ? colorScheme.error : colorScheme.primary,
      ),
    );
  }
```

- [ ] **Step 3: Add the export button next to Edit**

Find this `Row` (currently lines 124-152):

```dart
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              workout['name'],
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: colorScheme.primary),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditWorkoutScreen(
                                    workoutId: widget.workoutId,
                                  ),
                                ),
                              );
                              _fetchWorkoutDetails();
                            },
                          ),
                        ],
                      ),
```

Replace it with (adds an export `IconButton` before the Edit button):

```dart
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              workout['name'],
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.ios_share, color: colorScheme.primary),
                            tooltip: 'Export workout',
                            onPressed: _exportWorkout,
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: colorScheme.primary),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditWorkoutScreen(
                                    workoutId: widget.workoutId,
                                  ),
                                ),
                              );
                              _fetchWorkoutDetails();
                            },
                          ),
                        ],
                      ),
```

- [ ] **Step 4: Verify the project analyzes cleanly**

Run: `flutter analyze`
Expected: no new errors.

- [ ] **Step 5: Manually verify in the running app**

Run: `flutter run` (or use the existing dev-run workflow for this project), open any custom workout's detail screen, tap the new export icon, and confirm the save dialog opens and a valid `.json` file is written (open it afterward and check it matches the Task 2 schema).

- [ ] **Step 6: Commit**

```bash
git add lib/screens/workout/workout_detail_screen.dart
git commit -m "feat: add export button to the workout detail screen"
```

---

### Task 9: Export a workout cycle from `workout_calendar_screen.dart`

**Files:**
- Modify: `lib/screens/workout/workout_calendar_screen.dart:1-173` (imports, and the app bar `actions` list at lines 161-172)

**Interfaces:**
- Consumes: `WorkoutExportService.extractCyclePattern`, `WorkoutExportService.cycleExportJson` (Task 3), `WorkoutFileIO.saveJsonFile` (Task 7), `ApiService.fetchCustomWorkout` (existing).

- [ ] **Step 1: Add imports**

At the top of `lib/screens/workout/workout_calendar_screen.dart`, add:

```dart
import '../../services/workout_export_service.dart';
import '../../services/workout_file_io.dart';
```

- [ ] **Step 2: Add an export handler and a snackbar helper**

Inside `_WorkoutCalendarScreenState`, add these two methods (near `_fetchWeeklyPlan`):

```dart
  Future<void> _exportCycle() async {
    try {
      final weeklyPlan = await _weeklyPlanFuture;
      final weeksList = weeklyPlan['weeks'] as List<dynamic>?;
      if (weeksList == null || weeksList.isEmpty) {
        if (!mounted) return;
        _showSnack('No workout plan to export');
        return;
      }

      final pattern = WorkoutExportService.extractCyclePattern(weeklyPlan);
      final uniqueIds = pattern.daysPattern.values.whereType<int>().toSet();

      final detailsById = <int, Map<String, dynamic>>{};
      for (final id in uniqueIds) {
        detailsById[id] = await _apiService.fetchCustomWorkout(id);
      }

      final json = WorkoutExportService.cycleExportJson(
        weeks: pattern.weeks,
        daysPatternByWorkoutId: pattern.daysPattern,
        workoutDetailsById: detailsById,
      );

      final saved = await WorkoutFileIO.saveJsonFile(
        suggestedFileName: 'workout_cycle.json',
        contents: json,
      );

      if (!mounted || !saved) return;
      _showSnack('Workout cycle exported successfully');
    } catch (e) {
      if (!mounted) return;
      _showSnack('Failed to export workout cycle: $e', isError: true);
    }
  }

  void _showSnack(String message) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: colorScheme.primary),
    );
  }
```

- [ ] **Step 3: Add the export button to the app bar**

Find this `actions` list (currently lines 161-172):

```dart
        actions: [
          if (widget.onModeToggle != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: _buildModeToggle(context, isSimple: false),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchWeeklyPlan,
            tooltip: 'Refresh workout plan',
          ),
        ],
```

Replace it with (adds an export `IconButton` before Refresh):

```dart
        actions: [
          if (widget.onModeToggle != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: _buildModeToggle(context, isSimple: false),
            ),
          IconButton(
            icon: const Icon(Icons.ios_share),
            onPressed: _exportCycle,
            tooltip: 'Export workout cycle',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchWeeklyPlan,
            tooltip: 'Refresh workout plan',
          ),
        ],
```

- [ ] **Step 4: Verify the project analyzes cleanly**

Run: `flutter analyze`
Expected: no new errors.

- [ ] **Step 5: Manually verify in the running app**

Run the app, switch Workouts to Advanced mode (calendar view), create a workout cycle if none exists, tap the new export icon, and confirm the saved `.json` file matches the Task 3 schema (correct `days_pattern` names and bundled `workouts`).

- [ ] **Step 6: Commit**

```bash
git add lib/screens/workout/workout_calendar_screen.dart
git commit -m "feat: add export button to the workout calendar screen"
```

---

### Task 10: `ImportConfirmationDialog` widget

**Files:**
- Create: `lib/screens/workout/import_confirmation_dialog.dart`
- Test: `test/import_confirmation_dialog_test.dart`

**Interfaces:**
- Produces: `ImportConfirmationDialog.show(BuildContext context, {required List<String> workoutNames, required List<String> unmatchedExerciseNames}) -> Future<bool>` — shows the workout name(s) about to be created and any exercise names that couldn't be matched; resolves `true` if the user taps Import, `false` if they cancel (including dismissing the dialog).

- [ ] **Step 1: Write the failing tests**

Create `test/import_confirmation_dialog_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_tracker_app/screens/workout/import_confirmation_dialog.dart';

void main() {
  testWidgets('shows workout names and unmatched exercise warnings, Import returns true',
      (tester) async {
    late Future<bool> resultFuture;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              resultFuture = ImportConfirmationDialog.show(
                context,
                workoutNames: ['Push Day', 'Pull Day'],
                unmatchedExerciseNames: ['Cable Fly'],
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('• Push Day'), findsOneWidget);
    expect(find.text('• Pull Day'), findsOneWidget);
    expect(find.text('• Cable Fly'), findsOneWidget);

    await tester.tap(find.text('Import'));
    await tester.pumpAndSettle();

    expect(await resultFuture, isTrue);
  });

  testWidgets('hides the warning section when every exercise matched', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              ImportConfirmationDialog.show(
                context,
                workoutNames: ['Push Day'],
                unmatchedExerciseNames: [],
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.textContaining("weren't found"), findsNothing);
  });

  testWidgets('Cancel returns false', (tester) async {
    late Future<bool> resultFuture;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              resultFuture = ImportConfirmationDialog.show(
                context,
                workoutNames: ['Push Day'],
                unmatchedExerciseNames: [],
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(await resultFuture, isFalse);
  });
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `flutter test test/import_confirmation_dialog_test.dart`
Expected: FAIL — `lib/screens/workout/import_confirmation_dialog.dart` does not exist yet.

- [ ] **Step 3: Write the implementation**

Create `lib/screens/workout/import_confirmation_dialog.dart`:

```dart
import 'package:flutter/material.dart';

class ImportConfirmationDialog extends StatelessWidget {
  final List<String> workoutNames;
  final List<String> unmatchedExerciseNames;

  const ImportConfirmationDialog({
    super.key,
    required this.workoutNames,
    required this.unmatchedExerciseNames,
  });

  static Future<bool> show(
    BuildContext context, {
    required List<String> workoutNames,
    required List<String> unmatchedExerciseNames,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ImportConfirmationDialog(
        workoutNames: workoutNames,
        unmatchedExerciseNames: unmatchedExerciseNames,
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Import workout program'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('The following workouts will be created:'),
            const SizedBox(height: 8),
            for (final name in workoutNames)
              Text('• $name', style: const TextStyle(fontWeight: FontWeight.bold)),
            if (unmatchedExerciseNames.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                "These exercises weren't found and will be skipped:",
                style: TextStyle(color: colorScheme.error),
              ),
              const SizedBox(height: 8),
              for (final name in unmatchedExerciseNames) Text('• $name'),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Import'),
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `flutter test test/import_confirmation_dialog_test.dart`
Expected: PASS (3 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/screens/workout/import_confirmation_dialog.dart test/import_confirmation_dialog_test.dart
git commit -m "feat: add import confirmation dialog"
```

---

### Task 11: Wire import into `workout_list_screen.dart`

**Files:**
- Modify: `lib/screens/workout/workout_list_screen.dart:1-129` (imports, the app bar `actions` list at lines 109-115, and new methods on `_WorkoutManagementScreenState`)

**Interfaces:**
- Consumes: `WorkoutFileIO.pickJsonFileContents` (Task 7), `WorkoutImportService.parseWorkoutImportJson`, `WorkoutImportFormatException`, `WorkoutImportService.matchWorkoutExercises`, `ExerciseMatchResult`, `WorkoutImportService.remapDaysPatternToIds` (Tasks 4-6), `ImportConfirmationDialog.show` (Task 10), `ApiService.getGymExercises`, `ApiService.storeCustomWorkout`, `ApiService.storeWeeklyWorkouts` (existing).

This task has no new unit tests of its own — all the logic it calls is already covered in Tasks 2-6 and 10. Verify it by running the app (Step 5).

- [ ] **Step 1: Add imports**

At the top of `lib/screens/workout/workout_list_screen.dart`, add:

```dart
import 'package:intl/intl.dart';
import '../../services/workout_file_io.dart';
import '../../services/workout_import_service.dart';
import 'import_confirmation_dialog.dart';
```

- [ ] **Step 2: Add the import button to the app bar**

Find this `actions` list (currently lines 109-115):

```dart
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchWorkouts,
            tooltip: 'Refresh workouts',
          ),
        ],
```

Replace it with (adds an import `IconButton` before Refresh):

```dart
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload_outlined),
            onPressed: _importWorkoutProgram,
            tooltip: 'Import workout program',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchWorkouts,
            tooltip: 'Refresh workouts',
          ),
        ],
```

- [ ] **Step 3: Add the import flow methods**

Inside `_WorkoutManagementScreenState`, add these methods (near `_fetchWorkouts`):

```dart
  Future<void> _importWorkoutProgram() async {
    try {
      final contents = await WorkoutFileIO.pickJsonFileContents();
      if (contents == null) return;

      final decoded = WorkoutImportService.parseWorkoutImportJson(contents);
      final catalog =
          (await _apiService.getGymExercises()).cast<Map<String, dynamic>>();

      if (decoded['type'] == 'workout') {
        await _importSingleWorkout(decoded, catalog);
      } else {
        await _importWorkoutCycle(decoded, catalog);
      }
    } on WorkoutImportFormatException catch (e) {
      _showSnack(e.message, isError: true);
    } catch (e) {
      _showSnack('Failed to import workout program: $e', isError: true);
    }
  }

  Future<void> _importSingleWorkout(
    Map<String, dynamic> workoutJson,
    List<Map<String, dynamic>> catalog,
  ) async {
    final match = WorkoutImportService.matchWorkoutExercises(workoutJson, catalog);

    if (!mounted) return;
    final confirmed = await ImportConfirmationDialog.show(
      context,
      workoutNames: [workoutJson['name'] as String],
      unmatchedExerciseNames: match.unmatchedNames,
    );
    if (!confirmed) return;

    await _apiService.storeCustomWorkout(
      workoutJson['name'] as String,
      workoutJson['description'] as String? ?? '',
      match.matchedGymExercises,
    );

    if (!mounted) return;
    _showSnack('Workout "${workoutJson['name']}" imported successfully');
    _fetchWorkouts();
  }

  Future<void> _importWorkoutCycle(
    Map<String, dynamic> cycleJson,
    List<Map<String, dynamic>> catalog,
  ) async {
    final workoutsJson =
        (cycleJson['workouts'] as List<dynamic>).cast<Map<String, dynamic>>();

    final matches = <String, ExerciseMatchResult>{};
    final allUnmatched = <String>{};
    for (final workoutJson in workoutsJson) {
      final match = WorkoutImportService.matchWorkoutExercises(workoutJson, catalog);
      matches[workoutJson['name'] as String] = match;
      allUnmatched.addAll(match.unmatchedNames);
    }

    if (!mounted) return;
    final confirmed = await ImportConfirmationDialog.show(
      context,
      workoutNames: workoutsJson.map((w) => w['name'] as String).toList(),
      unmatchedExerciseNames: allUnmatched.toList(),
    );
    if (!confirmed) return;

    final nameToNewId = <String, int>{};
    for (final workoutJson in workoutsJson) {
      final name = workoutJson['name'] as String;
      final created = await _apiService.storeCustomWorkout(
        name,
        workoutJson['description'] as String? ?? '',
        matches[name]!.matchedGymExercises,
      );
      nameToNewId[name] = created['id'] as int;
    }

    if (!mounted) return;
    final startDate = await _pickCycleStartDate();
    if (startDate == null) return;

    final daysPatternByName = cycleJson['days_pattern'] as Map<String, dynamic>;
    final daysPatternByNewId =
        WorkoutImportService.remapDaysPatternToIds(daysPatternByName, nameToNewId);

    await _apiService.storeWeeklyWorkouts(
      DateFormat('yyyy-MM-dd').format(startDate),
      cycleJson['weeks'] as int,
      daysPatternByNewId,
    );

    if (!mounted) return;
    _showSnack('Workout cycle imported successfully');
    _fetchWorkouts();
  }

  Future<DateTime?> _pickCycleStartDate() {
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
  }

  void _showSnack(String message, {bool isError = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: isError ? colorScheme.onError : colorScheme.onPrimary),
        ),
        backgroundColor: isError ? colorScheme.error : colorScheme.primary,
      ),
    );
  }
```

- [ ] **Step 4: Verify the project analyzes cleanly**

Run: `flutter analyze`
Expected: no new errors.

- [ ] **Step 5: Manually verify the full round trip in the running app**

Run the app and:
1. Export a workout from `workout_detail_screen.dart` (Task 8), then go to the workout list and import that same file. Confirm the dialog shows the correct name, tap Import, and confirm a new (duplicate) workout appears in the list with the same exercises.
2. Edit the exported `.json` file to rename one exercise to something not in your catalog, re-import, and confirm the confirmation dialog lists it under the unmatched warning and the created workout omits it.
3. Export a workout cycle from `workout_calendar_screen.dart` (Task 9), then import that file. Confirm you're prompted for a start date, and afterward the calendar screen shows the recreated cycle.
4. Try importing a non-JSON file and a JSON file with `"type": "something_else"`; confirm both show the expected error snackbar and nothing is created.

- [ ] **Step 6: Run the full test suite one last time**

Run: `flutter test`
Expected: PASS (all tests, including the pre-existing ones — no regressions)

- [ ] **Step 7: Commit**

```bash
git add lib/screens/workout/workout_list_screen.dart
git commit -m "feat: wire workout program import into the workout list screen"
```
