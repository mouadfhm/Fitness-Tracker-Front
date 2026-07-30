# 03 — Deep Links

**Depends on:** 01 (for the `log_id` and open-tracking call). **Size:** M.
**Read `00-index.md` first.**

## Goal

A tapped notification should open the screen it is about. Today every tap lands on the home
screen, so a meal reminder still costs the user two more taps to act on — and each one loses a
meaningful share of them.

## Payload

Add a `data` block alongside the existing notification:

```json
{ "type": "meal_reminder", "log_id": "1234", "route": "foods" }
```

Routes map to screens that already exist. Do not create new screens for this:

| route | screen |
|---|---|
| `home` | `HomeScreen` (nutrition) |
| `workouts` | `WorkoutRootScreen` |
| `foods` | `FoodsScreen` |
| `profile` | `ProfileScreen` |

## App changes — three entry paths

All three are genuinely distinct and all are required. Handling only one is the usual bug here:

| Path | App state when tapped |
|---|---|
| `FirebaseMessaging.instance.getInitialMessage()` | terminated — cold start |
| `FirebaseMessaging.onMessageOpenedApp` | background to foreground |
| local notification `onDidReceiveNotificationResponse` | foreground (message was re-posted locally) |

For the foreground path, pass the route through the local notification's `payload` field —
the `RemoteMessage` is not available in that callback.

Navigate via the existing `NavigationService.navigatorKey`, which is already wired in
`main.dart`. Guard against a null navigator state on cold start: the message arrives before the
first frame, so defer with `WidgetsBinding.instance.addPostFrameCallback` or the navigation is
silently dropped.

An unknown or missing `route` must fall back to the home screen, never crash.

The tap also fires `POST /api/notifications/{log_id}/opened` (spec 01), fire-and-forget.

## Acceptance

- Tapping a meal reminder from each of the three app states lands on the foods screen.
- A payload with no `route` opens the app normally.
- Cold-start taps navigate reliably, not intermittently.

## Out of scope

`https://` app links or custom URL schemes. This is FCM payload routing only.
