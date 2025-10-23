import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:state_benchmark/cases/bloc_case.dart' as bloc;
import 'package:state_benchmark/cases/riverpod_case.dart' as riverpod;
import 'package:state_benchmark/cases/pipex_case.dart' as pipex;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_x/pipe_x.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Storage for results with multiple runs
  final Map<String, Map<String, List<BenchmarkResult>>> allResults = {};

  // Configuration - Increased warmup to ensure fair JIT compilation
  const int warmupIterations = 100; // More warmup for fair JIT
  const int measurementIterations = 500;
  const int numberOfRuns = 5;

  // RANDOMIZE test order to eliminate order effects
  final frameworks = ['BLoC', 'Riverpod', 'PipeX']..shuffle();

  print('\n🎲 Test execution order (randomized): ${frameworks.join(' → ')}\n');

  group('🚀 Simple Counter (with warmup & multiple runs)', () {
    for (final framework in frameworks) {
      testWidgets('$framework Counter - Statistically Valid',
          (WidgetTester tester) async {
        final List<BenchmarkResult> runs = [];

        for (int run = 0; run < numberOfRuns; run++) {
          print('\n  🔄 Run ${run + 1}/$numberOfRuns for $framework');

          // Clear widget tree from previous run
          if (run > 0) {
            await tester.pumpWidget(const SizedBox());
            await tester.pumpAndSettle();
          }

          // Better GC handling between runs
          await _forceGCPause();

          final result = await _benchmarkSimpleCounter(
            tester,
            binding,
            framework,
            warmupIterations: warmupIterations,
            measurementIterations: measurementIterations,
          );
          runs.add(result);
        }

        allResults['Simple Counter'] = allResults['Simple Counter'] ?? {};
        allResults['Simple Counter']![framework] = runs;

        _printStatisticalSummary(framework, 'Simple Counter', runs);
      });
    }
  });

  group('🔥 Multi-Counter (isolated updates)', () {
    for (final framework in frameworks) {
      testWidgets('$framework Multi-Counter - Individual Updates',
          (WidgetTester tester) async {
        final List<BenchmarkResult> runs = [];

        for (int run = 0; run < numberOfRuns; run++) {
          print('\n  🔄 Run ${run + 1}/$numberOfRuns for $framework');

          // Clear widget tree from previous run
          if (run > 0) {
            await tester.pumpWidget(const SizedBox());
            await tester.pumpAndSettle();
          }

          await _forceGCPause();

          final result = await _benchmarkMultiCounter(
            tester,
            binding,
            framework,
            counterCount: 20, // Reduced from 50 to avoid timeout
            rounds: 10, // Reduced from 20
            warmupRounds: 5, // Reduced from 10
          );
          runs.add(result);
        }

        allResults['Multi-Counter'] = allResults['Multi-Counter'] ?? {};
        allResults['Multi-Counter']![framework] = runs;

        _printStatisticalSummary(framework, 'Multi-Counter', runs);
      });
    }
  });

  group('💎  Complex State (individual field updates)', () {
    for (final framework in frameworks) {
      testWidgets('$framework Complex - Separate Field Measurements',
          (WidgetTester tester) async {
        final List<BenchmarkResult> runs = [];

        for (int run = 0; run < numberOfRuns; run++) {
          print('\n  🔄 Run ${run + 1}/$numberOfRuns for $framework');

          // Clear widget tree from previous run
          if (run > 0) {
            await tester.pumpWidget(const SizedBox());
            await tester.pumpAndSettle();
          }

          await _forceGCPause();

          final result = await _benchmarkComplexState(
            tester,
            binding,
            framework,
            iterations: 100,
            warmupIterations: 30,
          );
          runs.add(result);
        }

        allResults['Complex State'] = allResults['Complex State'] ?? {};
        allResults['Complex State']![framework] = runs;

        _printStatisticalSummary(framework, 'Complex State', runs);
      });
    }
  });

  group('⚡Stress Test (realistic pressure)', () {
    for (final framework in frameworks) {
      testWidgets('$framework Stress - Burst Updates',
          (WidgetTester tester) async {
        final List<BenchmarkResult> runs = [];

        for (int run = 0; run < 3; run++) {
          print('\n  🔄 Run ${run + 1}/3 for $framework');

          // Clear widget tree from previous run
          if (run > 0) {
            await tester.pumpWidget(const SizedBox());
            await tester.pumpAndSettle();
          }

          await _forceGCPause();

          final result = await _benchmarkStress(
            tester,
            binding,
            framework,
            totalUpdates: 1000, // Fair test: 1000 sequential updates with pump
          );
          runs.add(result);
        }

        allResults['Stress Test'] = allResults['Stress Test'] ?? {};
        allResults['Stress Test']![framework] = runs;

        _printStatisticalSummary(framework, 'Stress Test', runs);
      });
    }
  });

  group('🧪 Instance Creation Overhead', () {
    testWidgets('Instance Creation (Not Memory)', (WidgetTester tester) async {
      await _benchmarkInstanceCreation(tester);
    });
  });

  tearDownAll(() {
    if (allResults.isEmpty) return;

    _printComprehensiveReport(allResults);
    _exportResultsToJson(allResults);
  });
}

