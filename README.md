# 🔧 PipeX State Management

**PipeX** is a Flutter library designed for state management, utilizing pipeline architecture. It focuses on precise reactivity and streamlined code to enhance development.

<img src="images/banner.png" alt="PipeX Logo" style="width: 100%;" />

<p align="center">
  <br>
  <a href="https://pub.dev/packages/pipe_x">
    <img src="https://img.shields.io/pub/v/pipe_x.svg" alt="pub package" />
  </a>
  <a href="https://github.com/navaneethkrishnaindeed/pipe_x">
    <img src="https://img.shields.io/github/stars/navaneethkrishnaindeed/pipe_x" alt="GitHub" />
  </a>
  <a href="https://discord.gg/kyn3SZxUWn">
     <img src="https://img.shields.io/badge/Discord-Join%20Server-7289da?logo=discord&logoColor=white" alt="Discord" />
  </a>
  <br><br>
</p>

<p align="center">
  <b>
    <span style="font-size:1.25em">
      🚫 No Streams &nbsp; &nbsp;|&nbsp; &nbsp; 🚫 No Dependency Injection &nbsp; &nbsp;|&nbsp; &nbsp; 🚫 No Keys For Widget Updates
    </span>
  </b>
  <br><br>
  <span>
     <i>
      PipeX eliminates boilerplate.<br>
      Just pure, fine-grained reactivity with Dart Object Manipulation and Custom Elements <br>
     </i>
  </span>
</p>

