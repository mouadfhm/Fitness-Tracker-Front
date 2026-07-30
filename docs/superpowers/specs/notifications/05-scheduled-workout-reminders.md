# 05 — Scheduled-Workout Reminders

**Depends on:** nothing (09 improves it). **Size:** M. **Read `00-index.md` first.**

## Goal

Users already tell you when they intend to train — `scheduled_workouts` and `weekly_cycle_plans`
exist and are populated — and nothing notifies them. A reminder for a session the user themselves
scheduled converts far better than a generic 18:30 blast, because it references a commitment they
made rather than a nag from you.

This is the highest-value untapped signal in the schema.

## Behaviour

New command `send:workout-session-reminder`, scheduled **hourly** (not daily) in
`routes/console.php`.

Each run finds scheduled workouts starting within the next 30–90 minutes that have no
corresponding `workout_logs` entry yet, and notifies the owner:

> 🏋️ Leg Day in an hour — your plan says squats, leg press, calf raises.

Include the workout name. Include the first few exercises if cheaply available; if that requires
extra joins, ship without them — the name alone carries most of the value.

Weekly cycle plans need expanding into concrete dates for the current week before the same
window check applies.

## Correctness notes

- **Do not double-send.** Record a send in `notification_logs` (spec 01) keyed by type plus the
  scheduled workout id, or add a `reminded_at` column on `scheduled_workouts`. Running hourly
  means an unguarded implementation fires up to three times per session.
- Skip sessions already logged as complete.
- Times are currently `Africa/Casablanca` for everyone; spec 09 fixes that. Until then a user
  abroad gets this at the wrong hour — acceptable short-term, since the daily reminders already
  share the flaw.

## Acceptance

- A workout scheduled for 18:00 produces exactly one reminder around 17:00.
- Logging the workout beforehand suppresses it.
- Users with no scheduled workouts receive nothing.

## Out of scope

Rescheduling or snoozing from the notification. Read-only reminder.
