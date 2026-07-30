# Notification Delivery Foundation (Subsystem A)

**Date:** 2026-07-30
**Status:** Approved, ready for implementation plan
**Scope:** Laravel backend (`~/apps/fitness-backend` on 84.8.223.140) + Flutter app (`fitness_tracker_front`)

## Context

The FCM pipeline was repaired on 2026-07-30 (four root causes: a `UserDevice`/`UserDevices`
class mismatch that made every token registration return 500, missing Firebase credentials, a
schedule defined in Laravel 12's ignored `app/Console/Kernel.php`, and no foreground handler in
the app). Notifications now deliver end to end.

This subsystem is the plumbing that engagement features are built on. It is deliberately
separated from three later subsystems: **B** (preferences, quiet hours, per-user timezone),
**C** (scheduled-workout reminders, personalization, habitual send times), and **D** (streaks).
Those depend on A and should not begin before it lands.

## Goals

1. Deliver to every device a user owns, not just the most recent one.
2. Stop reminding users who have stopped engaging, on a decaying schedule.
3. Record what was sent and what was opened, so engagement work can be measured.
4. Take a notification tap to the relevant screen rather than the home screen.
5. Send in batches rather than one HTTP call per user.

## Non-goals

Explicitly deferred, to keep this shippable:

- Per-user notification preferences and quiet hours (subsystem B).
- Per-user timezone; all scheduling stays `Africa/Casablanca` (subsystem B).
- Personalized message content and habitual send times (subsystem C).
- Streaks (subsystem D).
- A queue worker. Multicast batching is sufficient at current volume; add a queue when
  measurements show it is needed.

## Data model

### `user_devices` — one row per device

Current schema is `id, user_id, device_token, created_at, updated_at`, written with
`updateOrCreate(['user_id' => Auth::id()], ...)`, which permits exactly one device per user.

Migration:

- Add unique index on `device_token`.
- Add `platform` (string, nullable) — `android` / `ios`.
- Add `last_seen_at` (timestamp, nullable).

Registration becomes keyed on the token:

```php
UserDevice::updateOrCreate(
    ['device_token' => $request->device_token],
    ['user_id' => Auth::id(), 'platform' => $request->platform, 'last_seen_at' => now()]
);
```

Keying on `device_token` also fixes account switching: when a second user logs in on the same
physical device, the row is reassigned rather than leaving a stale row that would push the first
user's notifications to someone else's phone.

**Migration risk:** the unique index fails if duplicate tokens already exist. The migration must
delete older duplicates (keeping the most recent row per token) before adding the index. The
`down()` drops the index and the two columns.

### `notification_logs` — new table

| Column | Type | Notes |
|---|---|---|
| `id` | bigint pk | |
| `user_id` | foreign key, indexed | |
| `type` | string | `meal_reminder`, `workout_reminder`, `achievement`, `winback` |
| `title` | string | as sent |
| `body` | text | as sent |
| `status` | string | `sent`, `failed`, `skipped` |
| `error` | string, nullable | failure reason |
| `sent_at` | timestamp | |
| `opened_at` | timestamp, nullable | set by the open-tracking endpoint |

Composite index on `(user_id, type, sent_at)` — the exact lookup the backoff check performs.

Purely additive, so it carries no risk to existing data.

## Backoff

State is **derived, not stored**. A denormalized `last_engaged_at` column on `users` would be
cheaper to read but must be updated from every write path; the first time a new logging endpoint
forgets to touch it, users silently go dormant and get nagged. Deriving from source tables is
always correct.

```
lastEngagedAt(user) = MAX(
    meals.created_at,
    workout_logs.created_at,
    progress.created_at,
    notification_logs.opened_at
)
```

Computed for the entire user base in four `GROUP BY user_id` aggregate queries, not per user, so
query count is constant regardless of user count.

| Days since last engagement | Minimum gap between reminders of a type |
|---|---|
| 0–7 | 1 day |
| 8–21 | 3 days |
| 22–60 | 7 days |
| over 60 | do not send |

A user with no engagement records at all (new account, never logged anything) is treated as day 0
and receives daily reminders — this is onboarding, not dormancy.

Re-engagement resets the cadence automatically because the input is a `MAX()`; no separate reset
logic exists or is needed.

`EngagementService` exposes:

- `lastEngagedAtForAll(): array` — `[user_id => Carbon|null]`
- `dueForReminder(int $userId, string $type, ?Carbon $lastEngaged, ?Carbon $lastSent): bool`

Skipped users are recorded in `notification_logs` with `status = 'skipped'`, so the decision is
auditable rather than invisible.

## Dispatch

`NotificationService` gains two paths:

- `sendToUser($userId, $title, $body, $type, $route = null)` — every device belonging to the
  user; used for achievement unlocks.
- `sendBulk($userIds, $title, $body, $type, $route = null)` — kreait `sendMulticast()` in batches
  of 500 tokens. Valid only because daily reminder copy is identical for all recipients.

`MulticastSendReport` returns `invalidTokens()` and `unknownTokens()`; those rows are deleted in a
single query per batch. This replaces the per-send `NotFound`/`InvalidArgument` pruning added
during the repair.

**Known boundary:** multicast requires an identical message. Subsystem C's personalized copy is
per-user by definition and must use `sendToUser()`. This is expected, and is why C is scoped
separately.

## Deep links

The Android config already sets `channel_id: fitness_reminders`. Payloads gain a data block:

```json
{ "type": "meal_reminder", "log_id": "1234", "route": "foods" }
```

Routes map to existing screens only — `home`, `workouts`, `foods`, `profile`. No new screens.

Flutter handles all three entry paths, which are genuinely distinct and all required:

| Path | App state |
|---|---|
| `FirebaseMessaging.instance.getInitialMessage()` | terminated (cold start from tap) |
| `FirebaseMessaging.onMessageOpenedApp` | background to foreground |
| local-notification `onDidReceiveNotificationResponse` | foreground (re-posted locally) |

Navigation goes through the existing `NavigationService.navigatorKey`. On tap the app calls
`POST /api/notifications/{log}/opened`, which sets `opened_at` and thereby resets the engagement
clock. The call is fire-and-forget: a failure must never block navigation.

## API changes

| Endpoint | Change |
|---|---|
| `POST /api/save-device-token` | accepts optional `platform`; keyed on token |
| `POST /api/notifications/{log}/opened` | new; `auth:sanctum`; 204 on success |

The open endpoint must verify the log belongs to the authenticated user, otherwise it is an
enumeration oracle over other users' notification IDs.

## Testing

- Unit tests for the backoff table across boundary days (0, 7, 8, 21, 22, 60, 61) and the
  never-engaged case. This is pure logic, most likely to be wrong, and least visible when it is.
- Feature test: registering the same token twice yields one row; two tokens for one user yield
  two; re-registering another user's token reassigns it.
- Feature test: the open endpoint rejects a log belonging to a different user.

## Rollout

1. Apply migrations to production deliberately, after checking `user_devices` for duplicate
   tokens (currently 1 row, so the dedupe is expected to be a no-op).
2. Rebuild and restart only `fitness-backend`, as during the repair.
3. Verify: token count unchanged, `schedule:list` still correct, a manual `sendToUser` still
   arrives on a real device.
4. Ship the Flutter build. Deep links require the new app; everything else works on the installed
   version.

Backend source changes are uncommitted on the server and must be committed to the
Fitness-Tracker-backend repository, or the next rebuild from a clean clone loses them.
