import 'package:flutter/widgets.dart';
import '../widgets/hub_provider.dart';
import '../core/hub.dart';

/// Extension on [BuildContext] to provide convenient access to [Hub]s
/// provided by [HubProvider] ancestors.
///
/// This allows you to write:
/// ```dart
/// final myHub = context.read<MyHub>();
/// ```
///
/// Instead of:
/// ```dart
/// final myHub = HubProvider.read<MyHub>(context);
/// ```
extension HubBuildContextExtension on BuildContext {
  /// Reads a [Hub] of type [T] from the widget tree without listening to changes.
  ///
  /// This is useful when you need to access a Hub's methods (like updating state)
  /// but don't want the widget to rebuild when the Hub's pipes change.
  ///
  /// Example:
  /// ```dart
  /// ElevatedButton(
  ///   onPressed: () {
  ///     context.read<CounterHub>().increment();
  ///   },
  ///   child: const Text('Increment'),
  /// )
  /// ```
  ///
  /// Throws an error if no [HubProvider] of type [T] is found in the widget tree.
  T read<T extends Hub>() {
    return HubProvider.read<T>(this);
  }
}
