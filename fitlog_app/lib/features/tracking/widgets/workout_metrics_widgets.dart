import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlog_app/features/tracking/providers/tracking_notifier.dart';
import 'package:fitlog_app/shared/extensions/duration_extensions.dart';
import 'package:fitlog_app/core/utils/pace_calculator.dart';
import 'metric_card.dart';

/// Renders the current workout duration.
class DurationMetric extends ConsumerWidget {
  const DurationMetric({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final durationSeconds = ref.watch(
      trackingNotifierProvider.select((state) => state.durationSeconds),
    );
    final duration = Duration(seconds: durationSeconds.toInt());

    return MetricCard(
      label: 'Time',
      value: duration.toHoursMinutesSeconds(),
      icon: Icons.timer_outlined,
      iconColor: Colors.blue,
    );
  }
}

/// Renders the current workout distance in kilometers.
class DistanceMetric extends ConsumerWidget {
  const DistanceMetric({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final distanceMeters = ref.watch(
      trackingNotifierProvider.select((state) => state.distanceMeters),
    );
    final distanceKm = distanceMeters / 1000.0;

    return MetricCard(
      label: 'Distance',
      value: distanceKm.toStringAsFixed(2),
      unit: 'km',
      icon: Icons.directions_run,
      iconColor: Colors.green,
    );
  }
}

/// Renders the current speed in km/h.
class SpeedMetric extends ConsumerWidget {
  const SpeedMetric({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSpeed = ref.watch(
      trackingNotifierProvider.select((state) => state.currentSpeed),
    );
    final speedKmH = currentSpeed * 3.6;

    return MetricCard(
      label: 'Speed',
      value: speedKmH.toStringAsFixed(1),
      unit: 'km/h',
      icon: Icons.speed,
      iconColor: Colors.orange,
    );
  }
}

/// Renders the current pace in min/km.
class PaceMetric extends ConsumerWidget {
  const PaceMetric({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSpeed = ref.watch(
      trackingNotifierProvider.select((state) => state.currentSpeed),
    );
    final pace = PaceCalculator.calculatePaceMinPerKm(currentSpeed);

    return MetricCard(
      label: 'Pace',
      value: PaceCalculator.formatPace(pace),
      unit: '/km',
      icon: Icons.av_timer,
      iconColor: Colors.purple,
    );
  }
}

/// A 2x2 grid displaying the four key real-time metrics.
class WorkoutMetricsGrid extends StatelessWidget {
  const WorkoutMetricsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.3,
      children: const [
        DurationMetric(),
        DistanceMetric(),
        SpeedMetric(),
        PaceMetric(),
      ],
    );
  }
}
