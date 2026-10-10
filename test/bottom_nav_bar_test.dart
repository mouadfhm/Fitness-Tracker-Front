import 'package:fitness_tracker_app/l10n/app_localizations.dart';
import 'package:fitness_tracker_app/screens/main_shell.dart';
import 'package:fitness_tracker_app/screens/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('inside the shell, tapping a tab switches in place', (tester) async {
    int? selected;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MainShellScope(
          currentIndex: 0,
          select: (i) => selected = i,
          child: const Scaffold(
            bottomNavigationBar: CustomBottomNavBar(currentIndex: 0),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Foods'));
    await tester.pump();

    expect(selected, 2);
    // No route was pushed: still exactly one page on the navigator.
    expect(find.byType(CustomBottomNavBar), findsOneWidget);
  });

  testWidgets('tapping the current tab does nothing', (tester) async {
    int? selected;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MainShellScope(
          currentIndex: 1,
          select: (i) => selected = i,
          child: const Scaffold(
            bottomNavigationBar: CustomBottomNavBar(currentIndex: 1),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Workouts'));
    await tester.pump();

    expect(selected, isNull);
  });

  testWidgets('labels follow the app language', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          bottomNavigationBar: CustomBottomNavBar(currentIndex: 0),
        ),
      ),
    );

    expect(find.text('Aliments'), findsOneWidget);
    expect(find.text('Foods'), findsNothing);
  });
}
