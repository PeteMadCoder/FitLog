import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fitlog_app/features/tracking/models/workout.dart';
import 'package:fitlog_app/features/tracking/models/gps_point.dart';
import 'package:fitlog_app/features/tracking/widgets/metric_card.dart';
import 'package:fitlog_app/features/analytics/providers/analytics_providers.dart';
import 'package:fitlog_app/shared/extensions/duration_extensions.dart';
import 'package:fitlog_app/core/utils/pace_calculator.dart';
import 'package:fitlog_app/features/analytics/services/split_calculator.dart';
import 'package:fitlog_app/features/tracking/models/sport_type.dart';

/// A premium screen presenting the post-workout analysis,
/// including a static route map, summary metrics, and interactive charts.
class WorkoutDetailScreen extends ConsumerStatefulWidget {
  final int workoutId;

  const WorkoutDetailScreen({super.key, required this.workoutId});

  @override
  ConsumerState<WorkoutDetailScreen> createState() =>
      _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends ConsumerState<WorkoutDetailScreen> {
  int _selectedChartIndex = 0; // 0 for Elevation, 1 for Speed, 2 for Pace

  @override
  Widget build(BuildContext context) {
    final workoutAsync = ref.watch(workoutDetailProvider(widget.workoutId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Summary'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditNameDialog(context),
            tooltip: 'Edit Name',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteConfirmation(context),
            tooltip: 'Delete Workout',
          ),
        ],
      ),
      body: workoutAsync.when(
        data: (workout) {
          if (workout == null) {
            return const Center(child: Text('Workout not found'));
          }
          return _buildContent(context, workout);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text(
            'Error: $err',
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Workout workout) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final gpsPoints = workout.gpsPoints.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final List<LatLng> routePoints = gpsPoints
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    final sport = SportType.fromId(workout.sportType);
    final startFormatted = _formatDateTime(workout.startTime);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Sport Header / Title card
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: sport.color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  sport.icon,
                  color: sport.color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.name ??
                          '${sport.name.toUpperCase()} WORKOUT',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      startFormatted,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 2. Grid of Summary Metrics
          const Text(
            'PERFORMANCE STATISTICS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          _buildMetricsGrid(workout),
          const SizedBox(height: 32),

          // 3. Static Route Map
          Container(
            height: 240,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: colorScheme.outlineVariant.withOpacity(0.4),
                width: 1.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: routePoints.isNotEmpty
                  ? FlutterMap(
                      options: MapOptions(
                        initialCameraFit: CameraFit.bounds(
                          bounds: LatLngBounds.fromPoints(routePoints),
                          padding: const EdgeInsets.all(32.0),
                        ),
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.madcoder.fitlog.app',
                        ),
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: routePoints,
                              color: colorScheme.primary,
                              strokeWidth: 5.0,
                            ),
                          ],
                        ),
                        MarkerLayer(
                          markers: [
                            // Start marker (Green)
                            Marker(
                              point: routePoints.first,
                              width: 16,
                              height: 16,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            // End marker (Red)
                            Marker(
                              point: routePoints.last,
                              width: 16,
                              height: 16,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Container(
                      color: colorScheme.surfaceVariant.withOpacity(0.3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.map_outlined,
                            size: 48,
                            color: colorScheme.onSurface.withOpacity(0.4),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No GPS route recorded',
                            style: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 32),

          // 4. Interactive Charts Section
          const Text(
            'ACTIVITY ANALYSIS CHARTS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          _buildChartsSection(context, gpsPoints),
          const SizedBox(height: 32),
          const Text(
            'LAP SPLITS (1KM)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          _buildLapsTable(context, gpsPoints),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(Workout workout) {
    final duration = Duration(seconds: workout.durationSeconds.toInt());
    final distanceKm = workout.distanceMeters / 1000.0;

    final averageSpeedKmH = workout.averageSpeed != null
        ? workout.averageSpeed! * 3.6
        : 0.0;
    final maxSpeedKmH = workout.maxSpeed != null
        ? workout.maxSpeed! * 3.6
        : 0.0;

    final pace = PaceCalculator.calculateAveragePaceMinPerKm(
      duration,
      workout.distanceMeters,
    );

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: [
        MetricCard(
          label: 'Distance',
          value: distanceKm.toStringAsFixed(2),
          unit: 'km',
          icon: Icons.directions_run,
          iconColor: Colors.green,
        ),
        MetricCard(
          label: 'Duration',
          value: duration.toHoursMinutesSeconds(),
          icon: Icons.timer_outlined,
          iconColor: Colors.blue,
        ),
        MetricCard(
          label: 'Avg Speed',
          value: averageSpeedKmH.toStringAsFixed(1),
          unit: 'km/h',
          icon: Icons.speed,
          iconColor: Colors.orange,
        ),
        MetricCard(
          label: 'Avg Pace',
          value: PaceCalculator.formatPace(pace),
          unit: '/km',
          icon: Icons.av_timer,
          iconColor: Colors.purple,
        ),
        MetricCard(
          label: 'Max Speed',
          value: maxSpeedKmH.toStringAsFixed(1),
          unit: 'km/h',
          icon: Icons.bolt,
          iconColor: Colors.amber,
        ),
        MetricCard(
          label: 'Elevation Gain',
          value: workout.elevationGain?.toStringAsFixed(0) ?? '0',
          unit: 'm',
          icon: Icons.terrain,
          iconColor: Colors.brown,
        ),
      ],
    );
  }

  Widget _buildChartsSection(BuildContext context, dynamic gpsPointsList) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Safely cast gpsPointsList
    final points = List.from(gpsPointsList);

    if (points.length < 2) {
      return Container(
        padding: const EdgeInsets.all(24.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              Icons.show_chart_outlined,
              size: 40,
              color: colorScheme.onSurface.withOpacity(0.4),
            ),
            const SizedBox(height: 8),
            Text(
              'Not enough telemetry data to draw charts',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.6),
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    // Prepare data spots
    double cumulativeDistance = 0.0;
    final List<FlSpot> elevationSpots = [];
    final List<FlSpot> speedSpots = [];
    final List<FlSpot> paceSpots = [];

    final startTime = points.first.timestamp as DateTime;

    for (int i = 0; i < points.length; i++) {
      final currentPoint = points[i];
      if (i > 0) {
        final prevPoint = points[i - 1];
        cumulativeDistance += _calculateDistance(
          prevPoint.latitude,
          prevPoint.longitude,
          currentPoint.latitude,
          currentPoint.longitude,
        );
      }

      final altitude = currentPoint.altitude ?? 0.0;
      final distanceKm = cumulativeDistance / 1000.0;
      elevationSpots.add(FlSpot(distanceKm, altitude));

      final elapsedMinutes =
          (currentPoint.timestamp as DateTime).difference(startTime).inSeconds /
          60.0;
      final speedKmH = (currentPoint.speed ?? 0.0) * 3.6;
      speedSpots.add(FlSpot(elapsedMinutes, speedKmH));

      final pace =
          PaceCalculator.calculatePaceMinPerKm(currentPoint.speed ?? 0.0) ??
          0.0;
      paceSpots.add(FlSpot(elapsedMinutes, pace));
    }

    // Select active chart parameters
    List<FlSpot> activeSpots;
    Color barColor;
    String bottomUnit;
    String leftUnit;
    String tooltipLabel;

    switch (_selectedChartIndex) {
      case 0:
        activeSpots = elevationSpots;
        barColor = Colors.brown;
        bottomUnit = ' km';
        leftUnit = ' m';
        tooltipLabel = 'Elevation';
        break;
      case 1:
        activeSpots = speedSpots;
        barColor = Colors.orange;
        bottomUnit = ' min';
        leftUnit = ' km/h';
        tooltipLabel = 'Speed';
        break;
      case 2:
      default:
        activeSpots = paceSpots;
        barColor = Colors.purple;
        bottomUnit = ' min';
        leftUnit = ' /km';
        tooltipLabel = 'Pace';
        break;
    }

    if (activeSpots.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate dynamic bounds and intervals
    final minX = activeSpots.map((s) => s.x).reduce(min);
    final maxX = activeSpots.map((s) => s.x).reduce(max);
    final rangeX = maxX - minX;
    final intervalX = rangeX > 0 ? rangeX / 4.0 : 1.0;

    final minY = activeSpots.map((s) => s.y).reduce(min);
    final maxY = activeSpots.map((s) => s.y).reduce(max);
    final rangeY = maxY - minY;

    final paddedMinY = rangeY > 0 ? minY - (rangeY * 0.1) : minY - 10;
    final paddedMaxY = rangeY > 0 ? maxY + (rangeY * 0.1) : maxY + 10;
    final intervalY = rangeY > 0 ? rangeY / 3.0 : 1.0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: colorScheme.outlineVariant.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 24, 20),
        child: Column(
          children: [
            // Chart Selection Control
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                  value: 0,
                  label: Text('Elevation'),
                  icon: Icon(Icons.terrain_outlined, size: 18),
                ),
                ButtonSegment(
                  value: 1,
                  label: Text('Speed'),
                  icon: Icon(Icons.speed_outlined, size: 18),
                ),
                ButtonSegment(
                  value: 2,
                  label: Text('Pace'),
                  icon: Icon(Icons.av_timer_outlined, size: 18),
                ),
              ],
              selected: {_selectedChartIndex},
              onSelectionChanged: (set) {
                setState(() {
                  _selectedChartIndex = set.first;
                });
              },
              showSelectedIcon: false,
              style: const ButtonStyle(visualDensity: VisualDensity.compact),
            ),
            const SizedBox(height: 28),

            // Line Chart View
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  minX: minX,
                  maxX: maxX,
                  minY: paddedMinY,
                  maxY: paddedMaxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: colorScheme.outlineVariant.withOpacity(0.2),
                        strokeWidth: 1.0,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: intervalX,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              '${value.toStringAsFixed(1)}$bottomUnit',
                              style: TextStyle(
                                fontSize: 9,
                                color: colorScheme.onSurface.withOpacity(0.55),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 44,
                        interval: intervalY,
                        getTitlesWidget: (value, meta) {
                          // For pace chart, format clean MM:SS
                          String valueStr;
                          if (_selectedChartIndex == 2) {
                            valueStr = PaceCalculator.formatPace(value);
                          } else {
                            valueStr = value.toStringAsFixed(0);
                          }

                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              '$valueStr$leftUnit',
                              style: TextStyle(
                                fontSize: 9,
                                color: colorScheme.onSurface.withOpacity(0.55),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (spot) =>
                          colorScheme.surfaceContainerHighest,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final xStr = spot.x.toStringAsFixed(2);
                          String yStr;
                          if (_selectedChartIndex == 2) {
                            yStr = PaceCalculator.formatPace(spot.y);
                          } else {
                            yStr = spot.y.toStringAsFixed(1);
                          }

                          return LineTooltipItem(
                            '$tooltipLabel\n$yStr$leftUnit at $xStr$bottomUnit',
                            TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: activeSpots,
                      isCurved: true,
                      barWidth: 3.0,
                      color: barColor,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            barColor.withOpacity(0.24),
                            barColor.withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const r = 6371000.0; // Earth radius in meters
    final dLat = (lat2 - lat1) * pi / 180.0;
    final dLon = (lon2 - lon1) * pi / 180.0;

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180.0) *
            cos(lat2 * pi / 180.0) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  Widget _buildLapsTable(BuildContext context, List<dynamic> gpsPointsList) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final gpsPoints = List<GpsPoint>.from(gpsPointsList);
    final splits = SplitCalculator.calculateSplits(gpsPoints);

    if (splits.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              Icons.format_list_numbered,
              size: 40,
              color: colorScheme.onSurface.withOpacity(0.4),
            ),
            const SizedBox(height: 8),
            Text(
              'No splits recorded',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.6),
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: colorScheme.outlineVariant.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'LAP',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface.withOpacity(0.55),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'DISTANCE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface.withOpacity(0.55),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'TIME',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface.withOpacity(0.55),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'AVG PACE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface.withOpacity(0.55),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: splits.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final split = splits[index];
                final distKm = split.distanceMeters / 1000.0;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 12.0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${split.index}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          '${distKm.toStringAsFixed(2)} km',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          split.duration.toHoursMinutesSeconds(),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          '${PaceCalculator.formatPace(split.averagePaceMinPerKm)}/km',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = monthNames[dt.month - 1];
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    final hourStr = dt.hour.toString().padLeft(2, '0');
    return '$month ${dt.day}, ${dt.year} at $hourStr:$minuteStr';
  }

  void _showEditNameDialog(BuildContext context) {
    final workout = ref.read(workoutDetailProvider(widget.workoutId)).value;
    if (workout == null) return;

    final controller = TextEditingController(text: workout.name);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Workout Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter workout name',
            labelText: 'Name',
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              final newName = controller.text.trim();
              ref
                  .read(workoutEditorProvider.notifier)
                  .updateWorkoutName(widget.workoutId, newName);
              Navigator.pop(ctx);
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Workout?'),
        content: const Text(
          'This will permanently remove this workout and all its data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(workoutEditorProvider.notifier)
                  .deleteWorkout(widget.workoutId);
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Close detail screen
            },
            child: const Text(
              'DELETE',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
