# State Management Benchmark

A comprehensive benchmark comparing **PipeX**, **Riverpod**, and **BLoC** state management frameworks for Flutter.

## 🎯 Benchmark Approach

This project uses **Flutter integration tests** to measure real-world performance with actual widgets and frame timing.

### Why Integration Tests?

All three frameworks (PipeX, Riverpod, BLoC) have Flutter dependencies, so we benchmark them in their natural environment - running Flutter apps with actual UI updates.

## 🚀 Running Benchmarks

```bash
# Navigate to benchmark directory
cd state_benchmark

# Run the benchmark integration tests
flutter test integration_test/ui_benchmark_test.dart

# Run on a specific device
flutter test integration_test/ui_benchmark_test.dart -d <device-id>

# Run with verbose output
flutter test integration_test/ui_benchmark_test.dart -v
```

## 📊 What Gets Benchmarked

### 1. Simple Counter (100 rapid updates)
- Measures basic state mutation performance
- Tests widget rebuild efficiency
- All three frameworks

### 2. Multi-Counter (50 counters × 20 rounds)
- Tests handling of multiple independent states
- Measures isolation and parallel state handling
- All three frameworks

### 3. Complex State (100 updates)
- Large objects with multiple fields (text, number, percentage, etc.)
- Tests immutability overhead
- All three frameworks

### 4. Stress Test (1000 rapid updates)
- Continuous rapid state mutations
- Memory and GC pressure testing
- All three frameworks

## 📁 Project Structure

```
state_benchmark/
├── integration_test/
│   └── ui_benchmark_test.dart    # Main benchmark suite
├── lib/
│   ├── cases/                     # Test case implementations
│   │   ├── pipex_case.dart       # PipeX implementations
│   │   ├── riverpod_case.dart    # Riverpod implementations
│   │   └── bloc_case.dart        # BLoC implementations
│   └── main.dart                  # Interactive demo app (optional)
├── results/
│   └── README.md                  # Benchmark results and analysis
├── pubspec.yaml
└── README.md                      # This file
```

## 📈 Sample Output

```
╔══════════════════════════════════════════════════════════════════════╗
║              📊 COMPREHENSIVE BENCHMARK RESULTS                      ║
╚══════════════════════════════════════════════════════════════════════╝

┌─ Simple Counter (100 updates) ────────────────────────────────────
│  🏆 PipeX       :    245 ms
│     Riverpod    :    287 ms
│  🐌 BLoC        :    312 ms
│
│  💡 PipeX is fastest by 67ms (21.5% faster than BLoC)
└────────────────────────────────────────────────────────────────────

┌─ Multi-Counter (50 counters) ──────────────────────────────────────
│  🏆 PipeX       :   1823 ms
│     Riverpod    :   2145 ms
│  🐌 BLoC        :   2789 ms
│
│  💡 PipeX is fastest by 966ms (34.6% faster than BLoC)
└────────────────────────────────────────────────────────────────────

...
```

## 🎛️ Test Cases

Each framework implements identical test cases:

### PipeX Example
```dart
class CounterHub extends Hub {
  late final Pipe<int> count = Pipe(0);
  void increment() => count.value++;
}
```

### Riverpod Example
```dart
class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(0);
  void increment() => state++;
}
```

### BLoC Example
```dart
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(CounterState(0)) {
    on<IncrementEvent>((event, emit) => emit(CounterState(state.value + 1)));
  }
}
```

## 📊 Metrics

The benchmarks measure:

1. **Time (milliseconds)** - Total time to complete operations
2. **Frame timing** - How long each update takes
3. **Rebuild count** - Widget rebuild efficiency
4. **Memory usage** - Through stress testing

## 🔧 Customization

To add new benchmark scenarios, edit `integration_test/ui_benchmark_test.dart`:

```dart
testWidgets('Your Custom Benchmark', (WidgetTester tester) async {
  // Setup
  
  final stopwatch = Stopwatch()..start();
  // Your benchmark code
  stopwatch.stop();
  
  allResults['Your Test'] = {'Framework': stopwatch.elapsedMilliseconds};
});
```

## 📱 Optional: Interactive Demo

Run the demo app to manually test the frameworks:

```bash
cd state_benchmark
flutter run lib/main.dart
```

This provides an interactive UI to visually compare the frameworks.

## 🎓 Best Practices

1. **Run on Real Devices** - Emulators have different performance
2. **Profile Mode** - Use `--profile` for accurate timing
3. **Multiple Runs** - Run 3-5 times and take median
4. **Consistent Environment** - Same device, close other apps
5. **Document Results** - Track over time in `results/`

## 📚 Documentation

- **Test Cases**: See `lib/cases/` for implementations
- **Results**: See `results/README.md` for detailed analysis
- **Main App**: See `lib/main.dart` for interactive demo

## 🤝 Contributing

To improve benchmarks:

1. Add new realistic test scenarios
2. Improve measurement accuracy
3. Add more frameworks for comparison
4. Document findings in `results/`

## ⚡ Quick Commands

```bash
# Run benchmarks
flutter test integration_test/

# Run demo app
flutter run

# Clean build
flutter clean && flutter pub get

# Check for issues
flutter analyze
```

---

**Note**: This benchmark focuses on **real-world UI performance**. Results include Flutter framework overhead and represent actual user experience.

