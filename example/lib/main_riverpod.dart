import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Custom ProviderObserver for debugging and logging
class LoggerObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    debugPrint('''
{
  "provider": "${provider.name ?? provider.runtimeType}",
  "previousValue": "$previousValue",
  "newValue": "$newValue"
}''');
  }

  @override
  void providerDidFail(
    ProviderBase provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    debugPrint(
        'Provider ${provider.name ?? provider.runtimeType} failed: $error');
  }
}

void main() {
  runApp(
    // ProviderScope is required at the root for Riverpod
    // Adding ProviderObserver for advanced debugging
    ProviderScope(
      observers: [LoggerObserver()],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      showPerformanceOverlay: true,
      title: 'Riverpod State Management Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      onGenerateRoute: _onGenerateRoute,
    );
  }

  static Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const ExamplesListScreen());
      case '/counter':
        return MaterialPageRoute(builder: (_) => const CounterExample());
      case '/multiple-pipes':
        return MaterialPageRoute(builder: (_) => const MultiplePipesExample());
      case '/standalone-pipe':
        return MaterialPageRoute(builder: (_) => const StandalonePipeExample());
      case '/single-sink':
        return MaterialPageRoute(builder: (_) => const SingleSinkExample());
      case '/multiple-sinks':
        return MaterialPageRoute(builder: (_) => const MultipleSinksExample());
      case '/well':
        return MaterialPageRoute(builder: (_) => const WellExample());
      case '/hub-provider':
        return MaterialPageRoute(builder: (_) => const HubProviderExample());
      case '/multi-hub-provider':
        return MaterialPageRoute(
            builder: (_) => const MultiHubProviderExample());
      case '/scoped-vs-global':
        return MaterialPageRoute(builder: (_) => const ScopedVsGlobalExample());
      case '/computed-values':
        return MaterialPageRoute(builder: (_) => const ComputedValuesExample());
      case '/async':
        return MaterialPageRoute(builder: (_) => const AsyncExample());
      case '/form':
        return MaterialPageRoute(builder: (_) => const FormExample());
      case '/class-type':
        return MaterialPageRoute(builder: (_) => const ClassTypeExample());
      default:
        return null;
    }
  }
}

class ExamplesListScreen extends StatelessWidget {
  const ExamplesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌊 Riverpod Examples'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          _buildSection(context, '📦 Basic Examples', const [
            _Example('Counter with Provider', '/counter'),
            _Example('Multiple Providers', '/multiple-pipes'),
            _Example('Standalone Provider (Scoped)', '/standalone-pipe'),
            _Example('Class Type in Provider', '/class-type'),
          ]),
          _buildSection(context, '🔄 Reactive Widgets', const [
            _Example('Single Consumer', '/single-sink'),
            _Example('Multiple Consumers', '/multiple-sinks'),
            _Example('Multiple Providers Watching', '/well'),
          ]),
          _buildSection(context, '🏗️ Dependency Injection', const [
            _Example('Provider Basics', '/hub-provider'),
            _Example('Multiple Providers', '/multi-hub-provider'),
            _Example('Scoped vs Global', '/scoped-vs-global'),
          ]),
          _buildSection(context, '⚡ Advanced Patterns', const [
            _Example('Computed Values (Getters)', '/computed-values'),
            _Example('Async Operations', '/async'),
            _Example('Form Management', '/form'),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<_Example> examples) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...examples.map((example) => ListTile(
              leading: const Icon(Icons.arrow_forward_ios, size: 16),
              title: Text(example.title),
              onTap: () => Navigator.pushNamed(context, example.route),
            )),
        const Divider(),
      ],
    );
  }
}

class _Example {
  final String title;
  final String route;
  const _Example(this.title, this.route);
}

// ============================================================================
// EXAMPLE 1: Counter with Provider
// ============================================================================

// StateNotifier for counter logic
class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(0);

  void increment() => state++;
  void decrement() => state--;
  void reset() => state = 0;
}

// Provider definition
final counterProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier();
});

