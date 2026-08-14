# Workout Program Export/Import — Design

## Goal

Let a user save a custom workout or a full workout cycle (weekly plan) to a
JSON file on their device, and load one back in — for backup, or to move a
program between accounts/devices. File-based only; no backend/API changes.

## File format

A single versioned JSON schema covers both cases, distinguished by `type`.

### Single workout (`type: "workout"`)

```json
{
  "type": "workout",
  "version": 1,
  "name": "Push Day",
  "description": "Chest, shoulders, triceps",
  "exercises": [
    { "name": "Bench Press", "sets": 3, "reps": 10, "duration": null, "rest": 60 }
  ]
}
```

Exercises are keyed by **name**, not by the backend's numeric
`gym_exercise_id` — IDs aren't portable across accounts/environments, names
are matched against the importing user's exercise catalog at import time.

### Workout cycle (`type: "workout_cycle"`)

```json
{
  "type": "workout_cycle",
  "version": 1,
  "weeks": 4,
  "days_pattern": { "mon": "Push Day", "tue": null, "wed": "Pull Day", "thu": null, "fri": null, "sat": null, "sun": null },
  "workouts": [
    { "name": "Push Day", "description": "...", "exercises": [ /* same shape as above */ ] },
    { "name": "Pull Day", "description": "...", "exercises": [ /* ... */ ] }
  ]
}
```

`days_pattern` maps day key → workout name (or `null` for a rest day).
`workouts` is the deduplicated set of full workout definitions referenced by
the pattern, so the file is self-contained — importing doesn't require the
referenced workouts to already exist.

`start_date` is deliberately **not** stored. A saved start date would almost
always be stale by re-import time, so import always prompts for a fresh one
(reusing the date picker already in `new_workout_cycle_screen.dart`).

## New dependency

Add `file_picker` (^8.x) — cross-platform save/open file dialogs (Android,
iOS, Windows, macOS, Linux, web), replacing the need for separate
mobile/desktop/web file-handling code.

## Export flow

- **Single workout**: new export icon in `workout_detail_screen.dart`'s app
  bar (next to Edit). Builds the JSON from the already-fetched workout
  detail and calls `FilePicker.platform.saveFile(...)` with a suggested
  filename derived from the workout name (e.g. `push_day.json`).
- **Workout cycle**: new export icon in `workout_calendar_screen.dart`'s app
  bar, enabled only when a plan exists. Uses the fetched weekly plan's
  `days_pattern` plus one `fetchCustomWorkout` call per unique workout it
  references, to build the bundled JSON.
- Both are implemented in a new `lib/services/workout_export_service.dart`,
  which owns JSON construction and the `file_picker` calls. Screens stay
  thin and call into this service, matching the existing screen → service
  pattern used elsewhere (`ApiService`).

## Import flow

- **Entry point**: a single "Import" icon in `workout_list_screen.dart`
  (`WorkoutManagementScreen`)'s app bar, next to Refresh. One entry point
  handles both file types — the imported file's `type` field decides what
  happens next.
- Reads the file via `FilePicker.platform.pickFiles(...)`, parses JSON,
  validates `type` and `version`. Invalid/unsupported files show an error
  snackbar and abort.
- **Exercise matching**: for each exercise in the file, look up an
  exact-name-match (case-insensitive) against the user's exercise catalog
  (`ApiService`'s v2 exercises-search). Matched exercises resolve to their
  `gym_exercise_id`; unmatched ones are collected but do not block the
  import — they're dropped from the recreated workout.
- Before writing anything, a confirmation dialog shows: the workout name(s)
  about to be created, and a warning list of any exercise names that
  couldn't be matched.
- On confirm:
  - **Single workout** → one `storeCustomWorkout` call.
  - **Cycle** → `storeCustomWorkout` for each bundled workout (if a workout
    with the exact same name already exists for the user, ask whether to
    reuse the existing one or create a duplicate), then prompt for a start
    date and call `storeWeeklyWorkouts` with `days_pattern` remapped from
    workout names to the newly-resolved IDs.
- On a failure partway through a cycle import (e.g. network drop), workouts
  already created remain — they're valid on their own — but the flow stops
  rather than silently retrying or rolling back.

## Out of scope

- Sharing via a backend-generated code/link (file-based only, per user
  decision).
- Editing an imported file's contents before creating it (import is
  create-only; the user can edit via the normal edit-workout screen
  afterward).
