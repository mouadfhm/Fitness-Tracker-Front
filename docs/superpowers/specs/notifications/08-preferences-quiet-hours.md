# 08 — Preferences & Quiet Hours

**Depends on:** nothing. **Size:** L (backend + API + Flutter UI).
**Read `00-index.md` first.**

## Goal

Users have no in-app way to control notifications. The only off switch is the OS one — and that
one is permanent, all-or-nothing, and invisible to you. Ship this before increasing notification
volume, not after.

## Schema

New table `notification_preferences`, one row per user, created lazily with defaults on:

| Column | Type | Default |
|---|---|---|
| `user_id` | fk, unique | |
| `meal_reminders` | boolean | true |
| `workout_reminders` | boolean | true |
| `achievements` | boolean | true |
| `winback` | boolean | true |
| `quiet_from` | time, nullable | `22:00` |
| `quiet_to` | time, nullable | `08:00` |

A missing row must mean "all enabled", so existing users keep working without a backfill.

## Enforcement

Enforce centrally in `NotificationService`, not in each command. Every send checks the user's
preference for that `type` and the quiet window before dispatching. One choke point means a new
notification type cannot accidentally bypass preferences.

Quiet hours wrap midnight (`22:00`–`08:00`), so the comparison is not a simple `between` — handle
the wrapping case explicitly, it is the classic bug here.

Suppressed sends get a `notification_logs` row with `status = 'skipped'` (spec 01) so suppression
is visible rather than mysterious.

Quiet hours are evaluated in the user's timezone (spec 09) when available, otherwise
`Africa/Casablanca`.

## API

```
GET  /api/notification-preferences   → current values (defaults if no row)
PUT  /api/notification-preferences   → update
```

Both `auth:sanctum`.

## App

Add a Notifications section to the existing `lib/screens/settings_screen.dart` — four toggles and
a quiet-hours time range. Follow the screen's existing widget and theming patterns rather than
introducing new ones.

## Acceptance

- Disabling meal reminders stops them and leaves the others working.
- A send inside quiet hours is skipped and logged as `skipped`.
- A user with no preferences row receives everything.
- Preferences survive logout and reinstall (server-side, not local).

## Out of scope

Per-type custom send times, and a global "pause for a week" control. Add later if asked for.
