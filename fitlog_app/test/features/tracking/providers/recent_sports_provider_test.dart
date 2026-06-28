import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlog_app/features/tracking/models/sport_type.dart';
import 'package:fitlog_app/features/tracking/providers/recent_sports_provider.dart';

void main() {
  group('RecentSportsProvider Unit Tests', () {
    test('recentSportsProvider overrides stream correctly', () async {
      final container = ProviderContainer(
        overrides: [
          recentSportsProvider.overrideWith((ref) => Stream.value([
            SportType.fromId('cycling'),
            SportType.fromId('walking'),
          ])),
        ],
      );
      addTearDown(container.dispose);

      final stream = container.read(recentSportsProvider.stream);
      final value = await stream.first;

      expect(value.length, equals(2));
      expect(value[0].id, equals('cycling'));
      expect(value[1].id, equals('walking'));
    });
  });
}
