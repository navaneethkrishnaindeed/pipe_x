import 'dart:async';

import 'package:flutter/widgets.dart';

import 'hub.dart' show Hub;
import 'reactive_subscriber.dart';

/// 🌿 A reactive container that holds a value and notifies subscribers when it changes
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
  final Set<ReactiveSubscriber> _subscribers = {};
  bool _isNotifying = false;
  bool _disposed = false;
  final List<VoidCallback> _listeners = [];
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
  ///   late final count = Pipe<int>(0);
  /// }
  /// ```
  ///
  /// When created inside a [Hub] constructor, the pipe is automatically
  /// registered for disposal, eliminating the need for manual registration.
  Pipe(
    this._value, {
    bool? autoDispose,
  }) : _autoDispose = autoDispose ?? true {
    // Default to auto-dispose for safety
    // Auto-register with hub if we're in a hub context
    _autoRegisterIfNeeded(this);
  }

  /// Internal method to auto-register this pipe with current hub
  static void _autoRegisterIfNeeded(Pipe pipe) {
    final hub = Hub.current;
    if (hub != null) {
      hub.autoRegisterPipe(pipe);
      pipe._isRegisteredWithController = true;
      // Disable auto-dispose for hub-managed pipes
      // They'll be disposed by the hub
      pipe._autoDispose = false;
    }
  }

  /// The current value of this pipe
  ///
  /// Throws [StateError] if this pipe has been disposed.
  T get value {
    if (_disposed) {
      throw StateError('Cannot access value of a disposed Pipe');
    }
    return _value;
  }

  /// Sets a new value and notifies subscribers if the value changed
  ///
  /// The value is only updated and subscribers notified if [shouldNotify]
  /// returns true (i.e., the new value is different from the current value).
  ///
  /// Throws [StateError] if this pipe has been disposed.
  set value(T newValue) {
    if (_disposed) {
      throw StateError('Cannot set value on a disposed Pipe');
    }
    if (shouldNotify(newValue)) {
      _value = newValue;
      notifySubscribers();
    }
  }

  /// Determines if subscribers should be notified about a value change
  ///
  /// By default, uses standard Dart inequality (!=) to compare values.
  /// Override this to customize when rebuilds occur.
  bool shouldNotify(T newValue) {
    return _value != newValue;
  }

  /// Notifies all subscribers that the value has changed
  ///
  /// This is called automatically by the setter. You typically don't need to call this manually.
  void notifySubscribers() {
    if (_isNotifying) return;

    _isNotifying = true;
    try {
      // Create a copy to avoid concurrent modification
      final subscribersCopy = List.of(_subscribers);
      for (final subscriber in subscribersCopy) {
        if (subscriber.mounted) {
          final element = subscriber as Element;
          if (element.mounted) {
            element.markNeedsBuild();
          }
        }
      }

      // Notify additional listeners
      final listenersCopy = List.of(_listeners);
      for (final listener in listenersCopy) {
        listener();
      }
    } finally {
      _isNotifying = false;
    }
  }

  /// Updates the internal value and notifies subscribers (for subclasses)
  ///
  /// This is used by subclasses to update the value
  /// without going through the public setter.
  void updateValue(T newValue) {
    _value = newValue;
    notifySubscribers();
  }

  /// Attaches a subscriber
  ///
  /// This is called automatically when a Sink or Well widget mounts.
  /// You typically don't need to call this manually.
  void attach(ReactiveSubscriber subscriber) => _subscribers.add(subscriber);

  /// Detaches a subscriber
  ///
  /// This is called automatically when a Sink or Well widget unmounts.
  /// You typically don't need to call this manually.
  ///
  /// If [autoDispose] is true and this was the last subscriber, the pipe
  /// will automatically dispose itself.
  void detach(ReactiveSubscriber subscriber) {
    _subscribers.remove(subscriber);

    // Auto-dispose if enabled, not managed by hub, and no more subscribers
    if (_autoDispose &&
        !_isRegisteredWithController &&
        _subscribers.isEmpty &&
        _listeners.isEmpty &&
        !_disposed) {
      scheduleMicrotask(() {
        // Double-check conditions haven't changed
        if (_subscribers.isEmpty && _listeners.isEmpty && !_disposed) {
          dispose();
        }
      });
    }
  }

  /// Adds a listener callback that will be called when the value changes
  ///
  /// This is useful for side effects or when creating computed pipes.
  /// Remember to [removeListener] when done to avoid memory leaks.
  void addListener(VoidCallback listener) => _listeners.add(listener);

  /// Removes a previously added listener
  void removeListener(VoidCallback listener) => _listeners.remove(listener);

  /// Forces an update even if the value didn't change
  ///
  /// Use this when you want to force a rebuild even if the value appears
  /// to be the same (e.g., for mutable objects where the reference didn't change
  /// but the internal state did).
  ///
  /// Throws [StateError] if this pipe has been disposed.
  void pump(T newValue) {
    if (_disposed) {
      throw StateError('Cannot update value on a disposed Pipe');
    }
    _value = newValue;
    notifySubscribers();
  }

  /// Disposes this pipe and cleans up all subscriptions
  ///
  /// After calling this, the pipe should not be used anymore.
  /// This method is idempotent - calling it multiple times has no effect.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _subscribers.clear();
    _listeners.clear();
  }

  /// Returns the number of active subscribers
  int get subscriberCount => _subscribers.length;

  /// Whether this pipe has been disposed
  bool get disposed => _disposed;

  /// Whether this pipe will auto-dispose when subscriber count reaches 0
  ///
  /// Defaults to true for standalone pipes, false for hub-managed pipes.
  bool get autoDispose => _autoDispose;

  /// Whether this pipe is registered with a hub
  bool get isRegisteredWithController => _isRegisteredWithController;
}
