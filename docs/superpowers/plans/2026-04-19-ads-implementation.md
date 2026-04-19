# Ads Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add clean, non-intrusive AdMob ads to the fitness tracker — a bottom banner on all 4 main screens and an inline medium-rectangle ad card injected every 8 items in the Foods and Workout List screens.

**Architecture:** Two focused widgets (`AdBannerWidget`, `InlineAdCard`) + a constants file (`AdConfig`) + a list-injection helper (`ad_list_helper.dart`). No service class or provider. Both widgets return `SizedBox.shrink()` on non-mobile platforms and on load failure, so layout is never disrupted. Inline cards use `AdSize.mediumRectangle` (300×250) — same banner ad unit ID as the bottom banner, just a larger size.

**Tech Stack:** Flutter, `google_mobile_ads: ^5.0.0`, AdMob (Android + iOS)

---

## File Map

| File | Action |
|------|--------|
| `pubspec.yaml` | Uncomment `google_mobile_ads: ^5.0.0` |
| `android/app/src/main/AndroidManifest.xml` | Add AdMob app ID `<meta-data>` inside `<application>` |
| `ios/Runner/Info.plist` | Add `GADApplicationIdentifier` key |
| `lib/main.dart` | Call `MobileAds.instance.initialize()` before `runApp` |
| `lib/utils/ad_config.dart` | **New** — ad unit ID constants |
| `lib/utils/add_banner.dart` | **Rewrite** — `AdBannerWidget` (was fully commented out) |
| `lib/utils/inline_ad_card.dart` | **New** — `InlineAdCard` (medium rectangle banner in lists) |
| `lib/utils/ad_list_helper.dart` | **New** — `effectiveItemCount`, `isAdIndex`, `realIndexFor`, `adAwareItemBuilder` |
| `test/ad_list_helper_test.dart` | **New** — unit tests for injection math |
| `lib/screens/home_screen.dart` | Stack `AdBannerWidget` above `CustomBottomNavBar` |
| `lib/screens/workout/workout_calendar_screen.dart` | Stack `AdBannerWidget` above `CustomBottomNavBar` |
| `lib/screens/foods_screen.dart` | Stack `AdBannerWidget` above `CustomBottomNavBar` + inject `InlineAdCard` in food list |
| `lib/screens/workout/workout_list_screen.dart` | Add `AdBannerWidget` as `bottomNavigationBar` + inject `InlineAdCard` in workout list |

---

## Task 1: Enable the dependency and configure platform IDs

**Files:**
- Modify: `pubspec.yaml`
- Modify: `android/app/src/main/AndroidManifest.xml`
- Modify: `ios/Runner/Info.plist`

- [ ] **Step 1: Uncomment `google_mobile_ads` in pubspec.yaml**

  In `pubspec.yaml`, change:
  ```yaml
  # google_mobile_ads: ^5.0.0
  ```
  to:
  ```yaml
  google_mobile_ads: ^5.0.0
  ```

- [ ] **Step 2: Add AdMob app ID to AndroidManifest.xml**

  Inside the `<application>` tag in `android/app/src/main/AndroidManifest.xml`, add this `<meta-data>` entry just before the closing `</application>` tag:
  ```xml
  <meta-data
      android:name="com.google.android.gms.ads.APPLICATION_ID"
      android:value="ca-app-pub-4974791906266394~1619455967"/>
  ```

  The file should look like:
  ```xml
  <manifest xmlns:android="http://schemas.android.com/apk/res/android">
  <uses-permission android:name="android.permission.INTERNET"/>
  <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
      <application
          android:label="Fitness Tracker"
          android:name="${applicationName}"
          android:icon="@mipmap/ic_launcher">
          <activity ... >
              ...
          </activity>
          <meta-data
              android:name="flutterEmbedding"
              android:value="2" />
          <meta-data
              android:name="com.google.android.gms.ads.APPLICATION_ID"
              android:value="ca-app-pub-4974791906266394~1619455967"/>
      </application>
      ...
  </manifest>
  ```

- [ ] **Step 3: Add AdMob app ID to Info.plist**

  In `ios/Runner/Info.plist`, add these two lines just before `</dict>` at the end:
  ```xml
  	<key>GADApplicationIdentifier</key>
  	<string>ca-app-pub-4974791906266394~1619455967</string>
  ```

