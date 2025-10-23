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
// Async Stream Benchmark
// Tests handling of rapid async updates
// ============================================================================

class BlocAsyncStreamBenchmark extends BenchmarkBase {
  BlocAsyncStreamBenchmark() : super('BLoC Async Stream (1000 updates)');

  @override
  void run() {
    testWidgets('BLoC async test', (WidgetTester tester) async {
      final stopwatch = Stopwatch();
      final asyncBloc = bloc.AsyncCounterBloc();
      int updateCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: asyncBloc,
            child: BlocBuilder<bloc.AsyncCounterBloc, bloc.CounterState>(
              builder: (context, state) {
                updateCount++;
                return Text('${state.value}');
              },
            ),
          ),
        ),
      );

      stopwatch.start();

      // Trigger 1000 async updates
      for (int i = 0; i < 1000; i++) {
        asyncBloc.add(bloc.IncrementEvent());
      }

      // Wait for all updates to complete
      await tester.pumpAndSettle();
      stopwatch.stop();

      print(
          '$name: ${stopwatch.elapsedMilliseconds} ms (${updateCount} rebuilds)');

      asyncBloc.close();
    });
  }
}

class RiverpodAsyncStreamBenchmark extends BenchmarkBase {
  RiverpodAsyncStreamBenchmark()
      : super('Riverpod Async Stream (1000 updates)');

  @override
  void run() {
    testWidgets('Riverpod async test', (WidgetTester tester) async {
      final stopwatch = Stopwatch();
      final container = ProviderContainer();
      int updateCount = 0;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) {
                updateCount++;
                final count = ref.watch(riverpod.asyncCounterProvider);
                return Text('$count');
              },
            ),
          ),
        ),
      );

      stopwatch.start();

      // Trigger 1000 async updates
      final futures = <Future>[];
      for (int i = 0; i < 1000; i++) {
        futures.add(container
            .read(riverpod.asyncCounterProvider.notifier)
            .incrementAsync());
      }

      await Future.wait(futures);
      await tester.pumpAndSettle();
      stopwatch.stop();

      print(
          '$name: ${stopwatch.elapsedMilliseconds} ms (${updateCount} rebuilds)');

      container.dispose();
    });
  }
}

class PipeXAsyncStreamBenchmark extends BenchmarkBase {
  PipeXAsyncStreamBenchmark() : super('PipeX Async Stream (1000 updates)');

  @override
  void run() {
    testWidgets('PipeX async test', (WidgetTester tester) async {
      final stopwatch = Stopwatch();
      final hub = pipex.AsyncCounterHub();
      int updateCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: HubProvider<pipex.AsyncCounterHub>(
            create: () => hub,
            child: Sink<int>(
              pipe: hub.count,
              builder: (context, value) {
                updateCount++;
                return Text('$value');
              },
            ),
          ),
        ),
      );

      stopwatch.start();

      // Trigger 1000 async updates
      final futures = <Future>[];
      for (int i = 0; i < 1000; i++) {
        futures.add(hub.incrementAsync());
      }

      await Future.wait(futures);
      await tester.pumpAndSettle();
      stopwatch.stop();

      print(
          '$name: ${stopwatch.elapsedMilliseconds} ms (${updateCount} rebuilds)');

      hub.dispose();
    });
  }
}

// ============================================================================
// Concurrent Update Benchmark
// Tests handling of concurrent state modifications
// ============================================================================

class BlocConcurrentBenchmark extends BenchmarkBase {
  BlocConcurrentBenchmark() : super('BLoC Concurrent Updates');

  @override
  void run() {
    testWidgets('BLoC concurrent test', (WidgetTester tester) async {
      final stopwatch = Stopwatch();
      final multiBloc = bloc.MultiCounterBloc(50);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: multiBloc,
            child: BlocBuilder<bloc.MultiCounterBloc, bloc.MultiCounterState>(
              builder: (context, state) => const SizedBox(),
            ),
          ),
        ),
      );

      stopwatch.start();

      // Simulate concurrent updates to different counters
      final futures = <Future>[];
      for (int round = 0; round < 20; round++) {
        for (int id = 0; id < 50; id++) {
          futures.add(Future.delayed(
            Duration(microseconds: id * 10),
            () {
              multiBloc.increment(id);
              return tester.pump();
            },
          ));
        }
      }

