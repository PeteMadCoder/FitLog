import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlog_app/app/main_navigation_shell.dart';

void main() {
  testWidgets('Navigation Shell switches tabs on tap', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: MainNavigationShell(),
        ),
      ),
    );

    // Verify initial screen is the Home Dashboard.
    expect(find.text('Home Dashboard Screen'), findsOneWidget);

    // Tap Tracker icon to navigate to Tracker tab.
    await tester.tap(find.byIcon(Icons.play_circle_outline));
    await tester.pumpAndSettle();
    expect(find.text('Start Workout'), findsOneWidget);

    // Tap Maps icon to navigate to Maps tab.
    await tester.tap(find.byIcon(Icons.map_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Maps and Routes Screen'), findsOneWidget);

    // Tap Diary icon to navigate to Diary tab.
    await tester.tap(find.byIcon(Icons.calendar_month_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Workout Diary & Calendar Screen'), findsOneWidget);

    // Tap Stats icon to navigate to Stats tab.
    await tester.tap(find.byIcon(Icons.bar_chart_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Statistics Dashboard Screen'), findsOneWidget);
  });
}
