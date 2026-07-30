# 07 — Habitual Send Time

**Depends on:** 09 (sending at "their" hour is meaningless without their timezone).
**Size:** M. **Read `00-index.md` first.**

## Goal

Reminders fire at a fixed 10:00 and 18:30 for everyone. Someone who always logs breakfast at
07:30 either already logged by 10:00 or has long since forgotten. Send at the hour each user
actually uses the app.

## Approach

Add `users.preferred_meal_hour` and `users.preferred_workout_hour` (tinyint, nullable).

Recompute weekly via a scheduled command: take the **median** hour of that user's `meals`
(and `workout_logs`) `created_at` over the last 30 days, in the user's timezone. Median, not
mean — one 3am snack should not drag the whole estimate.

Require a minimum sample (say 5 entries) before overriding the default; below that leave the
column null and use 10:00 / 18:30.

Then convert the daily reminder commands from `dailyAt()` to **hourly** runs that select users
whose preferred hour matches the current hour in their timezone. The cron already runs every
minute, so no infrastructure change is needed.

## Correctness notes

- Guard against double-sends when a user's preferred hour changes mid-day — the
  once-per-day-per-type check from spec 02 covers this if present; otherwise add an explicit
  "already sent today" check.
- A user whose habitual hour is 03:00 should still be clamped to a sane window (say 07:00–22:00),
  or you will wake people up because they once logged a midnight snack.

## Acceptance

- A user who consistently logs at 07:30 receives the meal reminder at 07:00, not 10:00.
- A user with fewer than 5 entries receives it at the 10:00 default.
- Nobody receives a reminder outside the clamp window.
- Exactly one reminder per type per day.

## Out of scope

Per-notification-type custom times chosen by the user in the UI — that is preferences (08).