- [ ] **Step 4: Run flutter pub get**

  ```bash
  flutter pub get
  ```

  Expected: resolves `google_mobile_ads` and updates `pubspec.lock` with no errors.

- [ ] **Step 5: Verify analyzer is happy**

  ```bash
  flutter analyze
  ```

  Expected: no new errors (existing warnings from pre-existing code are fine).

- [ ] **Step 6: Commit**

  ```bash
  git add pubspec.yaml pubspec.lock android/app/src/main/AndroidManifest.xml ios/Runner/Info.plist
  git commit -m "feat: enable google_mobile_ads and configure AdMob app ID"
  ```

---

## Task 2: Create AdConfig constants

**Files:**
- Create: `lib/utils/ad_config.dart`

- [ ] **Step 1: Create the file**

  Create `lib/utils/ad_config.dart`:
  ```dart
  class AdConfig {
    AdConfig._();

    // AdMob App ID: ca-app-pub-4974791906266394~1619455967
    // Registered in AndroidManifest.xml and ios/Runner/Info.plist

    // Production ad unit ID — used for both bottom banners and inline (medium rectangle) cards.
    // A single banner ad unit supports multiple AdSize values.
    static const String adUnitId = 'ca-app-pub-4974791906266394/1779797786';
  }
  ```

- [ ] **Step 2: Commit**

  ```bash
  git add lib/utils/ad_config.dart
  git commit -m "feat: add AdConfig constants"
  ```

---

## Task 3: Write AdBannerWidget unit test, then implement

**Files:**
- Modify: `lib/utils/add_banner.dart`
- Test: `test/widget_test.dart` (add to existing file)

- [ ] **Step 1: Write the widget test**

  Open `test/widget_test.dart`. Add at the top of the file (after existing imports):
  ```dart
  import 'package:fitness_tracker_app/utils/add_banner.dart';
  ```

  Add this test group at the bottom of the file (inside `void main()`):
  ```dart
  group('AdBannerWidget', () {
    testWidgets('renders SizedBox.shrink when no ad loaded', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AdBannerWidget())),
      );
      // Before ad loads, widget should occupy zero space
      final sizedBox = tester.widgetList<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.any((b) => b.width == 0 && b.height == 0), isTrue);
    });
  });
  ```

- [ ] **Step 2: Run the test — expect it to fail with "not found"**

  ```bash
  flutter test test/widget_test.dart
  ```

  Expected: FAIL — `add_banner.dart` imports don't export `AdBannerWidget` yet.

- [ ] **Step 3: Rewrite add_banner.dart**

  Replace the entire contents of `lib/utils/add_banner.dart` with:
  ```dart
  import 'dart:io';
  import 'package:flutter/material.dart';
  import 'package:google_mobile_ads/google_mobile_ads.dart';
  import 'ad_config.dart';

  class AdBannerWidget extends StatefulWidget {
    const AdBannerWidget({super.key});

    @override
    State<AdBannerWidget> createState() => _AdBannerWidgetState();
  }

  class _AdBannerWidgetState extends State<AdBannerWidget> {
    BannerAd? _bannerAd;

    @override
    void initState() {
      super.initState();
      if (!Platform.isAndroid && !Platform.isIOS) return;
      _bannerAd = BannerAd(
        adUnitId: AdConfig.adUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) => setState(() => _bannerAd = ad as BannerAd),
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            setState(() => _bannerAd = null);
          },
        ),
      )..load();
    }

    @override
    void dispose() {
      _bannerAd?.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      if (_bannerAd == null) return const SizedBox.shrink();
      return SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
  }
  ```

- [ ] **Step 4: Run the test — expect it to pass**

  ```bash
  flutter test test/widget_test.dart
  ```

  Expected: PASS for the AdBannerWidget group.

- [ ] **Step 5: Commit**

  ```bash
  git add lib/utils/add_banner.dart test/widget_test.dart
  git commit -m "feat: implement AdBannerWidget"
  ```

---

## Task 4: Create InlineAdCard

**Files:**
- Create: `lib/utils/inline_ad_card.dart`

`InlineAdCard` is a `BannerAd` with `AdSize.mediumRectangle` (300×250) for placement inside scrollable lists. It uses the same ad unit ID as the bottom banner.

