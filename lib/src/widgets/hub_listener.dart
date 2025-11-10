import 'package:flutter/widgets.dart';
import '../core/hub.dart';
import '../extensions/build_context_extension.dart';

/// A widget that listens to hub changes and executes a callback conditionally
///
/// [HubListener] monitors all pipes in a hub and executes [onConditionMet]
/// when [listenWhen] returns true. This widget does NOT rebuild - it's purely
/// for side effects.
///
/// Example:
/// ```dart
/// HubListener<CounterHub>(
///   listenWhen: (hub) {
///     return hub.count.value == hub.target.value;
///   },
///   onConditionMet: () {
///     showDialog(
///       context: context,
///       builder: (_) => AlertDialog(title: Text('Target Reached!')),
///     );
///   },
///   child: MyWidget(),
/// )
/// ```
class HubListener<T extends Hub> extends StatefulWidget {
  /// The condition that determines when to execute the callback
  ///
  /// Called whenever any pipe in the hub changes. Return true to trigger
  /// [onConditionMet], false to skip it.
  final bool Function(T hub) listenWhen;

  /// Callback executed when [listenWhen] returns true
  ///
  /// Use this for side effects like showing dialogs, navigation,
  /// logging, analytics, etc.
  final VoidCallback onConditionMet;

  /// The widget to display (never rebuilds)
  final Widget child;

  const HubListener({
    super.key,
    required this.listenWhen,
    required this.onConditionMet,
    required this.child,
  }) : assert(
          T != Hub,
          '\n\n'
          ' HubListener requires an explicit type parameter!\n\n\n'
          ' Bad:  HubListener(...) \n Missing type\n\n'
          ' Good: HubListener<YourHub>(...) \n Explicit type\n\n\n\n'
          'Example:\n'
          '  HubListener<CounterHub>(\n'
          '    listenWhen: (hub) => hub.count.value == 10,\n'
          '    onConditionMet: () => showDialog(...),\n'
          '    child: MyWidget(),\n'
          '  )\n',
        );

  @override
  State<HubListener<T>> createState() => _HubListenerState<T>();
}

class _HubListenerState<T extends Hub> extends State<HubListener<T>> {
  late final T _hub;
  VoidCallback? _removeListener;
  bool _isListenerSet = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isListenerSet) {
      _hub = context.read<T>();
      _isListenerSet = true;

      // Set up listener on the hub - NO setState, just execute callback
      // Store the dispose function for cleanup
      _removeListener = _hub.addListener(() {
        // Check if condition is met
        if (widget.listenWhen(_hub)) {
          // Execute callback for side effects only
          widget.onConditionMet();
        }
      });
    }
  }

  @override
  void dispose() {
    // Clean up the listener
    _removeListener?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Child never rebuilds - just passes through
    return widget.child;
  }
}
