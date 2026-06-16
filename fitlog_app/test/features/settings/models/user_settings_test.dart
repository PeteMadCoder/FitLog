import 'package:flutter_test/flutter_test.dart';
import 'package:fitlog_app/features/settings/models/user_settings.dart';

void main() {
  group('UserSettings Model Tests', () {
    test('default constructor sets all properties to null', () {
      final settings = UserSettings();
      expect(settings.gender, isNull);
      expect(settings.height, isNull);
      expect(settings.weight, isNull);
    });

    test('parameterized constructor sets properties correctly', () {
      final settings = UserSettings(
        gender: 'Female',
        height: 168.5,
        weight: 62.0,
      );
      expect(settings.gender, equals('Female'));
      expect(settings.height, equals(168.5));
      expect(settings.weight, equals(62.0));
    });

    test('copyWith updates specified fields only', () {
      final settings = UserSettings(
        gender: 'Male',
        height: 175.0,
        weight: 70.0,
      );

      final updated = settings.copyWith(weight: 75.0);
      
      expect(updated.gender, equals('Male'));
      expect(updated.height, equals(175.0));
      expect(updated.weight, equals(75.0));
    });

    test('toJson and fromJson work correctly', () {
      final settings = UserSettings(
        gender: 'Other',
        height: 180.0,
        weight: 85.0,
      );

      final json = settings.toJson();
      expect(json['gender'], equals('Other'));
      expect(json['height'], equals(180.0));
      expect(json['weight'], equals(85.0));

      final restored = UserSettings.fromJson(json);
      expect(restored.gender, equals('Other'));
      expect(restored.height, equals(180.0));
      expect(restored.weight, equals(85.0));
    });
  });
}
