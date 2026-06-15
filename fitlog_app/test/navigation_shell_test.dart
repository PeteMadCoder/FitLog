import 'package:fitlog_app/app/main_navigation_shell.dart';
import 'package:fitlog_app/features/analytics/providers/analytics_providers.dart';
import 'package:fitlog_app/features/diary/providers/diary_providers.dart';
import 'package:fitlog_app/features/tracking/models/workout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Navigation Shell switches tabs on tap', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          workoutHistoryProvider.overrideWith(
            (ref) => Stream.value(<Workout>[]),
          ),
          latestWorkoutProvider.overrideWith(
            (ref) => Stream.value(null),
          ),
          weeklyActivitySummaryProvider.overrideWith(
            (ref) => Stream.value(WeeklyActivitySummary(statsBySport: {})),
          ),
        ],
        child: const MaterialApp(home: MainNavigationShell()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify initial screen is the Home Dashboard.
    // There are two "Home" texts: one in the AppBar and one in the BottomNavigationBar.
    expect(find.text('Home'), findsNWidgets(2));

    // Tap Tracker icon to navigate to Tracker tab.
    await tester.tap(find.byIcon(Icons.play_circle_outline));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Start Workout'), findsOneWidget);

    // Tap Diary icon to navigate to Diary tab.
    await tester.tap(find.byIcon(Icons.calendar_month_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Workout Diary'), findsOneWidget);

    // Tap Stats icon to navigate to Stats tab.
    await tester.tap(find.byIcon(Icons.bar_chart_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Statistics'), findsOneWidget);
  });
}