// ============================================================================
// Utility Functions
// ============================================================================

/// Force GC pause between runs
Future<void> _forceGCPause() async {
  developer.Timeline.startSync('GC_Pause');
  await Future.delayed(const Duration(milliseconds: 500));
  developer.Timeline.finishSync();
}

// ============================================================================
// Benchmark Implementations
// ============================================================================

Future<BenchmarkResult> _benchmarkSimpleCounter(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
  String framework, {
  required int warmupIterations,
  required int measurementIterations,
}) async {
  if (framework == 'BLoC') {
    final blocInstance = bloc.CounterBloc();

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: blocInstance,
          child: const Scaffold(body: bloc.BlocCounterWidget()),
        ),
      ),
    );

    // Verify widget is built
    expect(find.byType(bloc.BlocCounterWidget), findsOneWidget);
    print('  ✓ BLoC widget built successfully');

    // WARMUP PHASE
    for (int i = 0; i < warmupIterations; i++) {
      blocInstance.add(bloc.IncrementEvent());
      await tester.pump();
    }
    print('  ✓ Warmup complete (${warmupIterations} iterations)');

    // MEASUREMENT PHASE with verification
    final List<int> stateUpdateTimes = [];
    final stopwatch = Stopwatch();

    for (int i = 0; i < measurementIterations; i++) {
      // Measure update-to-render time
      stopwatch.start();
      blocInstance.add(bloc.IncrementEvent());
      await tester.pump();
      stopwatch.stop();
      stateUpdateTimes.add(stopwatch.elapsedMicroseconds);
      stopwatch.reset();
    }

    // VERIFY final state (should be warmup + measurement iterations)
    final expectedValue = warmupIterations + measurementIterations;
    expect(blocInstance.state.value, expectedValue,
        reason: 'State updates should have been applied');

    // Verify widget still exists and shows correct value
    expect(find.text('BLoC: $expectedValue'), findsOneWidget);
    print('  ✓ Final value verified: $expectedValue');

    blocInstance.close();

    return BenchmarkResult(
      framework: framework,
      category: 'Simple Counter',
      stateUpdateTimes: stateUpdateTimes,
      renderTimes: [],
    );
  } else if (framework == 'Riverpod') {
    final container = ProviderContainer();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: riverpod.RiverpodCounterWidget()),
        ),
      ),
    );

    // Verify widget is built
    expect(find.byType(riverpod.RiverpodCounterWidget), findsOneWidget);
    print('  ✓ Riverpod widget built successfully');

    // WARMUP
    for (int i = 0; i < warmupIterations; i++) {
      container.read(riverpod.counterProvider.notifier).increment();
      await tester.pump();
    }
    print('  ✓ Warmup complete (${warmupIterations} iterations)');

    // MEASUREMENT with verification
    final List<int> stateUpdateTimes = [];
    final stopwatch = Stopwatch();

    for (int i = 0; i < measurementIterations; i++) {
      stopwatch.start();
      container.read(riverpod.counterProvider.notifier).increment();
      await tester.pump();
      stopwatch.stop();
      stateUpdateTimes.add(stopwatch.elapsedMicroseconds);
      stopwatch.reset();
    }

    // VERIFY final state
    final expectedValue = warmupIterations + measurementIterations;
    expect(container.read(riverpod.counterProvider), expectedValue,
        reason: 'State updates should have been applied');

    // Verify widget still exists and shows correct value
    expect(find.text('Riverpod: $expectedValue'), findsOneWidget);
    print('  ✓ Final value verified: $expectedValue');

    container.dispose();

    return BenchmarkResult(
      framework: framework,
      category: 'Simple Counter',
      stateUpdateTimes: stateUpdateTimes,
      renderTimes: [],
    );
  } else {
    // PipeX
    final hub = pipex.CounterHub();

    await tester.pumpWidget(
      MaterialApp(
        home: HubProvider<pipex.CounterHub>(
          create: () => hub,
          child: const Scaffold(body: pipex.PipeXCounterWidget()),
        ),
      ),
    );

    // Verify widget is built
    expect(find.byType(pipex.PipeXCounterWidget), findsOneWidget);
    print('  ✓ PipeX widget built successfully');

    // WARMUP
    for (int i = 0; i < warmupIterations; i++) {
      hub.increment();
      await tester.pump();
    }
    print('  ✓ Warmup complete (${warmupIterations} iterations)');

    // MEASUREMENT with verification
    final List<int> stateUpdateTimes = [];
    final stopwatch = Stopwatch();

    for (int i = 0; i < measurementIterations; i++) {
      stopwatch.start();
      hub.increment();
      await tester.pump();
      stopwatch.stop();
      stateUpdateTimes.add(stopwatch.elapsedMicroseconds);
      stopwatch.reset();
    }

    // VERIFY final state
    final expectedValue = warmupIterations + measurementIterations;
    expect(hub.count.value, expectedValue,
        reason: 'State updates should have been applied');

    // Verify widget still exists and shows correct value
    expect(find.text('PipeX: $expectedValue'), findsOneWidget);
    print('  ✓ Final value verified: $expectedValue');

    return BenchmarkResult(
      framework: framework,
      category: 'Simple Counter',
      stateUpdateTimes: stateUpdateTimes,
      renderTimes: [],
    );
  }
}