      await Future.wait(futures);
      await tester.pumpAndSettle();
      stopwatch.stop();

      print(
          '$name: ${stopwatch.elapsedMilliseconds} ms (1000 concurrent updates)');

      multiBloc.close();
    });
  }
}

class PipeXConcurrentBenchmark extends BenchmarkBase {
  PipeXConcurrentBenchmark() : super('PipeX Concurrent Updates');

  @override
  void run() {
    testWidgets('PipeX concurrent test', (WidgetTester tester) async {
      final stopwatch = Stopwatch();
      final hub = pipex.MultiCounterHub(50);

      await tester.pumpWidget(
        MaterialApp(
          home: HubProvider<pipex.MultiCounterHub>(
            create: () => hub,
            child: const SizedBox(),
          ),
        ),
      );

      stopwatch.start();

      // Simulate concurrent updates to different counters
      final futures = <Future>[];
      for (int round = 0; round < 20; round++) {
        for (int id = 0; id < 50; id++) {
          futures.add(Future.delayed(
            Duration(microseconds: id * 10),
            () {
              hub.increment(id);
              return tester.pump();
            },
          ));
        }
      }

      await Future.wait(futures);
      await tester.pumpAndSettle();
      stopwatch.stop();

      print(
          '$name: ${stopwatch.elapsedMilliseconds} ms (1000 concurrent updates)');

      hub.dispose();
    });
  }
}

// ============================================================================
// Stream Processing Benchmark
// Tests handling of continuous stream data
// ============================================================================

class BlocStreamProcessingBenchmark extends BenchmarkBase {
  BlocStreamProcessingBenchmark() : super('BLoC Stream Processing');

  @override
  void run() {
    testWidgets('BLoC stream test', (WidgetTester tester) async {
      final stopwatch = Stopwatch();
      final asyncBloc = bloc.AsyncCounterBloc();
      int finalValue = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: asyncBloc,
            child: BlocBuilder<bloc.AsyncCounterBloc, bloc.CounterState>(
              builder: (context, state) {
                finalValue = state.value;
                return Text('${state.value}');
              },
            ),
          ),
        ),
      );

      stopwatch.start();

      // Process rapid stream
      await for (final value in asyncBloc.rapidStream(500)) {
        asyncBloc.add(bloc.SetValueEvent(value));
        await tester.pump();
      }

      await tester.pumpAndSettle();
      stopwatch.stop();

      print(
          '$name: ${stopwatch.elapsedMilliseconds} ms (final value: $finalValue)');

      asyncBloc.close();
    });
  }
}

class PipeXStreamProcessingBenchmark extends BenchmarkBase {
  PipeXStreamProcessingBenchmark() : super('PipeX Stream Processing');

  @override
  void run() {
    testWidgets('PipeX stream test', (WidgetTester tester) async {
      final stopwatch = Stopwatch();
      final hub = pipex.AsyncCounterHub();
      int finalValue = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: HubProvider<pipex.AsyncCounterHub>(
            create: () => hub,
            child: Sink<int>(
              pipe: hub.count,
              builder: (context, value) {
                finalValue = value;
                return Text('$value');
              },
            ),
          ),
        ),
      );

      stopwatch.start();

      // Process rapid stream
      await for (final value in hub.rapidStream(500)) {
        hub.count.value = value;
        await tester.pump();
      }

      await tester.pumpAndSettle();
      stopwatch.stop();

      print(
          '$name: ${stopwatch.elapsedMilliseconds} ms (final value: $finalValue)');

      hub.dispose();
    });
  }
}

// ============================================================================
// Run all async benchmarks
// ============================================================================

void runAsyncBenchmarks() {
  print('\n=== ASYNC BENCHMARKS ===\n');

  print('Async Stream Performance:');
  BlocAsyncStreamBenchmark().run();
  RiverpodAsyncStreamBenchmark().run();
  PipeXAsyncStreamBenchmark().run();

  print('\nConcurrent Updates:');
  BlocConcurrentBenchmark().run();
  PipeXConcurrentBenchmark().run();

  print('\nStream Processing:');
  BlocStreamProcessingBenchmark().run();
  PipeXStreamProcessingBenchmark().run();
}
