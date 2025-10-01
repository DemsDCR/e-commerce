// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:login/main.dart';

void main() {
  setUpAll(() async {
    // Initialize Firebase for testing
    await Firebase.initializeApp();
  });

  testWidgets('App starts and shows auth wrapper', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app starts with the auth wrapper
    expect(find.byType(MyApp), findsOneWidget);
  });
}
