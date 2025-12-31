import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:assistant_side_bar_example/main.dart';

void main() {
  testWidgets('App renders without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Verify the app renders
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Sidebar Demo'), findsWidgets);
  });

  testWidgets('Sidebar controls are visible', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Verify control buttons exist
    expect(find.text('Expand Sidebar'), findsOneWidget);
    expect(find.text('Collapse Sidebar'), findsOneWidget);
    expect(find.text('Request Attention'), findsOneWidget);
  });
}
