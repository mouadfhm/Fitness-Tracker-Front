# Ads Integration Design

**Date:** 2026-04-19  
**Status:** Approved

## Goal

Add clean, non-intrusive advertisements to the fitness tracker app using Google Mobile Ads (AdMob). Ads must degrade gracefully on non-mobile platforms (Windows/desktop) and never show empty whitespace on load failure.

## Format

Two ad types:

1. **Bottom Banner (`AdBannerWidget`)** — `AdSize.banner` (320×50px), anchored at the bottom of the screen inside a `SafeArea`. Renders as `SizedBox.shrink()` on failure or non-mobile platforms.

2. **Native Ad Card (`NativeAdCard`)** — a list item widget that matches the app's existing card style. Has a small muted `Sponsored` label. Renders as `SizedBox.shrink()` on failure or non-mobile platforms.

## Placement

All 4 main content screens get a bottom banner. Foods and Workout List also get native ad cards injected into their lists.

| Screen | Banner | Native Card |
|--------|--------|-------------|
| Home (Nutrition) | ✅ | — |
| Workout Calendar | ✅ | — |
| Foods | ✅ | ✅ |
| Workout List | ✅ | ✅ |

**Native card frequency:** One card every 8 real list items, starting after the 5th item. Examples:
- 4 items → 0 ads
- 6 items → 1 ad (after item 5)
- 14 items → 2 ads (after items 5 and 13)
- 22 items → 3 ads (after items 5, 13, and 21)

## Platforms

Android and iOS only. On Windows/desktop, both widgets return `SizedBox.shrink()` — no crashes, no layout gaps.

## Architecture

Approach: two focused widgets + a constants file. No service layer or provider needed.

### Files

| File | Action |
|------|--------|
| `pubspec.yaml` | Uncomment `google_mobile_ads: ^5.0.0` |
| `lib/main.dart` | Add `MobileAds.instance.initialize()` before `runApp` |
| `lib/utils/ad_config.dart` | New — ad unit ID constants (test IDs default) |
| `lib/utils/add_banner.dart` | Uncomment + rewrite → `AdBannerWidget` |
| `lib/utils/native_ad_card.dart` | New — `NativeAdCard` widget |
| `lib/screens/home_screen.dart` | Add `AdBannerWidget` at bottom |
| `lib/screens/workout/workout_calendar_screen.dart` | Add `AdBannerWidget` at bottom |
| `lib/screens/foods_screen.dart` | Add `AdBannerWidget` + inject `NativeAdCard` in list |
| `lib/screens/workout/workout_list_screen.dart` | Add `AdBannerWidget` + inject `NativeAdCard` in list |

### `ad_config.dart`

Holds all ad unit ID constants with a `// TODO: replace with real IDs` comment on each. Uses Google's official test IDs by default:

```dart
// Banner
static const String bannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
static const String bannerIos     = 'ca-app-pub-3940256099942544/2934735716';

// Native
static const String nativeAndroid = 'ca-app-pub-3940256099942544/2247696110';
static const String nativeIos     = 'ca-app-pub-3940256099942544/3986624511';
```

Returns the correct ID based on `Platform.isAndroid`.

### `AdBannerWidget`

- Stateful widget
- Loads `BannerAd` in `initState`, disposes in `dispose`
- On load failure: sets `_bannerAd = null`, renders `SizedBox.shrink()`
- On non-mobile (`!Platform.isAndroid && !Platform.isIOS`): returns `SizedBox.shrink()` immediately

### `NativeAdCard`

- Stateful widget
- Loads `NativeAd` in `initState`, disposes in `dispose`
- Styled to match app card appearance with muted `Sponsored` label
- On load failure or non-mobile: returns `SizedBox.shrink()`

### List injection helper

A top-level function `injectNativeAds(List<Widget> items)` returns a new list with `NativeAdCard` widgets inserted. Insertion rule: add one after every 8th item, starting at index 5 (i.e., at positions 5, 13, 21, ...). No ad added if list has fewer than 5 items.

## Ad Unit IDs

Real AdMob IDs to replace after testing (existing app ID in code: `ca-app-pub-4974791906266394`):
- Banner Android: replace `ad_config.dart` constant
- Banner iOS: replace `ad_config.dart` constant  
- Native Android: replace `ad_config.dart` constant
- Native iOS: replace `ad_config.dart` constant
