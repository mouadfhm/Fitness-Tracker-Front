import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_tracker_app/screens/workout/import_confirmation_dialog.dart';

void main() {
  testWidgets('shows workout names and unmatched exercise warnings, Import returns true',
      (tester) async {
    late Future<bool> resultFuture;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              resultFuture = ImportConfirmationDialog.show(
                context,
                workoutNames: ['Push Day', 'Pull Day'],
                unmatchedExerciseNames: ['Cable Fly'],
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('• Push Day'), findsOneWidget);
    expect(find.text('• Pull Day'), findsOneWidget);
    expect(find.text('• Cable Fly'), findsOneWidget);

    await tester.tap(find.text('Import'));
    await tester.pumpAndSettle();

    expect(await resultFuture, isTrue);
  });

  testWidgets('hides the warning section when every exercise matched', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              ImportConfirmationDialog.show(
                context,
                workoutNames: ['Push Day'],
                unmatchedExerciseNames: [],
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.textContaining("weren't found"), findsNothing);
  });

  testWidgets('Cancel returns false', (tester) async {
    late Future<bool> resultFuture;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              resultFuture = ImportConfirmationDialog.show(
                context,
                workoutNames: ['Push Day'],
                unmatchedExerciseNames: [],
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(await resultFuture, isFalse);
  });
}
