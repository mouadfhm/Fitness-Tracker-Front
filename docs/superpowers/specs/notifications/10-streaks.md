# 10 — Streaks

**Depends on:** 01 (to avoid double-sending the at-risk nudge). **Size:** L.
**Read `00-index.md` first.**

## Goal

Streaks are the most reliable habit mechanic in fitness apps, because they create loss aversion
rather than requiring motivation. The app already has `achievements` and `user_achievements` to
build on.

## Definition — decide before coding

A **streak day** is any day the user logs at least one meal **or** one workout. Meal-only and
workout-only streaks are more precise but multiply the copy and the edge cases; one combined
streak is easier to explain to a user, and a streak nobody understands does not motivate anyone.

Days are evaluated in the user's timezone (spec 09) when available, otherwise
`Africa/Casablanca`. Getting this wrong breaks streaks at midnight for real users, so it is worth
being careful.

## Schema

New table `user_streaks`:

| Column | Type | Notes |
|---|---|---|
| `user_id` | fk, unique | |
| `current_days` | int | 0 when broken |
| `longest_days` | int | personal best, never decreases |
| `last_day` | date | last qualifying day, e.g. `2026-07-30` |

Backfill from existing `meals` and `workout_logs` history at migration time, otherwise every
existing user starts at zero and the feature launches feeling like a punishment.

## Maintenance

Update on write via the same model observers spec 02 uses (`Meal`, `WorkoutLog` `created`):
if `last_day` is yesterday, increment; if today, no-op; if older, reset to 1.

## The notification

One nightly command, at a fixed evening hour, notifying users whose streak is **at risk** —
`current_days >= 3` and nothing logged today:

> 🔥 6-day streak — don't break it. Log anything today.

Send **before** the streak breaks, not after. A notification telling someone they already failed
demotivates; one offering a save converts.

Threshold of 3 avoids nagging users who logged once yesterday.

## Acceptance

- Logging on consecutive days increments; skipping a day resets to 1 on the next log.
- `longest_days` never decreases.
- The at-risk notification fires only for streaks of 3+ with nothing logged today, at most once
  per day.
- Backfill produces plausible streaks for existing users.

## Out of scope

Streak freezes, repair tokens, or paid restores. Ship the basic mechanic first and see whether
it moves retention before building an economy on top of it.
