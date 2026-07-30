# Notification Improvements — Index

**Date:** 2026-07-30
**Purpose:** Each numbered spec in this folder is independently runnable in its own session.
Read **this file plus the one spec you are executing**. Do not read the others — that is the
whole point of the split.

Supersedes `../2026-07-30-notification-delivery-foundation-design.md`.

## Shared context (read once per session)

**Backend:** Laravel 12, at `~/apps/fitness-backend` on `ubuntu@84.8.223.140`. Runs as the
`fitness_app` Docker container, built from `~/apps/docker-compose.yml` (that compose file is not
in any repo). Code changes require a rebuild:

```bash
cd ~/apps && docker compose build fitness-backend && docker compose up -d fitness-backend
```

**Frontend:** Flutter, this repo, branch `dev`. API base URL comes from `.env.production`
(`https://mouadcloud.duckdns.org/api`).

**Firebase:** project `fitness-tracker-f1352`. Service account mounted read-only from
`~/apps/secrets/fitness-firebase/` to `/var/www/storage/app/firebase`; path set by
`FIREBASE_CREDENTIALS`. kreait/firebase-php **5.26.5** — note `CloudMessage::withTarget()` and
array-form `withAndroidConfig()`, not the v7 API.

**Scheduler:** ubuntu's crontab runs `docker exec fitness_app php artisan schedule:run` every
minute. Laravel 12 **ignores** `app/Console/Kernel.php` — schedules live in `routes/console.php`.

**Current state after the 2026-07-30 repair:** notifications deliver end to end. Existing
notifications are a daily meal reminder (10:00), a daily workout reminder (18:30, weekdays), and
achievement unlocks. All are unconditional apart from "did they already log today", identical for
every user, and untracked.

**Key files:** `app/Services/NotificationService.php`, `app/Console/Commands/SendDaily*.php`,
`app/Http/Controllers/NotificationController.php`, `app/Models/UserDevice.php`,
`routes/console.php`, and `lib/services/firebase_service.dart`.

The Android channel id `fitness_reminders` is hardcoded in three places that must stay in sync:
the backend payload, `firebase_service.dart`, and `default_notification_channel_id` in
`AndroidManifest.xml`.

## The specs

| # | Spec | Depends on | Size |
|---|---|---|---|
| 01 | Send & open logging | — | S |
| 02 | Engagement backoff | 01 | M |
| 03 | Deep links | 01 | M |
| 04 | Multicast batching | — | S |
| 05 | Scheduled-workout reminders | — | M |
| 06 | Personalized content | 03 | M |
| 07 | Habitual send time | 09 | M |
| 08 | Preferences & quiet hours | — | L |
| 09 | Per-user timezone | — | S |
| 10 | Streaks | 01 | L |

## Recommended order

**01 first.** It is small, has no dependencies, and both 02 and 03 need it. It also gives you
open-rate data, without which every later decision here is guesswork.

Then **09 → 08** (correctness and user control) before **05 → 06 → 07** (more and louder
notifications). Shipping content features before users can turn them off is how apps earn
permanent OS-level notification bans.

**10 (streaks)** is the strongest retention lever but the largest build; do it once the
foundation is in place.

**04** is independent and can slot in anywhere volume becomes a problem.

## Deliberately dropped

Multi-device delivery (one row per device instead of per user) was scoped and then dropped at the
user's request on 2026-07-30. `user_devices` remains keyed on `user_id` via
`updateOrCreate(['user_id' => ...])`, so **a user with two devices receives notifications only on
the most recently registered one**, and reinstalling orphans the old row. Revisit if multi-device
complaints appear.

## Conventions for every spec here

- Migrations must have working `down()` methods; production has real users.
- A failed push must never break the request that triggered it.
- Verify against production by sending a real notification, not by reading code.
- Backend changes must be committed to the Fitness-Tracker-backend repo, or the next rebuild from
  a clean clone loses them.
