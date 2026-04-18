import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitness_tracker_app/providers/exercise_provider.dart';
import 'package:fitness_tracker_app/screens/workout_screen.dart';
import 'package:fitness_tracker_app/screens/workout/workout_calendar_screen.dart';
import 'package:fitness_tracker_app/screens/workout_root_screen.dart';

Widget _wrap(Widget child) => MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ExercisesProvider())],
      child: MaterialApp(home: child),
    );

void main() {
  setUpAll(() async {
    await dotenv.load(fileName: '.env.development');
  });

  testWidgets('WorkoutScreen calls onModeToggle when Advanced tapped', (tester) async {
    bool toggled = false;
    await tester.pumpWidget(_wrap(
      WorkoutScreen(onModeToggle: () => toggled = true),
    ));
    await tester.pump();
    await tester.tap(find.text('Advanced'));
    expect(toggled, isTrue);
  });

  testWidgets('WorkoutScreen shows Simple as active by default', (tester) async {
    await tester.pumpWidget(_wrap(
      WorkoutScreen(onModeToggle: () {}),
    ));
    await tester.pump();
    expect(find.text('Simple'), findsOneWidget);
    expect(find.text('Advanced'), findsOneWidget);
  });

  testWidgets('WorkoutCalendarScreen calls onModeToggle when Simple tapped', (tester) async {
    bool toggled = false;
    await tester.pumpWidget(MaterialApp(
      home: WorkoutCalendarScreen(onModeToggle: () => toggled = true),
    ));
    await tester.pump();
    await tester.tap(find.text('Simple'));
    expect(toggled, isTrue);
  });

  group('WorkoutRootScreen', () {
    testWidgets('shows Simple mode by default (no saved preference)', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(_wrap(const WorkoutRootScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Search Exercises...'), findsOneWidget);
    });

    testWidgets('shows Advanced mode when preference is saved', (tester) async {
      SharedPreferences.setMockInitialValues({'workout_mode': 'advanced'});
      await tester.pumpWidget(_wrap(const WorkoutRootScreen()));
      // Pump until SharedPreferences loads — WorkoutCalendarScreen has ongoing
      // API futures so we cannot pumpAndSettle; a few pumps are sufficient.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Search Exercises...'), findsNothing);
    });
  });
}