class CounterExample extends ConsumerWidget {
  const CounterExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Counter Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Basic counter with StateNotifier & Consumer:'),
            const SizedBox(height: 16),
            Text(
              '$count',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: 'dec',
                  onPressed: () =>
                      ref.read(counterProvider.notifier).decrement(),
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  heroTag: 'inc',
                  onPressed: () =>
                      ref.read(counterProvider.notifier).increment(),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(counterProvider.notifier).reset(),
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 2: Multiple Providers
// ============================================================================

// Individual providers for each piece of state
final nameProvider = StateProvider<String>((ref) => 'John Doe');
final ageProvider = StateProvider<int>((ref) => 25);
final emailProvider = StateProvider<String>((ref) => 'john@example.com');

// Computed value using a provider that depends on others
final userSummaryProvider = Provider<String>((ref) {
  final name = ref.watch(nameProvider);
  final age = ref.watch(ageProvider);
  return '$name, $age years old';
});

class MultiplePipesExample extends ConsumerWidget {
  const MultiplePipesExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(nameProvider);
    final age = ref.watch(ageProvider);
    final email = ref.watch(emailProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Multiple Providers')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Multiple independent providers:'),
            const SizedBox(height: 24),
            Text('Name: $name', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Age: $age', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Email: $email', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(nameProvider.notifier).state = 'Jane Smith';
                ref.read(ageProvider.notifier).state = 30;
                ref.read(emailProvider.notifier).state = 'jane@example.com';
              },
              child: const Text('Update User'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 3: Standalone Provider (Scoped with autoDispose)
// ============================================================================

// Using autoDispose modifier makes providers automatically dispose when no longer watched
final standaloneCounterProvider = StateProvider.autoDispose<int>((ref) => 0);
final standaloneMessageProvider =
    StateProvider.autoDispose<String>((ref) => 'Hello!');

class StandalonePipeExample extends ConsumerWidget {
  const StandalonePipeExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(standaloneCounterProvider);
    final message = ref.watch(standaloneMessageProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Standalone Provider')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Providers with autoDispose (auto-dispose on unmount):'),
            const SizedBox(height: 24),
            Text(
              'Counter: $counter',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 18, color: Colors.blue),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final newCount = counter + 1;
                ref.read(standaloneCounterProvider.notifier).state = newCount;
                ref.read(standaloneMessageProvider.notifier).state =
                    'Count: $newCount';
              },
              child: const Text('Increment'),
            ),
            const SizedBox(height: 16),
            Text(
              'These providers will auto-dispose when you go back',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 4: Single Consumer
// ============================================================================

// StateNotifier for timer
class TimerNotifier extends StateNotifier<int> {
  TimerNotifier() : super(0) {
    _startTimer();
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        state++;
        return true;
      }
      return false;
    });
  }
}

final timerProvider =
    StateNotifierProvider.autoDispose<TimerNotifier, int>((ref) {
  return TimerNotifier();
});

class SingleSinkExample extends ConsumerWidget {
  const SingleSinkExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seconds = ref.watch(timerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Single Consumer')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Only the Consumer rebuilds, not the entire screen:'),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Timer: $seconds seconds',
                style:
                    const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'This text never rebuilds!',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 5: Multiple Consumers
// ============================================================================

// Multiple counter providers
final counterAProvider = StateProvider<int>((ref) => 0);
final counterBProvider = StateProvider<int>((ref) => 0);
final counterCProvider = StateProvider<int>((ref) => 0);

class MultipleSinksExample extends ConsumerWidget {
  const MultipleSinksExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Multiple Consumers')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Each Consumer rebuilds independently:'),
            const SizedBox(height: 32),
            _CounterRow('Counter A', counterAProvider),
            const SizedBox(height: 16),
            _CounterRow('Counter B', counterBProvider),
            const SizedBox(height: 16),
            _CounterRow('Counter C', counterCProvider),
          ],
        ),
      ),
    );
  }
}

class _CounterRow extends ConsumerWidget {
  final String label;
  final StateProvider<int> provider;

