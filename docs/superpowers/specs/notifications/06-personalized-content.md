# 06 — Personalized Content

**Depends on:** 03 (a personalized nudge the user cannot act on in one tap is wasted).
**Size:** M. **Read `00-index.md` first.**

## Goal

Every reminder currently sends identical copy, which trains users to ignore it. The app already
stores enough to say something specific.

## Message sources

Draw from data that already exists — `meals`, `workout_logs`, `progress`, and the user's
`fitness_goal`, `weight`, `height`, `age`, `activity_level` on `users`:

| Situation | Copy |
|---|---|
| Under calorie goal, evening | "You're 480 kcal under your goal — still time to log dinner" |
| Workout streak within reach of a record | "You logged 4 workouts last week. One more today matches your record." |
| Recent weight progress | "Down 1.2 kg this month — log today's weigh-in" |
| Nothing notable | fall back to the current generic copy |

The fallback is not optional. Personalization that cannot find a fact must still send something
sensible rather than an empty or awkward message.

## Implementation

`NotificationContentService::forUser(int $userId, string $type): array` returning
`['title' => ..., 'body' => ...]`. Keep the copy decisions in this one class rather than inside
the commands, so the rules are testable in isolation and readable in one place.

Compute inputs in **bulk** before the loop — one grouped query per source table for all
candidate users — rather than per user inside it. Per-user queries here turn a fast command into
a slow one as the user base grows.

## Interaction with 04

Personalized copy differs per user, so it **cannot** use `sendMulticast`. This path must use the
per-user send. That is expected, not a conflict; see 04 for the boundary.

## Acceptance

- Two users in different states receive different copy.
- A user with no notable facts still receives the generic reminder.
- Copy generation issues a constant number of queries regardless of user count.

## Out of scope

LLM-generated copy. Rules-based only — predictable, free, and testable.
