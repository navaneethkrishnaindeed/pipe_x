// ignore_for_file: invalid_use_of_protected_member, prefer_function_declarations_over_variables

import 'package:flutter/foundation.dart';

import 'async_pipe.dart';
import 'async_value.dart';
import 'computed_pipe.dart';
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
  final List<VoidCallback> _hubListeners = [];
  final Map<VoidCallback, Map<Pipe, void Function(dynamic)>> _listenerToPipeCallbacks = {};

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
    assert(
      !pipe.disposed,
      '\n\n'
      ' Cannot register a disposed Pipe to Hub!\n\n'
      ' The pipe you are trying to register has already been disposed.\n'
      ' Make sure you are not registering a pipe that has been disposed.\n'
      'Tip: Create a new pipe instance or ensure the pipe is alive before registering.\n',
    );
    final pipeKey = key ?? pipe.hashCode.toString();
    _pipes[pipeKey] = pipe;
    // Mark the pipe as registered with a controller
    pipe.isRegisteredWithController = true;

    // Attach hub listeners to this pipe
    for (final hubCallback in _hubListeners) {
      final pipeListener = (_) => hubCallback();
      _listenerToPipeCallbacks[hubCallback]![pipe] = pipeListener;
      pipe.addListener(pipeListener);
    }

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
    return registerPipe(newPipe, pipeKey);
  }

  /// Creates and registers a [ComputedPipe] with dependencies
  ///
  /// A computed pipe derives its value from other pipes and automatically
  /// updates when any dependency changes. This is more efficient than getters
  /// because it caches the computed value and can be subscribed to.
  ///
  /// ```dart
  /// class CartHub extends Hub {
  ///   late final items = pipe(<CartItem>[]);
  ///   late final taxRate = pipe(0.08);
  ///
  ///   // Computed pipe - updates when items or taxRate change
  ///   late final total = computed(
  ///     dependencies: [items, taxRate],
  ///     compute: () {
  ///       final subtotal = items.value.fold(0.0, (sum, i) => sum + i.price);
  ///       return subtotal * (1 + taxRate.value);
  ///     },
  ///   );
  /// }
  /// ```
  ///
  /// ### When to use computed vs getters:
  ///
  /// **Use `computed()`** when:
  /// - You need to subscribe to the derived value with Sink/Well
  /// - The computation is expensive and should be cached
  /// - You want fine-grained reactivity (only rebuild when result changes)
  ///
  /// **Use getters** when:
  /// - The computation is trivial (e.g., `bool get isEmpty => items.value.isEmpty`)
  /// - You don't need to subscribe to it directly
  @protected
  ComputedPipe<T> computed<T>({
    required List<Pipe> dependencies,
    required T Function() compute,
    String? key,
  }) {
    checkNotDisposed();
    final computedPipe = ComputedPipe<T>(
      dependencies: dependencies,
      compute: compute,
    );
    final pipeKey = key ?? '_computed_${_autoRegisterCounter++}';
    return registerPipe(computedPipe, pipeKey);
  }

  /// Creates and registers an [AsyncPipe] for async operations
  ///
  /// An async pipe wraps a [Future] and exposes loading/data/error states
  /// via [AsyncValue]. This is perfect for API calls and async operations.
  ///
  /// ```dart
  /// class UserHub extends Hub {
  ///   late final user = asyncPipe<User>(() => api.fetchUser());
  ///   late final posts = asyncPipe<List<Post>>(
  ///     () => api.fetchPosts(),
  ///     immediate: false, // Don't fetch immediately
  ///   );
  ///
  ///   void loadPosts() => posts.refresh();
  /// }
  /// ```
  ///
  /// Use in widgets with pattern matching:
  /// ```dart
  /// Sink<AsyncValue<User>>(
  ///   pipe: hub.user,
  ///   builder: (context, state) => state.when(
  ///     loading: () => CircularProgressIndicator(),
  ///     data: (user) => Text(user.name),
  ///     onError: (e, _) => Text('Error: $e'),
  ///   ),
  /// )
  /// ```
  ///
  /// - [futureFactory]: Function that returns the Future to execute
  /// - [immediate]: If true (default), starts loading immediately
  /// - [key]: Optional key for the pipe registration
  @protected
  AsyncPipe<T> asyncPipe<T>(
    Future<T> Function() futureFactory, {
    bool immediate = true,
    String? key,
  }) {
    checkNotDisposed();
    final async = AsyncPipe<T>(futureFactory, immediate: immediate);
    final pipeKey = key ?? '_async_${_autoRegisterCounter++}';
    return registerPipe(async, pipeKey);
  }

  /// Creates and registers an [AsyncPipe] with an initial value
  ///
  /// The pipe starts with [AsyncData] containing the initial value.
  /// The future can be executed later with [AsyncPipe.refresh].
  ///
  /// ```dart
  /// class SettingsHub extends Hub {
  ///   late final theme = asyncPipeWithInitial(
  ///     ThemeMode.system,
  ///     () => storage.loadTheme(),
  ///   );
  /// }
  /// ```
  @protected
  AsyncPipe<T> asyncPipeWithInitial<T>(
    T initialValue,
    Future<T> Function() futureFactory, {
    String? key,
  }) {
    checkNotDisposed();
    final async = AsyncPipe<T>.withInitialValue(initialValue, futureFactory);
    final pipeKey = key ?? '_async_${_autoRegisterCounter++}';
    return registerPipe(async, pipeKey);
  }

  /// Gets the total number of active subscribers across all pipes
  ///
  /// This is useful for debugging and understanding which parts of your
  /// UI are subscribed to this hub's state.
  int get subscriberCount {
    return _pipes.values.fold(0, (sum, pipe) => sum + pipe.subscriberCount);
  }

  /// Listens to all pipe changes in this hub
  ///
  /// The callback is triggered whenever any pipe value updates.
  /// Returns a dispose function to remove the listener.
  ///
  /// Example:
  /// ```dart
  /// final hub = MyHub();
  /// final removeListener = hub.listen(() {
  ///   print('Something changed!');
  /// });
  ///
  /// // Later, to clean up:
  /// removeListener();
  /// ```
  VoidCallback addListener(VoidCallback callback) {
    checkNotDisposed();
    _hubListeners.add(callback);

    // Initialize tracking map for this callback
    final pipeListeners = <Pipe, void Function(dynamic)>{};
    _listenerToPipeCallbacks[callback] = pipeListeners;

    // Attach callback to all existing pipes
    for (final pipe in _pipes.values) {
      final listener = (_) => callback();
      pipeListeners[pipe] = listener;
      pipe.addListener(listener);
    }

    // Return dispose function
    return () {
      _hubListeners.remove(callback);
      // Remove all pipe-specific listeners
      final listeners = _listenerToPipeCallbacks.remove(callback);
      if (listeners != null) {
        for (final entry in listeners.entries) {
          if (!entry.key.disposed) {
            entry.key.removeListener(entry.value);
          }
        }
      }
    };
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

    // Clear hub listeners
    _hubListeners.clear();
    _listenerToPipeCallbacks.clear();

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
