// ignore_for_file: invalid_use_of_protected_member

import 'dart:async';

import 'async_value.dart';
import 'pipe.dart';

/// A reactive pipe for handling asynchronous operations
///
/// [AsyncPipe] wraps a [Future] and exposes its state as an [AsyncValue],
/// which can be loading, data, or error. This makes it easy to build UIs
/// that respond to async state changes.
///
/// Example:
/// ```dart
/// class UserHub extends Hub {
///   late final user = asyncPipe<User>(
///     () => api.fetchUser(),
///   );
///
///   // Refresh the data
///   void refresh() => user.refresh();
/// }
///
/// // In your widget
/// Sink<AsyncValue<User>>(
///   pipe: hub.user,
///   builder: (context, state) => state.when(
///     loading: () => CircularProgressIndicator(),
///     data: (user) => Text(user.name),
///     onError: (e, _) => Text('Error: $e'),
///   ),
/// )
/// ```
class AsyncPipe<T> extends Pipe<AsyncValue<T>> {
  final Future<T> Function() _futureFactory;
  Future<T>? _currentFuture;
  bool _isCancelled = false;

  /// Creates an async pipe with a future factory
  ///
  /// The [futureFactory] is called immediately to start loading data.
  /// Use [refresh] to re-fetch the data.
  ///
  /// - [immediate]: If true (default), starts loading immediately.
  ///   Set to false to delay loading until [refresh] is called.
  ///
  /// ### Example:
  /// ```dart
  /// // Loads immediately
  /// final users = AsyncPipe(() => api.fetchUsers());
  ///
  /// // Loads on demand
  /// final users = AsyncPipe(
  ///   () => api.fetchUsers(),
  ///   immediate: false,
  /// );
  /// users.refresh(); // Start loading
  /// ```
  AsyncPipe(
    Future<T> Function() futureFactory, {
    bool immediate = true,
  })  : _futureFactory = futureFactory,
        super(const AsyncLoading(), autoDispose: false) {
    if (immediate) {
      _execute();
    }
  }

  /// Creates an async pipe with an initial value
  ///
  /// The pipe starts with [AsyncData] containing the initial value.
  /// The [futureFactory] can be called later with [refresh].
  ///
  /// ### Example:
  /// ```dart
  /// final counter = AsyncPipe.withInitialValue(
  ///   0,
  ///   () => api.fetchLatestCount(),
  /// );
  /// // Starts with AsyncData(0)
  /// // Call refresh() to fetch from API
  /// ```
  AsyncPipe.withInitialValue(
    T initialValue,
    Future<T> Function() futureFactory,
  )   : _futureFactory = futureFactory,
        super(AsyncData(initialValue), autoDispose: false);

  /// Executes the future and updates state
  Future<void> _execute() async {
    if (disposed) return;

    // Set loading state (preserve previous data if available)
    final previousValue = value.valueOrNull;
    if (previousValue == null) {
      pump(const AsyncLoading());
    } else {
      // Keep showing previous data while refreshing
      pump(AsyncRefreshing(previousValue));
    }

    _isCancelled = false;

    try {
      _currentFuture = _futureFactory();
      final result = await _currentFuture!;

      // Check if cancelled or disposed before updating
      if (_isCancelled || disposed) return;

      pump(AsyncData(result));
    } catch (e, stackTrace) {
      // Check if cancelled or disposed before updating
      if (_isCancelled || disposed) return;

      pump(AsyncError(e, stackTrace));
    }
  }

  /// Refreshes the async data by re-executing the future
  ///
  /// If a fetch is already in progress, it will be cancelled and
  /// a new one will start.
  ///
  /// Returns a [Future] that completes when the refresh is done.
  Future<void> refresh() async {
    _isCancelled = true; // Cancel any in-flight request
    await _execute();
  }

  /// Resets to loading state and fetches fresh data
  ///
  /// Unlike [refresh], this clears any existing data before loading.
  Future<void> reset() async {
    _isCancelled = true;
    pump(const AsyncLoading());
    await _execute();
  }

  /// Manually sets the data value
  ///
  /// This is useful for optimistic updates.
  ///
  /// ### Example:
  /// ```dart
  /// // Optimistic update
  /// final oldValue = hub.user.value.valueOrNull;
  /// hub.user.setData(updatedUser);
  /// try {
  ///   await api.updateUser(updatedUser);
  /// } catch (e) {
  ///   // Rollback on error
  ///   if (oldValue != null) hub.user.setData(oldValue);
  /// }
  /// ```
  void setData(T data) {
    pump(AsyncData(data));
  }

  /// Manually sets an error state
  void setError(Object error, [StackTrace? stackTrace]) {
    pump(AsyncError(error, stackTrace));
  }

  /// Manually sets loading state
  void setLoading() {
    pump(const AsyncLoading());
  }

  /// Whether the pipe is currently loading (initial or refreshing)
  bool get isLoading => value.isLoading || value is AsyncRefreshing<T>;

  /// Whether the pipe has successfully loaded data
  bool get hasData => value.hasData;

  /// Whether the pipe has an error
  bool get hasError => value.hasError;

  /// The current data value, or null if loading/error
  T? get dataOrNull => value.valueOrNull;

  /// The current error, or null if loading/data
  Object? get errorOrNull => value.errorOrNull;

  /// Setting value directly is not recommended for AsyncPipe
  ///
  /// Use [setData], [setError], [setLoading], or [refresh] instead.
  @override
  set value(AsyncValue<T> newValue) {
    pump(newValue);
  }

  @override
  void dispose() {
    _isCancelled = true;
    _currentFuture = null;
    super.dispose();
  }
}
