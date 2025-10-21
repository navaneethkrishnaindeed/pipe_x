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

  /// 🌿 **Sink**

  /// [Sink] is a widget designed to build only when the [Pipe] it subscribes to changes.
  /// It provides a fine-tuned control over widget rebuilds, ensuring efficiency and
  /// performance optimization in Flutter applications.

  /// ### 🎉 Features
  /// - **Automatic Rebuild**: Automatically rebuilds when the subscribed [Pipe]'s value changes.
  /// - **Fine-Grained Control**: Only the widget portion wrapped by [Sink] rebuilds, not the entire tree.
  /// - **Easy Integration**: Simply plug [Pipe] and a builder to create reactive UIs effortlessly.
  /// - **Minimalistic Design**: Lightweight and designed to keep boilerplate to a minimum.

  /// ### 🚀 Example Usage

  /// **Basic Example:**
  /// ```dart
  /// Sink<int>(
  ///   pipe: hub.count, // Attach to a Pipe
  ///   builder: (context, value) => Text('Count: $value'), // Use Pipe value
  /// )
  /// ```

  /// **In a Widget Tree:**
  /// ```dart
  /// Column(
  ///   children: [
  ///     Text('Title'),
  ///     Sink<String>(
  ///       pipe: hub.title, // Reacts when title changes
  ///       builder: (context, value) => Text('Title: $value'),
  ///     ),
  ///     ElevatedButton(
  ///       onPressed: () => hub.title.update('New Title'), // Update to trigger rebuild
  ///       child: Text('Change Title'),
  ///     ),
  ///   ],
  /// )
  /// ```

  /// ### 📚 Best Practices
  /// - **Keep it Scoped**: Limit the widget tree within [Sink] to only those needing updates.
  /// - **Combine with Other Widgets**: Use alongside other reactive widgets like [Well] for complex UIs.
  /// - **Optimize Performance**: Avoid wrapping large widget trees unnecessarily.

  /// ### ⚠️ Notes
  /// - Ensure the [Pipe] provided is initialized before using in [Sink].
  /// - **Avoid Nesting**: Try to keep nesting minimal to maintain readability and performance.
  // Start Generation Here

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
  SinkElement(super.widget);

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
