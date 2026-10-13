// Walks through the six App Store screens with a demo account and asks the
// "App Store screenshots" workflow (.github/workflows/app-store-screenshots.yml)
// to capture each one from the iPhone simulator.
//
// Run on a booted simulator, in English or French:
//   flutter test integration_test/app_store_screenshots_test.dart \
//     -d <simulator id> --dart-define=SCREENSHOT_LANG=fr
// Without the workflow polling, it just shows each screen and moves on.

import 'package:fitness_tracker_app/main.dart';
import 'package:fitness_tracker_app/providers/achievement_provider.dart';
import 'package:fitness_tracker_app/providers/exercise_provider.dart';
import 'package:fitness_tracker_app/providers/food_provider.dart';
import 'package:fitness_tracker_app/providers/locale_provider.dart';
import 'package:fitness_tracker_app/providers/profile_provider.dart';
import 'package:fitness_tracker_app/providers/theme_provider.dart';
import 'package:fitness_tracker_app/screens/achievements_screen.dart';
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

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App Store screenshots ($_lang)', (tester) async {
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

    Future<void> shoot(String name) async {
      await _waitUntilLoaded(tester);
      await backend.screenshot('$_lang/$name');
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

    await shoot('1-today');

    selectTab(2);
    await shoot('2-foods');

    selectTab(1);
    await shoot('3-week-plan');

    // Today's workout on the plan (DemoBackend always puts the first one on
    // today).
    open(const WorkoutDetailScreen(workoutId: 1));
    await shoot('4-workout');
    back();

    selectTab(3);
    open(const ProgressScreen());
    await shoot('5-progress');
    back();

    open(const AchievementsScreen());
    await shoot('6-achievements');
  });
}

/// Pumps until nothing on screen is still loading, then lets animations
/// (page transitions, the nav bar circle, charts) finish.
Future<void> _waitUntilLoaded(WidgetTester tester) async {
  final spinner = find.byWidgetPredicate(
    (w) => w is ProgressIndicator && w.value == null,
  );
  // Give the screen time to start its requests and show its spinner first.
  await tester.pump(const Duration(seconds: 2));
  final deadline = DateTime.now().add(const Duration(seconds: 30));
  while (spinner.evaluate().isNotEmpty) {
    if (DateTime.now().isAfter(deadline)) {
      throw TestFailure('Still loading after 30 seconds');
    }
    await tester.pump(const Duration(milliseconds: 250));
  }
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 250));
  }
}