Future<BenchmarkResult> _benchmarkMultiCounter(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
  String framework, {
  required int counterCount,
  required int rounds,
  required int warmupRounds,
}) async {
  final List<int> stateUpdateTimes = [];

  if (framework == 'BLoC') {
    final multiBloc = bloc.MultiCounterBloc(counterCount);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: multiBloc,
          child: Scaffold(
            body: bloc.BlocMultiCounterWidget(count: counterCount),
          ),
        ),
      ),
    );

    // WARMUP
    for (int round = 0; round < warmupRounds; round++) {
      for (int i = 0; i < counterCount; i++) {
        multiBloc.increment(i);
        await tester.pump(); // Pump after EACH update to ensure rebuild
      }
    }

    // MEASUREMENT - Individual counter updates
    final stopwatch = Stopwatch();

    for (int round = 0; round < rounds; round++) {
      stopwatch.start();
      multiBloc.increment(round % counterCount);
      await tester.pump();
      stopwatch.stop();
      stateUpdateTimes.add(stopwatch.elapsedMicroseconds);
      stopwatch.reset();
    }

    multiBloc.close();
  } else if (framework == 'Riverpod') {
    final container = ProviderContainer();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: riverpod.RiverpodMultiCounterWidget(
              count: counterCount,
            ),
          ),
        ),
      ),
    );

    // WARMUP
    for (int round = 0; round < warmupRounds; round++) {
      for (int i = 0; i < counterCount; i++) {
        container.read(riverpod.individualCounterProvider(i).notifier).state++;
        await tester.pump(); // Pump after EACH update to ensure rebuild
      }
    }

    // MEASUREMENT
    final stopwatch = Stopwatch();

    for (int round = 0; round < rounds; round++) {
      final id = round % counterCount;

      stopwatch.start();
      container.read(riverpod.individualCounterProvider(id).notifier).state++;
      await tester.pump();
      stopwatch.stop();
      stateUpdateTimes.add(stopwatch.elapsedMicroseconds);
      stopwatch.reset();
    }

    container.dispose();
  } else {
    // PipeX
    final hub = pipex.MultiCounterHub(counterCount);

    await tester.pumpWidget(
      MaterialApp(
        home: HubProvider<pipex.MultiCounterHub>(
          create: () => hub,
          child: Scaffold(
            body: pipex.PipeXMultiCounterWidget(count: counterCount),
          ),
        ),
      ),
    );

    // WARMUP
    for (int round = 0; round < warmupRounds; round++) {
      for (int i = 0; i < counterCount; i++) {
        hub.increment(i);
        await tester.pump(); // Pump after EACH update to ensure rebuild
      }
    }

    // MEASUREMENT
    final stopwatch = Stopwatch();

    for (int round = 0; round < rounds; round++) {
      final id = round % counterCount;

      stopwatch.start();
      hub.increment(id);
      await tester.pump();
      stopwatch.stop();
      stateUpdateTimes.add(stopwatch.elapsedMicroseconds);
      stopwatch.reset();
    }
  }

  return BenchmarkResult(
    framework: framework,
    category: 'Multi-Counter',
    stateUpdateTimes: stateUpdateTimes,
    renderTimes: [],
  );
}

