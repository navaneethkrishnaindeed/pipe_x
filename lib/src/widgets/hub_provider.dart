import 'package:flutter/widgets.dart';

import '../core/hub.dart';

/// Provider widget for dependency injection of hubs
///
/// [HubProvider] creates or provides a hub and makes it available to all
/// descendant widgets. The hub is automatically disposed when the
/// provider is removed from the widget tree (only for created hubs).
///
/// Example with create (lifecycle managed):
/// ```dart
/// HubProvider<CounterHub>(
///   create: () => CounterHub(),
///   child: MyApp(),
/// )
/// ```
///
/// Example with value (externally managed):
/// ```dart
/// final hub = CounterHub();
/// HubProvider<CounterHub>.value(
///   value: hub,
///   child: MyApp(),
/// )
/// ```
///
/// Access the hub in descendant widgets using:
/// - [HubProvider.of] - Creates a dependency (widget rebuilds if hub instance changes)
/// - [HubProvider.read] - No dependency (use in callbacks)
class HubProvider<T extends Hub> extends StatefulWidget {
  /// Factory function that creates the hub
  final T Function()? _create;

  /// Pre-existing hub instance
  final T? _value;

  /// The widget tree that will have access to the hub
  final Widget child;

  /// Constructs a [HubProvider] widget with a factory function
  ///
  /// This constructor creates a [HubProvider] that instantiates a hub of type [T],
  /// manages its lifecycle, and makes it available to all descendant widgets.
  /// The hub will be automatically disposed when the provider is removed.
  ///
  /// The [create] parameter is a factory function used to create the hub.
  ///
  /// The [child] parameter is the widget tree that requires access to the hub.
  ///
  /// Example:
  /// ```dart
  /// HubProvider<CounterHub>(
  ///   create: () => CounterHub(),
  ///   child: MyApp(),
  /// )
  /// ```
  const HubProvider({
    required T Function() create,
    required this.child,
    super.key,
  })  : _create = create,
        _value = null;

  /// Constructs a [HubProvider] widget with an existing hub instance
  ///
  /// This constructor creates a [HubProvider] that provides an already-created
  /// hub instance to all descendant widgets. The hub will NOT be automatically
  /// disposed when the provider is removed, as it's managed externally.
  ///
  /// The [value] parameter is the pre-existing hub instance.
  ///
  /// The [child] parameter is the widget tree that requires access to the hub.
  ///
  /// Example:
  /// ```dart
  /// final myHub = CounterHub();
  /// HubProvider<CounterHub>.value(
  ///   value: myHub,
  ///   child: MyApp(),
  /// )
  /// ```
  const HubProvider.value({
    required T value,
    required this.child,
    super.key,
  })  : _value = value,
        _create = null;

  @override
  State<HubProvider<T>> createState() => _HubProviderState<T>();

  /// Accesses the hub from the context with a dependency
  ///
  /// This creates a dependency on the hub. If the hub instance
  /// changes (rare, usually only on hot reload), the widget will rebuild.
  ///
  /// Use this when you need the hub instance in your build method.
  ///
  /// Throws [StateError] if no provider is found or if the hub is disposed.
  static T of<T extends Hub>(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<_InheritedHub<T>>();

    if (provider != null) {
      final hub = provider.hub;
      if (hub.disposed) {
        throw StateError(
          'Cannot access a disposed Hub.\n'
          'The hub of type $T has already been disposed.\n'
          'This usually happens when trying to access a hub after its provider has been removed from the tree.',
        );
      }
      return hub;
    }

    // Also check for dynamic provider from MultiHubProvider
    final elements = <InheritedElement>[];
    context.visitAncestorElements((element) {
      if (element is InheritedElement) {
        elements.add(element);
      }
      return true;
    });

    for (final element in elements) {
      final widget = element.widget;
      if (widget is InheritedWidget) {
        // Check if it's our dynamic type using runtime type check
        if (widget.runtimeType.toString().contains('_InheritedHubDynamic')) {
          try {
            final hub = (widget as dynamic).hub;
            if (hub is T) {
              if (hub.disposed) {
                throw StateError(
                  'Cannot access a disposed Hub.\n'
                  'The hub of type $T has already been disposed.\n'
                  'This usually happens when trying to access a hub after its provider has been removed from the tree.',
                );
              }
              context.dependOnInheritedElement(element);
              return hub;
            }
          } catch (_) {}
        }
      }
    }

    throw StateError(
      'No HubProvider<$T> found in context. '
      'Make sure to wrap your widget tree with HubProvider<$T>.',
    );
  }

