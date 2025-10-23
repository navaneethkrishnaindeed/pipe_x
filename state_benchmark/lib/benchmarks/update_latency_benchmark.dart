import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../cases/bloc_case.dart' as bloc;
import '../cases/riverpod_case.dart' as riverpod;
import '../cases/pipex_case.dart' as pipex;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_x/pipe_x.dart';

// ============================================================================
// Update Latency Benchmark
// Measures time from state change to widget update
// ============================================================================

class BlocUpdateLatencyBenchmark extends BenchmarkBase {
  BlocUpdateLatencyBenchmark() : super('BLoC Update Latency');

  @override
  void run() {
    final stopwatch = Stopwatch();

    testWidgets('BLoC latency test', (WidgetTester tester) async {
      final blocInstance = bloc.CounterBloc();
      int updateCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: blocInstance,
            child: BlocBuilder<bloc.CounterBloc, bloc.CounterState>(
              builder: (context, state) {
                if (updateCount > 0) {
                  stopwatch.stop();
                }
                updateCount++;
                return Text('${state.value}');
              },
            ),
          ),
        ),
      );

      // Measure 1000 updates
      final latencies = <int>[];
      for (int i = 0; i < 1000; i++) {
        stopwatch.reset();
        stopwatch.start();
        blocInstance.add(bloc.IncrementEvent());
        await tester.pump();
        latencies.add(stopwatch.elapsedMicroseconds);
      }

      final avgLatency = latencies.reduce((a, b) => a + b) / latencies.length;
      print('$name: ${avgLatency.toStringAsFixed(2)} μs average');

      blocInstance.close();
    });
  }
}

class RiverpodUpdateLatencyBenchmark extends BenchmarkBase {
  RiverpodUpdateLatencyBenchmark() : super('Riverpod Update Latency');

  @override
  void run() {
    final stopwatch = Stopwatch();

    testWidgets('Riverpod latency test', (WidgetTester tester) async {
      final container = ProviderContainer();
      int updateCount = 0;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) {
                if (updateCount > 0) {
                  stopwatch.stop();
                }
                updateCount++;
                final count = ref.watch(riverpod.counterProvider);
                return Text('$count');
              },
            ),
          ),
        ),
      );

      // Measure 1000 updates
      final latencies = <int>[];
      for (int i = 0; i < 1000; i++) {
        stopwatch.reset();
        stopwatch.start();
        container.read(riverpod.counterProvider.notifier).increment();
        await tester.pump();
        latencies.add(stopwatch.elapsedMicroseconds);
      }

      final avgLatency = latencies.reduce((a, b) => a + b) / latencies.length;
      print('$name: ${avgLatency.toStringAsFixed(2)} μs average');

      container.dispose();
    });
  }
}

class PipeXUpdateLatencyBenchmark extends BenchmarkBase {
  PipeXUpdateLatencyBenchmark() : super('PipeX Update Latency');

  @override
  void run() {
    final stopwatch = Stopwatch();

    testWidgets('PipeX latency test', (WidgetTester tester) async {
      final hub = pipex.CounterHub();
      int updateCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: HubProvider<pipex.CounterHub>(
            create: () => hub,
            child: Sink<int>(
              pipe: hub.count,
              builder: (context, value) {
                if (updateCount > 0) {
                  stopwatch.stop();
                }
                updateCount++;
                return Text('$value');
              },
            ),
          ),
        ),
      );

      // Measure 1000 updates
      final latencies = <int>[];
      for (int i = 0; i < 1000; i++) {
        stopwatch.reset();
        stopwatch.start();
        hub.increment();
        await tester.pump();
        latencies.add(stopwatch.elapsedMicroseconds);
      }

      final avgLatency = latencies.reduce((a, b) => a + b) / latencies.length;
      print('$name: ${avgLatency.toStringAsFixed(2)} μs average');

      hub.dispose();
    });
  }
}

// ============================================================================
// Batch Update Benchmark
// Tests performance when updating multiple values simultaneously
// ============================================================================

class BlocBatchUpdateBenchmark extends BenchmarkBase {
  BlocBatchUpdateBenchmark() : super('BLoC Batch Update (100 counters)');

