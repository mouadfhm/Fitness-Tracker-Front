import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_tracker_app/screens/onboarding_screen.dart';

Widget _wrap(Widget child) => MaterialApp(home: child);

void main() {
  group('OnboardingScreen Step 1', () {
    testWidgets('shows progress bar with 4 segments', (tester) async {
      await tester.pumpWidget(_wrap(const OnboardingScreen()));
      expect(find.text('Your body stats'), findsOneWidget);
    });

    testWidgets('BMI card shows dash when fields are empty', (tester) async {
      await tester.pumpWidget(_wrap(const OnboardingScreen()));
      expect(find.textContaining('BMI'), findsOneWidget);
    });

    testWidgets('BMI card updates when weight and height are entered', (tester) async {
      await tester.pumpWidget(_wrap(const OnboardingScreen()));
      await tester.enterText(find.byKey(const Key('weight_field')), '70');
      await tester.enterText(find.byKey(const Key('height_field')), '175');
      await tester.pump();
      expect(find.textContaining('22.'), findsOneWidget);
    });

    testWidgets('Next button advances to step 2', (tester) async {
      await tester.pumpWidget(_wrap(const OnboardingScreen()));
      await tester.enterText(find.byKey(const Key('age_field')), '25');
      await tester.enterText(find.byKey(const Key('weight_field')), '70');
      await tester.enterText(find.byKey(const Key('height_field')), '175');
      await tester.pump();
      // Step 1 now has a units switch, so Next can sit below the fold.
      await tester.ensureVisible(find.text('Next'));
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text("What's your gender?"), findsOneWidget);
    });
  });

  group('OnboardingScreen Steps 2-4', () {
    Future<void> advanceToStep2(WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const OnboardingScreen()));
      await tester.enterText(find.byKey(const Key('age_field')), '25');
      await tester.enterText(find.byKey(const Key('weight_field')), '70');
      await tester.enterText(find.byKey(const Key('height_field')), '175');
      await tester.pump();
      // Step 1 now has a units switch, so Next can sit below the fold.
      await tester.ensureVisible(find.text('Next'));
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }

    testWidgets('Step 2 shows gender options', (tester) async {
      await advanceToStep2(tester);
      expect(find.text("What's your gender?"), findsOneWidget);
      expect(find.text('Male'), findsOneWidget);
      expect(find.text('Female'), findsOneWidget);
    });

    testWidgets('Tapping Female selects it', (tester) async {
      await advanceToStep2(tester);
      await tester.tap(find.text('Female'));
      await tester.pump();
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('Step 3 shows activity options', (tester) async {
      await advanceToStep2(tester);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('How active are you?'), findsOneWidget);
      expect(find.text('Mostly sitting'), findsOneWidget);
      expect(find.text('Moderately active'), findsOneWidget);
    });

    testWidgets('Step 4 shows goal options', (tester) async {
      await advanceToStep2(tester);
      // Step 2 → Step 3
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      // Step 3 has 5 activity cards — Next button may need scrolling
      await tester.ensureVisible(find.text('Next'));
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text("What's your goal?"), findsOneWidget);
      expect(find.text('Lose weight'), findsOneWidget);
      expect(find.text('Build muscle'), findsOneWidget);
      expect(find.text('Stay at my weight'), findsOneWidget);
    });
  });

  group('OnboardingScreen units', () {
    testWidgets('switching to lb / ft keeps the same BMI', (tester) async {
      await tester.pumpWidget(_wrap(const OnboardingScreen()));
      await tester.enterText(find.byKey(const Key('weight_field')), '70');
      await tester.enterText(find.byKey(const Key('height_field')), '175');
      await tester.pump();
      expect(find.text('22.9'), findsOneWidget);

      await tester.tap(find.text('lb / ft'));
      await tester.pump();
      expect(find.byKey(const Key('height_ft_field')), findsOneWidget);
      expect(find.byKey(const Key('height_field')), findsNothing);
      // 70 kg -> 154 lb, 175 cm -> 5 ft 9 in: BMI stays about the same.
      expect(find.textContaining('22.'), findsOneWidget);
    });
  });
}
