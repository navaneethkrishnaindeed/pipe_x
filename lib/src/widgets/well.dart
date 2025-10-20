import 'package:flutter/widgets.dart';

import '../core/pipe.dart';
import '../core/reactive_subscriber.dart';
import 'sink.dart';

/// 🌿 A widget that subscribes to multiple [Pipe]s and rebuilds when any changes
///
/// [Well] allows you to listen to multiple pipes without
/// nesting Sink widgets. This is perfect for displaying computed
/// values that depend on multiple pipes.
///
/// Example:
/// ```dart
/// class MyHub extends Hub {
///   late final a = Pipe(5);
///   late final b = Pipe(10);
///
///   int get total => a.value + b.value;
/// }
///
/// // Instead of nested Sink:
/// Sink(pipe: a, builder: (_,__) =>
///   Sink(pipe: b, builder: (_,__) =>
///     Text('${hub.total}')
///   )
/// )
///
/// // Use Well:
/// Well(
///   pipes: [hub.a, hub.b],
///   builder: (context) => Text('Total: ${hub.total}'),
/// )
/// ```
class Well extends Widget {
  /// The list of pipes to subscribe to
  final List<Pipe> pipes;

  /// Builder function that creates the widget tree
  ///
  /// This function is called whenever ANY of the pipes' values change.
  final Widget Function(BuildContext context) builder;

  const Well({
    required this.pipes,
    required this.builder,
    super.key,
  });

  @override
  Element createElement() => WellElement(this);
}

/// The element that manages subscriptions to multiple pipes
class WellElement extends ComponentElement implements ReactiveSubscriber {
  WellElement(Well widget) : super(widget);

  @override
  Well get widget => super.widget as Well;

  List<Pipe>? _currentPipes;

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    _currentPipes = widget.pipes;
    // Attach to all pipes
    for (final pipe in _currentPipes!) {
      pipe.attach(this);
    }
  }

  @override
  void update(Well newWidget) {
    final oldPipes = _currentPipes!;
    final newPipes = newWidget.pipes;

    // Find pipes that were removed
    for (final oldPipe in oldPipes) {
      if (!newPipes.contains(oldPipe)) {
        oldPipe.detach(this);
      }
    }

    // Find pipes that were added
    for (final newPipe in newPipes) {
      if (!oldPipes.contains(newPipe)) {
        newPipe.attach(this);
      }
    }

    _currentPipes = newPipes;
    super.update(newWidget);
  }

  @override
  void unmount() {
    // Detach from all pipes
    for (final pipe in _currentPipes!) {
      pipe.detach(this);
    }
    _currentPipes = null;
    super.unmount();
  }

  @override
  Widget build() {
    final child = widget.builder(this);

    // Prevent nesting Sink or Well as direct child
    assert(
      child is! Sink && child is! Well,
      '❌ Do not nest Sink or Well as the direct child!\n'
      'If you need multiple pipes, add them to the pipes list:\n'
      'Well(pipes: [pipe1, pipe2, pipe3], builder: ...)',
    );

    return child;
  }
}
