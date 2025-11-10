import 'package:flutter/material.dart';
import 'package:pipe_x/pipe_x.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PipeX State Management Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
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
        return MaterialPageRoute(
          builder: (_) => HubProvider(
            create: () => CounterHub(),
            child: const CounterExample(),
          ),
        );
      case '/multiple-pipes':
        return MaterialPageRoute(
          builder: (_) => HubProvider(
            create: () => UserHub(),
            child: const MultiplePipesExample(),
          ),
        );
      case '/standalone-pipe':
        return MaterialPageRoute(builder: (_) => const StandalonePipeExample());
      case '/single-sink':
        return MaterialPageRoute(
          builder: (_) => HubProvider(
            create: () => TimerHub()..startTimer(),
            child: const SingleSinkExample(),
          ),
        );
      case '/multiple-sinks':
        return MaterialPageRoute(
          builder: (_) => HubProvider(
            create: () => MultiCounterHub(),
            child: const MultipleSinksExample(),
          ),
        );
      case '/well':
        return MaterialPageRoute(
          builder: (_) => HubProvider(
            create: () => CalculatorHub(),
            child: const WellExample(),
          ),
        );
      case '/hub-provider':
        return MaterialPageRoute(
          builder: (_) => HubProvider(
            create: () => ThemeHub(),
            child: const HubProviderExample(),
          ),
        );
      case '/multi-hub-provider':
        return MaterialPageRoute(
          builder: (_) => MultiHubProvider(
            hubs: [
              () => AuthHub(),
              () => SettingsHub(),
            ],
            child: const MultiHubProviderExample(),
          ),
        );
      case '/hub-provider-value':
        // Pre-create the hub instance
        final preCreatedHub = ThemeHub();
        return MaterialPageRoute(
          builder: (_) => HubProvider<ThemeHub>.value(
            value: preCreatedHub,
            child: const HubProviderValueExample(),
          ),
        );
      case '/multi-hub-provider-value':
        // Pre-create hub instances
        final authHub = AuthHub();
        final settingsHub = SettingsHub();
        return MaterialPageRoute(
          builder: (_) => MultiHubProvider(
            hubs: [
              authHub, // Existing instance
              settingsHub, // Existing instance
            ],
            child: const MultiHubProviderValueExample(),
          ),
        );
      case '/scoped-vs-global':
        return MaterialPageRoute(
          builder: (_) => HubProvider(
            create: () => CounterGlobalHub(),
            child: const ScopedVsGlobalExample(),
          ),
        );
      case '/computed-values':
        return MaterialPageRoute(
          builder: (_) => HubProvider(
            create: () => ShoppingHub(),
            child: const ComputedValuesExample(),
          ),
        );
      case '/async':
        return MaterialPageRoute(
          builder: (_) => HubProvider(
            create: () => DataHub(),
            child: const AsyncExample(),
          ),
        );
      case '/form':
        return MaterialPageRoute(
          builder: (_) => HubProvider(
            create: () => FormHub(),
            child: const FormExample(),
          ),
        );
      case '/class-type':
        return MaterialPageRoute(
          builder: (_) => HubProvider(
            create: () => UserProfileHub(),
            child: const ClassTypeExample(),
          ),
        );
      case '/hub-listener':
        return MaterialPageRoute(
          builder: (_) => HubProvider(
            create: () => TargetCounterHub(),
            child: const HubListenerExample(),
          ),
        );
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
        title: const Text('💧 PipeX Examples'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          _buildSection(context, '📦 Basic Examples', const [
            _Example('Counter with Hub', '/counter'),
            _Example('Multiple Pipes', '/multiple-pipes'),
            _Example('Standalone Pipe (Auto-dispose)', '/standalone-pipe'),
            _Example('Class Type in Pipe', '/class-type'),
          ]),
          _buildSection(context, '🔄 Reactive Widgets', const [
            _Example('Single Sink', '/single-sink'),
            _Example('Multiple Sinks', '/multiple-sinks'),
            _Example('Well (Multiple Pipes)', '/well'),
          ]),
          _buildSection(context, '🏗️ Dependency Injection', const [
            _Example('HubProvider Basics', '/hub-provider'),
            _Example('MultiHubProvider', '/multi-hub-provider'),
            _Example('HubProvider.value (External Lifecycle)',
                '/hub-provider-value'),
            _Example(
                'MultiHubProvider with Values', '/multi-hub-provider-value'),
            _Example('Scoped vs Global', '/scoped-vs-global'),
          ]),
          _buildSection(context, '⚡ Advanced Patterns', const [
            _Example('Computed Values (Getters)', '/computed-values'),
            _Example('Async Operations', '/async'),
            _Example('Form Management', '/form'),
            _Example('HubListener (Conditional Side Effects)', '/hub-listener'),
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
// EXAMPLE 1: Counter with Hub
// ============================================================================

class CounterHub extends Hub {
  late final count = pipe(0);

  void increment() => count.value++;
  void decrement() => count.value--;
  void reset() => count.value = 0;
}

class CounterExample extends StatelessWidget {
  const CounterExample({super.key});

  @override
  Widget build(BuildContext context) {
    final hub = context.read<CounterHub>();

    return Scaffold(
      appBar: AppBar(title: const Text('Counter Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Basic counter with Hub & Sink:'),
            const SizedBox(height: 16),
            Sink(
              pipe: hub.count,
              builder: (context, value) {
                return Text(
                  '$value',
                  style: Theme.of(context).textTheme.displayLarge,
                );
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: 'dec',
                  onPressed: () => hub.decrement(),
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  heroTag: 'inc',
                  onPressed: () => hub.increment(),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => hub.reset(),
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 2: Multiple Pipes
// ============================================================================

class UserHub extends Hub {
  late final name = pipe('John Doe');
  late final age = pipe(25);
  late final email = pipe('john@example.com');

  // Computed value using getter
  String get summary => '${name.value}, ${age.value} years old';
}

class MultiplePipesExample extends StatelessWidget {
  const MultiplePipesExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Multiple Pipes')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Multiple independent pipes in one Hub:'),
            const SizedBox(height: 24),
            Sink(
              pipe: context.read<UserHub>().name,
              builder: (context, value) =>
                  Text('Name: $value', style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 8),
            Sink(
              pipe: context.read<UserHub>().age,
              builder: (context, value) =>
                  Text('Age: $value', style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 8),
            Sink(
              pipe: context.read<UserHub>().email,
              builder: (context, value) =>
                  Text('Email: $value', style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final hub = context.read<UserHub>();
                hub.name.value = 'Jane Smith';
                hub.age.value = 30;
                hub.email.value = 'jane@example.com';
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
// EXAMPLE 3: Standalone Pipe (Auto-dispose)
// ============================================================================

class StandalonePipeExample extends StatefulWidget {
  const StandalonePipeExample({super.key});

  @override
  State<StandalonePipeExample> createState() => _StandalonePipeExampleState();
}

class _StandalonePipeExampleState extends State<StandalonePipeExample> {
  late final Pipe<int> counter;
  late final Pipe<String> message;

  @override
  void initState() {
    super.initState();
    // These pipes are created outside a Hub, so they'll auto-dispose
    counter = Pipe(0);
    message = Pipe('Hello!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Standalone Pipe')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Pipes without Hub (auto-dispose on unmount):'),
            const SizedBox(height: 24),
            Sink(
              pipe: counter,
              builder: (context, value) => Text(
                'Counter: $value',
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(height: 16),
            Sink(
              pipe: message,
              builder: (context, value) => Text(
                value,
                style: const TextStyle(fontSize: 18, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                counter.value++;
                message.value = 'Count: ${counter.value}';
              },
              child: const Text('Increment'),
            ),
            const SizedBox(height: 16),
            Text(
              'These pipes will auto-dispose when you go back',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 4: Single Sink
// ============================================================================

class TimerHub extends Hub {
  late final seconds = pipe(0);

  void startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!disposed) {
        seconds.value++;
        return true;
      }
      return false;
    });
  }
}

class SingleSinkExample extends StatelessWidget {
  const SingleSinkExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Single Sink')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Only the Sink rebuilds, not the entire screen:'),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Sink(
                pipe: context.read<TimerHub>().seconds,
                builder: (context, value) {
                  return Text(
                    'Timer: $value seconds',
                    style: const TextStyle(
                        fontSize: 32, fontWeight: FontWeight.bold),
                  );
                },
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
// EXAMPLE 5: Multiple Sinks
// ============================================================================

class MultiCounterHub extends Hub {
  late final counterA = pipe(0);
  late final counterB = pipe(0);
  late final counterC = pipe(0);

  void incrementA() => counterA.value++;
  void incrementB() => counterB.value++;
  void incrementC() => counterC.value++;
}

class MultipleSinksExample extends StatelessWidget {
  const MultipleSinksExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Multiple Sinks')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Each Sink rebuilds independently:'),
            const SizedBox(height: 32),
            _CounterRow('Counter A', context.read<MultiCounterHub>().counterA,
                () {
              context.read<MultiCounterHub>().incrementA();
            }),
            const SizedBox(height: 16),
            _CounterRow('Counter B', context.read<MultiCounterHub>().counterB,
                () {
              context.read<MultiCounterHub>().incrementB();
            }),
            const SizedBox(height: 16),
            _CounterRow('Counter C', context.read<MultiCounterHub>().counterC,
                () {
              context.read<MultiCounterHub>().incrementC();
            }),
          ],
        ),
      ),
    );
  }
}

class _CounterRow extends StatelessWidget {
  final String label;
  final Pipe<int> pipe;
  final VoidCallback onIncrement;

  const _CounterRow(this.label, this.pipe, this.onIncrement);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 18)),
        Row(
          children: [
            Sink(
              pipe: pipe,
              builder: (context, value) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('$value',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: onIncrement,
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================================
// EXAMPLE 6: Well (Multiple Pipes)
// ============================================================================

class CalculatorHub extends Hub {
  late final a = pipe(5);
  late final b = pipe(10);
  late final operation = pipe<String>('+');

  double get result {
    switch (operation.value) {
      case '+':
        return (a.value + b.value).toDouble();
      case '-':
        return (a.value - b.value).toDouble();
      case '*':
        return (a.value * b.value).toDouble();
      case '/':
        return b.value != 0 ? a.value / b.value : 0;
      default:
        return 0;
    }
  }
}

class WellExample extends StatelessWidget {
  const WellExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Well Example')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Well listens to multiple pipes at once:'),
            const SizedBox(height: 32),
            Well(
              pipes: [
                context.read<CalculatorHub>().a,
                context.read<CalculatorHub>().b,
                context.read<CalculatorHub>().operation,
              ],
              builder: (context) {
                final hub = context.read<CalculatorHub>();
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${hub.a.value} ${hub.operation.value} ${hub.b.value} = ${hub.result.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => context.read<CalculatorHub>().a.value++,
                  child: const Text('A+'),
                ),
                ElevatedButton(
                  onPressed: () => context.read<CalculatorHub>().b.value++,
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
                      context.read<CalculatorHub>().operation.value = op,
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
// EXAMPLE 7: HubProvider Basics
// ============================================================================

class ThemeHub extends Hub {
  late final isDark = pipe(false);

  void toggle() => isDark.value = !isDark.value;
}

class HubProviderExample extends StatelessWidget {
  const HubProviderExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Sink(
      pipe: context.read<ThemeHub>().isDark,
      builder: (context, isDark) {
        return MaterialApp(
          theme: isDark ? ThemeData.dark() : ThemeData.light(),
          home: Scaffold(
            appBar: AppBar(
              title: const Text('HubProvider Example'),
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
                    onPressed: () => context.read<ThemeHub>().toggle(),
                    child: const Text('Toggle Theme'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// EXAMPLE 8: MultiHubProvider
// ============================================================================

class AuthHub extends Hub {
  late final isLoggedIn = pipe(false);
  late final username = pipe('Guest');

  void login(String name) {
    username.value = name;
    isLoggedIn.value = true;
  }

  void logout() {
    username.value = 'Guest';
    isLoggedIn.value = false;
  }
}

class SettingsHub extends Hub {
  late final fontSize = pipe(16.0);
  late final enableNotifications = pipe(true);

  void increaseFontSize() => fontSize.value += 2;
  void decreaseFontSize() => fontSize.value -= 2;
}

class MultiHubProviderExample extends StatelessWidget {
  const MultiHubProviderExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MultiHubProvider')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Multiple Hubs without nesting:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Well(
              pipes: [
                context.read<AuthHub>().isLoggedIn,
                context.read<AuthHub>().username,
              ],
              builder: (context) {
                final auth = context.read<AuthHub>();
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Auth Status: ${auth.isLoggedIn.value ? "Logged In" : "Logged Out"}'),
                        Text('Username: ${auth.username.value}'),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (auth.isLoggedIn.value) {
                              auth.logout();
                            } else {
                              auth.login('John Doe');
                            }
                          },
                          child:
                              Text(auth.isLoggedIn.value ? 'Logout' : 'Login'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Sink<double>(
              pipe: context.read<SettingsHub>().fontSize,
              builder: (context, fontSize) {
                return Card(
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
                              onPressed: () => context
                                  .read<SettingsHub>()
                                  .decreaseFontSize(),
                              child: const Text('A-'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => context
                                  .read<SettingsHub>()
                                  .increaseFontSize(),
                              child: const Text('A+'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 8.1: HubProvider.value (External Lifecycle)
// ============================================================================
//
// Use HubProvider.value when you want to manage the hub's lifecycle yourself.
// The hub is NOT automatically disposed when the provider is removed.
//
// Use cases:
// - Share a hub instance across multiple routes
// - When you need to keep state alive beyond widget lifecycle
// - Integration with existing dependency injection systems
// - Testing scenarios where you provide mock instances
// ============================================================================

class HubProviderValueExample extends StatefulWidget {
  const HubProviderValueExample({super.key});

  @override
  State<HubProviderValueExample> createState() =>
      _HubProviderValueExampleState();
}

class _HubProviderValueExampleState extends State<HubProviderValueExample> {
  int _toggleCount = 0;

  @override
  Widget build(BuildContext context) {
    return Sink(
      pipe: context.read<ThemeHub>().isDark,
      builder: (context, isDark) {
        return MaterialApp(
          theme: isDark ? ThemeData.dark() : ThemeData.light(),
          home: Scaffold(
            appBar: AppBar(
              title: const Text('HubProvider.value Example'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Info card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.orange.shade700),
                              const SizedBox(width: 8),
                              const Text(
                                'HubProvider.value',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'This example uses HubProvider.value constructor.\n\n'
                            '✅ Hub was created BEFORE the provider\n'
                            '✅ You manage the lifecycle (not auto-disposed)\n'
                            '✅ Perfect for sharing state across routes\n'
                            '✅ Useful for testing with mock instances',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Theme toggle
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            isDark ? '🌙 Dark Mode' : '☀️ Light Mode',
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Toggled $_toggleCount times',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() => _toggleCount++);
                              context.read<ThemeHub>().toggle();
                            },
                            icon: const Icon(Icons.brightness_6),
                            label: const Text('Toggle Theme'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Code example
                  Card(
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '📝 How this example was created:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            '// 1. Create the hub FIRST\n'
                            'final myHub = ThemeHub();\n\n'
                            '// 2. Provide it using .value\n'
                            'HubProvider<ThemeHub>.value(\n'
                            '  value: myHub,  // Pass existing instance\n'
                            '  child: MyApp(),\n'
                            ')\n\n'
                            '// 3. You must dispose it manually\n'
                            '// when you\'re done:\n'
                            'myHub.dispose();',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Comparison
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'HubProvider.create vs .value',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildComparisonRow(
                            'Lifecycle Management',
                            'Automatic',
                            'Manual',
                          ),
                          _buildComparisonRow(
                            'Auto-dispose',
                            'Yes ✅',
                            'No ❌',
                          ),
                          _buildComparisonRow(
                            'Created',
                            'By provider',
                            'Before provider',
                          ),
                          _buildComparisonRow(
                            'Use case',
                            'Most cases',
                            'Shared state',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildComparisonRow(String label, String create, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    create,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 8.2: MultiHubProvider with Existing Instances
// ============================================================================
//
// MultiHubProvider can accept both:
// - Factory functions: () => MyHub() (will be created and disposed)
// - Hub instances: myHub (will NOT be disposed)
//
// Mix and match as needed for your use case!
// ============================================================================

class MultiHubProviderValueExample extends StatelessWidget {
  const MultiHubProviderValueExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MultiHubProvider with Values'),
        backgroundColor: Colors.teal.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info card
            Card(
              color: Colors.teal.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.layers, color: Colors.teal.shade700),
                        const SizedBox(width: 8),
                        const Text(
                          'Pre-created Hub Instances',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Both hubs in this example were created BEFORE '
                      'the MultiHubProvider:\n\n'
                      '✅ Full control over initialization\n'
                      '✅ Can configure hubs before providing them\n'
                      '✅ Easy to test with dependency injection\n'
                      '✅ You manage disposal manually',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Auth Hub section
            Well(
              pipes: [
                context.read<AuthHub>().isLoggedIn,
                context.read<AuthHub>().username,
              ],
              builder: (context) {
                final auth = context.read<AuthHub>();
                return Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.account_circle,
                              color: auth.isLoggedIn.value
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Auth Hub (Pre-created)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        Text(
                          'Status: ${auth.isLoggedIn.value ? "Logged In ✅" : "Logged Out ❌"}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          'User: ${auth.username.value}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (auth.isLoggedIn.value) {
                              auth.logout();
                            } else {
                              auth.login('Alice');
                            }
                          },
                          icon: Icon(
                            auth.isLoggedIn.value ? Icons.logout : Icons.login,
                          ),
                          label: Text(
                            auth.isLoggedIn.value ? 'Logout' : 'Login',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Settings Hub section
            Sink<double>(
              pipe: context.read<SettingsHub>().fontSize,
              builder: (context, fontSize) {
                return Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.settings, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Settings Hub (Pre-created)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        Text(
                          'Font Size: ${fontSize.toInt()}px',
                          style: TextStyle(fontSize: fontSize),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => context
                                  .read<SettingsHub>()
                                  .decreaseFontSize(),
                              icon: const Icon(Icons.text_decrease),
                              label: const Text('Smaller'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () => context
                                  .read<SettingsHub>()
                                  .increaseFontSize(),
                              icon: const Icon(Icons.text_increase),
                              label: const Text('Larger'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Code example
            Card(
              color: Colors.grey.shade100,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📝 Code for this example:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      '// 1. Create hub instances first\n'
                      'final authHub = AuthHub();\n'
                      'final settingsHub = SettingsHub();\n\n'
                      '// 2. Pass them to MultiHubProvider\n'
                      'MultiHubProvider(\n'
                      '  hubs: [\n'
                      '    authHub,        // Existing instance\n'
                      '    settingsHub,    // Existing instance\n'
                      '  ],\n'
                      '  child: MyApp(),\n'
                      ')\n\n'
                      '// You can also mix factories and values:\n'
                      'MultiHubProvider(\n'
                      '  hubs: [\n'
                      '    authHub,           // Existing (no dispose)\n'
                      '    () => ThemeHub(),  // Factory (auto-dispose)\n'
                      '  ],\n'
                      '  child: MyApp(),\n'
                      ')',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
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

class CounterGlobalHub extends Hub {
  late final count = pipe(0);
  void increment() => count.value++;
}

class ScopedVsGlobalExample extends StatelessWidget {
  const ScopedVsGlobalExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scoped vs Global')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Global Hub (survives navigation):'),
            Sink(
              pipe: context.read<CounterGlobalHub>().count,
              builder: (context, value) => Text('Global Count: $value',
                  style: const TextStyle(fontSize: 24)),
            ),
            ElevatedButton(
              onPressed: () => context.read<CounterGlobalHub>().increment(),
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

class ScopedScreen extends StatelessWidget {
  const ScopedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return HubProvider(
      create: () => CounterGlobalHub(), // New instance, disposed on pop
      child: Scaffold(
        appBar: AppBar(title: const Text('Scoped Screen')),
        body: Center(
          child: Comp(),
        ),
      ),
    );
  }
}

class Comp extends StatelessWidget {
  const Comp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Scoped Hub (disposed on back):'),
        Sink(
          pipe: context.read<CounterGlobalHub>().count,
          builder: (context, value) => Text('Scoped Count: $value',
              style: const TextStyle(fontSize: 24)),
        ),
        ElevatedButton(
          onPressed: () => context.read<CounterGlobalHub>().increment(),
          child: const Text('Increment Scoped'),
        ),
      ],
    );
  }
}

// ============================================================================
// EXAMPLE 10: Computed Values (Getters)
// ============================================================================

class ShoppingHub extends Hub {
  late final items = pipe<List<String>>([]);
  late final pricePerItem = pipe(9.99);

  // Computed values using getters
  int get itemCount => items.value.length;
  double get total => itemCount * pricePerItem.value;
  String get summary => '$itemCount items - \$${total.toStringAsFixed(2)}';

  void addItem(String item) {
    items.value = [...items.value, item];
  }

  void clear() {
    items.value = [];
  }
}

class ComputedValuesExample extends StatelessWidget {
  const ComputedValuesExample({super.key});

  @override
  Widget build(BuildContext context) {
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
            Well(
              pipes: [
                context.read<ShoppingHub>().items,
                context.read<ShoppingHub>().pricePerItem,
              ],
              builder: (context) {
                final hub = context.read<ShoppingHub>();
                return Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Items: ${hub.itemCount}',
                            style: const TextStyle(fontSize: 18)),
                        Text(
                            'Price per item: \$${hub.pricePerItem.value.toStringAsFixed(2)}'),
                        const Divider(),
                        Text(
                          'Total: \$${hub.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Sink(
                pipe: context.read<ShoppingHub>().items,
                builder: (context, items) {
                  if (items.isEmpty) {
                    return const Center(child: Text('No items yet'));
                  }
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.shopping_cart),
                        title: Text(items[index]),
                      );
                    },
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final hub = context.read<ShoppingHub>();
                      hub.addItem('Item ${hub.itemCount + 1}');
                    },
                    child: const Text('Add Item'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => context.read<ShoppingHub>().clear(),
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

// User Profile Model - Regular class, NOT a Pipe!
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String country;
  final String occupation;
  final String bio;
  final String joinedDate;
  // Note: gender and age will be managed separately as Pipes for reactivity

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.country,
    required this.occupation,
    required this.bio,
    required this.joinedDate,
  });
}

class DataHub extends Hub {
  late final isLoading = pipe(false);
  late final error = pipe<String?>(null);

  // Profile data as a Pipe for reactivity!
  late final userProfile = pipe<UserProfile?>(null);

  // Only editable fields are Pipes for granular reactivity!
  late final gender = pipe<String>('Male');
  late final age = pipe<int>(25);

  Future<void> fetchUserProfile() async {
    isLoading.value = true;
    error.value = null;

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Load profile data into Pipe
      userProfile.value = UserProfile(
        id: 'USR-12345',
        name: 'John Doe',
        email: 'john.doe@example.com',
        phone: '+1 (555) 123-4567',
        address: '123 Main Street, Apt 4B',
        city: 'San Francisco',
        country: 'United States',
        occupation: 'Software Engineer',
        bio: 'Passionate about Flutter and reactive programming. '
            'Love building clean, performant applications.',
        joinedDate: 'January 15, 2023',
      );

      // Load reactive fields (Pipes)
      gender.value = 'Male';
      age.value = 28;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}

class AsyncExample extends StatefulWidget {
  const AsyncExample({super.key});

  @override
  State<AsyncExample> createState() => _AsyncExampleState();
}

class _AsyncExampleState extends State<AsyncExample> {
  @override
  void initState() {
    super.initState();
    // Fetch user profile immediately after the first frame is rendered
    context.read<DataHub>().fetchUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    final hub = context.read<DataHub>();

    return Scaffold(
      appBar: AppBar(title: const Text('User Profile - Async Demo')),
      body: Stack(
        children: [
          // Bottom Layer: Profile Screen (static data + reactive fields)
          _ProfileScreen(hub: hub),

          // Top Layer: Loading Overlay (Sink for loading state)
          Sink(
            pipe: hub.isLoading,
            builder: (context, isLoading) {
              if (!isLoading) return const SizedBox.shrink();

              return Container(
                color: const Color.fromARGB(255, 197, 228, 213),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Loading Profile...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProfileScreen extends StatelessWidget {
  final DataHub hub;

  const _ProfileScreen({required this.hub});

  @override
  Widget build(BuildContext context) {
    // Use Sink to reactively rebuild when profile data is loaded!
    return Sink(
      pipe: hub.userProfile,
      builder: (context, profile) {
        if (profile == null) {
          return const Center(
            child: Text('No profile data loaded'),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                '📱 User Profile',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Profile data loaded via Pipe! Gender & Age use separate Sinks for independent updates.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Divider(height: 32),

              const SizedBox(height: 16),
              _buildField('ID', profile.id, Icons.badge),
              _buildField('Name', profile.name, Icons.person),
              _buildField('Email', profile.email, Icons.email),
              _buildField('Phone', profile.phone, Icons.phone),
              _buildField('Address', profile.address, Icons.home),
              _buildField('City', profile.city, Icons.location_city),
              _buildField('Country', profile.country, Icons.flag),
              _buildField('Occupation', profile.occupation, Icons.work),
              _buildField('Bio', profile.bio, Icons.description, maxLines: 3),
              _buildField('Joined', profile.joinedDate, Icons.calendar_today),

              const SizedBox(height: 16),

              // Gender - Reactive with Sink
              Row(
                children: [
                  const Icon(Icons.wc, size: 20, color: Colors.grey),
                  const SizedBox(width: 12),
                  const Text('Gender:',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                ],
              ),
              const SizedBox(height: 16),
              Sink(
                pipe: hub.gender,
                builder: (context, gender) {
                  return Row(
                    children: [
                      ...['Male', 'Female', 'Other'].map((g) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(g),
                              selected: gender == g,
                              onSelected: (selected) {
                                if (selected) hub.gender.value = g;
                              },
                            ),
                          )),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // Age - Reactive with Sink
              Row(
                children: [
                  const Icon(Icons.cake, size: 20, color: Colors.grey),
                  const SizedBox(width: 12),
                  const Text('Age:',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  Sink(
                    pipe: hub.age,
                    builder: (context, age) {
                      return Row(
                        children: [
                          Text(
                            '$age years',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            children: [
                              IconButton(
                                onPressed: () => hub.age.value++,
                                icon: const Icon(Icons.add_circle),
                                color: Colors.green,
                              ),
                              IconButton(
                                onPressed: () {
                                  if (hub.age.value > 1) hub.age.value--;
                                },
                                icon: const Icon(Icons.remove_circle),
                                color: Colors.red,
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.tips_and_updates, size: 16, color: Colors.amber),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Try changing Gender or Age - ONLY those Sinks rebuild!\n'
                        'The outer Sink (userProfile) and static fields stay untouched. 🚀\n'
                        'Reload → Outer Sink rebuilds all. Edit field → Only that Sink rebuilds!',
                        style: TextStyle(fontSize: 11, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Reload Button
              Center(
                child: ElevatedButton.icon(
                  onPressed: hub.fetchUserProfile,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reload Profile'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildField(String label, String value, IconData icon,
      {int? maxLines}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              const SizedBox(height: 12),
              Icon(icon, size: 20, color: Colors.grey),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label:',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14),
                  maxLines: maxLines,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 12: Form Management
// ============================================================================

class FormHub extends Hub {
  late final name = pipe('');
  late final email = pipe('');
  late final age = pipe('');

  // Validation computed values
  bool get isNameValid => name.value.length >= 3;
  bool get isEmailValid => email.value.contains('@');
  bool get isAgeValid =>
      int.tryParse(age.value) != null && int.parse(age.value) >= 18;
  bool get isFormValid => isNameValid && isEmailValid && isAgeValid;

  void submit() {
    if (isFormValid) {
      // Handle submission
    }
  }
}

class FormExample extends StatelessWidget {
  const FormExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Management')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration:
                  const InputDecoration(labelText: 'Name (min 3 chars)'),
              onChanged: (value) => context.read<FormHub>().name.value = value,
            ),
            Sink(
              pipe: context.read<FormHub>().name,
              builder: (context, value) {
                final hub = context.read<FormHub>();
                return Text(
                  hub.isNameValid ? '✓ Valid' : '✗ Too short',
                  style: TextStyle(
                      color: hub.isNameValid ? Colors.green : Colors.red,
                      fontSize: 12),
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Email'),
              onChanged: (value) => context.read<FormHub>().email.value = value,
            ),
            Sink(
              pipe: context.read<FormHub>().email,
              builder: (context, value) {
                final hub = context.read<FormHub>();
                return Text(
                  hub.isEmailValid ? '✓ Valid' : '✗ Invalid email',
                  style: TextStyle(
                      color: hub.isEmailValid ? Colors.green : Colors.red,
                      fontSize: 12),
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Age (18+)'),
              keyboardType: TextInputType.number,
              onChanged: (value) => context.read<FormHub>().age.value = value,
            ),
            Sink(
              pipe: context.read<FormHub>().age,
              builder: (context, value) {
                final hub = context.read<FormHub>();
                return Text(
                  hub.isAgeValid ? '✓ Valid' : '✗ Must be 18+',
                  style: TextStyle(
                      color: hub.isAgeValid ? Colors.green : Colors.red,
                      fontSize: 12),
                );
              },
            ),
            const SizedBox(height: 24),
            Well(
              pipes: [
                context.read<FormHub>().name,
                context.read<FormHub>().email,
                context.read<FormHub>().age,
              ],
              builder: (context) {
                final hub = context.read<FormHub>();
                return ElevatedButton(
                  onPressed: hub.isFormValid ? () => hub.submit() : null,
                  child: const Text('Submit'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 13: Class Type in Pipe
// ============================================================================

/// User profile model class (MUTABLE)
/// This class demonstrates using mutable objects with Pipe.forceUpdate()
class MutableUserProfile {
  String name;
  int age;
  String email;
  String bio;
  bool isPremium;

  MutableUserProfile({
    required this.name,
    required this.age,
    required this.email,
    required this.bio,
    required this.isPremium,
  });
}

class UserProfileHub extends Hub {
  late final user = pipe<MutableUserProfile>(
    MutableUserProfile(
      name: 'John Doe',
      age: 28,
      email: 'john@example.com',
      bio: 'Flutter developer',
      isPremium: false,
    ),
  );

  /// Update specific fields by mutating the object and calling forceUpdate
  /// This demonstrates using mutable objects with Pipe
  void updateName(String name) {
    user.value.name = name;
    user.pump(user.value); // Force rebuild even though reference didn't change
  }

  void updateAge(int age) {
    user.value.age++;
    user.pump(user.value);
  }

  void updateEmail(String email) {
    user.value.email = email;
    user.pump(user.value);
  }

  void updateBio(String bio) {
    user.value.bio = bio;
    user.pump(user.value);
  }

  void togglePremium() {
    user.value.isPremium = !user.value.isPremium;
    user.pump(user.value);
  }
}

class ClassTypeExample extends StatelessWidget {
  const ClassTypeExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Class Type in Pipe')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Using MUTABLE classes in Pipes:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Entire object is stored in one Pipe. Mutate fields and call forceUpdate().',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Display user profile
            Sink(
              pipe: context.read<UserProfileHub>().user,
              builder: (context, user) {
                return Card(
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
                            const Icon(Icons.email,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(user.email),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(child: Text(user.bio)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
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
                context.read<UserProfileHub>().updateName(value);
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
                context.read<UserProfileHub>().updateEmail(value);
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
                context.read<UserProfileHub>().updateBio(value);
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
                    final hub = context.read<UserProfileHub>();
                    final newAge = (hub.user.value.age - 1).clamp(0, 120);
                    hub.updateAge(newAge);
                  },
                ),
                Sink(
                  pipe: context.read<UserProfileHub>().user,
                  builder: (context, user) => Text(
                    '${user.age}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    final hub = context.read<UserProfileHub>();
                    final newAge = (hub.user.value.age + 1).clamp(0, 120);
                    hub.updateAge(newAge);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Premium toggle
            ElevatedButton.icon(
              onPressed: () => context.read<UserProfileHub>().togglePremium(),
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
                  Text('• Entire object stored in Pipe<UserProfile>'),
                  Text('• Mutate object fields directly'),
                  Text('• Call forceUpdate() to trigger Sink rebuild'),
                  Text('• Useful for mutable objects (e.g., from APIs)'),
                  Text('• Reference stays same, but UI updates'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE: HubListener - Conditional Side Effects
// ============================================================================

class TargetCounterHub extends Hub {
  late final count = pipe(0);
  late final target = pipe(5);
  late final VoidCallback _removeListener;

  void onTargetReached(BuildContext context) {
    _removeListener = addListener(() {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎯 Target Reached!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  void increment() => count.value++;
  void decrement() => count.value--;
  void setTarget(int value) => target.value = value;

  @override
  void dispose() {
    _removeListener();
    super.dispose();
  }
}

class HubListenerExample extends StatelessWidget {
  const HubListenerExample({super.key});

  @override
  Widget build(BuildContext context) {
    final hub = context.read<TargetCounterHub>();
    hub.onTargetReached(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('HubListener Example'),
        backgroundColor: Colors.purple,
      ),
      body: HubListener<TargetCounterHub>(
        listenWhen: (hub) {
          // Condition: when count equals target
          return hub.count.value == hub.target.value;
        },
        onConditionMet: () {
          // Side effect: show snackbar (NO rebuild!)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎯🎯🎯 Target Reached!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '🎯 Target Counter',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              // Current count
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Count: ',
                    style: TextStyle(fontSize: 20),
                  ),
                  Sink<int>(
                    pipe: hub.count,
                    builder: (context, count) => Text(
                      count.toString(),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Target value
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Target: ',
                    style: TextStyle(fontSize: 20),
                  ),
                  Sink<int>(
                    pipe: hub.target,
                    builder: (context, target) => Text(
                      target.toString(),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Counter buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: hub.decrement,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Icon(Icons.remove, size: 32),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: hub.increment,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Icon(Icons.add, size: 32),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Target selection
              const Text(
                'Set Target:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [3, 5, 10, 15, 20].map((value) {
                  return Sink<int>(
                    pipe: hub.target,
                    builder: (context, currentTarget) => OutlinedButton(
                      onPressed: () => hub.setTarget(value),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: currentTarget == value
                            ? Colors.purple.withOpacity(0.2)
                            : null,
                        side: BorderSide(
                          color: currentTarget == value
                              ? Colors.purple
                              : Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        value.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: currentTarget == value
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const Spacer(),

              // Info box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💡 How HubListener works:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('• Monitors ALL pipes in the hub'),
                    Text('• listenWhen: checks condition on every change'),
                    Text('• onConditionMet: executes when condition is true'),
                    Text('• Child widget NEVER rebuilds'),
                    Text('• Perfect for: snackbars, dialogs, navigation'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
