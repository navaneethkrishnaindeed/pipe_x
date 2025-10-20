import 'package:flutter/widgets.dart';

import '../core/hub.dart';

/// 🌿 Provides multiple hubs at once without nesting
///
/// [MultiHubProvider] is a convenience widget that avoids the "pyramid of doom"
/// when you need to provide multiple hubs at the same level.
///
/// Without MultiHubProvider:
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
/// With MultiHubProvider:
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
class MultiHubProvider extends StatelessWidget {
  /// List of hub factory functions
  ///
  /// Hubs are created in order (first to last). This can be important
  /// if one hub depends on another.
  final List<Hub Function()> hubs;

  /// The widget tree that will have access to all hubs
  final Widget child;

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
        create: hubs[i],
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
  final Hub Function() create;
  final Widget child;

  const _HubProviderWrapper({
    required this.create,
    required this.child,
  });

  @override
  State<_HubProviderWrapper> createState() => _HubProviderWrapperState();
}

class _HubProviderWrapperState extends State<_HubProviderWrapper> {
  late Hub _hub;

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
