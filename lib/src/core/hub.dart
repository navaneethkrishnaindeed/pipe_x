import 'package:flutter/foundation.dart';

import 'pipe.dart';

/// Reactive hub that manages state with automatic disposal
///
/// [Hub] provides lifecycle management and reactive state management
/// for [Pipe] instances. Use the [pipe] method to create pipes that are
/// automatically registered and disposed with the hub.
///
/// Example:
/// ```dart
/// class CounterHub extends Hub {
///   // Use pipe() method to create and register pipes
///   late final count = pipe(0);
///   late final name = pipe('John');
///   late final user = pipe(User(name: 'Jane', age: 25));
///
///   // Use getters for derived/computed values
///   bool get isEven => count.value % 2 == 0;
///   String get displayText => 'Count: ${count.value} (${isEven ? "Even" : "Odd"})';
///
///   void increment() => count.value++;
/// }
/// ```
abstract class Hub {
  bool _disposed = false;
  final Map<String, Pipe> _pipes = {};
  int _autoRegisterCounter = 0;

  /// Creates a hub
  Hub();

  /// Whether this hub has been disposed
  bool get disposed => _disposed;

  /// Registers a pipe for automatic disposal
  ///
  /// When this hub is disposed, all registered pipes will be
  /// disposed automatically. You can optionally provide a [key] for the
  /// pipe, otherwise its hash code will be used.
  ///
  /// Returns the same pipe instance that was passed in, for convenience.
  @protected
  T registerPipe<T extends Pipe>(T pipe, [String? key]) {
    checkNotDisposed();
    final pipeKey = key ?? pipe.hashCode.toString();
    _pipes[pipeKey] = pipe;
    // Mark the pipe as registered with a controller
    pipe.isRegisteredWithController = true;
    return pipe;
  }

  /// Creates and registers a new [Pipe] with the given initial value
  ///
  /// This is the recommended way to create pipes in a Hub.
  /// The pipe is automatically registered for disposal when the hub is disposed.
  ///
  /// ```dart
  /// class MyHub extends Hub {
  ///   late final count = pipe(0);
  ///   late final name = pipe('Hello');
  /// }
  /// ```
  @protected
  Pipe<T> pipe<T>(
    T initialValue, {
    String? key,
  }) {
    checkNotDisposed();
    final newPipe = Pipe<T>(initialValue, autoDispose: false);
    final pipeKey = key ?? '_auto_${_autoRegisterCounter++}';
    _pipes[pipeKey] = newPipe;
    // Mark the pipe as registered with a controller
    newPipe.isRegisteredWithController = true;
    return newPipe;
  }

  /// Gets the total number of active subscribers across all pipes
  ///
  /// This is useful for debugging and understanding which parts of your
  /// UI are subscribed to this hub's state.
  int get subscriberCount {
    return _pipes.values.fold(0, (sum, pipe) => sum + pipe.subscriberCount);
  }

  /// Override this method to clean up resources when the hub is disposed
  ///
  /// This is called automatically when [dispose] is called.
  @protected
  void onDispose() {}

  /// Disposes this hub and cleans up resources
  ///
  /// After calling this, the hub should not be used anymore.
  /// This method is idempotent - calling it multiple times has no effect.
  void dispose() {
    if (_disposed) return;
    _disposed = true;

    // Dispose all registered pipes
    for (final pipe in _pipes.values) {
      pipe.dispose();
    }
    _pipes.clear();

    onDispose();
  }

  /// Throws a [StateError] if this hub has been disposed
  ///
  /// Note: If you're using [Pipe] objects, they automatically check
  /// for disposal when you set their values, so you don't need to call
  /// this manually. This is mainly useful for non-Pipe operations.
  @protected
  void checkNotDisposed() {
    if (_disposed) {
      throw StateError('Hub is already disposed');
    }
  }
}
