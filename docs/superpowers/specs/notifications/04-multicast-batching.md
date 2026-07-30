# 04 — Multicast Batching

**Depends on:** nothing. **Size:** S. **Read `00-index.md` first.**

## Goal

The daily commands loop over every user and make one FCM HTTP call each, synchronously, inside a
cron-triggered process. Fine now; it becomes a timeout as the user base grows.

## Change

Add `NotificationService::sendBulk(array $userIds, string $title, string $body, string $type)`
using kreait's `sendMulticast()` in batches of **500 tokens** (the FCM limit).

`MulticastSendReport` returns `invalidTokens()` and `unknownTokens()`. Delete those rows in one
query per batch — this replaces the per-send `NotFound`/`InvalidArgument` pruning currently in
`sendNotification()`.

Both daily reminder commands switch to `sendBulk`.

## The constraint that matters

**Multicast requires an identical message for every recipient.** It is valid for the current
daily reminders because their copy is the same for everyone. It is *not* compatible with spec 06
(personalized content), which is per-user by definition.

So the two paths coexist permanently: `sendBulk` for identical broadcast copy, `sendNotification`
for per-user copy. If 06 lands first, this spec applies only to whatever notifications remain
identical — possibly none, in which case skip it.

If spec 01 has landed, `sendBulk` must still write one `notification_logs` row per recipient.

## Acceptance

- A send to 600 users issues 2 FCM calls, not 600.
- Invalid tokens returned in the report are deleted.
- Per-user log rows are still written when 01 is present.

## Out of scope

A queue worker. Deferred deliberately — add one when measurements show batching is not enough,
not before. The lm3allem stack on the same box already has the pattern to copy if needed.