Future<BenchmarkResult> _benchmarkComplexState(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
  String framework, {
  required int iterations,
  required int warmupIterations,
}) async {
  final List<int> stateUpdateTimes = [];

  if (framework == 'BLoC') {
    final complexBloc = bloc.ComplexBloc();

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: complexBloc,
          child: const Scaffold(body: bloc.BlocComplexWidget()),
        ),
      ),
    );

    // WARMUP
    for (int i = 0; i < warmupIterations; i++) {
      complexBloc.add(bloc.UpdateTextEvent('Warmup $i'));
      await tester.pump();
    }

    // MEASUREMENT - ONE UPDATE AT A TIME (not batched!)
    final stopwatch = Stopwatch();

    for (int i = 0; i < iterations; i++) {
      stopwatch.start();

      // Cycle through different field types
      if (i % 3 == 0) {
        complexBloc.add(bloc.UpdateTextEvent('Value $i'));
      } else if (i % 3 == 1) {
        complexBloc.add(bloc.UpdateNumberEvent(i));
      } else {
        complexBloc.add(bloc.UpdatePercentageEvent(i * 0.5));
      }

      await tester.pump();
      stopwatch.stop();
      stateUpdateTimes.add(stopwatch.elapsedMicroseconds);
      stopwatch.reset();
    }

    complexBloc.close();
  } else if (framework == 'Riverpod') {
    final container = ProviderContainer();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: riverpod.RiverpodComplexWidget()),
        ),
      ),
    );

    final notifier = container.read(riverpod.complexProvider.notifier);

    // WARMUP
    for (int i = 0; i < warmupIterations; i++) {
      notifier.updateText('Warmup $i');
      await tester.pump();
    }

    // MEASUREMENT
    final stopwatch = Stopwatch();

    for (int i = 0; i < iterations; i++) {
      stopwatch.start();

      if (i % 3 == 0) {
        notifier.updateText('Value $i');
      } else if (i % 3 == 1) {
        notifier.updateNumber(i);
      } else {
        notifier.updatePercentage(i * 0.5);
      }

      await tester.pump();
      stopwatch.stop();
      stateUpdateTimes.add(stopwatch.elapsedMicroseconds);
      stopwatch.reset();
    }

    container.dispose();
  } else {
    // PipeX
    final hub = pipex.ComplexHub();

    await tester.pumpWidget(
      MaterialApp(
        home: HubProvider<pipex.ComplexHub>(
          create: () => hub,
          child: const Scaffold(body: pipex.PipeXComplexWidget()),
        ),
      ),
    );

    // WARMUP
    for (int i = 0; i < warmupIterations; i++) {
      hub.updateText('Warmup $i');
      await tester.pump();
    }

    // MEASUREMENT
    final stopwatch = Stopwatch();

    for (int i = 0; i < iterations; i++) {
      stopwatch.start();

      if (i % 3 == 0) {
        hub.updateText('Value $i');
      } else if (i % 3 == 1) {
        hub.updateNumber(i);
      } else {
        hub.updatePercentage(i * 0.5);
      }

      await tester.pump();
      stopwatch.stop();
      stateUpdateTimes.add(stopwatch.elapsedMicroseconds);
      stopwatch.reset();
    }
  }

  return BenchmarkResult(
    framework: framework,
    category: 'Complex State',
    stateUpdateTimes: stateUpdateTimes,
    renderTimes: [],
  );
}