- [ ] **Step 1: Write the widget test**

  Add to `test/widget_test.dart`:
  ```dart
  import 'package:fitness_tracker_app/utils/inline_ad_card.dart';
  ```

  Add inside `void main()`:
  ```dart
  group('InlineAdCard', () {
    testWidgets('renders SizedBox.shrink when no ad loaded', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: InlineAdCard())),
      );
      final sizedBox = tester.widgetList<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.any((b) => b.width == 0 && b.height == 0), isTrue);
    });
  });
  ```

- [ ] **Step 2: Run the test — expect it to fail**

  ```bash
  flutter test test/widget_test.dart
  ```

  Expected: FAIL — `inline_ad_card.dart` does not exist.

- [ ] **Step 3: Create lib/utils/inline_ad_card.dart**

  ```dart
  import 'dart:io';
  import 'package:flutter/material.dart';
  import 'package:google_mobile_ads/google_mobile_ads.dart';
  import 'ad_config.dart';

  class InlineAdCard extends StatefulWidget {
    const InlineAdCard({super.key});

    @override
    State<InlineAdCard> createState() => _InlineAdCardState();
  }

  class _InlineAdCardState extends State<InlineAdCard> {
    BannerAd? _ad;

    @override
    void initState() {
      super.initState();
      if (!Platform.isAndroid && !Platform.isIOS) return;
      _ad = BannerAd(
        adUnitId: AdConfig.adUnitId,
        size: AdSize.mediumRectangle,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) => setState(() => _ad = ad as BannerAd),
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            setState(() => _ad = null);
          },
        ),
      )..load();
    }

    @override
    void dispose() {
      _ad?.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      if (_ad == null) return const SizedBox.shrink();
      return Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        width: _ad!.size.width.toDouble(),
        height: _ad!.size.height.toDouble(),
        child: AdWidget(ad: _ad!),
      );
    }
  }
  ```

- [ ] **Step 4: Run the test — expect it to pass**

  ```bash
  flutter test test/widget_test.dart
  ```

  Expected: PASS.

- [ ] **Step 5: Commit**

  ```bash
  git add lib/utils/inline_ad_card.dart test/widget_test.dart
  git commit -m "feat: implement InlineAdCard"
  ```

---

## Task 5: Create ad list injection helper + tests

**Files:**
- Create: `lib/utils/ad_list_helper.dart`
- Create: `test/ad_list_helper_test.dart`

This helper converts a real item count into an "effective" count that includes ad slots, and maps effective indices back to real data indices.

Injection rule: ad slots at effective indices 5, 14, 23, 32, ... (starts at 5, then every +9 = 8 real items + 1 ad slot).

- [ ] **Step 1: Write the tests first**

  Create `test/ad_list_helper_test.dart`:
  ```dart
  import 'package:flutter_test/flutter_test.dart';
  import 'package:fitness_tracker_app/utils/ad_list_helper.dart';

  void main() {
    group('effectiveItemCount', () {
      test('returns real count unchanged when fewer than 5 items', () {
        expect(effectiveItemCount(0), 0);
        expect(effectiveItemCount(4), 4);
      });

      test('adds one ad slot for 5 to 12 real items', () {
        expect(effectiveItemCount(5), 6);
        expect(effectiveItemCount(6), 7);
        expect(effectiveItemCount(12), 13);
      });

      test('adds two ad slots for 13 to 20 real items', () {
        expect(effectiveItemCount(13), 15);
        expect(effectiveItemCount(14), 16);
        expect(effectiveItemCount(20), 22);
      });

      test('adds three ad slots for 21 to 28 real items', () {
        expect(effectiveItemCount(21), 24);
        expect(effectiveItemCount(28), 31);
      });
    });

    group('isAdIndex', () {
      test('returns false for indices 0-4', () {
        for (int i = 0; i < 5; i++) {
          expect(isAdIndex(i), isFalse, reason: 'index $i should not be an ad');
        }
      });

      test('returns true at 5, 14, 23', () {
        expect(isAdIndex(5), isTrue);
        expect(isAdIndex(14), isTrue);
        expect(isAdIndex(23), isTrue);
      });

      test('returns false for non-ad indices', () {
        expect(isAdIndex(4), isFalse);
        expect(isAdIndex(6), isFalse);
        expect(isAdIndex(13), isFalse);
        expect(isAdIndex(15), isFalse);
      });
    });

    group('realIndexFor', () {
      test('maps effective 0-4 to real 0-4 (no ads before)', () {
        for (int i = 0; i < 5; i++) {
          expect(realIndexFor(i), i);
        }
      });

      test('maps effective 6-13 to real 5-12 (one ad before at 5)', () {
        expect(realIndexFor(6), 5);
        expect(realIndexFor(13), 12);
      });

      test('maps effective 15-22 to real 13-20 (two ads before)', () {
        expect(realIndexFor(15), 13);
        expect(realIndexFor(22), 20);
      });
    });
  }
  ```