<p align="center">
  <a href="state_benchmark/README.md">
    <img 
      src="https://img.shields.io/badge/📊_Read_Full_Benchmark_Report-Click_Here-blue?style=for-the-badge&logo=github" 
      alt="View Full Benchmark Report"
      style="
        padding: 14px 40px;
        background: linear-gradient(90deg, #1976d2 0%, #64b5f6 100%);
        border-radius: 15px;
        box-shadow: 0 6px 24px rgba(25,118,210,0.16);
        margin: 20px 0;
        display: inline-block;
      "
    />
  </a>
</p>

---

## 📑 Table of Contents

1. [What is PipeX?](#what-is-pipex)
2. [Core Concepts](#core-concepts)
3. [Quick Start](#quick-start)
4. [Core Components](#core-components)
5. [Advanced Features](#advanced-features)
6. [Common Patterns](#common-patterns)
7. [Best Practices](#best-practices)
8. [Migration Guide](#migration-guide)
9. [API Reference](#api-reference)
10. [Examples](#examples)

---

## What is PipeX?

**PipeX** is a lightweight, reactive state management library for Flutter that emphasizes:

- ✨ **Fine-grained reactivity**: Only the widgets that depend on changed state rebuild
- 🔄 **Automatic lifecycle management**: No manual cleanup, everything disposes automatically
- 🎯 **Simplicity**: Minimal boilerplate, intuitive API
- 🔒 **Type safety**: Full Dart type system support
- 📦 **Declarative**: State flows naturally through your widget tree
- ⚡ **Performance**: Direct Element manipulation for optimal rebuilds

### Core Metaphor

The library uses a **plumbing/water** metaphor:

- **Pipe<T>**: Carries values (water) through your application
- **Hub**: Central junction where multiple pipes connect and are managed
- **Sink**: Where values flow into your UI and cause updates
- **Well**: Deeper reservoir that draws from multiple pipes at once
- **HubListener**: Valve that triggers actions without affecting the flow

---

## Core Concepts

### 1. Pipe<T> - The Reactive Container

A `Pipe` holds a value and notifies subscribers when it changes.

```dart
final counter = Pipe(0);  // Create a pipe with initial value
counter.value++;           // Update value → triggers rebuilds
print(counter.value);      // Read current value
```

### 2. Hub - The State Manager

A `Hub` groups related Pipes and manages their lifecycle.

```dart
class CounterHub extends Hub {
  late final count = pipe(0);        // Auto-registered!
  late final name = pipe('John');   // Auto-disposed!
  
  void increment() => count.value++;
}
```

### 3. Sink - Single Pipe Subscriber

`Sink` rebuilds when a single Pipe changes.

```dart
Sink(
  pipe: hub.count,
  builder: (context, value) => Text('$value'),
)
```

### 4. Well - Multiple Pipe Subscriber

`Well` rebuilds when ANY of multiple Pipes change.

```dart
Well(
  pipes: [hub.count, hub.name],
  builder: (context) {
    final hub = context.read<MyHub>();
    return Text('${hub.name.value}: ${hub.count.value}');
  },
)
```

### 5. HubProvider - Dependency Injection

Provides a Hub to the widget tree and manages its lifecycle.

```dart
HubProvider(
  create: () => CounterHub(),
  child: HomeScreen(),
)
```

### 6. HubListener - Side Effects

Triggers callbacks based on conditions without rebuilding its child.

```dart
HubListener<CounterHub>(  // Defining Type of Listner is Mandatory or Listner Will throw state error
  listenWhen: (hub) => hub.count.value == 10,
  onConditionMet: () => print('Count reached 10!'),
  child: MyWidget(),
)
```

---

## Quick Start

### 1. Add Dependency

```yaml
dependencies:
  pipe_x: ^latest_version
```

### 2. Create a Hub

```dart
import 'package:pipe_x/pipe_x.dart';

class CounterHub extends Hub {
  // Use pipe() to create pipes - automatically registered and disposed!
  late final count = pipe(0);
  
  // Business logic
  void increment() => count.value++;
  void decrement() => count.value--;
  void reset() => count.value = 0;
  
  // Computed values with getters
  bool get isEven => count.value % 2 == 0;
  String get label => 'Count: ${count.value}';
}
```

### 3. Provide the Hub

```dart
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HubProvider(
        create: () => CounterHub(),
        child: CounterScreen(),
      ),
    );
  }
}
```

### 4. Use in UI

```dart
class CounterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hub = context.read<CounterHub>();
    
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Only this Sink rebuilds when count changes
            Sink(
              pipe: hub.count,
              builder: (context, value) => Text(
                '$value',
                style: TextStyle(fontSize: 48),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: hub.decrement,
                  child: Text('-'),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: hub.increment,
                  child: Text('+'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Core Components

### Pipe<T>

**Purpose**: Reactive container for a value of type `T`.

#### Creating Pipes

```dart
// Standalone (auto-disposes when no subscribers)
final count = Pipe(0);

// In a Hub (Hub manages disposal)
class MyHub extends Hub {
  late final count = pipe(0);
}
```

#### Methods

```dart
// Read value
int value = pipe.value;

// Update value (notifies if changed)
pipe.value = newValue;

// Force update (even if value unchanged)
pipe.pump(newValue);

// Add listener for side effects
pipe.addListener(() => print('Changed!'));

// Remove listener
pipe.removeListener(callback);

// Dispose manually (not needed in Hub)
pipe.dispose();
```

#### Disposed Check

```dart
// All operations check if pipe is disposed
pipe.value; // Throws StateError if disposed
pipe.value = 5; // Throws StateError if disposed
pipe.pump(5); // Throws StateError if disposed
```

---

### Hub

**Purpose**: State manager that groups related Pipes.

#### Creating a Hub

```dart
class ShoppingCartHub extends Hub {
  // Pipes (automatically registered!)
  late final items = pipe<List<Product>>([]);
  late final discount = pipe(0.0);
  late final isLoading = pipe(false);
  
  // Computed values (use getters)
  double get subtotal => items.value.fold(0, (sum, item) => sum + item.price);
  double get total => subtotal * (1 - discount.value);
  int get itemCount => items.value.length;
  
  // Business logic (methods)
  void addItem(Product product) {
    items.value = [...items.value, product];
  }
  
  void removeItem(String productId) {
    items.value = items.value.where((item) => item.id != productId).toList();
  }
  
  void applyDiscount(double percent) {
    discount.value = percent.clamp(0.0, 1.0);
  }
  
  // Cleanup (optional)
  @override
  void onDispose() {
    // Custom cleanup like canceling timers, closing streams, etc.
  }
}
```

#### Hub Methods

```dart
// Listen to all pipe changes in this hub
final removeListener = hub.addListener(() {
  print('Something changed!');
});
// Later: removeListener();

// Get total subscriber count (debugging)
int count = hub.subscriberCount;

// Check if disposed
bool isDisposed = hub.disposed;

// Dispose (usually done by HubProvider)
hub.dispose();
```

---

### Sink<T>

**Purpose**: Widget that subscribes to a single Pipe and rebuilds when it changes.

```dart
Sink<int>(
  pipe: hub.counter,
  builder: (context, value) => Text('Count: $value'),
)
```

**When to use**: Single Pipe, type-safe access to value in builder.

---

### Well

**Purpose**: Widget that subscribes to multiple Pipes and rebuilds when ANY change.

```dart
Well(
  pipes: [hub.firstName, hub.lastName, hub.age],
  builder: (context) {
    final hub = context.read<UserHub>();
    return Text(
      '${hub.firstName.value} ${hub.lastName.value}, ${hub.age.value}',
    );
  },
)
```

**When to use**: Multiple Pipes, computed values from multiple sources.

---

### HubProvider

**Purpose**: Provides a Hub to the widget tree and manages its lifecycle.

```dart
HubProvider<CounterHub>(
  create: () => CounterHub(),
  child: MyApp(),
)
```

#### Access Methods

```dart
// context.read<T>() - No rebuild dependency (use in callbacks)
final hub = context.read<CounterHub>();
hub.increment();

// HubProvider.of<T>(context) - Creates dependency (rarely needed)
final hub = HubProvider.of<CounterHub>(context);

// HubProvider.read<T>(context) - Same as context.read<T>()
final hub = HubProvider.read<CounterHub>(context);
```

---

### MultiHubProvider

**Purpose**: Provide multiple Hubs without nesting.

```dart
MultiHubProvider(
  hubs: [
    () => AuthHub(),
    () => ThemeHub(),
    () => SettingsHub(),
  ],
  child: MyApp(),
)
```

**Access**: Same as `HubProvider` - use `context.read<T>()`.

---

### HubListener

**Purpose**: Execute side effects based on Hub state without rebuilding the child.

```dart
HubListener<CounterHub>(
  listenWhen: (hub) => hub.count.value == 10,
  onConditionMet: () {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Count reached 10!'),
      ),
    );
  },
  child: MyWidget(), // This never rebuilds due to the listener
)
```

**When to use**:
- Navigation based on state
- Show dialogs/snackbars
- Analytics/logging
- Any side effect that shouldn't trigger a rebuild

---

## Advanced Features

### 1. Mutable Objects with pump()

For objects where you mutate internal state without changing the reference:

```dart
class User {
  String name;
  int age;
  
  User({required this.name, required this.age});
}

class UserHub extends Hub {
  late final user = pipe(User(name: 'John', age: 25));
  
  void updateName(String name) {
    user.value.name = name;  // Mutate object
    user.pump(user.value);   // Force update (reference unchanged)
  }
}
```

**Why?** `shouldNotify()` checks reference equality. Mutations don't change the reference, so `pump()` bypasses the check.

**Alternative** (preferred): Use immutable updates:

```dart
void updateName(String name) {
  user.value = User(
    name: name,
    age: user.value.age,
  );
}
```

---

### 2. Hub Listeners

Listen to all changes in a Hub for side effects:

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  VoidCallback? _removeListener;
  
  @override
  void initState() {
    super.initState();
    final hub = context.read<DataHub>();
    
    _removeListener = hub.addListener(() {
      // Called whenever ANY pipe in this hub changes
      print('Hub state changed!');
      // Do NOT call setState here - use HubListener widget instead
    });
  }
  
  @override
  void dispose() {
    _removeListener?.call(); // Cleanup
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

**Better alternative**: Use `HubListener` widget (handles lifecycle automatically).

---

### 3. Granular Reactivity

PipeX allows extremely fine-grained control over what rebuilds:

```dart
class ProfileHub extends Hub {
  late final userProfile = pipe<UserProfile?>(null);
  late final gender = pipe<String>('Male');
  late final age = pipe<int>(25);
}

// In UI:
Sink(
  pipe: hub.userProfile,
  builder: (context, profile) {
    if (profile == null) return CircularProgressIndicator();
    
    return Column(
      children: [
        // Static fields (rebuild only when userProfile changes)
        Text('Name: ${profile.name}'),
        Text('Email: ${profile.email}'),
        Text('Phone: ${profile.phone}'),
        
        // Separate reactive fields (rebuild independently!)
        Sink(
          pipe: hub.gender,
          builder: (context, gender) => Text('Gender: $gender'),
        ),
        Sink(
          pipe: hub.age,
          builder: (context, age) => Text('Age: $age'),
        ),
      ],
    );
  },
)
```

**Result**:
- Change `gender` → Only gender Sink rebuilds
- Change `age` → Only age Sink rebuilds
- Reload profile → Outer Sink rebuilds (all static fields + nested Sinks get new instances but don't rebuild unless their values changed)

---

### 4. Standalone Pipes (Auto-Dispose)

Pipes can be used outside Hubs with automatic disposal:

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late final counter = Pipe(0); // Auto-disposes when no subscribers
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Sink(
          pipe: counter,
          builder: (context, value) => Text('$value'),
        ),
        ElevatedButton(
          onPressed: () => counter.value++,
          child: Text('+'),
        ),
      ],
    );
  }
}
```

**Auto-dispose behavior**: When the last widget unsubscribes (widget unmounts), the Pipe automatically disposes itself.

---

## Common Patterns

### Pattern 1: Form Management

```dart
class LoginHub extends Hub {
  late final email = pipe('');
  late final password = pipe('');
  late final isLoading = pipe(false);
  late final error = pipe<String?>(null);
  
  // Validation
  bool get isEmailValid => email.value.contains('@');
  bool get isPasswordValid => password.value.length >= 6;
  bool get canSubmit => isEmailValid && isPasswordValid && !isLoading.value;
  
  Future<void> login() async {
    if (!canSubmit) return;
    
    isLoading.value = true;
    error.value = null;
    
    try {
      await authService.login(email.value, password.value);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
```

---

### Pattern 2: Async Data Loading

```dart
class DataHub extends Hub {
  late final isLoading = pipe(false);
  late final error = pipe<String?>(null);
  late final userProfile = pipe<UserProfile?>(null);
  late final gender = pipe<String>('Male');
  late final age = pipe<int>(25);

  Future<void> fetchUserProfile() async {
    isLoading.value = true;
    error.value = null;

    try {
      await Future.delayed(Duration(seconds: 2)); // Simulate API
      
      userProfile.value = UserProfile(
        id: 'USR-12345',
        name: 'John Doe',
        email: 'john@example.com',
        // ... more fields
      );
      
      gender.value = 'Male';
      age.value = 28;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
```

**UI with Loading Overlay**:

```dart
Stack(
  children: [
    // Main content
    Sink(
      pipe: hub.userProfile,
      builder: (context, profile) {
        if (profile == null) return Center(child: Text('No data'));
        return ProfileView(profile: profile);
      },
    ),
    
    // Loading overlay
    Sink(
      pipe: hub.isLoading,
      builder: (context, isLoading) {
        if (!isLoading) return SizedBox.shrink();
        return Container(
          color: Colors.black54,
          child: Center(child: CircularProgressIndicator()),
        );
      },
    ),
  ],
)
```

---

### Pattern 3: Computed Values

```dart
class CartHub extends Hub {
  late final items = pipe<List<CartItem>>([]);
  late final taxRate = pipe(0.08);
  late final couponDiscount = pipe(0.0);
  
  // Computed with getters
  double get subtotal => items.value.fold(0.0, (sum, item) => sum + item.price);
  double get tax => subtotal * taxRate.value;
  double get discount => subtotal * couponDiscount.value;
  double get total => subtotal + tax - discount;
}
```

---

### Pattern 4: Scoped vs Global State

**Global Hub** (app-wide):

```dart
MaterialApp(
  home: MultiHubProvider(
    hubs: [
      () => AuthHub(),      // Lives for app lifetime
      () => ThemeHub(),     // Lives for app lifetime
      () => SettingsHub(),  // Lives for app lifetime
    ],
    child: HomeScreen(),
  ),
)
```

**Scoped Hub** (screen-specific):

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => HubProvider(
      create: () => EditProductHub(product),  // Disposed on pop
      child: EditProductScreen(),
    ),
  ),
)
```

---

## Best Practices

### 1. Keep Sinks Small

❌ **Bad** - Entire screen rebuilds:

```dart
Sink(
  pipe: hub.counter,
  builder: (context, value) => Scaffold(...), // Too large!
)
```

✅ **Good** - Only necessary parts rebuild:

```dart
Scaffold(
  appBar: AppBar(
    title: Sink(
      pipe: hub.counter,
      builder: (context, value) => Text('$value'), // Granular!
    ),
  ),
  body: ProfileBody(), // Never rebuilds
)
```

---

### 2. Use Getters for Computed Values

❌ **Bad** - Redundant state:

```dart
class CounterHub extends Hub {
  late final count = pipe(0);
  late final isEven = pipe(false); // Don't do this!
  
  void increment() {
    count.value++;
    isEven.value = count.value % 2 == 0; // Manual sync
  }
}
```

✅ **Good** - Computed:

```dart
class CounterHub extends Hub {
  late final count = pipe(0);
  bool get isEven => count.value % 2 == 0; // Computed!
  
  void increment() => count.value++;
}
```

---

### 3. Use Well for Multiple Pipes

❌ **Bad** - Nested Sinks:

```dart
Sink(
  pipe: hub.firstName,
  builder: (context, first) => Sink(
    pipe: hub.lastName,
    builder: (context, last) => Text('$first $last'),
  ),
)
```

✅ **Good** - Single Well:

```dart
Well(
  pipes: [hub.firstName, hub.lastName],
  builder: (context) {
    final hub = context.read<UserHub>();
    return Text('${hub.firstName.value} ${hub.lastName.value}');
  },
)
```

---

### 4. Separation of Concerns

❌ **Bad** - Logic in UI:

```dart
ElevatedButton(
  onPressed: () {
    final cart = context.read<CartHub>();
    cart.items.value = [...cart.items.value, newItem];
    cart.total.value = cart.items.value.fold(0, (sum, i) => sum + i.price);
  },
  child: Text('Add'),
)
```

✅ **Good** - Logic in Hub:

```dart
// In Hub:
void addItem(CartItem item) {
  items.value = [...items.value, item];
}

// In UI:
@override
Widget build(BuildContext context) {
  final hub = context.read<CartHub>();
  
  return ElevatedButton(
    onPressed: () => hub.addItem(newItem),
    child: Text('Add'),
  );
}
```

---

### 5. Proper Error Handling

```dart
class DataHub extends Hub {
  late final data = pipe<List<Item>>([]);
  late final isLoading = pipe(false);
  late final error = pipe<String?>(null);
  
  Future<void> fetchData() async {
    isLoading.value = true;
    error.value = null; // Clear previous errors
    
    try {
      final result = await api.getData();
      data.value = result;
    } catch (e) {
      error.value = e.toString();
      // Optional: Log to analytics
    } finally {
      isLoading.value = false; // Always cleanup
    }
  }
}
```

---

### 6. Use HubListener for Side Effects

❌ **Bad** - Side effects in build:

```dart
@override
Widget build(BuildContext context) {
  final hub = context.read<CartHub>();
  
  if (hub.itemCount.value > 10) {
    // ❌ Don't do this in build!
    showDialog(...);
  }
  
  return MyWidget();
}
```

✅ **Good** - Use HubListener:

```dart
HubListener<CartHub>(
  listenWhen: (hub) => hub.items.value.length > 10,
  onConditionMet: () {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Cart has more than 10 items!'),
      ),
    );
  },
  child: MyWidget(),
)
```

---

## Migration Guide

### From setState

**Before**:

```dart
class _CounterState extends State<CounterScreen> {
  int _count = 0;
  
  void _increment() => setState(() => _count++);
  
  @override
  Widget build(BuildContext context) {
    return Text('$_count'); // Entire widget rebuilds
  }
}
```

**After**:

```dart
class CounterHub extends Hub {
  late final count = pipe(0);
  void increment() => count.value++;
}

class CounterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hub = context.read<CounterHub>();
    
    return Sink(
      pipe: hub.count,
      builder: (context, value) => Text('$value'), // Only Text rebuilds
    );
  }
}
```

---

### From Provider/ChangeNotifier

**Before**:

```dart
class Counter with ChangeNotifier {
  int _count = 0;
  int get count => _count;
  
  void increment() {
    _count++;
    notifyListeners(); // Manual notification
  }
}

// Usage
Consumer<Counter>(
  builder: (context, counter, child) => Text('${counter.count}'),
)
```

**After**:

```dart
class CounterHub extends Hub {
  late final count = pipe(0);
  void increment() => count.value++; // Auto-notification
}

// Usage
@override
Widget build(BuildContext context) {
  final hub = context.read<CounterHub>();
  
  return Sink(
    pipe: hub.count,
    builder: (context, value) => Text('$value'),
  );
}
```

---

### From BLoC

**Before**:

```dart
// Events
class IncrementEvent extends CounterEvent {}

// State
class CounterState {
  final int count;
  CounterState(this.count);
  CounterState copyWith({int? count}) => CounterState(count ?? this.count);
}

// BLoC
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(CounterState(0)) {
    on<IncrementEvent>((event, emit) {
      emit(state.copyWith(count: state.count + 1));
    });
  }
}

// Usage
BlocBuilder<CounterBloc, CounterState>(
  builder: (context, state) => Text('${state.count}'),
)

// Actions
context.read<CounterBloc>().add(IncrementEvent());
```

**After**:

```dart
// Hub (combines BLoC + State)
class CounterHub extends Hub {
  late final count = pipe(0);
  void increment() => count.value++; // Direct!
}

// Usage
@override
Widget build(BuildContext context) {
  final hub = context.read<CounterHub>();
  
  return Column(
    children: [
      Sink(
        pipe: hub.count,
        builder: (context, value) => Text('$value'),
      ),
      ElevatedButton(
        onPressed: hub.increment, // Direct!
        child: Text('+'),
      ),
    ],
  );
}
```

**Key differences**:
- ❌ No Event classes
- ❌ No State classes with copyWith
- ❌ No emit()
- ✅ Direct method calls
- ✅ Automatic notifications
- ✅ Less boilerplate

---

## API Reference

### Pipe<T>

```dart
// Constructor
Pipe(T initialValue, {bool? autoDispose})

// Properties
T value                     // Get/set value
bool disposed               // Check if disposed
int subscriberCount         // Number of subscribers

// Methods
void pump(T newValue)       // Force update
void addListener(VoidCallback callback)
void removeListener(VoidCallback callback)
void dispose()              // Cleanup
```

---

### Hub

```dart
// Constructor
Hub()

// Properties
bool disposed               // Check if disposed
int subscriberCount         // Total subscribers

// Methods (Protected)
@protected Pipe<T> pipe<T>(T initialValue, {String? key})
@protected T registerPipe<T extends Pipe>(T pipe, [String? key])
@protected void checkNotDisposed()
@protected void onDispose()

// Public Methods
VoidCallback addListener(VoidCallback callback)
void dispose()
```

---

### Sink<T>

```dart
Sink({
  required Pipe<T> pipe,
  required Widget Function(BuildContext, T) builder,
})
```

---

### Well

```dart
Well({
  required List<Pipe> pipes,
  required Widget Function(BuildContext) builder,
})
```

---

### HubProvider<T>

```dart
HubProvider({
  required T Function() create,
  required Widget child,
})

// Static methods
static T of<T extends Hub>(BuildContext context)
static T read<T extends Hub>(BuildContext context)
```

---

### HubListener<T>

```dart
HubListener({
  required bool Function(T hub) listenWhen,
  required VoidCallback onConditionMet,
  required Widget child,
})
```

---

### MultiHubProvider

```dart
MultiHubProvider({
  required List<Hub Function()> hubs,
  required Widget child,
})
```

---

### BuildContext Extension

```dart
extension HubBuildContextExtension on BuildContext {
  T read<T extends Hub>()  // Same as HubProvider.read<T>(this)
}
```

---

## Examples

Check the `/example` folder for comprehensive examples:

1. **Basic Counter** - Simple state management
2. **Multiple Sinks** - Granular rebuilds
3. **Well Widget** - Multiple pipe subscriptions
4. **Form Management** - Input handling with validation
5. **Computed Values** - Getters for derived state
6. **List Management** - Adding/removing items
7. **Conditional Rendering** - Loading/error/success states
8. **Multi-Hub** - Multiple state managers
9. **Scoped Hub** - Screen-specific state
10. **Side Effects** - HubListener for actions
11. **Async Operations** - API calls with loading states
12. **Mutable Objects** - Using pump() for complex objects

---

## Performance Considerations

1. **Granular Rebuilds**: PipeX rebuilds only the exact widgets subscribed to changed state
2. **No Unnecessary Subscriptions**: Use `context.read<T>()` in callbacks (no rebuild dependency)
3. **Element-Level Control**: Direct `markNeedsBuild()` calls for optimal performance
4. **Auto-Disposal**: Automatic cleanup prevents memory leaks
5. **Type Safety**: Compile-time checks prevent runtime errors

---

## Testing

### Unit Testing Hubs

```dart
test('CounterHub increments', () {
  final hub = CounterHub();
  
  expect(hub.count.value, 0);
  hub.increment();
  expect(hub.count.value, 1);
  
  hub.dispose(); // Cleanup
});
```

### Widget Testing

```dart
testWidgets('Sink rebuilds on pipe change', (tester) async {
  final hub = CounterHub();
  
  await tester.pumpWidget(
    MaterialApp(
      home: HubProvider(
        create: () => hub,
        child: Sink(
          pipe: hub.count,
          builder: (context, value) => Text('$value'),
        ),
      ),
    ),
  );
  
  expect(find.text('0'), findsOneWidget);
  
  hub.increment();
  await tester.pump();
  
  expect(find.text('1'), findsOneWidget);
});
```

---

## Common Questions

**Q: Can I use PipeX with other state management?**  
A: Yes! PipeX works alongside Provider, BLoC, Riverpod, etc.

**Q: How do I persist state?**  
A: Add persistence in your Hub methods:

```dart
class CounterHub extends Hub {
  late final count = pipe(prefs.getInt('count') ?? 0);
  
  void increment() {
    count.value++;
    prefs.setInt('count', count.value);
  }
}
```

**Q: Does PipeX work without Flutter?**  
A: Core classes (`Pipe`, `Hub`) work in pure Dart. Widgets require Flutter.

**Q: What about code generation?**  
A: PipeX intentionally avoids code generation for simplicity.

---

## License & Credits

**Design Inspirations:**
- MobX: Reactivity concepts
- Provider: Dependency injection
- Signals: Fine-grained reactivity
- BLoC: Business logic separation

**Philosophy**: Take the best ideas and create something simpler.

---

## Contributing

Found a bug? Have a feature request? Please [file an issue](https://github.com/navaneethkrishnaindeed/pipe_x/issues)!

---

## Support

- 📚 [Documentation](https://pub.dev/documentation/pipe_x)
- 💬 [Discord Community](https://discord.gg/rWKewdGH)
- 🐛 [Issue Tracker](https://github.com/navaneethkrishnaindeed/pipe_x/issues)
- ⭐ [Star on GitHub](https://github.com/navaneethkrishnaindeed/pipe_x)

---

**Happy coding with PipeX!** 🔧✨
