# 09 — Per-User Timezone

**Depends on:** nothing. **Size:** S. **Read `00-index.md` first.**

## Goal

All reminders are hardcoded to `Africa/Casablanca` in `routes/console.php`. Any user outside
Morocco gets woken up or reminded at a useless hour. This is small, and specs 07 and 08 both
depend on it being right.

## Schema

Add `users.timezone` (string, nullable). Null means fall back to `Africa/Casablanca` — do not
backfill a guess.

## Collecting it

The app reports its IANA timezone on login and on token registration. Add it to the existing
`POST /api/save-device-token` body, which the app already calls at exactly the right moments, so
no new endpoint or call site is needed:

```json
{ "device_token": "...", "timezone": "Africa/Casablanca" }
```

Get the value in Flutter via the `flutter_timezone` package (`flutter_local_notifications` may
already pull in `timezone` as a transitive dependency — check before adding).

Validate server-side against `timezone_identifiers_list()` and ignore invalid values rather than
storing junk that will later throw inside Carbon.

## Using it

Reminder commands switch from a single `dailyAt(...)->timezone('Africa/Casablanca')` to running
**hourly** and selecting users whose local hour matches the target. This is the same structural
change spec 07 needs, so if you are doing both, do them together — the second one is then nearly
free.

## Acceptance

- A user reporting `Europe/Paris` gets the 10:00 reminder at 10:00 Paris time.
- A user with null timezone gets it at 10:00 Casablanca, exactly as today.
- An invalid timezone string is rejected and leaves the stored value unchanged.

## Out of scope

A manual timezone picker in settings. Device-reported only; revisit if users travel and complain.
