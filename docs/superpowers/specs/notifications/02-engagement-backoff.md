# 02 — Engagement Backoff

**Depends on:** 01 (needs `notification_logs` for last-sent). **Size:** M.
**Read `00-index.md` first.**

## Goal

Stop reminding users who have stopped engaging. Today both daily commands ping every user who
hasn't logged, every day, forever — the pattern that produces uninstalls and one-star reviews.

## Approach: stored column

Add `users.last_engaged_at` (timestamp, nullable, indexed).

This was chosen over deriving the value from `MAX()` across `meals`, `workout_logs`, `progress`,
and `notification_logs.opened_at`. The stored column reads faster, at the cost of needing an
update on every engagement path.

**The risk is real and must be mitigated:** if a future logging endpoint forgets to update the
column, those users silently look dormant and get nagged. Do **not** scatter
`$user->update(['last_engaged_at' => now()])` across controllers. Instead register Eloquent
**model observers** on `Meal`, `WorkoutLog`, and `Progress` (`created` event) that touch the
column. New code paths writing those models are then covered automatically. The open-tracking
endpoint from spec 01 touches it too.

Backfill in the migration:

```sql
UPDATE users SET last_engaged_at = (
  SELECT MAX(created_at) FROM meals WHERE meals.user_id = users.id
)
```

extended with the same for `workout_logs` and `progress`, taking the greatest of the three.
Without a backfill every existing user looks dormant on day one and reminders stop instantly.

## Backoff table

| Days since `last_engaged_at` | Minimum gap between reminders of a type |
|---|---|
| 0–7 | 1 day |
| 8–21 | 3 days |
| 22–60 | 7 days |
| over 60 | do not send |

A user with `last_engaged_at IS NULL` (new account, never logged) counts as day 0 and gets daily
reminders — that is onboarding, not dormancy. Re-engagement resets the cadence automatically.

## Implementation

`EngagementService::dueForReminder(int $userId, string $type): bool` compares days-inactive
against the last `notification_logs.sent_at` for that user and type. Both daily commands filter
their candidate list through it.

Skipped users get a `notification_logs` row with `status = 'skipped'`, so the decision is
auditable rather than invisible.

## Acceptance

- Unit tests covering boundary days 0, 7, 8, 21, 22, 60, 61 and the null case.
- A user inactive 30 days receives at most one reminder per type per week.
- A user inactive 90 days receives none.
- Logging a meal returns them to daily on the next run.

## Out of scope

Win-back campaigns with distinct copy for dormant users — that is content, and belongs with 06.