  @override
  void run() {
    final stopwatch = Stopwatch();

    testWidgets('BLoC batch test', (WidgetTester tester) async {
      final multiBloc = bloc.MultiCounterBloc(100);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: multiBloc,
            child: BlocBuilder<bloc.MultiCounterBloc, bloc.MultiCounterState>(
              builder: (context, state) {
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      // Measure time to update all 100 counters
      stopwatch.start();
      for (int i = 0; i < 100; i++) {
        multiBloc.increment(i);
      }
      await tester.pumpAndSettle();
      stopwatch.stop();

      print('$name: ${stopwatch.elapsedMilliseconds} ms');

      multiBloc.close();
    });
  }
}

class PipeXBatchUpdateBenchmark extends BenchmarkBase {
  PipeXBatchUpdateBenchmark() : super('PipeX Batch Update (100 counters)');

  @override
  void run() {
    final stopwatch = Stopwatch();

    testWidgets('PipeX batch test', (WidgetTester tester) async {
      final hub = pipex.MultiCounterHub(100);

      await tester.pumpWidget(
        MaterialApp(
          home: HubProvider<pipex.MultiCounterHub>(
            create: () => hub,
            child: const SizedBox(),
          ),
        ),
      );

      // Measure time to update all 100 counters
      stopwatch.start();
      for (int i = 0; i < 100; i++) {
        hub.increment(i);
      }
      await tester.pumpAndSettle();
      stopwatch.stop();

      print('$name: ${stopwatch.elapsedMilliseconds} ms');

      hub.dispose();
    });
  }
}

// ============================================================================
// Memory Pressure Test
// Tests performance under memory pressure with large state objects
// ============================================================================

class BlocMemoryPressureBenchmark extends BenchmarkBase {
  BlocMemoryPressureBenchmark() : super('BLoC Memory Pressure');

  @override
  void run() {
    testWidgets('BLoC memory test', (WidgetTester tester) async {
      final stopwatch = Stopwatch();
      final complexBloc = bloc.ComplexBloc();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: complexBloc,
            child: BlocBuilder<bloc.ComplexBloc, bloc.ComplexState>(
              builder: (context, state) => const SizedBox(),
            ),
          ),
        ),
      );

      stopwatch.start();
      // Rapidly update complex state 500 times
      for (int i = 0; i < 500; i++) {
        complexBloc.add(bloc.UpdateTextEvent('Value $i'));
        complexBloc.add(bloc.UpdateNumberEvent(i));
        complexBloc.add(bloc.UpdatePercentageEvent(i * 0.1));
        await tester.pump();
      }
      stopwatch.stop();

      print('$name: ${stopwatch.elapsedMilliseconds} ms for 1500 updates');

      complexBloc.close();
    });
  }
}

class PipeXMemoryPressureBenchmark extends BenchmarkBase {
  PipeXMemoryPressureBenchmark() : super('PipeX Memory Pressure');

  @override
  void run() {
    testWidgets('PipeX memory test', (WidgetTester tester) async {
      final stopwatch = Stopwatch();
      final hub = pipex.ComplexHub();

      await tester.pumpWidget(
        MaterialApp(
          home: HubProvider<pipex.ComplexHub>(
            create: () => hub,
            child: Well(
              pipes: [hub.text, hub.number, hub.percentage],
              builder: (context) => const SizedBox(),
            ),
          ),
        ),
      );

      stopwatch.start();
      // Rapidly update complex state 500 times
      for (int i = 0; i < 500; i++) {
        hub.updateText('Value $i');
        hub.updateNumber(i);
        hub.updatePercentage(i * 0.1);
        await tester.pump();
      }
      stopwatch.stop();

      print('$name: ${stopwatch.elapsedMilliseconds} ms for 1500 updates');

      hub.dispose();
    });
  }
}

// ============================================================================
// Run all update latency benchmarks
// ============================================================================

void runUpdateLatencyBenchmarks() {
  print('\n=== UPDATE LATENCY BENCHMARKS ===\n');

  print('Single Update Latency:');
  BlocUpdateLatencyBenchmark().run();
  RiverpodUpdateLatencyBenchmark().run();
  PipeXUpdateLatencyBenchmark().run();

  print('\nBatch Updates:');
  BlocBatchUpdateBenchmark().run();
  PipeXBatchUpdateBenchmark().run();

  print('\nMemory Pressure:');
  BlocMemoryPressureBenchmark().run();
  PipeXMemoryPressureBenchmark().run();
}
