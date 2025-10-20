import 'package:flutter/widgets.dart';

import '../core/pipe.dart';
import '../core/reactive_subscriber.dart';

/// 🌿 A widget that subscribes to a [Pipe] and rebuilds when its value changes
///
/// [Sink] is a minimal widget that only rebuilds when the pipe it
/// depends on changes. This provides fine-grained control over rebuilds.
///
/// Example:
/// ```dart
/// Sink<int>(
///   pipe: hub.count,
///   builder: (context, value) => Text('Count: $value'),
/// )
/// ```
///
/// Best Practice: Keep Sink as small and specific as possible.
/// Only wrap the widgets that actually need to rebuild when the pipe changes.
class Sink<T> extends Widget {
  /// The pipe to subscribe to
  final Pipe<T> pipe;

  /// Builder function that creates the widget tree
  ///
  /// This function is called whenever the pipe's value changes.
  /// The [value] parameter contains the current value of the pipe.
  final Widget Function(BuildContext context, T value) builder;

  const Sink({
    required this.pipe,
    required this.builder,
    super.key,
  });

  @override
  Element createElement() => SinkElement<T>(this);
}

/// The element that manages the subscription lifecycle for [Sink]
///
/// This element automatically:
/// - Subscribes to the pipe when mounted
/// - Updates subscription when the pipe changes
/// - Unsubscribes when unmounted
///
/// You typically don't interact with this class directly.
class SinkElement<T> extends ComponentElement implements ReactiveSubscriber {
  SinkElement(Sink<T> widget) : super(widget);

  @override
  Sink<T> get widget => super.widget as Sink<T>;

  Pipe<T>? _currentPipe;

  /// Called when this element is mounted to the tree
  ///
  /// Subscribes to the pipe so that this element will rebuild when
  /// the pipe's value changes.
  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    _currentPipe = widget.pipe;
    _currentPipe!.attach(this);
  }

  /// Called when the widget is updated with a new configuration
  ///
  /// If the pipe has changed, unsubscribes from the old pipe
  /// and subscribes to the new one.
  @override
  void update(Sink<T> newWidget) {
    final oldPipe = _currentPipe;
    final newPipe = newWidget.pipe;

    // Handle pipe changes
    if (oldPipe != newPipe) {
      oldPipe?.detach(this);
      newPipe.attach(this);
      _currentPipe = newPipe;
    }

    super.update(newWidget);
  }

  /// Called when this element is removed from the tree
  ///
  /// Unsubscribes from the pipe to prevent memory leaks.
  @override
  void unmount() {
    _currentPipe?.detach(this);
    _currentPipe = null;
    super.unmount();
  }

  /// Builds the widget tree using the current pipe value
  @override
  Widget build() {
    final child = widget.builder(this, widget.pipe.value);

    // Prevent nesting Sink or Well as direct child
    assert(
      child is! Sink && !child.runtimeType.toString().startsWith('Well'),
      '❌ Do not nest Sink or Well as the direct child!\n'
      'Use Well with multiple pipes instead:\n'
      'Well(pipes: [pipe1, pipe2], builder: ...)',
    );

    return child;
  }
}
