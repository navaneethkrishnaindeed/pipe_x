import 'package:flutter/widgets.dart';

import '../core/hub.dart';

/// 🌿 Provider widget for dependency injection of hubs
///
/// [HubProvider] creates a hub and makes it available to all
/// descendant widgets. The hub is automatically disposed when the
/// provider is removed from the widget tree.
///
/// Example:
/// ```dart
/// HubProvider<CounterHub>(
///   create: () => CounterHub(),
///   child: MyApp(),
/// )
/// ```
///
/// Access the hub in descendant widgets using:
/// - [HubProvider.of] - Creates a dependency (widget rebuilds if hub instance changes)
/// - [HubProvider.read] - No dependency (use in callbacks)
class HubProvider<T extends Hub> extends StatefulWidget {
  /// Factory function that creates the hub
  final T Function() create;

  /// The widget tree that will have access to the hub
  final Widget child;
  /// 🎉 Constructs a [HubProvider] widget
  ///
  /// This constructor creates a [HubProvider] that instantiates a hub of type `T`, 
  /// manages its lifecycle, and makes it available to all descendant widgets.
  ///
  /// The [create] parameter is a factory function used to create the hub.
  ///
  /// The [child] parameter is the widget tree that requires access to the hub.
  ///
  /// Example:
  /// ```dart
  /// HubProvider<CounterHub>(
  ///   create: () => CounterHub(),  // 🚀 Hub creation
  ///   child: MyApp(),              // 🌳 Widget tree with hub access
  /// )
  /// ```
  const HubProvider({
    required this.create,
    required this.child,
    super.key,
  });

  @override
  State<HubProvider<T>> createState() => _HubProviderState<T>();

  /// Accesses the hub from the context with a dependency
  ///
  /// This creates a dependency on the hub. If the hub instance
  /// changes (rare, usually only on hot reload), the widget will rebuild.
  ///
  /// Use this when you need the hub instance in your build method.
  ///
  /// Throws [StateError] if no provider is found.
  static T of<T extends Hub>(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<_InheritedHub<T>>();

    if (provider != null) {
      return provider.hub;
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
  /// Throws [StateError] if no provider is found.
  static T read<T extends Hub>(BuildContext context) {
    final provider = context.getInheritedWidgetOfExactType<_InheritedHub<T>>();

    if (provider != null) {
      return provider.hub;
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

  @override
  void initState() {
    super.initState();
    _hub = widget.create();
    // Remove hub from construction stack after creation
    _hub.completeConstruction();
  }

  @override
  void dispose() {
    _hub.dispose();
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
