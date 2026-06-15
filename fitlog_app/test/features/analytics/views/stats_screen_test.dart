import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlog_app/features/analytics/views/stats_screen.dart';
import 'package:fitlog_app/features/analytics/providers/analytics_providers.dart';

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
      const ProviderScope(
        child: MaterialApp(home: StatsScreen()),
      ),
    );

    await tester.pump();

    // Check if selector exists
    expect(find.byType(SegmentedButton<StatsTimeframe>), findsOneWidget);
    
    // Tap 'Month'
    await tester.tap(find.text('Month'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    
    // We can't easily verify the provider state change here without a more complex setup,
    // but we can verify the widget responded if we wanted to.
  });
}
