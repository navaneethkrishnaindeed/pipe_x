// ignore_for_file: invalid_use_of_protected_member, prefer_function_declarations_over_variables

import 'pipe.dart';

/// A reactive pipe whose value is computed from other pipes
///
/// [ComputedPipe] automatically tracks dependencies and recomputes
/// its value whenever any dependency changes. This provides true
/// reactive derived state.
///
/// Example:
/// ```dart
/// class CartHub extends Hub {
///   late final items = pipe(<CartItem>[]);
///   late final taxRate = pipe(0.08);
///
///   // Computed pipe - automatically updates when items or taxRate change
///   late final total = computed(
///     dependencies: [items, taxRate],
///     compute: () {
///       final subtotal = items.value.fold(0.0, (sum, item) => sum + item.price);
///       return subtotal * (1 + taxRate.value);
///     },
///   );
/// }
/// ```
///
/// Unlike getters, [ComputedPipe] can be subscribed to with [Sink] or [Well],
/// and only recomputes when dependencies actually change.
class ComputedPipe<T> extends Pipe<T> {
  final List<Pipe> _dependencies;
  final T Function() _compute;
  final List<void Function(dynamic)> _dependencyListeners = [];

  /// Creates a computed pipe with dependencies and a compute function
  ///
  /// - [dependencies]: List of pipes this computed value depends on
  /// - [compute]: Function that calculates the derived value
  ///
  /// The compute function is called immediately to get the initial value,
  /// and again whenever any dependency changes.
  ///
  /// ### Example:
  /// ```dart
  /// final firstName = Pipe('John');
  /// final lastName = Pipe('Doe');
  ///
  /// final fullName = ComputedPipe(
  ///   dependencies: [firstName, lastName],
  ///   compute: () => '${firstName.value} ${lastName.value}',
  /// );
  ///
  /// print(fullName.value); // 'John Doe'
  /// firstName.value = 'Jane';
  /// print(fullName.value); // 'Jane Doe'
  /// ```
  ComputedPipe({
    required List<Pipe> dependencies,
    required T Function() compute,
  })  : _dependencies = dependencies,
        _compute = compute,
        assert(
          dependencies.isNotEmpty,
          '\n\n'
          ' ComputedPipe requires at least one dependency!\n\n'
          ' If you don\'t have dependencies, use a regular Pipe instead.\n'
          'Example:\n'
          '  final computed = ComputedPipe(\n'
          '    dependencies: [pipe1, pipe2],  // ← At least one pipe\n'
          '    compute: () => pipe1.value + pipe2.value,\n'
          '  )\n',
        ),
        assert(
          dependencies.every((p) => !p.disposed),
          '\n\n'
          ' ComputedPipe received one or more disposed dependencies!\n\n'
          ' Ensure all dependency pipes are alive (not disposed).\n'
          'Tip: Create pipes on your Hub and let the Hub manage lifecycle.\n',
        ),
        super(compute(), autoDispose: false) {
    // Listen to all dependencies
    _setupDependencyListeners();
  }

  /// Sets up listeners on all dependency pipes
  void _setupDependencyListeners() {
    for (final dep in _dependencies) {
      final listener = (_) => _recompute();
      _dependencyListeners.add(listener);
      dep.addListener(listener);
    }
  }

  /// Recomputes the value when a dependency changes
  void _recompute() {
    if (disposed) return;

    final newValue = _compute();
    // Only update and notify if value actually changed
    if (shouldNotify(newValue)) {
      pump(newValue);
    }
  }

  /// The current computed value
  ///
  /// This returns the cached computed value. The value is only
  /// recomputed when dependencies change, not on every access.
  @override
  T get value {
    assert(!disposed, 'Cannot access value of a disposed ComputedPipe');
    return super.value;
  }

  /// Setting value directly on a ComputedPipe is not allowed
  ///
  /// The value is derived from dependencies and cannot be set manually.
  /// If you need to set a value directly, use a regular [Pipe] instead.
  @override
  set value(T newValue) {
    throw UnsupportedError(
      'Cannot set value directly on a ComputedPipe.\n'
      'ComputedPipe values are derived from their dependencies.\n'
      'Update the dependency pipes instead.',
    );
  }

  /// Disposes this computed pipe and removes all dependency listeners
  ///
  /// This is called automatically when the parent Hub is disposed.
  @override
  void dispose() {
    if (disposed) return;

    // Remove listeners from dependencies first
    for (var i = 0; i < _dependencies.length; i++) {
      final dep = _dependencies[i];
      if (!dep.disposed && i < _dependencyListeners.length) {
        dep.removeListener(_dependencyListeners[i]);
      }
    }
    _dependencyListeners.clear();

    super.dispose();
  }

  /// The pipes this computed pipe depends on
  ///
  /// This is mainly for debugging and testing.
  List<Pipe> get dependencies => List.unmodifiable(_dependencies);
}
