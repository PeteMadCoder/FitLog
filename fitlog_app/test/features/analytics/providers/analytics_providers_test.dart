import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlog_app/features/analytics/providers/analytics_providers.dart';

void main() {
  group('SelectedStatsTimeframe Provider', () {
    test('initial state should be weekly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(selectedStatsTimeframeProvider), equals(StatsTimeframe.weekly));
    });

    test('setTimeframe should update state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(selectedStatsTimeframeProvider.notifier).setTimeframe(StatsTimeframe.monthly);
      expect(container.read(selectedStatsTimeframeProvider), equals(StatsTimeframe.monthly));

      container.read(selectedStatsTimeframeProvider.notifier).setTimeframe(StatsTimeframe.yearly);
      expect(container.read(selectedStatsTimeframeProvider), equals(StatsTimeframe.yearly));
    });
  });

  group('AggregatedStats factory', () {
    test('empty factory should return zeroed stats', () {
      final stats = AggregatedStats.empty();
      expect(stats.totalDistanceMeters, equals(0));
      expect(stats.totalDuration, equals(Duration.zero));
      expect(stats.totalCalories, equals(0));
      expect(stats.workoutCount, equals(0));
    });
  });
}
