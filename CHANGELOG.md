# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.4.3]

  - Documetation updates on nested sinks and in Async Example 11

## [1.4.2]

  - Added Permanent discord invite badge
 
## [1.4.1]

  - Badges updates 


## [1.4.0+1]

  - Analytics Changes and Readme Updates 


## [1.4.0]

### Added
- **`HubListener` Widget**: New widget for executing conditional side effects based on Hub state changes without rebuilding its child. Perfect for navigation, dialogs, and other side effects.
  - Type-safe with mandatory generic type parameter enforcement
  - `listenWhen` condition to control when the callback fires
  - `onConditionMet` callback for side effects
  - Automatic lifecycle management
- **Hub-level Listeners**: New `Hub.addListener()` method that triggers on any pipe update within the hub
  - Returns a dispose function for easy cleanup
  - Attaches to all existing and future pipes automatically
  - Memory-safe with proper listener management
- **Comprehensive Async Operations Example**: Added detailed example demonstrating real-world async data loading patterns
  - User profile with 10+ fields
  - Full-screen loading overlay using Stack and Sink
  - Separate reactive fields (gender, age) with independent Sinks
  - Error handling and loading states
  - Demonstrates granular reactivity benefits

### Enhanced
- **Disposed State Safety**: Added runtime checks to prevent usage of disposed objects
  - `Pipe` methods now throw clear errors when used after disposal (value getter/setter, addListener, removeListener, pump)
  - `Sink` and `Well` constructors now assert that pipes are not disposed
  - `Hub.registerPipe()` asserts pipe is not disposed
  - Better error messages guiding developers to fix issues
- **Protected API Surface**: Added `@protected` annotations to internal methods across all core components
  - `Hub.registerPipe()`, `Hub.pipe()`, `Hub.checkNotDisposed()`, `Hub.onDispose()`
  - `Pipe.attach()`, `Pipe.detach()` (used internally by Sink/Well)
  - Clearer distinction between public and internal APIs
- **Code Quality**: Improved internal consistency
  - `Hub.pipe()` now uses `Hub.registerPipe()` internally (DRY principle)
  - Graceful cleanup when detaching from disposed pipes
  - Consistent naming with `addListener()` throughout

### Changed
- **Non-const Constructors**: `Sink`, `Well`, and `MultiHubProvider` constructors are no longer const to support runtime assertions
  - Enables better developer experience with clear error messages
  - Minimal impact on performance, significant gain in safety

### Documentation
- Completely updated README with new package features
- All examples now follow best practice pattern: `final hub = context.read<MyHub>()` at the top of build methods
- Updated examples to show Hub scoping to screens instead of entire app (better lifecycle management)
- Enhanced migration guides from setState, Provider, and BLoC
- Expanded best practices section with new patterns
- Added HubListener usage examples and patterns

## [1.3.0]
- Added `HubProvider.value` to support externally-managed Hub lifecycles. Now you can pass pre-created Hub objects, allowing for global shared state, easier testing, or integration with DI systems. Hubs provided this way are **not** automatically disposed.
- Added `MultiHubProvider` support for mixing existing hub instances (values) and hub factories, providing maximum flexibility for composition and dependency injection use-cases.
- Examples and documentation updated to cover both features.
- Added `state_benchmark` project with 3 tests benchmarking PipeX against Riverpod and BLoC. 
- PipeX achieved best median update time in Basic and Complex tests; Riverpod slightly led in Multi-state. All frameworks performed highly, with PipeX and Riverpod having the most test wins.

## [1.2.1]
   Readme.md Updates

## [1.2.0]
 Documentation for Sink and Well Contructors 

## [1.1.0]
 Documentation updates for Hub , HubProvider, MultiHubProvider, Sink and Well Contructors 

## [1.0.4]
- Added badges 

## [1.0.3] 

- Updated Banner and pubspec.yaml issues

## [1.0.2]
Updated to Webp Logo

## [1.0.1] 

 Updated documentation and table of contents structure for better navigation

## [1.0.0] - 2025-10-20

### Added
- Initial release of PipeX state management library
- Core reactive primitives:
  - `Pipe<T>`: Reactive container for state with automatic notification
  - `Hub`: State manager with automatic pipe lifecycle management
  - `Sink`: Widget for subscribing to a single pipe
  - `Well`: Widget for subscribing to multiple pipes
  - `HubProvider`: Dependency injection for hubs
  - `MultiHubProvider`: Provide multiple hubs without nesting
  - `ReactiveSubscriber`: Interface for reactive subscriptions
- Extensions:
  - `BuildContext.read<T>()`: Convenient hub access
- Features:
  - Fine-grained reactivity with automatic rebuilds
  - Automatic lifecycle management and disposal
  - Auto-registration of pipes in hubs
  - Type-safe API with full Dart type system support
  - Zero boilerplate with intuitive API
  - Standalone pipe support with auto-disposal
- Comprehensive documentation and examples
- MIT License

### Documentation
- Complete README with usage guide
- Extensive inline documentation
- Multiple example implementations demonstrating all features
- Best practices and patterns guide

[1.4.3]: https://github.com/navaneethkrishnaindeed/pipe_x/releases/tag/v1.4.3
[1.4.2]: https://github.com/navaneethkrishnaindeed/pipe_x/releases/tag/v1.4.2
[1.4.1]: https://github.com/navaneethkrishnaindeed/pipe_x/releases/tag/v1.4.1
[1.4.0+1]: https://github.com/navaneethkrishnaindeed/pipe_x/releases/tag/v1.4.0+1
[1.4.0]: https://github.com/navaneethkrishnaindeed/pipe_x/releases/tag/v1.4.0
[1.3.0]: https://github.com/navaneethkrishnaindeed/pipe_x/releases/tag/v1.3.0
[1.2.1]: https://github.com/navaneethkrishnaindeed/pipe_x/releases/tag/v1.2.1
[1.2.0]: https://github.com/navaneethkrishnaindeed/pipe_x/releases/tag/v1.2.0
[1.1.0]: https://github.com/navaneethkrishnaindeed/pipe_x/releases/tag/v1.1.0
[1.0.4]: https://github.com/navaneethkrishnaindeed/pipe_x/releases/tag/v1.0.4
[1.0.3]: https://github.com/navaneethkrishnaindeed/pipe_x/releases/tag/v1.0.3
[1.0.2]: https://github.com/navaneethkrishnaindeed/pipe_x/releases/tag/v1.0.2
[1.0.1]: https://github.com/navaneethkrishnaindeed/pipe_x/releases/tag/v1.0.1
[1.0.0]: https://github.com/navaneethkrishnaindeed/pipe_x/releases/tag/v1.0.0



