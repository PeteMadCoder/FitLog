/// A generic Result class to handle operations that can either succeed or fail
/// without throwing exceptions.
///
/// Uses Dart's sealed class mechanism to ensure pattern matching completeness.
sealed class Result<S, F> {
  const Result();

  /// Returns true if this is a [Success].
  bool get isSuccess => this is Success<S, F>;

  /// Returns true if this is a [Failure].
  bool get isFailure => this is Failure<S, F>;

  /// Returns the success value, or null if this is a failure.
  S? get successOrNullValue => switch (this) {
    Success(value: final v) => v,
    Failure() => null,
  };

  /// Returns the failure value, or null if this is a success.
  F? get failureOrNullValue => switch (this) {
    Success() => null,
    Failure(error: final e) => e,
  };

  /// Transforms the success value using [fn] if this is a [Success].
  Result<T, F> map<T>(T Function(S value) fn) {
    return switch (this) {
      Success(value: final v) => Success(fn(v)),
      Failure(error: final e) => Failure(e),
    };
  }

  /// Transforms the failure value using [fn] if this is a [Failure].
  Result<S, T> mapFailure<T>(T Function(F error) fn) {
    return switch (this) {
      Success(value: final v) => Success(v),
      Failure(error: final e) => Failure(fn(e)),
    };
  }

  /// Executes [onSuccess] or [onFailure] depending on the type of result.
  R fold<R>(R Function(S value) onSuccess, R Function(F error) onFailure) {
    return switch (this) {
      Success(value: final v) => onSuccess(v),
      Failure(error: final e) => onFailure(e),
    };
  }
}

/// Represents a successful operation containing a [value] of type [S].
class Success<S, F> extends Result<S, F> {
  final S value;
  const Success(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Success<S, F> && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success($value)';
}

/// Represents a failed operation containing an [error] of type [F].
class Failure<S, F> extends Result<S, F> {
  final F error;
  const Failure(this.error);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Failure<S, F> && other.error == error);

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Failure($error)';
}
