# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[1.0.1]: https://github.com/yourusername/pipe_x/releases/tag/v1.1.0
[1.0.0]: https://github.com/yourusername/pipe_x/releases/tag/v1.0.0



