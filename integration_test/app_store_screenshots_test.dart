// Walks through the six App Store screens with a demo account and asks the
// "App Store screenshots" workflow (.github/workflows/app-store-screenshots.yml)
// to capture each one from the iPhone simulator.
//
// Run on a booted simulator, in English or French:
//   flutter test integration_test/app_store_screenshots_test.dart \
//     -d <simulator id> --dart-define=SCREENSHOT_LANG=fr
// Without the workflow polling, it just shows each screen and moves on.
//
// With --dart-define=APP_PREVIEW=true it plays the same screens as a ~25 s
// walk-through instead, for the App Store app preview video: the workflow
// records the simulator between the "preview/start" and "preview/end"
// signals.

import 'package:fitness_tracker_app/main.dart';
import 'package:fitness_tracker_app/providers/achievement_provider.dart';
import 'package:fitness_tracker_app/providers/exercise_provider.dart';
import 'package:fitness_tracker_app/providers/food_provider.dart';
import 'package:fitness_tracker_app/providers/locale_provider.dart';
import 'package:fitness_tracker_app/providers/profile_provider.dart';
import 'package:fitness_tracker_app/providers/theme_provider.dart';
import 'package:fitness_tracker_app/screens/achievements_screen.dart';
import 'package:fitness_tracker_app/screens/foods_screen.dart';
import 'package:fitness_tracker_app/screens/home_screen.dart';
import 'package:fitness_tracker_app/screens/main_shell.dart';
import 'package:fitness_tracker_app/screens/progress_screen.dart';
import 'package:fitness_tracker_app/screens/widgets/bottom_nav_bar.dart';
import 'package:fitness_tracker_app/screens/widgets/notification_prompt_card.dart';
import 'package:fitness_tracker_app/screens/workout/workout_detail_screen.dart';
import 'package:fitness_tracker_app/services/navigation_service.dart';
import 'package:fitness_tracker_app/services/token_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'demo_backend.dart';

const _lang = String.fromEnvironment('SCREENSHOT_LANG', defaultValue: 'en');
const _preview = bool.fromEnvironment('APP_PREVIEW');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App Store ${_preview ? 'preview' : 'screenshots'} ($_lang)', (
    tester,
  ) async {
    final backend = await DemoBackend.start(language: _lang);
    addTearDown(backend.close);

    dotenv.testLoad(fileInput: 'BASE_URL=${backend.baseUrl}');
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.setString('language_code', _lang);
    await prefs.setString('theme_mode', 'light');
    // The weekly calendar rather than the simple activity log.
    await prefs.setString('workout_mode', 'advanced');
    await prefs.setBool(NotificationPromptCard.dismissedKey, true);
    await TokenService.saveToken('demo-token');

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => ProfileProvider()..fetchProfile(),
          ),
          ChangeNotifierProvider(create: (_) => FoodProvider()),
          ChangeNotifierProvider(create: (_) => ExercisesProvider()),
          ChangeNotifierProvider(create: (_) => AchievementsProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ],
        child: const MyApp(isLoggedIn: true),
      ),
    );

    /// In screenshot mode, waits for the screen and has it captured. In
    /// preview mode, shows it for a few seconds, scrolling the main list of
    /// the [screen] widget down by [scroll] pixels halfway through.
    Future<void> shoot(String name, {double scroll = 0, Type? screen}) async {
      if (!_preview) {
        await _waitUntilLoaded(tester);
        await backend.screenshot('$_lang/$name');
        return;
      }
      await _waitUntilLoaded(tester, settle: false);
      await _hold(tester, const Duration(milliseconds: 1500));
      if (scroll > 0) {
        // The vertical list with the most to scroll; other tabs' lists are
        // still in the tree, so look only inside this screen.
        final position = tester
            .stateList<ScrollableState>(
              find.descendant(
                of: find.byType(screen!),
                matching: find.byType(Scrollable),
              ),
            )
            .map((s) => s.position)
            .where((p) => p.axis == Axis.vertical)
            .reduce((a, b) => a.maxScrollExtent >= b.maxScrollExtent ? a : b);
        // Not awaited: the animation runs on frames, which _hold pumps.
        position.animateTo(
          scroll.clamp(0, position.maxScrollExtent),
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeInOut,
        );
        await _hold(tester, const Duration(milliseconds: 2200));
      } else {
        await _hold(tester, const Duration(milliseconds: 1500));
      }
    }

    void selectTab(int index) {
      final bar = tester.element(
        find.byType(CustomBottomNavBar, skipOffstage: false),
      );
      MainShellScope.maybeOf(bar)!.select(index);
    }

    void open(Widget screen) {
      NavigationService.navigatorKey.currentState!.push(
        MaterialPageRoute(builder: (_) => screen),
      );
    }

    void back() => NavigationService.navigatorKey.currentState!.pop();

    if (_preview) {
      // Load the other tabs before recording, so the video doesn't show
      // them loading.
      for (final tab in [2, 1, 0]) {
        selectTab(tab);
        await _waitUntilLoaded(tester);
      }
      await backend.screenshot('preview/start');
    }

    await shoot('1-today', scroll: 420, screen: HomeScreen);

    selectTab(2);
    await shoot('2-foods', scroll: 500, screen: FoodsScreen);

    selectTab(1);
    await shoot('3-week-plan');

    // Today's workout on the plan (DemoBackend always puts the first one on
    // today).
    open(const WorkoutDetailScreen(workoutId: 1));
    await shoot('4-workout', scroll: 300, screen: WorkoutDetailScreen);
    back();

    selectTab(3);
    open(const ProgressScreen());
    await shoot('5-progress');
    back();

    open(const AchievementsScreen());
    await shoot('6-achievements', scroll: 500, screen: AchievementsScreen);

    if (_preview) await backend.screenshot('preview/end');
  });
}

/// Keeps frames coming for [duration] of real time.
Future<void> _hold(WidgetTester tester, Duration duration) async {
  final end = DateTime.now().add(duration);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

/// Pumps until nothing on screen is still loading, then (with [settle]) lets
/// animations (page transitions, the nav bar circle, charts) finish.
Future<void> _waitUntilLoaded(WidgetTester tester, {bool settle = true}) async {
  final spinner = find.byWidgetPredicate(
    (w) => w is ProgressIndicator && w.value == null,
  );
  // Give the screen time to start its requests and show its spinner first.
  await _hold(tester, Duration(milliseconds: settle ? 2000 : 300));
  final deadline = DateTime.now().add(const Duration(seconds: 30));
  while (spinner.evaluate().isNotEmpty) {
    if (DateTime.now().isAfter(deadline)) {
      throw TestFailure('Still loading after 30 seconds');
    }
    await tester.pump(const Duration(milliseconds: 16));
  }
  if (settle) await _hold(tester, const Duration(seconds: 2));
}
