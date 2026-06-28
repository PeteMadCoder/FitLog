import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlog_app/features/analytics/views/stats_screen.dart';
import 'package:fitlog_app/features/analytics/providers/analytics_providers.dart';

class FakeSelectedStatsTimeframe extends SelectedStatsTimeframe {
  final StatsTimeframe initialValue;
  FakeSelectedStatsTimeframe(this.initialValue);

  @override
  StatsTimeframe build() => initialValue;
}

class FakeStatsReferenceDate extends StatsReferenceDate {
  final DateTime initialValue;
  FakeStatsReferenceDate(this.initialValue);

  @override
  DateTime build() => initialValue;
}

void main() {
  testWidgets('StatsScreen displays aggregated metrics', (tester) async {
    final stats = AggregatedStats(
      totalDistanceMeters: 5000,
      totalDuration: const Duration(minutes: 30),
      totalCalories: 350,
      workoutCount: 2,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardStatsProvider.overrideWith((ref) => Stream.value(stats)),
        ],
        child: const MaterialApp(home: StatsScreen()),
      ),
    );

    await tester.pump(); // Start stream
    await tester.pump(); // Render data

    expect(find.text('5.00'), findsOneWidget); // 5000m = 5km
    expect(find.text('30:00'), findsOneWidget);
    expect(find.text('350'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('StatsScreen timeframe selector works', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: StatsScreen())),
    );

    await tester.pump();

    // Check if selector exists
    expect(find.byType(SegmentedButton<StatsTimeframe>), findsOneWidget);

    // Tap 'Month'
    await tester.tap(find.text('Month'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('StatsScreen displays pagination and week calendar when timeframe is weekly', (tester) async {
    final stats = AggregatedStats(
      totalDistanceMeters: 1000,
      totalDuration: const Duration(minutes: 10),
      totalCalories: 100,
      workoutCount: 1,
    );

    final mockRefDate = DateTime(2026, 6, 28);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardStatsProvider.overrideWith((ref) => Stream.value(stats)),
          selectedStatsTimeframeProvider.overrideWith(() => FakeSelectedStatsTimeframe(StatsTimeframe.weekly)),
          statsReferenceDateProvider.overrideWith(() => FakeStatsReferenceDate(mockRefDate)),
          statsWorkoutsProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: const MaterialApp(home: StatsScreen()),
      ),
    );

    await tester.pump();
    await tester.pump();

    // Weekly header: Monday is June 22. Sunday is June 28.
    expect(find.text('June 22 - 28, 2026'), findsOneWidget);

    // Week calendar should display weekday labels and day numbers of that week
    expect(find.text('22'), findsOneWidget);
    expect(find.text('28'), findsOneWidget);

    // Chevron icons for navigation
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });

  testWidgets('StatsScreen displays monthly calendar when timeframe is monthly', (tester) async {
    final stats = AggregatedStats(
      totalDistanceMeters: 2000,
      totalDuration: const Duration(minutes: 20),
      totalCalories: 200,
      workoutCount: 2,
    );

    final mockRefDate = DateTime(2026, 6, 28);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardStatsProvider.overrideWith((ref) => Stream.value(stats)),
          selectedStatsTimeframeProvider.overrideWith(() => FakeSelectedStatsTimeframe(StatsTimeframe.monthly)),
          statsReferenceDateProvider.overrideWith(() => FakeStatsReferenceDate(mockRefDate)),
          statsWorkoutsProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: const MaterialApp(home: StatsScreen()),
      ),
    );

    await tester.pump();
    await tester.pump();

    // Monthly header: "June 2026"
    expect(find.text('June 2026'), findsOneWidget);

    // Grid should contain days of June (1 to 30)
    expect(find.text('1'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
  });

  testWidgets('StatsScreen displays yearly heatmap when timeframe is yearly', (tester) async {
    final stats = AggregatedStats(
      totalDistanceMeters: 3000,
      totalDuration: const Duration(minutes: 30),
      totalCalories: 300,
      workoutCount: 3,
    );

    final mockRefDate = DateTime(2026, 6, 28);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardStatsProvider.overrideWith((ref) => Stream.value(stats)),
          selectedStatsTimeframeProvider.overrideWith(() => FakeSelectedStatsTimeframe(StatsTimeframe.yearly)),
          statsReferenceDateProvider.overrideWith(() => FakeStatsReferenceDate(mockRefDate)),
          statsWorkoutsProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: const MaterialApp(home: StatsScreen()),
      ),
    );

    await tester.pump();
    await tester.pump();

    // Yearly header: "Year 2026"
    expect(find.text('Year 2026'), findsOneWidget);
    
    // Heatmap title
    expect(find.text('Activity Heatmap'), findsOneWidget);
  });
}