  const _CounterRow(this.label, this.provider);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(provider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 18)),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('$value',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => ref.read(provider.notifier).state++,
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================================
// EXAMPLE 6: Multiple Providers Watching (Well equivalent)
// ============================================================================

// Calculator state providers
final calculatorAProvider = StateProvider<int>((ref) => 5);
final calculatorBProvider = StateProvider<int>((ref) => 10);
final calculatorOperationProvider = StateProvider<String>((ref) => '+');

// Computed result provider
final calculatorResultProvider = Provider<double>((ref) {
  final a = ref.watch(calculatorAProvider);
  final b = ref.watch(calculatorBProvider);
  final operation = ref.watch(calculatorOperationProvider);

  switch (operation) {
    case '+':
      return (a + b).toDouble();
    case '-':
      return (a - b).toDouble();
    case '*':
      return (a * b).toDouble();
    case '/':
      return b != 0 ? a / b : 0;
    default:
      return 0;
  }
});

class WellExample extends ConsumerWidget {
  const WellExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(calculatorAProvider);
    final b = ref.watch(calculatorBProvider);
    final operation = ref.watch(calculatorOperationProvider);
    final result = ref.watch(calculatorResultProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Multiple Providers Watching')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Consumer watches multiple providers at once:'),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$a $operation $b = ${result.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () =>
                      ref.read(calculatorAProvider.notifier).state++,
                  child: const Text('A+'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(calculatorBProvider.notifier).state++,
                  child: const Text('B+'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: ['+', '-', '*', '/'].map((op) {
                return ElevatedButton(
                  onPressed: () =>
                      ref.read(calculatorOperationProvider.notifier).state = op,
                  child: Text(op),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 7: Provider Basics (Theme switching)
// ============================================================================

final isDarkThemeProvider = StateProvider<bool>((ref) => false);

class HubProviderExample extends ConsumerWidget {
  const HubProviderExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkThemeProvider);

    return MaterialApp(
      theme: isDark ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Provider Example'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isDark ? '🌙 Dark Mode' : '☀️ Light Mode',
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () =>
                    ref.read(isDarkThemeProvider.notifier).state = !isDark,
                child: const Text('Toggle Theme'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 8: Multiple Providers (Auth + Settings)
// ============================================================================

// Auth state
class AuthState {
  final bool isLoggedIn;
  final String username;

  AuthState({required this.isLoggedIn, required this.username});

  AuthState copyWith({bool? isLoggedIn, String? username}) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      username: username ?? this.username,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState(isLoggedIn: false, username: 'Guest'));

  void login(String name) {
    state = AuthState(isLoggedIn: true, username: name);
  }

  void logout() {
    state = AuthState(isLoggedIn: false, username: 'Guest');
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// Settings providers
final fontSizeProvider = StateProvider<double>((ref) => 16.0);
final enableNotificationsProvider = StateProvider<bool>((ref) => true);

class MultiHubProviderExample extends ConsumerWidget {
  const MultiHubProviderExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final fontSize = ref.watch(fontSizeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Multiple Providers')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Multiple Providers without nesting:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Auth Status: ${auth.isLoggedIn ? "Logged In" : "Logged Out"}'),
                    Text('Username: ${auth.username}'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (auth.isLoggedIn) {
                          ref.read(authProvider.notifier).logout();
                        } else {
                          ref.read(authProvider.notifier).login('John Doe');
                        }
                      },
                      child: Text(auth.isLoggedIn ? 'Logout' : 'Login'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Font Size: ${fontSize.toInt()}',
                        style: TextStyle(fontSize: fontSize)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () =>
                              ref.read(fontSizeProvider.notifier).state -= 2,
                          child: const Text('A-'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () =>
                              ref.read(fontSizeProvider.notifier).state += 2,
                          child: const Text('A+'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 9: Scoped vs Global
// ============================================================================

// Global provider (survives navigation)
final globalCounterProvider = StateProvider<int>((ref) => 0);

// Scoped provider (created per screen, auto-disposes)
final scopedCounterProvider = StateProvider.autoDispose<int>((ref) => 0);

class ScopedVsGlobalExample extends ConsumerWidget {
  const ScopedVsGlobalExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalCount = ref.watch(globalCounterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Scoped vs Global')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Global Provider (survives navigation):'),
            Text('Global Count: $globalCount',
                style: const TextStyle(fontSize: 24)),
            ElevatedButton(
              onPressed: () => ref.read(globalCounterProvider.notifier).state++,
              child: const Text('Increment Global'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ScopedScreen()),
                );
              },
              child: const Text('Open Scoped Screen'),
            ),
          ],
        ),
      ),
    );
  }
}

class ScopedScreen extends ConsumerWidget {
  const ScopedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scopedCount = ref.watch(scopedCounterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Scoped Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Scoped Provider (disposed on back):'),
            Text('Scoped Count: $scopedCount',
                style: const TextStyle(fontSize: 24)),
            ElevatedButton(
              onPressed: () => ref.read(scopedCounterProvider.notifier).state++,
              child: const Text('Increment Scoped'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 10: Computed Values (Getters)
// ============================================================================

// Shopping cart state
class ShoppingState {
  final List<String> items;
  final double pricePerItem;

  ShoppingState({required this.items, required this.pricePerItem});

  ShoppingState copyWith({List<String>? items, double? pricePerItem}) {
    return ShoppingState(
      items: items ?? this.items,
      pricePerItem: pricePerItem ?? this.pricePerItem,
    );
  }

  int get itemCount => items.length;
  double get total => itemCount * pricePerItem;
  String get summary => '$itemCount items - \$${total.toStringAsFixed(2)}';
}

class ShoppingNotifier extends StateNotifier<ShoppingState> {
  ShoppingNotifier() : super(ShoppingState(items: [], pricePerItem: 9.99));

  void addItem(String item) {
    state = state.copyWith(items: [...state.items, item]);
  }

  void clear() {
    state = state.copyWith(items: []);
  }
}

final shoppingProvider =
    StateNotifierProvider<ShoppingNotifier, ShoppingState>((ref) {
  return ShoppingNotifier();
});

class ComputedValuesExample extends ConsumerWidget {
  const ComputedValuesExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopping = ref.watch(shoppingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Computed Values')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Use getters for computed/derived state:',
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Items: ${shopping.itemCount}',
                        style: const TextStyle(fontSize: 18)),
                    Text(
                        'Price per item: \$${shopping.pricePerItem.toStringAsFixed(2)}'),
                    const Divider(),
                    Text(
                      'Total: \$${shopping.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: shopping.items.isEmpty
                  ? const Center(child: Text('No items yet'))
                  : ListView.builder(
                      itemCount: shopping.items.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.shopping_cart),
                          title: Text(shopping.items[index]),
                        );
                      },
                    ),
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref
                          .read(shoppingProvider.notifier)
                          .addItem('Item ${shopping.itemCount + 1}');
                    },
                    child: const Text('Add Item'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => ref.read(shoppingProvider.notifier).clear(),
                  child: const Text('Clear'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 11: Async Operations
// ============================================================================

// Async data state
class AsyncDataState {
  final bool isLoading;
  final String? data;
  final String? error;

  AsyncDataState({
    required this.isLoading,
    this.data,
    this.error,
  });
}

class AsyncDataNotifier extends StateNotifier<AsyncDataState> {
  AsyncDataNotifier() : super(AsyncDataState(isLoading: false));

  Future<void> fetchData() async {
    state = AsyncDataState(isLoading: true);

    try {
      await Future.delayed(const Duration(seconds: 2));
      state = AsyncDataState(
        isLoading: false,
        data: 'Data loaded at ${DateTime.now().toIso8601String()}',
      );
    } catch (e) {
      state = AsyncDataState(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final asyncDataProvider =
    StateNotifierProvider<AsyncDataNotifier, AsyncDataState>((ref) {
  return AsyncDataNotifier();
});

class AsyncExample extends ConsumerWidget {
  const AsyncExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataState = ref.watch(asyncDataProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Async Operations')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Builder(
            builder: (context) {
              if (dataState.isLoading) {
                return const CircularProgressIndicator();
              }

              if (dataState.error != null) {
                return Text('Error: ${dataState.error}',
                    style: const TextStyle(color: Colors.red));
              }

              if (dataState.data != null) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(dataState.data!, textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () =>
                          ref.read(asyncDataProvider.notifier).fetchData(),
                      child: const Text('Reload'),
                    ),
                  ],
                );
              }

              return ElevatedButton(
                onPressed: () =>
                    ref.read(asyncDataProvider.notifier).fetchData(),
                child: const Text('Fetch Data'),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 12: Form Management
// ============================================================================

// Form state
class FormState {
  final String name;
  final String email;
  final String age;

  FormState({
    required this.name,
    required this.email,
    required this.age,
  });

  FormState copyWith({String? name, String? email, String? age}) {
    return FormState(
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
    );
  }

  bool get isNameValid => name.length >= 3;
  bool get isEmailValid => email.contains('@');
  bool get isAgeValid => int.tryParse(age) != null && int.parse(age) >= 18;
  bool get isFormValid => isNameValid && isEmailValid && isAgeValid;
}

class FormNotifier extends StateNotifier<FormState> {
  FormNotifier() : super(FormState(name: '', email: '', age: ''));

  void updateName(String name) => state = state.copyWith(name: name);
  void updateEmail(String email) => state = state.copyWith(email: email);
  void updateAge(String age) => state = state.copyWith(age: age);

  void submit() {
    if (state.isFormValid) {
      // Handle submission
    }
  }
}

final formProvider = StateNotifierProvider<FormNotifier, FormState>((ref) {
  return FormNotifier();
});

class FormExample extends ConsumerWidget {
  const FormExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(formProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Form Management')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration:
                  const InputDecoration(labelText: 'Name (min 3 chars)'),
              onChanged: (value) =>
                  ref.read(formProvider.notifier).updateName(value),
            ),
            Text(
              formState.isNameValid ? '✓ Valid' : '✗ Too short',
              style: TextStyle(
                  color: formState.isNameValid ? Colors.green : Colors.red,
                  fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Email'),
              onChanged: (value) =>
                  ref.read(formProvider.notifier).updateEmail(value),
            ),
            Text(
              formState.isEmailValid ? '✓ Valid' : '✗ Invalid email',
              style: TextStyle(
                  color: formState.isEmailValid ? Colors.green : Colors.red,
                  fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Age (18+)'),
              keyboardType: TextInputType.number,
              onChanged: (value) =>
                  ref.read(formProvider.notifier).updateAge(value),
            ),
            Text(
              formState.isAgeValid ? '✓ Valid' : '✗ Must be 18+',
              style: TextStyle(
                  color: formState.isAgeValid ? Colors.green : Colors.red,
                  fontSize: 12),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: formState.isFormValid
                  ? () => ref.read(formProvider.notifier).submit()
                  : null,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 13: Class Type in Provider
// ============================================================================

/// User profile model class (MUTABLE)
/// This class demonstrates using mutable objects with StateNotifier
class UserProfile {
  String name;
  int age;
  String email;
  String bio;
  bool isPremium;

  UserProfile({
    required this.name,
    required this.age,
    required this.email,
    required this.bio,
    required this.isPremium,
  });

  // For Riverpod, it's better to create a copy method for immutable updates
  UserProfile copyWith({
    String? name,
    int? age,
    String? email,
    String? bio,
    bool? isPremium,
  }) {
    return UserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}

class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier()
      : super(UserProfile(
          name: 'John Doe',
          age: 28,
          email: 'john@example.com',
          bio: 'Flutter developer',
          isPremium: false,
        ));

  /// Riverpod prefers immutable updates using copyWith
  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void updateAge(int age) {
    state = state.copyWith(age: age);
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updateBio(String bio) {
    state = state.copyWith(bio: bio);
  }

  void togglePremium() {
    state = state.copyWith(isPremium: !state.isPremium);
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  return UserProfileNotifier();
});

class ClassTypeExample extends ConsumerWidget {
  const ClassTypeExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Class Type in Provider')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Using classes in StateNotifier:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Entire object is stored. Use copyWith() for immutable updates.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Display user profile
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor:
                              user.isPremium ? Colors.amber : Colors.grey,
                          child: Text(
                            user.name.isNotEmpty ? user.name[0] : '?',
                            style: const TextStyle(
                                fontSize: 24, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    user.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (user.isPremium)
                                    const Padding(
                                      padding: EdgeInsets.only(left: 8),
                                      child: Icon(Icons.star,
                                          color: Colors.amber, size: 20),
                                    ),
                                ],
                              ),
                              Text(
                                '${user.age} years old',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        const Icon(Icons.email, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(user.email),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(child: Text(user.bio)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
            const Text(
              'Update Methods:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Update name
            TextField(
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                ref.read(userProfileProvider.notifier).updateName(value);
              },
            ),
            const SizedBox(height: 12),

            // Update email
            TextField(
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                ref.read(userProfileProvider.notifier).updateEmail(value);
              },
            ),
            const SizedBox(height: 12),

            // Update bio
            TextField(
              decoration: const InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onChanged: (value) {
                ref.read(userProfileProvider.notifier).updateBio(value);
              },
            ),
            const SizedBox(height: 24),

            // Age buttons
            Row(
              children: [
                const Text('Age: '),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    final newAge = (user.age - 1).clamp(0, 120);
                    ref.read(userProfileProvider.notifier).updateAge(newAge);
                  },
                ),
                Text(
                  '${user.age}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    final newAge = (user.age + 1).clamp(0, 120);
                    ref.read(userProfileProvider.notifier).updateAge(newAge);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Premium toggle
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(userProfileProvider.notifier).togglePremium(),
              icon: const Icon(Icons.star),
              label: const Text('Toggle Premium Status'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),

            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 Key Points:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('• Entire object stored in StateNotifier<UserProfile>'),
                  Text('• Use copyWith() for immutable updates'),
                  Text('• StateNotifier automatically notifies listeners'),
                  Text('• Preferred pattern for complex state objects'),
                  Text('• Ensures predictable state updates'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