- [ ] **Step 2: Run the tests — expect them to fail**

  ```bash
  flutter test test/ad_list_helper_test.dart
  ```

  Expected: FAIL — `ad_list_helper.dart` does not exist.

- [ ] **Step 3: Create lib/utils/ad_list_helper.dart**

  ```dart
  import 'package:flutter/material.dart';
  import 'inline_ad_card.dart';

  /// Returns true if [effectiveIndex] is an ad slot.
  /// Ad slots are at effective indices 5, 14, 23, 32, ... (every 9th position starting at 5).
  bool isAdIndex(int effectiveIndex) {
    if (effectiveIndex < 5) return false;
    return (effectiveIndex - 5) % 9 == 0;
  }

  /// Maps an [effectiveIndex] (which includes ad slots) to the real data index.
  /// Only call this when [isAdIndex] returns false for [effectiveIndex].
  int realIndexFor(int effectiveIndex) {
    final int adsBefore =
        effectiveIndex < 5 ? 0 : ((effectiveIndex - 5) ~/ 9) + 1;
    return effectiveIndex - adsBefore;
  }

  /// Returns the total item count including ad slots for a list with [realCount] real items.
  int effectiveItemCount(int realCount) {
    if (realCount < 5) return realCount;
    return realCount + ((realCount - 5) ~/ 8) + 1;
  }

  /// Returns the widget for [effectiveIndex]: an [InlineAdCard] for ad slots,
  /// or the result of [realBuilder] for real items.
  Widget adAwareItemBuilder(
    int effectiveIndex,
    Widget Function(int realIndex) realBuilder,
  ) {
    if (isAdIndex(effectiveIndex)) return const InlineAdCard();
    return realBuilder(realIndexFor(effectiveIndex));
  }
  ```

- [ ] **Step 4: Run the tests — expect them to pass**

  ```bash
  flutter test test/ad_list_helper_test.dart
  ```

  Expected: all 10 test cases PASS.

- [ ] **Step 5: Commit**

  ```bash
  git add lib/utils/ad_list_helper.dart test/ad_list_helper_test.dart
  git commit -m "feat: add ad list injection helper with tests"
  ```

---

## Task 6: Initialize MobileAds in main.dart

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Add the import and initialization call**

  In `lib/main.dart`, add this import after the existing imports:
  ```dart
  import 'package:google_mobile_ads/google_mobile_ads.dart';
  ```

  In the `main()` function, add the initialization call after `WidgetsFlutterBinding.ensureInitialized()`:
  ```dart
  Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await MobileAds.instance.initialize();          // add this line
    await dotenv.load(fileName: ".env.production");
    final token = await TokenService.getToken();
    runApp( ... );
  }
  ```

- [ ] **Step 2: Verify it compiles**

  ```bash
  flutter analyze
  ```

  Expected: no errors.

- [ ] **Step 3: Commit**

  ```bash
  git add lib/main.dart
  git commit -m "feat: initialize MobileAds on app startup"
  ```

---

## Task 7: Add banner to HomeScreen

**Files:**
- Modify: `lib/screens/home_screen.dart`

The `HomeScreen` Scaffold has `bottomNavigationBar: CustomBottomNavBar(currentIndex: _currentIndex)` at line 720. Replace it with a `Column` that stacks `AdBannerWidget` above the nav bar.

- [ ] **Step 1: Add the import**

  In `lib/screens/home_screen.dart`, add:
  ```dart
  import '../utils/add_banner.dart';
  ```

