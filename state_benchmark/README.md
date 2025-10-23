# State Management Benchmark

A comprehensive, **fair**, and **unbiased** benchmark suite comparing **PipeX**, **Riverpod**, and **BLoC** state management solutions for Flutter.

## ⚖️ Why This Benchmark is Fair

Unlike biased benchmarks that only test one framework's strengths, this suite:

✅ **Tests each framework where it excels**
- Riverpod: Derived/computed state
- BLoC: Complex async flows  
- PipeX: Raw update speed

✅ **Uses equivalent architectures** where comparable
- Riverpod uses family providers for fair isolation
- Each framework follows best practices

✅ **Explains trade-offs transparently**
- Architectural differences are noted
- Performance differences are contextualized

**👉 Read [FAIR_COMPARISON.md](FAIR_COMPARISON.md) for details on eliminated biases.**

## 🎯 Features

- **Interactive UI Benchmarks** - Visual comparison with real-time performance metrics
- **Automated Integration Tests** - Programmatic performance measurement
- **Multiple Test Scenarios** - Simple counters, multi-state, complex objects, derived state, async flows, and stress tests
- **Detailed Metrics** - Update latency, rebuild counts, memory usage, async performance
- **Results Export** - CSV format for further analysis
- **Fair Comparison Notes** - Each test explains what it measures and why

## 📁 Project Structure

```
state_benchmark/
 ├─ lib/
 │   ├─ main.dart                      # Interactive benchmark UI
 │   ├─ cases/
 │   │   ├─ bloc_case.dart            # BLoC test implementations
 │   │   ├─ riverpod_case.dart        # Riverpod test implementations
 │   │   └─ pipex_case.dart           # PipeX test implementations
 │   └─ benchmarks/
 │       ├─ rebuild_benchmark.dart     # Widget rebuild measurements
 │       ├─ update_latency_benchmark.dart  # State update latency tests
 │       └─ async_benchmark.dart       # Async performance tests
 ├─ integration_test/
 │   └─ ui_benchmark_test.dart        # Automated UI performance tests
 ├─ results/                          # Benchmark results storage
 │   ├─ README.md
 │   └─ results.csv
 └─ pubspec.yaml
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.3.0 or higher
- Dart SDK 3.3.0 or higher

### Installation

```bash
cd state_benchmark
flutter pub get
```

## 📊 Running Benchmarks

### Option 1: Interactive UI (Recommended)

Run the app to use the interactive benchmark interface:

```bash
flutter run
```

**Features:**
- Visual comparison of all three frameworks
- Real-time performance metrics
- Multiple test scenarios (Simple Counter, Multi-Counter, Complex State, Stress Tests)
- Results panel with detailed metrics
- Export results to CSV

### Option 2: Integration Tests

Run automated integration tests with detailed performance metrics:

```bash
flutter test integration_test/ui_benchmark_test.dart
```

This will:
- Execute all benchmark scenarios programmatically
- Measure frame timing and performance
- Generate detailed reports
- Save results to `results/` directory

### Option 3: Drive Tests (Device/Emulator)

For real device performance testing:

```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/ui_benchmark_test.dart
```

## 📈 Test Scenarios

### 1. Simple Counter
- Basic increment/decrement operations
- Single value state management
- Measures: Update latency, rebuild count
- **Fair for**: All frameworks (baseline)

### 2. Multi-Counter (50 counters) ⚖️ NOW FAIR
- Many independent state values
- Tests: State isolation, batch updates
- Measures: Batch update time, rebuild efficiency
- **Fair for**: All frameworks (Riverpod now uses family providers)

### 3. Complex State
- Large objects with nested data
- Multiple fields (text, number, percentage, etc.)
- Measures: Complex state update performance, memory usage
- **Fair for**: All frameworks (tests architectural trade-offs)

### 4. Derived State ⭐ NEW
- Automatic recomputation of computed values
- Multiple dependent states
- Measures: Derived state update performance, boilerplate
- **Fair for**: **Riverpod** (its strength - automatic dependency tracking)

### 5. Async Flow ⭐ NEW
- Complex async operations with debouncing
- Error handling and loading states
- Measures: Async processing efficiency
- **Fair for**: **BLoC** (its strength - stream operators)

### 6. Stress Tests
- **Rapid Updates**: 1000 consecutive updates
- **Concurrent Updates**: 500 simultaneous state changes
- **Memory Pressure**: 2000 updates with large objects
- Measures: Throughput, latency under load, stability

## 📊 Metrics Explained

### Update Latency
Time from state change to widget rebuild completion. Lower is better.

**Good**: < 100 μs  
**Acceptable**: 100-500 μs  
**Poor**: > 500 μs

### Rebuild Count
Number of widget rebuilds for N state changes. Fewer is better (indicates better optimization).

**Ideal**: 1:1 ratio (1 rebuild per state change)  
**Acceptable**: < 1.5:1 ratio  
**Poor**: > 2:1 ratio

### Batch Update Time
Time to update multiple independent states. Lower is better.

### Memory Usage
Memory consumed by state management infrastructure. Lower is better.

### Async Performance
Handling of rapid asynchronous updates without blocking UI. Higher throughput is better.

## 📁 Results

Results are automatically saved to the `results/` directory:

- `results_<timestamp>.csv` - Detailed benchmark results
- `stress_test_results.txt` - Stress test summaries

### CSV Format

```csv
Test Name,Framework,Metric,Value,Unit,Timestamp
Simple Counter,BLoC,Update Time,125.34,μs,2025-10-22T10:30:45.123Z
Simple Counter,Riverpod,Update Time,98.76,μs,2025-10-22T10:30:45.456Z
Simple Counter,PipeX,Update Time,87.21,μs,2025-10-22T10:30:45.789Z
```

## 🔬 Understanding Results

### What Makes a Good State Management Solution?

1. **Low Latency** - Fast state updates → responsive UI
2. **Minimal Rebuilds** - Only affected widgets rebuild → efficient
3. **Good Async Handling** - Smooth under async load → reliable
4. **Low Memory** - Minimal overhead → scalable
5. **State Isolation** - Independent states don't affect each other → maintainable

### Expected Performance Characteristics

**BLoC**
- ✅ Good async support (built-in stream handling)
- ⚠️ May rebuild all listeners for any state change
- ⚠️ More boilerplate (events, states, blocs)

**Riverpod**
- ✅ Fine-grained reactivity
- ✅ Good developer experience
- ⚠️ More complex for simple cases

**PipeX**
- ✅ Minimal boilerplate
- ✅ Direct element-tree integration
- ✅ Fine-grained reactivity
- ✅ Lightweight

## 🛠️ Customizing Benchmarks

### Adding New Tests

1. Create test implementations in `lib/cases/`
2. Add benchmark harness in `lib/benchmarks/`
3. Update `main.dart` to include new test in UI
4. Add integration test in `integration_test/`

### Example: Adding Custom Benchmark

```dart
// lib/cases/pipex_case.dart
class MyCustomHub extends Hub {
  late final Pipe<int> myState;
  
