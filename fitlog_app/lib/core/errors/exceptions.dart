/// Base class for all domain-specific exceptions in FitLog.
abstract class AppException implements Exception {
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  const AppException(this.message, [this.error, this.stackTrace]);

  @override
  String toString() =>
      '$runtimeType: $message${error != null ? " ($error)" : ""}';
}

/// Thrown when an error occurs during database operations (Isar).
class DatabaseException extends AppException {
  const DatabaseException(super.message, [super.error, super.stackTrace]);
}

/// Thrown when location/GPS retrieval fails or is unsupported.
class LocationException extends AppException {
  const LocationException(super.message, [super.error, super.stackTrace]);
}

/// Thrown when connecting to or communicating with BLE sensors fails.
class SensorException extends AppException {
  const SensorException(super.message, [super.error, super.stackTrace]);
}

/// Thrown when the user denies essential device permissions (e.g., GPS, Bluetooth).
class PermissionException extends AppException {
  const PermissionException(super.message, [super.error, super.stackTrace]);
}

/// Thrown when parsing, importing, or exporting GPX/TCX files fails.
class BackupException extends AppException {
  const BackupException(super.message, [super.error, super.stackTrace]);
}

/// Catch-all exception for other unexpected system errors.
class UnknownException extends AppException {
  const UnknownException(super.message, [super.error, super.stackTrace]);
}
