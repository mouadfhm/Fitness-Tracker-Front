import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_tracker_app/screens/forgot_password_screen.dart';

void main() {
  setUpAll(() => dotenv.testLoad(fileInput: 'BASE_URL=http://localhost'));

  Widget wrap(Widget child) => MaterialApp(home: child);

  testWidgets('starts by asking for the email, prefilled from login', (tester) async {
    await tester.pumpWidget(wrap(const ForgotPasswordScreen(initialEmail: 'me@example.com')));

    expect(find.text('Send code'), findsOneWidget);
    expect(find.text('me@example.com'), findsOneWidget);
    expect(find.text('Code'), findsNothing);
  });

  testWidgets('rejects an invalid email before calling the server', (tester) async {
    await tester.pumpWidget(wrap(const ForgotPasswordScreen()));

    await tester.enterText(find.byType(TextFormField), 'not-an-email');
    await tester.tap(find.text('Send code'));
    await tester.pump();

    expect(find.text('Please enter a valid email address'), findsOneWidget);
  });
}