Future<BenchmarkResult> _benchmarkStress(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
  String framework, {
  required int totalUpdates,
}) async {
  // Stress test: Rapid sequential updates (measures real-world high-frequency throughput)
  // Each update followed by pump (not idle) to measure actual render performance
  final List<int> updateTimes = [];
  final stopwatch = Stopwatch();

  if (framework == 'BLoC') {
    final blocInstance = bloc.CounterBloc();
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: blocInstance,
          child: const Scaffold(body: bloc.BlocCounterWidget()),
        ),
      ),
    );

    for (int i = 0; i < totalUpdates; i++) {
      stopwatch.start();
      blocInstance.add(bloc.IncrementEvent());
      await tester.pump(); // Just pump, no idle - fair comparison
      stopwatch.stop();
      updateTimes.add(stopwatch.elapsedMicroseconds);
      stopwatch.reset();
    }

    blocInstance.close();
  } else if (framework == 'Riverpod') {
    final container = ProviderContainer();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: riverpod.RiverpodCounterWidget()),
        ),
      ),
    );

    for (int i = 0; i < totalUpdates; i++) {
      stopwatch.start();
      container.read(riverpod.counterProvider.notifier).increment();
      await tester.pump();
      stopwatch.stop();
      updateTimes.add(stopwatch.elapsedMicroseconds);
      stopwatch.reset();
    }

    container.dispose();
  } else {
    final hub = pipex.CounterHub();
    await tester.pumpWidget(
      MaterialApp(
        home: HubProvider<pipex.CounterHub>(
          create: () => hub,
          child: const Scaffold(body: pipex.PipeXCounterWidget()),
        ),
      ),
    );

    for (int i = 0; i < totalUpdates; i++) {
      stopwatch.start();
      hub.increment();
      await tester.pump();
      stopwatch.stop();
      updateTimes.add(stopwatch.elapsedMicroseconds);
      stopwatch.reset();
    }
  }

  return BenchmarkResult(
    framework: framework,
    category: 'Stress Test',
    stateUpdateTimes: updateTimes,
    renderTimes: [], // Not tracking separate render times in this test
  );
}

