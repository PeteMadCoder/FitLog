import 'package:flutter_test/flutter_test.dart';
import 'package:fitlog_app/core/errors/result.dart';
import 'package:fitlog_app/core/errors/exceptions.dart';

void main() {
  group('Result tests', () {
    test('Success result has expected properties', () {
      const Result<int, String> result = Success(42);

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.successOrNullValue, equals(42));
      expect(result.failureOrNullValue, isNull);
    });

    test('Failure result has expected properties', () {
      const Result<int, String> result = Failure('Error occurred');

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.successOrNullValue, isNull);
      expect(result.failureOrNullValue, equals('Error occurred'));
    });

    test('fold correctly evaluates Success', () {
      const Result<int, String> result = Success(42);
      final value = result.fold(
        (val) => val * 2,
        (err) => 0,
      );
      expect(value, equals(84));
    });

    test('fold correctly evaluates Failure', () {
      const Result<int, String> result = Failure('Error');
      final value = result.fold(
        (val) => val * 2,
        (err) => 999,
      );
      expect(value, equals(999));
    });

    test('map transforms success value and leaves failure intact', () {
      const Result<int, String> success = Success(10);
      final mappedSuccess = success.map((v) => v.toString());
      expect(mappedSuccess, equals(const Success<String, String>('10')));

      const Result<int, String> failure = Failure('Failed');
      final mappedFailure = failure.map((v) => v.toString());
      expect(mappedFailure, equals(const Failure<String, String>('Failed')));
    });

    test('mapFailure transforms failure value and leaves success intact', () {
      const Result<int, String> success = Success(10);
      final mappedSuccess = success.mapFailure((e) => Exception(e));
      expect(mappedSuccess.successOrNullValue, equals(10));

      const Result<int, String> failure = Failure('Failed');
      final mappedFailure = failure.mapFailure((e) => '$e modified');
      expect(mappedFailure, equals(const Failure<int, String>('Failed modified')));
    });

    test('equality and toString override work correctly', () {
      const success1 = Success<int, String>(5);
      const success2 = Success<int, String>(5);
      const success3 = Success<int, String>(6);

      expect(success1, equals(success2));
      expect(success1.hashCode, equals(success2.hashCode));
      expect(success1, isNot(equals(success3)));
      expect(success1.toString(), equals('Success(5)'));

      const failure1 = Failure<int, String>('error');
      const failure2 = Failure<int, String>('error');
      const failure3 = Failure<int, String>('different error');

      expect(failure1, equals(failure2));
      expect(failure1.hashCode, equals(failure2.hashCode));
      expect(failure1, isNot(equals(failure3)));
      expect(failure1.toString(), equals('Failure(error)'));
    });
  });

  group('AppException tests', () {
    test('AppException and subclasses capture fields correctly', () {
      final dbException = DatabaseException('DB Failed', 'Unique constraint');
      expect(dbException.message, equals('DB Failed'));
      expect(dbException.error, equals('Unique constraint'));
      expect(dbException.toString(), contains('DatabaseException: DB Failed (Unique constraint)'));

      final locationException = LocationException('GPS Lost');
      expect(locationException.message, equals('GPS Lost'));
      expect(locationException.toString(), equals('LocationException: GPS Lost'));

      final sensorException = SensorException('BLE disconnected');
      expect(sensorException.toString(), equals('SensorException: BLE disconnected'));

      final permissionException = PermissionException('Permission denied');
      expect(permissionException.toString(), equals('PermissionException: Permission denied'));

      final backupException = BackupException('GPX Parse Error');
      expect(backupException.toString(), equals('BackupException: GPX Parse Error'));

      final unknownException = UnknownException('Something failed');
      expect(unknownException.toString(), equals('UnknownException: Something failed'));
    });
  });
}
