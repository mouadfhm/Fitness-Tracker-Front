# 01 — Send & Open Logging

**Depends on:** nothing. **Size:** S. **Read `00-index.md` first.**

## Goal

Record every notification sent and whether it was opened. Today there is no way to answer "did
anyone open these?", which makes every other engagement change unmeasurable.

## Schema

New table `notification_logs`:

| Column | Type | Notes |
|---|---|---|
| `id` | bigint pk | |
| `user_id` | fk, indexed | |
| `type` | string | `meal_reminder`, `workout_reminder`, `achievement`, `winback` |
| `title` | string | as sent |
| `body` | text | as sent |
| `status` | string | `sent`, `failed`, `skipped` |
| `error` | string, nullable | failure reason when `failed` |
| `sent_at` | timestamp | |
| `opened_at` | timestamp, nullable | |

Composite index on `(user_id, type, sent_at)` — the lookup spec 02 performs. Purely additive, so
no risk to existing rows.

## Backend changes

`NotificationService::sendNotification()` gains a `$type` argument and writes one row per send,
including failures (`status = 'failed'`, with the exception message in `error`). Callers to
update: `AchievementService`, `SendDailyReminder`, `SendDailyMealReminder`.

New endpoint, `auth:sanctum`:

```
POST /api/notifications/{log}/opened   → 204
```

It **must** verify the log belongs to the authenticated user. Without that check it is an
enumeration oracle over other users' notification ids.

Include `log_id` in the FCM payload's `data` block so the app knows what to report.

## App changes

Minimal here: the app must call the endpoint when a notification is tapped. If spec 03 (deep
links) has already landed, add the call to its existing tap handler. If not, add a tap handler in
`firebase_service.dart` that only fires this call. Fire-and-forget — a failure must never block
the UI.

## Acceptance

- Sending any notification writes exactly one row with the correct `type`.
- A failed send writes `status = 'failed'` and does not throw.
- Tapping a notification sets `opened_at`.
- Requesting another user's log id returns 403/404, not 204.

## Out of scope

Dashboards or reporting UI. Query the table directly; build reporting once there is data worth
looking at.
