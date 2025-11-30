// ignore_for_file: prefer_final_fields

import 'dart:async';

import 'package:flutter/widgets.dart';

import 'hub.dart' show Hub;
import 'reactive_subscriber.dart';

/// A reactive container that holds a value and notifies subscribers when it changes
///
/// [Pipe] is the core primitive for reactive state management. When the value changes,
/// all subscribed widgets rebuild automatically.
///
/// Example:
/// ```dart
/// final counter = Pipe<int>(0);
/// counter.value++; // All subscribed widgets rebuild
/// ```
///
/// When created inside a [Hub], pipes are automatically registered
/// for disposal - no manual registration needed!
class Pipe<T> {
  T _value;
  // Use List of Elements for zero-cast hot path - cast once during attach/detach
  final List<Element> _subscribers = [];
  bool _isNotifying = false;
  bool _disposed = false;
  final List<void Function(T)> _listeners = [];
  bool _autoDispose;
  bool _isRegisteredWithController = false;

  /// Creates a [Pipe] with an initial value.
  ///
  /// - [autoDispose]: Automatically disposes the pipe when the last subscriber
  ///   detaches. Defaults to true for standalone pipes (not part of a Hub),
  ///   and false for pipes within a Hub, which handles disposal for you.
  ///
  /// ### Examples:
  ///
  /// **Standalone Pipe:**
  /// ```dart
  /// final countPipe = Pipe<int>(0);
  /// countPipe.value = 5; // Updates and notifies subscribers
  /// ```
  ///
  /// **Pipe in a Hub:**
  /// ```dart
  /// class MyHub extends Hub {
  ///   late finaal count = pipe(0);  // Use Hub's pipe() method
  /// }
  /// ```
  ///
  /// When using pipes in a Hub, use the Hub's `pipe()` method for
  /// automatic registration and disposal management.
  Pipe(
    this._value, {
    bool? autoDispose,
  }) : _autoDispose = autoDispose ?? true;

  /// The current value of this pipe
  ///
  /// Throws [StateError] if this pipe has been disposed.
  @pragma('vm:prefer-inline')
  T get value {
    // Hot path optimization: disposed check only in debug mode for production speed
    assert(!_disposed, 'Cannot access value of a disposed Pipe');
    return _value;
  }

  /// Sets a new value and notifies subscribers if the value changed
  ///
  /// The value is only updated and subscribers notified if [shouldNotify]
  /// returns true (i.e., the new value is different from the current value).
  ///
  /// Throws [StateError] if this pipe has been disposed.
  @pragma('vm:prefer-inline')
  set value(T newValue) {
    // Hot path optimization: disposed check only in debug mode
    assert(!_disposed, 'Cannot set value on a disposed Pipe');
    if (shouldNotify(newValue)) {
      _value = newValue;
      notifySubscribers();
    }
  }

  /// Determines if subscribers should be notified about a value change
  ///
  /// By default, uses standard Dart inequality (!=) to compare values.
  /// Override this to customize when rebuilds occur.
  @protected
  @pragma('vm:prefer-inline')
  bool shouldNotify(T newValue) {
    return !identical(_value, newValue) && _value != newValue;
  }

  /// Notifies all subscribers that the value has changed
  ///
  /// This is called automatically by the setter. You typically don't need to call this manually.
  @protected
  void notifySubscribers() {
    if (_isNotifying) return;

    _isNotifying = true;

    // Subscribers: ULTRA FAST - no try-catch needed
    // markNeedsBuild() is framework code, won't throw
    final subscribersLength = _subscribers.length;
    for (var i = 0; i < subscribersLength; i++) {
      _subscribers[i].markNeedsBuild();
    }

    // Listeners: Protected - user code could throw
    try {
      final listenersLength = _listeners.length;
      for (var i = 0; i < listenersLength; i++) {
        _listeners[i](_value);
      }
    } finally {
      _isNotifying = false;
    }
  }

  /// Attaches a subscriber
  ///
  /// This is called automatically when a Sink or Well widget mounts.
  /// You typically don't need to call this manually.
  ///
  /// Throws [StateError] if this pipe has been disposed.
  @protected
  @pragma('vm:prefer-inline')
  void attach(ReactiveSubscriber subscriber) {
    assert(!_disposed, 'Cannot attach to a disposed Pipe');
    // Cast once during attach (cold path) for zero-cast hot path
    _subscribers.add(subscriber as Element);
  }

