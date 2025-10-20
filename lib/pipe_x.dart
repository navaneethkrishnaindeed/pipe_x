// 🌿 PipeX - A lightweight, reactive state management library for Flutter
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
// // 1. Create a hub
// class CounterHub extends Hub {
//   late final Pipe<int> count;
//
//   CounterHub() {
//     count = registerPipe(Pipe(0));
//   }
//
//   void increment() => count.value++;
// }
//
// // 2. Provide the hub
// HubProvider<CounterHub>(
//   create: () => CounterHub(),
//   child: MyApp(),
// )
//
// // 3. Use Sink to display reactive state
// Sink<int>(
//   pipe: hub.count,
//   builder: (context, value) => Text('Count: $value'),
// )
//
// // 4. Call methods in callbacks
// ElevatedButton(
//   onPressed: () {
//     HubProvider.read<CounterHub>(context).increment();
//   },
//   child: Text('+'),
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
export 'src/widgets/multi_hub_provider.dart';

// Extensions
export 'src/extensions/build_context_extension.dart';
