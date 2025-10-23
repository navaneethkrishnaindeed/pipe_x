# Benchmark Results

This directory contains benchmark results from comparing PipeX, Riverpod, and BLoC state management solutions.

## Result Files

- `results_*.csv` - CSV files with detailed benchmark results
- `stress_test_results.txt` - Stress test performance metrics
- Additional test outputs will be saved here

## CSV Format

```csv
Test Name,Framework,Metric,Value,Unit,Timestamp
```

Example:
```csv
Simple Counter,BLoC,Update Time,125.34,μs,2025-10-22T10:30:45.123Z
Simple Counter,Riverpod,Update Time,98.76,μs,2025-10-22T10:30:45.456Z
Simple Counter,PipeX,Update Time,87.21,μs,2025-10-22T10:30:45.789Z
```

## Metrics Tracked

1. **Update Latency** - Time from state change to widget update
2. **Rebuild Count** - Number of widget rebuilds for N state changes
3. **Batch Update Time** - Time to update multiple independent states
4. **Memory Pressure** - Performance under large state objects
5. **Async Performance** - Handling of rapid async updates
6. **Concurrent Updates** - Performance with simultaneous state modifications

## Running Benchmarks

### UI Benchmarks (Interactive)
```bash
cd state_benchmark
flutter run
```

### Integration Tests (Automated)
```bash
flutter test integration_test/ui_benchmark_test.dart
```

### Command Line Benchmarks
```bash
flutter test test/benchmark_test.dart
```

## Analyzing Results

Use the provided analysis scripts or import CSV files into your preferred data analysis tool.

Key metrics to compare:
- Lower latency is better
- Fewer rebuilds indicate better performance
- Lower memory usage is better
- Faster async handling is better

## Notes

- All benchmarks are run on the same device/emulator for fair comparison
- Results may vary based on device performance and Flutter version
- Run multiple times and average results for accuracy
- Ensure device is not under thermal throttling during tests