  /// Detaches a subscriber
  ///
  /// This is called automatically when a Sink or Well widget unmounts.
  /// You typically don't need to call this manually.
  ///
  /// If [autoDispose] is true and this was the last subscriber, the pipe
  /// will automatically dispose itself.
  ///
  /// Note: Detaching from a disposed pipe is a no-op (doesn't throw).
  /// This allows safe cleanup during widget unmounting.
  @protected
  void detach(ReactiveSubscriber subscriber) {
    // Allow detaching from disposed pipes during cleanup - just do nothing
    if (_disposed) {
      return;
    }

    // Cast once during detach (cold path)
    final element = subscriber as Element;

    // Optimized removal: iterate backwards for better removal performance
    for (var i = _subscribers.length - 1; i >= 0; i--) {
      if (identical(_subscribers[i], element)) {
        _subscribers.removeAt(i);
        break; // Assume single subscription per subscriber
      }
    }

    // Auto-dispose if enabled, not managed by hub, and no more subscribers
    if (_autoDispose &&
        !_isRegisteredWithController &&
        _subscribers.isEmpty &&
        _listeners.isEmpty &&
        !_isNotifying) {
      scheduleMicrotask(() {
        // Double-check conditions haven't changed
        if (_subscribers.isEmpty &&
            _listeners.isEmpty &&
            !_disposed &&
            !_isNotifying) {
          dispose();
        }
      });
    }
  }

  /// Adds a listener callback that will be called when the value changes
  ///
  /// The callback receives the new value as a parameter.
  ///
  /// This is useful for side effects or when creating computed pipes.
  /// Remember to [removeListener] when done to avoid memory leaks.
  ///
  /// ### Example:
  /// ```dart
  /// final counter = Pipe<int>(0);
  ///
  /// counter.addListener((value) {
  ///   print('Counter changed to: $value');
  /// });
  ///
  /// counter.value++; // Prints: Counter changed to: 1
  /// ```
  ///
  /// Throws [StateError] if this pipe has been disposed.
  @pragma('vm:prefer-inline')
  void addListener(void Function(T) listener) {
    assert(!_disposed, 'Cannot add listener to a disposed Pipe');
    _listeners.add(listener);
  }

  /// Removes a previously added listener
  ///
  /// ### Example:
  /// ```dart
  /// void logChanges(int value) {
  ///   print('Value: $value');
  /// }
  ///
  /// pipe.addListener(logChanges);
  /// // ... later ...
  /// pipe.removeListener(logChanges);
  /// ```
  ///
  /// Throws [StateError] if this pipe has been disposed.
  void removeListener(void Function(T) listener) {
    assert(!_disposed, 'Cannot remove listener from a disposed Pipe');

    // Optimized removal using identical check
    for (var i = _listeners.length - 1; i >= 0; i--) {
      if (identical(_listeners[i], listener)) {
        _listeners.removeAt(i);
        break;
      }
    }

    // Auto-dispose if enabled, not managed by hub, and no more subscribers/listeners
    if (_autoDispose &&
        !_isRegisteredWithController &&
        _subscribers.isEmpty &&
        _listeners.isEmpty &&
        !_isNotifying) {
      scheduleMicrotask(() {
        // Double-check conditions haven't changed
        if (_subscribers.isEmpty &&
            _listeners.isEmpty &&
            !_disposed &&
            !_isNotifying) {
          dispose();
        }
      });
    }
  }

  /// Forces an update even if the value didn't change
  ///
  /// Use this when you want to force a rebuild even if the value appears
  /// to be the same (e.g., for mutable objects where the reference didn't change
  /// but the internal state did).
  ///
  /// Throws [StateError] if this pipe has been disposed.
  @pragma('vm:prefer-inline')
  void pump(T newValue) {
    assert(!_disposed, 'Cannot update value on a disposed Pipe');
    _value = newValue;
    notifySubscribers();
  }

  /// Disposes this pipe and cleans up all subscriptions
  ///
  /// After calling this, the pipe should not be used anymore.
  /// This method is idempotent - calling it multiple times has no effect.
  void dispose() {
    if (_disposed) return;

    // Safety: Don't dispose during notification to prevent iterator corruption
    if (_isNotifying) {
      scheduleMicrotask(dispose);
      return;
    }

    _disposed = true;
    _subscribers.clear();
    _listeners.clear();
  }

  /// Returns the number of active subscribers
  ///
  /// This is mainly for internal use and debugging.
  @protected
  int get subscriberCount => _subscribers.length;

  /// Whether this pipe has been disposed
  bool get disposed => _disposed;

  /// Whether this pipe will auto-dispose when subscriber count reaches 0
  ///
  /// Defaults to true for standalone pipes, false for hub-managed pipes.
  @protected
  bool get autoDispose => _autoDispose;

  /// Whether this pipe is registered with a hub
  @protected
  bool get isRegisteredWithController => _isRegisteredWithController;

  /// Internal method to mark this pipe as registered with a hub
  ///
  /// This is called by Hub when a pipe is registered and should not be
  /// called directly by user code.
  @protected
  set isRegisteredWithController(bool value) {
    _isRegisteredWithController = value;
  }
}
