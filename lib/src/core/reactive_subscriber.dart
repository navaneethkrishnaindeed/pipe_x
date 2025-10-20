/// 🌿 Interface for elements that can subscribe to reactive pipes
///
/// This interface decouples [Pipe] from Flutter's Element implementation,
/// making the code more testable and maintainable.
///
/// Elements that want to subscribe to pipes must implement this interface.
abstract class ReactiveSubscriber {
  /// Marks this subscriber for rebuild
  ///
  /// This is called when a pipe's value changes and this subscriber
  /// needs to rebuild.
  void markNeedsBuild();

  /// Whether this subscriber is currently mounted in the widget tree
  ///
  /// Used to prevent rebuilding unmounted widgets.
  bool get mounted;
}