- [ ] **Step 2: Replace the bottomNavigationBar value**

  Find:
  ```dart
  bottomNavigationBar: CustomBottomNavBar(currentIndex: _currentIndex),
  ```

  Replace with:
  ```dart
  bottomNavigationBar: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const AdBannerWidget(),
      CustomBottomNavBar(currentIndex: _currentIndex),
    ],
  ),
  ```

- [ ] **Step 3: Run analyzer**

  ```bash
  flutter analyze
  ```

  Expected: no errors.

- [ ] **Step 4: Commit**

  ```bash
  git add lib/screens/home_screen.dart
  git commit -m "feat: add banner ad to HomeScreen"
  ```

---

## Task 8: Add banner to WorkoutCalendarScreen

**Files:**
- Modify: `lib/screens/workout/workout_calendar_screen.dart`

`WorkoutCalendarScreen` Scaffold also has `bottomNavigationBar: CustomBottomNavBar(currentIndex: _currentIndex)` at line 228.

- [ ] **Step 1: Add the import**

  In `lib/screens/workout/workout_calendar_screen.dart`, add:
  ```dart
  import '../../utils/add_banner.dart';
  ```

- [ ] **Step 2: Replace the bottomNavigationBar value**

  Find:
  ```dart
  bottomNavigationBar: CustomBottomNavBar(currentIndex: _currentIndex),
  ```

  Replace with:
  ```dart
  bottomNavigationBar: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const AdBannerWidget(),
      CustomBottomNavBar(currentIndex: _currentIndex),
    ],
  ),
  ```

- [ ] **Step 3: Run analyzer**

  ```bash
  flutter analyze
  ```

  Expected: no errors.

- [ ] **Step 4: Commit**

  ```bash
  git add lib/screens/workout/workout_calendar_screen.dart
  git commit -m "feat: add banner ad to WorkoutCalendarScreen"
  ```

---

## Task 9: Add banner + inline ads to FoodsScreen

**Files:**
- Modify: `lib/screens/foods_screen.dart`

The food list is a `ListView.builder` inside a `Consumer<FoodProvider>`. It is at line 384 with `itemCount: filteredFoods.length` and a card-based `itemBuilder`. We replace the count with `effectiveItemCount` and the builder with `adAwareItemBuilder`.

The `bottomNavigationBar` is at line 472.

- [ ] **Step 1: Add imports**

  In `lib/screens/foods_screen.dart`, add:
  ```dart
  import '../utils/add_banner.dart';
  import '../utils/ad_list_helper.dart';
  ```

- [ ] **Step 2: Replace the bottomNavigationBar**

  Find:
  ```dart
  bottomNavigationBar: CustomBottomNavBar(currentIndex: _currentIndex),
  ```

  Replace with:
  ```dart
  bottomNavigationBar: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const AdBannerWidget(),
      CustomBottomNavBar(currentIndex: _currentIndex),
    ],
  ),
  ```

- [ ] **Step 3: Update the ListView.builder for the food list**

  Find the `ListView.builder` for foods (around line 384). It currently looks like:
  ```dart
  ListView.builder(
    key: const PageStorageKey<String>('food_list'),
    itemCount: filteredFoods.length,
    itemBuilder: (context, index) {
      final food = filteredFoods[index];
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ...
      );
    },
  ),
  ```

  Replace with:
  ```dart
  ListView.builder(
    key: const PageStorageKey<String>('food_list'),
    itemCount: effectiveItemCount(filteredFoods.length),
    itemBuilder: (context, index) => adAwareItemBuilder(
      index,
      (realIndex) {
        final food = filteredFoods[realIndex];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: colorScheme.primary.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              food.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: colorScheme.onSurface,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calories: \${food.calories} kcal',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 4),
                _buildNutritionInfo(food, proteinColor, carbsColor, fatsColor, caloriesColor),
              ],
            ),
            leading: Icon(
              food.isFavorite == 1 ? Icons.favorite : Icons.favorite_border,
              color: food.isFavorite == 1 ? colorScheme.error : colorScheme.onSurfaceVariant,
              size: 28,
            ),
            trailing: Icon(Icons.arrow_forward_ios, color: colorScheme.primary),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FoodDetailsScreen(food: food)),
              );
            },
          ),
        );
      },
    ),
  ),
  ```

- [ ] **Step 4: Run analyzer**

  ```bash
  flutter analyze
  ```

  Expected: no errors.

