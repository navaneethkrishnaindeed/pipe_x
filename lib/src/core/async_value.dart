/// Represents the state of an asynchronous operation
///
/// [AsyncValue] is a sealed class with three possible states:
/// - [AsyncLoading]: Operation is in progress
/// - [AsyncData]: Operation completed successfully with data
/// - [AsyncError]: Operation failed with an error
///
/// Example:
/// ```dart
/// final asyncValue = AsyncData(42);
///
/// // Pattern matching
/// switch (asyncValue) {
///   case AsyncLoading():
///     print('Loading...');
///   case AsyncData(:final value):
///     print('Data: $value');
///   case AsyncError(:final error):
///     print('Error: $error');
/// }
///
/// // Or use the when method
/// asyncValue.when(
///   loading: () => CircularProgressIndicator(),
///   data: (value) => Text('$value'),
///   onError: (error, stack) => Text('Error: $error'),
/// );
/// ```
sealed class AsyncValue<T> {
  const AsyncValue();

  /// Whether this value is currently loading
  bool get isLoading => this is AsyncLoading<T>;

  /// Whether this value has data
  bool get hasData => this is AsyncData<T>;

  /// Whether this value has an error
  bool get hasError => this is AsyncError<T>;

  /// The data if available, null otherwise
  T? get valueOrNull {
    final self = this;
    if (self is AsyncData<T>) {
      return self.value;
    }
    return null;
  }

  /// The error if available, null otherwise
  Object? get errorOrNull {
    final self = this;
    if (self is AsyncError<T>) {
      return self.error;
    }
    return null;
  }

  /// The stack trace if available, null otherwise
  StackTrace? get stackTraceOrNull {
    final self = this;
    if (self is AsyncError<T>) {
      return self.stackTrace;
    }
    return null;
  }

  /// Pattern matches on the current state
  ///
  /// All callbacks are required. Use [maybeWhen] for optional callbacks.
  ///
  /// Note: [AsyncRefreshing] is treated as loading state. Use [valueOrNull]
  /// to access previous data during refresh if needed.
  R when<R>({
    required R Function() loading,
    required R Function(T value) data,
    required R Function(Object error, StackTrace? stackTrace) onError,
  }) {
    final self = this;
    return switch (self) {
      AsyncLoading() || AsyncRefreshing() => loading(),
      AsyncData(:final value) => data(value),
      AsyncError(:final error, :final stackTrace) => onError(error, stackTrace),
    };
  }

  /// Pattern matches with optional callbacks and a required fallback
  R maybeWhen<R>({
    R Function()? loading,
    R Function(T value)? data,
    R Function(Object error, StackTrace? stackTrace)? onError,
    required R Function() orElse,
  }) {
    final self = this;
    return switch (self) {
      AsyncLoading() || AsyncRefreshing() => loading != null ? loading() : orElse(),
      AsyncData(:final value) => data != null ? data(value) : orElse(),
      AsyncError(:final error, :final stackTrace) => onError != null ? onError(error, stackTrace) : orElse(),
    };
  }

  /// Maps the data value if present
  AsyncValue<R> map<R>(R Function(T value) mapper) {
    final self = this;
    return switch (self) {
      AsyncLoading() => AsyncLoading<R>(),
      AsyncRefreshing(:final previousValue) => AsyncRefreshing(mapper(previousValue)),
      AsyncData(:final value) => AsyncData(mapper(value)),
      AsyncError(:final error, :final stackTrace) => AsyncError(error, stackTrace),
    };
  }

  /// Returns the value or throws if loading/error
  ///
  /// For [AsyncRefreshing], returns the previous value.
  T get requireValue {
    final self = this;
    if (self is AsyncData<T>) {
      return self.value;
    }
    if (self is AsyncRefreshing<T>) {
      return self.previousValue;
    }
    if (self is AsyncError<T>) {
      throw self.error;
    }
    throw StateError('Cannot get value while loading');
  }

  @override
  String toString() {
    final self = this;
    return switch (self) {
      AsyncLoading() => 'AsyncLoading()',
      AsyncRefreshing(:final previousValue) => 'AsyncRefreshing($previousValue)',
      AsyncData(:final value) => 'AsyncData($value)',
      AsyncError(:final error) => 'AsyncError($error)',
    };
  }
}

/// Represents a loading state
final class AsyncLoading<T> extends AsyncValue<T> {
  const AsyncLoading();

  @override
  bool operator ==(Object other) => identical(this, other) || other is AsyncLoading<T>;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Represents a successful state with data
final class AsyncData<T> extends AsyncValue<T> {
  /// The data value
  final T value;

  const AsyncData(this.value);

  @override
  bool operator ==(Object other) => identical(this, other) || (other is AsyncData<T> && other.value == value);

  @override
  int get hashCode => value.hashCode;
}

/// Represents an error state
final class AsyncError<T> extends AsyncValue<T> {
  /// The error that occurred
  final Object error;

  /// The stack trace if available
  final StackTrace? stackTrace;

  const AsyncError(this.error, [this.stackTrace]);

  @override
  bool operator ==(Object other) => identical(this, other) || (other is AsyncError<T> && other.error == error);

  @override
  int get hashCode => error.hashCode;
}

/// Represents a refreshing state with previous data available
///
/// This is a special loading state that preserves the previous value,
/// allowing UIs to show stale data while refreshing.
final class AsyncRefreshing<T> extends AsyncValue<T> {
  /// The previous data value
  final T previousValue;

  const AsyncRefreshing(this.previousValue);

  @override
  bool get isLoading => true;

  @override
  bool get hasData => true;

  @override
  T? get valueOrNull => previousValue;

  @override
  bool operator ==(Object other) => identical(this, other) || (other is AsyncRefreshing<T> && other.previousValue == previousValue);

  @override
  int get hashCode => previousValue.hashCode;

  @override
  String toString() => 'AsyncRefreshing($previousValue)';
}