  MyCustomHub() {
    myState = registerPipe(Pipe(0));
  }
  
  void myOperation() {
    // Your logic here
  }
}

// lib/benchmarks/my_benchmark.dart
class MyBenchmark extends BenchmarkBase {
  MyBenchmark() : super('My Custom Benchmark');
  
  @override
  void run() {
    // Your benchmark logic
  }
}
```

## 📝 Best Practices

1. **Run on Real Devices** - Emulators may not reflect real performance
2. **Profile Mode** - Use `flutter run --profile` for accurate measurements
3. **Multiple Runs** - Average results from multiple runs
4. **Consistent Environment** - Same device, same conditions
5. **Avoid Thermal Throttling** - Let device cool between runs

## 🎛️ Configuration

Edit `pubspec.yaml` to update framework versions:

```yaml
dependencies:
  pipe_x: ^latest
  flutter_bloc: ^8.1.3
  flutter_riverpod: ^2.4.0
```

## 🐛 Troubleshooting

### Tests Taking Too Long
- Reduce iteration counts in stress tests
- Run individual tests instead of full suite

### Memory Issues
- Reduce number of state instances in memory tests
- Run tests individually

### Inconsistent Results
- Ensure device is not under load
- Close other apps
- Wait for device to cool
- Run in profile mode, not debug mode

## 📄 License

This benchmark suite is part of the PipeX project and follows the same license.

## 🤝 Contributing

To contribute benchmark scenarios:

1. Fork the repository
2. Add your benchmark scenario
3. Ensure tests pass
4. Submit a pull request

## 📞 Support

For issues or questions:
- Open an issue on GitHub
- Check existing documentation
- Review example implementations

## 📚 Documentation

- **⭐ FAIR_COMPARISON.md** - **START HERE**: Complete explanation of fairness and bias elimination
- **BENCHMARK_GUIDE.md** - Comprehensive guide on running and interpreting benchmarks
- **PIPEX_LIFECYCLE.md** - Understanding PipeX's unique lifecycle management  
- **PROJECT_SUMMARY.md** - Complete project overview and implementation details

---

**Happy Fair Benchmarking! 🚀⚖️**

