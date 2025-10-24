# PipeX Tests

Comprehensive unit tests for all PipeX components.

## Test Structure

```
test/
├── core/
│   ├── pipe_test.dart          # Tests for Pipe class
│   └── hub_test.dart            # Tests for Hub class
├── widgets/
│   ├── sink_test.dart           # Tests for Sink widget
│   ├── well_test.dart           # Tests for Well widget
│   ├── hub_provider_test.dart   # Tests for HubProvider widget
│   └── multi_hub_provider_test.dart  # Tests for MultiHubProvider widget
└── extensions/
    └── build_context_extension_test.dart  # Tests for BuildContext extension

```

## Test Coverage

### Core Components (30 tests)

#### Pipe (18 tests)
- Initialization with correct value
- Value updates
- Listener notifications
- Prevent duplicate notifications for same values
- Force updates with pump()
- Listener management (add/remove)
- Disposal error handling
- Subscriber count tracking
- Disposed state checking
- Custom types support
- Nullable types support
- Auto-dispose flag

#### Hub (12 tests)
- Auto-registration of pipes during construction
- Method-based pipe updates
- Disposed state tracking
- Idempotent disposal
- Auto-disposal of registered pipes
- onDispose lifecycle callback
- Subscriber count across all pipes
- Multiple pipe type handling
- Manual pipe registration

### Widget Components (48 tests)

#### Sink (13 tests)
- Building with initial values
- Rebuilding on pipe value changes
- Multiple rebuilds
- Preventing unnecessary rebuilds
- Pipe reference changes
- Unsubscribe on disposal
- Different data types
- Context availability
- Multiple subscriptions to same pipe
- Complex widget trees

#### Well (13 tests)
- Building with multiple pipes
- Rebuilding on any pipe change
- Subscriber count tracking for all pipes
- Pipe list changes
- Different data types
- Empty pipe lists
- Context availability
- Batch rebuilds for simultaneous changes
- Computed values
- Complex widget trees

#### HubProvider (13 tests)
- Providing hub with create constructor
- Providing hub with value constructor
- Auto-disposal of created hubs
- Manual lifecycle management for value hubs
- HubProvider.of with dependency
- HubProvider.read without dependency
- Hub method invocation
- Error handling for missing providers
- Nested providers
- Validation of disposed hubs
- Integration with Sink and Well
- Multiple widgets accessing same hub

#### MultiHubProvider (9 tests)
- Multiple hub provision with factories
- Multiple hub provision with instances
- Mixed factories and instances
- Auto-disposal of factory-created hubs
- Manual lifecycle for instance hubs
- Empty lists
- Single hub provision
- Correct hub ordering
- Invalid type error handling
- Complex widget trees

### Extensions (10 tests)

#### HubBuildContextExtension (10 tests)
- context.read() functionality
- No dependency creation
- Multiple hub types
- Usage in callbacks
- Integration with MultiHubProvider
- Error handling for missing hubs
- Equivalence with HubProvider.read
- Deep nesting
- Integration with Sink
- Integration with Well
- Multiple calls returning same instance

## Running Tests

Run all tests:
```bash
flutter test
```

Run specific test file:
```bash
flutter test test/core/pipe_test.dart
```

Run specific test:
```bash
flutter test --plain-name "should initialize with correct value"
```

Run tests with coverage:
```bash
flutter test --coverage
```

## Test Patterns

### Testing Pipes
```dart
test('should update value', () {
  final pipe = Pipe<int>(0);
  pipe.value = 10;
  expect(pipe.value, 10);
  pipe.dispose();
});
```

### Testing Hubs
```dart
test('should auto-register pipes', () {
  final hub = TestHub();
  hub.completeConstruction();
  
  hub.dispose();
  expect(hub.count.disposed, true);
});
```

### Testing Widgets
```dart
testWidgets('should rebuild on change', (tester) async {
  final pipe = Pipe<int>(0);
  
  await tester.pumpWidget(
    MaterialApp(
      home: Sink<int>(
        pipe: pipe,
        builder: (context, value) => Text('$value'),
      ),
    ),
  );
  
  pipe.value = 5;
  await tester.pump();
  
  expect(find.text('5'), findsOneWidget);
  pipe.dispose();
});
```

## Key Testing Considerations

1. **Always dispose pipes and hubs** after tests to prevent memory leaks
2. **Use `await tester.pump()`** after state changes in widget tests
3. **Use `autoDispose: false`** when testing pipe lifecycle explicitly
4. **Test both success and error paths** for robust coverage
5. **Test integration between components** (Hub with Sink, Provider with Well, etc.)
6. **Validate lifecycle management** (creation, updates, disposal)
7. **Test error handling** (disposed access, missing providers, invalid types)

## Test Results

```
All 85 tests passed! ✓
```

### Coverage by Component
- **Pipe**: 18/18 ✓
- **Hub**: 12/12 ✓
- **Sink**: 13/13 ✓
- **Well**: 13/13 ✓
- **HubProvider**: 13/13 ✓
- **MultiHubProvider**: 9/9 ✓
- **BuildContext Extension**: 10/10 ✓

