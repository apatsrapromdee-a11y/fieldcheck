import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fieldcheck/main.dart';

void main() {
  testWidgets('FieldCheck app loads successfully',
      (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const FieldCheckApp());

    // Wait until all widgets are rendered
    await tester.pumpAndSettle();

    // Verify the app title appears
    expect(find.text('FieldCheck'), findsOneWidget);

    // Verify the Floating Action Button exists
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Verify the Add icon exists
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}