- [ ] **Step 5: Commit**

  ```bash
  git add lib/screens/foods_screen.dart
  git commit -m "feat: add banner and inline ads to FoodsScreen"
  ```

---

## Task 10: Add banner + inline ads to WorkoutManagementScreen

**Files:**
- Modify: `lib/screens/workout/workout_list_screen.dart`

`WorkoutManagementScreen` has no `bottomNavigationBar` (it's nested inside `WorkoutRootScreen`). Add `AdBannerWidget` as its `bottomNavigationBar`. The workout list is a `ListView.separated` in `_buildWorkoutsList` — convert it to use `adAwareItemBuilder`.

- [ ] **Step 1: Add imports**

  In `lib/screens/workout/workout_list_screen.dart`, add:
  ```dart
  import '../../utils/add_banner.dart';
  import '../../utils/ad_list_helper.dart';
  ```

- [ ] **Step 2: Add AdBannerWidget as bottomNavigationBar**

  In the `build` method, find the `Scaffold(...)` and add `bottomNavigationBar`:
  ```dart
  return Scaffold(
    backgroundColor: theme.scaffoldBackgroundColor,
    appBar: AppBar( ... ),
    body: _isLoading
        ? _buildLoadingState(colorScheme)
        : _errorMessage != null
        ? _buildErrorState(colorScheme)
        : _buildWorkoutsList(theme, colorScheme),
    bottomNavigationBar: const AdBannerWidget(),   // add this line
    floatingActionButton: FloatingActionButton( ... ),
  );
  ```

- [ ] **Step 3: Update _buildWorkoutsList to inject inline ads**

  Find `_buildWorkoutsList` (around line 128). It currently has a `ListView.separated`:
  ```dart
  Widget _buildWorkoutsList(ThemeData theme, ColorScheme colorScheme) {
    if (_workouts.isEmpty) {
      return _buildEmptyState(theme, colorScheme);
    }
    return RefreshIndicator(
      onRefresh: _fetchWorkouts,
      color: colorScheme.primary,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _workouts.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final workout = _workouts[index];
          return _buildWorkoutCard(theme, colorScheme, workout);
        },
      ),
    );
  }
  ```

  Replace with:
  ```dart
  Widget _buildWorkoutsList(ThemeData theme, ColorScheme colorScheme) {
    if (_workouts.isEmpty) {
      return _buildEmptyState(theme, colorScheme);
    }
    return RefreshIndicator(
      onRefresh: _fetchWorkouts,
      color: colorScheme.primary,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: effectiveItemCount(_workouts.length),
        separatorBuilder: (context, index) =>
            isAdIndex(index) || isAdIndex(index + 1) ? const SizedBox.shrink() : const SizedBox(height: 12),
        itemBuilder: (context, index) => adAwareItemBuilder(
          index,
          (realIndex) => _buildWorkoutCard(theme, colorScheme, _workouts[realIndex]),
        ),
      ),
    );
  }
  ```

  Note: The `separatorBuilder` returns `SizedBox.shrink()` when the next item is an ad card (so there's no double-spacing around the ad).

- [ ] **Step 4: Run analyzer**

  ```bash
  flutter analyze
  ```

  Expected: no errors.

- [ ] **Step 5: Run all tests**

  ```bash
  flutter test
  ```

  Expected: all tests pass.

- [ ] **Step 6: Commit**

  ```bash
  git add lib/screens/workout/workout_list_screen.dart
  git commit -m "feat: add banner and inline ads to WorkoutManagementScreen"
  ```

---

## Task 11: Final verification

- [ ] **Step 1: Run full test suite**

  ```bash
  flutter test
  ```

  Expected: all tests pass with no errors.

- [ ] **Step 2: Run static analysis**

  ```bash
  flutter analyze
  ```

  Expected: clean (no new errors beyond pre-existing warnings).

- [ ] **Step 3: Build for Android to verify compilation**

  ```bash
  flutter build apk --debug
  ```

  Expected: builds successfully. APK is in `build/app/outputs/flutter-apk/`.

- [ ] **Step 4: Commit if anything was missed**

  If any files were changed in the verification steps, commit them:
  ```bash
  git add -A
  git commit -m "fix: address any final analyzer issues"
  ```
