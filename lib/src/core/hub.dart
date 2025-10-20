import 'package:flutter/foundation.dart';

import 'pipe.dart';

/// 🌿 Reactive hub that manages state with automatic disposal
///
/// [Hub] provides lifecycle management and reactive state management
/// for [Pipe] instances. Pipes created in the hub are automatically
/// registered and disposed - no manual registration needed!
///
/// Example:
/// ```dart
/// class CounterHub extends Hub {
///   // ✨ Automatic registration - just create the Pipe!
///   late final count = Pipe(0);
///   late final name = Pipe('John');
///   late final user = Pipe(User(name: 'Jane', age: 25));
///
///   // Use getters for derived/computed values
///   bool get isEven => count.value % 2 == 0;
///   String get displayText => 'Count: ${count.value} (${isEven ? "Even" : "Odd"})';
///
///   // No need for checkNotDisposed()! Pipe checks automatically
///   void increment() => count.value++;
/// }
/// ```
abstract class Hub {
  bool _disposed = false;
  final Map<String, Pipe> _pipes = {};
  int _autoRegisterCounter = 0;

  /// Stack of hubs currently being constructed (for auto-registration)
  static final List<Hub> _constructionStack = [];

  /// Creates a hub with auto-registration support for pipes
  Hub() {
    // Push this hub onto the stack during construction
    _constructionStack.add(this);
    // Subclass constructor runs here
    // late final fields in the subclass will be initialized when first accessed
    // and will find this hub in the stack
  }

  /// Internal: Completes hub construction
  ///
  /// This removes the hub from the construction stack so that
  /// standalone pipes created afterwards won't be auto-registered.
  ///
  /// Called automatically by HubProvider. DO NOT call manually.
  void completeConstruction() {
    _constructionStack.remove(this);
  }

  /// Gets the hub currently being constructed, if any (used internally by Pipe)
  static Hub? get current =>
      _constructionStack.isEmpty ? null : _constructionStack.last;

  /// Internal method for automatic pipe registration
  void autoRegisterPipe(Pipe pipe) {
    if (_disposed) {
      throw StateError('Cannot register pipe on disposed hub');
    }
    final key = '_auto_${_autoRegisterCounter++}';
    _pipes[key] = pipe;
  }

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
    return pipe;
  }

  /// Creates and registers a new [Pipe] with the given initial value
  ///
  /// This is a convenience method that combines Pipe creation and registration.
  /// Use this to reduce boilerplate:
  ///
  /// ```dart
  /// class MyHub extends Hub {
  ///   late final Pipe<int> count = pipe(0);
  ///   late final Pipe<String> name = pipe('Hello');
  /// }
  /// ```
  @protected
  Pipe<T> pipe<T>(
    T initialValue, {
    String? key,
  }) {
    checkNotDisposed();
    final newPipe = Pipe<T>(initialValue);
    return registerPipe(newPipe, key);
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