  /// Accesses the hub from the context without creating a dependency
  ///
  /// This does NOT create a dependency. The widget will never rebuild when
  /// the hub changes. Use this in callbacks and event handlers.
  ///
  /// Example:
  /// ```dart
  /// ElevatedButton(
  ///   onPressed: () {
  ///     HubProvider.read<CounterHub>(context).increment();
  ///   },
  ///   child: Text('+'),
  /// )
  /// ```
  ///
  /// Throws [StateError] if no provider is found or if the hub is disposed.
  static T read<T extends Hub>(BuildContext context) {
    final provider = context.getInheritedWidgetOfExactType<_InheritedHub<T>>();

    if (provider != null) {
      final hub = provider.hub;
      if (hub.disposed) {
        throw StateError(
          'Cannot read from a disposed Hub.\n'
          'The hub of type $T has already been disposed.\n'
          'This usually happens when trying to access a hub after its provider has been removed from the tree.',
        );
      }
      return hub;
    }

    // Also check for dynamic provider from MultiHubProvider
    final elements = <InheritedElement>[];
    context.visitAncestorElements((element) {
      if (element is InheritedElement) {
        elements.add(element);
      }
      return true;
    });

    for (final element in elements) {
      final widget = element.widget;
      if (widget is InheritedWidget) {
        // Check if it's our dynamic type using runtime type check
        if (widget.runtimeType.toString().contains('_InheritedHubDynamic')) {
          try {
            final hub = (widget as dynamic).hub;
            if (hub is T) {
              if (hub.disposed) {
                throw StateError(
                  'Cannot read from a disposed Hub.\n'
                  'The hub of type $T has already been disposed.\n'
                  'This usually happens when trying to access a hub after its provider has been removed from the tree.',
                );
              }
              return hub;
            }
          } catch (_) {}
        }
      }
    }

    throw StateError(
      'No HubProvider<$T> found in context. '
      'Make sure to wrap your widget tree with HubProvider<$T>.',
    );
  }
}

class _HubProviderState<T extends Hub> extends State<HubProvider<T>> {
  late T _hub;
  bool _shouldDispose = false;

  @override
  void initState() {
    super.initState();

    // Type-safe initialization with fail-safe checks
    if (widget._create != null && widget._value != null) {
      throw FlutterError(
        'HubProvider cannot have both create and value.\n'
        'Use either HubProvider(create: ...) or HubProvider.value(value: ...).\n'
        'This is likely a bug in the HubProvider implementation.',
      );
    }

    if (widget._create == null && widget._value == null) {
      throw FlutterError(
        'HubProvider must have either create or value.\n'
        'Use either HubProvider(create: ...) or HubProvider.value(value: ...).\n'
        'This is likely a bug in the HubProvider implementation.',
      );
    }

    if (widget._create != null) {
      // Create mode: instantiate and manage lifecycle
      _hub = widget._create!();
      _shouldDispose = true;

      // Validate that the created hub is valid
      if (_hub.disposed) {
        throw FlutterError(
          'HubProvider create function returned a disposed hub.\n'
          'The factory for $T returned a hub that has already been disposed.\n'
          'Make sure your create function creates a new hub instance.',
        );
      }
    } else {
      // Value mode: use existing instance, don't manage lifecycle
      _hub = widget._value!;
      _shouldDispose = false;

      // Validate that the hub is not disposed
      if (_hub.disposed) {
        throw FlutterError(
          'Cannot provide a disposed hub to HubProvider.value.\n'
          'The hub of type $T has already been disposed.\n'
          'Make sure you are not providing a hub that has been disposed, or create a new instance instead.',
        );
      }
    }
  }

  @override
  void dispose() {
    // Only dispose if we created the hub
    if (_shouldDispose) {
      _hub.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedHub<T>(
      hub: _hub,
      child: widget.child,
    );
  }
}

class _InheritedHub<T extends Hub> extends InheritedWidget {
  final T hub;

  const _InheritedHub({
    required this.hub,
    required super.child,
  });

  @override
  bool updateShouldNotify(_InheritedHub<T> oldWidget) {
    return hub != oldWidget.hub;
  }
}
