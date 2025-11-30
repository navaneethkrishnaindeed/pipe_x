// PipeX - A lightweight, reactive state management library for Flutter
//
// PipeX provides fine-grained reactivity with minimal boilerplate. It works
// directly with Flutter's Element tree to provide optimal performance.
//
// ## Core Concepts
//
// - **Pipe**: A reactive container that holds a value and notifies subscribers
// - **Hub**: Reactive hub with automatic Pipe disposal and lifecycle management
// - **Sink**: Widget that subscribes to a Pipe and rebuilds on changes
// - **Well**: Widget that subscribes to multiple Pipes without nesting
// - **HubProvider**: Dependency injection for hubs
// - **MultiHubProvider**: Provide multiple hubs without nesting
//
// ## Quick Start
//
// ```dart
// // 1. Create a hub with pipes (automatic registration!)
// class CounterHub extends Hub {
//   late final count = Pipe(0);  //  Auto-registered!
//
//   void increment() => count.value++;
//   void decrement() => count.value--;
// }
//
// // 2. Provide the hub using HubProvider
// HubProvider<CounterHub>(
//   create: () => CounterHub(),  // Provider manages lifecycle
//   child: MyApp(),
// )
//
// // 3. Use Sink to display reactive state
// Sink<int>(
//   pipe: context.read<CounterHub>().count,
//   builder: (context, value) => Text('Count: $value'),
// )
//
// // 4. Update state in callbacks using read() (no rebuild dependency)
// ElevatedButton(
//   onPressed: () {
//     context.read<CounterHub>().increment();
//   },
//   child: Text('+'),
// )
// ```
//
// ## HubProvider Access Methods
//
// ```dart
// // HubProvider.of() - Creates dependency (rebuilds if hub instance changes)
// final hub = HubProvider.of<CounterHub>(context);
//
// // HubProvider.read() - No dependency (use in callbacks)
// final hub = HubProvider.read<CounterHub>(context);
//
// // Extension method - Same as read()
// final hub = context.read<CounterHub>();
// ```
//
// ## MultiHubProvider - Avoid Nesting
//
// ```dart
// // Instead of nested providers:
// HubProvider<AuthHub>(
//   create: () => AuthHub(),
//   child: HubProvider<ThemeHub>(
//     create: () => ThemeHub(),
//     child: MyApp(),
//   ),
// )
//
// // Use MultiHubProvider:
// MultiHubProvider(
//   hubs: [
//     () => AuthHub(),    // Factory functions
//     () => ThemeHub(),
//     existingHub,        // Or existing instances
//   ],
//   child: MyApp(),
// )
// ```
//
// ## Well - Multiple Pipes Without Nesting
//
// ```dart
// // Instead of nested Sinks:
// Sink(pipe: hub.a, builder: (_,__) =>
//   Sink(pipe: hub.b, builder: (_,__) =>
//     Text('${hub.total}')
//   )
// )
//
// // Use Well:
// Well(
//   pipes: [hub.a, hub.b],
//   builder: (context) => Text('Total: ${hub.total}'),
// )
// ```
//
// For more information, see the documentation and examples.

/// PipeX - Reactive state management library for Flutter
library;

// Core classes
export 'src/core/hub.dart';
export 'src/core/pipe.dart';
export 'src/core/reactive_subscriber.dart';

// Widgets
export 'src/widgets/sink.dart';
export 'src/widgets/well.dart';
export 'src/widgets/hub_provider.dart';
export 'src/widgets/hub_listener.dart';
export 'src/widgets/multi_hub_provider.dart';

// Extensions
export 'src/extensions/build_context_extension.dart';