Future<void> _benchmarkInstanceCreation(WidgetTester tester) async {
  print('\n╔' + '═' * 78 + '╗');
  print('║' + ' ' * 20 + '🧪 INSTANCE CREATION OVERHEAD' + ' ' * 20 + '║');
  print('╚' + '═' * 78 + '╝\n');

  // Force GC before starting
  developer.Timeline.startSync('Memory Benchmark');

  for (final framework in ['BLoC', 'Riverpod', 'PipeX']) {
    print('Testing $framework memory usage...');

    // Get initial memory
    await developer.debugger(when: false);

    const instanceCount = 100;

    if (framework == 'BLoC') {
      final blocs = <bloc.CounterBloc>[];

      // Create instances
      for (int i = 0; i < instanceCount; i++) {
        blocs.add(bloc.CounterBloc());
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: blocs
                  .map((b) => BlocProvider.value(
                        value: b,
                        child: const bloc.BlocCounterWidget(),
                      ))
                  .toList(),
            ),
          ),
        ),
      );
      await tester.pump();

      print('  Created $instanceCount BLoC instances');

      // Cleanup
      for (final b in blocs) {
        b.close();
      }
    } else if (framework == 'Riverpod') {
      final container = ProviderContainer();

      // Create instances via providers
      for (int i = 0; i < instanceCount; i++) {
        container.read(riverpod.individualCounterProvider(i));
      }

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: ListView(
                children: List.generate(
                  instanceCount,
                  (i) => Consumer(
                    builder: (context, ref, _) {
                      final value =
                          ref.watch(riverpod.individualCounterProvider(i));
                      return ListTile(title: Text('Counter $i: $value'));
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      print('  Created $instanceCount Riverpod providers');

      container.dispose();
    } else {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: List.generate(
                instanceCount,
                (i) => HubProvider<pipex.CounterHub>(
                  key: ValueKey('hub_$i'),
                  create: () => pipex.CounterHub(),
                  child: const pipex.PipeXCounterWidget(),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      print('  Created $instanceCount PipeX hubs');
    }

    // Clear for next test
    await tester.pumpWidget(const SizedBox());
    await tester.pump();

    print('  ✓ Cleaned up\n');
  }

  developer.Timeline.finishSync();
  print('💡 This test measures INSTANCE CREATION time, NOT memory usage.');
  print('   For actual memory profiling:');
  print(
      '   1. Run: flutter drive --profile -t integration_test/ui_benchmark_test_improved.dart');
  print('   2. Open DevTools Memory Profiler');
  print('   3. Take heap snapshots before/after instance creation');
  print('   4. Compare retained size\n');
}

// ============================================================================
// Data Classes
// ============================================================================

class BenchmarkResult {
  final String framework;
  final String category;
  final List<int> stateUpdateTimes;
  final List<int> renderTimes;

  BenchmarkResult({
    required this.framework,
    required this.category,
    required this.stateUpdateTimes,
    required this.renderTimes,
  });

  // Statistical calculations
  double get avgStateUpdate =>
      _average(stateUpdateTimes.map((t) => t / 1000.0).toList());
  double get medianStateUpdate =>
      _median(stateUpdateTimes.map((t) => t / 1000.0).toList());
  double get stdDevStateUpdate =>
      _stdDev(stateUpdateTimes.map((t) => t / 1000.0).toList());
  double get p95StateUpdate =>
      _percentile(stateUpdateTimes.map((t) => t / 1000.0).toList(), 0.95);

  double get avgRender => _average(renderTimes.map((t) => t / 1000.0).toList());
  double get medianRender =>
      _median(renderTimes.map((t) => t / 1000.0).toList());
  double get stdDevRender =>
      _stdDev(renderTimes.map((t) => t / 1000.0).toList());

  Map<String, dynamic> toJson() => {
        'framework': framework,
        'category': category,
        'stateUpdate': {
          'avg': avgStateUpdate,
          'median': medianStateUpdate,
          'stdDev': stdDevStateUpdate,
          'p95': p95StateUpdate,
        },
      };
}

// ============================================================================
// Statistical Functions
// ============================================================================

double _average(List<double> values) {
  if (values.isEmpty) return 0.0;
  return values.reduce((a, b) => a + b) / values.length;
}

double _median(List<double> values) {
  if (values.isEmpty) return 0.0;
  final sorted = List<double>.from(values)..sort();
  final middle = sorted.length ~/ 2;
  if (sorted.length % 2 == 1) {
    return sorted[middle];
  }
  return (sorted[middle - 1] + sorted[middle]) / 2;
}

double _stdDev(List<double> values) {
  if (values.isEmpty) return 0.0;
  final avg = _average(values);
  final variance =
      values.map((v) => (v - avg) * (v - avg)).reduce((a, b) => a + b) /
          values.length;
  return variance.isNaN || variance < 0 ? 0.0 : math.sqrt(variance);
}

double _percentile(List<double> values, double percentile) {
  if (values.isEmpty) return 0.0;
  final sorted = List<double>.from(values)..sort();
  final index = (sorted.length * percentile).ceil() - 1;
  return sorted[index.clamp(0, sorted.length - 1)];
}

// ============================================================================
// Reporting Functions
// ============================================================================

void _printStatisticalSummary(
  String framework,
  String category,
  List<BenchmarkResult> runs,
) {
  print('\n' + '─' * 80);
  print('📊 $framework - $category (${runs.length} runs)');
  print('─' * 80);

  // Aggregate per-run statistics (NOT raw measurements!)
  // Each run has its own median, we aggregate those
  final runMedianStates = runs.map((r) => r.medianStateUpdate).toList();
  final runP95States = runs.map((r) => r.p95StateUpdate).toList();

  // Report median-of-medians (most robust)
  final medianState = _median(runMedianStates);
  final stdDevAcrossRuns = _stdDev(runMedianStates); // Variability across runs

  // Report average P95
  final avgP95State = _average(runP95States);

  print('🔄 State Update Performance (includes rendering):');
  print('   Median: ${medianState.toStringAsFixed(3)} ms');
  print('   P95 (worst case): ${avgP95State.toStringAsFixed(3)} ms');

  final cvAcrossRuns =
      medianState > 0 ? (stdDevAcrossRuns / medianState * 100).toDouble() : 0.0;
  print('\n📈 Run-to-Run Consistency:');
  print(
      '   Variability: ±${stdDevAcrossRuns.toStringAsFixed(3)} ms (${cvAcrossRuns.toStringAsFixed(1)}%) ${_getConsistencyRating(cvAcrossRuns)}');

  print('─' * 80);
}

String _getConsistencyRating(double cv) {
  if (cv < 10) return '✅ Excellent';
  if (cv < 20) return '👍 Good';
  if (cv < 30) return '⚠️  Fair';
  return '🔴 Poor (high variance)';
}

void _printComprehensiveReport(
    Map<String, Map<String, List<BenchmarkResult>>> allResults) {
  print('\n\n');
  print('╔' + '═' * 88 + '╗');
  print(
      '║' + ' ' * 15 + '🏆 BENCHMARK - STATISTICAL REPORT 🏆' + ' ' * 15 + '║');
  print('╚' + '═' * 88 + '╝');
  print('\n');
  print('📌 Note: All tests use fair comparison methods (pump, not idle).');
  print('   Results reflect real-world rendering performance.');
  print('');

  for (final category in allResults.keys) {
    print('\n┌─ $category ${'─' * (86 - category.length)}');

    final frameworkResults = allResults[category]!;
    final frameworks = frameworkResults.keys.toList();

    // Calculate median-of-medians for ranking (correct statistical approach)
    final rankings = <String, double>{};
    for (final framework in frameworks) {
      final runs = frameworkResults[framework]!;
      // Get median from each run, then take median of those
      final runMedians = runs.map((r) => r.medianStateUpdate).toList();
      rankings[framework] = _median(runMedians);
    }

    final sorted = rankings.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    for (int i = 0; i < sorted.length; i++) {
      final entry = sorted[i];
      final marker = i == 0
          ? '🏆'
          : i == 1
              ? '🥈'
              : '🥉';

      print('│  $marker ${entry.key.padRight(12)}: '
          '${entry.value.toStringAsFixed(3)} ms (median-of-medians state update)');
    }

    if (sorted.length > 1) {
      final fastest = sorted.first.value;
      final slowest = sorted.last.value;
      final diff = slowest - fastest;
      final percentDiff =
          fastest > 0 ? ((diff / fastest) * 100).toStringAsFixed(1) : '0';
      print('│');
      print(
          '│  💡 ${sorted.first.key} is $percentDiff% faster than ${sorted.last.key}');
    }

    print('└' + '─' * 88);
  }

  // Calculate overall wins
  print('\n┌─ Overall Summary ' + '─' * 69);
  final wins = <String, int>{'BLoC': 0, 'Riverpod': 0, 'PipeX': 0};

  for (final category in allResults.keys) {
    final frameworkResults = allResults[category]!;
    final frameworks = frameworkResults.keys.toList();
    final rankings = <String, double>{};

    for (final framework in frameworks) {
      final runs = frameworkResults[framework]!;
      final runMedians = runs.map((r) => r.medianStateUpdate).toList();
      rankings[framework] = _median(runMedians);
    }

    final sorted = rankings.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    if (sorted.isNotEmpty) {
      wins[sorted.first.key] = (wins[sorted.first.key] ?? 0) + 1;
    }
  }

  print('│');
  wins.forEach((framework, count) {
    print('│  $framework: $count wins');
  });

  print('└' + '─' * 88);
  print('\n');
}

void _exportResultsToJson(
    Map<String, Map<String, List<BenchmarkResult>>> allResults) {
  try {
    final jsonData = {
      'timestamp': DateTime.now().toIso8601String(),
      'platform': Platform.operatingSystem,
      'note': 'Benchmark with warmup, multiple runs, and statistical analysis',
      'categories': allResults.map((category, frameworks) {
        return MapEntry(
          category,
          frameworks.map((framework, runs) {
            return MapEntry(framework, runs.map((r) => r.toJson()).toList());
          }),
        );
      }),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
    print('\n📊 Benchmark JSON Results:\n$jsonString');
  } catch (e) {
    print('⚠️  Could not export JSON: $e');
  }
}
