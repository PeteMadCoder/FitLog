import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:isar/isar.dart';
import 'package:fitlog_app/app/app_providers.dart';
import 'package:fitlog_app/features/tracking/models/workout.dart';
import 'package:fitlog_app/features/tracking/models/sport_type.dart';

part 'recent_sports_provider.g.dart';

/// Provider exposing a list of the 5 most recently used unique [SportType]s.
@riverpod
Stream<List<SportType>> recentSports(RecentSportsRef ref) async* {
  final isar = await ref.watch(isarProvider.future);

  final query = isar.workouts
      .filter()
      .isCompletedEqualTo(true)
      .sortByStartTimeDesc();

  yield* query.watch(fireImmediately: true).map((workouts) {
    final uniqueSportIds = <String>{};
    final recent = <SportType>[];
    for (final w in workouts) {
      if (uniqueSportIds.length >= 5) break;
      final sportId = w.sportType;
      if (!uniqueSportIds.contains(sportId)) {
        uniqueSportIds.add(sportId);
        recent.add(SportType.fromId(sportId));
      }
    }
    return recent;
  });
}
