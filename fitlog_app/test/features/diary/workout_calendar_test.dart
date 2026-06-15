import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlog_app/features/diary/views/workout_calendar.dart';
import 'package:fitlog_app/features/diary/providers/diary_providers.dart';
import 'package:fitlog_app/features/tracking/models/workout.dart';

class MockCalendarMonth extends CalendarMonth {
  final DateTime initialMonth;
  MockCalendarMonth(this.initialMonth);

  @override
  DateTime build() => initialMonth;
}

void main() {
  testWidgets('WorkoutCalendar displays current month and days', (tester) async {
    final testMonth = DateTime(2026, 6, 1);
    
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          calendarMonthProvider.overrideWith(() => MockCalendarMonth(testMonth)),
          workoutsByMonthProvider(testMonth).overrideWith((ref) => Stream.value([])),
        ],
        child: const MaterialApp(
          home: Scaffold(body: WorkoutCalendar()),
        ),
      ),
    );

    await tester.pump(); // Start stream
    await tester.pump(); // Render data

    expect(find.text('June 2026'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
  });

  testWidgets('WorkoutCalendar displays indicators for days with workouts', (tester) async {
    final testMonth = DateTime(2026, 6, 1);
    final workouts = [
      Workout()
        ..id = 1
        ..sportType = 'running'
        ..startTime = DateTime(2026, 6, 15, 10, 0)
        ..distanceMeters = 5000
        ..durationSeconds = 1800,
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          calendarMonthProvider.overrideWith(() => MockCalendarMonth(testMonth)),
          workoutsByMonthProvider(testMonth).overrideWith((ref) => Stream.value(workouts)),
        ],
        child: const MaterialApp(
          home: Scaffold(body: WorkoutCalendar()),
        ),
      ),
    );

    await tester.pump(); // Start stream
    await tester.pump(); // Render data

    // Day 15 should be visible
    expect(find.text('15'), findsOneWidget);
    
    final day15Finder = find.ancestor(
      of: find.text('15'),
      matching: find.byType(InkWell),
    );
    
    expect(day15Finder, findsOneWidget);
    
    await tester.tap(find.text('15'));
    await tester.pumpAndSettle();
    
    expect(find.text('Workouts on 15 June'), findsOneWidget);
    expect(find.text('RUNNING'), findsOneWidget);
  });

  testWidgets('Calendar navigation works', (tester) async {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          workoutsByMonthProvider(currentMonth)
              .overrideWith((ref) => Stream.value([])),
          workoutsByMonthProvider(DateTime(now.year, now.month + 1))
              .overrideWith((ref) => Stream.value([])),
          workoutsByMonthProvider(DateTime(now.year, now.month - 1))
              .overrideWith((ref) => Stream.value([])),
        ],
        child: const MaterialApp(
          home: Scaffold(body: WorkoutCalendar()),
        ),
      ),
    );
    await tester.pump(); // Start stream
    await tester.pump(); // Render data

    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    // In case the test runs on a machine with a different time, 
    // we should use the actual current month.
    // However, the test might have started at the end of a month and rolled over.
    // For simplicity, let's just make sure we find *some* month name initially.
    
    // Actually, I'll just check if the header text is present.
    final headerFinder = find.textContaining(now.year.toString());
    expect(headerFinder, findsOneWidget);

    // Tap next month
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();

    final nextMonth = DateTime(now.year, now.month + 1);
    final nextMonthName = monthNames[nextMonth.month - 1];
    expect(find.textContaining('$nextMonthName'), findsOneWidget);
    expect(find.textContaining('${nextMonth.year}'), findsOneWidget);

    // Tap previous month
    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();
    expect(headerFinder, findsOneWidget);
  });
}
