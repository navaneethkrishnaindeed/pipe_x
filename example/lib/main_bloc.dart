import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      showPerformanceOverlay: true,
      title: 'Bloc State Management Demo',
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
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => CounterBloc(),
            child: const CounterExample(),
          ),
        );
      case '/multiple-pipes':
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => UserCubit(),
            child: const MultiplePipesExample(),
          ),
        );
      case '/standalone-pipe':
        return MaterialPageRoute(builder: (_) => const StandalonePipeExample());
      case '/single-sink':
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => TimerCubit()..startTimer(),
            child: const SingleSinkExample(),
          ),
        );
      case '/multiple-sinks':
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => MultiCounterCubit(),
            child: const MultipleSinksExample(),
          ),
        );
      case '/well':
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => CalculatorCubit(),
            child: const WellExample(),
          ),
        );
      case '/hub-provider':
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => ThemeCubit(),
            child: const HubProviderExample(),
          ),
        );
      case '/multi-hub-provider':
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => AuthCubit()),
              BlocProvider(create: (_) => SettingsCubit()),
            ],
            child: const MultiHubProviderExample(),
          ),
        );
      case '/scoped-vs-global':
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => CounterGlobalCubit(),
            child: const ScopedVsGlobalExample(),
          ),
        );
      case '/computed-values':
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => ShoppingCubit(),
            child: const ComputedValuesExample(),
          ),
        );
      case '/async':
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => DataCubit(),
            child: const AsyncExample(),
          ),
        );
      case '/form':
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => FormCubit(),
            child: const FormExample(),
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
        title: const Text('🔷 Bloc Examples'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          _buildSection(context, '📦 Basic Examples', const [
            _Example('Counter with Bloc (Events & States)', '/counter'),
            _Example('Multiple State Values', '/multiple-pipes'),
            _Example('Standalone (No Provider)', '/standalone-pipe'),
          ]),
          _buildSection(context, '🔄 Reactive Widgets', const [
            _Example('Single BlocBuilder', '/single-sink'),
            _Example('Multiple BlocBuilders', '/multiple-sinks'),
            _Example('BlocSelector (Multiple)', '/well'),
          ]),
          _buildSection(context, '🏗️ Dependency Injection', const [
            _Example('BlocProvider Basics', '/hub-provider'),
            _Example('MultiBlocProvider', '/multi-hub-provider'),
            _Example('Scoped vs Global', '/scoped-vs-global'),
          ]),
          _buildSection(context, '⚡ Advanced Patterns', const [
            _Example('Computed Values', '/computed-values'),
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
// EXAMPLE 1: Counter with Bloc (Events & States)
// ============================================================================

// Counter Events
abstract class CounterEvent {}

class IncrementEvent extends CounterEvent {}

class DecrementEvent extends CounterEvent {}

class ResetEvent extends CounterEvent {}

// Counter States
abstract class CounterState {
  final int value;
  const CounterState(this.value);
}

class CounterInitial extends CounterState {
  const CounterInitial() : super(0);
}

class CounterIncremented extends CounterState {
  const CounterIncremented(super.value);
}

class CounterDecremented extends CounterState {
  const CounterDecremented(super.value);
}

class CounterReset extends CounterState {
  const CounterReset() : super(0);
}

// Counter Bloc
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterInitial()) {
    on<IncrementEvent>(_onIncrement);
    on<DecrementEvent>(_onDecrement);
    on<ResetEvent>(_onReset);
  }

  void _onIncrement(IncrementEvent event, Emitter<CounterState> emit) {
    emit(CounterIncremented(state.value + 1));
  }

  void _onDecrement(DecrementEvent event, Emitter<CounterState> emit) {
    emit(CounterDecremented(state.value - 1));
  }

  void _onReset(ResetEvent event, Emitter<CounterState> emit) {
    emit(const CounterReset());
  }
}

class CounterExample extends StatelessWidget {
  const CounterExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter Example (Bloc with Events)')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Counter with Bloc Events & State Classes:'),
            const SizedBox(height: 16),
            BlocBuilder<CounterBloc, CounterState>(
              builder: (context, state) {
                return Column(
                  children: [
                    Text(
                      '${state.value}',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'State: ${state.runtimeType}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: 'dec',
                  onPressed: () =>
                      context.read<CounterBloc>().add(DecrementEvent()),
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  heroTag: 'inc',
                  onPressed: () =>
                      context.read<CounterBloc>().add(IncrementEvent()),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<CounterBloc>().add(ResetEvent()),
              child: const Text('Reset'),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📝 Pattern:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('• Events: IncrementEvent, DecrementEvent, ResetEvent'),
                  Text(
                      '• States: CounterIncremented, CounterDecremented, CounterReset'),
                  Text(
                      '• Event handlers: _onIncrement, _onDecrement, _onReset'),
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
// EXAMPLE 2: Multiple State Values
// ============================================================================

class UserState {
  final String name;
  final int age;
  final String email;

  UserState({
    required this.name,
    required this.age,
    required this.email,
  });

  UserState copyWith({String? name, int? age, String? email}) {
    return UserState(
      name: name ?? this.name,
      age: age ?? this.age,
      email: email ?? this.email,
    );
  }
}

class UserCubit extends Cubit<UserState> {
  UserCubit()
      : super(UserState(
          name: 'John Doe',
          age: 25,
          email: 'john@example.com',
        ));

  String get summary => '${state.name}, ${state.age} years old';

  void updateUser(String name, int age, String email) {
    emit(state.copyWith(name: name, age: age, email: email));
  }
}

class MultiplePipesExample extends StatelessWidget {
  const MultiplePipesExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Multiple State Values (Bloc)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Multiple values in one Cubit state:'),
            const SizedBox(height: 24),
            BlocBuilder<UserCubit, UserState>(
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name: ${state.name}',
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text('Age: ${state.age}',
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text('Email: ${state.email}',
                        style: const TextStyle(fontSize: 18)),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context
                    .read<UserCubit>()
                    .updateUser('Jane Smith', 30, 'jane@example.com');
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
// EXAMPLE 3: Standalone (No Provider)
// ============================================================================

// Simple cubit for standalone example
class StandaloneCounterCubit extends Cubit<int> {
  StandaloneCounterCubit() : super(0);

  void increment() => emit(state + 1);
}

class MessageCubit extends Cubit<String> {
  MessageCubit() : super('Hello!');

  void updateMessage(String msg) => emit(msg);
}

class StandalonePipeExample extends StatefulWidget {
  const StandalonePipeExample({super.key});

  @override
  State<StandalonePipeExample> createState() => _StandalonePipeExampleState();
}

class _StandalonePipeExampleState extends State<StandalonePipeExample> {
  late final StandaloneCounterCubit counterCubit;
  late final MessageCubit messageCubit;

  @override
  void initState() {
    super.initState();
    counterCubit = StandaloneCounterCubit();
    messageCubit = MessageCubit();
  }

  @override
  void dispose() {
    counterCubit.close();
    messageCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Standalone (Bloc)')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Cubits without Provider (manual disposal):'),
            const SizedBox(height: 24),
            BlocBuilder<StandaloneCounterCubit, int>(
              bloc: counterCubit,
              builder: (context, count) => Text(
                'Counter: $count',
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(height: 16),
            BlocBuilder<MessageCubit, String>(
              bloc: messageCubit,
              builder: (context, message) => Text(
                message,
                style: const TextStyle(fontSize: 18, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                counterCubit.increment();
                messageCubit.updateMessage('Count: ${counterCubit.state}');
              },
              child: const Text('Increment'),
            ),
            const SizedBox(height: 16),
            Text(
              'These cubits are disposed in dispose()',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 4: Single BlocBuilder
// ============================================================================

class TimerCubit extends Cubit<int> {
  TimerCubit() : super(0);

  void startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!isClosed) {
        emit(state + 1);
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
      appBar: AppBar(title: const Text('Single BlocBuilder')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Only the BlocBuilder rebuilds:'),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: BlocBuilder<TimerCubit, int>(
                builder: (context, seconds) {
                  return Text(
                    'Timer: $seconds seconds',
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
// EXAMPLE 5: Multiple BlocBuilders
// ============================================================================

class MultiCounterState {
  final int counterA;
  final int counterB;
  final int counterC;

  MultiCounterState({
    required this.counterA,
    required this.counterB,
    required this.counterC,
  });

  MultiCounterState copyWith({int? counterA, int? counterB, int? counterC}) {
    return MultiCounterState(
      counterA: counterA ?? this.counterA,
      counterB: counterB ?? this.counterB,
      counterC: counterC ?? this.counterC,
    );
  }
}

class MultiCounterCubit extends Cubit<MultiCounterState> {
  MultiCounterCubit()
      : super(MultiCounterState(counterA: 0, counterB: 0, counterC: 0));

  void incrementA() => emit(state.copyWith(counterA: state.counterA + 1));
  void incrementB() => emit(state.copyWith(counterB: state.counterB + 1));
  void incrementC() => emit(state.copyWith(counterC: state.counterC + 1));
}

class MultipleSinksExample extends StatelessWidget {
  const MultipleSinksExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Multiple BlocBuilders')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('BlocSelector for granular rebuilds:'),
            const SizedBox(height: 32),
            BlocSelector<MultiCounterCubit, MultiCounterState, int>(
              selector: (state) => state.counterA,
              builder: (context, counterA) => _CounterRow(
                'Counter A',
                counterA,
                () => context.read<MultiCounterCubit>().incrementA(),
              ),
            ),
            const SizedBox(height: 16),
            BlocSelector<MultiCounterCubit, MultiCounterState, int>(
              selector: (state) => state.counterB,
              builder: (context, counterB) => _CounterRow(
                'Counter B',
                counterB,
                () => context.read<MultiCounterCubit>().incrementB(),
              ),
            ),
            const SizedBox(height: 16),
            BlocSelector<MultiCounterCubit, MultiCounterState, int>(
              selector: (state) => state.counterC,
              builder: (context, counterC) => _CounterRow(
                'Counter C',
                counterC,
                () => context.read<MultiCounterCubit>().incrementC(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CounterRow extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback onIncrement;

  const _CounterRow(this.label, this.value, this.onIncrement);

  @override
  Widget build(BuildContext context) {
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
              onPressed: onIncrement,
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================================
// EXAMPLE 6: BlocSelector (Multiple Values)
// ============================================================================

class CalculatorState {
  final int a;
  final int b;
  final String operation;

  CalculatorState({
    required this.a,
    required this.b,
    required this.operation,
  });

  double get result {
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
  }

  CalculatorState copyWith({int? a, int? b, String? operation}) {
    return CalculatorState(
      a: a ?? this.a,
      b: b ?? this.b,
      operation: operation ?? this.operation,
    );
  }
}

class CalculatorCubit extends Cubit<CalculatorState> {
  CalculatorCubit() : super(CalculatorState(a: 5, b: 10, operation: '+'));

  void incrementA() => emit(state.copyWith(a: state.a + 1));
  void incrementB() => emit(state.copyWith(b: state.b + 1));
  void setOperation(String op) => emit(state.copyWith(operation: op));
}

class WellExample extends StatelessWidget {
  const WellExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BlocSelector Example')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('BlocBuilder rebuilds when ANY value changes:'),
            const SizedBox(height: 32),
            BlocBuilder<CalculatorCubit, CalculatorState>(
              builder: (context, state) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${state.a} ${state.operation} ${state.b} = ${state.result.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => context.read<CalculatorCubit>().incrementA(),
                  child: const Text('A+'),
                ),
                ElevatedButton(
                  onPressed: () => context.read<CalculatorCubit>().incrementB(),
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
                      context.read<CalculatorCubit>().setOperation(op),
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
// EXAMPLE 7: BlocProvider Basics
// ============================================================================

class ThemeCubit extends Cubit<bool> {
  ThemeCubit() : super(false);

  void toggle() => emit(!state);
}

class HubProviderExample extends StatelessWidget {
  const HubProviderExample({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, bool>(
      builder: (context, isDark) {
        return MaterialApp(
          theme: isDark ? ThemeData.dark() : ThemeData.light(),
          home: Scaffold(
            appBar: AppBar(
              title: const Text('BlocProvider Example'),
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
                    onPressed: () => context.read<ThemeCubit>().toggle(),
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
// EXAMPLE 8: MultiBlocProvider
// ============================================================================

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthState(isLoggedIn: false, username: 'Guest'));

  void login(String name) => emit(AuthState(isLoggedIn: true, username: name));
  void logout() => emit(AuthState(isLoggedIn: false, username: 'Guest'));
}

class AuthState {
  final bool isLoggedIn;
  final String username;

  AuthState({required this.isLoggedIn, required this.username});
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit()
      : super(SettingsState(fontSize: 16.0, enableNotifications: true));

  void increaseFontSize() => emit(state.copyWith(fontSize: state.fontSize + 2));
  void decreaseFontSize() =>
      emit(state.copyWith(fontSize: (state.fontSize - 2).clamp(12, 32)));
}

class SettingsState {
  final double fontSize;
  final bool enableNotifications;

  SettingsState({required this.fontSize, required this.enableNotifications});

  SettingsState copyWith({double? fontSize, bool? enableNotifications}) {
    return SettingsState(
      fontSize: fontSize ?? this.fontSize,
      enableNotifications: enableNotifications ?? this.enableNotifications,
    );
  }
}

class MultiHubProviderExample extends StatelessWidget {
  const MultiHubProviderExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MultiBlocProvider')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Multiple Cubits without nesting:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, auth) {
                return Card(
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
                              context.read<AuthCubit>().logout();
                            } else {
                              context.read<AuthCubit>().login('John Doe');
                            }
                          },
                          child: Text(auth.isLoggedIn ? 'Logout' : 'Login'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, settings) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Font Size: ${settings.fontSize.toInt()}',
                            style: TextStyle(fontSize: settings.fontSize)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () => context
                                  .read<SettingsCubit>()
                                  .decreaseFontSize(),
                              child: const Text('A-'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => context
                                  .read<SettingsCubit>()
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
// EXAMPLE 9: Scoped vs Global
// ============================================================================

class CounterGlobalCubit extends Cubit<int> {
  CounterGlobalCubit() : super(0);
  void increment() => emit(state + 1);
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
            const Text('Global Cubit (survives navigation):'),
            BlocBuilder<CounterGlobalCubit, int>(
              builder: (context, count) => Text('Global Count: $count',
                  style: const TextStyle(fontSize: 24)),
            ),
            ElevatedButton(
              onPressed: () => context.read<CounterGlobalCubit>().increment(),
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
    return BlocProvider(
      create: (_) => CounterGlobalCubit(), // New instance, disposed on pop
      child: Scaffold(
        appBar: AppBar(title: const Text('Scoped Screen')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Scoped Cubit (disposed on back):'),
              BlocBuilder<CounterGlobalCubit, int>(
                builder: (context, count) => Text('Scoped Count: $count',
                    style: const TextStyle(fontSize: 24)),
              ),
              ElevatedButton(
                onPressed: () => context.read<CounterGlobalCubit>().increment(),
                child: const Text('Increment Scoped'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 10: Computed Values
// ============================================================================

class ShoppingState {
  final List<String> items;
  final double pricePerItem;

  ShoppingState({required this.items, required this.pricePerItem});

  int get itemCount => items.length;
  double get total => itemCount * pricePerItem;
  String get summary => '$itemCount items - \$${total.toStringAsFixed(2)}';

  ShoppingState copyWith({List<String>? items, double? pricePerItem}) {
    return ShoppingState(
      items: items ?? this.items,
      pricePerItem: pricePerItem ?? this.pricePerItem,
    );
  }
}

class ShoppingCubit extends Cubit<ShoppingState> {
  ShoppingCubit() : super(ShoppingState(items: [], pricePerItem: 9.99));

  void addItem(String item) {
    emit(state.copyWith(items: [...state.items, item]));
  }

  void clear() {
    emit(state.copyWith(items: []));
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
            BlocBuilder<ShoppingCubit, ShoppingState>(
              builder: (context, state) {
                return Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Items: ${state.itemCount}',
                            style: const TextStyle(fontSize: 18)),
                        Text(
                            'Price per item: \$${state.pricePerItem.toStringAsFixed(2)}'),
                        const Divider(),
                        Text(
                          'Total: \$${state.total.toStringAsFixed(2)}',
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
              child: BlocBuilder<ShoppingCubit, ShoppingState>(
                builder: (context, state) {
                  if (state.items.isEmpty) {
                    return const Center(child: Text('No items yet'));
                  }
                  return ListView.builder(
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.shopping_cart),
                        title: Text(state.items[index]),
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
                      final cubit = context.read<ShoppingCubit>();
                      cubit.addItem('Item ${cubit.state.itemCount + 1}');
                    },
                    child: const Text('Add Item'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => context.read<ShoppingCubit>().clear(),
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

class DataState {
  final bool isLoading;
  final String? data;
  final String? error;

  DataState({required this.isLoading, this.data, this.error});
}

class DataCubit extends Cubit<DataState> {
  DataCubit() : super(DataState(isLoading: false));

  Future<void> fetchData() async {
    emit(DataState(isLoading: true));

    try {
      await Future.delayed(const Duration(seconds: 2));
      emit(DataState(
        isLoading: false,
        data: 'Data loaded at ${DateTime.now().toIso8601String()}',
      ));
    } catch (e) {
      emit(DataState(isLoading: false, error: e.toString()));
    }
  }
}

class AsyncExample extends StatelessWidget {
  const AsyncExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Async Operations')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: BlocBuilder<DataCubit, DataState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const CircularProgressIndicator();
              }

              if (state.error != null) {
                return Text('Error: ${state.error}',
                    style: const TextStyle(color: Colors.red));
              }

              if (state.data != null) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.data!, textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.read<DataCubit>().fetchData(),
                      child: const Text('Reload'),
                    ),
                  ],
                );
              }

              return ElevatedButton(
                onPressed: () => context.read<DataCubit>().fetchData(),
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

class FormState {
  final String name;
  final String email;
  final String age;

  FormState({required this.name, required this.email, required this.age});

  bool get isNameValid => name.length >= 3;
  bool get isEmailValid => email.contains('@');
  bool get isAgeValid => int.tryParse(age) != null && int.parse(age) >= 18;
  bool get isFormValid => isNameValid && isEmailValid && isAgeValid;

  FormState copyWith({String? name, String? email, String? age}) {
    return FormState(
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
    );
  }
}

class FormCubit extends Cubit<FormState> {
  FormCubit() : super(FormState(name: '', email: '', age: ''));

  void updateName(String name) => emit(state.copyWith(name: name));
  void updateEmail(String email) => emit(state.copyWith(email: email));
  void updateAge(String age) => emit(state.copyWith(age: age));

  void submit() {
    if (state.isFormValid) {
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
              onChanged: (value) => context.read<FormCubit>().updateName(value),
            ),
            BlocSelector<FormCubit, FormState, bool>(
              selector: (state) => state.isNameValid,
              builder: (context, isValid) {
                return Text(
                  isValid ? '✓ Valid' : '✗ Too short',
                  style: TextStyle(
                      color: isValid ? Colors.green : Colors.red, fontSize: 12),
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Email'),
              onChanged: (value) =>
                  context.read<FormCubit>().updateEmail(value),
            ),
            BlocSelector<FormCubit, FormState, bool>(
              selector: (state) => state.isEmailValid,
              builder: (context, isValid) {
                return Text(
                  isValid ? '✓ Valid' : '✗ Invalid email',
                  style: TextStyle(
                      color: isValid ? Colors.green : Colors.red, fontSize: 12),
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Age (18+)'),
              keyboardType: TextInputType.number,
              onChanged: (value) => context.read<FormCubit>().updateAge(value),
            ),
            BlocSelector<FormCubit, FormState, bool>(
              selector: (state) => state.isAgeValid,
              builder: (context, isValid) {
                return Text(
                  isValid ? '✓ Valid' : '✗ Must be 18+',
                  style: TextStyle(
                      color: isValid ? Colors.green : Colors.red, fontSize: 12),
                );
              },
            ),
            const SizedBox(height: 24),
            BlocBuilder<FormCubit, FormState>(
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: state.isFormValid
                      ? () => context.read<FormCubit>().submit()
                      : null,
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
