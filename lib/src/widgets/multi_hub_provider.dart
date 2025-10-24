import 'package:flutter/widgets.dart';

import '../core/hub.dart';

/// Provides multiple hubs at once without nesting
///
/// [MultiHubProvider] is a convenience widget that avoids the "pyramid of doom"
/// when you need to provide multiple hubs at the same level.
///
/// Without MultiHubProvider (nested):
/// ```dart
/// HubProvider<AuthHub>(
///   create: () => AuthHub(),
///   child: HubProvider<ThemeHub>(
///     create: () => ThemeHub(),
///     child: HubProvider<SettingsHub>(
///       create: () => SettingsHub(),
///       child: MyApp(),
///     ),
///   ),
/// )
/// ```
///
/// With MultiHubProvider (flat):
/// ```dart
/// MultiHubProvider(
///   hubs: [
///     () => AuthHub(),
///     () => ThemeHub(),
///     () => SettingsHub(),
///   ],
///   child: MyApp(),
/// )
/// ```
///
/// Using existing instances:
/// ```dart
/// final authHub = AuthHub();
/// final themeHub = ThemeHub();
/// MultiHubProvider(
///   hubs: [
///     authHub,
///     themeHub,
///   ],
///   child: MyApp(),
/// )
/// ```
///
/// Mix factories and values:
/// ```dart
/// final authHub = AuthHub();
/// MultiHubProvider(
///   hubs: [
///     authHub,              // Existing instance
///     () => ThemeHub(),     // Factory function
///   ],
///   child: MyApp(),
/// )
/// ```
class MultiHubProvider extends StatelessWidget {
  /// List of hubs or hub factory functions
  ///
  /// Each item can be either:
  /// - A [Hub] instance (will not be disposed)
  /// - A [Hub Function()] factory (will be created and disposed)
  ///
  /// Hubs are provided in order (first to last). This can be important
  /// if one hub depends on another.
  final List<Object> hubs;

  /// The widget tree that will have access to all hubs
  final Widget child;

  /// Constructs a [MultiHubProvider] widget
  ///
  /// This constructor creates a [MultiHubProvider] that manages multiple
  /// hubs simultaneously, reducing the complexity of nested [HubProvider] widgets.
  ///
  /// The [hubs] parameter accepts a list of either:
  /// - Hub instances (for existing hubs that won't be disposed)
  /// - Factory functions that return hubs (for new hubs that will be created and disposed)
  ///
  /// Example:
  /// ```dart
  /// final existingHub = AuthHub();
  /// MultiHubProvider(
  ///   hubs: [
  ///     existingHub,         // Existing hub instance
  ///     () => ThemeHub(),    // Factory function
  ///     () => SettingsHub(), // Factory function
  ///   ],
  ///   child: MyApp(),
  /// )
  /// ```
  const MultiHubProvider({
    required this.hubs,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Widget current = child;

    // Wrap child with providers in reverse order
    // so the first hub is the outermost
    for (int i = hubs.length - 1; i >= 0; i--) {
      current = _HubProviderWrapper(
        hubOrFactory: hubs[i],
        child: current,
      );
    }

    return current;
  }
}

/// Internal wrapper widget for providing a single hub
///
/// This is used internally by [MultiHubProvider] to wrap each hub.
class _HubProviderWrapper extends StatefulWidget {
  final Object hubOrFactory;
  final Widget child;

  const _HubProviderWrapper({
    required this.hubOrFactory,
    required this.child,
  });

  @override
  State<_HubProviderWrapper> createState() => _HubProviderWrapperState();
}

class _HubProviderWrapperState extends State<_HubProviderWrapper> {
  late Hub _hub;
  bool _shouldDispose = false;

  @override
  void initState() {
    super.initState();

    // Type-safe initialization with fail-safe checks
    final hubOrFactory = widget.hubOrFactory;

    if (hubOrFactory is Hub) {
      // Value mode: use existing instance, don't manage lifecycle

      // Validate that the hub is not disposed
      if (hubOrFactory.disposed) {
        throw FlutterError(
          'Cannot provide a disposed hub to MultiHubProvider.\n'
          'The hub of type ${hubOrFactory.runtimeType} has already been disposed.\n'
          'Make sure you are not providing a hub that has been disposed, or create a new instance instead.',
        );
      }

      _hub = hubOrFactory;
      _shouldDispose = false;
    } else if (hubOrFactory is Hub Function()) {
      // Create mode: instantiate and manage lifecycle
      _hub = hubOrFactory();
      _shouldDispose = true;

      // Validate that the created hub is valid
      if (_hub.disposed) {
        throw FlutterError(
          'MultiHubProvider factory function returned a disposed hub.\n'
          'The factory for ${_hub.runtimeType} returned a hub that has already been disposed.\n'
          'Make sure your factory function creates a new hub instance.',
        );
      }

      // Remove hub from construction stack after creation
      _hub.completeConstruction();
    } else {
      throw FlutterError(
        'Invalid type in MultiHubProvider.hubs list.\n'
        'Each item in the hubs list must be either:\n'
        '  - A Hub instance (e.g., MyHub())\n'
        '  - A Hub factory function (e.g., () => MyHub())\n'
        'Got: ${hubOrFactory.runtimeType}',
      );
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
    return _InheritedHubDynamic(
      hub: _hub,
      child: widget.child,
    );
  }
}

/// Dynamic version of InheritedWidget for MultiHubProvider
///
/// This allows any hub type to be provided through the same widget.
class _InheritedHubDynamic extends InheritedWidget {
  final Hub hub;

  const _InheritedHubDynamic({
    required this.hub,
    required super.child,
  });

  @override
  bool updateShouldNotify(_InheritedHubDynamic oldWidget) {
    return hub != oldWidget.hub;
  }
}
