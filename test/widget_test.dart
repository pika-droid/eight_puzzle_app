// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:eight_puzzle_app/main.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    // Build our app and trigger a frame.
    await tester.pumpWidget(const EightPuzzleApp());

    // Allow time for BLoC to initialize and emit first state.
    // NOTE: We cannot use pumpAndSettle because the PuzzleBloc starts a periodic Timer,
    // which causes pumpAndSettle to time out.
    await tester.pump(const Duration(seconds: 1));

    // Verify that our app initializes with the puzzle page.
    expect(find.text('8 Puzzle'), findsOneWidget);
  });
}
